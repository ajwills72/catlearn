/*
    SUSTAINNetwork.cpp
    cogc++
    Created by Todd Gureckis (gureckis@love.psy.utexas.edu) on Sat Feb 09 2002.
 
    SUSTAIN: A network model of category learning
    Model developed by Bradley C. Love (love@psy.utexas.edu)
    code Copyright (C) 2002  Todd M. Gureckis (gureckis@love.psy.utexas.edu)

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


#include "SUSTAINNetwork.h"


/*+SUSTAINNetwork+++++++++++++++++++++++++++++++

    SUSTAINNetwork (COGParser &configarg, 
		    COGParam &params, 
		    COGCategoryLearningInputFiles &mydata)

    Network constructor.  Allocates space for the
    layers of the network (input units, clusters, 
    category units).
    
    Arguements are the configuration options for
    the model, the parameters for the model,
    and a pointer to a category learning input
    files object.  This is information is also
    used in the initialization of the network
    (number of output/input units, parameters,
    etc...).

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
SUSTAINNetwork::SUSTAINNetwork (COGParser &configarg, COGParam &params, 
				COGCategoryLearningInputFiles &mydata): config(configarg)
{    

    // ask STL to pre-allocaate space for the layers of the network
    inputDims.reserve (50);
    outputUnits.reserve (50);
    clusters.reserve (50);
    
    // get parameters
    R = params["R"];
    BETA = params["BETA"];
    D = params["D"];
    LEARN = params["LEARN"];
    THRESHOLD = params["THRESHOLD"];
    NEW_CLUSTER_ERROR_TOLERANCE = params["NEW_CLUSTER_ERROR_TOLERANCE"];
    
    /*
    cout << "R = " << R << endl;
    cout << "BETA = " << BETA << endl;
    cout << "D = " << D << endl;
    cout << "LEARN = " << LEARN << endl;
    cout << "THRESHOLD = " << THRESHOLD << endl;
    cout << "NEW_CLUSTER_ERROR_TOL = " << NEW_CLUSTER_ERROR_TOLERANCE << endl;
    */
    
    // get some configuration options
    int cat_label_lambda = config.GetAsBool ("USE_CAT_LABEL_LAMBDA");
    int distinct_focus = config.GetAsBool ("USE_DISTINCT_FOCUS_LAMBDA");
    
    if ( config.IsSet ("MAXIMUM_CLUSTERS") ) {
	maximum_clusters = config.GetAsInt ("MAXIMUM_CLUSTERS");
    }
    else {
	maximum_clusters = 10000; // an arbitrarily large number of clusters if not specified
    }
    
    if ( config.IsSet ("RECOG_TYPE") ) {
	recog_type = config.GetAsInt ("RECOG_TYPE");
    }
    else {
	recog_type = DEFAULT; // overall familiarity
    }

    if ( config.IsSet ("DOTS") ) {
        dot_stimuli = config.GetAsBool ("DOTS");
    }


            
    if ( dot_stimuli ) {
        
        for ( int i = 0; i < mydata.GetNDims (); i++ ) {
            char type = mydata.GetTypeForDim (i);
            double max = mydata.GetMaxForDim (i);
            double min = mydata.GetMinForDim (i);
            int nvals  = mydata.GetNValsForDim (i);
            // DOTS CODE - set one to a different init lambda and the rest to zero
            double init_lambda;
            if (type == 'D') {
                init_lambda = 0.925795;
            }
            else if ((type == 'C') || (type == 'N')) {
                init_lambda = 1.0;
            }
            else {
                init_lambda = 0.0;
            }
            
            // if we are fitting the lambda with the model then don't use initlambda
            SUSTAINDimension inputdim (type, max, min, nvals, init_lambda);
            inputDims.push_back (inputdim);

            // create output dimensions that are the same
            for ( int j = 0; j < inputDims.back().nVals; j++ ) {
                SUSTAINCatUnit outputunit;
                outputUnits.push_back (outputunit);
            }
        }
        
    } else {
        // for number of dimensions
        for ( int i = 0; i < mydata.GetNDims (); i++ ) {
    
            // create input dimensions
            char type  = mydata.GetTypeForDim (i);
            double max = mydata.GetMaxForDim (i);
            double min = mydata.GetMinForDim (i);
            int nvals  = mydata.GetNValsForDim (i);
            // DOTS CODE - set one to a different init lambda and the rest to zero
            double init_lambda = 1.0;
            
            // if we are at the category label lambda, then use it as a parameter
            // this is HARDCODED AND PROBABLY BAD
            if ( (i == (mydata.GetNDims () - 1) ) && cat_label_lambda ) {
                init_lambda = params["CAT_LABEL_LAMBDA"];
            }
    
            
            // $$$$$
            // for sl3 the first dim gets distinct_focus
            if ( config.IsSet ("DISTINCT_FOCUS_DIM") ) {
                if ( (i == config.GetAsInt("DISTINCT_FOCUS_DIM")) && distinct_focus ) {
                    init_lambda = params["DISTINCT_FOCUS"];
                }
            }
            else if ( (i == (mydata.GetNDims () - 2) ) && distinct_focus ) {
                init_lambda = params["DISTINCT_FOCUS"];
            }
            // $$$$$
        
            // if we are fitting the lambda with the model then don't use initlambda
            SUSTAINDimension inputdim (type, max, min, nvals, init_lambda);
            inputDims.push_back (inputdim);
	
            // create output dimensions that are the same
            for ( int j = 0; j < nvals; j++ ) {
                SUSTAINCatUnit outputunit;
                outputUnits.push_back (outputunit);
            }
        }
    }

}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++

    StimulateNetwork (COGCategoryLearningStimulusItems& stimulus)

    Overloaded version of StimulateNetwork.
    see StimulateNetwork for more documentation.
    The overloaded function copies a stimulus item
    (stimulus) onto the input layer of the network.
    This only done once per stimulus presentation,
    thus any calls after the first stimulus presentation
    need only call StimulateNetwork().  The value
    of the last input will still be available on the
    input units until this overloaded version is called.

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
int
SUSTAINNetwork::StimulateNetwork (COGCategoryLearningStimulusItem& stimulus)
{
    // Note:
    // This is where a massive code slow down occur.  Actually copying
    // the value of the input dimensions on each stimulus presentation
    // is inefficient but perhaps a bit more clear.  If it becomes
    // a problem then a new solution could be worked up.
    
    // set the values of the input and and the status of the output dimensions
    itemType = -999; 
    int index = 0;
    for ( int i = 0; i < (int)stimulus.size (); i++ ) {
	inputDims[i].SetValue (stimulus[i].value, stimulus[i].status);
	for ( int j = 0; j < (int)inputDims[i].nVals; j++ ) {
	    outputUnits[index++].SetStatus (stimulus[i].status);
	}
        // $$$$$
        if (inputDims[i].status == ALWAYS_WRONG)
        {
            itemType = ALWAYS_WRONG;
	}
        else if (inputDims[i].status == ALWAYS_RIGHT)
	{
            itemType = ALWAYS_RIGHT;
	}
        // $$$$$
    }
    
    return StimulateNetwork ();
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
   
     StimulateNetwork ()

    StimulateNetwork is the main workhorse function
    of the model.  It passes a stimulus item
    that is currently in the input layer through
    the network.  This function is usually complimented
    by DoLearning() which creates new clusters, etc...

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
int
SUSTAINNetwork::StimulateNetwork ()
{
    feedback = FEEDBACK_UNKNOWN;
    feedbackprob = 0.0;
    
    // for each cluster
    for ( unsigned int i = 0; i < clusters.size (); i++ ) {

	// calculate distances
	CalculateDistance (i);
	
	// calculate activation of each cluster
	CalculateActivation (i);
    }

    // calculate output after lateral inhibition creates competition
    CalculateOutputs ();

    // calculate winner
    CalculateWinner ();

    // propogate winner
    PropogateWinner ();

    // calculate cat unit outputs
    CalculateOutputProbabilities ();

    // receive feedback
    ReceiveFeedback ();
    
    // $$$$$
    if ( itemType == ALWAYS_WRONG ) {
        feedback = FEEDBACK_INCORRECT;
    }
    else if ( itemType == ALWAYS_RIGHT ) {
        feedback = FEEDBACK_CORRECT;
    }
    // $$$$$
    
    return feedback;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++

    ForcedChoice (COGCategoryLearningStimulusItems& stimulus1, 
		    COGCategoryLearningStimulusItems& stimulus2)

    The forced choice stimulation function.  Commonly
    used in experiments, where two items are shown and the
    subject is to choice between them.

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::ForcedChoice (COGCategoryLearningStimulusItem& correct, 
				COGCategoryLearningStimulusItem& incorrect)
{
    
    SUSTAINCatUnits::iterator p;
    
    // present correct item and find output of category unit
    double correctoutput;
    StimulateNetwork(correct);
    p = outputUnits.begin ();
    for ( int i = 0; i < (int)inputDims.size (); i++ ) {
	if ( inputDims[i].status == UNKNOWN ) {
	    for ( int j = 0; j < inputDims[i].nVals; j++) {
		if ( inputDims[i].dimensionRep[j] >= 1 ) {
		    correctoutput = p->GetActivation ();
		}
		p++;
	    }
	}
	else {
	    p += inputDims[i].nVals;
	}
    }
    
    // present incorrect item and find output of category unit
    double incorrectoutput;
    StimulateNetwork(incorrect);
    p = outputUnits.begin ();
    for ( int i = 0; i < (int)inputDims.size (); i++ ) {
	if ( inputDims[i].status == UNKNOWN ) {
	    for ( int j = 0; j < inputDims[i].nVals; j++) {
		if ( inputDims[i].dimensionRep[j] >= 1 ) {
		    incorrectoutput = p->GetActivation ();
		}
		p++;
	    }
	}
	else {
	    p += inputDims[i].nVals;
	}
    }
    
    double result = exp(D*correctoutput) / (exp(D*correctoutput) + exp(D*incorrectoutput));
    
    return result;
}


// $$$$$
/*+SUSTAINNetwork+++++++++++++++++++++++++++++++

    ForcedChoice0 (COGCategoryLearningStimulusItems& stimulus1, 
		    COGCategoryLearningStimulusItems& stimulus2)

    The forced choice stimulation function using
    sum of all clusters' outputs.

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::ForcedChoice0 (COGCategoryLearningStimulusItem& correct, 
				COGCategoryLearningStimulusItem& incorrect)
{    
    // present correct item and find output of category unit
    double correctoutput = 0.0;
    StimulateNetwork(correct);
    for ( unsigned int i = 0; i < clusters.size (); i++ ) {
	correctoutput += clusters[i].output;
    }
    
    // present incorrect item and find output of category unit
    double incorrectoutput = 0.0;
    StimulateNetwork(incorrect);
    for ( unsigned int i = 0; i < clusters.size (); i++ ) {
	incorrectoutput += clusters[i].output;
    }
    
    double result = exp(D*correctoutput) / (exp(D*correctoutput) + exp(D*incorrectoutput));
    
    return result;
}
// $$$$$


// $$$$$
/*+SUSTAINNetwork+++++++++++++++++++++++++++++++

    ForcedChoice1 (COGCategoryLearningStimulusItems& stimulus1, 
		    COGCategoryLearningStimulusItems& stimulus2)

    The forced choice stimulation function using
    most activated cluster's output.

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::ForcedChoice1 (COGCategoryLearningStimulusItem& correct, 
				COGCategoryLearningStimulusItem& incorrect)
{    
    // present correct item and find output of category unit
    double correctoutput;
    StimulateNetwork(correct);
    correctoutput = clusters[0].output;
    
    // present incorrect item and find output of category unit
    double incorrectoutput;
    StimulateNetwork(incorrect);
    incorrectoutput = clusters[0].output;
    
    double result = exp(D*correctoutput) / (exp(D*correctoutput) + exp(D*incorrectoutput));
    
    return result;
}
// $$$$$

    
// $$$$$
/*+SUSTAINNetwork+++++++++++++++++++++++++++++++

    ForcedChoice2 (COGCategoryLearningStimulusItems& stimulus1, 
		    COGCategoryLearningStimulusItems& stimulus2)

    The forced choice stimulation function using
    sum of all clusters' activations.

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::ForcedChoice2 (COGCategoryLearningStimulusItem& correct, 
				COGCategoryLearningStimulusItem& incorrect)
{    
    // present correct item and find output of category unit
    double correctoutput = 0.0;
    StimulateNetwork(correct);
    for ( unsigned int i = 0; i < clusters.size (); i++ ) {
	correctoutput += clusters[i].activation;
    }
    
    // present incorrect item and find output of category unit
    double incorrectoutput = 0.0;
    StimulateNetwork(incorrect);
    for ( unsigned int i = 0; i < clusters.size (); i++ ) {
	incorrectoutput += clusters[i].activation;
    }
    
    double result = exp(D*correctoutput) / (exp(D*correctoutput) + exp(D*incorrectoutput));
    
    if (result < 0.000001) result = 0.0;
    
    return result;
}
// $$$$$


/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
 
    CalculateDistance (int i)

    This function computes the distance from the
    current input stimulus to cluster i, where i
    is a value between 0 and clusters.size().

++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::CalculateDistance (int i)
{

    // Note:
    // The = and - operators are overloaded for SUSTAINDimension objects
    // so that the following code will compute the distance according
    // to the correct metric.  See SUSTAINDimension() for more information
    // on this.  
    
    if ( dot_stimuli ) {
        
        for ( int j = 0; j < (int)inputDims.size (); j++ ) {
            if (inputDims[j].type == DOT_DIMENSION) {
                // note that this assumes the dimension is continuous
                clusters[i].distance[0] = MinimumAvgDistancePermutation(inputDims, clusters[i].position);
            }
            else if (inputDims[j].type == DOT_IGNORE) {
                clusters[i].distance[j] = 0.0;
            }
            else {
                clusters[i].distance[j] = Distance(inputDims[j], clusters[i].position[j]);
            }
        }
    }
    else { // NORMAL DISTANCE
        // for each input dimension, calculate distance from current input to cluster
        for ( int j = 0; j < (int)inputDims.size (); j++ ) {
            clusters[i].distance[j] = Distance(inputDims[j], clusters[i].position[j]);
        }
    }
}

/*+dot_distance+++++++++++++++++++++++++++++++
    
    operator< (const dot_distance &rhs) const

    ordering function so that the STL sort() function
    works on lists of type dot_distance
    
++++++++++++++++++++++++++++++++dot_distance+*/
int
dot_distance::operator<(const dot_distance &rhs) const {
   return (this->distance < rhs.distance);
}

/*+dot_distance+++++++++++++++++++++++++++++++
    
    operator==(const dot_distance &rhs) const

    equality testing operator that the STL remove() 
    function works on lists of type dot_distance
    
++++++++++++++++++++++++++++++++dot_distance+*/
int
dot_distance::operator==(const dot_distance &rhs) const {
    if ((this->x == rhs.x) || (this->y == rhs.y)) {
        return 1;
    } else { return 0; }
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    MinimumAvgDistancePermutation (SUSTAINPosition x, SUSTAINPosition y)

    Finds the minimum avg distance permutation
    using the greedy method between a stimulus item
    and a cluster.
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::MinimumAvgDistancePermutation (SUSTAINPosition x, SUSTAINPosition y)
{

    // the number of coordinate pairs is the integer number of times the 2 goes in
    // could be a problem if there were more than one category label or something
    if ( x.size() != y.size() ) {
        cout << "ERROR Number of coordinate points is not equal in input and cluster" << endl;
        exit (0);
    }
    
    /*
    cout << "point===";
    for ( int i = 0; i < x.size(); i++ ) {
        cout << x[i].dimensionRep[0] << ", ";
    }
    cout << endl;
    
    cout << "cluster===";
    for ( int i = 0; i < y.size(); i++ ) {
        cout << y[i].dimensionRep[0] << ", ";
    }
    cout << endl;
    */


    // build distance list with coordinates
    list<dot_distance> L;
    for ( int i = 0; i < x.size()-1; i+=2 ) {
        for ( int j = 0; j < y.size()-1; j+=2 ) {
            dot_distance test;
            
            test.distance = sqrt( pow((x[i].dimensionRep[0] - y[j].dimensionRep[0]),2.0) +
                          pow((x[i+1].dimensionRep[0] - y[j+1].dimensionRep[0]),2.0) );
            test.x = i/2;
            test.y = j/2;
            L.push_back(test);
        }
    }
    
    //implement the greedy method
    list<int> to;
    list<int> from;
    for ( int i = 0; i < 9; i++ ) { 
        to.push_back(i); 
        from.push_back(i); 
    } 
    
    // sort by distance
    L.sort();

    double meandist = 0.0;
    double ndists = 0.0;
    while ( !from.empty() && !to.empty() ) {
        // take shortest distance off the stack
        dot_distance t = L.front();
        meandist += t.distance;
        ndists++;
        
        // remove from lists
        to.remove(t.y);
        from.remove(t.x);
        
        // remove all pairs from possible pairs
        L.remove(t);
    
    }
    
    meandist = (double)meandist/(double)ndists;
    double out = (meandist==0.0)?0.0:log(meandist);

    return out;
}


/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    CalculateActivation (int i)

    Passes the distances from each cluster to 
    each item through the attentional mechanism
    and then sums up the total activation of each 
    clusters.  i is the index for the cluster
    which should be in a range 0 to clusters.size()
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::CalculateActivation (int i)
{
    double sum1 = 0.0, sum2 = 0.0;
    double lambda2r = 0.0;
    
    // for each input dimension
    for ( unsigned int j = 0; j < inputDims.size (); j++ ) {
	if ( (inputDims[j].status == KNOWN) && (inputDims[j].type != DOT_IGNORE)) {
	    lambda2r = pow (inputDims[j].lambda, R);
            
            sum1 += lambda2r * exp (-inputDims[j].lambda * clusters[i].distance[j]);
	    sum2 += lambda2r;	
        }
	// else if MISSING or QUERIED
    }
    
    
    if ( sum2 == 0 ) {
	clusters[i].activation = 0; 
    }
    else {
	clusters[i].activation = sum1/sum2;
    }
    
    //cout << "distance = " << clusters[i].distance[0] << endl;
    //cout << "lambda = " << inputDims[0].lambda << endl;
    //cout << "cluster = " << clusters[i].activation << endl;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    CalculateOutputs ()

    The output of each cluster is attenuated in
    the presence of other highly activated clusters.
    This function implements the competitive
    inhibition between clusters and thus creates
    what we call the final output of the cluster
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::CalculateOutputs ()
{
    double sum = 0.0;
    
    for ( unsigned int i = 0; i < clusters.size (); i++ ) {
	sum += pow (clusters[i].activation, BETA);
    }

    for ( unsigned int i = 0; i < clusters.size(); i++ ) {
	if ( sum == 0 ) { clusters[i].output = 0.0; }
	else {
	    clusters[i].output = pow (clusters[i].activation, BETA)/sum;
	    clusters[i].output *= clusters[i].activation;
	}
    }
}

/*+unassociated++++++++++++++++++++++++++++++++
    sorting_clusters (SUSTAINCluster x, 
		      SUSTAINCluster y)
		      
    The standard STL vector structure provides
    a sorting algorithm sort() defined in 
    "algorithm.h" which needs a ordering criteria.
    This function defines that the clusters vector 
    should be sorted in descending order according 
    to the output level of the cluster.

++++++++++++++++++++++++++++++++++unassociated+*/
bool 
sorting_clusters (SUSTAINCluster x, SUSTAINCluster y) {
    return x.output > y.output;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    CalculateWinner ()

    Sorts the clusters in decending order
    according to their activation level.  This
    sort is done in place, but the cluster.id
    member can still be used to determine
    the order in which particular clusters
    were created.
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::CalculateWinner ()
{
    // sort the clusters in descending order by output level
    sort(clusters.begin (), clusters.end (), sorting_clusters);
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    PropogateWinner ()

    This function passes the output of the winning
    cluster across the connections weights activate
    the category units.  Note that this function
    assumes that there is only one winner of the
    cluster competition, although future versions
    might want to consider more than one cluster
    as the winner.
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::PropogateWinner () 
{

    if (clusters.size () > 0) {
	for (unsigned int j = 0; j < outputUnits.size (); j++) {
	    double act = clusters[0].output * clusters[0].connections[j];
	    outputUnits[j].SetActivation (act);
	}
    }
    
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    CalculateOutputProbabilities ()

    This function calculates that output probabilities
    for each category unit.  If the status of the 
    dimension is known that these probabilities
    are set to zero (i.e., there is zero probability of 
    responding blue when you are being asked to 
    predict the category label)
    
    Otherwise the activation of each category
    unit is passed through a function to compute
    the probability of responding with that category
    label.  Thus, highly activated category
    units will get a stronger probability of response.
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::CalculateOutputProbabilities () 
{
    SUSTAINCatUnits::iterator p = outputUnits.begin ();
    
    for ( unsigned int i = 0; i < inputDims.size (); i++ ) {

	// if known then just set the probability to zero
	if ( inputDims[i].status == KNOWN ) {
	    for ( int j = 0; j < inputDims[i].nVals; j++ ) {
		p->SetProbability (0.0);
		p++;
	    }
	}
	else {
	
	    if ( inputDims[i].type == CONTINUOUS ) {
		p->SetProbability (p->GetActivation());
		p++;
	    }
	    else if ( inputDims[i].type == NOMINAL ) {
	    	double sum = 0;
		SUSTAINCatUnits::iterator oldp = p;	
		
		for ( int j = 0; j < inputDims[i].nVals; j++ ) {
		    sum += exp (p->GetActivation() * D);
		    p++;
		}
		
		p = oldp;
		
		for (int j = 0; j < inputDims[i].nVals; j++) {
		    double prob = exp (p->GetActivation() * D)/sum;
		    p->SetProbability (prob);
		    p++;
		}
	    }
	    
	} // if
	
    } // for

}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    OutputDecisionFunction ()

    SUSTAIN includes a noisy decision function
    that uses the probabilities of responses to
    do "probability matching" for responses.  Thus
    the model responds with the most highly
    probable category unit on the queried or
    unknown dimensions in most cases, however,
    the model may randomly give the "incorrect"
    response.  This is to simulate noise in
    human decision making.  
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
int
SUSTAINNetwork::OutputDecisionFunction(double prob)
{
    double needle;
    int return_val;
    
    needle = rand()/(RAND_MAX+1.0);
    if (needle > prob) {
	return_val = FEEDBACK_INCORRECT;
    }
    else {
	return_val = FEEDBACK_CORRECT;
    }
    
    return return_val;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    ReceiveFeedback ()

    In choosing a response SUSTAIN uses a noisy
    decision function (see OutputDecisionFunction).
    The probability of responding correctly is
    first calculated that then the actualy
    response in probability weighted to match
    this probability. (i.e. in a large number
    of trials with this same probability sustain
    will respond correctly with the same
    proportion.)  
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::ReceiveFeedback () 
{
    feedbackprob = GetProbabilityOfCorrect ();
    feedback = OutputDecisionFunction (feedbackprob);
    
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    GetProbability ()
    
    GetProbability is a interface function that
    can be used by SUSTAINModel to find out what
    the underlieing probability of a correct
    response was (this is used in creating
    learning curves, etc...)
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::GetProbability ()
{
    return feedbackprob;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    GetProbabilityOfCorrect ()
    
    GetProbabilityOfCorrect returns the probability
    of giving a correct response for the queried
    input dimensions (UNKNOWN dimension).
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double	
SUSTAINNetwork::GetProbabilityOfCorrect () 
{

    double prob = 0.0;
    SUSTAINCatUnits::iterator p = outputUnits.begin ();
    
    // find correct answer
    // and find probability of getting that answer
    for ( int i = 0; i < (int)inputDims.size (); i++ ) {
	if ( (inputDims[i].status == UNKNOWN) ) {
	    
	    if ( inputDims[i].type == NOMINAL ) {
		// if a nominal dimension, we have to search for the "correct answer"
		for ( int j = 0; j < inputDims[i].nVals; j++ ) {
		    if ( inputDims[i].dimensionRep[j] >= 1 ) {
			prob = p->GetProbability ();
		    }
		    p++;
		}
	    }
	    else if ( inputDims[i].type == CONTINUOUS ) {
		// if we are predicting a continuous dimension we don't have to search
		prob = p->GetProbability ();
	    }
	}
	else {
	    p += inputDims[i].nVals;
	}
	
    }

    return prob;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    DoLearning ()
    
    DoLearning is the main function for learning
    and recruitment of clusters.  If no clusters
    exist a new one is created initially, otherwise
    clusters are added according to the recruitment
    rule.  There is a older recruitment rule for
    legacy...
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::DoLearning ()
{

    if ( (int)clusters.size () == 0 ) { 
	CreateNewCluster ();
	StimulateNetwork ();
	AdjustWinner (0);
    }
    else {
	// cluster recruitment rule
	if ( config.GetAsInt("CLUSTER_RECRUITMENT_RULE") == OLD_RECRUITMENT_RULE ) {
	    OldClusterRecruitmentRule ();
	}
	else {
	    ClusterRecruitmentRule ();
	}
    }

}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    AdjustWinner ()
    
    The winning cluster's connection, cluster position,
    and attentional weights are all updated.
    clustern is the index of the winning cluster
    (should be 0, since the clusters are sorted by
    output level)
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::AdjustWinner (int clustern)
{
    AdjustConnections (clustern);
    AdjustClusterPosition (clustern);
    AdjustLambdaValues (clustern);
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    AdjustConnections ()
    
    Updates the winning clusters connections to
    make it more likely to predict the correct 
    response for the items it responds to.
    There are two modes of operation, either
    all the connections are updated, or only
    those related to the queried (UNKNOWN) dimension
    are updated.
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::AdjustConnections (int clustern)
{
    if( config.GetAsBool("ADJUST_ALL_CONNECTIONS") == TRUE ) {
	
	// for each dimension
	int pos = 0;
	for ( unsigned int i = 0; i < inputDims.size(); i++ ) {
	    // for values in dimension
	    for ( int j = 0; j < inputDims[i].nVals; j++ ) {
		// calculate error (humble teacher)
                // $$$$$
		double error = 0.0;
                
                if ( inputDims[i].status == ALWAYS_WRONG ) {
                    error = HumbleTeacherError ((1-FindResponseOfCluster(0)), 
						    outputUnits[pos].activation);
                }
                else if ( inputDims[i].status == ALWAYS_RIGHT ) {
                    error = HumbleTeacherError (FindResponseOfCluster(0), 
						    outputUnits[pos].activation);
                }
                else {
                    error = HumbleTeacherError (inputDims[i].dimensionRep[j], 
						    outputUnits[pos].activation);
                }
                
                // $$$$$
		// cluster[0] connections equal to something new
		clusters[clustern].connections[pos] += LEARN * error * clusters[clustern].output;
		pos++;
	    }
	}
	
    }
    else {
	
	// for each dimension that is unknown 
	int pos = 0;
	for ( unsigned int i = 0; i < inputDims.size(); i++ ) {
	    
            double tmp = 0.0;
            // for values in dimension
		
            // calculate error (humble teacher)
            // $$$$$
            double error = 0.0;
                    
            if ( inputDims[i].status == ALWAYS_WRONG ) {
                for ( int j = 0; j < (int)inputDims[i].nVals; j++ ) {
                    error = HumbleTeacherError ((1-FindResponseOfCluster(0)), 
                                                outputUnits[pos].activation);
                    //tmp += error * clusters[clustern].output;
		    clusters[clustern].connections[pos] += LEARN * error * clusters[clustern].output;
		    pos++;
                }
            }
            else if ( inputDims[i].status == ALWAYS_RIGHT ) {
                for ( int j = 0; j < (int)inputDims[i].nVals; j++ ) {
                    error = HumbleTeacherError (FindResponseOfCluster(0), 
                                                outputUnits[pos].activation);
                    //tmp += error * clusters[clustern].output;
		    clusters[clustern].connections[pos] += LEARN * error * clusters[clustern].output;
		    pos++;
                }
            }
            else if ( inputDims[i].status == UNKNOWN ) {
                for ( int j = 0; j < (int)inputDims[i].nVals; j++ ) {
                    error = HumbleTeacherError (inputDims[i].dimensionRep[j], 
                                                outputUnits[pos].activation);
                    //tmp += error * clusters[clustern].output;
		    clusters[clustern].connections[pos] += LEARN * error * clusters[clustern].output;
		    pos++;
                }
            }
            // $$$$$
		    

		/*if(tmp == 0.0) {
		    cout << "weights saturated" << endl;
		}
		*/

	    else {
		pos += inputDims[i].nVals;
	    } // if UNKNOWN
	} // for inputDims.size()
    
    } // if adjust_all_connections
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    HumbleTeacherError ()
    
    HumbleTeacherError was developed by John
    Krushce as a method of generating an error
    signal in a network.  It does not "punish"
    the model for over predicting the predicted
    value.
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::HumbleTeacherError (double actual, double model)
{
    if ( (model > 1) && (actual == 1) ) {
	return 0;
    }
    else if ( (model < 0) && (actual == 0) ) {
	return 0;
    }
    else {
	return (actual - model);
    }
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    AdjustClusterPosition ()
    
    The position of the cluster is updated
    so that it is closer to the current stimulus
    item
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::AdjustClusterPosition (int clustern)
{
    for ( int i = 0; i < (int)inputDims.size(); i++ ) {
	// for values in dimension
	for ( int j = 0; j < (int)inputDims[i].nVals; j++ ) {
	
            // $$$$$
	    double delta = 0.0;
                                
            if ( inputDims[i].status == ALWAYS_WRONG ) { 
                delta = ((1-FindResponseOfCluster(0)) - 
                            clusters[clustern].position[i].dimensionRep[j]);
            }
            else if ( inputDims[i].status == ALWAYS_RIGHT ) {
                delta = (FindResponseOfCluster(0) - 
                            clusters[clustern].position[i].dimensionRep[j]);
            }
            else {
                delta = (inputDims[i].dimensionRep[j] - 
                            clusters[clustern].position[i].dimensionRep[j]);
            }
            
            // $$$$$
	    clusters[clustern].position[i].dimensionRep[j] += LEARN * delta;
	}
    }
    
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    AdjustLambdaValues ()
    
    The attention values are increased on dimension
    that are providing consistent information for
    each cluster (ie, the distance along that dimension
    between item and cluster is small or zero)
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::AdjustLambdaValues (int clustern)
{

    //int distinct_focus = config.GetAsBool ("USE_DISTINCT_FOCUS_LAMBDA");
    
    for ( int i = 0; i < (int)inputDims.size(); i++ ) {
    
        if (inputDims[i].type != DOT_IGNORE) {
            double term1 = exp (-1.0 * inputDims[i].lambda * clusters[clustern].distance[i]);
            double term2 = inputDims[i].lambda * clusters[clustern].distance[i];
            inputDims[i].lambda += LEARN * term1 * (1.0 - term2);
        }
        
    	/*if ( (i == (inputDims.size () - 2) ) && distinct_focus && (inputDims[i].lambda == 0.0) ) {
	    inputDims[i].lambda = 0.0;
	}
        */
    }
    

}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    ClusterRecruitmentRule ()
    
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::ClusterRecruitmentRule ()
{

    // find the highest activation in my category
    int highest = FindMostActivatedClusterInMyCategory ();
    
    // if there is not a cluster in my category
    // if there is no cluster in my category or the highest activated
    // in my category is not the highest activated overall then
    // create a new cluster
    //if ( (highest == NO_CLUSTER_IN_MY_CATEGORY ) || (highest != 0) ) {
    if ( highest == NO_CLUSTER_IN_MY_CATEGORY ) {
	CreateNewCluster ();
	StimulateNetwork ();
	AdjustWinner (0);
    }
    else {
	if ( clusters[highest].activation < THRESHOLD ) {
	    CreateNewCluster ();
	    StimulateNetwork ();
	    AdjustWinner (0);
	}
	else {
	    AdjustWinner (highest);
	}
    }
    
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    FindMostActivatedClusterInMyCategory ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
int
SUSTAINNetwork::FindMostActivatedClusterInMyCategory ()
{

    // what is the correct category?
    double correct_category = FindCorrectCategory ();
    //double correct_response = FindCorrectResponse ();
    
    for ( int i = 0; i < (int)clusters.size (); i++ ) {
	
	double cluster_category = FindCategoryOfCluster (i);
	//double cluster_response = FindResponseOfCluster (i);
	
	if ( (cluster_category == correct_category) || 
	     (cluster_category == CLUSTER_NOT_IN_A_CATEGORY_YET) ) {
	    //cout << "This is the most activated in my category" << endl;
	    return i;
	}
    }
    
    // if there is no cluster in my category tell calling function
    return NO_CLUSTER_IN_MY_CATEGORY;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    FindCorrectResponse ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::FindCorrectResponse ()
{

    // NOTICE IF THERE ARE MULTIPLE ? DIMENSIONS
    // THE RESPONSE OF THE LAST DIMENSION IS USED
    // find correct answer
    // and find probability of getting that answer
    double resp = -1;
    
    int index = 0;
    for ( int i = 0; i < (int)inputDims.size(); i++ ) {
        if (inputDims[i].status == ALWAYS_WRONG) {
            resp = (1-FindResponseOfCluster(0));
        }
        else if (inputDims[i].status == ALWAYS_RIGHT) {
            resp = FindResponseOfCluster(0);
        }
	else if ( inputDims[i].status == UNKNOWN ) {
	    if ( inputDims[i].type == NOMINAL ) {
		for ( int j = 0; j < inputDims[i].nVals; j++ ) {
		    if ( inputDims[i].dimensionRep[j] >= 1 ) {
			resp = index;
		    }
		    index++;
		}
	    }
	    else {
		resp = inputDims[i].dimensionRep[0];
	    }
	}
	else {
	    index += inputDims[i].nVals;
	}
    }
    
    if (resp == -1) {
	cout << "ERROR in FindCorrectResponse (should never reach this condition)" << endl;
	exit(0);
	return -1;
    }
    else {
	return resp;
    }
    //ERROR
    
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    FindCorrectCategory ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::FindCorrectCategory()
{

    // find correct answer
 
    int index = 0;
    // YOU HACKED THE FUCK OUT OF THIS
    int i = (int)inputDims.size() - 1; // HARDCODED CATEGORY LABEL IN LAST POSITION
    

    if ( inputDims[i].type == NOMINAL ) {
        for ( int j = 0; j < inputDims[i].nVals; j++ ) {
            if ( inputDims[i].dimensionRep[j] >= 1 ) {
                return index;
            }
            index++;
        }
    }
    else {
        return inputDims[i].dimensionRep[0];
    }

    

    //ERROR
    cout << "ERROR in FindCorrectCategory (should never reach this condition)" << endl;
    exit(0);
    return -1;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    IsClusterInCorrectCategory ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
int
SUSTAINNetwork::IsClusterInCorrectCategory ()
{
    // $$$$$
    if ( itemType == ALWAYS_WRONG ) {
        return FALSE;
    }
    else if ( itemType == ALWAYS_RIGHT ) {
        return TRUE;
    }
    // $$$$$
    
    double clustercat = FindResponseOfCluster (0);
    double correct_category = FindCorrectResponse ();
    //double clustercat = FindCategoryOfCluster (0);
    //double correct_category = FindCorrectCategory ();
    
    // if cluster is not associated with a category yet, just pretend
    // it is correct
    if ( clustercat == CLUSTER_NOT_IN_A_CATEGORY_YET ) {
	return TRUE;
    }

    //cout << fabs(clustercat- correct_category) << " " << NEW_CLUSTER_ERROR_TOLERANCE << endl;
    
    // if cluster is in correct category
    //if(clustercat == correct_category) {
    if ( fabs(clustercat - correct_category) <= NEW_CLUSTER_ERROR_TOLERANCE ) {
	return TRUE;
    }
    else {
	return FALSE;
    }
    
    return TRUE;
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    FindCategoryOfCluster ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::FindCategoryOfCluster (int clustern)
{
    int index = 0;
    int maxindex = 0;
    double max = -9999.9;
    
    // find correct answer
    // and find probability of getting that answer
    // ANOTHER CRAZY FUCKING HACK
    unsigned int i = inputDims.size() - 1; // HARDCODED category label is last dimension
    

    if ( inputDims[i].type == NOMINAL ) {
        /* the old way looked for the most positive connection
            max = clusters[clustern].connections[index];
            for ( int j = 0; j < inputDims[i].nVals; j++ ) {
                if ( clusters[clustern].connections[index] >= max ) {
                    max = clusters[clustern].connections[index];
                    maxindex = index;
                }
                index++;
            }
        */
        // the new way looks for the clusters position along the category label dimension
        max = clusters[clustern].position[i].dimensionRep[index];
        for ( int j = 0; j < inputDims[i].nVals; j++ ) {
            if ( clusters[clustern].position[i].dimensionRep[index] >= max ) {
                max = clusters[clustern].position[i].dimensionRep[index];
                maxindex = index;
            }
            index++;
        }
    }
    else {
        // find clusters position along this dimension
        return clusters[clustern].position[i].dimensionRep[0];
    }
    
    if ( max == 0.0 ) {
	return CLUSTER_NOT_IN_A_CATEGORY_YET;
    }
    else {
	return maxindex;
    }
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    FindResponseOFCluster ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
double
SUSTAINNetwork::FindResponseOfCluster (int clustern)
{

    // NOTICE IF THERE ARE MULTIPLE ? DIMENSIONS
    // THE RESPONSE OF THE LAST DIMENSION IS USED
    int index = 0;
    int maxindex = 0;
    double max = -9999.9;
    
    // find correct answer
    // and find probability of getting that answer
    for ( unsigned int i = 0; i < inputDims.size(); i++ ) {
	if ( (inputDims[i].status == UNKNOWN) || (inputDims[i].status == ALWAYS_WRONG) || (inputDims[i].status == ALWAYS_RIGHT) ) {
	    if ( inputDims[i].type == NOMINAL ) {
		max = clusters[clustern].connections[index];
                for ( int j = 0; j < inputDims[i].nVals; j++ ) {
                    if ( clusters[clustern].connections[index] >= max ) {
                        max = clusters[clustern].connections[index];
                        maxindex = index;
                    }
                    index++;
                }
	    }
	    else {
		// find clusters position along this dimension
		return clusters[clustern].position[i].dimensionRep[0];
	    }
	}
	else {
	    index += inputDims[i].nVals;
        }
    }
    
    if ( max == 0.0 ) {
	return CLUSTER_NOT_IN_A_CATEGORY_YET;
    }
    else {
	return maxindex;
    }
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    OldClusterRecruitmentRule ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::OldClusterRecruitmentRule ()
{

    if ( (!IsClusterInCorrectCategory()) || (clusters[0].activation < THRESHOLD) ) {
	CreateNewCluster ();
	StimulateNetwork ();
	AdjustWinner (0);
    }
    else {
	AdjustWinner (0);
    }
    
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    GetNClusters ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
int
SUSTAINNetwork::GetNClusters ()
{
    return (int)clusters.size();
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    CreateNewCluster ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void	
SUSTAINNetwork::CreateNewCluster ()
{
    //cout << "created cluster!" << endl;
    if((int)clusters.size () < maximum_clusters) {
	SUSTAINCluster newcluster (inputDims, outputUnits, clusters.size());
	clusters.push_back (newcluster);
    }

}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    OutputAnalysis ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
void
SUSTAINNetwork::OutputAnalysis (const char *fn, vector<COGCategoryLearningStimulusItem> &items)
 {
    // open file for writing
    ofstream outfile (fn);
    
    if ( !outfile ) {
	cout << "error opening file " << fn << endl;
	exit(1);
    }
    
    // output lambdas
    outfile << endl;
    outfile << "lambdas = ";
    outfile << " { ";
    for ( unsigned int j = 0; j < inputDims.size(); j++ ) {
	outfile << inputDims[j].lambda;
	if ( j != inputDims.size()-1 ) {
	    outfile << ", ";
	}
    }
    outfile << " } " << endl;
    
    int n_real_items = (int)items.size ();
    // count number of items in each cluster
    vector<int> clusters_items ((int)clusters.size(), 0);
    
    // output which items are in which cluster
    outfile << "itemstoclusters = {";    
    for ( int i = 0; i < n_real_items; i++ ) {
        
        // figure out which cluster this would go to
        int cn = DetermineCluster (items[i]);
        clusters_items[cn]++;
        outfile << cn;
        
        if ( i != (n_real_items-1) ) {
            outfile << ", ";
        }
        
    }
    outfile << "}" << endl;
    
    /*
    outfile << "items = {" << endl;    
    for ( int i = 0; i < n_real_items; i++ ) {
        // figure out which cluster this would go to
	int cn = DetermineCluster (items[i]);
	clusters_items[cn]++;
	for ( int j = 0; j < (int)items[i].size(); j++ ) {
            outfile << items[i][j].value;
        }
        outfile  << " " << "-> cluster " << cn << ": ";
        for ( unsigned int k = 0; k < clusters[0].position.size(); k++ ) {
		outfile << "[";
		for ( int l = 0; l < clusters[0].position[k].nVals; l++ ) {
		    outfile << clusters[0].position[k].dimensionRep[l];
		    
		    if ( l != (clusters[0].position[k].nVals - 1) ) {
			outfile << ":";
		    }
		}
		outfile << "]";
	}
        // $$$$$
        if ( recog_type == SUM_OUT ) {
            // $$$$$ use the output of the most activated cluster
            // after cluster competition the first one should be the most activated
            double recog = 0;
            for (unsigned i = 0; i < clusters.size(); i++)
                recog += clusters[i].output;
            outfile << " " << recog << endl;
        }
        else if ( recog_type == HIGHEST_OUT ) {
            // $$$$$ use the output of the most activated cluster
            // after cluster competition the first one should be the most activated
            outfile << " " << clusters[0].output << endl;
        }
        else if ( recog_type == SUM_ACT ) {
            // $$$$$ use the sum of activations of all clusters
            double recog = 0;
            for (unsigned i = 0; i < clusters.size(); i++)
                recog += clusters[i].activation;
            outfile << " " << recog << endl;
        }
        else {
            // $$$$$ default is output of category unit
            SUSTAINCatUnits::iterator p;
            double recog = 0;
            p = outputUnits.begin ();
            for ( int i = 0; i < (int)inputDims.size (); i++ ) {
                if ( inputDims[i].status == UNKNOWN ) {
                    for ( int j = 0; j < inputDims[i].nVals; j++) {
                        if ( inputDims[i].dimensionRep[j] >= 1 ) {
                            recog = p->GetActivation ();
                        }
                        p++;
                    }
                }
                else {
                    p += inputDims[i].nVals;
                }
            }
            outfile << " " << recog << endl;
        }
    }
    outfile << "}" << endl;
    */
    
    // output cluster positions
    // for each cluster output its position
    outfile << "clusterpos = { ";
    for ( unsigned int i = 0; i < clusters.size(); i++ ) {
    
        outfile << " {";
        for ( unsigned int j = 0; j < clusters[i].position.size(); j++ ) {
            //if ( clusters[i].position[j].status == KNOWN ) {
                
                outfile << "{";
                for ( int k = 0; k < clusters[i].position[j].nVals; k++ ) {
                    outfile << clusters[i].position[j].dimensionRep[k];
                    
                    if ( k != (clusters[i].position[j].nVals - 1) ) {
                        outfile << ", ";
                    }
                }
                outfile << "}";
                
                if ( j != (clusters[i].position.size() - 1) ) {
                    //if (clusters[i].position[j+1].status == KNOWN) {
                        outfile << ", ";
                   // }
                }
            //}
        }
        outfile << "} ";
        
        if ( i != (clusters.size() - 1) ) {
            outfile << ", ";
        }
        
    }
    outfile << "}" << endl;
    
    // output n clusters
    outfile << "nclusters = " << (int)clusters.size () << endl;
    
    int n_dead = 0;
    
    // output cluster frequency table
    outfile << "clusterfreq =  {";
    for( unsigned int i = 0; i < clusters_items.size(); i++ ) {
	outfile << clusters_items[i];
	
	if( clusters_items[i] == 0 ) {
	    n_dead++;
	}
	
	if( i != (clusters_items.size()-1) ) {
	    outfile << ", ";
	}
    }
    outfile << "}" << endl;
    
    // output number of dead clusters (clusters that respond to no items)
    outfile << "nclustersdead = " << n_dead << endl;
    outfile << endl;
    
    outfile.close ();
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    DetermineCluster ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
int
SUSTAINNetwork::DetermineCluster (COGCategoryLearningStimulusItem& stimulus) {
    
    // set the values of the input and the status of the output dimensions
    int index = 0;
    for ( int i = 0; i < (int)stimulus.size (); i++ ) {
	inputDims[i].SetValue (stimulus[i].value, stimulus[i].status);
	/*
	for ( int j = 0; j < (int)inputDims[i].nVals; j++ ) {
	    outputUnits[index++].SetStatus (stimulus[i].status);
	}
	*/
    }
    
    // for each cluster
    for ( unsigned int i = 0; i < clusters.size (); i++ ) {

	// calculate distances
	CalculateDistance (i);
	
	// calculate activation of each cluster
	CalculateActivation (i);
    }
    
    // calculate output after lateral inhibition creates competition
    CalculateOutputs ();

    // calculate winner
    CalculateWinner ();
    
    return clusters[0].ident;
    
}

/*+SUSTAINNetwork+++++++++++++++++++++++++++++++
    
    ~SUSTAINNetwork ()
    
    
++++++++++++++++++++++++++++++++SUSTAINNetwork+*/
SUSTAINNetwork::~SUSTAINNetwork ()
{

}
