# # # .diva.backprop
#' backpropagate error and update weights
#' 
#' @param out_wts Matrix of output weights
#' @param in_wts Matrix of inputs weights
#' @param out_activation Array of output unit activations
#' @param current_target Target feature values for reconstruction
#'     error calculation
#' @param hid_activation Hidden unit activation
#' @param hid_activation_raw Raw hidden unit activation
#' @param ins_w_bias Inputs with bias unit added
#' @param learning_rate Learning rate for weight updates through
#'     backpropagation
#' @return List of updated in weights and out weights

.diva.backprop <- function(out_wts, in_wts, out_activation, current_target,
                     hid_activation, hid_activation_raw, ins_w_bias,
                     learning_rate){
    # # # calc error on output units
    out_delta <- 2 * (out_activation - current_target)
    
    # # # calc error on hidden units
    hid_delta <- out_delta %*% t(out_wts)
    hid_delta <- hid_delta[,2:ncol(hid_delta)] *
        .diva.sigmoid_grad(hid_activation_raw)
    
    # # # calc weight changes
    out_delta <- learning_rate * (t(hid_activation) %*% out_delta)
    hid_delta <- learning_rate * (t(ins_w_bias) %*% hid_delta)
    
    # # # adjust wts
    out_wts <- out_wts - out_delta
    in_wts <- in_wts - hid_delta

    return(list(out_wts = out_wts, 
                in_wts  = in_wts))
}

# # # .diva.forward_pass
#' Conducts forward pass
#' 
#' @param in_wts Matrix of weights from input to hidden layer
#' @param out_wts Array of weights from hidden layer to output
#'     channels
#' @param inputs Matrix of input features
#' @param continuous Boolean value to indicate if inputs are
#'     continuous
#' @return List of output unit activation, hidden unit activation, raw
#'     hidden unit activation and inputs with bias
#'

.diva.forward_pass <- function(in_wts, out_wts, inputs, continuous) {
    # # # init needed vars
    num_feats <- ncol(out_wts)
    num_cats  <- dim(out_wts)[3]
    num_stims <- nrow(inputs)
    if (is.null(num_stims)) {num_stims <- 1}
    
    # # # add bias to ins
    bias_units <- matrix(rep(1, num_stims), ncol = 1,
                         nrow = num_stims)
    ins_w_bias <- cbind(bias_units,
                        matrix(inputs, nrow = num_stims,
                               ncol = num_feats, byrow = TRUE))
    
    # # # ins to hids propagation
    hid_activation_raw <- ins_w_bias %*% in_wts
    hid_activation <- .diva.sigmoid(hid_activation_raw)
    
    # # # add bias unit to hid activation
    hid_activation <- cbind(bias_units, hid_activation)
    
    # # # hids to outs propagation
    out_activation <- array(rep(0, (num_stims * num_feats * num_cats)), 
                            dim = c(num_stims, num_feats, num_cats))
    
    # # # get output activation
    for (category in 1:num_cats) {
        out_activation[,,category] <- hid_activation %*%
            out_wts[,,category]
    }
    
    # # # apply output activation rule
    if(continuous == FALSE) out_activation <- .diva.sigmoid(out_activation)

    return(list(out_activation     = out_activation, 
                hid_activation     = hid_activation,
                hid_activation_raw = hid_activation_raw, 
                ins_w_bias         = ins_w_bias))
}

# # # .diva.get_wts
#' # Generate input and output weights for initialization of DIVA
#' 
#' @param num_feats Scalar value for the number of features in the
#'     input
#' @param num_hids Scalar value for the number of hidden units in the
#'     model architecture
#' @param num_cats Scalar value for the number of categories
#' @param wts_range Scalar value for the range of the generated
#'     weights
#' @param wts_center Scalar value for the center of the weights
#' @return List with input (input to hidden) weights and output
#'     weights (hidden to output channels)

.diva.get_wts <- function(num_feats, num_hids, num_cats, wts_range,
                    wts_center) {
    # # # set bias
    bias <- 1
    
    # # # Default Model behavior
    # # # generate wts between ins and hids
    in_wts <-
        (matrix(runif((num_feats + bias) * num_hids), ncol = num_hids) - 0.5) * 2 
    in_wts <- wts_center + (wts_range * in_wts)

    # # # generate wts between hids and outs
    out_wts <-
    (array(runif((num_hids + bias) * num_feats * num_cats), 
           dim = c((num_hids + bias), num_feats, num_cats)) - 0.5) * 2
    out_wts <- wts_center + (wts_range * out_wts)

    return(list(in_wts  = in_wts, 
                out_wts = out_wts))
}

# # # .diva.global_scale
#' Scale model targets to 0 : 1 values appropriate for sigmoid output unit activation
#' 
#' @param inputs Matrix of inputs in format -1 : 1 that need to be
#'     scaled
#' @return Matrix of inputs scaled to 0 : 1

.diva.global_scale <- function(inputs) { inputs / 2 + 0.5 }

# .diva.response_rule
#'  convert output activations to classification
#' 
#' @param out_activation Array of output channel activations
#' @param target_activation Array of output unit targets
#' @param beta_val Scalar value for the beta parameter (set in st)
#' @param phi Scalar value for response mapping constant (set in st)
#' @return List of classification probability, focusing weights and
#'     sum squared error

