nosof94train <- function(cond = 1,blocks = 16, absval = -1, subjs = 1,
                         seed = 7624, missing = 'geo', blkstyle = 'accurate') {
  set.seed(seed)
  shj61 <- array(0,dim=c(8,9,6))
  colnames(shj61) <- c('stim','x1','x2','x3','t1','t2','m1','m2','m3') 
  
  shj61[,,1] <- rbind( # Type I
    c(1,0,0,0,1,-1,0,0,0),
    c(2,0,0,1,1,-1,0,0,0),
    c(3,0,1,0,1,-1,0,0,0),
    c(4,0,1,1,1,-1,0,0,0),
    c(5,1,0,0,-1,1,0,0,0),
    c(6,1,0,1,-1,1,0,0,0),
    c(7,1,1,0,-1,1,0,0,0),
    c(8,1,1,1,-1,1,0,0,0)
  )
  
  shj61[,,2] <- rbind( # Type II
    c(1,0,0,0,1,-1,0,0,0),
    c(2,0,0,1,1,-1,0,0,0),
    c(3,0,1,0,-1,1,0,0,0),
    c(4,0,1,1,-1,1,0,0,0),
    c(5,1,0,0,-1,1,0,0,0),
    c(6,1,0,1,-1,1,0,0,0),
    c(7,1,1,0,1,-1,0,0,0),
    c(8,1,1,1,1,-1,0,0,0)
  )
  
  shj61[,,3] <- rbind( # Type III
    c(1,0,0,0,1,-1,0,0,0),
    c(2,0,0,1,1,-1,0,0,0),
    c(3,0,1,0,1,-1,0,0,0),
    c(4,0,1,1,-1,1,0,0,0),
    c(5,1,0,0,-1,1,0,0,0),
    c(6,1,0,1,1,-1,0,0,0),
    c(7,1,1,0,-1,1,0,0,0),
    c(8,1,1,1,-1,1,0,0,0)
  )
  
  shj61[,,4] <- rbind( # Type IV
    c(1,0,0,0,1,-1,0,0,0),
    c(2,0,0,1,1,-1,0,0,0),
    c(3,0,1,0,1,-1,0,0,0),
    c(4,0,1,1,-1,1,0,0,0),
    c(5,1,0,0,1,-1,0,0,0),
    c(6,1,0,1,-1,1,0,0,0),
    c(7,1,1,0,-1,1,0,0,0),
    c(8,1,1,1,-1,1,0,0,0)
  )
  
  shj61[,,5] <- rbind( # Type V
    c(1,0,0,0,1,-1,0,0,0),
    c(2,0,0,1,1,-1,0,0,0),
    c(3,0,1,0,1,-1,0,0,0),
    c(4,0,1,1,-1,1,0,0,0),
    c(5,1,0,0,-1,1,0,0,0),
    c(6,1,0,1,-1,1,0,0,0),
    c(7,1,1,0,-1,1,0,0,0),
    c(8,1,1,1,1,-1,0,0,0)
  )
  
  shj61[,,6] <- rbind( # Type VI
    c(1,0,0,0,1,-1,0,0,0),
    c(2,0,0,1,-1,1,0,0,0),
    c(3,0,1,0,-1,1,0,0,0),
    c(4,0,1,1,1,-1,0,0,0),
    c(5,1,0,0,-1,1,0,0,0),
    c(6,1,0,1,1,-1,0,0,0),
    c(7,1,1,0,1,-1,0,0,0),
    c(8,1,1,1,-1,1,0,0,0)
  )
  biglist <- NULL
  for(subj in 1:subjs) {
      makelist <- NULL
      for(blk in 1:blocks) { 
          ## Block 1 is randomized differently
          if(blk == 1 | blkstyle == "eights") { 
              blocka <- shj61[,,cond]
              blocka <- blocka[sample(nrow(blocka)),]
              blockb <- shj61[,,cond]
              blockb <- blockb[sample(nrow(blockb)),]
              block <- rbind(blocka,blockb)
          } else {
              block <- rbind(shj61[,,cond],shj61[,,cond]) 
              block <- block[sample(nrow(block)),]
          }
          block <- cbind(cond,blk,block)
          makelist <- rbind(makelist,block)
      }
      ## Add network reset for first trial
      ctrl <- c(1,rep(0,nrow(makelist)-1))
      makelist <- cbind(ctrl,makelist)
      biglist <- rbind(biglist,makelist)
  }
  
  ## Drop missing values if not geo representation
  if(missing != 'geo') biglist <- biglist[,1:9]
  ## If the value for category absence is not -1
  ## change the list to reflect this
  if(absval != -1) {
    biglist[biglist[,'t1'] == -1,'t1'] <- absval
    biglist[biglist[,'t2'] == -1,'t2'] <- absval
  }
  ## Change to padded coding? (e.g. SUSTAIN)
  if(missing == 'pad') {
      padlist <- cbind(biglist[,1:4],
                       biglist[, 'x1'], 1 - biglist[, 'x1'],
                       biglist[, 'x2'], 1 - biglist[, 'x2'],
                       biglist[, 'x3'], 1 - biglist[, 'x3'],
                       biglist[, 't1'], biglist[, 't2']) 
      colnames(padlist) <- c('ctrl', 'cond', 'blk', 'stim', 'x1', 'x2', 'y1',
                             'y2', 'z1', 'z2', 't1', 't2')
      biglist <- padlist
  }
  return(biglist)
}
