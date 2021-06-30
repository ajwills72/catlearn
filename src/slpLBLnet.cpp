// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// rows are output nodes
// columns are input nodes

// Equation 16: calculate output node activations
mat node_activation(rowvec input_nodes, mat hidden_weights, double c) {
  mat weightA = weights.each_row() % input;
  mat nodeact = sum(weightA, 1);
  mat nodeact = nodeact_for_each( [](mat& X) { exp(X); } );
  return nodeact;
}

// Equation 17: attentional filter
//
// Equation 18: normalised sigmoid choice function for outcome nodes
//
// Equation 19: local Bayesian updating within the outcome layer
//
// Equation 20: 

Rcpp::List slpLBLnet(List st, arma::mat tr, bool xtdo = false) {
}
