.choice.rule <- function(qs, rpt, beta, p) {
    vals <- exp(qs * beta + p * rpt)
    return(vals/sum(vals))
}

slpMBMF <- function(st, tr, xtdo = FALSE) {
    ## Initialize variables
    out <- array(0,dim= c(nrow(tr),2)) 
    q1.h <- c(0,0)
    rpt <- c(0,0)
    xout <- NULL
    ## Run through training list
    for(i in 1:nrow(tr)) {
        ## Read action, state, and reward for current trial
        s1.act <- tr[i,'s1.act']
        s2.state <- tr[i,'s2.state']
        t <- tr[i,'t']
        ## Track repeats of previous action for perseveration
        if(i>1) {
            prev.act <- tr[i-1,'s1.act']
            rpt <- c(0,0)
            if(s1.act == prev.act) rpt[prev.act] <- 1
        }
        ## Update QMB (Bellman's)
        st$q1.mb[1] <- (st$tprob[1,1] * st$q2[1] + st$tprob[1,2] *
                            st$q2[2])
        st$q1.mb[2] <- (st$tprob[2,2] * st$q2[2] + st$tprob[2,1] *
                            st$q2[1])
        ## Update Q (hybrid)
        q1.h[1] <- st$q1.mb[1] * st$w + st$q1.mf[1] * (1 - st$w)
        q1.h[2] <- st$q1.mb[2] * st$w + st$q1.mf[2] * (1 - st$w)        
        ## Record response probabilities
        out[i,] <- .choice.rule(q1.h, rpt, st$beta, st$p)
        ## Calculate MF delta at S2, wrt to S1 choice
        s1.d.mf <- st$q2[s2.state] - st$q1.mf[s1.act]
        ## Calculate a bunch of stuff the model doesn't use
        ## (but might be handy as neural regressors)
        if(xtdo) {
            s1.d.mb <- st$q2[s2.state] - st$q1.mb[s1.act]
            s1.d.h <- st$q2[s2.state] - q1.h[s1.act]
            s1.d.diff <- s1.d.mf - s1.d.mb
        }
        ## Update S1 QMF
        st$q1.mf[s1.act] = st$q1.mf[s1.act] + st$alpha * s1.d.mf
        ## Calculate MF delta at outcome
        s2.d.mf <- t - st$q2[s2.state]
        ## Update S2 QMF
        st$q2[s2.state] <- st$q2[s2.state] + st$alpha * s2.d.mf
        ## Stage-skipping update of QMF
        st$q1.mf[s1.act] = st$q1.mf[s1.act] + st$alpha * st$lambda *
            s2.d.mf
        ## Extended output
        if(xtdo) {
            xout <- rbind(xout, cbind(t(st$q1.mb), t(st$q1.mf),
                                      t(st$q2), t(q1.h), s1.d.mf,
                                      s1.d.mb, s1.d.h, s1.d.diff,
                                      s2.d.mf))
        }
    }
    if(xtdo) {
        rownames(xout) <- 1:nrow(xout)
        colnames(xout) <- c('q1.mb.1', 'q1.mb.2', 'q1.mf.1',
                            'q1.mf.2', 'q2.1', 'q2.2', 'q1.h.1',
                            'q1.h.2', 's1.d.mf', 's1.d.mb', 's1.d.h',
                            's1.d.diff','s2.d.mf')
        fout <- list(out = out, q1.mf = st$q1.mf,
                     q1.mb = st$q1.mb, q2 = st$q2, xout = xout)
    } else {
        fout <- list(out = out, q1.mf = st$q1.mf,
                     q1.mb = st$q1.mb, q2 = st$q2)
    }
    return(fout)
}
