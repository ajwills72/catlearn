// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// Equations correspond to Paskewitz and Jones (2020)

// Equation 11
// Find attended cues
rowvec attention_gain(rowvec input, rowvec eta) {
    rowvec gain = input % eta;
    return gain;
}

// Equation 13
// Calculate p-norm of attention
double attention_gain_pnorm(double P, rowvec gain) {
    rowvec gain_p(gain);
    for (uword j = 0; j < gain.n_elem; ++j) {
        gain_p[j] = pow(std::abs(gain[j]), P);
    }
    double p_sum = pow(sum(gain_p), 1/P);
    return p_sum;
}

// Equation 12
// Normalize Attentional Gains
rowvec attention_normalize(rowvec gain, double p_sum) {
    rowvec attention_norm = gain / p_sum;
    return attention_norm;
}

// Equation 5
// Calcualte Model Predictions
rowvec prediction(rowvec input, rowvec attention_norm, mat weights) {
    rowvec attended = input % attention_norm;
    mat activations = weights.each_row() % attended;
    mat predictions = sum(activations, 1);
    return predictions.as_row();
}

// Equation 2
// Exponential Ratio Scale Choice Rule
rowvec choice_rule(rowvec predictions, double phi, int outcomes) {
    rowvec scaled = predictions * phi;
    rowvec power(outcomes);
    for (uword j = 0; j < power.n_elem; ++j) {
        power[j] = std::exp(scaled[j]);
    }
    rowvec out_choice = (power / sum(power));
    return out_choice;
}

// Prediction Error
colvec prediction_error(rowvec output, rowvec predictions) {
    rowvec delta = output - predictions; // prediction error
    return delta.as_col();
}

// Equation 6
mat delta_learning(double lambda, colvec delta,
                   rowvec input, rowvec attention_norm) {
    rowvec attended = input % attention_norm;
    mat out(delta.n_elem, input.n_elem, fill::ones);
    out = out.each_row() % attended;
    out = out.each_col() % delta;
    out = out * lambda;
    return out;
}

// Equation 14
mat attentional_learning(double mu, double P, double p_norm, mat weights,
                         colvec delta, rowvec a_gain, rowvec input,
                         rowvec predictions) {
    mat activations = weights.each_row() % input;
    rowvec a_power(a_gain.n_elem);
    for (uword k = 0; k < a_gain.n_elem; ++k) {
          a_power[k] = pow(a_gain[k], (P - 1));
    }
    mat attention(weights.n_rows, weights.n_cols, fill::ones);
    attention = attention.each_row() % a_power;
    attention = attention.each_col() % predictions.as_col();
    mat out = (activations - attention);
    out = out.each_col() % delta;
    mat out_sum = sum(out, 0);
    mat delta_eta = out_sum % input;
    delta_eta = delta_eta * mu * pow(p_norm, -1);
    return delta_eta;
}

// [[Rcpp::export]]
Rcpp::List slpDRNCAG(List st, arma::mat tr, bool xtdo = false) {

    // declare variables
    double    P = as<double>(st["P"]);              // attentional normalization
    double    phi = as<double>(st["phi"]);          // response consistency
    double    lambda = as<double>(st["lambda"]);    // learning rate paramter
    double    mu = as<double>(st["mu"]);            // attentional learning rate
    int       colskip = as<int>(st["colskip"]);
    int       outcomes = as<int>(st["outcomes"]);
    mat       iweights = as<mat>(st["w"]);          // initial connection weights
    rowvec    ieta = as<rowvec>(st["eta"]);         // initial salience

    // declare variables that will be updated through the sim
    mat       weights(iweights);
    rowvec    eta(ieta);
    mat       out;
    // get size of weight matrix
    uword m = weights.n_rows, n = weights.n_cols;
    // get size of tr
    uword trow = tr.n_rows, tcol = tr.n_cols;
    // initialize miscellaneous variables
    rowvec train(tcol); // vector of current trial
    rowvec input(m);
    rowvec a_gain(n);    // attention gain
    double p_norm(n);    // p-norm of attention gains
    rowvec a_norm(n);    // normalized attention
    rowvec pred_out(m);  // vector of model predictions
    colvec delta(m);     // vector of prediction errors
    colvec output; output = zeros(outcomes); // teaching vector
    mat deltaW; deltaW = zeros(m, n); // change in weights
    rowvec deltaT; deltaT.zeros(n); // change in salience

    rowvec probabilities(outcomes); // vector of response probabilities
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
            // set weights to initial state from st
            weights.zeros();
            weights += iweights;
            // set salience to initial state from st
            eta.zeros();
            eta += ieta;
        }
        // Extract current trial
        train = tr.row(i);
        // Extract input node activations
        input = train.subvec(colskip, colskip + n - 1).as_row();
        // Extract teaching signals
        output = train.subvec(n + colskip, tcol - 1).as_col();
        // Calculate attention
        a_gain = attention_gain(input, eta);
        p_norm = attention_gain_pnorm(P, a_gain);
        a_norm = attention_normalize(a_gain, p_norm);
        pred_out = prediction(input, a_norm, weights);
        probabilities = choice_rule(pred_out, phi, outcomes);
        delta = prediction_error(output.as_row(), pred_out);
        // calculate weights if it is a learning trial
        if ( tr(i, 0) !=  2 ) {
          deltaW = delta_learning(lambda, delta, input, a_norm);
          deltaT = attentional_learning(mu, P, p_norm, weights,
                                   delta, a_gain, input, pred_out);
          weights += deltaW;
          eta += deltaT;
        }
        prob.row(i) = probabilities.as_row();
        activations.row(i) = pred_out.as_row();
        attention.row(i) = eta.as_row();
    }
    outFIN = Rcpp::List::create(Rcpp::Named("p") = prob,
        // Rcpp::Named("model_predictions") = activations,
        Rcpp::Named("attention") = attention,
        Rcpp::Named("final_weights") = weights);

    return outFIN;
}