## Author: Rene Schlegelmilch
## (Andy Wills made some minor changes)

## Main function
stsimGCM<-function(st) {
    ## Add weight for last dimension
    st$weights <- as.numeric(c(st$weights, 1-sum(st$weights)))
    
    ## Add choice bias for last category
    st$choice_bias <- as.numeric(
        c(st$choice_bias, 1-sum(st$choice_bias)))
    
    ## recode memory strength
    memory<-matrix(1, ncol=nrow(st$training_items))
    try(memory[which(st$training_items[,"mem"] %in% 1)]<-
            st$mp, silent=TRUE)
    
    ## convenience recoding: sensitivity global
    if (length(st$sensitivity)==1) {
        sensi<-st$sensitivity
    } else {
    ## sensitivity exemplar specific
        sensi<-matrix(st$sensitivity, 
                      ncol=nrow(st$training_items))
    }
    
    
    ## pass to prediction function
    get_p<-.gcm.predictions(tdf=st$tr, 
                            ex=st$training_items,
                            mem=memory,
                            r_met=st$r_metric,
                            c=sensi,
                            p=st$p,
                            gamma=st$gamma,
                            cb=st$choice_bias,
                            weights=st$weights,
                            nCats=st$nCats,
                            nFeat=st$nFeat
    )
    return(get_p)
}

## Prediction function
.gcm.predictions<-function(tdf,ex,mem,r_met,c,p,gamma,cb,weights, 
                           nCats, nFeat) {
    ## get column indices for first feature in training and tr
    feat1col_test<-grep("x1", colnames(tdf))
    feat1col_train<-grep("x1", colnames(ex))
    
    ## Go through every trial/item in the tr matrix/dataframe
    ## and calculate all exemplar similarities weighted by 
    ## memory strength
    sims<-apply(tdf[,feat1col_test:(feat1col_test+nFeat-1)],1, 
                function(x,r, w, sens, p1, memo, 
                         exemplars, ef1col, nF){
                    
                    ## 1.calculates absolute feature differences
                    ## between current item and all training items
                    ## 2. applies metric r
                    ## 3. calculates corresponding summed weighted
                    ## differences and 4. applies metric 1/r 
                    l1<-(colSums(w*(abs(t(exemplars[,
                        ef1col:(ef1col+nF-1)])-(as.numeric(x)))^r))
                        )^(1/r)
                    
                    ## calculates exponential similarity and
                    ## applies p, c and memory parameters
                    l3<- exp(-sens*(l1^p1))*memo
                },
                r=r_met, w=weights, p1=p, sens=c, 
                memo=mem, exemplars=ex, nF=nFeat,
                ef1col=feat1col_train
    )
    
    ## sums exemplar similarities for each category
    cat1col<-grep("cat1", colnames(ex))
    simsums<-t(sims)%*%as.matrix(ex[,cat1col:(cat1col+nCats-1)])
    
    ## applies gamma response scaling parameter
    simsums<-simsums^gamma
    
    ## applies category choice bias
    simsums<-t(cb*t(simsums))
    
    ## transforms category similarities to percent choice probability
    simperx<-simsums/(rowSums(simsums))
    
    return(simperx)
}


