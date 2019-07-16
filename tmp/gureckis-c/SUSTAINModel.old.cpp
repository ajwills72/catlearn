/*
    SUSTAINModel.cpp
    cogc++
    Created by Todd Gureckis (gureckis@love.psy.utexas.edu) on Sat Feb 25 2002.
 
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
    SetPGA (COGPga *pga)

    if you are going to use pga to get the parameters
    this setup function must be called so that
    the sustain model is aware of the location
    of the pga object and can ask it for the
    correct variables
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::SetPGA (COGPga *pga) {
    pga_obj = pga;
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    Setup (const char *filename)

    before making a call to Simulate() this function
    must be called.  Setup reads in all the data
    from disk at the start so that there are no
    disk accesses during the tight loops inside
    the model
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::Setup (const char *filename)
{
    runscript.Load (filename, '%');
    
    n_problems = runscript.GetAsInt("n_problems");
    
    for (int i = 0; i < n_problems; i++) {
	ReadInProblem(i);
    }
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    ReadInProblem (int i)

    for each problem defined in the setup file
    this function will read in the relevent
    settings and the input files
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::ReadInProblem (int i)
{
	ostrstream int_converter;
	
	// set up problem name
	int_converter << i << ends; // puts null character on the end
	pd[i].problemname = string("problem") + string(int_converter.str()) + string("_");
	
	GetProblemSettings(i);
	ReadInputFiles(i);
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    ReadInputFile (int i)

    for each problem defined in the setup file
    this function will read in the input files
    this includes datafile, environment files,
    human data (for fitting), and any other
    data files that are associated with the problem
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::ReadInputFiles (int i) 
{
    string variablename;
    
    for(int j = 0; j < pd[i].n_input_pairs; j++) {
	
	ostrstream int_c;
	int_c << j << ends;
	
	variablename = pd[i].problemname + "datafile" + string(int_c.str());
	string datafile(runscript.GetAsCharStar(variablename.c_str()));
	
	variablename  = pd[i].problemname + "envfile" + string(int_c.str());
	string envfile(runscript.GetAsCharStar(variablename.c_str()));

	pd[i].filepair[j].Load(datafile.c_str(), envfile.c_str());

    }
    
    // read in human data
    variablename = pd[i].problemname + "human_data";
    if (runscript.IsSet(variablename.c_str())) {
	ReadFileIntoVector(runscript.GetAsCharStar(variablename.c_str()), pd[i].humandata);
    }
    
    //read in relationship matricies
    for (int j = 0; j < pd[i].n_relationship_matrix; j++) {
	ostrstream int_c;
	int_c << j << ends;
	
	variablename = pd[i].problemname + "relationship_matrix" + string(int_c.str());
    
	if (runscript.IsSet(variablename.c_str())) {
	    ReadFileIntoVector(runscript.GetAsCharStar(variablename.c_str()), pd[i].relationship_matrix[j]);
	}
    }

}

/*++++++++++++++++++++++++++++++++++++++++++++++
    ReadFileIntoVector (const char *fn, vector<double> &vec)

    given a filename this function will read the
    file into a vector.  it assumes that the file
    contains a list of double precision numbers
    one-per-line.  This function should be moved
    into a general purpose vector class inside
    the COGC++ library
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::ReadFileIntoVector(const char *fn, vector<double> &vec) {

    ifstream data(fn);
    
    if(!data) {
	//ERROR
	cout << "ERROR opening " << fn << endl;
	exit(0);
    }

    // read in data from file
    typedef istream_iterator<double,ptrdiff_t> istream_iterator_double;
    istream_iterator_double start (data);
    istream_iterator_double end;
    back_insert_iterator<vector<double> > dest (vec);
 
    copy (start, end, dest);
    
    data.close();
    
    return;
    
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    GetProblemSettings (int i)

    this function will read in the problem
    settings for problem i.  this is all the
    setting that are defined in the simulation
    description file
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::GetProblemSettings (int i) 
{
    	
    string variablename;
    
    // get problem variables

    // MANDATORY option sustain_config 
    variablename = pd[i].problemname + "sustain_config";
    pd[i].sustainconfig = runscript.GetAsCharStar(variablename.c_str());
    pd[i].config.Load(pd[i].sustainconfig.c_str(), '%');
    
    // MANDATORY option parameter_file
    variablename = pd[i].problemname + "parameter_file";
    pd[i].parameterfile = runscript.GetAsCharStar(variablename.c_str());
    pd[i].param.Load(pd[i].parameterfile.c_str(), '%', pga_obj);
    
    // MANDATORY option ninputpairs
    variablename = pd[i].problemname + "ninputpairs";
    pd[i].n_input_pairs = runscript.GetAsInt(variablename.c_str());
    
    // MANDATORY option number_of_times
    variablename = pd[i].problemname + "number_of_times";
    pd[i].number_of_times = runscript.GetAsInt(variablename.c_str());

    // MANDATORY but MESSED UP option delete_network_at_end
    variablename = pd[i].problemname + "delete_network_at_end";
    pd[i].delete_network_at_end = runscript.GetAsBool(variablename.c_str());
	
    // MANDATORY option number_of_epochs
    variablename = pd[i].problemname + "number_of_epochs";
    pd[i].number_of_epochs = runscript.GetAsInt(variablename.c_str());
    
    // CURRENTLY MANDATORY but should be optional criterion
    variablename = pd[i].problemname + "criterion";
    pd[i].criterion = runscript.GetAsInt(variablename.c_str());
    
    // CURRENTLY MANDATORY BUT SHOULD BE optional percent_correct
    variablename = pd[i].problemname + "percent_correct";
    pd[i].percent_correct = runscript.GetAsDouble(variablename.c_str());
    
    // OPTIONAL parameter stop_no_new_clusters (defaults to FALSE)
    variablename = pd[i].problemname + "stop_no_new_clusters";
    if(runscript.IsSet(variablename.c_str())) {
	pd[i].stop_no_new_clusters = runscript.GetAsBool(variablename.c_str());
    }
    else {
	pd[i].stop_no_new_clusters = FALSE;
    }
    
    // CURRENTLY MANDATORY but should be optional fit_learning_curve
    variablename = pd[i].problemname + "fit_learning_curve";
    pd[i].fit_learning_curve = runscript.GetAsBool(variablename.c_str());
    
    // CURRENTLY MANDATORY but should be optional fit_blocks_to_criterion
    variablename = pd[i].problemname + "fit_blocks_to_criterion";
    pd[i].fit_blocks_to_criterion = runscript.GetAsBool(variablename.c_str());
    
    // CURRENTLY MANDATORY but should be optional fit_overall_accuracy
    variablename = pd[i].problemname + "fit_overall_accuracy";
    pd[i].fit_overall_accuracy = runscript.GetAsBool(variablename.c_str());
    
    // CURRENTLY MANDATORY but should be optional fit_reached_criterion
    variablename = pd[i].problemname + "fit_reached_criterion";
    pd[i].fit_reached_criterion = runscript.GetAsBool(variablename.c_str());
    
    // OPTIONAL fit_item_relationship_matrix
    variablename = pd[i].problemname + "fit_item_relationship_matrix";
    if(runscript.IsSet(variablename.c_str())) {

	pd[i].fit_item_relationship_matrix = runscript.GetAsBool(variablename.c_str());
	if(pd[i].fit_item_relationship_matrix) {
	    variablename = pd[i].problemname + "n_relationship_matrix";
	    pd[i].n_relationship_matrix = runscript.GetAsInt(variablename.c_str());
	}

    }
    
    // MANDATORY BUT SHOULD BE REMOVED sim_name
    // CODE SLOW HERE FIX when you have the chance
    pd[i].cg2_ymlin_inf_class = FALSE;
    pd[i].shepard_six = FALSE;
    pd[i].fish = FALSE;
    pd[i].first_last = FALSE;
    
    variablename = pd[i].problemname + "sim_name";
    string simname = runscript.GetAsCharStar(variablename.c_str());
    if( strcmp(simname.c_str(), "cg2ymlin") == 0) {
	pd[i].cg2_ymlin_inf_class = TRUE;
    }
    else if( strcmp(simname.c_str(), "shepard_six") == 0 ) {
	pd[i].shepard_six = TRUE;
    }
    else if( strcmp(simname.c_str(), "fish") == 0 ) {
	pd[i].fish = TRUE;
    }
    else if( strcmp(simname.c_str(), "first_last") == 0 ) {
	pd[i].first_last = TRUE;
    }
    
    // OPTION animation_snapshot
    variablename = pd[i].problemname + "animation_snapshot";
    if(runscript.IsSet(variablename.c_str())) {
	pd[i].animation_snapshot = TRUE;
	pd[i].animation_path = runscript.GetAsCharStar(variablename.c_str());
    }
    else {
	pd[i].animation_snapshot = FALSE;
    }

    // OPTIONAL randomize_files_per_item
    variablename = pd[i].problemname + "randomize_files_per_item";
    if(runscript.IsSet(variablename.c_str())) {
	pd[i].randomize_files_per_item =  runscript.GetAsBool(variablename.c_str());
    }
    else {
	pd[i].randomize_files_per_item = FALSE;
    }
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    PrintProblems ()

    a debugging function that is not updated 
    currently.  for each problem prints out
    the problem data struct so you can see
    which setting have been set and if they 
    are correct
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::PrintProblems() 
{
    // this function needs to be updated
    for (int i = 0; i < n_problems; i++) {
	cout << "Printing problem " << i << endl;
	
	cout << "n_input_pairs = " << pd[i].n_input_pairs << endl;
	cout << "number_of_times = " << pd[i].number_of_times << endl;
	cout << "delete_network_at_end = " << pd[i].delete_network_at_end << endl;
	cout << "number_of_epochs = " << pd[i].number_of_epochs << endl;
	cout << "criterion = " << pd[i].number_of_epochs << endl;
	cout << "percent_correct = " << pd[i].percent_correct << endl;
	cout << "n_items_correct = " << pd[i].n_items_correct << endl;
	cout << "n_blocks_correct = " << pd[i].n_blocks_correct << endl;
	cout << "quickfinish = " << pd[i].quickfinish << endl;
	cout << "n_blocks_to_criterion = " << pd[i].n_blocks_to_criterion << endl;
	cout << "times_reached_criterion = " << pd[i].times_reached_criterion << endl;
	cout << "fit_learning_curve = " << pd[i].fit_learning_curve << endl;
	cout << "fit_blocks_to_criterion = " << pd[i].fit_blocks_to_criterion << endl;
	cout << "fit_overall_accuracy = " << pd[i].fit_overall_accuracy << endl;
	cout << "fit_reached_criterion = " << pd[i].fit_reached_criterion << endl;
	
	cout << "human data " << endl;
	//pd[i].humandata->Print();
	cout << "filepairs " << endl;
	for (int j = 0; j < pd[i].n_input_pairs; j++) {
	    pd[i].filepair[j].Print();
	}
    }
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    CleanUp ()

    This function will empty the allocated
    STL vectors.  i don't think that this
    function is necessary
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::CleanUp() {

    for (int i = 0; i < n_problems; i++) {
	pd[i].humandata.clear();
	pd[i].cluster_freq.clear();
	for(int j = 0; j < pd[i].n_relationship_matrix; j++) {
	    pd[i].relationship_matrix[j].clear();
	}
	pd[i].last_items_correct.clear();
	pd[i].learning_curve.clear();
    }
    
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    Simulate ()

    where everything begins for a simulation.
    this is the toplevel simulation routine
    for each defined problem and for n_times
    it will iterate.  it also allocates the
    network.  soon should support cascading
    models.
    
    this should be called by pga in the evaluation
    function.  it returns the "fitness of the
    simulation if humandata is provided otherwise
    it returns a nominal value.
++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::Simulate () 
{
    int allocate = TRUE;
    
    for (int i = 0; i < n_problems; i++) {
     
	cp = i;
	
	SetUpDataWatchers();
	
	for (int j = 0; j < pd[cp].number_of_times; j++) {
	
	    if(allocate == TRUE) {
		network = new SUSTAINNetwork(pd[cp].config, pd[cp].param, pd[cp].filepair[0]);
	    }
	    
	    pd[cp].runid = j;
	    
	    RunModelGeneral();
	    
	    RunAnalysis(j);

	    if(pd[cp].delete_network_at_end == TRUE) {
		delete network;
		allocate = TRUE;
	    }
	    else {
		allocate = FALSE;
	    }
	    
	}
	
	FixUpDataWatchers();
	
    }
    
    return EvaluateFit();
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    RunAnalysis ()

    Analyzes a single simulation run and updates
    data structures that are computing means, modes,
    variances, etc... for fitting
    
    all of this information should be recoverable
    from the run_analysis/ directory data
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::RunAnalysis(int runid) 
{

    // get average number of clusters
    pd[cp].avg_clusters += network->GetNClusters();
    pd[cp].cluster_freq[network->GetNClusters()] += 1;
    pd[cp].avg_blocks_to_criterion += pd[cp].n_blocks_to_criterion;
    
    vector<double> modeldata;
    if (pd[cp].fit_item_relationship_matrix) {
	ItemRelationshipMatrix(modeldata);
	for(int i = 0; i < pd[cp].n_relationship_matrix; i++) {
	    // compare to each file using vector cosine
	    pd[cp].item_matrix_vc[i] += vectorCos(modeldata, pd[cp].relationship_matrix[i]);
	    // dot product
	    pd[cp].item_matrix_dotprod[i] += dotProd(modeldata, pd[cp].relationship_matrix[i]);
	}
    }
    
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    vectorCos (vector<double> &v1, vector<double &v2)

    computes the vector cosine between two STL vectors
    this should be moved to a general purpose
    vector class in COGC++
++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::vectorCos(vector<double> &v1, vector<double> &v2)
{

    double dot = dotProd(v1, v2);
    
    double sum1 = 0.0;
    double sum2 = 0.0;
    for (unsigned int i = 0; i < v1.size(); i++) {
	sum1 += pow(v1[i], 2);
	sum2 += pow(v2[i], 2);
    }

    return dot/(sqrt(sum1)*sqrt(sum2));
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    dotProd (vector<double> &v1, vector<double &v2)

    computes the dot product between to STL vectors
    should be moved to a general purpose vector class
    in COGC++ library
++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::dotProd(vector<double> &v1, vector<double> &v2) {
    

    
    if(v1.size() != v2.size()) {
	cout << "Two vectors used in dot product are not of equal length!";
	cout << v1.size() << " " << v2.size() << endl;
	exit(0);
    }

    double sum = 0.0;
    for (unsigned int i = 0; i < v1.size(); i++) {
	sum += v1[i] * v2[i];
    }
    
    return sum;
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
    int nitems = (pd[cp].filepair[0].GetNItems()/2);
    
    
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
    FixUpDataWatchers ()

    
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::FixUpDataWatchers ()
{
    // fix up data watchers
    for (int i = 0; i < pd[cp].number_of_epochs; i++) {
	pd[cp].learning_curve[i] = pd[cp].learning_curve[i]/(pd[cp].number_of_times*pd[cp].filepair[0].GetNItems ());
    }
    
    // OPTIONAL average_back_lc
    // if isset average back lc to 16
    string variablename = pd[cp].problemname + "average_back_lc";
    if(runscript.IsSet(variablename.c_str())) {
	if(runscript.GetAsBool(variablename.c_str())) {
	    vector<double> avgback;
	    for (int i = 0; i < pd[cp].number_of_epochs; i+=2) {
		double avg = (pd[cp].learning_curve[i] + pd[cp].learning_curve[i+1])/2.0;
		avgback.push_back(avg);
	    }
	    pd[cp].learning_curve = avgback;
	}
    }
    
    pd[cp].avg_clusters /= (double)pd[cp].number_of_times;
    pd[cp].avg_blocks_to_criterion /= (double)pd[cp].number_of_times;
    pd[cp].percent_times_reached_criterion = (double)pd[cp].times_reached_criterion/(double)pd[cp].number_of_times;
    pd[cp].overall_accuracy /= ((double)pd[cp].number_of_times*
				(double)pd[cp].number_of_epochs*
				(double)pd[cp].filepair[0].GetNItems());
    
    if (pd[cp].fit_item_relationship_matrix) {
	for(int j = 0; j < pd[cp].n_relationship_matrix; j++) {
	    pd[cp].item_matrix_vc[j] /= pd[cp].number_of_times;
	    pd[cp].item_matrix_dotprod[j] /= pd[cp].number_of_times;
	}
    }
    
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    EvaluateFit ()

    
++++++++++++++++++++++++++++++++++++++++++++++++*/
double
SUSTAINModel::EvaluateFit ()
{

    string 	    variablename;
    vector<double>  modeldata;
    vector<double>  humandata;
    int human = TRUE;

    //  for each problem, collect data to be fit and make a list of it
    //  also make a list of human data provided for each problem
    //  check the the number matches
    for (int i = 0; i < n_problems; i++) {
    
	// fit data based on what was set in the parameters
	if (pd[i].fit_learning_curve) {
	    // push learning curve onto end of model data
	    for(unsigned int j = 0; j < pd[i].learning_curve.size(); j++) {
		modeldata.push_back(pd[i].learning_curve[j]);
	    }
	}
	
	if (pd[i].fit_blocks_to_criterion) {
	   modeldata.push_back(pd[i].avg_blocks_to_criterion);
	}
	
	if (pd[i].fit_reached_criterion) {
	    modeldata.push_back(pd[i].percent_times_reached_criterion);
	}
	
	if (pd[i].fit_overall_accuracy) {
	    modeldata.push_back(pd[i].overall_accuracy);
	}
	
	if (pd[i].fit_item_relationship_matrix) {
	    for(int j = 0; j < pd[i].n_relationship_matrix; j++) {
		modeldata.push_back(pd[i].item_matrix_vc[j]);
		modeldata.push_back(pd[i].item_matrix_dotprod[j]);
	    }
	}
	
	// OPTIONAL output_fit
	// if isset output_fit
	variablename = pd[i].problemname + "output_fit";
	if(runscript.IsSet(variablename.c_str())) {
	    OutputFit(i);
	}
	
	// OPTIONAL human_data
	// push human data onto end of humandata vector
	// read in human data
	variablename = pd[i].problemname + "human_data";
	if (runscript.IsSet(variablename.c_str())) {
	    for(unsigned int j = 0; j < pd[i].humandata.size(); j++) {
		humandata.push_back(pd[i].humandata[j]);
	    }
	}
	else {
	    human = FALSE;
	}

    }
    
    if(!human) {
	cout << "not enough/any human data provided!" << endl;
	return -999;
    }
    
    if (modeldata.size() != humandata.size()) {
    
	// USE COG ERROR HERE
	cout << "Error... model and human data not equal in size" << endl;
	cout << "model = " << modeldata.size() << " human = " << humandata.size() << endl;
	
	for(unsigned int j = 0; j < modeldata.size() ; j++) {
	    cout << modeldata[j] << endl;
	}
	
	for(unsigned int j = 0; j < humandata.size() ; j++) {
	    cout << humandata[j] << endl;
	}
		
	exit(0);
    }
    
    // calculate mean squared error between the two
    double sum = 0.0;
    for (unsigned int i = 0; i < modeldata.size(); i++) {
	sum += pow(modeldata[i] - humandata[i], 2);
    }

    if (modeldata.size() > 1) {
	return sqrt(sum/(modeldata.size()-1));
    }
    else {
	return sqrt(sum);
    }
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    OutputFit ()

    
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::OutputFit (int i)
{

    string variablename;
    
    // for each problem, open output files
    // write fit data out and human data
    variablename = pd[i].problemname + "output_fit";
    
    // open output file
    ofstream outfile(runscript.GetAsCharStar(variablename.c_str()));

    if(!outfile) {
    // ADD ERROR CHECKING HERE
	cout << "Error opening " << runscript.GetAsCharStar(variablename.c_str()) << " for output fit" << endl;
	exit(0);
    }
    
    // fit data based on what was set in the parameters
    if (pd[i].fit_learning_curve) {
	// write model data
	for(unsigned int j = 0; j < pd[i].learning_curve.size(); j++) {
	    outfile << pd[i].learning_curve[j] << endl;
	}
    }
    
    if (pd[i].fit_blocks_to_criterion) {
	outfile << pd[i].avg_blocks_to_criterion << endl;
    }
    
    if (pd[i].fit_overall_accuracy) {
	outfile << pd[i].overall_accuracy << endl;
    }
    
    if (pd[i].fit_reached_criterion) {
	outfile << pd[i].percent_times_reached_criterion << endl;;
    }
    
    if (pd[i].fit_item_relationship_matrix) {
	for(int j = 0; j < pd[i].n_relationship_matrix; j++) {
	    outfile << pd[i].item_matrix_vc[j] << endl;
	    outfile << pd[i].item_matrix_dotprod[j] << endl;
	}
    }
	
    // close output file
    outfile.close();
	
    // OPTIONAL extra_analysis
    // if isset cluster analysis
    variablename = pd[i].problemname + "extra_analysis";
    if(runscript.IsSet(variablename.c_str())) {
	OutputExtraAnalysis(runscript.GetAsCharStar(variablename.c_str()), i);
    }

    return;
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    OutputExtraAnalysis ()

    
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::OutputExtraAnalysis(const char *fn, int i) {

    ofstream outfile(fn);
    
    if(!outfile) {
	// ADD ERROR CHECKING HERE
	cout << "error opening " << fn << " for output cluster analysis" << endl;
	exit(0);
    }
	
    outfile << "condition = " << i << endl;
    outfile << "meanclusters = " << pd[i].avg_clusters << endl;
    
    int max = 0;
    int max_index = 0;
    for(unsigned int j = 1; j < pd[i].cluster_freq.size(); j++) {
	if(pd[i].cluster_freq[j] > max) {
	    max = pd[i].cluster_freq[j];
	    max_index = j;
	}
    }
    outfile << "modeclusters = " << max_index << endl;
    
    outfile << "clusterfrequencies = { ";
    for(unsigned int j = 1; j < pd[i].cluster_freq.size(); j++) {
	outfile << pd[i].cluster_freq[j];
	if(j != pd[i].cluster_freq.size()-1) {
	    outfile << ", ";
	}
    }
    outfile << " }" << endl;
    
    
    outfile << "avgblockstocriterion = " << pd[i].avg_blocks_to_criterion << endl;
    
    outfile.close();
    
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    SetUpDataWatchers ()

    
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::SetUpDataWatchers() {


    pd[cp].cluster_freq.clear();
    pd[cp].learning_curve.clear();
    
    for (int j = 0; j < pd[cp].number_of_epochs; j++) {
	pd[cp].learning_curve.push_back(0.0);
    }

    pd[cp].avg_clusters = 0.0;
    pd[cp].avg_blocks_to_criterion = 0.0;
    pd[cp].times_reached_criterion = 0;
    pd[cp].percent_times_reached_criterion = 0.0;
    pd[cp].overall_accuracy = 0.0;
    
    for(int i = 0; i < 50; i++) {
	pd[cp].cluster_freq.push_back(0);
    }
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    RunModelGeneral ()

    
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::RunModelGeneral ()
{    

    // create set of random data/env training files to run
    // this was developed for use by ymlin/cg2 problems
    // if the number of training sets is just 1 then the code
    // essentially does nothing
    vector<int> files(pd[cp].n_input_pairs, 0);
    
    if(pd[cp].n_input_pairs > 1) {
	for (int i = 0; i < pd[cp].n_input_pairs; i++) {
	    files[i] = i;
	}
	RandomShuffleArray(files);
    }
    
    pd[cp].quickfinish = FALSE;
    pd[cp].n_blocks_correct = 0;
    pd[cp].n_blocks_to_criterion = 0;
    pd[cp].last_n_clusters = 0;
    pd[cp].delta_clusters = -1;
    pd[cp].frameid = 0; 		// for outputting animations
    
    // create a random epoch; this assumes that all input files have the same number of items
    vector<int>	epoch(pd[cp].filepair[0].GetNItems ());
	
    for (int j = 0; j < pd[cp].filepair[0].GetNItems (); j++) {
	epoch[j] = j;
    }


    if(pd[cp].cg2_ymlin_inf_class) {
	pd[cp].last_items_correct.clear();
	for(int i = 0; i < 3; i++) {
	    pd[cp].last_items_correct.push_back(0);
	}
    }
    
    // number of epochs	
    for (int i = 0; i < pd[cp].number_of_epochs; i++) { 
    	
	// n_input_pairs is > 1, this will start to loop through them each epoch
	int select_file_pair = i % pd[cp].n_input_pairs;
	
	RandomShuffleArray(epoch);
	
	pd[cp].n_items_correct = 0;
	
	// if inference if checkstopcriterion == true return
	if (pd[cp].cg2_ymlin_inf_class || pd[cp].stop_no_new_clusters) {  
	    if (CheckStopCriterion (i)) {
		return; 
	    }
	}
	else { 
	    CheckStopCriterion(i); 
	}
	
	RunModelOnItems (epoch, i, files[select_file_pair]);
	
	//cout << "epoch " << i << " " << pd[cp].n_items_correct << endl;
    
	UpdateStopCriterion (i);
	
	if (pd[cp].n_input_pairs > 1) {
	    if (select_file_pair == pd[cp].n_input_pairs-1 ) {
		RandomShuffleArray(files);
	    }
	}
    }


    if (pd[cp].cg2_ymlin_inf_class) {
	
	//unsigned int end = pd[cp].last_items_correct.size() - 1;
	double sum = 0;
	for(int i = 0; i < 3; i++) {
	    sum += pd[cp].last_items_correct[i];
	}
	
	// if three blocks in a row with total acc > percent corrent
	double pc_for_last_three = sum/( (double)pd[cp].filepair[0].GetNItems()*3.0);
	if ( pc_for_last_three >= pd[cp].percent_correct ) {
	    pd[cp].times_reached_criterion++;    
	}
    }
    else if (pd[cp].shepard_six || pd[cp].first_last) {
	if ( (pd[cp].n_blocks_correct >= pd[cp].criterion) && !pd[cp].quickfinish) {
	    pd[cp].times_reached_criterion++;
	}
    }

    
    if ( !pd[cp].quickfinish ) {
	//cout << "went to the end" << endl;
	pd[cp].n_blocks_to_criterion = pd[cp].number_of_epochs;
    }
    
    // if unsupervised then run the correct/incorrect part
    //            -unsupervised.. normal at first then
    //                       correct/incorrect part w/ decision function
    //                       (track accuracy per correlation
    // use param->correct_file_index and param->incorrect_file_index to
    // decide which is the right file


    // if a sorting study needs to print out the sort somehow
    //            -sorting studies:  run model like normal then
    //                       use print network status to determine sort
    //                       type
    
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    RandomShuffleArray ()

    should be moved to COGC++
++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::RandomShuffleArray(vector<int> &array) {
  
    int newplace = 0;
    int temp;
    
    for (unsigned int i = 0; i < array.size(); i++) {
	newplace = grint(i, array.size()-1);
	temp = array[newplace];
	array[newplace] = array[i];
	array[i] = temp;
    }
    
    return;
}

/*++++++++++++++++++++++++++++++++++++++++++++++
    CheckStopCriterion (int i)

++++++++++++++++++++++++++++++++++++++++++++++++*/
int
SUSTAINModel::CheckStopCriterion(int i)
{

    if (pd[cp].cg2_ymlin_inf_class) {
    
	//unsigned int end = pd[cp].last_items_correct.size() - 1;
	double sum = 0;
	for(int j = 0; j < 3; j++) {
	    sum += pd[cp].last_items_correct[j];
	}
	
	// if three blocks in a row with total acc > percent corrent
	double pc_for_last_three = sum/( (double)pd[cp].filepair[0].GetNItems()*3.0);
	if ( pc_for_last_three >= pd[cp].percent_correct ) {
	    pd[cp].n_blocks_to_criterion = i;
	    pd[cp].times_reached_criterion++;
	    return TRUE;
	}
	else {
	    return FALSE;
	}
	
    }
    else if (pd[cp].shepard_six || pd[cp].first_last) {
    
	if (pd[cp].quickfinish) {
	    return TRUE;
	}
	else if (pd[cp].n_blocks_correct >= pd[cp].criterion) {
	    pd[cp].quickfinish = TRUE;
	    pd[cp].n_blocks_to_criterion = i;
	    pd[cp].times_reached_criterion++;
	    return TRUE;
	}
	else {
	    return FALSE;
	}
	
    }
    else if (pd[cp].stop_no_new_clusters) {
	//cout << pd[cp].delta_clusters << endl;
	if( pd[cp].delta_clusters == 0 ) {
	    pd[cp].n_blocks_to_criterion = i;
	    pd[cp].times_reached_criterion++;
	    return TRUE;
	}
    }
    
    return FALSE;

}

/*++++++++++++++++++++++++++++++++++++++++++++++
    UpdateStopCriterion (int i)

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::UpdateStopCriterion(int i)
{

    //pd[cp].last_items_correct.push_back(pd[cp].n_items_correct);
    if (pd[cp].cg2_ymlin_inf_class) {
	pd[cp].last_items_correct[i%3] = pd[cp].n_items_correct;
    }
    else if (pd[cp].shepard_six || pd[cp].first_last) {

	// if the percent correct we obtained in this block is equal to or greater than
	// the percent correct we got then
	double percent_correct_this_block = (double)pd[cp].n_items_correct/(double)pd[cp].filepair[0].GetNItems ();
    
	if ( (percent_correct_this_block >= pd[cp].percent_correct) || (pd[cp].quickfinish) ) {
	    pd[cp].n_blocks_correct++;
	}
	else {
	    pd[cp].n_blocks_correct = 0;
	}
    }
    else if (pd[cp].stop_no_new_clusters) {
	pd[cp].delta_clusters = network->GetNClusters() - pd[cp].last_n_clusters;
	pd[cp].last_n_clusters = network->GetNClusters();
    }

}

/*++++++++++++++++++++++++++++++++++++++++++++++
    RunModelOnItems (int i)

++++++++++++++++++++++++++++++++++++++++++++++++*/
void
SUSTAINModel::RunModelOnItems (vector<int> &order, int current_epoch, int fileindex) 
{    
    for (int i = 0; i < pd[cp].filepair[fileindex].GetNItems (); i++) {
    
	if (!pd[cp].quickfinish) {
	    
	    int answer;
	    
	    if(pd[cp].randomize_files_per_item) {
		answer = network->StimulateNetwork(
		    pd[cp].filepair[grint(0, pd[cp].n_input_pairs-1)].items[order[i]]
		);
	    }
	    else {
		answer = network->StimulateNetwork(pd[cp].filepair[fileindex].items[order[i]]);
	    }
	
	    // do we want block correct in a row or just total acc?
	    if(pd[cp].cg2_ymlin_inf_class) {
		if (answer) { pd[cp].n_items_correct++; }
	    }
	    else {
		if (answer) { pd[cp].n_items_correct++; } 
		else { pd[cp].n_items_correct = 0; }
		
	    }
	    
	    // this is for output a learning curve
	    double prob = network->GetProbability();
	    pd[cp].learning_curve[current_epoch] += (1.0 - prob);
	    
	    // should add prob to overall here
	    pd[cp].overall_accuracy += prob;
	    
	    network->DoLearning ();
	 
	}
	else {
	
	    //if we have already reached criterion number of blocks just assume
	    // we are correct for the remaining blocks
	    pd[cp].learning_curve[current_epoch] += 0.0;
	    
	    // should add 1.0 to overall accuracy here
	    pd[cp].overall_accuracy += 1.0;
	    
	    pd[cp].n_items_correct++;
	}
	    
	if(pd[cp].animation_snapshot) {
	
	    ostrstream	runid_c;
	    ostrstream	frameid_c;
	    
	    runid_c << pd[cp].runid << ends;
	    frameid_c << pd[cp].frameid++ << ends;
	    
	    // create output filename
	    string outputfn = pd[cp].animation_path + "run" + 
				string(runid_c.str()) + "_frame" + string(frameid_c.str());
	
	    // output run analysis
	    network->OutputAnalysis(outputfn.c_str(), pd[cp].filepair[fileindex].items);
	}
    
    }

}
