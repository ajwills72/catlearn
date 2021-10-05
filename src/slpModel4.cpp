// Plugin for enabling C++11
// [[Rcpp::plugins(cpp11)]]
#include <Rcpp.h>
using namespace Rcpp;

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
// Equation 5: Function to calculate output node activation
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

// Equation 6: Function to calculate change in associative weights
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

// Equation 11/12: Function to calculate cue attention
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

// Equation 14: Function to calculate change in salience
NumericVector alpha_delta_calc(NumericVector teacher, NumericVector out_act,
                         NumericVector a_in, NumericVector alpha_i, NumericVector g, NumericMatrix w_in_out,
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
  }    // Calculate exemplar node activations
    a_ex = a_ex_calc(exemplars, a_in, sig, c);
  return gain_delta;
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
  NumericVector sig = as<NumericVector>(st["sigma"]);
  NumericMatrix w_in_out = as<NumericMatrix>(st["w_in_out"]);
  // End of particularly clumsy section
  // Initialisation
  int i,j,k, colFeat1, colt1, length = tr.nrow();
  NumericVector train(tr.ncol()), teacher(nCat), a_in(nFeat), a_ex(nCat), g(nFeat);
  NumericVector alpha_i(nFeat), out_act(nCat), probs(nCat), g_inits(nFeat), gain_delta(nFeat);
  NumericMatrix weight_delta = NumericMatrix(clone(w_in_out));
  NumericMatrix exgain_delta = NumericMatrix(clone(w_exemplars));
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
    train = exrow(tr, i);
    // Get input node activations
    for(j = 0; j < a_in.size(); j++){
      a_in(j) = train(colFeat1+j);
    }
    // Get teacher signals
    for(j=0;j<teacher.size();j++){
      teacher(j) = train(colt1+j);
    }
    // Conditional to establish whether the state of the
    // model needs resetting
    if(train(0) == 1){
      upd_w_in_out = NumericMatrix(clone(w_in_out));
    }
    // Calculate cue attention
    alpha_i = alpha_i_calc(g, a_in, P);
    // Calculate output node activation
    out_act = out_act_calc(upd_w_in_out, alpha_i);
    // Calculate probabilities of choosing each category
    probs = probs_calc(Rcpp::clone(out_act), phi);
    // Now for learning
    // If the ctrl column is set to 2 then learning is frozen
    if (train(0) < 2 ) {
      g_inits = NumericVector(clone(g));
      gain_delta = gain_delta_calc(teacher, out_act, a_in,
                                   alpha_i, Rcpp::clone(g), upd_w_in_out,
                                   l_gain, P);
      for(k=0;k<g.size();k++){
        g(k) = g(k) + gain_delta(k);
        if(g(k) < 0){
          g(k) = 0;
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
    }
    for(j=0;j<probs.size();j++){
      probs_out(i,j) = probs(j);
    }
  }

  if(xtdo) {
    output = Rcpp::List::create(Rcpp::Named("p") = probs_out,
                                Rcpp::Named("w_in_out") = upd_w_in_out,
                                Rcpp::Named("alpha_i") = g);
          } else {
    output = Rcpp::List::create(Rcpp::Named("p") = probs_out,
                                Rcpp::Named("w_in_out") = upd_w_in_out);
           }
  return output;
}
