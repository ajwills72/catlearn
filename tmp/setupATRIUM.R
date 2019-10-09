## Simulation of Erickson & Kruschke (1998, Exp. 1) with slpATRIUM
## René Schegelmilch, Andy Wills
## GPL 3.0

## AW: I split the optimize code off into another file.

library(catlearn)
library(Rcpp)
library(RcppArmadillo)
library(optimParallel)
library(DEoptim)

## Function for later plotting
mypal <- colorRampPalette( c("black", "white" ) )( 100 )
map2color <- function(x, pal, limits = NULL){
    if(is.null(limits)) limits <- range(x)
    pal[findInterval(x, seq(limits[1], limits[2], length.out = length(pal) + 1), 
                     all.inside = TRUE)]
}

## Model parameters
parX <- c(-2.01670452, 2.81326750,  0.02032553,  0.48252118,  1.08771288 ,
          1.93983134 , 3.31032516, 1.12242019)
## beta_g (gate bias), phi, lambda_r, lambda_e, lambda_a, lambda_g, sensitivity

## These were the closest approximation René could so far get.  but this is
## definitely depending on the trial order sample The values reported by
## Erickson & Kruschke (1998) were: c(-1.78984, 4.07742, .03375, .32163,
## 1.96593, .41313, 1.28296, .87080). But, the reported parameters led nowhere
## near the reported predictions. So René did a parameter optimization based on
## 40 simulated participants fitted against the average learning curves
## (Fig. 10) and transfer exception probabilities (Table B1) reported in
## Erickson & Kruschke (1998).

## Load Rcpp Version of ATRIUM
sourceCpp("../src/slpATRIUM.cpp")

## Generate NN participants for siomulation.
NN <- 40
triallist <- list()  # will hold all partiicpant trials

## The following were defined by René inside the loop, which is inefficient
## as obviously they are the same for each iteration of the loop. I moved them.

## These stimulus co-ordinates are from Erickson & Kruschke (1998) Figure
## C3.
seg_height   <-
    c(0.000, 0.657, 1.272, 2.224, 2.807, 3.53, 4.24, 4.962, 5.555, 6.131)
seg_position <-
    c(0.000, 0.997, 1.832, 3.071, 4.092, 5.017, 5.978, 7.243, 8.117, 8.988)
train_stim <- t(cbind(c(2, 2, 0, 0, 1, 0),
                      c(1, 4, 1, 0, 0, 0),
                      c(4, 1, 1, 0, 0, 0),
                      c(5, 3, 1, 0, 0, 0),
                      c(7, 2, 1, 0, 0, 0),
                      c(8, 4, 1, 0, 0, 0),
                      c(1, 5, 0, 1, 0, 0),
                      c(2, 7, 0, 1, 0, 0),
                      c(4, 6, 0, 1, 0, 0),
                      c(5, 8, 0, 1, 0, 0),
                      c(7, 7, 0, 0, 0, 1),
                      c(8, 5, 0, 1, 0, 0)
                      ))

for (n in 1:NN){
  ## logical stimulus values (0 to 9)
    stimuli <- cbind(expand.grid(0:9, 0:9), rep(0, 100))
    sr <- train_stim
  
  ## replace logical stim values by similarity scaling values
    for (i in 1:100){
        stimuli[i, 1] <- seg_position[stimuli[i, 1] + 1]
        stimuli[i, 2] <- seg_height[stimuli[i, 2] + 1]
    }

    for (i in 1:12){
      sr[i, 1] <- seg_position[sr[i, 1] + 1]
      sr[i, 2] <- seg_height[sr[i, 2] + 1]
    }
  
    exemplars <- sr[, 1:2]
    colnames(exemplars) <- c("x1", "x2")
    trainingblocks <- 29
    tr <- as.data.frame(matrix(0, nrow = (trainingblocks * 12),
                               ncol = (1 + 4 + 2 + 2)))
    for (i in 1:trainingblocks){
        samp <- sample(1:12, 12)
        tr[(1:12) + 12 * (i-1), 2:7] <- sr[samp, ]
        tr[(1:12) + 12 * (i-1), 8] <- samp
        tr[(1:12) + 12 * (i-1), 9] <- i
    }
    tr[1, 1] <- 1
    test_stims <- stimuli[,1:2]
    colnames(tr) <- c("ctrl", "x1", "x2", "t1", "t2", "t3", "t4", "stim",
                      "block")
    
    testtrials <- as.matrix(cbind(
        rep(0, nrow(test_stims)),
        test_stims,
        rep(0, nrow(test_stims)),
        rep(0, nrow(test_stims)),
        rep(0, nrow(test_stims)),
        rep(0, nrow(test_stims)),
        rep(0, nrow(test_stims)),
        rep(30, nrow(test_stims))))
    
    colnames(testtrials) <- c("ctrl", "x1", "x2", "t1", "t2", "t3", "t4", "stim",
                              "block")
    tr <- rbind(tr, testtrials)
    tr[tr[, "block"] == 30, 1] <- 2
    tr <- as.matrix(tr)
    triallist[[n]] <- tr  
}

