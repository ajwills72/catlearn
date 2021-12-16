// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;


// Equation 3: calculate output node activations
mat node_activation(rowvec input, mat weights) {
  mat weightA = weights.each_row() % input;
  mat nodeact = sum(weightA, 1);
  return nodeact;
}

// Equation 4: calculate least mean square error
double squared_differences(mat outnode, colvec teaching, double outcomes) {
  mat lms = outnode % teaching;
  double sqdif = (1/outcomes) * (accu(pow(lms, 2)));
  return sqdif;
}

// Equation 5: calculate the weight changes
mat delta_learning(mat outnode, colvec teaching, rowvec input, double beta) {
  colvec error = teaching - outnode;
  colvec delta = beta * error;
  mat activation(teaching.n_rows, input.n_cols, fill::ones);
  activation = activation.each_row() % input;
  activation = activation.each_col() % teaching;
  mat out = activation.each_col() % delta;
  return out;
}

// Equation 7
vec logistic_choice(mat outnode, double theta, double bias) {
  vec scale = -theta * (outnode - bias);
  vec power = zeros(outnode.n_elem);
  for (uword j = 0; j < power.n_elem; ++j) {
    power[j] = std::exp(scale[j]);
  }
  vec out = 1 / (1 + power);
  return out;
}


// Footnote 2
vec ratio_scale(mat outnode, double theta) {
  vec scale = theta * outnode;
  vec power = zeros(outnode.n_elem);
  for (uword j = 0; j < power.n_elem; ++j) {
    power[j] = std::exp(scale[j]);
  }
  vec out = power / sum(power);
  return out;
}

// [[Rcpp::export]]
Rcpp::List slpLMSnet(List st, arma::mat tr, bool xtdo = false,
                     std::string dec = "logistic") {

  // declare initial state of the model
  double    beta = as<double>(st["beta"]);
  double    theta = as<double>(st["theta"]);
  double    bias = as<double>(st["bias"]);
  int       colskip = as<int>(st["colskip"]);
  int       outcomes = as<int>(st["outcomes"]);
  mat       initW = as<mat>(st["w"]);

  // declare variables for simulation
  mat Weights(initW);
  mat Out;
  uword m = Weights.n_rows, n = Weights.n_cols;
  uword trow = tr.n_rows, tcol = tr.n_cols;
  // initialize miscellaneous variables used at different parts of the function
  rowvec train(tcol);
  rowvec input(m);
  colvec output; output = zeros(outcomes);
  vec ER; ER = zeros(outcomes);
  mat deltaM; deltaM = zeros(m, n);
  vec probabilities; probabilities = zeros(outcomes);
  // store outputs
  mat activations(trow, outcomes);
  mat prob(trow, outcomes);
  mat xOUT(trow, 1);
  List outFIN;

  // run model

  for (uword i = 0; i < trow ; i++) {
    if ( tr(i, 0) == 1 )
    {
      Weights.zeros();
      Weights += initW;
    }
    train = tr.row(i);
    // Extract input node activations
    input = train.subvec(colskip, colskip + n - 1).as_row();
    // Extract teaching signals
    output = train.subvec(n + colskip, tcol - 1).as_col();
    Out = node_activation(input, Weights);                     // Equation 3
    ER = squared_differences(Out, output, (double)outcomes);   // Equation 4
    // calculate weights if it is a learning trial
    if ( tr(i, 0) !=  2 ) {
      deltaM = delta_learning(Out, output, input, beta);       // Equation 5
      Weights += deltaM;
    }
    // pick choice function
    if (dec == "logistic") {
        probabilities = logistic_choice(Out, theta, bias);     // Equation 7
    } else if (dec == "softmax") {
        probabilities = ratio_scale(Out, theta);               // Footnote 2
    }
    // bind output
    prob.row(i) = probabilities.as_row();
    activations.row(i) = Out.as_row();
    xOUT.row(i) = ER;
  }

  if (xtdo == false) {
    outFIN = Rcpp::List::create(
        Rcpp::Named("p") = prob,
        Rcpp::Named("nodeActivations") = activations,
        Rcpp::Named("connectionWeightMatrix") = Weights);
  } else {
    outFIN = Rcpp::List::create(Rcpp::Named("p") = prob,
        Rcpp::Named("nodeActivations") = activations,
        Rcpp::Named("squaredDifferences") = xOUT,
        Rcpp::Named("connectionWeightMatrix") = Weights);
  }

  return outFIN;
}
