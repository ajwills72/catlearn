/*
    SUSTAINModel.cpp
    cogc++
    Created by Todd Gureckis (gureckis@love.psy.utexas.edu) on Sat Aug 12 2002.
 
    SUSTAIN: A network model of category learning
    Model developed by Bradley C. Love (love@psy.utexas.edu)
    Copyright (C) 2002  Todd M. Gureckis (gureckis@love.psy.utexas.edu)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
*/

#include "SUSTAINModel.h"

/*++++++++++++++++++++++++++++++++++++++++++++++
    Hack ()
    
    brad's hack function
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::Hack()
{

}

/*++++++++++++++++++++++++++++++++++++++++++++++
    Setup ()
    
    local Setup function... (if you want to 
    add something to the standard setup function)
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::Setup(const char *file, char *model) 
{
    //sustaindata = new SUSTAINData[n_problems];
    
    COGCategoryLearningModel::Setup (file, model);
}



/*++++++++++++++++++++++++++++++++++++++++++++++
    GetRecognitionResponse

++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::GetRecognitionResponse () 
{

    double recog = 0.0;
    if ( network->recog_type == SUM_ACT ) {
        // $$$$$ sum the activations of all clusters
        for (unsigned i = 0; i < network->clusters.size(); i++)
            recog += network->clusters[i].activation;
    }
    else if ( network->recog_type == SUM_OUT ) {
        // $$$$$ use the overall familiarity (default)
        for (unsigned i = 0; i < network->clusters.size(); i++)
            recog += network->clusters[i].output;
    }
    else  {  // network->recog_type == HIGHEST_OUT is the default!
        // $$$$$ the output of the most activated cluster
        // after cluster competition the first one should be the most activated
        recog = network->clusters[0].output;
    }
    return recog;
 
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    GetCategoryResponse

++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::GetCategoryResponse () 
{

    // for each output unit
    // if unit is unknown
    // return output
    for (unsigned int i = 0; i < network->outputUnits.size(); i++) {
        if(network->outputUnits[i].GetStatus() == UNKNOWN) {
            return network->outputUnits[i].GetActivation();
        }
    }

}

/*++++++++++++++++++++++++++++++++++++++++++++++
    GetUnsupCategory

++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::GetUnsupCategory () 
{
    return network->clusters[0].ident;
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    CreateModel ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::CreateModel () {
    network = new SUSTAINNetwork(pd[cp].config, pd[cp].param, pd[cp].filepair[0]);
}


/*++++++++++++++++++++++++++++++++++++++++++++++
    DeleteModel (COGPga *pga)

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::DeleteModel () {
    delete network;
    //delete [] sustaindata;
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    Stimulate (COGCategoryLearningStimulusItem &item)

++++++++++++++++++++++++++++++++++++++++++++++++*/
int
SUSTAINModel::Stimulate (COGCategoryLearningStimulusItem& item) {
    return network->StimulateNetwork(item);
}


