// C++ implementation of the slpEXIT function written by R. Schlegelmilch
// Angus Inkster 5/04/2019 CC-BY-SA 4.0

// Plugin for enabling C++11
// [[Rcpp::plugins(cpp11)]]
#include <Rcpp.h>
using namespace Rcpp;
// For both personal and modular reasons, a number of utility and model functions
// are defined before the full model function

// Equation numbers referenced are from the Appendix of Kruschke (2001)

// Utility Functions

// Function to extract row from df
NumericVector exrow(DataFrame x, int row) {
  int nCols=x.size();
  NumericVector exrow(nCols), nRows = x[0];
  for (int j = 0; j<nCols;j++) {
    NumericVector column(nRows.length());
    if (TYPEOF(x[j]) == 14){
      column = x[j] ;
    }
    exrow[j] = column[row] ;
  }
  return exrow;
}   

// Function to find position of specific string in string vector
int posfind(StringVector names, std::string element){
  int i, position;
  position = 0;
  for(i=0;i<names.size();i++){
    if(names[i] == element){
      position = i;
    }
  }
  return position;
}

// Model Functions

// Equation 1: Function to calculate output node activation
NumericVector out_act_calc(NumericMatrix w_in_out, NumericVector alpha_i){
  int i, j, nrow = w_in_out.nrow(), ncol = w_in_out.ncol();
  NumericVector out_act(nrow);
  for(i=0; i < nrow; i++){
    NumericVector acts(ncol);
    for(j=0; j < ncol; j++){
      acts(j) = w_in_out(i,j) * alpha_i(j);
    }
    out_act(i) = sum(acts);
  }
  return out_act;
}

// Equation 2: Function to calculate category choice probabilities
NumericVector probs_calc(NumericVector out_act, double phi){
  int i, ncol = out_act.size();
  NumericVector probs(ncol);
  out_act = exp(out_act * phi);
  for (i=0; i < ncol; i++){
    probs(i) = out_act(i)/sum(out_act);
  }
  return probs;
}

// Equation 3: Function to calculate exemplar activations
NumericVector a_ex_calc(NumericMatrix exemplars, NumericVector a_in, NumericVector sig, double c){
  int i, j, nrow = exemplars.nrow(), ncol = exemplars.ncol();
  NumericVector a_ex(nrow);
  for(i=0; i < nrow; i++){
    NumericVector diffs(ncol);
    for(j=0; j < ncol; j++){
      diffs(j) = sig(j) * std::abs(exemplars(i,j) - a_in(j));
    }
    a_ex(i) = exp(-1 * c * sum(diffs));
  }
  return a_ex;
}

// Equation 4: Function to calculate gain node activation
NumericVector g_calc(NumericMatrix w_exemplars, NumericVector a_in, NumericVector a_ex, NumericVector sig){
  int i, j, nrow = w_exemplars.nrow(), ncol = w_exemplars.ncol();
  NumericVector g(ncol);
  NumericVector exemstep(ncol);
  for(i=0; i < ncol; i++){
    NumericVector isum(nrow);
    for(j=0; j < nrow; j++){
      isum(j) = w_exemplars(j,i) * a_ex(j);
    }
    exemstep(i) = exp(sum(isum));
    if(exemstep(i) == (1.0/0.0)){
      exemstep(i) = std::numeric_limits<double>::max();
    }
    if(exemstep(i) == (-1.0/0.0)){
      exemstep(i) = -std::numeric_limits<double>::max();
    }
    g(i) =  a_in(i) * sig(i) * exemstep(i);
  }
  return g;
}

// Equation 5: Function to calculate cue attention
NumericVector alpha_i_calc(NumericVector g, NumericVector a_in, double P){
  int i, ncol = g.size();
  NumericVector alpha_i(ncol);
  NumericVector sumstep(ncol);
  for(i=0; i < ncol; i++){
    sumstep(i) = pow(g(i),P);
    if((sumstep(i) == 0) & (a_in(i) == 1)){
      sumstep(i) = std::numeric_limits<double>::min();
    }
  }
  for(i=0; i < ncol; i++){
  alpha_i(i) = g(i)/pow(sum(sumstep),(1/P));
  }
  return alpha_i;
}

