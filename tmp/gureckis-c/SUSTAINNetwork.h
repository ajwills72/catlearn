/*
    SUSTAINNetwork.h
    cogc++
    Created by Todd Gureckis (gureckis@love.psy.utexas.edu) on Sat Feb 09 2002.
 
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

#ifndef SUSTAINNETWORK_H
#define SUSTAINNETWORK_H 1

#include "COG.h"

#include "SUSTAINDimension.h"
#include "SUSTAINCluster.h"
#include "SUSTAINCatUnit.h"
#include <math.h>
#include <algorithm>

#define OLD_RECRUITMENT_RULE 0
#define NEW_RECRUITMENT_RULE 1

#define NO_CLUSTER_IN_MY_CATEGORY -1

#define FEEDBACK_CORRECT 1
#define FEEDBACK_INCORRECT 0
#define FEEDBACK_UNKNOWN -1

#define CLUSTER_NOT_IN_A_CATEGORY_YET -666

#define SUM_OUT 0
#define HIGHEST_OUT 1
#define SUM_ACT	2
#define DEFAULT -1

class dot_distance {
    public:
        double distance;
        int x;
        int y;
        int operator==(const dot_distance &rhs) const;
        int operator<(const dot_distance &rhs) const;
};

class SUSTAINNetwork : public COGError {
    friend	class SUSTAINCluster;
    friend	class SUSTAINModel;
    
    public:
			SUSTAINNetwork		(COGParser &config, COGParam &param, COGCategoryLearningInputFiles &mydata);
                
		int	StimulateNetwork	(COGCategoryLearningStimulusItem& tmp);
		int	StimulateNetwork			();
		double  ForcedChoice 		(COGCategoryLearningStimulusItem& correct, 
						    COGCategoryLearningStimulusItem& incorrect);
                double  ForcedChoice0 		(COGCategoryLearningStimulusItem& correct, 
						    COGCategoryLearningStimulusItem& incorrect);
                double  ForcedChoice1 		(COGCategoryLearningStimulusItem& correct, 
						    COGCategoryLearningStimulusItem& incorrect);
                double  ForcedChoice2 		(COGCategoryLearningStimulusItem& correct, 
						    COGCategoryLearningStimulusItem& incorrect);
		void	CalculateDistance			(int i);
                double  MinimumAvgDistancePermutation		(SUSTAINPosition x, SUSTAINPosition y);
                
		void	CalculateActivation			(int i);
		void	CalculateOutputs			();
		void	CalculateWinner				();
		void	PropogateWinner				();
		void	CalculateOutputProbabilities 		();
		int	OutputDecisionFunction			(double prob);
		
		void	ReceiveFeedback				();
		double	GetProbabilityOfCorrect			();
		double	GetProbability				();
		
		void	DoLearning 				();
		void	AdjustWinner				(int clustern);
		void	AdjustConnections 			(int clustern);
		double	HumbleTeacherError			(double actual, double model);
		void	AdjustClusterPosition			(int clustern);
		void	AdjustLambdaValues			(int clustern);
		int	IsClusterInCorrectCategory		();
		double	FindCorrectCategory			();
		double	FindCorrectResponse			();
		double	FindCategoryOfCluster			(int clustern);
		double	FindResponseOfCluster			(int clustern);
		void	ClusterRecruitmentRule 			();
		int	FindMostActivatedClusterInMyCategory	();
		void	OldClusterRecruitmentRule 		();
		void	CreateNewCluster			();
		int	DetermineCluster			(COGCategoryLearningStimulusItem& stimulus);
		int	GetNClusters				();
		void	OutputAnalysis 				(const char *fn, vector<COGCategoryLearningStimulusItem>	&items);

			~SUSTAINNetwork				();

    private:
    
	    // private data
	    COGParser			&config;
	    
	    //COGCategoryLearningStimulusItem 		&stimulus;
	    
	    SUSTAINPosition		inputDims;	// input dimensions
	    SUSTAINCatUnits		outputUnits;	// output units
	    SUSTAINClusters		clusters;	// clusters
	
	    int 			feedback;
	    double			feedbackprob;
	    int 			maximum_clusters;
            
            // $$$$$
	    int 			itemType;
            int				recog_type;
            // $$$$$
            int				dot_stimuli;    // are the input stimuli dots?
	    
	    // model parameters
	    double R;
	    double BETA;
	    double LEARN;
	    double D;
	    double THRESHOLD;
	    double NEW_CLUSTER_ERROR_TOLERANCE;
};

#endif