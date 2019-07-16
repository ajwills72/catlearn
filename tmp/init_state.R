# Initial state of the model, parameters are as follows:
# lr - learning rate parameter
# alr - attentional learning parameter
# w - a vector of initial association weights
# aw - a vector of initial attentional weights
# colskip - number of optional columns to be skipped

st <- list(lr = 0.3,
           alr = 0.1,
           w = rep(0, 8),
           alpha = rep(0.3, 8),
           colskip = 5)