// Equation 7: Function to calculate change in gain nodes
NumericVector gain_delta_calc(NumericVector teacher, NumericVector out_act, NumericVector a_in,
                         NumericVector alpha_i, NumericVector g, NumericMatrix w_in_out,
                         double l_gain, double P){
  int i, j, nrow = w_in_out.nrow(), ncol = w_in_out.ncol();
  double E3;
  NumericVector gain_delta(ncol), E1(teacher.size()), Ex(ncol);
  NumericMatrix E2(nrow,ncol),lhs(ncol,nrow),rhs(ncol,nrow);
  for(i=0; i < teacher.size(); i++){
    E1(i) = teacher(i) - out_act(i);
  }
  for(i=0; i < nrow; i++){
    for(j=0; j < ncol; j++){
    lhs(j,i) = a_in(j) * w_in_out(i,j);
    rhs(j,i) = pow(alpha_i(j),(P-1)) * out_act(i);
    E2(i,j) = lhs(j,i) - rhs(j,i);
    }
  }
  for(i=0; i < ncol; i++){
    NumericVector temp(teacher.size());
    for(j=0; j < nrow; j++){
      temp(j) = E1(j) * E2(j,i);
    }
    Ex(i) = sum(temp);
  }
  for(i=0; i < ncol; i++){
    g(i) = pow(g(i),P);
  }
  E3 = pow(sum(g),(1/P));
  for(i=0; i < ncol; i++){
    gain_delta(i) = l_gain * (Ex(i)/E3);
  }
  return gain_delta;
}

// Equation 8: Function to calculate change in associative weights
NumericMatrix weight_delta_calc(NumericVector teacher, NumericVector out_act, NumericVector alpha_i){
  int i, j, nrow = teacher.size(), ncol = alpha_i.size();
  NumericMatrix weight_delta(nrow,ncol);
  for(i=0; i < nrow; i++){
    for(j=0; j < ncol; j++){
      weight_delta(i,j) = ((teacher(i) - out_act(i)) * alpha_i(j));
    }
  }
  return weight_delta;
}

// Equation 9: Function to calculate change in weights from exemplar to gain nodes
NumericMatrix exgain_delta_calc(NumericVector g, NumericVector g_inits, NumericVector a_ex, 
                           NumericMatrix exemplars){
  int i,j, nrow = exemplars.nrow(), ncol = exemplars.ncol();
  NumericVector lhs(ncol);
  NumericMatrix exgain_delta(nrow,ncol),rhs(ncol,nrow);
  for(i=0; i < nrow; i++){
    for(j=0; j < ncol; j++){
      lhs(j) = g(j) - g_inits(j);
      rhs(j,i) = (exemplars(i,j) * a_ex(i)) * g_inits(j);
      exgain_delta(i,j) = (lhs(j) * rhs(j,i));
    }
  }
  return exgain_delta;
}

