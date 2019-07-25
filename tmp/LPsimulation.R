# Simulation of a Learned Predictiveness design
# Two learning rules: Rescorla & Wagner (1972) and Mackintosh (1975). 
# Mackintosh based on description in Beesley, Nguyen, Pearson, & Le Pelley (2015)

rm(list=ls())

library(pracma)
library(tidyverse)
library(reshape2)
library(gridExtra)

# simulation parameters
learningRule  <- 2 # 1 = RW72, 2 = Mack75
alpha <-  0.3 # starting value of alpha
beta <-  0.3 
aLR <- .1 # alpha learning rate for Mack75
simPs = 4 # number of simulated participants
numBlocks_Stg1 = 20
numBlocks_Stg2 = 20
trialData <- data.frame(matrix(0,nrow = simPs*(numBlocks_Stg1*8 + numBlocks_Stg2*4),ncol = 47))

colnames(trialData) <- c("simP", "Stage", "Block", "Cue 1", "Cue 2", "Cor Out", "Inc Out",
  "vA_1", "vB_1", "vC_1", "vD_1", "vV_1", "vW_1", "vX_1", "vY_1",
  "vA_2", "vB_2", "vC_2", "vD_2", "vV_2", "vW_2", "vX_2", "vY_2",
  "vA_3", "vB_3", "vC_3", "vD_3", "vV_3", "vW_3", "vX_3", "vY_3",
  "vA_4", "vB_4", "vC_4", "vD_4", "vV_4", "vW_4", "vX_4", "vY_4",
  "aA", "aB", "aC", "aD", "aV", "aW", "aX", "aY") 

count <- 0 # used to determine the row to record data into

for (p in 1:simPs) { # loop for simulated participants
  
  # setup the trial sequence
  
  # Stage 1 trials: (cue1/cue2/correct outcome/incorrect outcome)
  AV1 = c(1,5,1,2); AW1 = c(1,6,1,2)
  BV2 = c(2,5,2,1); BW2 = c(2,6,2,1)
  CX2 = c(3,7,2,1); CY2 = c(3,8,2,1)
  DX1 = c(4,7,1,2); DY1 = c(4,8,1,2)
  stg1Blk <- rbind(AV1,AW1,BV2,BW2,CX2,CY2,DX1,DY1)
  
  # Stage 2 trials: (cue1/cue2/correct outcome/incorrect outcome)
  AX3 = c(1,7,3,4); BY4 = c(2,8,4,3)
  CV3 = c(3,5,3,4); DW4 = c(4,6,4,3)
  stg2Blk <- rbind(AX3,BY4,CV3,DW4)
  
  trialSeq.S1 <- repmat(stg1Blk, numBlocks_Stg1,1)  #repmat is from pracma library (if there's a better way, let me know!)
  trialSeq.S1 <- trialSeq.S1[sample(nrow(trialSeq.S1)),] # shuffle by rows (a crude randomisation, but will make little difference)

  trialSeq.S2 <- repmat(stg2Blk, numBlocks_Stg2,1)
  trialSeq.S2 <- trialSeq.S2[sample(nrow(trialSeq.S2)),]
  
  trialSeq <- rbind(trialSeq.S1,trialSeq.S2) # the final order of trials to present to the model
  
  blockNums <- c(rep(1:numBlocks_Stg1, each=8), rep(1:numBlocks_Stg2, each=4)) # add block numbers
  stageNums <- c(rep(1,nrow(trialSeq.S1)), rep(2,nrow(trialSeq.S2))) # add stage numbers
  
  trialSeq <- cbind(stageNums,blockNums,trialSeq) # final trial sequence array
  
  colnames(trialSeq) <- c("Stage", "Block", "Cue 1", "Cue 2", "Cor Out", "Inc Out")
  
  # inititalise storage variables for simulated subject 
  v <-  matrix(0,nrow=8,ncol=4) # assoc. strength - 8 cues by 4 outcomes
  a <- rep(alpha, 8) # starting values of alpha
  lambda <-  c(1,0) # correct outcome / incorrect outcome (used as it loops outcomes)
  
  for (t in 1:nrow(trialSeq)) {
    cues <-  trialSeq[t,3:4] # current trial cues
    outs <-  trialSeq[t,5:6] # current trial outs (correct, incorrect)
    if (learningRule == 1) {
      # Rescorla-Wagner 1972
      for (o in 1:2) {
        error <- lambda[o] - (v[cues[1],outs[o]] + v[cues[2],outs[o]]) # calculate error based on summed v
        for (c in 1:2){
          v[cues[c],outs[o]] <- v[cues[c],outs[o]] + alpha*beta*error # update v for each cue based on error
        }
      }
    }
    else if (learningRule == 2) {
      # Mackintosh 1975
      for (o in 1:2) {
        for (c in 1:2){
          error <- lambda[o] - v[cues[c],outs[o]] # calculate error based on single v
          v[cues[c],outs[o]] <- v[cues[c],outs[o]] + a[cues[c]]*beta*error # update v for each cue based on error
        }
      }
      # determine best predictor of correct outcome and update alphas
      errDiff <- abs(1 - v[cues[1],outs[1]]) - abs(1 - v[cues[2],outs[1]]) # positive means second cue is better, negative first cue better
      if (errDiff < 0) { # cue 1 the better predictor of correct outcome
        a[cues[1]] <- a[cues[1]] + aLR*abs(errDiff)
        a[cues[2]] <- a[cues[2]] - aLR*abs(errDiff)
      } else if (errDiff > 0) { # cue 2 the better predictor of correct outcome
        a[cues[1]] <- a[cues[1]] - aLR*abs(errDiff)
        a[cues[2]] <- a[cues[2]] + aLR*abs(errDiff)
      }
      a[a<.1] <- .1; a[a>1] <- 1 # impose limits on alpha
    }
    count <- count + 1
    # write the new associative strengths / alphas out next to trial events (add simP num, p)
    trialData[count,] <- c(p,trialSeq[t,],rep(v),a) 
  }
}