.diva.response_rule <- function(out_activation, target_activation, beta_val, phi){
    num_feats <- ncol(out_activation)
    num_cats  <- dim(out_activation)[3]
    num_stims <- nrow(target_activation)
    if (is.null(num_stims)) {num_stims <- 1}

    # # # compute error  
    ssqerror <- array(as.vector(
        apply(out_activation, 3, function(x) {x - target_activation})),
            c(num_stims, num_feats, num_cats))
    ssqerror <- ssqerror ^ 2
    ssqerror[ssqerror < 1e-7] <- 1e-7

    # # # if focusing is on:
    if (beta_val > 0) {
        # # # get list of channel comparisons
        pairwise_comps <- combn(1:num_cats, 2)
    
        # # # get differences for each feature between categories
        diff_matrix <- 
            abs(apply(pairwise_comps, 2, function(x) {
                out_activation[,,x[1]] - out_activation[,,x[2]]}))

        # # # reconstruct activation array and get feature diversity means
        diff_array <- array(diff_matrix, dim = c(num_stims, num_feats, num_cats))
        feature_diffs <- apply(diff_array, 2, mean)

        # # # calculate diversities
        diversities <- exp(beta_val * feature_diffs)
        diversities[diversities > 1e+7] <- 1e+7

        # # # divide diversities by sum of diversities
        fweights <- diversities / sum(diversities)

        # # # or set fweights equal
        } else {
            fweights <- rep(1/num_feats, num_feats)
        }

    # # # apply focus weights; then get sum for each category
    ssqerror <- t(apply(ssqerror, 3, function(x) sum(x * fweights))) 

    # # # calculate inverse sse
    ssqerror <- 1 / ssqerror

    # # # subtract the max error for numerical stability
    ssqerror <- ssqerror - max(ssqerror)

    # # # apply response mapping and exponentiate
    ssqerror <- exp(phi * ssqerror)

    # # # set resp probs equal to 1
    ps <- ssqerror / sum(ssqerror)

    return(list(ps       = ps, 
                fweights = fweights, 
                ssqerror = ssqerror))
}

# .diva.sigmoid
# returns sigmoid evaluated element-wise in X
#'
#' Returns sigmoid evaluated element-wise in X
#' 
#' @param x Matrix of values to be evaluated with sigmoid function
#' @return Same format of input, evaluated with the sigmoid function

.diva.sigmoid <- function(x) {
    g = 1 / (1 + exp(-x))
    return(g)
}

# sigmoid gradient
#'
#' Returns gradient of the sigmoid function evaluated at x
#' 
#' @param x Values to be evaluated for the sigmoid gradient
#' @return Gradient of the sigmoid function for the input

.diva.sigmoid_grad <- function(x) {
    return(g = ((.diva.sigmoid(x)) * (1 - .diva.sigmoid(x))))
}

# slpDIVA
#'
#' Train stateful list processor DIVA
#' 
#' @param st A list of the model parameters
#' @param tr A matrix of the input and class labels
#' @param xtdo A boolean value indicating if extended output is
#'     desired
#' @return List including a matrix of model classification
#'     probabilities and list of model's final state

slpDIVA <- function(st, tr, xtdo = FALSE) {
    # # # construct weight matrix history list
    wts_history <- list(initial = list(), final = list())
 
    # # # convert targets to 0/1 for binomial input data ONLY
    targets <- tr[,(st$colskip + 1):(st$colskip + st$num_feats), drop = FALSE]
    if (st$continuous == FALSE) targets <- .diva.global_scale(targets)

    # # # init size parameter variables
    out <- matrix(rep(NA, st$num_cats * dim(tr)[1]), 
                  ncol = st$num_cats, nrow = dim(tr)[1])

    # # # iterate over each trial in the tr matrix 
    for (trial_num in 1:dim(tr)[1]) {
        current_input  <- tr[trial_num, (st$colskip + 1):(st$colskip +
                                                          st$num_feats)]
        current_target <- targets[trial_num,]
        # # # determine current class from MLP-style outs
        out_unit_loc   <- c((st$colskip + st$num_feats + 1),         
                          (st$colskip + st$num_feats + st$num_cats)) 
        out_units      <- tr[trial_num, out_unit_loc[1]:out_unit_loc[2]]
        current_class  <- which.max(out_units)

        # # # if ctrl is set to 1 generate new weights
        if (tr[trial_num, 'ctrl'] == 1) {
      
            # # # save existing weights
            wts_history$final[[length(wts_history$final) + 1]] <-
                list(in_wts = st$in_wts, out_wts = st$out_wts)

            # # # generate new weights
            wts <- .diva.get_wts(st$num_feats, st$num_hids,
                                 st$num_cats, st$wts_range,
                                 st$wts_center)
            st$in_wts  <- wts$in_wts
            st$out_wts <- wts$out_wts
            # # # save new weights
            wts_history$initial[[length(wts_history$initial) + 1]] <-
                list(in_wts = st$in_wts, out_wts = st$out_wts)        
        }

        # # # complete forward pass
        fp <- .diva.forward_pass(st$in_wts, st$out_wts, current_input,
                           st$continuous)

        # # # calculate classification probability
        response <- .diva.response_rule(fp$out_activation, current_target,
                                  st$beta_val, st$phi)

        # # # store classification accuracy
        out[trial_num,] = response$ps

        # # # adjust weights based on ctrl setting
        if (tr[trial_num, 'ctrl'] < 2) {
            # # # back propagate error to adjust weights
            class_wts        <- st$out_wts[,,current_class]
            class_activation <- fp$out_activation[,,current_class]

            adjusted_wts <- .diva.backprop(class_wts, st$in_wts,
                                     class_activation, current_target,
                                     fp$hid_activation,
                                     fp$hid_activation_raw,
                                     fp$ins_w_bias, st$learning_rate)
            
            # # # set new weights
            st$out_wts[,,current_class] <- adjusted_wts$out_wts
            st$in_wts                   <- adjusted_wts$in_wts
        }
    }
    
    # # # save extended output
    if (xtdo == TRUE) {
        xtd_output             <- list()
        xtd_output$wts_history <- wts_history
        return(list(out = out, xtd_output = xtd_output))
    }
    return(list(out = out, st = st))
}
