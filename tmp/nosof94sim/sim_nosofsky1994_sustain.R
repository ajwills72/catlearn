## catlearn simulation of Nosofsky et al. (1994) with slpSUSTAIN
rm(list=ls())
source('../R/nosof94plot.R') # unchanged from trunk
source('../R/slpSUSTAIN.R') # new to branch
source('../R/nosof94train.R') # updated in branch
source('../R/nosof94sustain.R') # new to branch

## Simulation results digitised from Love et al. (2004)
love.res <- read.csv("sustain-nosof94-love2004-tidied.csv")
nosof94plot(love.res)

## Simulation results produced by sustain_python
gureck.res <- read.table("shepard1-10kruns.dat", sep = " ")
gureck.res <- t(gureck.res)
gureck.res <- as.data.frame(gureck.res[1:32,])
colnames(gureck.res) <- c("1", "2", "3", "4", "5", "6")
library(tidyverse)
gureck.long <- gather(gureck.res, key = 'type', value = 'error')
block <- rep(rep(1:16, each = 2), times = 6)
gureck.long <- cbind(block, gureck.long)
gureck <- gureck.long %>%
    group_by(type, block) %>%
    summarise(error = mean(error))

max(abs(love.res$error - gureck$error))

round(love.res$error - gureck$error, 2)

nosof94plot(gureck)
nosof94plot(love.res)

### Our simulation
out.store <- nosof94sustain()
nosof94plot(out.store)
round(gureck$error - out.store$error, 2)
##round(love.res$error - out.store$error, 2)

nosof94plot(gureck)

## The following code is a bit of a hack to handle the way the Love et
## al. simulation handles the 'to-criterion' aspect of the experiment.
## This was not used in the CRAN version

load('rawout-1kruns.RData')
out$rnd <- runif(nrow(out))
out$corr <- 0
out$corr[out$pc < out$rnd] <- 1
out$subj <- rep(1:6000, each = 256)
out$subblk <- rep(1:32, each = 8)
out.tc <- aggregate(out$corr, list(out$subblk, out$cond, out$subj), sum)
colnames(out.tc) <- c('subblk', 'cond', 'subj', 'ncor')

btc <- NULL
for(j in 1:6000) {
    ncblk <- 0
    for(i in 1:32) {
        pos <- (j-1) * 32 + i
        if(out.tc$ncor[pos] == 8) {
            ncblk <- ncblk + 1
        } else {
            ncblk <- 0
        }
        if(ncblk == 4) {
            btc <- rbind(btc, out.tc[pos,])
            break
        }
    }
}

## Looking for outliers
library(tidyverse)
btc1 <- btc %>% filter(cond == 1)
hist(btc1$subblk)
## Run 17 seems pretty extreme
trial.store <- out %>% filter(subj == 17 & cond == 1 & blk == 1)
trial.store <- trial.store[1:8,5:12]

out.ag <- aggregate(out$pc, list(out$blk, out$subblk, out$cond, out$subj), mean)
colnames(out.ag) <- c('blk','subblk', 'cond', 'subj', 'error')

for(i in 1:6000) {
    first <- btc$subblk[i]
    out.ag$error[out.ag$subj == i & out.ag$subblk > btc$subblk[i]] <- 0
}

out.ag.f <- aggregate(out.ag$error,list(out.ag$blk,out.ag$cond),mean)
colnames(out.ag.f) <- c('block','type','error')
nosof94plot(out.ag.f) 

round(gureck$error - out.ag.f$error, 2)

#### Code for checking stateful aspect of function.
st <- list(r = 9.01245,
           beta = 1.252233,
           d = 16.924073,
           eta = 0.092327,
           tau = 0.0,
           lambda = out$lambda,
           dims = c(2, 2, 2),
           cluster = out$cluster,
           w = out$w,
           colskip = 4)

out2 <- slpSUSTAIN(st, tr.me, xtdo = FALSE)
out2
#######