# Analysis phase

# Make new columnns from averages of equivalent cues
trialData <- trialData %>% 
  mutate(Pc_v_S1 = rowMeans(trialData[,c("vA_1", "vB_2", "vC_2", "vD_1")])) %>%  # P cues, correct outcome, Stage 1
  mutate(Pi_v_S1 = rowMeans(trialData[,c("vA_2", "vB_1", "vC_1", "vD_2")])) %>% # P cues, incorrect outcome, Stage 1
  mutate(NP_v_S1 = rowMeans(trialData[,c("vV_1", "vV_2", "vW_1", "vW_2", "vX_1", "vX_2", "vY_1", "vY_2")])) %>% # NP cues, Stage 1
  mutate(pPc_v_S2 = rowMeans(trialData[,c("vA_3", "vB_4", "vC_3", "vD_4")])) %>% # Previously P cues, correct outcome, Stage 2
  mutate(pPi_v_S2 = rowMeans(trialData[,c("vA_4", "vB_3", "vC_4", "vD_3")])) %>% # Previously P cues, incorrect outcome, Stage 2
  mutate(pNPc_v_S2 = rowMeans(trialData[,c("vX_3", "vY_4", "vV_3", "vW_4")])) %>% # Previously NP cues, correct outcome, Stage 2
  mutate(pNPi_v_S2 = rowMeans(trialData[,c("vX_4", "vY_3", "vV_4", "vW_3")])) %>% # Previously NP cues, incorrect outcome, Stage 2
  mutate(P_a = rowMeans(trialData[,c("aA", "aB", "aC", "aD")])) %>% # P cues, alpha
  mutate(NP_a = rowMeans(trialData[,c("aV", "aW", "aX", "aY")])) # NP cues, alpha

# set the theme for the graphs
theme_set(theme_minimal())
theme_update(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
             axis.line = element_line(size = 0.5, linetype = "solid", colour = "black"))

# filter and summarize mean values across blocks in Stage 1
Stg1_v_Results <- trialData %>% filter(Stage == 1) %>% 
  group_by(Block) %>% summarise_at(vars(Pc_v_S1,Pi_v_S1,NP_v_S1),mean) # gives summary of vA across participants.
Stg1_a_Results <- trialData %>% filter(Stage == 1) %>% 
  group_by(Block) %>% summarise_at(vars(P_a, NP_a),mean) # gives summary of vA across participants.

# plot the Stage 1 associative strengths
s1_v_graph <- ggplot(melt(Stg1_v_Results, id = "Block"), aes(x = Block, y = value, colour = variable)) + 
  geom_point(size = 2) + geom_line(size = 1) + ylim(-.5,1)
# plot the Stage 1 alpha
s1_a_graph <- ggplot(melt(Stg1_a_Results, id = "Block"), aes(x = Block, y = value, colour = variable)) + 
  geom_point(size = 2) + geom_line(size = 1) +ylim(0,1)

# filter and summarize mean values across blocks in Stage 2
Stg2_v_Results <- trialData %>% filter(Stage == 2) %>% 
  group_by(Block) %>% summarise_at(vars(pPc_v_S2,pPi_v_S2,pNPc_v_S2,pNPi_v_S2),mean) # gives summary of vA across participants.
Stg2_a_Results <- trialData %>% filter(Stage == 2) %>% 
  group_by(Block) %>% summarise_at(vars(P_a, NP_a),mean) # gives summary of vA across participants.

# plot the Stage 2 associative strengths
s2_v_graph <- ggplot(melt(Stg2_v_Results, id = "Block"), aes(x = Block, y = value, colour = variable)) + 
  geom_point(size = 2) + geom_line(size = 1) + ylim(-.5,1)
# plot the Stage 2 alpha
s2_a_graph <- ggplot(melt(Stg2_a_Results, id = "Block"), aes(x = Block, y = value, colour = variable)) + 
  geom_point(size = 2) + geom_line(size = 1) + ylim(0,1)

# present as 2x2 grid - top Vs, bottom alphas
grid.arrange(s1_v_graph, s2_v_graph, s1_a_graph, s2_a_graph, ncol=2)

# #save
g <- arrangeGrob(s1_v_graph, s2_v_graph, s1_a_graph, s2_a_graph, ncol=2) #generates g
ggsave(file="graphOutput.png", g) #saves g

## Lenard's code to extract output at last trial for each ppt

tmp <- by(trialData, trialData[, "simP"], tail, n = 1)
tom <- do.call(rbind, as.list(tmp))[, c(1, 8:39)]