## Combine all pariticpants to one long tr file "trx"
## (is possible because the network resets if ctrl = 1)
trx <- triallist[[1]]
for (n in 2:NN){
  trx <- rbind(trx, triallist[[n]])
}

## This function takes in a set of parameters
## and data (like trc), and exemplars (defined "exemplars" in loop above)
## and returns a list of predictions added with cbind) to the trc file
## which then can be processed

minitman <- function(pars, data, exemplars){
    st <- list(nCat = 4, 
               nFeat = 2, 
               ## rule bias (-boundary); index 1: first; 2: second 
               beta = c(-mean(seg_position), -mean(seg_height)),
               ## perceptual sensitivity on each dimension (indices)
               ## a.k.a. rule gain
               y_r = c(pars[8], pars[8]), 
               c = pars[7],         # specificity
               beta_g = pars[1],    # gate bias
               y_g = 1,             # gate gain
               phi = pars[2],       # response scaling
               cost = c(1,1),       # index 1: exemplar; 2: rule module
               lambda_r = pars[3],  # rule learning
               lambda_e = pars[4],  # exemplar learning
               lambda_a = pars[5],  # attention learning
               lambda_g = pars[6],  # gate learning
               ## prime_dim tells the model on which dim the rule is (could be
               ## more than one)
               prime_dim=c(2)
               )
    st$exemplars <- exemplars
    tr <- data
    predics <- cppATRIUM(st, tr, xtdo = FALSE)$probs
    return(cbind(predics, tr))
}

## Run simulation
re1 <- minitman(parX, data = trx, exemplars)

## Recreate Figure 10 in Erickson & Kruschke (1998)
layout(matrix(1:2, ncol = 2, nrow = 1))
par(oma = c(2, 3, 1, 1), mar = c(1, 2, 1, 1))

## The participants' performance is approximated (as in fitting),
## by the forumulas below, which satisfy some data characteristics 
## as noted for each formula
## Predcitions left plot

rt1 <- aggregate(
    re1[, 1], by = list(r1 = re1[, "t1"], block = re1[, "block"]), mean)

rt2 <- aggregate(
    re1[, 2], by = list(r1 = re1[, "t2"], block = re1[, "block"]), mean)

CorrectRuleP <- (rowMeans(cbind(rt1$x[rt1$r1 == 1],rt2$x[rt2$r1 == 1])))

nt1 <- aggregate(
    re1[, 3], by = list(r1 = re1[, "t1"], block = re1[, "block"]), mean)

nt2 <- aggregate(
    re1[, 4], by = list(r1 = re1[, "t2"], block = re1[, "block"]), mean)

NearRuleP <- (rowMeans(cbind(nt1$x[rt1$r1 == 1],nt2$x[rt2$r1 == 1])))

## Approximated data curves (also used for fitting)
## Note Correct Rule starts ar .25 and ends at .89
## .6 is arrived at about block 11
corle <- (1/4) + (3/4) * (1 - exp(-1.9 * (0:28/28)))

