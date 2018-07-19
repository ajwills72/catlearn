nosof88exalcove_opt <- function(recompute = FALSE) {
    if(recompute) {
        ##  Define objective function to minimize
        .alcove.nosof88 <- function(params) {
            out <- nosof88exalcove(params)
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
        ## crashed: c(2,1,.25,.75), so removed from list
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
        res.cache <- bigresults
        ## End message
        print("...Calculations completed successfully.")
    } else {
        ## If not recomputing, use cached results
        res.cache <- structure(c(2, 2, 2, 2, 2, 2, 2, 8, 8, 8, 8, 8, 8, 8,
                             8, 1, 1, 1, 3, 3, 3, 3, 1, 1, 1, 1, 3, 3,
                             3, 3, 0.25, 0.75, 0.75, 0.25, 0.25, 0.75,
                             0.75, 0.25, 0.25, 0.75, 0.75, 0.25, 0.25,
                             0.75, 0.75, 0.25, 0.25, 0.75, 0.25, 0.75,
                             0.25, 0.75, 0.25, 0.75, 0.25, 0.75, 0.25,
                             0.75, 0.25, 0.75, 2.0151, 2.0006, 2.0529,
                             2.1463, 2.2855, 2.4539, 1.5483, 6.3267,
                             4.1929, 7.427, 7.0933, 7.978, 7.543,
                             7.9706, 7.39, 1.0024, 1.0015, 0.8152,
                             2.8275, 2.829, 2.8795, 2.6848, 5, 5,
                             3.5569, 4.9566, 3.8157, 4.5047, 3.8261,
                             4.3981, 0.2209, 0.7511, 0.6824, 0.3564,
                             0.9117, 0.2977, 0.9882, 0.588, 0.9898,
                             0.99, 0.99, 0.2552, 0.3684, 0.7602, 0.99,
                             0.2193, 0.2434, 0.4465, 0.05, 0.0503,
                             0.0525, 0.0546, 0.0282, 0.0278, 0.041,
                             0.0282, 0.0379, 0.0316, 0.0378, 0.0324,
                             0.5512, 0.5573, 0.5763, 0.515, 0.539,
                             0.5275, 0.4965, 0.6118, 0.5931, 0.6135,
                             0.6131, 0.6141, 0.6138, 0.6141, 0.6135),
                           .Dim = c(15L, 9L), .Dimnames = list(
                            c("result.1", "result.2", "result.3",
                              "result.4", "result.5", "result.6",
                              "result.7", "result.8", "result.9",
                              "result.10", "result.11", "result.12",
                              "result.13", "result.14", "result.15"),
                            c("i.c", "i.phi", "i.la", "i.lw", "c", "phi",
                              "la", "lw", "")))
    }
    ## Pick the best and return parameters
    params <- res.cache[which.min(res.cache[,9]),5:8]
    names(params) <- c('c','phi','la','lw')
    return(params)
}


