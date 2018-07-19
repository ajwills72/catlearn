// COVIS model, implemented as a list processor

// Written in C++11 with tempaltes from Rcpp in R Comments using
// equ. or page numbers refer to Ashby et al. (2011)

// [[Rcpp::plugins(cpp11)]]
#include <Rcpp.h>
#include <iostream>
using namespace Rcpp;

// Utility functions

double poisvar(double lambda){
  // Sample Poisson
  double poisvar = R::rpois(lambda);
  return poisvar;
}

double epsilon(double nvar){
  // Sample normally-distributed random noise
  double epsilon = R::rnorm(0,nvar);
  return epsilon;
}

NumericMatrix symat(int stims,int cats){
  // Generate matrix of initial synapse strengths. stims - Number of
  // sensory cortex units. cats - Number of striatal units
  int i,j;
  double u;
  NumericMatrix smat(stims,cats);
  for(i=0;i < cats; i++){
    for(j=0;j < stims; j++){
      u = R::runif(0,1);
      smat(j,i) = 0.001 + (0.0025 * u);
    }
  }
  return smat;
}

// Explicit system

double disfunc(double stimval,double deccrit){
  // Calculate discriminant value, Eq. 1
  double disval = stimval - deccrit;
  return disval;
}

int expres(double disval, double nvar,int crule){
  // Explicit system response ruile, p.68.  disval - discriminant
  // value (h_v).  nvar - noise (sigma_v)
  int Response;
  double eps = epsilon(nvar);
  if(disval < eps)
  {Response = 1;}
  else
  {Response = 2;}
  return Response;
}

int acccheck(int resp, NumericVector tr,int colskip,
             int stimdim){
  // Is response accurate? 
  int acc;
  acc = 0;
  if ((resp == 1) & (tr[colskip+stimdim] == 1)) acc = 1;
  if ((resp == 2) & (tr[colskip+stimdim] == -1)) acc = 1;
  return acc;
}

double updsal(double corcon, double errcon, double psal,
              int acc){
  // Update rule salience - equ. 2 & 3.  corcon - delta C.  errcon -
  // delta E.  psal - Z.  acc = 1 if correct, 0 if incorrect.
  double tsal;
  if (acc == 1){
    tsal = psal + corcon;
  }
  else{
    tsal = psal - errcon;
  }
  return tsal;
} 

double prerule(double rulsal,double perscon){
  // Add perseveration constant, Equ. 4.
  double rulweight = rulsal + perscon;
  return rulweight;
}
 
double ranrule(double rulsal,double lambda){
  // Add Poisson sample, Equ. 5.
  double pois = poisvar(lambda);
  double rulweight = rulsal + pois;
  return rulweight;
}

int rchoose(NumericVector exprules, double stocon){
  // Choose a rule based on the probabilities of those rules.
  // Probabilities come from Eq.7.  exprules - The rule weights.
  // stocon - parameter a (see .Rd file).
  int i,rsec;
  double sumsto;
  NumericVector selrules,storules,res;
  // Calculate probabilities
  selrules = exprules;
  storules = exprules;
  for(i=0;i < storules.size(); i++) {
    storules[i] = pow(storules[i],stocon);}
  sumsto = sum(storules);
  for(i=0;i < storules.size(); i++) {
    selrules[i] = storules[i]/sumsto;}
  // Select a rule
  res = selrules;
  std::partial_sum(selrules.begin(), selrules.end(),
                   res.begin());
  double val = (double)R::runif(0,1);
  for(i=0;i < res.size();i++){
    if (res[i] > val) {rsec = i;break;}
    else {rsec = -1;}
  }
  return rsec;
}

// Implicit system

double scuact(double sconst,double diff){
  // Assist calculataion of sensory unit activation on a trial. Part
  // of Equ. 8.  sconst: alpha diff: distance
  double act,super,e;
  super = -(pow(diff,2)/sconst);
  e = 2.718282;
  act = pow(e,super);
  return act;
}

