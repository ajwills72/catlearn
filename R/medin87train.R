medin87train <- function(blocks = 2, subjs = 2, seed = 7649, missing = 'pad') {
    set.seed(seed)
    train <- matrix(c( 1, 1, 1, 1, 1, 0, 0, 0, 0,
                       2, 1, 1, 1, 0, 0, 0, 0, 0,
                       3, 1, 1, 0, 1, 0, 0, 0, 0,
                       4, 1, 0, 1, 1, 0, 0, 0, 0,
                       5, 0, 1, 1, 1, 0, 0, 0, 0,
                       6, 0, 0, 0, 0, 0, 0, 0, 0,
                       7, 0, 0, 0, 1, 0, 0, 0, 0,
                       8, 0, 0, 1, 0, 0, 0, 0, 0,
                       9, 0, 1, 0, 0, 0, 0, 0, 0,
                      10, 1, 0, 0, 0, 0, 0, 0, 0),
                    ncol = 9, byrow = TRUE)

  colnames(train) <- c('stim','x1','x2','x3','x4','m1','m2','m3','m4') 

  biglist <- NULL
  for(subj in 1:subjs) {
      makelist <- NULL
      for(blk in 1:blocks) { 
          block <- train[sample(nrow(train)),]
          block <- cbind(blk,block)
          makelist <- rbind(makelist,block)
      }
      ## Add network reset for first trial, unsupervised learning for others
      ctrl <- c(4,rep(3,nrow(makelist)-1))
      makelist <- cbind(ctrl,makelist)
      biglist <- rbind(biglist,makelist)
  }
  
  ## Drop missing values if not geo representation
  if(missing != 'geo') biglist <- biglist[,1:7]

  ## Change to padded coding? (e.g. SUSTAIN)
  if(missing == 'pad') {
      padlist  <- convertSUSTAIN(biglist[,4:7]+1, c(2,2,2,2))
      colnames(padlist)  <- c("w1", "w2", "x1", "x2", "y1", "y2", "z1", "z2")
      biglist  <- cbind(biglist[,1:3], padlist)
  }
  return(biglist)
}
