st <- list(beta = 0.5, # positive learning parameter, 0 =< beta >= 1
           theta = 0.5, # positive scaling parameter, theta > 0
           bias = 0, # bias parameter, same as beta in act2probat
           # init weight matrix, row = number of outcomes, col = number of cues
           w = matrix(rep(0, 8), nrow = 2, ncol = 4),
           outcomes = 2, # number of possible outcomes
           colskip = 1)
