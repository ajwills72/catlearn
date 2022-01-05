// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// Equations correspond to Paskewitz and Jones (2020)

// Equation 11
// Find attended cues
rowvec activate_gains(rowvec input, rowvec eta) {
    rowvec gain = input % eta;
    return gain;
}

// Equation 13
// Calculate p-norm of attention
double gain_pnorm(double P, rowvec gain) {
    rowvec gain_p(gain);
    for (uword j = 0; j < gain.n_elem; ++j) {
        gain_p[j] = pow(gain[j], P);
    }
    double p_sum = pow(sum(gain_p), 1/P);
    return p_sum;
}

// Equation 12
// Normalize Attentional Gains
rowvec attention(rowvec gain, double p_sum) {
    rowvec attention_norm = gain / p_sum;
    return attention_norm;
}

// Equation 5
// Calcualte Model Predictions
rowvec z_prediction(rowvec input, rowvec attention_norm, mat weights) {
    rowvec attended = input % attention_norm;
    mat activations = weights.each_row() % attended;
    mat predictions = sum(activations, 1);
    return predictions.as_row();
}

// Equation 2
// Exponential Ratio Scale Choice Rule
rowvec ratio_rule(rowvec predictions, double phi, int outcomes) {
    rowvec scaled = predictions * phi;
    rowvec power(outcomes);
    for (uword j = 0; j < power.n_elem; ++j) {
        power[j] = std::exp(scaled[j]);
    }
    rowvec out_choice = (power / sum(power));
    return out_choice;
}

// Prediction Error
colvec error(rowvec output, rowvec predictions) {
    rowvec delta = output - predictions; // prediction error
    return delta.as_col();
}

// Equation 6
mat delta_rule(double lambda, colvec delta,
                   rowvec input, rowvec attention_norm) {
    rowvec attended = input % attention_norm;
    mat out(delta.n_elem, input.n_elem, fill::ones);
    out = out.each_row() % attended;
    out = out.each_col() % delta;
    out = out * lambda;
    return out;
}

// Equation 15
mat attentional_shift(double rho, double P, double p_norm, mat weights,
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
    mat delta_eta = rho * pow(p_norm, -1) * out_sum;
    return delta_eta;
}

// Equation 16
// attentional learning - updates salience
mat salience_update(double mu, rowvec a_gain,
                         rowvec shift, rowvec input) {
    rowvec doa = shift - a_gain;
    doa = doa % input;
    doa = doa * mu;
    return doa;

}

// [[Rcpp::export]]
Rcpp::List slpNNRAS(List st, arma::mat tr, bool xtdo = false) {

    // declare variables
    double    P = as<double>(st["P"]);              // attentional normalization
    double    phi = as<double>(st["phi"]);          // response consistency
    double    lambda = as<double>(st["lambda"]);    // learning rate paramter
    double    mu = as<double>(st["mu"]);            // attentional learning rate
    double    rho = as<double>(st["rho"]);          // attentional shift rate
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
    rowvec a_gain(n);           // attention gain
    rowvec shift_gain(n);       // attention gain during attentional shifts
    double p_norm(n);           // p-norm of attention gains
    rowvec a_norm(n);           // normalized attention
    rowvec pred_out(m);         // vector of model predictions
    colvec delta(m);            // vector of prediction errors
    colvec output; output = zeros(outcomes); // teaching vector
    mat deltaW; deltaW = zeros(m, n); // change in weights
    rowvec deltaT; deltaT.zeros(n); // change in salience
    rowvec shiftT; shiftT.zeros(n); // attentional shifts

    rowvec probabilities(outcomes); // vector of response probabilities
    // store outputs
    mat activations(trow, outcomes);
    mat salience(trow, n);
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
        a_gain = activate_gains(input, eta);          // Equation 11
        a_gain.clamp(0.01, datum::inf);               // clamp values at 0.1
        shift_gain = a_gain;                          // store gain
        p_norm = gain_pnorm(P, a_gain);               // Equation 13
        a_norm = attention(a_gain, p_norm);           // Equation 12
        pred_out = z_prediction(input, a_norm, weights);       // Equation 5
        probabilities = ratio_rule(pred_out, phi, outcomes);   // Equation 2

        // update weights and salience if it is a learning trial
        if ( tr(i, 0) !=  2 ) {
            for (uword i = 0; i < 10; i++) {
                p_norm = gain_pnorm(P, shift_gain);               // Equation 13
                a_norm = attention(shift_gain, p_norm);           // Equation 12
                pred_out = z_prediction(input, a_norm, weights);  // Equation 5
                delta = error(output.as_row(), pred_out);         // Equation 14
		// Equation 15
                shift_gain += attentional_shift(rho, P, p_norm, weights,
                                      delta, shift_gain, input, pred_out); 
                shift_gain.clamp(0.01, datum::inf);      // clamp values to 0.01
            }
            // recalculate attention and prediction before updates
            p_norm = gain_pnorm(P, shift_gain);                   // Equation 13
            a_norm = attention(shift_gain, p_norm);               // Equation 12
            pred_out = z_prediction(input, a_norm, weights);      // Equation 5
            delta = error(output.as_row(), pred_out);             // Equation 14
            // updates weights and salience
            deltaW = delta_rule(lambda, delta, input, a_norm);    // Equation 6
            deltaT = salience_update(mu, a_gain,
                                          shift_gain, input);     // Equation 16
            weights += deltaW;
            eta += deltaT;
            eta.clamp(0.01, datum::inf);                  // clamp values at 0.1
        }
        // strore trial-level output
        prob.row(i) = probabilities.as_row();
        activations.row(i) = delta.as_row();
        salience.row(i) = eta.as_row();
    }

    if (xtdo == false) {
        outFIN = Rcpp::List::create(
            Rcpp::Named("p") = prob,
            Rcpp::Named("final_eta") = eta,
            Rcpp::Named("final_weights") = weights);
    } else {
        outFIN = Rcpp::List::create(
            Rcpp::Named("p") = prob,
            Rcpp::Named("prediction_error") = activations,
            Rcpp::Named("eta") = salience,
            Rcpp::Named("final_eta") = eta,
            Rcpp::Named("final_weights") = weights);
    }

    return outFIN;
}
