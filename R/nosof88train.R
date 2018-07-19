nosof88train <- function(condition = 'B',blocks = 3, absval = -1,
                     subjs = 1, seed = 4182, missing = 'geo') {
  set.seed(seed)
  n88b <- rbind(
    c(1,-2.543,2.641,1,-1,0,0),
    c(2,.943,4.341,-1,1,0,0),
    c(3,-1.092,1.848,-1,1,0,0),
    c(4,1.558,2.902,-1,1,0,0),
    c(5,-2.258,.430,1,-1,0,0),
    c(6,.194,.572,-1,1,0,0),
    c(7,2.806,.202,-1,1,0,0),
    c(8,-1.177,-1.038,1,-1,0,0),
    c(9,1.543,-1.040,-1,1,0,0),
    c(10,-2.775,-3.149,1,-1,0,0),
    c(11,.528,-3.766,1,-1,0,0),
    c(12,1.709,-3.773,1,-1,0,0)
  )
  colnames(n88b) <- c('stim','x1','x2','t1','t2','m1','m2')

  cond <- switch(condition, B = 1, E2 = 2, E7 = 3)
  
  n88e2 <- rbind(n88b,n88b[2,],n88b[2,],n88b[2,],n88b[2,])
  
  n88e7 <- rbind(n88b,n88b[7,],n88b[7,],n88b[7,],n88b[7,])
 
  n88 <- switch(condition, B = n88b, E2 = n88e2, E7 = n88e7, n88b)

  # Run 'subjs' times
  finalist <- NULL
  for(subj in 1:subjs) {
    # Build list
      makelist <- NULL
      for(blk in 1:blocks) {
          block <- rbind(n88,n88,n88,n88)
          block <- cbind(cond,blk,block)
          block <- block[sample(nrow(block)),]
          makelist <- rbind(makelist,block)
      }
      ctrl <- c(1,rep(0,nrow(makelist)-1))
      makelist <- cbind(ctrl,makelist)
      finalist <- rbind(finalist,makelist)
  }
  # If not using the geometric model representation of dimension
  # absence (m1, m2, etc), drop these columns
  if(missing != 'geo') finalist <- finalist[,1:8]
  
  # If the value for category absence is not -1
  # change the list to reflect this
  if(absval != -1) {
    finalist[finalist[,'t1'] == -1,'t1'] <- absval
    finalist[finalist[,'t2'] == -1,'t2'] <- absval
  }
  return(finalist)
}
