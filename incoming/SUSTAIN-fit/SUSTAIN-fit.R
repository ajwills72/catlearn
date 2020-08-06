## prepare data to run SUSTAIN.
## we want to format the data to run with catlearn's function slpSUSTAIN (check ?catlearn and ?slpSUSTAIN for info. Also this paper is very helpful: https://paperpile.com/app/p/f630452d-d131-08c5-a75e-f74d97b9122c)

## set wd to be this directory
#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

## clean enverionment
rm(list=ls())
#sink(file = "sustain_fit.txt")

##load libraries
library(plyr)
library(tidyverse)
library(catlearn)
library(ggplot2)

##  Define objective function to minimize
sustain_obj <- function(parms) {
  model_obs <- getregpred(parms)
  ret <- ssecl(sumdata_test_empirical$accuracy,model_obs$accuracy)
  return(ret)
}

## import all data from blobs experiment
data_low_sim <- suppressMessages(suppressWarnings(read_delim("experiment_lowsim.txt",delim=" ")))
data_high_sim <- suppressMessages(suppressWarnings(read_delim("experiment_highsim.txt",delim=" ")))

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

## add condition for later use
data_low_sim$sim_cond <- "low_sim"
data_high_sim$sim_cond <- "high_sim"

# fix a variable name 
data_low_sim$studied_rec <- ifelse(data_low_sim$studied=="0","novel","studied")
data_high_sim$studied_rec <- ifelse(data_high_sim$studied=="0","novel","studied")

## aggregaate empirical data for fit
all_data <- rbind(data_high_sim,data_low_sim)

sumdata_test_empirical <- ddply(.data = all_data[all_data$trial_type=="3",],.variables = .(subject,sim_cond,schedule,studied_rec),.fun = summarize,accuracy=mean(hit,na.rm=T))

## load and convert stims structure into padded structure
high_stim <- read_csv("exemplars_highsim.csv")
low_stim <- read_csv("exemplars_lowsim.csv")

high_stim_padded <- convertSUSTAIN(high_stim[,c(2:ncol(high_stim))], c(4,4,4,4,4,4,4,4,3))

low_stim_padded <- convertSUSTAIN(low_stim[,c(2:ncol(low_stim))], c(33,33,34,49,49,49,48,48,3))

high_stim <- cbind(high_stim[1],high_stim_padded)
low_stim <- cbind(low_stim[1],low_stim_padded)

data_high_sim$stim <- paste(data_high_sim$corr_resp,str_remove_all(data_high_sim$fileinfo,"[abcdgfeiou.]"),sep="")
data_high_sim <- join(data_high_sim,high_stim)

data_low_sim$stim <- paste(data_low_sim$corr_resp,str_remove_all(data_low_sim$fileinfo,"[abcdgfeiou.]"),sep="")
data_low_sim <- join(data_low_sim,low_stim)

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

## reorder columns to follow what slpSUSTAIN expects
data_low_sim_ready <- data_low_sim[,c(365,1:362)]
data_high_sim_ready <- data_high_sim[,c(54,1:51)]

## run model
getregpred <- function(parms){
  r = parms[1]
  beta = parms[2]
  d = parms[3]
  eta = parms[4]
  print(r)
  print(beta)
  print(d)
  print(eta)
  
  st_low <- list(r = r,beta=beta,d=d, eta=eta,tau=0,lambda=c(1,1,1,1,1,1,1,1),cluster=NA,w=NA,dims=c(33,33,34,49,49,49,48,48),colskip=17)
  
  tr_low <- data.matrix(data_low_sim_ready)
  
  out_low <- slpSUSTAIN(st = st_low,tr = tr_low)
  
  st_high <- list(r = r,beta=beta,d=d, eta=eta,tau=0,lambda=c(1,1,1,1,1,1,1,1),cluster=NA,w=NA,dims=c(4,4,4,4,4,4,4,4),colskip=17)
  
  tr_high <- data.matrix(data_high_sim_ready)
  
  out_high <- slpSUSTAIN(st = st_high,tr = tr_high)
  
  data_high_sim <- cbind(data_high_sim_ready,out_high$probs)
  data_low_sim <- cbind(data_low_sim_ready,out_low$probs)
  
  # add column with model categorization
  
  data_high_sim$model_cat <- apply(data_high_sim[,c(53,54,55)],1,function(x) which.max(as.numeric(as.character(x)))-1)
  
  data_low_sim$model_cat <- apply(data_low_sim[,c(364,365,366)],1,function(x) which.max(as.numeric(as.character(x)))-1)
  
  # add column with model correctness
  data_high_sim$model_acc <- ifelse(data_high_sim$corr_resp==data_high_sim$model_cat,1,0)
  data_low_sim$model_acc <- ifelse(data_low_sim$corr_resp==data_low_sim$model_cat,1,0)
  
  # merge both sim conditions
  data_all <- rbind(data_high_sim[,c(2:17,56:57)],data_low_sim[,c(2:17,367:368)])
  
  # aggregate by condition
  sumdata_test_model <<- ddply(.data = data_all[data_all$trial_type=="3",],.variables = .(subject,sim_cond,schedule,studied_rec),.fun = summarize,accuracy=mean(model_acc,na.rm=T))
  
  return(sumdata_test_model)
  }

lb <- c(0.00001,0.00001,0.00001,0.00001) # Lower bounds
ub <- c(500,500,500,1)            # Upper bounds

startParms <- c(12, 1, 1, 0.5)
xout <- optim(startParms, sustain_obj, gr=NULL, method = "L-BFGS-B",lower = lb, upper = ub,control=list(maxit = 3000,trace=TRUE)) #to be equivalent to fminsearch

ssecl(sumdata_test_empirical$accuracy,sumdata_test_model$accuracy)
plot(sumdata_test_empirical$accuracy,sumdata_test_model$accuracy); abline(0,1)
cor(sumdata_test_empirical$accuracy,sumdata_test_model$accuracy)^2
