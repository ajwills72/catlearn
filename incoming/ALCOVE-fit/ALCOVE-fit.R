## prepare data to run ALCOVE.
## we want to format the data to run with catlearn's function slpALCOVE (check ?catlearn and ?slpSUSTAIN for info. Also this paper is very helpful: https://paperpile.com/app/p/f630452d-d131-08c5-a75e-f74d97b9122c)

## set wd to be this directory
#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
#setwd(getwd())

## clean enverionment
rm(list=ls())

##load libraries
library(data.table)
library(plyr)
library(tidyverse)
library(catlearn)
library(ggplot2)

##  Define objective function to minimize
alcove_obj <- function(parms) {
  model_obs <- getregpred(parms)
  ret <- ssecl(sumdata_test_empirical$accuracy,model_obs$accuracy)
  return(ret)
}

## import all data from blobs experiment
data_low_sim <- fread("experiment_lowsim.txt")
data_high_sim <- fread("experiment_highsim.txt")

## clean things as we did in the original experiment

data_low_sim$studied_rec <- ifelse(data_low_sim$studied=="x","9",ifelse(data_low_sim$studied=="X","9",data_low_sim$studied)) # 1 == 0 (not studied), 2 == 1 (studied)
data_low_sim$studied_rec <- ifelse(data_low_sim$studied_rec == "1","novel",ifelse(data_low_sim$studied_rec== "2","studied","none"))
data_low_sim$schedule <- ifelse(data_low_sim$schedule == "0","interleaved","blocked")

data_low_sim$rt_correct <- ifelse(data_low_sim$hit == "1",data_low_sim$RT,NA)

data_high_sim$studied_rec <- ifelse(data_high_sim$studied=="x","9",ifelse(data_high_sim$studied=="X","9",data_high_sim$studied)) # 1 == 0 (not studied), 2 == 1 (studied)
data_high_sim$studied_rec <- ifelse(data_high_sim$studied_rec == "1","novel",ifelse(data_high_sim$studied_rec== "2","studied","none"))
data_high_sim$schedule <- ifelse(data_high_sim$schedule == "0","interleaved","blocked")

data_high_sim$rt_correct <- ifelse(data_high_sim$hit == "1",data_high_sim$RT,NA)

## remove sbjs we removed in original analyses
data_low_sim <- data_low_sim[-which(data_low_sim$subject %in% c("1")),]
data_high_sim <- data_high_sim[-which(data_high_sim$subject %in% c("2","3","5","6","8","13","14","17","19","24","28","31","34","35","41","43")),]

## add stimulus features
high_stim <- read_csv("exemplars_highsim.csv")
low_stim <- read_csv("exemplars_lowsim.csv")

data_high_sim$stim <- paste(data_high_sim$corr_resp,str_remove_all(data_high_sim$fileinfo,"[abcdgfeiou.]"),sep="")
data_high_sim <- join(data_high_sim,high_stim)

data_low_sim$stim <- paste(data_low_sim$corr_resp,str_remove_all(data_low_sim$fileinfo,"[abcdgfeiou.]"),sep="")
data_low_sim <- join(data_low_sim,low_stim)

## change stimulus to be only a, b and c
#data_high_sim$fileinfo <- str_remove(data_high_sim$fileinfo,"[abcdgfeiou]")
#data_low_sim$fileinfo <- str_remove(data_low_sim$fileinfo,"[abcdgfeiou]")
#data_high_sim$fileinfo <- ifelse(data_high_sim$corr_resp=="0",paste("a",data_high_sim$fileinfo,sep=""),ifelse(data_high_sim$corr_resp=="1",paste("b",data_high_sim$fileinfo,sep=""),ifelse(data_high_sim$corr_resp=="2",paste("c",data_high_sim$fileinfo,sep=""),"ERROR")))

