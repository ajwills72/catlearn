################################################################################
################################################################################

################################################################################
################################################################################
## Error minimization function for finding out which parameters 
## can be used to approximate the reported data fits in Figure 10 of the ATRIUM
## article.  "Actual data" is approximated by logit functions, which are below
## desrcibed when reproducing the plot Figure 10 (after fitting). In short,
## they are very closely matching the average data characteristics (smoothed).
## Thus, predictions are made for NN individuals over blocks of training.
## Then they are aggregated according to Figure 10, and the averageis  compared 
## to the "approximate data" via summed squared error, which is then minimized 
## with DEoptim.
minmaxATR<-function(pars,trc,exemplars){
  seg_height<-c(0,.657,1.272,2.224,2.807,3.53,4.24,4.962,5.555,6.131)
  seg_position<-c(0,.997,1.832,3.071,4.092,5.017,5.978,7.243,8.117,8.988)
  st<-list(nCat=4, 
           nFeat=2, 
           beta=c(-mean(seg_position),-mean(seg_height)),
           y_r=c(pars[8],pars[8]), 
           c=pars[7],
           beta_g=pars[1],
           y_g=1,
           phi=pars[2],
           cost=c(1,1), 
           lambda_r=pars[3],
           lambda_e=pars[4],
           lambda_a=pars[5],
           lambda_g=pars[6],
           prime_dim=c(2) 
  ) 
  st$exemplars<-exemplars
  tr<-trc
  predics<-cppATRIUM(st,tr,xtdo=FALSE)$probs
  re1<-cbind(predics,tr)

  ## Correct Rule
  rt1<-aggregate(re1[,1],by=list(r1=re1[,"t1"],block=re1[,"block"]), mean)
  rt2<-aggregate(re1[,2],by=list(r1=re1[,"t2"],block=re1[,"block"]), mean)
  CorrectRuleP<-(rowMeans(cbind(rt1$x[rt1$r1==1],rt2$x[rt2$r1==1])))
  corle<-(1/4)+(3/4)*(1-exp(-1.9*(0:28/28)))
  dev1<-sum((CorrectRuleP-corle)^2)
  
  ## Near Exceptions (t1 and t3 are near; t2 and t4 are near)
  nt1<-aggregate(re1[,3],by=list(r1=re1[,"t1"],block=re1[,"block"]), mean)
  nt2<-aggregate(re1[,4],by=list(r1=re1[,"t2"],block=re1[,"block"]), mean)
  NearRuleP<-(rowMeans(cbind(nt1$x[rt1$r1==1],nt2$x[rt2$r1==1])))
  werle<- ((1/4)-(1/4)*(1-exp(-((abs(0/28-0:28/28))^1.15)/.5)))
  dev2<-sum((NearRuleP-werle)^2)
  
  ## Correct exceptions
  et1<-aggregate(re1[,3],by=list(r1=re1[,"t3"],block=re1[,"block"]), mean)
  et2<-aggregate(re1[,4],by=list(r1=re1[,"t4"],block=re1[,"block"]), mean)
  CorrectExP<-(rowMeans(cbind(et1$x[rt1$r1==1],et2$x[rt2$r1==1])))
  corex<-1-(.75)*(exp(-((abs(-2/28-0:28/28))^1.5)/.66))
  dev3<-sum((CorrectExP-corex)^2)
  
  ## Near Rule
  ent1<-aggregate(re1[,1],by=list(r1=re1[,"t3"],block=re1[,"block"]), mean)
  ent2<-aggregate(re1[,2],by=list(r1=re1[,"t4"],block=re1[,"block"]), mean)
  NExP<-(rowMeans(cbind(ent1$x[rt1$r1==1],ent2$x[rt2$r1==1])))
  werex<-  ((1/2.5)-(1/3)*(1-exp(-((abs(5/28-0:28/28))^1.5)/.4)))
  dev4<-sum((NExP-werex)^2)
  
  ## Also use the transfer data (table from appendix)
  ## Without this, the transfer exception
  ## percentages are generally overestimated
  ## by about 20%, except for the exceptions
  stimuli<-cbind(expand.grid(0:9,0:9),rep(0,100))
  for (i in 1:100){
    stimuli[i,1]<-seg_position[stimuli[i,1]+1]
    stimuli[i,2]<-seg_height[stimuli[i,2]+1]
  }
  test_stims<-stimuli[,1:2]
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
  testXX<-test_stims
  for (k in 1:(-1+nrow(re1)/448)) testXX<-rbind(testXX,test_stims)
  trasnfer2<-re1[re1[,"block"]==30,3:4]
  exprobs<-aggregate(rowSums(trasnfer2),
                     by=list(testXX[,1],testXX[,2]),mean)
  sumtonineTB1<-t(cbind(c(.1,.06,.08,.08,.08,.08,.21,.20,.18,.11),
                        c(.15,.05,.05,.08,.05,.03,.19,.34,.23,.08),
                        c(.05,.13,.10,.16,.18,.24,.32,.81,.39,.42),
                        c(.11,.05,.03,.02,.05,.02,.16,.21,.10,.11),
                        c(.03,.00,.03,.03,.02,.05,.02,.23,.08,.08)))
  dev5<-sum((exprobs$x-
      c(sumtonineTB1[5,],
        sumtonineTB1[4,],
        sumtonineTB1[3,],
        sumtonineTB1[2,],
        sumtonineTB1[1,]))^2)
 
  return(dev1+dev2+dev3+dev4+dev5)
}
################################################################################
################################################################################

stopCluster(cl)
cl <- makeCluster(2)     # set the number of processor cores
setDefaultCluster(cl=cl) # set 'cl' as default cluster
clusterEvalQ(cl, library(catlearn))
clusterEvalQ(cl, library(Rcpp))
clusterEvalQ(cl, library(RcppArmadillo))
clusterEvalQ(cl,sourceCpp("ATRIUMCPP/cppATRIUMv1.cpp"))

################################################################################
################################################################################
lo     = c( -5, 0,0,0,0,0,0,.5)
hi     = c( 5,10,2,2,2,2,20,2)
## 300 iterations, with NP=100 took about 1.5 hours on my laptop
fitATR<-DEoptim(minmaxATR,exemplars=exemplars,trc=trx, lower = lo, upper = hi,
                control = list(NP = 100, cluster=cl, itermax=300, 
                               trace=30, strategy=2))

sqrt(fitATR$optim$bestval/(100+4*29)) ## = average deviation in  p% from "data"
parX<-fitATR$optim$bestmem
stopCluster(cl)
## in this order: beta_g, phi, r, e ,  a , g, sensitivity
