# Subfunctions --------------------------

## Probability of making the right response (Eq. 8)
## AW: OK, 2018-03-21
.prob.response <- function(C.out, decision.consistency) {
    prob.denom <- sum(exp(decision.consistency * C.out))  # denominator
    prob.nom <- exp(decision.consistency * C.out)  # nominator
    prob <-  prob.nom / prob.denom
    return(prob)
}

## Calculating stimulus distance from a cluster (Eq. 4)
## AW: OK, 2018-03-21
.calc.distances <- function(input, cluster, fac.dims, fac.na) {
    mu <- matrix(0, nrow = nrow(cluster),
                 ncol = length(unique(fac.dims)))
    for (k in 1:nrow(cluster)) {
        mu[k, ] <- as.vector(tapply(abs(input - cluster[k, fac.na]), fac.dims,
                                    sum)) * 0.5 ## Equation 4
    }
    return(mu)
}


## Utility function for selecting a random cluster between those
## who have tied activations

.random <- function(act) {
    tmp <- which(act == max(act))
    ret <- tmp[sample(length(tmp), 1)]
    return(ret)
}

## Calculating cluster activation and related values (Eq.5, 6, A6)
## act - Activation of each cluster (Eq. 5)
## out - Activations after cluster competition (Eq. 6)
## rec - Recognition score from A6 equation in Appendix in Love and Gureckis (2007)

## mu.lambda - Product of mu and lambda, calculated within function
## but also needed in later calculation, so returned.

## AW: OK, 2018-03-21
.cluster.activation <- function(lambda, r, beta, mu, ties) {
    mu.lambda <- sweep(mu, MARGIN = 2, -lambda, `*`)
    nom <- sweep(exp(mu.lambda), MARGIN = 2, lambda ^ r, `*`)
    act <- apply(nom, MARGIN = 1, sum) / sum(lambda ^ r) # Equation 5
    out <- (act ^ beta / sum(act^beta)) * act # Equation 6
    rec <- sum(out) # Equation A6
    switch(
           ties,
           "random" = winner <- .random(act),
           "first" = winner <- which.max(act)
    )
    out[-winner] <- 0 # For all other non-winning clusters = 0
    clus <- list("act" = act,
              "out" = out,
              "rec" = rec,
              "mu.lambda" = mu.lambda,
              "winner" = winner)
    return(clus)
}


# Main function ----------------------------------