## Note Near Exception starts ar .25 and ends at .03
## it hits .1 at about 15 blocks
werle <- ((1/4)-(1/4)*(1 - exp(-((abs(0/28 - 0:28/28))^1.15)/.5)))

plot(corle, ylim = c(0,1), type = "l", lty = 1,pch = 21,bg = 0, lwd = 2,
     axes = F)
box(lwd = 2)
axis(side = 1, at = seq(0, 30, 5), labels = seq(0, 30, 5), lwd = 2)
par(las = 1)
axis(side = 2, at = seq(0, 1, .2), labels = seq(0, 1, .2), lwd = 2)
par(las = 1)
points(corle, ylim = c(0, 1), type = "p", lty = 1, pch = 21, bg = 0, lwd = 2)
lines(CorrectRuleP, lty = 3, lwd = 2)
points(CorrectRuleP, pch = 21, bg = 0, lwd = 2)
lines(werle, lwd = 2)
points(werle, pch = "|")
lines(NearRuleP, lty = 3, lwd = 2)
points(NearRuleP, pch = "|")

# Predictions: right plot
et1 <- aggregate(
    re1[, 3], by = list(r1 = re1[, "t3"], block = re1[, "block"]), mean)

et2 <- aggregate(
    re1[, 4], by = list(r1 = re1[, "t4"], block = re1[, "block"]), mean)

CorrectExP <- (rowMeans(cbind(et1$x[rt1$r1 == 1],et2$x[rt2$r1 == 1])))

ent1 <- aggregate(
    re1[, 1], by=list(r1 = re1[, "t3"], block = re1[, "block"]), mean)

ent2 <- aggregate(
    re1[, 2], by = list(r1 = re1[, "t4"], block = re1[, "block"]), mean)

NExP <- (rowMeans(cbind(ent1$x[rt1$r1 == 1],ent2$x[rt2$r1 == 1])))

## note Correct Exception starts at .25 and ends at .87
## .6 is hit at about block 13
corex <- 1 - (.75) * (exp(-((abs(-2 / 28 - 0:28 / 28))^1.5) / .66))

## note Neare rule peaks at about block 4 with .4,
## the intersencts with Corect exceptiosn at about block 6.2 
## then .2 is hit at about 22 blocks, and ends with about .1
## the lines intersect at about block 5
werex <- ((1/2.5) - (1/3) * (1-exp(-((abs(5 / 28 - 0:28 / 28))^1.5) / .4)))

plot(corex, ylim = c(0, 1), type = "l", lty = 1, pch = 21, bg = 0, lwd = 2,
     axes = F)
box(lwd = 2)
axis(side = 1, at = seq(0, 30, 5), labels = seq(0, 30, 5), lwd = 2)
par(las = 1)
axis(side = 2, at = seq(0, 1, .2), labels = seq(0, 1, .2), lwd = 2)
par(las = 1)
points(corex, ylim = c(0, 1), type = "p", lty = 1, pch = 21,bg = 0, lwd = 2)
lines(CorrectExP, lty = 3, lwd = 2)
points(CorrectExP, pch = 21, bg = 0, lwd = 2)
lines(werex, lwd = 2)
points(werex, pch = "|")
lines(NExP, lty = 3, lwd = 2)
points(NExP, pch = "|")

## Now, for some reason I'm not sure about, René runs the simulation again.
## with the same parameters as before...


## AW: It's around here, I stopped. It's not really that clear what's going on.
## I think you've moved to simulating Experiment 2, without having looked at
## the transfer phase of Exp. 1, but I'm not sure why, particularly as the
## Exp. 1 simulation doesn't reproduce the participants' training repsonses
## very well (see graph, right panel, top line -- end of training performance
## seriously underestimated).

## Also the code is kind of a mess. From here, there's a bunch of stuff being
## defined that has already been defined earlier, which is inefficient and
## makes it hard for others to follow your code.


parC <- parX

trainPlot1 <- array(NA, dim = c(50, 2, 29))
trainPlot2 <- array(NA, dim = c(50, 2, 29))
transPlot <- array(NA, dim = c(50, 4, 100))

