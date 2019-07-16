#include <Rcpp.h>
using namespace Rcpp;

//[[Rcpp::export]]

List slpMK75 (List st, NumericMatrix tr, bool xtdo = false) {
  // Some basic variables
  long i, k;
  long nrow = tr.nrow(), ncol = tr.ncol();

  // Extract initial parameters from the 'st' list.

  // Learning rate
  double lr = as<double>(st["lr"]);
  double alr = as<double>(st["alr"]);
  // colskip
  long colskip = as<long>(st["colskip"]);
  // Initial weights
  NumericVector initw = as<NumericVector>(st["w"]);
  NumericVector initaw = as<NumericVector>(st["alpha"]);
  // Initialise variables for simulation
  long nw = initw.size();
  NumericVector wm(nw);    // associative weights
  NumericVector aw(nw);   // attentional weights
  NumericVector inputs(nw);
  NumericVector activ(nw);
  NumericVector delta(nw);
  NumericVector error(nw);
  NumericVector sumET(nrow);
  NumericMatrix wmOUT(nrow, nw);
  NumericMatrix awOUT(nrow, nw);

  // Set weights to initial weights
  wm = clone(initw);
  aw = clone(initaw);
  // Run simulation
  for (i = 0; i < nrow; ++i) {

    if ( tr(i, 0)  == 1)                   // Reset model to initial state if new participant.
    {
      wm = clone(initw);
      aw = clone(initaw);
    } 

    if ( tr(i, 0) == 3) 
    {           
      wm = clone(initw);                  // Reset weights but not alphas
    }

    for (k = 0; k < nw; ++k) {
      inputs[k] = tr(i, colskip+k);        // Subset stimuli activations at current trial.
      activ[k] = inputs[k] * wm[k];        // Generate current stimuli weights.
    }
    
    sumET[i] = sum(activ);                 // Record output

    for (k = 0; k < nw; ++k) {
      delta[k] = lr * aw[k] * (tr(i, ncol-1) - activ[k]); // Calc change in associative strength.
    }

    if ( tr(i, 0)  != 2) { 
      for (k = 0; k < nw; ++k) {
        // update weights
        wm[k] += delta[k] * inputs[k];              // update attentional strength
        error[k] = sumET[i] - activ[k];             // Calculate the prediction error of all association strength other than k
        aw[k] += alr * fabs(tr(i, ncol-1) - error[k]) - fabs(tr(i, ncol-1) - activ[k]) * inputs[k];
        }
    }

    for (k = 0; k < nw; ++k) {
      if (aw[k] > 1) {
        aw[k] = 1;
      } else if (aw[k] < 0.1) {
      aw[k] = 0.1;
      }
    }

    if (xtdo) {
      wmOUT(i, _) = wm;                    // If xtdo = true, record updated weights to
      awOUT(i, _) = aw;
                                          // relevant row (i.e. trial).
    }
  }

  if (xtdo) {
    return Rcpp::List::create(Rcpp::Named("suma") = sumET,
                              Rcpp::Named("xoutw") = wmOUT,
                              Rcpp::Named("xouta") = awOUT,
                              Rcpp::Named("w") = wm,
                              Rcpp::Named("alpha") = aw);
  } else {
    return Rcpp::List::create(Rcpp::Named("suma") = sumET,
                              Rcpp::Named("w") = wm,
                              Rcpp::Named("alpha") = aw);
  }
}
