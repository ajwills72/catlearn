nosof88protoalcove_opt <- function(recompute = FALSE) {
    if(recompute) {
        ##  Define objective function to minimize
        .alcove.nosof88 <- function(params) {
            out <- nosof88protoalcove(params)
            ret <- ssecl(out$c2acc,catlearn::nosof88$c2acc)
            ## 'nosof88' for development 
            ## 'catlearn::nosof88' for package release
            return(ret)
        }
        ## Suppress output of optim function to console
        ctrl <- list(trace=0)
        ## Set bounds for optimzation
        lb <- c(0.0001,0.0001,0.0001,0.0001) # Lower bounds
        ub <- c(20,5,.99,.99)            # Upper bounds
        ## Set starting conditions
        pset <- rbind(
        c(2,1,.25,.25), c(2,1,.75,.25), c(2,1,.75,.75), c(2,3,.25,.25),
        c(2,3,.25,.75), c(2,3,.75,.25), c(2,3,.75,.75), c(8,1,.25,.25),
        c(8,1,.25,.75), c(8,1,.75,.25), c(8,1,.75,.75), c(8,3,.25,.25),
        c(8,3,.25,.75), c(8,3,.75,.25), c(8,3,.75,.75)
        )
        colnames(pset) <- c('c','phi','la','lw')
        ## Enable multi-core processing cluster
        cores = detectCores()
        c1 <- makeCluster(cores[1])
        registerDoParallel(c1)
        ## Information message
        print(paste(cores[1],"processing cores detected."))
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
            result <- optim(params, .alcove.nosof88,
                            method = "L-BFGS-B", lower = lb,
                            upper = ub, control = ctrl)
            tempres <- c(params, result$par, result$value)
            tempres # Equivalent to rbind into bigresults
        }
        ## Stop Cluster
        stopCluster(c1)
        ## Cache result
        colnames(bigresults) <- c('i.c','i.phi','i.la','i.lw','c','phi','la','lw','fit')
        res.cache <- bigresults
        ## End message
        print("...Calculations completed successfully.")
    } else {
        ## If not recomputing, use cached results
        res.cache <-
            structure(c(2, 2, 2, 2, 2, 2, 2, 8, 8, 8, 8, 8, 8, 8, 8,
                        1, 1, 1, 3, 3, 3, 3, 1, 1, 1, 1, 3, 3, 3, 3,
                        0.25, 0.75, 0.75, 0.25, 0.25, 0.75, 0.75,
                        0.25, 0.25, 0.75, 0.75, 0.25, 0.25, 0.75,
                        0.75, 0.25, 0.25, 0.75, 0.25, 0.75, 0.25,
                        0.75, 0.25, 0.75, 0.25, 0.75, 0.25, 0.75,
                        0.25, 0.75, 1.9944, 0.221, 0.221, 0.705,
                        2.0181, 1.0604, 4.791, 7.9074, 7.9851, 6.7185,
                        8.3114, 8.0109, 7.936, 8.1713, 7.9999, 1.0086,
                        1.4041, 1.4039, 3.133, 3.0004, 3.1156, 3.0667,
                        1.033, 1.0241, 1.4424, 1.0103, 3.0058, 3.0093,
                        3.023, 3, 0.2662, 0.0516, 0.0516, 0.6064,
                        0.243, 0.4732, 0.035, 0.5356, 0.1746, 0.1129,
                        0.5056, 0.3374, 0.1969, 0.3795, 0.7503, 0.276,
                        0.99, 0.99, 0.99, 0.75, 0.99, 0.99, 0.6245,
                        0.6101, 0.4982, 0.5056, 0.3934, 0.651, 0.7773,
                        0.7503, 3.2977, 0.4705, 0.4705, 2.0525,
                        2.9387, 2.5683, 2.9963, 3.5348, 3.5026,
                        3.4368, 3.5448, 3.4496, 3.3937, 3.4438,
                        3.5011), .Dim = c(15L, 9L),
                      .Dimnames = list(
                          c("result.1", "result.2", "result.3",
                            "result.4", "result.5", "result.6",
                            "result.7", "result.8", "result.9",
                            "result.10", "result.11", "result.12",
                            "result.13", "result.14", "result.15"),
                          c("i.c", "i.phi", "i.la", "i.lw", "c",
                            "phi", "la", "lw", "fit")))
    }
    ## Pick the best and return parameters
    params <- res.cache[which.min(res.cache[,9]),5:8]
    return(params)
}


