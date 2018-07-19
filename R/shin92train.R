shin92train <- function(condition = 'equal3', learn.blocks = 8,
                        trans.blocks = 3, absval = -1, format = 'mds',
                        subjs = 1, seed = 8416, missing = 'geo') {
    set.seed(seed) 
    if(format != 'mds') print("Only MDS format is currently supported.")
    # Conditions are: equal3, equal10, unequal3, unequal10
    # Stimulus numbers refer to row of Table A3, A4.
    # SIZE 3
    # Stimuli seen in training and transfer
    s3train <- rbind(
      c(2,.9305,.0776,-.1429,-1.0717,1,-1,0,0,0,0),
      c(3,.6451,.6287,-.8904,1.0324,1,-1,0,0,0,0),	
      c(4,1.1559,-.3372,-.7329,1.2986,1,-1,0,0,0,0),	
      c(10,-1.5174,-.2961,-.5246,-.2873,-1,1,0,0,0,0),		
      c(11,-.0089,.3389,.4944,1.5733,-1,1,0,0,0,0),	
      c(12,-.4424,.6693,2.7805,-.4533,-1,1,0,0,0,0)
    )
    colnames(s3train) <-
        c('stim','x1','x2','x3','x4','t1','t2','m1','m2','m3','m4')
   # Stimuli seen only in transfer
    s3trans <- rbind(
      c(1,.9694,.0059,-.6209,-.1873,1,-1,0,0,0,0),	
      c(5,1.006,.1898,-.2843,-.9134,1,-1,0,0,0,0),	
      c(6,.6745,.1733,-.4199,-1.3818,1,-1,0,0,0,0),	
      c(7,.6511,-1.5177,.4070,-.9353,1,-1,0,0,0,0),	
      c(8,.8853,1.4833,-.2765,1.0774,1,-1,0,0,0,0),	
      c(9,-.8916,.4258,.8141,-.5962,-1,1,0,0,0,0),	
      c(13,-1.5231,-.0079,-.7041,-.2034,-1,1,0,0,0,0),	
      c(14,-1.5419,-.2912,-1.4898,-.4593,-1,1,0,0,0,0),	
      c(15,-1.2977,.1226,.1353,1.9322,-1,1,0,0,0,0),	
      c(16,0.3051,.9219,.4551,-.4248,-1,1,0,0,0,0)	
    )
    colnames(s3trans) <-
        c('stim','x1','x2','x3','x4','t1','t2','m1','m2','m3','m4')
  # SIZE 10
  # Stimuli seen in training and transfer
    s10train <- rbind(
      c(2,1.0491,-.2873,-.9293,-1.3098,.1752,1.0285,1,-1,0,0,0,0,0,0),
      c(3,.6616,-.6742,-.4599,1.6471,-2.036,-1.2183,1,-1,0,0,0,0,0,0),
      c(4,1.163,-.8203,.1837,.0547,-.4740,-1.3086,1,-1,0,0,0,0,0,0),
      c(5,.6639,-1.3724,.1793,-.9942,-.7799,.5026,1,-1,0,0,0,0,0,0),
      c(6,.3289,-.751,.9431,2.6868,.813,1.7058,1,-1,0,0,0,0,0,0),
      c(7,-.6615,-1.7869,-.3285,.3104,.9705,1.8274,1,-1,0,0,0,0,0,0),
      c(8,.6187,-1.3887,-.0961,.5387,-.3447,-1.6048,1,-1,0,0,0,0,0,0),
      c(9,1.1293,-.3747,.4453,1.0226,-.2598,-1.063,1,-1,0,0,0,0,0,0),
      c(10,1.3625,1.0750,-.2169,.1501,2.1266,.2698,1,-1,0,0,0,0,0,0),
      c(11,.9936,-.6340,1.6302,1.3545,-.4047,-.014,1,-1,0,0,0,0,0,0),
      c(17,-1.7199,-.7317,-.1396,-.5504,-.351,-.578,-1,1,0,0,0,0,0,0),
      c(18,-.2496,1.1003,1.1637,-.6821,-.5739,-.9194,-1,1,0,0,0,0,0,0),
      c(19,-.7028,1.0984,-3.1494,1.0944,.2627,-.3817,-1,1,0,0,0,0,0,0),
      c(20,-.0711,1.5427,1.3221,.8833,-1.2754,.5006,-1,1,0,0,0,0,0,0),
      c(21,-1.4959,.0652,-.7188,.8491,1.2659,-1.1767,-1,1,0,0,0,0,0,0),
      c(22,-1.1607,.5984,-.1829,.1958,.6962,-.5115,-1,1,0,0,0,0,0,0),
      c(23,-.3900,.9843,2.1714,-.1751,.0056,.1282,-1,1,0,0,0,0,0,0),
      c(24,-.4273,1.6937,-.9903,.1280,.2572,-.7118,-1,1,0,0,0,0,0,0),
      c(25,-.4664,1.028,-.4638,-1.0557,-1.9051,1.4363,-1,1,0,0,0,0,0,0),
      c(26,.2417,1.8244,-.5165,.2943,-.3485,1.6476,-1,1,0,0,0,0,0,0)
    )
    colnames(s10train) <-
        c('stim','x1','x2','x3','x4','x5','x6','t1','t2','m1','m2',
          'm3','m4','m5','m6')
  # Stimuli seen only at transfer
    s10trans <- rbind(
      c(1,1.0219,-.7216,.0976,.2306,.3107,.8050,1,-1,0,0,0,0,0,0),
      c(12,1.0806,-.4745,-.8090,-1.006,.3988,.8344,1,-1,0,0,0,0,0,0),
      c(13,.8147,-.6511,-.5738,-1.0349,.7,1.242,1,-1,0,0,0,0,0,0),
      c(14,.9205,-.1507,-1.36,-.2456,-1.9087,.0217,1,-1,0,0,0,0,0,0),
      c(15,.8728,-.5964,.1759,-.7507,2.0278,-1.1888,1,-1,0,0,0,0,0,0),
      c(16,-.8352,1.1134,.3223,-.6718,-.2788,.1390,-1,1,0,0,0,0,0,0),
      c(27,-1.7273,-.7477,-.0072,-.7474,-.1268,.0096,-1,1,0,0,0,0,0,0),
      c(28,-1.7719,-1.1147,.6233,-.7751,-.62,-.1825,-1,1,0,0,0,0,0,0),
      c(29,-1.5775,.1587,.3962,.6772,.6412,.3347,-1,1,0,0,0,0,0,0),
      c(30,.3344,.9955,1.2879,-2.1187,1.036,-1.574,-1,1,0,0,0,0,0,0)
    )
    colnames(s10trans) <-
        c('stim','x1','x2','x3','x4','x5','x6','t1','t2','m1','m2',
          'm3','m4','m5','m6')
    # Make unequal frequency version of size 3 (add multiple stims 2
    # and 10) which are rows 1 and 4.
    s3train.un <- rbind(s3train, s3train[1,], s3train[1,],
                        s3train[1,], s3train[1,], s3train[4,],
                        s3train[4,], s3train[4,], s3train[4,])
    # Make unequal frequency version of size 10 (add multiple stims 2
    # and 17, which are rows 1 and 11).
    s10train.un <- rbind(s10train, s10train[1,], s10train[1,],
                         s10train[1,], s10train[1,], s10train[11,],
                         s10train[11,], s10train[11,], s10train[11,])
    # Code condition as number                    
    cond <- switch(condition, equal3 = 1, equal10 = 2, unequal3 = 3,
                   unequal10 = 10)
    # Set training block according to condition
    train <- switch(condition, equal3 = s3train, equal10 = s10train,
                    unequal3 = s3train.un, unequal10 = s10train.un)
    # Set test block according to condition
    # Note test block also contains trainig items, but always at equal
    # frequency, even in unequal frequency training conditions
    test <- switch(condition, equal3 = rbind(s3train, s3trans),
                   equal10 = rbind(s10train,s10trans), unequal3 =
                   rbind(s3train, s3trans), unequal10 =
                   rbind(s10train, s10trans))
    # Run 'subjs' times
    finalist <- NULL
    for(subj in 1:subjs) {
                                        # Build list
        makelist <- NULL
        makelist2 <- NULL
                                        # Training phase
        if(learn.blocks > 0) {    
            phase <- 1
            for(blk in 1:learn.blocks) {
                block <- cbind(cond,phase,blk,train)
                block <- block[sample(nrow(block)),]
                makelist <- rbind(makelist,block)
            }    
            ctrl <- c(1,rep(0,nrow(makelist)-1))
            makelist <- cbind(ctrl,makelist)
        }
                                        # Test phase
        if(trans.blocks > 0) {
            phase <- 2
            for(blk in 1:trans.blocks) {
                block <- cbind(cond,phase,blk,test)
                block <- block[sample(nrow(block)),]
                makelist2 <- rbind(makelist2,block)
            }    
            ctrl <- 2
            makelist2 <- cbind(ctrl,makelist2)
        }
                                        # Combine the two
        finalist <- rbind(finalist,makelist,makelist2)
    }
    # Drop m1 etc if not geo rep
    if(missing != 'geo') finalist <- finalist[,1:11]
    # If the value for category absence is not -1
    # change the list to reflect this
    if(absval != -1) {
        finalist[finalist[,'t1'] == -1,'t1'] <- absval
        finalist[finalist[,'t2'] == -1,'t2'] <- absval
    }
    return(finalist)
}