## add control column (to specify if training or test)
data_low_sim$prev_sbj <- lag(data_low_sim$subject)
data_low_sim$prev_trial_type <- lag(data_low_sim$trial_type)
data_low_sim$prev_sbj <- ifelse(is.na(data_low_sim$prev_sbj),0,data_low_sim$prev_sbj)
data_low_sim$prev_trial_type <- ifelse(is.na(data_low_sim$prev_trial_type),1,data_low_sim$prev_trial_type)

data_low_sim$ctrl <- ifelse(data_low_sim$prev_sbj!=data_low_sim$subject,1,
                            ifelse(data_low_sim$trial_type=="1"&data_low_sim$prev_trial_type=="3"&data_low_sim$prev_sbj==data_low_sim$subject,1,
                                   ifelse(data_low_sim$trial_type=="3",2,0))) 

data_high_sim$prev_sbj <- lag(data_high_sim$subject)
data_high_sim$prev_trial_type <- lag(data_high_sim$trial_type)
data_high_sim$prev_sbj <- ifelse(is.na(data_high_sim$prev_sbj),0,data_high_sim$prev_sbj)
data_high_sim$prev_trial_type <- ifelse(is.na(data_high_sim$prev_trial_type),1,data_high_sim$prev_trial_type)

data_high_sim$ctrl <- ifelse(data_high_sim$prev_sbj!=data_high_sim$subject,1,
                            ifelse(data_high_sim$trial_type=="1"&data_high_sim$prev_trial_type=="3"&data_high_sim$prev_sbj==data_high_sim$subject,1,
                                   ifelse(data_high_sim$trial_type=="3",2,0)))

## add condition for later use
data_low_sim$sim_cond <- "low_sim"
data_high_sim$sim_cond <- "high_sim"

# fix a variable name 
data_low_sim$studied_rec <- ifelse(data_low_sim$studied=="0","novel","studied")
data_high_sim$studied_rec <- ifelse(data_high_sim$studied=="0","novel","studied")

## aggregaate empirical data for fit
all_data <- rbind(data_high_sim,data_low_sim)

sumdata_test_empirical <- all_data[trial_type=="3",.(accuracy=mean(hit,na.rm=T)),by=.(subject,sim_cond,schedule,studied_rec)]

## reorder columns to follow what slpALCOVE expects
data_low_sim_ready <- data_low_sim[,c(37,38,1:34)]
data_high_sim_ready <- data_high_sim[,c(37,38,1:34)]
#data_low_sim <- data_low_sim[data_low_sim$block%in%c("1","5"),]
#data_high_sim <- data_high_sim[data_high_sim$block%in%c("1","5"),]

## run model for high and low similarity seperatedly (because structure is different so exemplar nodes would be different)

h_high <- as.matrix(fread("radial_highsim.csv",header = F))
h_low <- as.matrix(fread("radial_lowsim.csv",header = F))
w <- matrix(0, nrow=3, ncol=18)

getregpred <- function(parms){
  
  c <- parms[1]
  print(c)
  phi <- parms[2]
  print(phi)
  lw <- parms[3]
  print(lw)
  la <- parms[4]
  print(la)
  alpha <-c(0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125)
  
  st_high <- list(c=c,phi=phi,lw=lw,la=la,r=1,q=2,h=h_high,w=w,alpha=alpha,colskip=17)
  st_low <- list(c=c,phi=phi,lw=lw,la=la,r=1,q=2,h=h_low,w=w,alpha=alpha,colskip=17)
  
  tr_high <- data.matrix(data_high_sim_ready)
  tr_low <- data.matrix(data_low_sim_ready)
  
  out_high <- slpALCOVE(st = st_high,tr = tr_high)

  out_low <- slpALCOVE(st = st_low,tr = tr_low)
  
  # get model results into dataframe
  data_high_sim <- cbind(data_high_sim_ready,out_high$prob)
  data_low_sim <- cbind(data_low_sim_ready,out_low$prob)
  all_data <<- rbind(data_high_sim,data_low_sim)
  
  # add column with model categorization
  all_data$model_cat <- apply(all_data[,c(37,38,39)],1,function(x) which.max(as.numeric(as.character(x)))-1)
  
  # add column with model correctness
  all_data$model_acc <- ifelse(all_data$corr_resp==all_data$model_cat,1,0)
  
  # add column with model categorization
  all_data$model_cat <- apply(all_data[,c(37,38,39)],1,function(x) which.max(as.numeric(as.character(x)))-1)
  
  # add column with model correctness
  all_data$model_acc <- ifelse(all_data$corr_resp==all_data$model_cat,1,0)
  
  # aggregate by condition
  sumdata_test_model <<- all_data[trial_type=="3",.(accuracy=mean(model_acc,na.rm=T)),by=.(subject,sim_cond,schedule,studied_rec)]
  
  return(sumdata_test_model)
}

