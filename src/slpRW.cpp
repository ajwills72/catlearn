#include <Rcpp.h>
using namespace Rcpp;

List slpRW (List st, NumericMatrix tr, bool xtdo = false) {
  // Some basic variables
  long i, k;
  long nrow = tr.nrow(), ncol = tr.ncol();

  // Extract stuff from the 'st' list.

  // Learning rate
  double lr = as<double>(st["lr"]);
  // colskip
  long colskip = as<long>(st["colskip"]);
  // Initial weights
  NumericVector initw = as<NumericVector>(st["w"]); 
  
  // Initialise variables for simulation
  long nw = initw.size();
  NumericVector wm(nw); 
  NumericVector inputs(nw);
  NumericVector activ(nw);
  NumericVector delta(nw);  
  NumericVector sumET(nrow);
  NumericMatrix xOUT(nrow, nw);

  // Set weights to initial weights
  wm = clone(initw); 

  // Run simulation
  for (i = 0; i < nrow; ++i) {
    
    if ( tr(i, 0)  == 1)                   // Reset weights if new participant.
    {
      wm = clone(initw);
    }

    for (k = 0; k < nw; ++k) {
      inputs[k] = tr(i, colskip+k);        // Subset stimuli activations at current trial.
      activ[k] = inputs[k] * wm[k];       // Generate current stimuli weights.
    }
    
    sumET[i] = sum(activ);                // Record output (summed
					  // error term).
    
    for (k = 0; k < nw; ++k) {
      delta[k] = lr * (tr(i, ncol-1) - sumET[i]); // Calc change in associative strength.
    }
    
    if ( tr(i,0) != 2 ) {                // Unless weights are frozen...
      for (k = 0; k < nw; ++k) {
        wm[k] += delta[k] * inputs[k];    // ...update weights.
      }
    }
    if (xtdo) {
      xOUT(i, _) = wm;                    // If xtdo = true, record updated weights to
                                          // relevant row (i.e. trial).
    }
  }

  if (xtdo) {
    return Rcpp::List::create(Rcpp::Named("suma") = sumET,
                              Rcpp::Named("xout") = xOUT,
                              Rcpp::Named("w") = wm);
  } else {
    return Rcpp::List::create(Rcpp::Named("suma") = sumET,
                              Rcpp::Named("w") = wm);
  }
}
