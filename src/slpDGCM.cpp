// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// Equations correspond to Stewart and Morin (2007)
// Equation 1
mat distanceMatrix(double r, rowvec attention, mat exemplars, rowvec input) {
  mat difference = input - exemplars.each_row();
  difference = pow(abs(difference), r);
  difference = difference.each_row() % attention;
  colvec distances = sum(difference, 1);
  mat sim_out = pow(distances, 1/r);
  return sim_out;
}

// Assumption: muting exemplars with non-matching features
vec mute(mat exemplars, rowvec input) {
  uvec indices = find(input == 1);
  mat difference = input - exemplars.each_row();
  colvec index = min(difference.cols(indices), 1);
  colvec mute_exemplars(index.n_elem);
  for (int j = 0; j < index.n_elem; ++j) {
    if (index[j] == 0) {
      mute_exemplars[j] = 1;
    } else if (index[j] > 0) {
      mute_exemplars[j] = 0;
    }
  }
  return mute_exemplars;
}

// Equation 2
// Exponential transformation of distances
mat exponential_similarity(double c, int outcomes, colvec distances) {
  colvec power = distances * c;
  colvec similarity = zeros(outcomes);
  for (uword i = 0; i < outcomes; i++) {
    similarity[i] = std::exp(-power[i]);
  }
  return similarity;
}

// Equation 3
// Returns evidence for each category.
mat evidence(colvec t, double s, int outcomes, vec mute,
             colvec categories, colvec similarity) {
  colvec similar = s * (similarity % t);
  colvec dissimilar = (1 - similarity);
  dissimilar = (1 - s) * (dissimilar % t);
  similar = similar % mute;
  dissimilar = dissimilar % mute;
  colvec evidence = zeros(outcomes);
  for (uword i = 0; i < outcomes; i++) {
    colvec cat_sim = similar.rows( find(categories == (i + 1)) );
    colvec cat_dissim = dissimilar.rows( find(categories != (i + 1)) );
    evidence[i] = sum(cat_sim) + sum(cat_dissim);
  }
  evidence = evidence % mute;
  return evidence;
}

// Equation 4 (O'Bryan et al., 2018)
// Background-noise decision network
vec respond_noise(double base, colvec evidence, double outcomes) {
  double denominator = sum(evidence) + (outcomes * base);
  mat out = (evidence + base) / denominator;
  return out;
}

// Equation 4 (Stewart and Mintor, 2007)
// Store number of trials since exemplar appeared
vec trial_count(colvec distances, colvec count) {
  uvec close = find(distances > 0);
  for (uword i = 0; i < close.n_elem; i++) {
    count[close[i]] += 1;
  }
  if(any(distances == 0)) {
    uvec current = find(distances == 0);
    count[current[0]] = 0;
  }
  return count;
}

// Exemplar memory decay
vec decay(colvec n, double theta, colvec distances) {
  uvec close = find(distances > 0);
  colvec term = n * theta;
  colvec result = zeros(distances.n_elem);
  for (uword i = 0; i < close.n_elem; i++) {
    result[close[i]] = std::exp(-term[close[i]]);
  }
  return result;
}

// Equation (5)
// Biased decision rule network
vec respond_bias(colvec beta, colvec evidence, double gamma) {
  double denominator = sum(pow(beta % evidence, gamma));
  colvec nominator = pow(beta % evidence, gamma);
  mat out = nominator / denominator;
  return out;
}

// [[Rcpp::export]]
Rcpp::List slpDGCM(List st, arma::mat test,
                     std::string dec = "BIAS",
                     bool exemplar_mute = false,
                     bool exemplar_decay = true
                     ) {

  // declare initial state of the model
  double    r = as<double>(st["r"]);    // Euclidean - distance metric
  double    c = as<double>(st["c"]);    // generalization/specificity constant
  double    s = as<double>(st["s"]);    // similarity/dissimilarity weight
  double    theta = as<double>(st["theta"]); // decay parameter
  double    gamma = as<double>(st["gamma"]); // decision scaling constant
  colvec    beta = as<colvec>(st["beta"]);    // category bias vector
  double    base = as<double>(st["b"]);    // baseline level of similarity
  rowvec    attention = as<rowvec>(st["attentional_weights"]);
  int       outcomes = as<int>(st["outcomes"]);  // number of outcomes (integer)
  double    num_out = as<double>(st["outcomes"]); // number of outcomes (double)
  int       colskip = as<int>(st["colskip"]);
  mat       exemplars = as<mat>(st["exemplars"]);
  mat       pure_exemplars = exemplars.cols(0, exemplars.n_cols - 2);
  colvec    pure_categories = exemplars.col(exemplars.n_cols - 1);


  // declare variables used for the implementation
  colvec count; count = zeros(exemplars.n_rows);
  rowvec trial(test.n_cols);
  rowvec input(pure_exemplars.n_cols);
  uword n_trials = test.n_rows;
  uword n = exemplars.n_cols;
  colvec distances; distances = zeros(exemplars.n_rows);
  colvec similarity; similarity = zeros(exemplars.n_rows);
  vec probabilities; probabilities = zeros(outcomes);
  vec evidence_all; evidence_all = zeros(outcomes);
  vec muted; muted = zeros(exemplars.n_rows);
  // conditional parameters
  colvec t = as<colvec>(st["t"]);    // exemplar-specific memory strength
  if(exemplar_decay) t = zeros(exemplars.n_rows);
  mat memory_decay(n_trials, exemplars.n_rows);

  // declare output of main function
  mat evidence_out(n_trials, outcomes);
  mat prob(n_trials, outcomes);

  List outFIN;

  for (uword i = 0; i < n_trials; i++) {
    trial = test.row(i);
    input = trial.subvec(colskip - 1, trial.n_cols - 1).as_row();
    distances = distanceMatrix(r, attention, pure_exemplars, input);
    similarity = exponential_similarity(c, outcomes, distances);
    if(exemplar_mute) {
      muted = mute(pure_exemplars, input);
    } else {
      muted = ones(exemplars.n_rows);
    }
    if(exemplar_decay) {
      count = trial_count(distances, count);
      t = decay(count, theta, distances);
    }
    evidence_all = evidence(t, s, outcomes, muted,
                            pure_categories, similarity);
    if(dec == "NOISE") {
      probabilities = respond_noise(base, evidence_all, num_out);
    } else if(dec == "BIAS") {
      probabilities = respond_bias(beta, evidence_all, gamma);
    }
    // record outputs
    evidence_out.row(i) = evidence_all.t().as_row();
    prob.row(i) = probabilities.as_row();
    if(exemplar_decay) memory_decay.row(i) = t.t().as_row();
  }
  if (exemplar_decay) {
    return Rcpp::List::create(Rcpp::Named("decay") = memory_decay,
                              Rcpp::Named("v") = evidence_out,
                              Rcpp::Named("p") = prob);

  } else {
    return Rcpp::List::create(Rcpp::Named("v") = evidence_out,
                              Rcpp::Named("p") = prob);
  }
}
