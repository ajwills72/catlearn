#include <Rcpp.h>
using namespace Rcpp;

//[[Rcpp::export]]

List slpMack75 (List st, NumericMatrix tr, bool xtdo = false) {
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
  NumericVector error1(nw);
  NumericVector error2(nw);
  NumericVector sumET(nrow);
  NumericMatrix wmOUT(nrow, nw);
  NumericMatrix awOUT(nrow, nw);

  // Set weights to initial weights
  wm = clone(initw);
  aw = clone(initaw);
  // Run simulation
  for (i = 0; i < nrow; ++i) {

    // Reset model to initial state if new participant.
    if ( tr(i, 0)  == 1)
    {
      wm = clone(initw);
      aw = clone(initaw);
    }

    // Reset weights but not alphas
    if ( tr(i, 0) == 3)
    {
      wm = clone(initw);
    }

    // Reset alphas but not weights
    if ( tr(i, 0) == 4)
    {
      aw = clone(initaw);
    }

    for (k = 0; k < nw; ++k) {
      inputs[k] = tr(i, colskip+k); // Subset activations at current trial.
      activ[k] = inputs[k] * wm[k]; // Generate current stimuli weights.
    }

    sumET[i] = sum(activ);                 // Record output

    // Calculate changes in associative strengths
    for (k = 0; k < nw; ++k) {
      delta[k] = lr * aw[k] * (tr(i, ncol-1) - activ[k]); 
    }

    if ( tr(i, 0)  != 2) {
      for (k = 0; k < nw; ++k) {
        // update weights
        wm[k] += delta[k] * inputs[k];
        // Calculate the prediction error of all association strengths other than k
        error1[k] = tr(i, ncol-1) - (sumET[i] - activ[k]);
        // Calculate the prediction error of current stimuli/stimulus
        error2[k] = tr(i, ncol-1) - activ[k];
        // Update alpha values according to Le Pelley et al. (2016)'s Equation 2
        aw[k] += alr * (fabs(error1[k]) - fabs(error2[k])) * inputs[k];
      }
    }

    // Limiting alphas to 0.1 or 1 as described by Le Pelley et al. (2016)
    for (k = 0; k < nw; ++k) {
      if (aw[k] > 1) {
        aw[k] = 1;
      } else if (aw[k] < 0.1) {
        aw[k] = 0.1;
      }
    }

    if (xtdo) {
     // If xtdo = true, record updated weights to
      wmOUT(i, _) = wm;
      awOUT(i, _) = aw;
      // relevant row (i.e. trial).
    }
  }

  if (xtdo) {
    return Rcpp::List::create(Rcpp::Named("xoutw") = wmOUT,
        Rcpp::Named("xouta") = awOUT,
        Rcpp::Named("suma") = sumET,
        Rcpp::Named("w") = wm,
        Rcpp::Named("alpha") = aw);
  } else {
    return Rcpp::List::create(Rcpp::Named("suma") = sumET,
        Rcpp::Named("w") = wm,
        Rcpp::Named("alpha") = aw);
  }
}
