#include <RcppArmadillo.h>
#include <algorithm>    // std::count_if
#include <iostream>   	// std::count
#include <vector> 		// push_back
// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::depends(RcppEigen)]]

#include <RcppEigen.h>
using namespace Rcpp;
using  Eigen::Map;
using  Eigen::VectorXd;
typedef  Map<VectorXd>  MapVecd;

//--------------------------------------------------------------------------//
// ATRIUM: Erickson & Kruschke (1998)
// Author: René Schlegelmilch (University of Zurich, University of Bremen)

// Notes: 
// 1. set absval (below) to 0 to have teaching signals as reported in the 
// paper. However, leave them at -1 to make them actually 'work'
// (i.e. they teach logistic nodes, which also need to become negative (not 
//  zero) to'improve' over learning.
// 2. all initializations are set to zero, which is not disclosed in
// the paper. 
// 3. Humble teacher only; and attention nodes are non-normalized.
//---------------------------------------------------------------------------//



//---------------------------------------------------------------------------//
// [[Rcpp::export]]
List cppATRIUM(List st, NumericMatrix tr, bool xtdo = false) {

//// task variables and model settings import from R
// see rmd for variable descriptions (var names are the same below)
//--------------------------------------------------------------------------//
    int cats = as<int>(st["nCat"]);
    double dims = as<double>(st["nFeat"]);
    
    NumericVector prime_dim = as<NumericVector>(st["prime_dim"]);
    NumericVector beta = as<NumericVector>(st["beta"]);
    NumericVector cost = as<NumericVector>(st["cost"]);
    NumericVector y_r = as<NumericVector>(st["y_r"]);
    
    double y_g = as<double>(st["y_g"]);
	double c = as<double>(st["c"]);
	double phi = as<double>(st["phi"]);
	double beta_g = as<double>(st["beta_g"]);
	double lambda_r = as<double>(st["lambda_r"]);
	double lambda_e = as<double>(st["lambda_e"]);
	double lambda_a = as<double>(st["lambda_a"]);
	double lambda_g = as<double>(st["lambda_g"]);
	
	bool xtdo1 = xtdo;
	NumericMatrix tr_C =tr;
	NumericMatrix exemplars_C = as<NumericMatrix>(st["exemplars"]);
	int absval =-1;
//--------------------------------------------------------------------------//    


//// General setup, relevant variables pre-processing
//--------------------------------------------------------------------------//
 	// Number of exemplars
 	int n_ex_C = exemplars_C.nrow(); 
 	
 	// Number of trials
    int n_trials = tr_C.nrow();
    
    // number of dimensions with rules
    int nRules =prime_dim.size();
    
    // which one is the ctrl column in tr?
    CharacterVector trcolX=colnames(tr_C);
    int ictrl=0;
    for (int i=0;i<trcolX.size();i++){
        if (trcolX[i]=="ctrl") ictrl=i;
    }
    // Create Vectors that hold column indices of x1, x2 .. , and t1, t2, ..
    IntegerVector cX(cats);  //t1, t2, ..
    IntegerVector dX(dims);  //x1, x2, .. 
    int iC=0;
    int iX=0;
    for (int i=0;i<trcolX.size();i++){
        if (trcolX[i]=="t1") iC=i;
        if (trcolX[i]=="x1") iX=i;
    }
    for (int i=0;i<cats;i++) {
         cX[i]=iC+i;
    };
    for (int i=0;i<dims;i++) {
         dX[i]=iX+i;
    };
    

    // Dummy variable used in E2 for indexing the two rule nodes [0,1]
    NumericVector dumI(2);
    // and another which can later be changed based on dumI and the nRules 
    NumericVector dumII(2);
    for (int i=0; i<2; i++){
    	dumI[i]=i;
    }

	// Initialize a_rk (rule activation E2) at zero
	// adds zero line in any case to circumvent aggregation errors with 
	// summation, as done in E2, if there is only one rule.
	// Summing would be necessary if there are more than 1 rule dimensions.
    NumericMatrix  ark(prime_dim.size()+1,cats);
    for (int d=0; d<(prime_dim.size());d++){
    	 for (int k=0; k<cats;k++){
    	 	ark(d,k)=0;
    	 }
    }
    // used for E3
    NumericVector e_probs(cats);
    NumericMatrix w_r(nRules*2,cats); 
    
    // exemplar response weights (E4)
    NumericMatrix w_e(cats,n_ex_C); 
    
	// exemplar gate weights (E5)
    NumericVector w_g(n_ex_C); 
    
	// stimulus and category input vectors
    NumericVector a_input(dims);
    IntegerVector c_input(cats);
    
   // attention weights (e.g., E3)
   NumericVector alpha(dims);
   for (int i=0;i<dims;i++){
			alpha[i]=1/dims;
	}
			
	// teaching signal vector: rule 
	NumericVector t_r(cats);
	// teaching signal vector: exemplars 
	NumericVector t_e(cats);
			
	// gate activation (E5)
	NumericVector a_g(2);
	
	// exemplar update delta
	NumericMatrix delta_w_e(n_ex_C, cats);
	// everything else is done within the loop below
//--------------------------------------------------------------------------//   
   
   
   
 // Output trackers
//--------------------------------------------------------------------------//
        // Trial Predictions (before update)
        NumericMatrix track_probs(n_trials,cats); 
        // all below are stored - after the update in a corresponding trial
        // so becoming effective in the 'next trial'
        // exemplar associations
        NumericMatrix track_w_g(n_trials,n_ex_C); 
        // Exemplar to rule associations
        arma::cube track_wr(cats,n_trials, nRules*2);
        // exemplar to response weights
        arma::cube track_w_e(cats,n_trials, n_ex_C);
        // gate activations in each trial
        NumericMatrix track_a_g(n_trials,2); 
        // attention weights in each trial (after update)
        NumericMatrix track_alpha(n_trials,dims); 

//--------------------------------------------------------------------------//


for (int j=0; j<(n_trials);j++ ){

	// trial input: // 
	for (int i=0; i<dims;i++ ){
		a_input[i]=tr_C(j,dX[i]);
	}
	for (int i=0; i<cats;i++ ){
		c_input[i]=tr_C(j,cX[i]);
	}
	// trial input end // 
	
		
    // Re/Initialize //
	//-----------------------------------------------------------------//    
    if (tr(j,ictrl)==1){
        // initialize
        // rule response gains (one link to each what?
        for (int i=0; i<cats;i++){
        	for (int nr=0; nr<nRules*2;nr++){
        		w_r(nr,i)=0;
        	}
        }
        // exemplar response gains
        for (int i=0; i<cats;i++){
        	for (int nr=0; nr<n_ex_C;nr++){
        		w_e(nr,i)=0;
        	}
        }
        for (int nr=0; nr<n_ex_C;nr++){
        		w_g[nr]=0;
        	}
        

        // dimension attention
		for (int i=0;i<dims;i++){
			alpha[i]=0;
		}
    }
    // Re/Initialize end //
	//-----------------------------------------------------------------//    
	
	
		
	// Rule Activation  (E1)  //
	//-----------------------------------------------------------------//    
	NumericMatrix  act2(prime_dim.size(),2);
    for (int i=0;i<prime_dim.size();i++){
    	act2(i,0)=1-
    		pow(1+exp(
    			-y_r[prime_dim[i]-1]*(a_input[prime_dim[i]-1]
    			+beta[prime_dim[i]-1])
    		),-1);
    	act2(i,1)=1-act2(i,0);
    }
    
    // act2(ruledimensions, [small vs large]) matrix for current trial
    // Note: The model here is allowed to have more
    // than one rule dimension. E.g. if prime_dim is defined as 
    // prime_dim=c(1,2), then t1 and t2 are treated as the rule dimensions,
    // and act2 row one would indicate t1, and act2 row 2 would indicate t2
    // these these are trivial sigmoid functions, they are not tracked.
    // NOT ... more than 1 dim would require special treatment of w_r
    
    // Rule Activation  (E1)  end // 
    //-----------------------------------------------------------------//   
    
    // Rule output activation (E2) //
	//-----------------------------------------------------------------//    
     NumericVector   r_probs(cats);
    for (int k=0;k<cats;k++){
    	for (int d=0;d<prime_dim.size();d++){
    	dumII=d*2+dumI;
    	double om1=0;
			for (int r=0;r<2;r++){
    			om1+=act2(d,r)*w_r(dumII[r],k) ;
    			}
    	ark(d,k)=om1;
    	}
    }
    for (int k=0;k<cats;k++){
    r_probs[k]=sum(ark(_,k));
    }
   	// Rule output activation (E2) end //
	//-----------------------------------------------------------------//   
    
    
    
    // ALCOVE output activation (E3) //
	//-----------------------------------------------------------------//    
		NumericVector e_activate(n_ex_C);
    NumericMatrix e_later(n_ex_C,dims); // used in (E14)
    double om2=0;
    double om3=0;
    for (int i=0; i<n_ex_C;i++){
      om2=0;
      om3=0;
      for (int n=0; n<dims;n++){
        om3=exemplars_C(i,n);
        om2+=alpha[n]*abs(om3-a_input[n]);
        e_later(i,n)=abs(om3-a_input[n]) ;// for the ,,, attention update...
      }
     
      e_activate[i]=exp(-.5*c*om2);
    }
    for (int k=0; k<cats;k++){
      e_probs[k]=0;
      for (int i=0; i<n_ex_C;i++){
    	  e_probs[k]+=w_e(i,k)*e_activate[i]; //
      }
    }
    // Note that, if every trial has a known exemplar, and if c > 10,
    // then e_activate[i] for the current exemplar will always be almost 1
    // because no generalization/interference from other exemplars.
    // This means the predictions are solely based on w_e, which
    // has been shown and criticized as over-fitting by Jäkel et al (2008).
    // (Of course, the w_e learning rate will then indicate the speed of
    // optimal learning, which freely fits 'overall' 
    // probability of accuracy within the moving window of trials).
    
    // ALCOVE output activation (E3) end //
	//-----------------------------------------------------------------//    


	// Gating Node (E5) //
	//-----------------------------------------------------------------//   
	// note: a_g[0] is exemplar gate; a_g[1] is rule gate
	double om4=0;
	for (int i=0; i<n_ex_C;i++){
		om4+=w_g[i]*e_activate[i];
	}
	// note: positive values of w_g will activate the exemplar gate,
    // negative values the rule gate
	a_g[0]=pow(1+exp(-y_g*(om4+beta_g)),-1);
	a_g[1]=1-a_g[0];

	// Gating Node (E5) end //
	//-----------------------------------------------------------------//   

	
	
	// Response Probability (E6) //
	//-----------------------------------------------------------------//    
		NumericVector probs(cats);
    for (int k=0; k<cats;k++){
    	probs[k]= a_g[0]*exp(phi*e_probs[k])/sum(exp(phi*e_probs))+
    			  a_g[1]*exp(phi*r_probs[k])/sum(exp(phi*r_probs));
    }
    track_probs(j,_)=probs;
    //debug2(j,_)=r_probs;
    
	//debug(j,_)=probs;


  	// Response Probability (E6)  end //
	//-----------------------------------------------------------------//   
  
  
  
  
  // LEARNING //
  //-----------------------------------------------------------------//   
  if (tr(j,ictrl)!=2){
    
    
	
	// teaching signals //   
	//-----------------------------------------------------------------//    
     for (int k=0; k<cats; k++){
    	if (c_input[k]!=1) { 
    		t_r[k]=absval; // Rule teachers (E7) t_r
    		t_e[k]=absval; // Rule teachers (E7) t_e
    		if (r_probs[k]<absval) {
    			t_r[k]=r_probs[k];
    		}
    		if (e_probs[k]<absval) {
    			t_e[k]=e_probs[k];
    		}
    	}
    	if (c_input[k]==1) {
    		t_r[k]=1;
    		t_e[k]=1;
    		if (r_probs[k]>1) {
    			t_r[k]=r_probs[k];
    		}
    		if (e_probs[k]>1) {
    			t_e[k]=e_probs[k];
    		}
    	}
     }
    // teaching signals end //   
	//-----------------------------------------------------------------//    
    
    
    
    
    // Rule Accuracy (E9) //
	//-----------------------------------------------------------------// 
    
    // I actually am uncertain what the ||t-a ||^2 means
    // The internet says its usual meaning is 'euclidean norm'
    //meaning the length of the vector
    // so (diffk1)^2 +(diffk2)^2 +.. = ||t-a ||^2
    
    // Rule Accuracy //
    double RA=0;
    double mag1=0;
    for (int k=0;k<cats;k++) {
    	mag1+=pow((t_r[k]-r_probs[k]),2);
    }
    RA=exp(-.5*cost[1]*mag1);
    
    // Exemplar Accuracy (10)
    double EA;
    mag1=0;
    for (int k=0;k<cats;k++) {
    	mag1+=pow((t_e[k]-e_probs[k]),2);
    }
    EA=exp(-.5*cost[0]*mag1);

	//  Overall Accuracy (E11, why is there E8...?)
	double MA;
    MA=a_g[0]*EA+a_g[1]*RA;
    
    // Rule Accuracy (E9) end //
	//-----------------------------------------------------------------// 
    
    
    
    
	//    Updates   //
	//-----------------------------------------------------------------//    
		
		
		
    //  Rule to category gain update (E12) //
	//-----------------------------------------------------------------//     
    NumericMatrix delta_w_r(nRules*2, cats);
    for (int d=0;d<prime_dim.size();d++){
    	dumII=d*2+dumI;
    	for (int i=0;i<2;i++){
    		for (int k=0;k<cats;k++){
    			delta_w_r(dumII[i],k)=lambda_r*(t_r[k]-r_probs[k])*
    				act2(d,i)*((cost[1]*RA*a_g[1])/MA);
    		}
    	}
    }
    //  Rule to category gain update (E12) end //
	//-----------------------------------------------------------------//     
    
    
    
    // Exemplar to category gain update (E13) //
	//-----------------------------------------------------------------// 
    for (int n=0;n<(n_ex_C);n++){
    	for (int k=0;k<cats;k++){
    		delta_w_e(n,k)=lambda_e*(t_e[k]-e_probs[k])*
    		e_activate[n]*((cost[0]*EA*a_g[0])/MA);
    	}
    }
    // Exemplar to category gain update (E13) end //
	//-----------------------------------------------------------------// 
	
	
	
	
	
	// Attention Update (E14) //
	//-----------------------------------------------------------------// 
	NumericVector delta_alpha(dims);
	double om5=0;
	double om6=0;
	for (int n =0;n<dims;n++){
		om5=0;
		for  (int i =0;i<n_ex_C;i++){
			om6=0;
			for  (int k =0;k<cats;k++){
				om6+=w_e(i,k)*(t_e[k]-e_probs[k])*((a_g[0]*cost[0]*EA)/MA);
			}
			om5+=om6*e_activate[i]*c*e_later(i,n);
		}
		delta_alpha[n]= -lambda_a*om5;
	}
	// Attention Update (E14) end //
	//-----------------------------------------------------------------// 
	
	
	
	
	
	// Gate Weight Update (E15) //
	//-----------------------------------------------------------------// 
	NumericVector delta_w_g(n_ex_C);
	for (int i=0;i<n_ex_C;i++){
		delta_w_g[i]=
    	lambda_g*(a_g[0]*a_g[1])*y_g*e_activate[i]*((EA-RA)/MA);
	}
    // Gate Weight Update (E15) end //
	//-----------------------------------------------------------------// 
	
	
	
	// Commit updates to weights //
	//-----------------------------------------------------------------// 
	// attention
	alpha=alpha+delta_alpha;
	for (int k=0;k<dims;k++){
		if (alpha[k]<0) alpha[k]=0;
	}
	// exemplar to rule weights
	for (int d=0;d<prime_dim.size();d++){
    	dumII=d*2+dumI;
		for (int k=0;k<cats;k++){
	  		for (int n=0;n<2;n++){
	    		w_r(dumII[n],k)=w_r(dumII[n],k)+delta_w_r(dumII[n],k);
	  		}
		}
	}
	// exemplar to category weights
	for (int k=0;k<cats;k++){
	  for (int n=0;n<n_ex_C;n++){
	    w_e(n,k)=w_e(n,k)+delta_w_e(n,k);
	    track_w_e(k,j,n)=w_e(n,k)+delta_w_e(n,k);
	  }
	}
	
	// exemplar to gate weightes
	  for (int n=0;n<n_ex_C;n++){
	    w_g[n]=w_g[n]+delta_w_g[n];
	  }
	// Commit updates to weights end//
	//-----------------------------------------------------------------// 
  
  
  }  
  // LEARNING END //
  //-----------------------------------------------------------------//   
	
	
	
  // Tracking outside of learning 
  // (what is not tracked here,
  // is not tracked for ctrl!=2)
  //-----------------------------------------------------------------//    
	for (int d=0;d<prime_dim.size();d++){
    	dumII=d*2+dumI;
		for (int k=0;k<cats;k++){
	  		for (int n=0;n<2;n++){
	    		track_wr(k,j,dumII[n])=w_r(dumII[n],k);
	  		}
		}
	}
	track_alpha(j,_)=alpha;
	track_w_g(j,_)=w_g;
	track_a_g(j,_)=a_g;	
	
} // ends j loop
//--------------------------------------------------------------------------//    
        
 
// Output 
//--------------------------------------------------------------------------//

	if (xtdo1==FALSE)   {
    			return  Rcpp::List::create(Named("probs")=track_probs);
    } else {
     			return  Rcpp::List::create(Named("probs")=track_probs,
     									    Named("w_g")=track_w_g,
     										Named("a_g")=track_a_g,
     										Named("alpha")=track_alpha,
     										Named("w_r")=track_wr,
     										Named("w_e")=track_w_e);
    }
}