slpSUSTAIN <- function(st, tr, xtdo = FALSE, ties = "random") {

## Imports from st --------------------------------

    ## Internally, colskip is implemented slightly differently in slp
    ## SUSTAIN to other slp functions. To avoid this potentially
    ## confusing difference, the following line is needed
    colskip <- st$colskip + 1

    lambda <- st$lambda
    w <- st$w
    cluster <- st$cluster
    maxcat <- st$maxcat

    ## maxcat introduced in v.0.7, so older sims will not have set it
    ## We need to detect this and set to default value, otherwise older
    ## simulations will break. AW 2019-10-03
    if(is.null(maxcat)) maxcat <- 0

    ## Setting up factors for later

    ## fac.dims: The dimension each position in the stimulus input refers
    ## to. For example, in a three dimensional stimulus with 2,3, and 2, levels
    ## on the dimensions, this would return 1 1 2 2 2 3 3

    fac.dims <- rep(seq_along(st$dims), st$dims)

    ## The numbers 1:N, where N is the length of fac.dims. Useful in various
    ## pieces of code later on

    fac.na <- seq(sum(st$dims))


## Setting up environment ------------------------

    ## Arrays for xout
    sim <- NULL
    xout <- rep(0, nrow(tr))
    activations <- rep(0,nrow(tr))
    prob.o <- NULL
    rec <- rep(0,nrow(tr))

### Error checking ---------------------------------

    ## Check that dimensions and values match up, return error if they don't
    if (length(st$dims) != length(lambda)) {
        stop(paste(
                   "length of dimensions mismatch. \n",
                   "dim, lambda, w, ",
                   "and cluster are not of equal lengths.\n"
                   ),
            call. = TRUE)
        }

## Run simulation ---------------------------------

    for (i in 1:nrow(tr)) {

        ## Setting up current trial

        ## trial - Import current trial
        trial <- tr[i, ]

        ## fac.queried: The positions of the queried dimension values in the
        ## stimulus input
        if (trial['ctrl'] %in% c(0, 1, 2)) {
            fac.queried <- seq(sum(st$dims) + 1, ncol(tr) - colskip + 1)
        } else {
            fac.queried <- fac.na
        }

### Error checking ---------------------------------

        ## On first trial, check if colskip is correct
        ## Note, arguments evaluated from left to right, so it is only
        ## executed during supervised trials, because unsupervised trials
        ## have no queried dimensions and it has not been tested.
        if (i == 1 && trial["ctrl"] %in% 0:2 &&
            max(fac.queried) + colskip - 1 != ncol(tr)) {
            stop("colskip is not correct.\nCheck number of optional columns!",
            call. = TRUE)
        }

        ## input - Set up stimulus representation
        input <- as.vector(trial[colskip:(colskip + sum(st$dims) - 1)])

        ## Reset network if requested to do so.
        if (trial['ctrl'] %in% c(1, 4)) {
            ## Revert to a single cluster centered on the current trial's
            ## stimulus
            w <- st$w
            lambda <- st$lambda
            cluster <-st$cluster
            ## If cluster is NA, set up a single cluster centered on
            ## the first training stimulus. (The length == 1 thing is
            ## to avoid a tedious warning message).

            if(length(cluster) == 1) {
                if(is.na(cluster)) {
                    cluster <- matrix(as.vector(trial[colskip:(ncol(tr))]),
                                         nrow = 1)
                }
            }

            ## If w is NA, set up zero weights to a single cluster

            if(length(w) == 1) {
                if(is.na(w)) {
                    w <- matrix(rep(0, ncol(cluster)), nrow = 1)
                }
            }

        }
        ## Equation 4 - Calculate distances of stimulus from each cluster's
        ## position
        mu <- .calc.distances(input, cluster, fac.dims, fac.na)

        ## c.act - The activations of clusters and recognition scores
        c.act <- .cluster.activation(lambda, st$r, st$beta, mu, ties)

        ## C.out - Activations of output units (Eq. 7)
        ## AW: OK, 2018-03-23
        C.out <- w[which.max(c.act$act), ] * c.act$out[which.max(c.act$act)]

        ## Response probabilites (Eq.8) - calculated across queried dimension
        ## for supervised learning and across all dimensions for unsupervised
        ## learning.
        ## AW: OK, 2018-03-23
        if (trial["ctrl"] %in% c(0,1,2)){
            prob.r <-  .prob.response(C.out[fac.queried], st$d)
        } else {
            prob.r <-  .prob.response(C.out, st$d)
        }

        ## Kruschke's (1992) humble teacher (Eq. 9)
        ## AW: OK, 2018-03-23
        target <- as.vector(trial[colskip:(length(trial))])
        target[target == 1] <- pmax(C.out[which(target == 1)], 1)
        target[target == 0] <- pmin(C.out[which(target == 0)], 0)

        ## Cluster recruitment in supervised learning

        ## (If the network has been reset this trial , we should not
        ## create a new cluster, as that has already been done).
        ## AW: 2018-03-23: OK
        new.cluster <- FALSE
        exist.cluster <- FALSE
        ## Rules for new cluster under supervised learning

        if (trial["ctrl"] == 0) {

            ## t.queried - the index of the unit in the queried
            ## dimension that has the highest activation.

            t.queried <- which.max(C.out[fac.queried])

            ## If the highest-activated unit has a target value of
            ## less than one, the model has made an error and recruits
            ## a new cluster.
            if (target[fac.queried][t.queried] < 1) new.cluster <- TRUE

            ## An edge case is if there is a tie between the most and
            ## second most active unit. Here, we should create a new
            ## cluster.

            in.order <- C.out[fac.queried][order(C.out[fac.queried])]
            if(in.order[1] == in.order[2]) new.cluster <- TRUE

        }

        ### Cluster recruitment in unsupervised learning
        ### and in unsupervised free-sorting tasks
        ### (e.g. Medin et al. 1987)
        ## AW: OK, 2018-04-19

        if (trial["ctrl"] == 3 & maxcat > 0) {
            if (max(c.act$act) < st$tau &
                maxcat > nrow(cluster)) new.cluster <- TRUE
        } else if (trial["ctrl"] == 3 & maxcat == 0) {
            if (max(c.act$act) < st$tau) new.cluster <- TRUE
        }

        ## If new.cluster is true, make sure the cluster doesn't
        ## already exist
        if (new.cluster) {
            ## Do not recruit new cluster if cluster already exists
            sim <- rowSums(abs(sweep(cluster,
                                 2,
                                 as.vector(trial[colskip:(length(trial))]),
                                 FUN = "-"
                                 )))
            if (any(sim == 0)) {
                new.cluster <- FALSE
                exist.cluster <- TRUE
            }
        }

        ### Adding a new cluster if appropriate.
        ## AW: OK, 2018-04-19
        if (new.cluster == TRUE) {
            ## Create new cluster centered on current stimulus

            cluster <- rbind(cluster,
                             as.vector(trial[colskip:(length(trial))]))

            ## The new cluster gets a set of weights to the queried
            ## dimension, intialized at zero

            w <-  rbind(w, rep(0, length(st$w)))

            ## The new cluster also needs a set of distances to the
            ## presented stimulus (which will of course be zero)

            mu <- rbind(mu, vector(mode = "numeric",
                                   length = length(st$dims)))

            ## ..and now we have to re-calculate the activation of all
            ## clusters
            c.act <- .cluster.activation(lambda, st$r, st$beta, mu, ties)
        }

        ## UPDATES
        ## Check if cluster already exists, if yes, update that cluster
        ## otherwise select new one or the winner
        ifelse(exist.cluster == TRUE,
               win <- which(sim == 0)[1],
               win <- c.act$winner)

        if (trial['ctrl'] %in% c(0, 1, 3, 4)) {
            ## Update position of winning cluster (Equ. 12)
            ## AW: OK, 2018-03-23
            cluster[win, fac.na] <-
                cluster[win, fac.na] +
                (st$eta * (input - cluster[win,fac.na]))

            ## Upquate receptive tuning field (Equ. 13)
            ## (Note: mu.lambda includes the minus sign, hence the absence of a
            ## minus sign in its first use below, and the presence of the
            ## addition sign in the second use (despite minus in Eq. 13 here).
            ## AW: OK, 2018-03-23
            lambda <- lambda + (st$eta * exp(c.act$mu.lambda[win, ]) *
                                (1 + c.act$mu.lambda[win, ]))

            ## Equation 14 - one-layer delta learning rule (Widrow & Hoff, 1960)
            ## AW: Corrected, 2018-03-23
            w[win, fac.queried] <- w[win, fac.queried] +
                (st$eta * (target[fac.queried] - C.out[fac.queried]) *
                 c.act$out[win])
        }

        ## Record additional information about the trial
        ## AW: 2018-04-19, OK
        xout[i] <- win ## Identity of winning cluster
        activations[i] <- c.act$out[win] ## Activation of winning cluster
        prob.o <- rbind(prob.o, prob.r) ## Response probabilities
        rec[i] <- c.act$rec ## Recognition score
    }

## Organise output --------------------

    ## AW: 2018-04-19, OK
    rownames(prob.o) <- NULL

    if (xtdo) {
        extdo <- cbind("probabilities" = prob.o, "winning" = xout,
                       "activation" = activations,
                       "recognition score" = rec)
    }

    if (xtdo) {
        ret <- list("xtdo" = extdo, "lambda" = lambda,
                "cluster" = cluster, "w" = w)
    } else {
        ret <- list("probs" = prob.o, "lambda" = lambda,
                "w" = w, "cluster" = cluster)
    }
    return(ret)
}
