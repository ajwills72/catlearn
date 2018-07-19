shin92protoalcove <- function(params = NULL) {
    ## Retrieve parameters from optimization archive as a default
    if(is.null(params)) params <- shin92protoalcove_opt()
    # Size 3 condition
    # Set training
    bigtr3 <- shin92train(condition = 'equal3', absval = -1,
                          format = 'mds', subjs = 100, seed =8416)
    # Set hidden units
    h3 <- shin92train(condition = 'equal3', learn.blocks = 0,
                      trans.blocks = 1, absval = -1, format = 'mds',
                      subjs = 1, seed =8416)
    h3 <- h3[order(h3[,'stim']),]
    h3 <- h3[,c('x1','x2','x3','x4')]
    h3 <- t(h3)
    pro1 <- rowMeans(h3[,2:4])
    pro2 <- rowMeans(h3[,10:12])
    h3p <- cbind(pro1,pro2)
    # Set model initial state
    init.state3 <- list(colskip = 5, r = 2, q = 1,
                        alpha = c(.25,.25,.25,.25),
                        w = array(0,dim=c(2,2)), h = h3p,
                        c = params[1], phi = params[2],
                        la = params[3], lw = params[4])
    # Run simulation
    out <- slpALCOVE(init.state3,bigtr3)
    out <- out$p # Strip out final state info
    colnames(out) <- c('p1','p2')
    # Combine output to training list
    out <- data.frame(cbind(bigtr3,out))
    out <- out[out$phase == 2,]
    out.ag3 <- aggregate(out$p2,list(out$cond,out$stim),mean) 
    colnames(out.ag3) <- c('cond','stim','c2p')
    # Size 10 condition
    # Set training
    bigtr10 <- shin92train(condition = 'equal10', absval = -1,
                          format = 'mds', subjs = 100, seed =8416)
    # Set hidden units
    h10 <- shin92train(condition = 'equal10', learn.blocks = 0,
                      trans.blocks = 1, absval = -1, format = 'mds',
                      subjs = 1, seed =8416)
    h10 <- h10[order(h10[,'stim']),]
    h10 <- h10[,c('x1','x2','x3','x4','x5','x6')] 
    h10 <- t(h10)
    pro1 <- rowMeans(h10[,2:11])
    pro2 <- rowMeans(h10[,17:26])
    h10p <- cbind(pro1,pro2)

    # Set model initial state
    init.state10 <- list(colskip = 5, r = 2, q = 1,
                        alpha = c(1/6,1/6,1/6,1/6,1/6,1/6),
                        w = array(0,dim=c(2,2)), h = h10p,
                        c = params[1], phi = params[2],
                        la = params[3], lw = params[4])
    # Run simulation
    out <- slpALCOVE(init.state10,bigtr10)
    out <- out$p # Strip out final state info
    colnames(out) <- c('p1','p2')
    # Combine output to training list
    out <- data.frame(cbind(bigtr10,out))
    out <- out[out$phase == 2,]
    out.ag10 <- aggregate(out$p2,list(out$cond,out$stim),mean) 
    colnames(out.ag10) <- c('cond','stim','c2p')
    out.ag <- rbind(out.ag3,out.ag10)
    return(out.ag)
}