NumericVector actcalc(NumericMatrix scumat,
                      NumericVector cstim, double sconst){
  // Calculate the activation of sensory cortex, Equ.8 of P+W2012.
  // scumat: Co-ordinates of the sensory cortex units in psychological
  // space.  cstim: Co-ordinates of the presented stimulus.  sconst:
  // alpha (Equ.8).
  int i,j,nrow = scumat.nrow(), ncol = scumat.ncol();
  NumericVector dists(nrow);
  for(i=0;i < nrow;i++){
    NumericVector diffs(ncol);
    for(j=0;j < ncol;j++){
      diffs(j) = (scumat(i,j) - cstim(j));
      diffs(j) = pow(diffs(j),2);
    }
    dists(i) = sqrt(sum(diffs));
  }
  for(i=0;i < nrow;i++){
    dists(i) = scuact(sconst,dists(i));
  }
  return dists;
}

NumericVector stract(NumericMatrix wkj,NumericVector ik,
                     double noisecon){
  // Calculate the activation of striatal units, Equ 9.  wkj:
  // sensory-striatal link strengths.  ik: Activation of sensory
  // cortical units.  noisecon: Normally distributed noise (variance
  // constant).
  int i,j,nrow = wkj.nrow(), ncol = wkj.ncol();
  double noise;
  NumericVector sumact(ncol);
  for(i=0;i < ncol;i++){
    noise = epsilon(noisecon);
    for(j=0;j < nrow;j++){
      sumact(i) = sumact(i) + (wkj(j,i) * ik(j));
    }
    sumact(i) = sumact(i) + noise;
  }
  return sumact;
}

int decact(NumericVector sumact){
  // Make a decision based on summed activations
  int i,act=0,ncol = sumact.size();
  double largeact;
  largeact = max(sumact);
  for(i=0;i < ncol;i++){
    if (sumact(i) == largeact){act = i + 1;}
    }
  return act;
}

// Learning equations

// Dopamine release 

double obtrew(int acc){
  // Calculate obtained reward, part of Eq.13.
  double rew;
  if (acc == 1){rew = 1;}
  if (acc == 0){rew = -1;}
  if (acc == -1){rew = 0;}
  return rew;
}

double prerew(double prep,double prer,double precon){
  // Calculate predicted reward, Eq. 12.  prep: previous P.  prer:
  // previous R. precon - ???
  double rew,add;
  add = precon*(prer-prep);
  rew = prep + add;
  return rew;
}

double doprel(double obtrew, double prerew){
  // Calculate dopamine release, Eq. 14. obtrew - obtained reward (1 =
  // correct, 0 = absence of feedback, -1 = incorrect). prerew - ???
  double rpe,dn;
  rpe = obtrew - prerew;
  if (rpe > 1){dn = 1;}
  if ((1 >= rpe) and (rpe > -0.25)){dn = (0.8*rpe)+0.2;}
  if (rpe <= -0.25){dn = 0;}
  return dn;
}

double nsystr(double systr,double act,double sum,double dn,
              double alpha,double beta,double gamma,
              double nmda,double ampa,double dbase,
              double wmax){
  // Equation 10. nsystr - New SYnapse STRength
  
  // Calculated values: systr - SYnapse STRength.  act - sensory
  // cortex activation.  sum - striatal unit activation.  dn -
  // Dopamine released.
  
  // Parameters: alpha - alpha-w.  beta - beta-w.  gamma - gamma-w.
  // nmda - theta nmda.  dbase - dbase.  wmax - wmax.  ampa - theta
  // ampa.
  
  double a1,a2,a3,b1,b2,b3,c1,c2,c3,d1,d2,d3,out;
  double out1,out2,out3;
  // section 1 : increases in strength
  a1 = act * alpha;
  b1 = sum - nmda;
  if (b1 < 0){b1 = 0;}
  c1 = dn -dbase;
  if (c1 < 0){c1 = 0;}
  d1 = wmax - systr;
  if (d1 < 0){d1 = 0;}
  out1 = a1*b1*c1*d1;
  // section 2 : decreases in strength
  a2 = beta * act;
  b2 = sum - nmda;
  if (b2 < 0){b2 = 0;}
  c2 = dbase - dn;
  if (c2 < 0){c2 = 0;}
  d2 = systr;
  out2 = a2*b2*c2*d2;
  // section 3: more decreases in strength
  a3 = gamma * act;
  b3 = nmda - sum;
  if (b3 < 0){b3 = 0;}
  c3 = b3 - ampa;
  if (c3 < 0){c3 = 0;}
  d3 = systr;
  out3 = a3*c3*d3;
  out = systr + out1 - out2 - out3;
  return out;
}