for (n in 1:50){
    ## AW: Remove seg height/post defs, as already defined

    ## "Replicate" Fits of Erickson & Kruschke 1998
    ## the fitted settings are these: Experiment 1
  st<-list(nCat=4, 
           nFeat=2, 
           beta=c(-mean(seg_position),-mean(seg_height)), #rule bias (-boundary); index 1: first; 2: second 
           # dimension
           y_r=c(parC[8],parC[8]), #rule gain
           c=parC[7],#1.28296, #specificity
           beta_g=parC[1],#.1 #1.78984, #gate bias
           y_g=1,  # gate gain
           phi=parC[2],#4.07742, # response scaling
           cost=c(1,1), # index 1: exemplar; 2: rule module
           lambda_r=parC[3],# .03375, # rule learning
           lambda_e=parC[4],#.32163, # exemplar learning
           lambda_a=parC[5],#1.96593, # attention learning
           lambda_g=parC[6],#.41313, # gate learning
           prime_dim=c(2) # tells the model on which dim the rule is (could be more than one)
  ) 
  #st$beta_g=-1.78984
  ## note: prime_dim 1 in the paper is the column "x2" in tr here, which is
  ##  prime_dim=2
  ## (can also be a vector with multiple dimensions, the rules will be generated 
  ## automatically.
  ## i.e. nRules=length(prime_dim)
  
  
  ## logical stimulus values (0 to 9)
  stimuli<-cbind(expand.grid(0:9,0:9),rep(0,100))
  sr<-t(cbind(
    c(2,2,0,0,1,0),
    c(1,4,1,0,0,0),
    c(4,1,1,0,0,0),
    c(5,3,1,0,0,0),
    c(7,2,1,0,0,0),
    c(8,4,1,0,0,0),
    c(1,5,0,1,0,0),
    c(2,7,0,1,0,0),
    c(4,6,0,1,0,0),
    c(5,8,0,1,0,0),
    c(7,7,0,0,0,1),
    c(8,5,0,1,0,0)
  ))
  
  ## replace logical stim values by similarity scaling values
  for (i in 1:100){
    stimuli[i,1]<-seg_position[stimuli[i,1]+1]
    stimuli[i,2]<-seg_height[stimuli[i,2]+1]
  }
  test_stims<-stimuli[,1:2]
  for (i in 1:12){
    sr[i,1]<-seg_position[sr[i,1]+1]
    sr[i,2]<-seg_height[sr[i,2]+1]
  }
  
  # plot of the category structure:
  # layout(matrix(1))
  # plot(test_stims, pch=0,cex=5, xlab="Secondary Dimension",ylab="Primary 
  # Dimension")
  # points(sr[sr[,3]==1,1:2],pch=16,cex=3)
  # points(sr[sr[,4]==1,1:2],pch=15,cex=3)
  # points(x=sr[sr[,5]==1,1],y=sr[sr[,5]==1,1],pch=1,cex=3, lwd=3)
  # points(x=sr[sr[,6]==1,1],y=sr[sr[,6]==1,1],pch=0,cex=3, lwd=3)
  
  st$exemplars<-sr[,1:2]
  colnames(st$exemplars)<-c("x1","x2")
  trainingblocks<-29
  tr<-as.data.frame(matrix(0,nrow=(trainingblocks*12),
                           ncol=(1+st$nCat+st$nFeat+2)))
  for (i in 1:trainingblocks){
    samp<-sample(1:12,12)
    tr[(1:12)+12*(i-1),2:7]<-sr[samp,]
    tr[(1:12)+12*(i-1),8]<-samp
    tr[(1:12)+12*(i-1),9]<-i
  }
  tr[1,1]<-1
  test_stims<-stimuli[,1:2]
  colnames(tr)<-c("ctrl","x1","x2","t1","t2","t3","t4","stim","block")
  testtrials<-as.matrix(cbind(rep(0,nrow(test_stims)),test_stims,
                              rep(0,nrow(test_stims)),rep(0,nrow(test_stims)),rep(0,nrow(test_stims)),
                              rep(0,nrow(test_stims)),rep(0,nrow(test_stims)),rep(30,nrow(test_stims))))
  colnames(testtrials)<-c("ctrl","x1","x2","t1","t2","t3","t4","stim","block")
  tr<-rbind(tr,testtrials)
  head(tr)
  tr[tr[,"block"]==30,1]<-2
  tr<-as.matrix(tr)
  tr[1:16,]
  layout(1)
  #plot(y=tr[1:16,"x2"],x=tr[1:16,"x1"],pch=22,bg=sapply(1:16,function(x){which.max(tr[x,c("t1"#,"t2","t3","t4")])}), ylim=c(0,9), cex=4,xlim=c(0,6))
  
  
  predics<-cppATRIUM(st,tr,xtdo=FALSE)$probs
  cbind(tr,predics,cppATRIUM(st,tr,xtdo=TRUE)$a_g)[50:70,]
  1/(1+exp(-.87080*(5.240-3.2)))
  ### Generating plot like in Figure 16; but with ATRIUM predictions only
  ## left plot
  layout(matrix(1:2,1,2))
  library(plyr)
  ## Tule = t1 and t2
  t1<-which((tr[,"t1"]==1) & tr[,1]!=2)
  t2<-which(tr[,"t2"]==1  & tr[,1]!=2)
  t3<-which(tr[,"t3"]==1  & tr[,1]!=2)
  t4<-which(tr[,"t4"]==1  & tr[,1]!=2)
  tr1<-aggregate(predics[t1,1], by=list(block=tr[t1,"block"]),mean)
  tr2<-aggregate(predics[t2,2], by=list(block=tr[t2,"block"]),mean)
  tr1n1<-aggregate(predics[t1,3], by=list(block=tr[t1,"block"]),mean)
  tr2n2<-aggregate(predics[t2,4], by=list(block=tr[t2,"block"]),mean)
  #plot(NULL,xlim=c(0,30),ylim=c(0,1), ylab="p(Correct)",xlab="Trainingblock")
  #points(rowMeans(cbind(tr1[,2],tr2[,2])), type="b",pch=1)
  trainPlot1[n,1,]<-rowMeans(cbind(tr1[,2],tr2[,2]), na.rm=T)
  #points(rowMeans(cbind(tr1n1[,2],tr1n2[,2],tr2n1[,2],tr2n2[,2])), type="b",pch=2)
  trainPlot1[n,2,]<-rowMeans(cbind(tr1n1[,2],tr2n2[,2]))
  #legend(x=0,y=1,legend=c("Correct Rule","Near Exception"), pch=1:2, bty = "n")
  ## note: with the settings reported in Erickson & Kruschke (fits for scaled dimensions)
  ## the model produces crazy predcitions 
  ## use (some) alternative settings for better behavior
  tr[t4,]
  predics[t3,]
  ## right plot
  tr1<-aggregate(predics[t3,3], by=list(block=tr[t3,"block"]),mean)
  tr2<-aggregate(predics[t4,4], by=list(block=tr[t4,"block"]),mean)
  tr1n1<-aggregate(predics[t3,1], by=list(block=tr[t3,"block"]),mean)
  tr1n2<-aggregate(predics[t4,2], by=list(block=tr[t4,"block"]),mean)
  #plot(NULL,xlim=c(0,30),ylim=c(0,1), ylab="p(Correct)",xlab="Trainingblock")
  #points(rowMeans(cbind(tr1[,2],tr2[,2])), type="b",pch=1)
  trainPlot2[n,1,]<-rowMeans(cbind(tr1[,2],tr2[,2]))
  #points(rowMeans(cbind(tr1n1[,2],tr1n2[,2])), type="b",pch=2)
  trainPlot2[n,2,]<-rowMeans(cbind(tr1n1[,2],tr1n2[,2]))
  #legend(x=0,y=1,legend=c("Correct Exception","Near Rule"), pch=1:2, bty="n")
  ## Note: if a rule predicts two categories,
  ## each exception could be predicted into one of the two "rule categores", 
  ## that's why here are 4 trianlge lines (2 exception categoriesx2rulecategories).
  ## The two triangle lines that make this curved turn represent 
  ## the applied rules, overall (e.g. large to A and small to B), 
  ## which of course means that when A is predicted for one exception then B is not,
  ## the B curve then goes flat.
  ## Note: When lambda_e is set to 0 then categories 3 and 4 (exceptions), 
  ## are covered by one of two different rules each (triangles in the right graph)
  
  ## Transfer Stimuli
  testp<-predics[tr[,"block"]==30,]
  ### First: The plot as shown in Figure 13; exception = category 4
  ### note: space is not rotated as in the paper
  layout(matrix(1))
  squaresize<-5  ## size of the filled squares
  #plot(y=test_stims[,2],x=test_stims[,1], cex=squaresize,pch=0, 
  #     ylab="Primary Dimension (D1)", xlab="Secondary Dimension (D2)",
  #     ylim=c(-0.5,6.5),xlim=c(-.5,9.5))
  categorypredictions<-2 #3 or 4
  #points(y=test_stims[,2],x=test_stims[,1], cex=squaresize, pch=15,
  #       col=map2color(testp[,categorypredictions],mypal, limits=c(0,1)))
  
  ## insert choice probabilities
  #xxx<-as.character(round(testp[,categorypredictions],2))
  #text(y=test_stims[,2],x=test_stims[,1], cex=1, labels=xxx, col="white")
  transPlot[n,,]<-t(testp)
}
# 
layout(matrix(c(1,2,3,3),ncol=2,nrow=2, byrow=2))
par(oma=c(1,1,1,1),mar=c(2,2,0,0))
plot(NULL,xlim=c(0,30),ylim=c(0,1), ylab="p(Correct)",xlab="Trainingblock")
points(colMeans(trainPlot1[,1,], na.rm=T), type="b",pch=1)
points(colMeans(trainPlot1[,2,], na.rm=T), type="b",pch=2)
legend(x=0,y=1,legend=c("Correct Rule","Near Exception"), pch=1:2, bty = "n")

