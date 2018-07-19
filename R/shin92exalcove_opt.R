## Run minimization
shin92exalcove_opt <- function(params = c(2, 1, .25, .75),
                               recompute = FALSE,
                               trace = 0) {

    ##  Define objective function to minimize
    .alcove.shin92 <- function(params) {
        out <- shin92exalcove(params)
        ret <- ssecl(out$c2p,catlearn::shin92$c2acc)
        ## 'shin92' for development 
        ## 'catlearn::shin92' for package release
        return(ret)
    }

    ## Set level of output verbosity
    ctrl <- list(trace=trace)
    
    ## Set bounds for optimzation
    lb <- c(0.001,0.001,0.001,0.001) # Lower bounds
    ub <- c(20,5,.90,.90)            # Upper bounds

    if(recompute) {
        ## Run optimzation
        names(params) <- c('c','phi','la','lw')
        result <- optim(params, .alcove.shin92, method = "L-BFGS-B",
                        lower = lb, upper = ub, control = ctrl)
        params <- result$par
    } else {
        ## Set result from stored copy
        params <- c(2.16500692601153, 0.636557148593828, 
                      0.0985741221287437, 0.9)
    }
    
    return(params)
}