// Run the simulation 
// [[Rcpp::export]]
List slpCOVIS(List st,
              NumericMatrix tr,
              bool crx = true,
              bool respt = false,
              bool rgive = true,
              bool xtdo = false){
// This clumsy section copies stuff out of an R List.
double corcon = as<double>(st["corcon"]);
double errcon = as<double>(st["errcon"]);
double perscon = as<double>(st["perscon"]);
double decsto = as<double>(st["decsto"]);
double decbound = as<double>(st["decbound"]);
double lambda = as<double>(st["lambda"]);
double envar = as<double>(st["envar"]);
double emaxval = as<double>(st["emaxval"]);
double dbase = as<double>(st["dbase"]);
double alphaw = as<double>(st["alphaw"]);
double betaw = as<double>(st["betaw"]);
double gammaw = as<double>(st["gammaw"]);
double nmda = as<double>(st["nmda"]);
double ampa = as<double>(st["ampa"]);
double wmax = as<double>(st["wmax"]);
double invar = as<double>(st["invar"]);
double sconst = as<double>(st["sconst"]);
double prep = as<double>(st["prep"]);
double prer = as<double>(st["prer"]);
double etrust = as<double>(st["etrust"]);
double itrust = as<double>(st["itrust"]);
double ocp = as<double>(st["ocp"]);
double oep = as<double>(st["oep"]);
int colskip = as<int>(st["colskip"]);
int stimdim = as<int>(st["stimdim"]);
int crule = as<int>(st["crule"]);
NumericVector initrules = as<NumericVector>(st["initrules"]);
NumericMatrix initsy = as<NumericMatrix>(st["initsy"]);
NumericMatrix scups = as<NumericMatrix>(st["scups"]);
// End of clumsy section
int i,j,k,cdim=0,rrule = -1,expresp,impresp,expacc=0;
int impacc=0,sresp=0,sused=0,acc=0, nrow = initsy.nrow();
int ncol = initsy.ncol(),length = tr.nrow();
double hvx,hvp,econf,iconf,dn=0,imaxval=0;
List frules,fupdsy;
NumericVector fetrust,fitrust,fcrule,fprep,fprer;
NumericVector train = tr(0,_),acts,sumact,cstim;
NumericMatrix updsy,outmat(length,2);
NumericVector updrules = (clone(initrules));
NumericVector wrules = (clone(initrules));
if (rgive){crule = rchoose(Rcpp::clone(updrules),decsto);}
updsy = symat(initsy.nrow(),initsy.ncol());
// Setup output matrix
if (xtdo){outmat = NumericMatrix(length,45);}
// Run loop for length of training matrix
for(i=0;i<length;i++){
  // Initial setup for current trial
  int l=0,m=0,n=0;
  train = tr(i,_);
  // Reset model to initial state?
  if(train(0) == 1)
  { if (i>0){frules.push_back(updrules);
             fupdsy.push_back(updsy);
             fetrust.push_back(etrust);
             fitrust.push_back(itrust);
             fcrule.push_back(crule);
             fprep.push_back(prep);
             fprer.push_back(prer);}
    crule = as<int>(st["crule"]);
    etrust = as<double>(st["etrust"]);
    itrust = as<double>(st["itrust"]);
    prep = as<double>(st["prep"]);
    prer = as<double>(st["prer"]);
    updrules = NumericVector(clone(initrules));
    wrules = NumericVector(clone(initrules));
    if (rgive){crule = rchoose(Rcpp::clone(updrules),decsto);}
    updsy = symat(initsy.nrow(),initsy.ncol());
  }
  cstim = train[Range(colskip,((colskip-1)+stimdim))];
  // Generate a response from the Explicit system
  cdim = cstim[crule];
  hvx = disfunc(cdim,decbound);
  expresp = expres(hvx,envar,crule);
  // Generate a response from the Implicit system
  acts = actcalc(scups,cstim,sconst);
  sumact = stract(updsy,acts,invar);
  hvp = fabs(sumact(0) - sumact(1));
  impresp = decact(sumact);
  // Decide which system response to use
  econf = fabs(hvx)/emaxval; 
  if(fabs(sumact(0)-sumact(1)) > imaxval)
    {imaxval = fabs(sumact(0)-sumact(1));}
  iconf = hvp/imaxval;
  if((econf*etrust) > (iconf*itrust))
    {sresp = expresp;
     sused = 1;}
  else 
    {sresp = impresp;
     sused = 2;}
  // Freeze learning?   // learning if we desire
  if (train(0) < 2){
  // Update Explicit system rules based on accuracy
  if (respt == true)
    {expacc = acccheck(sresp,train,colskip,stimdim);
     impacc = acccheck(sresp,train,colskip,stimdim);}
  if (respt == false)
    {expacc = acccheck(expresp,train,colskip,stimdim);
     impacc = acccheck(impresp,train,colskip,stimdim);}
  if (sused == 1)
     {acc = acccheck(expresp,train,colskip,stimdim);}
  else
     {acc = acccheck(impresp,train,colskip,stimdim);}
  // Update the explicit system based on the accuracy
  if (expacc == 1)
    {updrules[crule] = updsal(corcon,errcon,
                              updrules[crule],expacc);
     }
  else
    {if (crx == true)
	{rrule = int(R::runif(0,32767)) % updrules.size();}
     if (crx == false)
      {rrule = int(R::runif(0,32767)) % updrules.size();
          for (j=0;j<1000;j++){
            if (crule == rrule)
            {rrule = int(R::runif(0,32767)) % updrules.size();}
            else
            {break;}
          }
       }
       updrules[crule] = updsal(corcon,errcon,
                                updrules[crule],expacc);
       for(j=0;j<updrules.size();j++){
         if (updrules[j] < 0){updrules[j] = 0;}
       }
       wrules = Rcpp::clone(updrules);
       wrules[crule] = prerule(wrules[crule],perscon);
       wrules[rrule] = ranrule(wrules[rrule],lambda);
       crule = rchoose(Rcpp::clone(wrules),decsto);}
  if (expacc == 1)
    {etrust = etrust + (ocp*(1-etrust));}
  else 
    {etrust = etrust - (oep*etrust);}
  
  // Update Implicit system based on accuracy
  prep = prerew(prep,prer,0.025);
  prer = obtrew(impacc);
  dn = doprel(prer,prep);
  for(j=0;j<nrow;j++){
    for(k=0;k<ncol;k++){
      updsy(j,k) = nsystr(updsy(j,k),acts(j),sumact(k),dn,
            alphaw,betaw,gammaw,nmda,ampa,dbase,wmax);
    }
  }
  // Update the trust in the implicit system
  itrust = 1 - etrust;
  }
  // Update output matrix
  if (sresp == 1){outmat(i,0) = 1;
                  outmat(i,1) = 0;}
  if (sresp == 2){outmat(i,0) = 0;
                  outmat(i,1) = 1;}
  if (xtdo){
            outmat(i,2) = acc;
            outmat(i,3) = sused;
            outmat(i,4) = cdim;
            outmat(i,5) = hvx;
            outmat(i,6) = expresp;
            outmat(i,7) = hvp;
            outmat(i,8) = impresp;
            outmat(i,9) = econf;
            outmat(i,10) = iconf;
            outmat(i,11) = imaxval;
            outmat(i,12) = emaxval;
            outmat(i,13) = expacc;
            outmat(i,14) = impacc;
            outmat(i,15) = respt;
            outmat(i,16) = rrule;
            outmat(i,17) = dn;
            outmat(i,18) = etrust;
            outmat(i,19) = itrust;
            outmat(i,20) = crule;
            outmat(i,21) = prep;
            outmat(i,22) = prer;
            for(j=23;j<27;j++){
              outmat(i,j) = cstim(l);
              l = l + 1;
              }
            for(j=27;j<43;j++){
              outmat(i,j) = acts(m);
              m = m + 1;
              }
            for(j=43;j<45;j++){
              outmat(i,j) = sumact(n);
              n = n + 1;
              }
            }
    }
frules.push_back(updrules);
fupdsy.push_back(updsy);
fetrust.push_back(etrust);
fitrust.push_back(itrust);
fcrule.push_back(crule);
fprep.push_back(prep);
fprer.push_back(prer);
return Rcpp::List::create(Rcpp::Named("foutmat") = outmat,
                          Rcpp::Named("frules") = frules,
                          Rcpp::Named("fsystr") = fupdsy,
                          Rcpp::Named("fetrust") = fetrust,
                          Rcpp::Named("fitrust") = fitrust,
                          Rcpp::Named("frule") = fcrule,
                          Rcpp::Named("fprep") = fprep,
                          Rcpp::Named("fprer") = fprer);
}