// The function that follows is the full slpexit function in C++
// It uses the above functions for speed and modularity
// [[Rcpp::export]]
List slpEXIT(List st, DataFrame tr, bool xtdo = false){
  // This clumsy section copies stuff out of an R List
  // There seems to be no way in RCpp to get direct access to
  // a List at input?
  int nFeat = as<int>(st["nFeat"]);
  int nCat = as<int>(st["nCat"]);
  int iterations = as<int>(st["iterations"]);
  double phi = as<double>(st["phi"]);
  double c = as<double>(st["c"]);
  double P = as<double>(st["P"]);
  double l_gain = as<double>(st["l_gain"]);
  double l_weight = as<double>(st["l_weight"]);
  double l_ex = as<double>(st["l_ex"]);
  NumericVector sig = as<NumericVector>(st["sigma"]);
  NumericMatrix exemplars = as<NumericMatrix>(st["exemplars"]);
  NumericMatrix w_exemplars = as<NumericMatrix>(st["w_exemplars"]);
  NumericMatrix w_in_out = as<NumericMatrix>(st["w_in_out"]);
  // End of particularly clumsy section
  // Initialisation 
  int i,j,k, colFeat1, colt1, length = tr.nrow();
  NumericVector train(tr.ncol()), teacher(nCat), a_in(nFeat), a_ex(nCat), g(nFeat);
  NumericVector alpha_i(nFeat), out_act(nCat), probs(nCat), g_inits(nFeat), gain_delta(nFeat);
  NumericMatrix weight_delta = NumericMatrix(clone(w_in_out));
  NumericMatrix exgain_delta = NumericMatrix(clone(w_exemplars));
  NumericMatrix upd_w_exemplars = NumericMatrix(clone(w_exemplars));
  NumericMatrix upd_w_in_out = NumericMatrix(clone(w_in_out));
  NumericMatrix probs_out(length,nCat);
  List output;
  // Setup output matrix
  NumericMatrix outmat(length,nCat);
  StringVector trnames = tr.names();
  colFeat1 = posfind(trnames,"x1");
  colt1 = posfind(trnames,"t1");
  // Run loop for length of training matrix
  for(i=0;i<length;i++){
    // Initial setup for current trial
    train = exrow(tr,i);
    // Get input node activations
    for(j=0;j<a_in.size();j++){
      a_in(j) = train(colFeat1+j);
    }
    // Get teacher signals
    for(j=0;j<teacher.size();j++){
      teacher(j) = train(colt1+j);
    }
    // Calculate exemplar node activations
    a_ex = a_ex_calc(exemplars, a_in, sig, c);
    // Conditional to establish whether the state of the
    // model needs resetting
    if(train(0) == 1){
      upd_w_exemplars = NumericMatrix(clone(w_exemplars));
      upd_w_in_out = NumericMatrix(clone(w_in_out));
    }
    // Calculate gain node activations
    g = g_calc(upd_w_exemplars, a_in, a_ex, sig);
    // Calculate cue attention
    alpha_i = alpha_i_calc(g, a_in, P);
    // Calculate output node activation
    out_act = out_act_calc(upd_w_in_out, alpha_i);
    // Calculate probabilities of choosing each category 
    probs = probs_calc(Rcpp::clone(out_act), phi);
    // Now for learning
    // If the ctrl column is set to 2 then learning is frozen
    if (train(0) < 2 ){
      g_inits = NumericVector(clone(g));
      for(j=0;j<iterations;j++){
        gain_delta = gain_delta_calc(teacher, out_act, a_in,
                                     alpha_i, Rcpp::clone(g), upd_w_in_out,
                                     l_gain, P);
        for(k=0;k<g.size();k++){
          g(k) = g(k) + gain_delta(k);
          if(g(k) < 0){
            g(k) = 0;
          }
        }
        alpha_i = alpha_i_calc(g, a_in, P);
        out_act = out_act_calc(upd_w_in_out, alpha_i);
      }
      weight_delta = weight_delta_calc(teacher, out_act, alpha_i);
      for(j=0;j<upd_w_in_out.nrow();j++){
        for(k=0;k<upd_w_in_out.ncol();k++){
          upd_w_in_out(j,k) = upd_w_in_out(j,k) + (weight_delta(j,k) * l_weight);
        }
      }
      exgain_delta = exgain_delta_calc(g, g_inits, a_ex, exemplars);
      for(j=0;j<upd_w_exemplars.nrow();j++){
        for(k=0;k<upd_w_exemplars.ncol();k++){
          upd_w_exemplars(j,k) = upd_w_exemplars(j,k) + (exgain_delta(j,k) * l_ex);
        }
      }
    }
    for(j=0;j<probs.size();j++){
      probs_out(i,j) = probs(j);
    }
    
  }
  if(xtdo){output = Rcpp::List::create(Rcpp::Named("p") = probs_out,
                                       Rcpp::Named("w_in_out") = upd_w_in_out,
                                       Rcpp::Named("w_exemplars") = upd_w_exemplars,
                                       Rcpp::Named("g") = g);} else {
           output = Rcpp::List::create(Rcpp::Named("p") = probs_out,
                                       Rcpp::Named("w_in_out") = upd_w_in_out,
                                       Rcpp::Named("w_exemplars") = upd_w_exemplars);
                                   }
  return output;
}