lb <- c(0.000001,0.0000001,0.000001,0.000001) # Lower bounds
ub <- c(20,20,.99,.99)            # Upper bounds

startParms <- c(1,1,.01,.5)
xout <- optim(startParms, alcove_obj, gr=NULL,method = "L-BFGS-B",lower = lb, upper = ub,control=list(maxit = 3000,trace=TRUE)) #to be equivalent to fminsearch

conf.int <-function(x) qnorm(0.975)*sd(x)/sqrt(length(x))

test_empirical <- sumdata_test_empirical[,.(NRuns =.N,accuracy=mean(accuracy,na.rm=T),stderr=sd(accuracy,na.rm=T)/length(unique(paste(sim_cond,subject,sep = ""))),confint=conf.int(accuracy)),by=.(sim_cond,schedule,studied_rec)]

test_model <- sumdata_test_model[,.(NRuns =.N,accuracy=mean(accuracy,na.rm=T),stderr=sd(accuracy,na.rm=T)/length(unique(paste(sim_cond,subject,sep = ""))),confint=conf.int(accuracy)),by=.(sim_cond,schedule,studied_rec)]

studied.labs <- c("New Items", "Old Items")
names(studied.labs) <- c("novel","studied")

plot <- ggplot(test_empirical, aes(x=sim_cond, y=accuracy,fill = schedule)) + geom_bar(position="dodge",stat="identity",color="black",alpha=0.4) + coord_cartesian(ylim = c(0,1), expand = TRUE) + geom_errorbar(data = test_empirical,aes(ymax = accuracy + confint, ymin= accuracy - confint, width=0.2),position=position_dodge(width = 0.90)) + geom_point(data = test_model, aes(x=sim_cond, y=accuracy,group = schedule,colour=schedule),position=position_dodge(width = 0.90),size=4) + geom_errorbar(data = test_model, aes(ymax = accuracy + confint, ymin= accuracy - confint, width=0.2,colour=schedule),position=position_dodge(width = 0.90)) + scale_colour_manual(values=c("#e66101","#b2abd2"),labels = c("Blocked", "Interleaved")) + labs(x="Category Structure",y="Probability of Correct Classification") + theme_bw() +  theme(legend.position="left",legend.title = element_blank(),panel.grid.major = element_blank(),panel.grid.minor=element_blank(),panel.background=element_blank()) + scale_fill_manual(values=c("#e66101","#b2abd2"),labels = c("Blocked", "Interleaved")) + theme(legend.position = c(0.4,0.9)) + scale_x_discrete(labels= c("High Similarity","Low Similarity"))

plot + facet_grid(. ~ studied_rec,as.table = T,labeller = labeller(studied_rec=studied.labs))

ggsave(filename = "results.pdf",plot = graph1,device = "pdf")

ggsave(filename = "Fitting results.png",plot = plot + facet_grid(. ~ studied_rec,as.table = T,labeller = labeller(studied_rec=studied.labs)),width = 8,height = 5)

save.image(paste(getwd(),"Fit.RData",sep="/"))

ssecl(sumdata_test_empirical$accuracy,sumdata_test_model$accuracy)
plot(sumdata_test_empirical$accuracy,sumdata_test_model$accuracy); abline(0,1)
cor(sumdata_test_empirical$accuracy,sumdata_test_model$accuracy)^2
