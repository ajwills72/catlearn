// Plugin for enabling C++11
// [[Rcpp::plugins(cpp11)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// [[Rcpp::export]]

// TODO define initial state in an st file

// Equation 3
// [[Rcpp::export]]

mat node_activation(rowvec input, mat weights) {
  mat weightA = weights.each_col() % input;
  mat nodeact = cumsum(out, 1);
  return nodeact;
}

// Equation 4
// [[Rcpp::export]]
mat squared_differences(mat o, mat d, int m) {
  mat lms = o % d;
  mat sqdif = (1/m)(sum(square(lms)));
  return sqdif;
}

// Equation 5
// [[Rcpp::export]]
mat LMS_learning(mat o, mat d, double beta) {
  mat error = d - o;
}

// Equation 7
// [[Rcpp::export]]
mat logistic_choice() {

}

// [[Rcpp::export]]
List slpLMSnet(List st, NumericMatrix tr, bool xtdo = false) {


// declare initial state of the model
double    beta = as<double>(st["beta"]);
double    om = as<double>(st["om"]);
int       colskip = as<int>(st["colskip"]);
int       outcomes = as<int>(st["outcomes"]);
const mat initW = as<mat>(st["w"]);

// declare variables for simulation
mat W; W = Rcpp::clone(initw);
mat O;
int m = W.n_rows, n = W.n_cols;
int trow = tr.n_rows; tcol = tr.n_col;
// positions of stimuli and outcomes in each row of tr
vec stimpos = linspace(0, m - 1, m);
vec outpos  = linspace((m - outcomes) - 1, (m - 1), m)
// initialize miscellaneous variables used at different parts of the function
rowvec trian; train = zeros(tcol)
rowvec input; input = zeros(n);
colvec output; output = zeros(outcomes); 
// store outputs
mat activations(trow, as<int>(st["outcomes"]));
mat xOUT(trow, 1)

  // run model

 for (i = 0, i < nrow ; i++) {
   if ( tr(i, 0) == 1 )
   {
    W.fill(initW);
   }
   train = tr.row(i);
   input = train.elem(colskip + stimpos);
   output = tarin.elem(colskip + outpos);
   O = node_activation(input, output, weights);
 }


 return(out)
}
