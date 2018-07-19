nosof94exalcove_opt <- function(recompute = FALSE, xtdo = FALSE) {
    if(recompute) {
        ##  Define objective function to minimize
        .alcove.nosof94 <- function(params) {
            out <- nosof94exalcove(params)
            ret <- ssecl(out$error,catlearn::nosof94$error)
            return(ret)
        }
        ## Suppress output of optim function to console
        ctrl <- list(trace=0)
        ## Set bounds for optimzation
        lb <- c(0.0001,0.0001,0.0001,0.0001) # Lower bounds
        ub <- c(20,20,.99,.99)            # Upper bounds
        ## Set starting conditions
        ## crashed: c(1,1,.01,.01), so removed from list
        pset <- rbind(
            c(1,1,.01,.5), c(1,1,0.5,.01), c(1,1,.5,.5),
            c(1,10,.01,.01), c(1,10,.01,.5), c(1,10,.5,.01),
            c(1,10,.5,.5), c(10,1,.01,.01), c(10,1,.01,.5),
            c(10,1,.5,.01), c(10,1,.5,.5), c(10,10,.01,.01),
            c(10,10,.01,.5), c(10,10,.5,.01), c(10,10,.5,.5)
        )
        colnames(pset) <- c('c','phi','la','lw')
        ## Enable multi-core processing cluster
        cores = detectCores()
        c1 <- makeCluster(cores[1])
        registerDoParallel(c1)
        ## Information message
        print(paste(cores[1],"processing threads detected."))
        ## Produce warning message
        print("The optimization will now be re-calculated.")
        print("This can take some hours, and there is no progress bar.")
        print("Calculating...")
        ## Parallel loop around initial conditions
        i=NULL # Pre-defining i here stops CRAN complaining.
        bigresults <- foreach(i=1:15, .combine=rbind,
                              .packages=c('catlearn')) %dopar% {
            params <- pset[i,]
            names(params) <- c('i.c','i.phi','i.la','i.lw')
            result = tryCatch({
                optim(params, .alcove.nosof94, method = "L-BFGS-B",
                      lower = lb, upper = ub, control = ctrl)
            }, error = function(e) {
                list(par = c(NA,NA,NA,NA), value = NA)
            })
            tempres <- c(params, result$par, result$value)
            tempres # Equivalent to rbind into bigresults
        }
        ## Stop Cluster
        stopCluster(c1)
        ## Cache result
        colnames(bigresults) <- c('i.c','i.phi','i.la','i.lw','c',
                                  'phi','la','lw','fit')
        
        res.cache <- bigresults
        ## End message
        print("...Calculations completed successfully.")
    } else {
        ## If not recomputing, use cached results
        res.cache <-
            structure(c(1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 10, 10,
                        10, 10, 1, 1, 1, 10, 10, 10, 10, 1, 1, 1, 1,
                        10, 10, 10, 10, 0.01, 0.5, 0.5, 0.01, 0.01,
                        0.5, 0.5, 0.01, 0.01, 0.5, 0.5, 0.01, 0.01,
                        0.5, 0.5, 0.5, 0.01, 0.5, 0.01, 0.5, 0.01,
                        0.5, 0.01, 0.5, 0.01, 0.5, 0.01, 0.5, 0.01,
                        0.5, 5.0603, NA, 3.9029, 7.7237, 1.3919,
                        7.3231, 5.8219, 8.792, 9.9338, 9.2038, 9.8279,
                        4.2943, NA, 10, 7.3464, 1.9855, NA, 1.9955,
                        10.0652, 9.9927, 10.3229, 1.9539, 20, 1.9719,
                        20, 1.9738, 1.9518, NA, 10, 8.9759, 0.879, NA,
                        0.9896, 0.9825, 0.0017, 0.6548, 0.9856,
                        0.9363, 0.99, 0.6753, 0.99, 0.99, NA, 0.5003,
                        0.99, 0.0744, NA, 0.077, 0.99, 0.841, 0.479,
                        0.0754, 0.99, 0.072, 0.99, 0.0719, 0.0781, NA,
                        0.0117, 0.0132, 0.1423, NA, 0.146, 1.2589,
                        0.6382, 1.2431, 0.1419, 1.2499, 0.1447,
                        1.2471, 0.1446, 0.1449, NA, 0.2766, 0.2251),
                      .Dim = c(15L, 9L),
                      .Dimnames = list(
                          c(
                              "result.1", "result.2", "result.3",
                              "result.4", "result.5", "result.6",
                              "result.7", "result.8", "result.9",
                              "result.10", "result.11", "result.12",
                              "result.13", "result.14", "result.15"),
                          c("i.c", "i.phi", "i.la", "i.lw", "c",
                            "phi", "la", "lw", "fit")))
    }
    ## Pick the best and return parameters
    params <- res.cache[which.min(res.cache[,9]),5:8]
    names(params) <- c('c','phi','la','lw')
    ## Print the outcomes
    if(xtdo) {
        print("Best fits from different starting points.")
        print(res.cache)
        print("Best fit overall for:")
        print(params)
    }
    return(params)
}