/*++++++++++++++++++++++++++++++++++++++++++++++
    ForcedChoice (COGCategoryLearningStimulusItem &item)

++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::ForcedChoice (COGCategoryLearningStimulusItem& correct, COGCategoryLearningStimulusItem& incorrect) {
    
    // $$$$$
    if ( network->recog_type == SUM_OUT ) {
        // $$$$$ use the output of the most activated cluster
        // after cluster competition the first one should be the most activated
        return network->ForcedChoice0(correct, incorrect);
    }
    else if ( network->recog_type == HIGHEST_OUT ) {
        // $$$$$ use the output of the most activated cluster
        // after cluster competition the first one should be the most activated
        return network->ForcedChoice1(correct, incorrect);
    }
    else if ( network->recog_type == SUM_ACT ) {
        // $$$$$ use the sum of activations of all clusters
        return network->ForcedChoice2(correct, incorrect);
    }
    else {
        // $$$$$ default
        return network->ForcedChoice(correct, incorrect);
    }
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    ResponseProbability ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::ResponseProbability () {
    return network->GetProbability ();
}


/*++++++++++++++++++++++++++++++++++++++++++++++
    DoLearning ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::DoLearning () {
    network->DoLearning();
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    RunAnalysis ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::RunAnalysis (int runid) {

    //cout << "run analysis" << endl;
    // get average number of clusters
    int n_clusters = network->GetNClusters ();
    sustaindata[cp].avg_clusters += n_clusters;
        
    sustaindata[cp].cluster_freq[n_clusters] += 1;
    
    COGCategoryLearningModel::RunAnalysis (runid);
}


/*++++++++++++++++++++++++++++++++++++++++++++++
    OutputRunAnalysis ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::OutputRunAnalysis (const char *fn) {
    // output run analysis
    if (pd[cp].problem_type == 9) // if sl_category_size
    {
        network->OutputAnalysis(fn, pd[cp].filepair[1].items);
    }
    else 
    {
        network->OutputAnalysis(fn, pd[cp].filepair[0].items);
    }
}


/*++++++++++++++++++++++++++++++++++++++++++++++
    OutputExtraAnalysis ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::OutputExtraAnalysis (const char *fn, int i) {

    ofstream outfile(fn);
    
    if(!outfile) {
	// ADD ERROR CHECKING HERE
	cout << "error opening " << fn << " for output cluster analysis" << endl;
	exit(0);
    }
	
    outfile << "condition = " << i << endl;
    outfile << "meanclusters = " << sustaindata[i].avg_clusters << endl;
    
    int max = 0;
    int max_index = 0;
    for(unsigned int j = 1; j < CLUSTER_FREQ_SIZE; j++) {
	if(sustaindata[i].cluster_freq[j] > max) {
	    max = sustaindata[i].cluster_freq[j];
	    max_index = j;
	}
    }
    outfile << "modeclusters = " << max_index << endl;

    outfile << "clusterfrequencies = { ";
    for(unsigned int j = 1; j < CLUSTER_FREQ_SIZE; j++) {
	outfile << sustaindata[i].cluster_freq[j];
	if(j != CLUSTER_FREQ_SIZE-1) {
	    outfile << ", ";
	}
    }
    outfile << " }" << endl;
    
    outfile << "avgblockstocriterion = " << pd[i].avg_blocks_to_criterion << endl;
    outfile << endl;
    
    // $$$$$ write some stuff
    
    vector<double> recogModel(5);
    vector<double> recogHuman(5);
    double sumModel = 0.0;
    double sumHuman = 0.0;
    double meanModel = 0.0;
    double meanHuman = 0.0;
    double sdModel = 0.0;
    double sdHuman = 0.0;
    
    if (pd[i].problem_type == 7) // if pn3
    { 
        recogModel[0] = pd[i].except_recog;
        recogModel[1] = pd[i].reg_recog;
        recogModel[2] = pd[i].prot_recog;
        recogModel[3] = pd[i].newSim_recog;
        recogModel[4] = pd[i].newDisim_recog;
        
        int n = recogModel.size();
        
        //ok, do model
        //calculate mean
        for (int j = 0; j < n; j++) 
            sumModel += recogModel[j];
        meanModel=sumModel/n;
        
        // calculate sd
        for (unsigned int j = 0; j < n; j++) 
            sdModel+=pow(recogModel[j]-meanModel,2);
        if (sdModel>0.000001)   
            sdModel=sqrt(sdModel/(n-1));
        else sdModel=1.0;
        
        //transform to t
        for (unsigned int j = 0; j < n; j++)
            recogModel[j]=(recogModel[j]-meanModel)/sdModel;
        
        //ok, do human
        //calculate mean
        for (int j = 0; j < n; j++) {
            recogHuman[j] = pd[i].humandata[j + n];
            sumHuman += recogHuman[j];
        }
        meanHuman=sumHuman/n;
        
        // calculate sd
        for (unsigned int j = 0; j < n; j++) 
            sdHuman+=pow(recogHuman[j]-meanHuman,2);
        if (sdHuman>0.000001)   
            sdHuman=sqrt(sdHuman/(n-1));
        else sdHuman=1.0;
            
        for (unsigned int j = 0; j < n; j++)
            recogModel[j]=(recogModel[j]*sdHuman)+meanHuman;

        /////////////////////////////////////////////////////
        // debugging remove me
        /////////////////////////////////////////////////////
        cout << "classification (test phase)" << endl;
        cout << "  exception: " << pd[i].except_corr << ", " << pd[i].humandata[0] << endl;
        cout << "  rules old: " << pd[i].reg_corr << ", " << pd[i].humandata[1] << endl;
        cout << "  prototype: " << pd[i].prot_corr << ", " << pd[i].humandata[2] << endl;
        cout << "  novel sim: " << pd[i].newSim_corr << ", " << pd[i].humandata[3] << endl;
        cout << "  novel dis: " << pd[i].newDisim_corr << ", " << pd[i].humandata[4] << endl;
        cout << endl;
        cout << "recognition (test phase)" << endl;
        cout << "  exception: " << recogModel[0] << ", " << recogHuman[0] << endl;
        cout << "  rules old: " << recogModel[1] << ", " << recogHuman[1] << endl;
        cout << "  prototype: " << recogModel[2] << ", " << recogHuman[2] << endl;
        cout << "  novel sim: " << recogModel[3] << ", " << recogHuman[3] << endl;
        cout << "  novel dis: " << recogModel[4] << ", " << recogHuman[4] << endl;
        cout << endl;
        cout << "prot-expt: " << pd[i].prot_corr - pd[i].except_corr << ", " << pd[i].humandata[2] - pd[i].humandata[0] << endl;
        cout << endl;
        /////////////////////////////////////////////////////
        /////////////////////////////////////////////////////
        
        outfile << "(item type: model performance , human performance)" << endl;
        outfile << endl;
        outfile << "exception: " << pd[i].except_corr << ", " << pd[i].humandata[0] << endl;
        outfile << "rules old: " << pd[i].reg_corr << ", " << pd[i].humandata[1] << endl;
        outfile << "prototype: " << pd[i].prot_corr << ", " << pd[i].humandata[2] << endl;
        outfile << "novel sim: " << pd[i].newSim_corr << ", " << pd[i].humandata[3] << endl;
        outfile << "novel dis: " << pd[i].newDisim_corr << ", " << pd[i].humandata[4] << endl;
        outfile << endl;
        outfile << "exception: " << recogModel[0] << ", " << recogHuman[0] << endl;
        outfile << "rules old: " << recogModel[1] << ", " << recogHuman[1] << endl;
        outfile << "prototype: " << recogModel[2] << ", " << recogHuman[2] << endl;
        outfile << "novel sim: " << recogModel[3] << ", " << recogHuman[3] << endl;
        outfile << "novel dis: " << recogModel[4] << ", " << recogHuman[4] << endl;
        outfile << endl;
        outfile << "prot-expt: " << pd[i].prot_corr - pd[i].except_corr << ", " << pd[i].humandata[2] - pd[i].humandata[0] << endl;
        outfile << endl;

    }
    else if ((pd[i].problem_type == 9) || (pd[i].problem_type == 16) || (pd[i].problem_type == 17)) // if sl3
    {
        /////////////////////////////////////////////////////
        // debugging remove me
        /////////////////////////////////////////////////////
        cout << "recognition (test phase)" << endl;
        cout << "  expt small: " << pd[i].smallX_recog << ", " << pd[i].humandata[0] << endl;
        cout << "  rule small: " << pd[i].smallR_recog << ", " << pd[i].humandata[1] << endl;
        cout << "  expt large: " << pd[i].largeX_recog << ", " << pd[i].humandata[2] << endl;
        cout << "  rule large: " << pd[i].largeR_recog << ", " << pd[i].humandata[3] << endl;
        cout << "  novel item: " << pd[i].novel_recog << ", " << pd[i].humandata[4] << endl;
        cout << endl;
        cout << "classification (test phase)" << endl;
        cout << "  expt small: " << pd[i].smallX_corr << ", " << pd[i].humandata[5] << endl;
        cout << "  rule small: " << pd[i].smallR_corr << ", " << pd[i].humandata[6] << endl;
        cout << "  expt large: " << pd[i].largeX_corr << ", " << pd[i].humandata[7] << endl;
        cout << "  rule large: " << pd[i].largeR_corr << ", " << pd[i].humandata[8] << endl;
        cout << "  novel item: " << pd[i].novel_corr << ", " << pd[i].humandata[9] << endl;
        cout << endl;
        /////////////////////////////////////////////////////
        /////////////////////////////////////////////////////
        
        outfile << "(item type: model performance , human performance)" << endl;
        outfile << endl;
        outfile << "  expt small: " << pd[i].smallX_recog << ", " << pd[i].humandata[0] << endl;
        outfile << "  rule small: " << pd[i].smallR_recog << ", " << pd[i].humandata[1] << endl;
        outfile << "  expt large: " << pd[i].largeX_recog << ", " << pd[i].humandata[2] << endl;
        outfile << "  rule large: " << pd[i].largeR_recog << ", " << pd[i].humandata[3] << endl;
        outfile << "  novel item: " << pd[i].novel_recog << ", " << pd[i].humandata[4] << endl;
        outfile << endl;
        outfile << "  expt small: " << pd[i].smallX_corr << ", " << pd[i].humandata[5] << endl;
        outfile << "  rule small: " << pd[i].smallR_corr << ", " << pd[i].humandata[6] << endl;
        outfile << "  expt large: " << pd[i].largeX_corr << ", " << pd[i].humandata[7] << endl;
        outfile << "  rule large: " << pd[i].largeR_corr << ", " << pd[i].humandata[8] << endl;
        outfile << "  novel item: " << pd[i].novel_corr << ", " << pd[i].humandata[9] << endl;
        outfile << endl;
        
    }
    // if sl1 (always-wrong) or sl2 (alwayas-right) or sl4 (unsperviesed learning with recogntion ratings)
    else if (pd[i].problem_type == 12 || pd[i].problem_type == 13) // if sl1 (always-wrong) or sl2 (alwayas-right)
    {
        recogModel[0] = pd[i].special_recog;
        recogModel[1] = pd[i].reg_recog;
        recogModel[2] = pd[i].novel_recog;

        for(int j = 0; j < 3; j++)
        {
            recogHuman[j] = pd[i].humandata[j];
            sumHuman += recogHuman[j];
            sumModel += recogModel[j];
        }

        meanHuman = sumHuman / 3;
        meanModel = sumModel / 3;

        double diff = meanHuman - meanModel;

        for(int k = 0; k < 3; k++)
        {
            recogModel[k] += diff;
        }
        
        /////////////////////////////////////////////////////
        // debugging remove me
        /////////////////////////////////////////////////////
        cout << "recognition (test phase)" << endl;
        cout << "  specials: " << recogModel[0] << ", " << recogHuman[0] << endl;
        cout << "  regulars: " << recogModel[1] << ", " << recogHuman[1] << endl;
        cout << "  novels: " << recogModel[2] << ", " << recogHuman[2] << endl;
        cout << endl;
        /////////////////////////////////////////////////////
        /////////////////////////////////////////////////////
        
        outfile << "(item type: model performance , human performance)" << endl;
        outfile << endl;
        outfile << "  specials: " << recogModel[0] << ", " << recogHuman[0] << endl;
        outfile << "  regulars: " << recogModel[1] << ", " << recogHuman[1] << endl;
        outfile << "  novels: " << recogModel[2] << ", " << recogHuman[2] << endl;
        outfile << endl;
        
    }
    else if (pd[i].problem_type == 14) // if sl4 (unsupervised)
    {
        recogModel[0] = pd[i].special_recog;
        recogModel[1] = pd[i].reg_recog;
        recogModel[2] = pd[i].novel_recog;

        int n = 3;
        
        for (int j = 0; j < n; j++) {
            recogHuman[j] = pd[i].humandata[j];
            sumHuman += recogHuman[j];
            sumModel += recogModel[j];
        }
        
        //ok, do model
        //calculate mean
        meanModel=sumModel/n;
        
        // calculate sd
        for (unsigned int j = 0; j < n; j++) 
            sdModel+=pow(recogModel[j]-meanModel,2);
        if (sdModel>0.000001)   
            sdModel=sqrt(sdModel/(n-1));
        else sdModel=1.0;
        //transform to t
        for (unsigned int j = 0; j < n; j++)
            recogModel[j]=(recogModel[j]-meanModel)/sdModel;
        
        //ok, do human
        //calculate mean
        meanHuman=sumHuman/n;
        
        // calculate sd
        for (unsigned int j = 0; j < n; j++) 
            sdHuman+=pow(recogHuman[j]-meanHuman,2);
        if (sdHuman>0.000001)   
            sdHuman=sqrt(sdHuman/(n-1));
        else sdHuman=1.0;
            
        for (unsigned int j = 0; j < n; j++)
            recogModel[j]=(recogModel[j]*sdHuman)+meanHuman;
        
        /////////////////////////////////////////////////////
        // debugging remove me
        /////////////////////////////////////////////////////
        cout << "recognition (test phase)" << endl;
        cout << "  specials: " << recogModel[0] << ", " << recogHuman[0] << endl;
        cout << "  regulars: " << recogModel[1] << ", " << recogHuman[1] << endl;
        cout << "  novels: " << recogModel[2] << ", " << recogHuman[2] << endl;
        cout << endl;
        /////////////////////////////////////////////////////
        /////////////////////////////////////////////////////
        
        outfile << "(item type: model performance , human performance)" << endl;
        outfile << endl;
        outfile << "  specials: " << recogModel[0] << ", " << recogHuman[0] << endl;
        outfile << "  regulars: " << recogModel[1] << ", " << recogHuman[1] << endl;
        outfile << "  novels: " << recogModel[2] << ", " << recogHuman[2] << endl;
        outfile << endl;

    }
    else if (pd[i].problem_type == 15) // if sl_wrong_right
    {
        
        /////////////////////////////////////////////////////
        // debugging remove me
        /////////////////////////////////////////////////////
        cout << "recognition (test phase)" << endl;
        cout << "  wrong: " << pd[i].special_recog << ", " << pd[i].humandata[0] << endl;
        cout << "  right: " << pd[i].special2_recog << ", " << pd[i].humandata[1] << endl;
        cout << "  regs: " << pd[i].reg_recog << ", " << pd[i].humandata[2] << endl;
        cout << endl;
        /////////////////////////////////////////////////////
        /////////////////////////////////////////////////////
        
        outfile << "(item type: model performance , human performance)" << endl;
        outfile << endl;
        outfile << "  wrong: " << pd[i].special_recog << ", " << pd[i].humandata[0] << endl;
        outfile << "  right: " << pd[i].special2_recog << ", " << pd[i].humandata[1] << endl;
        outfile << "  regs: " << pd[i].reg_recog << ", " << pd[i].humandata[2] << endl;
        outfile << endl;
        
    }
    
    outfile.close();

}

/*++++++++++++++++++++++++++++++++++++++++++++++
    SetUpDataWatchers ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::SetUpDataWatchers () {

    sustaindata[cp].avg_clusters = 0.0;

    for(int i = 0; i < CLUSTER_FREQ_SIZE; i++) {
	sustaindata[cp].cluster_freq[i] = 0;
    }

    
    COGCategoryLearningModel::SetUpDataWatchers ();
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    FixUpDataWatchers ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::FixUpDataWatchers () {

    sustaindata[cp].avg_clusters /= (double)pd[cp].number_of_times;

    COGCategoryLearningModel::FixUpDataWatchers ();
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    ItemRelationshipMatrix (vector<double> &modeldata)

    this fucntion computes the lower diagonal of
    relationships between items (ie, which items
    are in the same cluster.  for example, if
    there were four items {a,b,c,d} a matrix
    like this could be constructed:
    
      a b c d
    a 1 1 0 1
    b 1 1 0 0
    c 0 0 1 1
    d 1 0 1 1
    
    where a 1 means that item {i,j} is in the same
    cluster and a 0 means the item {i,j} are in
    different cluster.  notice diagonal of ones.
    
    the vector constructed in modeldata is the lower
    diagonal of this matrix (not including the main
    diagonal)
    ie, {1,0,1,0,0,1}
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::ItemRelationshipMatrix(vector<double> &modeldata)
{

    int nitems = (pd[cp].filepair[0].GetNItems());
    
    
    vector<int> which_cluster(nitems, 0);
    
    // for each item find cluster
    for (int i = 0; i < nitems; i++) {
	which_cluster[i] = network->DetermineCluster(pd[cp].filepair[0].items[i]);
    }
        
    modeldata.reserve(nitems);
    
    // 	for each item store cluster
    // start at 1 to avoid the diagonal of the matrix
    for (int i = 0; i < nitems; i++) {
	int my_cluster = which_cluster[i];
	for (int j = i+1; j < nitems; j++) {
	    // 	for each item compare stored cluster to one in memory
	    //	if equal set matrix i,j = 1
	    if(my_cluster == which_cluster[j]) {
		modeldata.push_back(1.0);
	    }
	    else {
		modeldata.push_back(0.0);
	    }
	}
    }

}

/*++++++++++++++++++++++++++++++++++++++++++++++
    TypeOfSort ()

    this fucntion figures out how the items
    are sorted into cluster:
	uneven, 1d, or family resemblance

++++++++++++++++++++++++++++++++++++++++++++++++*/
int
SUSTAINModel::TypeOfSort()
{

    // allocate and clear space
    int nitems = (pd[cp].filepair[0].GetNItems());
    int itemclusters[network->GetNClusters()][nitems];
    for (int i = 0; i < network->GetNClusters(); i++) {
	for (int j = 0; j < nitems; j++) { itemclusters[i][j] = 0;}
    }
    
    // for each item find cluster
    for (int i = 0; i < nitems; i++) {
	int tmp = network->DetermineCluster(pd[cp].filepair[0].items[i]);
	itemclusters[tmp][i] = 1;
    }

    //debugging
    /*
    for (int i = 0; i < network->GetNClusters(); i++) {
	for (int j = 0; j < nitems; j++) {
	    cout << itemclusters[i][j] << " ";
	}
	cout << endl;
    }
    */
    
    
    // UNEVEN
    // check if the clustering is uneven
    vector<int> nclustersperitem;
    for (int i = 0; i < network->GetNClusters(); i++) {
	int sum = 0;
	for (int j = 0; j < nitems; j++) {
	    sum += itemclusters[i][j];
	}
	nclustersperitem.push_back(sum);
    }
    
    if((network->GetNClusters() > 2) || (nclustersperitem[0] != nclustersperitem[1])) {
	return UNEVEN_SORT;
    }
    
    
    // ONED
    // check if the cluster is 1d

    // for each dimension of the items
    for (int i = 0; i < pd[cp].filepair[0].items[0].size(); i++) {
	
	// if the dimension is known to the model
	if(pd[cp].filepair[0].items[0][i].status == 'k') {
	    
	    vector<double> values;
	    
	    // for each item
	    for (int j = 0; j < nitems; j++) {
		// if item is in cluster 1
		if(itemclusters[1][j]) {
		    values.push_back(pd[cp].filepair[0].items[j][i].value);
		}
	    } 
	
	
	    // if all the values on this dimension are equal
	    bool allequal = true;
	    for(int k = 1; k < values.size(); k++) {
		if(values[k] != values[0]) {
		    allequal = false;
		}
	    }
	
	    if(allequal == true) {
		return ONED_SORT;
	    }
	}
    }
    
    // ok it's not any of these two...
    //CHECK FAMILY RESEMBLANCE
    //check if the items are partitioned in a family resemblance structure
    bool fr = true;
    for (int i = 1; i < 5; i++) {
	if(itemclusters[0][0] != itemclusters[0][i]) {
	    fr = false;
	}
    }
    
    if(fr) {
	return FR_SORT;
    }
    
    
    // DEBUG
    /*
    for (int i = 0; i < nitems; i++) {
        // if item is in cluster 1
	if(itemclusters[1][i]) {
	    for (int j = 0; j < pd[cp].filepair[0].items[i].size(); j++) {
		if(pd[cp].filepair[0].items[i][j].status == 'k') {
		    cout << pd[cp].filepair[0].items[i][j].value << " ";
		}
	    }
	    cout << endl;
	}
    }
    
    for (int i = 0; i < nclustersperitem.size(); i++) {
	cout << nclustersperitem[i] << " ";
    }
    cout << endl;
    */
    
    return UNKNOWN_SORT;
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    GetNClusters ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
int 
SUSTAINModel::GetNClusters() 
{
    return network->GetNClusters();
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    GetModeClusters ()

++++++++++++++++++++++++++++++++++++++++++++++++*/
int
SUSTAINModel::GetModeClusters(int i)
{
    int max = 0;
    int max_index = 0;
    for(unsigned int j = 1; j < CLUSTER_FREQ_SIZE; j++) {
	if(sustaindata[i].cluster_freq[j] > max) {
	    max = sustaindata[i].cluster_freq[j];
	    max_index = j;
	}
    }
    
    return max_index;
}