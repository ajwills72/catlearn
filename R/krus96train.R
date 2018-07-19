krus96train <-
    function(blocks = 15, subjs = 56, ctxt = TRUE, seed = 1) {
   set.seed(seed)

    ## note "x7"=bias cue, which is always on

   sr <- rbind(
       ##I1, PC1, PR1, I2, PC2, PR2, X, C1, R1, C2, R2
       c( 1,   1,   0,  0,   0,   0, 1,  1,  0,  0,  0), # I1.PC1
       c( 1,   1,   0,  0,   0,   0, 1,  1,  0,  0,  0), # I1.PC1
       c( 1,   1,   0,  0,   0,   0, 1,  1,  0,  0,  0), # I1.PC1       
       c( 1,   0,   1,  0,   0,   0, 1,  0,  1,  0,  0), # I1.PR1
       
       c( 0,   0,   0,  1,   1,   0, 1,  0,  0,  1,  0), # I2.PC2
       c( 0,   0,   0,  1,   1,   0, 1,  0,  0,  1,  0), # I2.PC2
       c( 0,   0,   0,  1,   1,   0, 1,  0,  0,  1,  0), # I2.PC2              
       c( 0,   0,   0,  1,   0,   1, 1,  0,  0,  0,  1)  # I2.PR2
   )

   trainingitems <- data.frame(cbind("", sr))
    
   colnames(trainingitems) <- c("stim", "x1", "x2", "x3", "x4", "x5",
                                "x6", "x7", "t1", "t2", "t3", "t4")

   trainingitems[,"stim"] <- c(rep("I1.PC1", 3), "I1.PR1",
                                    rep("I2.PC2", 3), "I2.PR2")
   
   testitems <- rbind(
       ##I1, PC1, PR1, I2, PC2, PR2, X, C1, R1, C2, R2 
       c( 1,   0,   0,  0,   0,   0, 1,  0,  0,  0,  0), # I1
       c( 0,   1,   0,  0,   0,   0, 1,  0,  0,  0,  0), # PC1
       c( 0,   0,   1,  0,   0,   0, 1,  0,  0,  0,  0), # PR1
       c( 0,   0,   0,  1,   0,   0, 1,  0,  0,  0,  0), # I2
       c( 0,   0,   0,  0,   1,   0, 1,  0,  0,  0,  0), # PC2
       c( 0,   0,   0,  0,   0,   1, 1,  0,  0,  0,  0), # PR2
       c( 0,   1,   1,  0,   0,   0, 1,  0,  0,  0,  0), # PC1.PR1
       c( 0,   0,   0,  0,   1,   1, 1,  0,  0,  0,  0), # PC2.PR2
       c( 1,   1,   1,  0,   0,   0, 1,  0,  0,  0,  0), # I1.PC1.PR1
       c( 0,   0,   0,  1,   1,   1, 1,  0,  0,  0,  0), # I2.PC2.PR2
       c( 1,   0,   0,  0,   1,   0, 1,  0,  0,  0,  0), # I1.PC2
       c( 1,   0,   0,  0,   0,   1, 1,  0,  0,  0,  0), # I1.PR2
       c( 0,   1,   0,  1,   0,   0, 1,  0,  0,  0,  0), # I2.PC1
       c( 0,   0,   1,  1,   0,   0, 1,  0,  0,  0,  0), # I2.PR1
       c( 0,   1,   0,  0,   0,   1, 1,  0,  0,  0,  0), # PC1.PR2
       c( 0,   0,   1,  0,   1,   0, 1,  0,  0,  0,  0), # PC2.PR1
       c( 1,   1,   0,  0,   0,   1, 1,  0,  0,  0,  0), # I1.PC1.PR2
       c( 0,   0,   1,  1,   1,   0, 1,  0,  0,  0,  0) # I2.PC2.PR1
   )
   
    teststim <- c("I1", "PC1", "PR1", "I2", "PC2", "PR2", "PC1.PR1",
                  "PC2.PR2", "I1.PC1.PR1", "I2.PC2.PR2", "I1.PC2",
                  "I1.PR2", "I2.PC1", "I2.PR1", "PC1.PR2", "PC2.PR1",
                  "I1.PC1.PR2", "I2.PC2.PR1")                                
     
    bigtr <- NULL
    for(subj in 1:subjs) {
        
        tr <- data.frame(matrix(0, ncol=14, nrow = (blocks * nrow(sr))))
    
        for (i in 1:blocks){
            samp <- sample(1:nrow(sr), nrow(sr))
            tr[(1:nrow(sr)) + nrow(sr) * (i-1), 2] <- i
            tr[(1:nrow(sr)) + nrow(sr) * (i-1), 3] <- trainingitems[samp,
                                                                 "stim"]
            tr[(1:nrow(sr)) + nrow(sr) * (i-1), 4:14] <- sr[samp,]
        }
    
        tr[1,1]<-1
    
        colnames(tr) <- c("ctrl", "block", colnames(trainingitems))
    
        testrials <- data.frame(2, blocks + 1, teststim, testitems)

        colnames(testrials) <- colnames(tr)
        traintrials<-nrow(tr)
        tr <- rbind(tr, testrials)
        tr[(traintrials+1):(nrow(tr)),"ctrl"]<-2
        bigtr <- rbind(bigtr, tr)

    }

   if(!ctxt) bigtr <- bigtr[,c(1:9, 11:14)]
    return(bigtr)
}
