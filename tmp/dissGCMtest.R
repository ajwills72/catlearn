library(catlearn)
library(Rcpp)
library(RcppArmadillo)

sourceCpp("stdissGCM.cpp")


#training stimuli (only one row per unique stimuli, reps are account for using memory weights)
stim=matrix(c(
              1,1,0,0,0,0, 1,
              1,0,1,0,0,0, 2,
              0,0,0,1,1,0, 3,
              0,0,0,1,0,1, 4), ncol = 7, byrow = T)

#Category labels, one for each stimulus
cats=c(1,2,3,4)

#Transfer/test stimuli
#This is a row for each unique transfer stimulus
tr = matrix(c(
             1, 1, 0, 0, 0, 0, #0,1,2
             1, 0, 1, 0, 0, 0, #3
             0, 0, 0, 1, 1, 0, #4,5,6
             0, 0, 0, 1, 0, 1, #7
             1, 0, 0, 0, 0, 0, #8
             0, 0, 0, 1, 0, 0, #9
             0, 1, 0, 0, 0, 0, #10
             0, 0, 1, 0, 0, 0, #11
             0, 0, 0, 0, 1, 0, #12
             0, 0, 0, 0, 0, 1, #13
             0, 1, 1, 0, 0, 0, #14, 15
             0, 0, 0, 0, 1, 1, #16, 17
             1, 0, 0, 0, 1, 0, #18
             1, 0, 0, 0, 0, 1, #19
             0, 1, 0, 1, 0, 0, #20
             0, 0, 1, 1, 0, 0, #21
             0, 0, 1, 0, 1, 0, #22, 23
             0, 1, 0, 0, 0, 1 #24, 25
             ),
             ncol = 6,
             byrow = T)

params=c(0.27692188, 0.66524089, 0.88723335, 0.16967400, 0.71206208, 0.87939732, 9.04906080, 0.94614863, 0.02250668)

st <- list(attentional_weights = params[1:6]/sum(abs(params[1:6])),
           c = params[7],
           s = params[8],
           b = params[9],
           t = c(3, 1, 3, 1),
           r = 1,
           colskip = 1,
           outcomes = 4,
           exemplars = stim)

model_out <- stdissGCM(st, tr[11:12, ])
