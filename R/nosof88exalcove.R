nosof88exalcove <- function(params = NULL) {
    ## Retrieve parameters from optimization archive as a default
    if(is.null(params)) params <- nosof88exalcove_opt()
    # Set training
    bigtr <- nosof88train('B',blocks = 3, absval = -1, subjs = 100,
                          seed = 4182)
    bigtr <- rbind(bigtr, nosof88train('E2',blocks = 3, absval = -1,
                                      subjs = 100, seed = 4182))
    bigtr <- rbind(bigtr, nosof88train('E7',blocks = 3, absval = -1,
                                      subjs = 100, seed = 4182))
    # Set initial model state
    init.state <- list(colskip = 4, r = 2, q = 1, alpha = c(.5,.5),
                       w = array(0,dim=c(2,12)),
                       h = cbind(c(-2.543,2.641), c(.943,4.341),
                                 c(-1.092,1.848), c(1.558,2.902),
                                 c(-2.258,.430), c(.194,.572),
                                 c(2.806,.202), c(-1.177,-1.038),
                                 c(1.543,-1.040), c(-2.775,-3.149),
                                 c(.528,-3.766), c(1.709,-3.773)
                                 ),
                       c = params[1], phi = params[2], la = params[3],
                       lw = params[4]
                       )
    # Run simulation
    out <- slpALCOVE(init.state,bigtr)
    out <- out$p # Strip out final state info
    #Combine output to training list
    colnames(out) <- c('p1','p2')
    out <- data.frame(cbind(bigtr,out))
    out.ag <- aggregate(out$p2,list(out$stim,out$cond),mean)
    colnames(out.ag) <- c('stim','cond','c2acc')
    return(out.ag)                   
}

    
