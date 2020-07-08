st <- list(beta = 0.5, # positive learning parameter, 0 =< beta >= 1
           om = 0.5, # positive scaling parameter, om > 0
           # init weight matrix, row = number of outcomes, col = number of cues
           w = matrix(rep(0, 8), nrow = 2, ncol = 4),
           outcomes = 2, # number of possuble outcomes
           colskip = 1)