plot(NULL,xlim=c(0,30),ylim=c(0,1), ylab="p(Correct)",xlab="Trainingblock")
points(colMeans(trainPlot2[,1,], na.rm=T), type="b",pch=1)
points(colMeans(trainPlot2[,2,], na.rm=T), type="b",pch=2)
legend(x=0,y=1,legend=c("Correct Exception","Near Rule"), pch=1:2, bty = "n")

## all exception probs

test_stims[1:10,1]<-rev(test_stims[91:100,1])
test_stims[11:20,1]<-rev(test_stims[81:90,1])
test_stims[21:30,1]<-rev(test_stims[71:80,1])
test_stims[31:40,1]<-rev(test_stims[61:70,1])
test_stims[41:50,1]<-rev(test_stims[51:60,1])

test_stims[1:10,2]<-(test_stims[91:100,2])
test_stims[11:20,2]<-(test_stims[81:90,2])
test_stims[21:30,2]<-(test_stims[71:80,2])
test_stims[31:40,2]<-(test_stims[61:70,2])
test_stims[41:50,2]<-(test_stims[51:60,2])
exprobs<-colMeans(transPlot[,4,]+transPlot[,3,], na.rm=T)
exprobs<-aggregate(exprobs, by=list(test_stims[,1],test_stims[,2]),mean,na.rm=T )

squaresize<-5  ## size of the filled squares
plot(y=test_stims[,2],x=test_stims[,1], cex=squaresize,pch=0,
     ylab="Primary Dimension (D1)", xlab="Secondary Dimension (D2)",
     ylim=c(3,6.5),xlim=c(-.5,9.5))
points(y=exprobs$Group.2,x=exprobs$Group.1, cex=squaresize, pch=15,
       col=map2color(exprobs$x,mypal, limits=c(0,1)))
## insert choice probabilities
xxx<-as.character(round(exprobs$x,2))
text(y=exprobs$Group.2,x=exprobs$Group.1, cex=1, labels=xxx, col="white")


