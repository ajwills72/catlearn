nosof88protoalcove <- function(params = NULL) {
    ## Retrieve parameters from optimization archive as a default
    if(is.null(params)) params <- nosof88protoalcove_opt()

    bigout <- NULL
    # Define prototypes, by condition
    h = cbind(c(-2.543,2.641), c(.943,4.341), c(-1.092,1.848),
              c(1.558,2.902), c(-2.258,.430), c(.194,.572),
              c(2.806,.202), c(-1.177,-1.038), c(1.543,-1.040),
              c(-2.775,-3.149), c(.528,-3.766), c(1.709,-3.773))
    ## Condition B
    cat1 <- cbind(h[,1],h[,5],h[,8],h[,10],h[,11],h[,12])
    cat1p <- rowMeans(cat1)
    cat2 <- cbind(h[,2],h[,3],h[,4],h[,6],h[,7],h[,9])
    cat2p <- rowMeans(cat2)
    hb <- cbind(cat1p,cat2p)
    ## Condition E2
    cat2 <- cbind(h[,2],h[,2],h[,2],h[,2],h[,2],h[,3],h[,4],h[,6],
                  h[,7],h[,9])
    cat2p <- rowMeans(cat2)
    he2 <- cbind(cat1p,cat2p)
    ## Condition E7
    cat2 <- cbind(h[,2],h[,3],h[,4],h[,6],h[,7],h[,7],h[,7],h[,7],
                  h[,7],h[,9])
    cat2p <- rowMeans(cat2)
    he7 <- cbind(cat1p,cat2p)
    ## Housekeeping
    rm(h,cat1,cat1p,cat2,cat2p)
    
    # Set model initial state (h will be changed later)
    init.state <- list(colskip = 4, r = 2, q = 1, alpha = c(.5,.5),
                       w = array(0,dim=c(2,2)), h = hb, c = params[1],
                       phi = params[2], la = params[3],
                       lw = params[4])
    
    # Condition B
    ## Set training
    bigtr <- nosof88train('B',blocks = 3, absval = -1, subjs = 100,
                          seed = 4182)
    ## Run simulation
    init.state$h <- hb
    out <- slpALCOVE(init.state,bigtr)
    out <- out$p
    colnames(out) <- c('p1','p2')
    out <- data.frame(cbind(bigtr,out))
    out.ag <- aggregate(out$p2,list(out$stim,out$cond),mean)
    bigout <- rbind(bigout,out.ag)

    # Condition E2
    ## Set training
    bigtr <- nosof88train('E2',blocks = 3, absval = -1, subjs = 100,
                          seed = 4182)
    ## Run simulation
    init.state$h <- he2
    out <- slpALCOVE(init.state,bigtr)
    out <- out$p
    colnames(out) <- c('p1','p2')
    out <- data.frame(cbind(bigtr,out))
    out.ag <- aggregate(out$p2,list(out$stim,out$cond),mean)
    bigout <- rbind(bigout,out.ag)

    # Condition E7
    ## Set training
    bigtr <- nosof88train('E7',blocks = 3, absval = -1, subjs = 100,
                          seed = 4182)
    ## Run simulation
    init.state$h <- he7
    out <- slpALCOVE(init.state,bigtr)
    out <- out$p
    colnames(out) <- c('p1','p2')
    out <- data.frame(cbind(bigtr,out))
    out.ag <- aggregate(out$p2,list(out$stim,out$cond),mean)
    bigout <- rbind(bigout,out.ag)
    colnames(bigout) <- c('stim','cond','c2acc')

    return(bigout)    
    }
