## Author: René Schlegelmilch, Andy Wills
## Equation numbers reference to the Appendix of Kruschke (2001, JEP:LMC).
    
slpEXIT <-function(st, tr,xtdo=FALSE) {

    ## Kludgy fix to avoid a R CMD build warning
    silent <- NULL
    
    ## Preparation of processing vars

    ## first column indices of the features
    colFeat1 <- grep("x1$", colnames(tr))

    ## and first column of the teacher values
    colt1 <- grep("t1$", colnames(tr))
    
    ## set up ouptut matrices
    ## response probability matrix will be the default output
    probs_out <- matrix(0, ncol=st$nCat, nrow=nrow(tr))
    
    ## salience vector sigma
    sig <- rep(1,st$nFeat)
    sig[] <- st$sigma

    ## set up weights
    w_exemplars <- st$exemplars
    w_in_out <- st$w_in_out
    
    ## go through all the trials and apply model
    for(j in 1:nrow(tr)){
    
        ## first define indicator variables for correct cats
        ## cCat: index of present cat; eCat: absent cats
        cCat <- eCat <- c()
        
        ## ("try", in case there are no cats e.g. during test trials)
        try(cCat <- which(tr[j, colt1:(colt1 + st$nCat - 1)] == 1),
            silent == TRUE)
        
        ## teaching signals:
        ## t=0 if outcome is absent and t=1 if outcome present.
        teacher <- matrix(0, ncol=st$nCat)
        teacher[cCat] <- 1
        
        ## input activations for current trial 
        a_in <- as.numeric(tr[j, colFeat1:(colFeat1 + st$nFeat - 1)])

        ## calculate exemplar activation a_ex(x)
        ## with minkowski metric Equation (3)
        a_ex<-exp(-st$c*colSums(
            sig*t(abs(t(
                t(st$exemplars)-
                    as.numeric(a_in))))
        ))
        
        ## Is there a user defined intialization?
        if (tr[j, "ctrl"] == 1) {
            w_exemplars <- st$w_exemplars
            w_in_out <- st$w_in_out
        }
        
        ## calculate current activation of gain nodes g
        ## Equation (4) 
        g <- a_in * sig * exp(colSums(w_exemplars * a_ex))

        ## calculate current attention strengths alpha_i
        ## Equation (5) 
        alpha_i <- g/((sum(g^st$P))^(1/st$P))

        ## calculate category activation
        ## Equation (1)
        out_act <- (alpha_i) %*% t(w_in_out)
        
        ## Note: a_in does not appear here, depiste appearing in
        ## Equation (1). This is because including it does not change
        ## the numbers produces. This is, in turn, because alpha_i is
        ## present in Eq. 1, and alpha_i is computed from g (Equation
        ## 5), which is in turn computed from a_in (Equation 4). Where
        ## a_in is zero, g will be zero, and so alpha_i will be
        ## zero. So multiplying by a_in in Equation 1 has no
        ## effect. Where a_in is one, multiplying by it has no effect
        ## on Equation 1 anyway. a_in is only permitted to be 1 or 0
        ## in EXIT, so the a_in term in Equation 1 can have no effect.
       
        ## and category probability
        ## Equation (2)
        probs <- exp(out_act * st$phi) / sum(exp(out_act * st$phi))
        
        ### from here it is learning ##
        
        ## is this a frozen learning trial? (ctrl==2)
        ## if not, then learn, otherwise jump to end
        if(tr[j, "ctrl"] != 2) {
        
            ## Attention Shifting in 'st$iterations' iterations
            ## Equation (7)
            g_inits <- g
            for (k in 1:st$iterations) {
    
                ### Update exemplar gains, attention weights 
                ### and exemplar node weights
    
                ## first term teacher values
                E1 <- (teacher - out_act)
                
                ## second term (wI*a_inI - alpha_I*a_out)
                E2 <- t(as.numeric(a_in) * t(w_in_out) -
                          as.numeric(alpha_i^(st$P-1)) %*% (out_act))
                
                ## Terms E1 and E2 are calculated for each current
                ## input I and then summed accross category nodes
                Ex <- E1 %*% (E2)
                
                ## divided by 3rd term
                E3 <- sum(g^st$P)^(1/st$P)
                
                ## Full equation then:
                gain_delta <- st$l_gain*(Ex/E3)
                
                ## adjust g for current Input I
                g <- g + gain_delta
                g[g<0] <- 0

                ## re-calculate attention strengths alpha_i. Note:
                ## calculated in each iteration according to Kruschke
                ## Equation (5)
                alpha_i <- g/((sum(g^st$P))^(1/st$P))
                
                ## re-calculate category activation. Note: calculated
                ## in each iteration according to Kruschke Equation
                ## (1)
                out_act<-(alpha_i*a_in)%*%t(w_in_out)
                
            }
            
            ## Learning of Associations
            ## Gradient of error for weight change
            ## Equation (8)
            weight_delta <- t(sapply(1:st$nCat , function(x){
                (teacher[x] - out_act[x])*
                    as.numeric(alpha_i)
            }))
            
            w_in_out <- w_in_out + weight_delta * st$l_weight
            
            ## Gradient of error for exemplar gain change
            ## gain from current exemplar X to present input node I 
            ## Equation (9)
            w_exemplars <-
                w_exemplars + st$l_ex *
                (
                    t(
                        as.numeric(g - g_inits)*
                        t(st$exemplars * a_ex) * as.numeric(g_inits)
                      )
                )
            
        } ## learning end
        
    probs_out[j,] <- probs
    
    }

    output <- list()
    output$p <-probs_out
    output$w_in_out <- w_in_out
    output$w_exemplars <- w_exemplars
 
    if (xtdo==T){
        output$g <- g
        }
    
    return(output)
}




