/*
    SUSTAINModel.h
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

#ifndef SUSTAINMODEL_H
#define SUSTAINMODEL_H 1

#include "COG.h"
#include "COGCategoryLearningModel.h"
#include "SUSTAINNetwork.h"
#include <string.h>
#include <string>
#include <strstream.h>
#include <vector>
#include <queue>



#define CLUSTER_FREQ_SIZE 50


struct sustainData {    
    double		avg_clusters;
    int			cluster_freq[CLUSTER_FREQ_SIZE];
};

typedef struct sustainData SUSTAINData;


class SUSTAINModel : public COGCategoryLearningModel {

    public:
            void Setup			(const char *file, char *model);
	    void CreateModel		();
            void DeleteModel		();
            int  Stimulate		(COGCategoryLearningStimulusItem& stimulus);
            double ResponseProbability	();
            void DoLearning		();
            void RunAnalysis		(int runid);
            void OutputExtraAnalysis	(const char *fn, int problem_index);
            void OutputRunAnalysis	(const char *fn);	
            void ItemRelationshipMatrix (vector<double> &modeldata);
	    int  TypeOfSort		();
            void FixUpDataWatchers	();
            void SetUpDataWatchers	();
	    double  ForcedChoice	(COGCategoryLearningStimulusItem& stimulus1, 
					    COGCategoryLearningStimulusItem& stimulus2);
            double GetRecognitionResponse ();
            double GetCategoryResponse  ();
            double GetUnsupCategory	();
            void   Hack			();
	    int	   GetNClusters		();
	    int	   GetModeClusters	(int i);
	    
    private:	    
	// private data
	SUSTAINNetwork			*network;
	vector<SUSTAINPosition>		inputItems;	// input dimensions
        SUSTAINData			sustaindata[10];

};

#endif



