// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// Equations correspond to O'Bryan et al. (2018)
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
// TODO: only compare where input is 1
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
mat exponential_similarity(double c, int outcomes, colvec distances) {
  colvec power = distances * c;
  colvec similarity = zeros(outcomes);
  for (uword i = 0; i < outcomes; i++) {
    similarity[i] = std::exp(-power[i]);
  }
  return similarity;
}

// Equation 3
// returns evidence for each category
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

// Equation 4
vec respond(double b, colvec evidence) {
  double denominator = sum(evidence) + (4 * b);
  mat out = (evidence + b) / denominator;
  return out;
}

// [[Rcpp::export]]
Rcpp::List stdissGCM(List st, arma::mat test, bool xtdo = false) {

  // declare initial state of the model
  double    r = as<double>(st["r"]); // Euclidean - distance metric
  double    c = as<double>(st["c"]); // specificity constant
  double    s = as<double>(st["s"]); // similarity/dissimilarity weight
  double    b = as<double>(st["b"]); // baseline level of similarity
  colvec    t = as<colvec>(st["t"]); // exemplar-specific memory strength
  rowvec    attention = as<rowvec>(st["attentional_weights"]);
  int       outcomes = as<int>(st["outcomes"]);
  int       colskip = as<int>(st["colskip"]);
  mat       exemplars = as<mat>(st["exemplars"]);
  mat       pure_exemplars = exemplars.cols(0, exemplars.n_cols - 2);
  colvec    pure_categories = exemplars.col(exemplars.n_cols - 1);

  // declare variables used for the implementation
  rowvec trial(test.n_cols);
  rowvec input(pure_exemplars.n_cols);
  uword n_trials = test.n_rows;
  colvec distances; distances = zeros(exemplars.n_rows);
  colvec similarity; similarity = zeros(exemplars.n_rows);
  vec probabilities; probabilities = zeros(outcomes);
  vec evidence_all; evidence_all = zeros(outcomes);
  vec muted; muted = zeros(exemplars.n_rows);
  // declare output of main function
  mat evidence_out(n_trials, outcomes);
  mat similarity_out(n_trials, outcomes);
  mat prob(n_trials, outcomes);
  List outFIN;

  for (uword i = 0; i < n_trials; i++) {
    input = test.row(i);
    distances = distanceMatrix(r, attention, pure_exemplars, input);
    similarity = exponential_similarity(c, outcomes, distances);
    muted = mute(pure_exemplars, input);
    evidence_all = evidence(t, s, outcomes, muted, pure_categories, similarity);
    probabilities = respond(b, evidence_all);
    // record outputs
    similarity_out.row(i) = evidence_all.t().as_row();
    evidence_out.row(i) = similarity.t().as_row();
    prob.row(i) = probabilities.as_row();
  }
  return Rcpp::List::create(Rcpp::Named("Evidence") = evidence_out,
                            Rcpp::Named("Similarity") = similarity_out,
                            Rcpp::Named("p") = prob);
}
