// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// Equations correspond to Paskewitz and Jones (2020)

// Equation 11
// Find attended cues
vec attention_gain(rowvec input, rowvec eta) {
    vec gain = input % eta;
    return gain;
}

// Equation 13
// Calculate p-norm of attention
mat attention_gain_pnorm(double P, vec gain) {
    vec gain_p(gain);
    for (uword j = 0; j < gain.n_elem; ++j) {
      gain_p[j] = pow(abs(gain[j]), P);
    }
    double p_sum = pow(accu(gain_p), 1/P);
    return p_sum;
}

// Equation 12
// Normalize Attentional Gains
mat attention_normalize(rowvec gain, double p_sum) {
    rowvec attention_norm = gain / p_sum;
    return attention_norm;
}

// Equation 5
// Calcualte Model Predictions
mat prediction(rowvec input, rowvec attention_norm, mat weights) {
    rowvec attended = input % attention_norm;
    mat activations = weights.each_row() % attended;
    mat predictions = sum(activations, 1);
    return predictions.as_row();
}

// Equation 2
// Exponential Ratio Scale Choice Rule
mat choice_rule(rowvec predictions, double phi, int outcomes) {
    vec scaled = predictions * phi;
    vec power = zeros(outcomes);
    for (uword j = 0; j < power.n_elem; ++j) {
      power[j] = std::exp(scaled[j]);
    }
    rowvec out_choice = power / accu(power);
    return out_choice;
}

// Prediction Error
mat prediction_error(rowvec output, rowvec predictions) {
    rowvec delta = output - predictions; // prediction error
    return delta.as_col();
}

// Equation 6
mat delta_learning(double lambda, rowvec output, colvec delta,
                   rowvec input, rowvec attention_norm) {
    rowvec attended = input % attention_norm;
    mat out = delta.each_row() % attended;
    out = out * lambda;
    return out;
}

// Equation 14
mat attentional_learning(double mu, double P, double p_norm, mat weights,
                         colvec delta, rowvec eta, rowvec input,
                         rowvec predictions) {
    predictions = predictions.as_col();
    mat activations = weights.each_row() % input;
    rowvec a_power = zeros(eta.n_elem);
    for (uword k = 0; k < eta.n_elem; ++j) {
        a_power[k] = pow(eta[k], (P - 1));
    }
    vec att_descend = predictions.each_row() * a_power;
    mat out = predictions.each_col() * (activations - att_descend);
    out = out % delta;
    mat out_sum = sum(out, 1);
    mat delta_eta= out_sum.each_col() * input;
    delta_eta = delta_eta * mu;
    return delta_eta;
}

// [[Rcpp::export]]
Rcpp::List slpLMSnet(List st, arma::mat tr, bool xtdo = false) {

    // declare variables  double    beta = as<double>(st["beta"]);
    double    P = as<double>(st["P"]);              // attentional normalization
    double    phi = as<double>(st["phi"]);          // response consistency
    double    lamba = as<double>(st["lambda"]);      // learning rate paramter
    double    mu = as<double>(st["mu"]);            // attentional learning rate
    int       colskip = as<int>(st["colskip"]);
    int       outcomes = as<int>(st["outcomes"]);
    mat       iweights = as<mat>(st["w"]);
    mat       eta = as<mat>(st["eta"]);

    // declare data objects
    mat       weights(iweights);
    mat       out;
    // get size of weight matrix
    uword m = weghts.n_rows, n = weights.n_cols;
    // get size of tr
    uword trow = tr.n_rows, tcol = tr.n_cols;
    // initialize miscellaneous variables
    rowvec train(tcol);
    rowvec input(m);
    rowvec a_norm = zeros(n);
    colvec output; output = zeros(outcomes);
    mat deltaW; deltaW = zeros(m, n); // change in weights
    mat deltaT; deltaT = zeros(m, n); // change in salience
    vec probabilities; probabilities = zeros(outcomes);
    // store outputs
    mat activations(trow, outcomes);
    mat attention(trow, n);
    mat prob(trow, outcomes);
    mat xOUT(trow, 1);
    List outFIN;

    // run model
    for (uword i = 0; i < trow ; i++) {
        // reset network to inital state if ctrl = 1
        if ( tr(i, 0) == 1 )
        {
          weights.zeros();
          weights += initW;
        }
        // Extract current trial
        train = tr.row(i);
        // Extract input node activations
        input = train.subvec(colskip, colskip + n - 1).as_row();
        // Extract teaching signals
        output = train.subvec(n + colskip, tcol - 1).as_row();

        // if it is a learning trial then update weights
        if ( tr(i, 0) !=  2 )
        {
          deltaM = delta_learning(delta, predout, input,attention_norm);       // Equation 5
          weights += deltaM;
        }

    }
}