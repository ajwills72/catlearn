/*
    SUSTAINModel.h
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

#ifndef SUSTAINMODEL_H
#define SUSTAINMODEL_H 1

#include "COG.h"
#include "SUSTAINNetwork.h"
#include <string.h>
#include <string>
#include <strstream.h>
#include <vector>
#include <queue>

#define grint(min, max) ((rand() % (int)(((max) + 1) - (min))) + (min))

struct problemData {

    // problem type
    int			shepard_six;
    int			cg2_ymlin_inf_class;
    int			fish;
    int			first_last;
    
    COGCategoryLearningInputFiles	filepair[10];
    COGParser		config;
    COGParam		param;
    
    vector<double>	humandata;
    string		problemname;
    string		sustainconfig;
    string		parameterfile;
    int			n_input_pairs;
    int			number_of_times;
    int			delete_network_at_end;
    int			number_of_epochs;
    
    int			delta_clusters;
    int			stop_no_new_clusters;
    int			last_n_clusters;
    
    int			criterion;
    double		percent_correct;
    int			n_items_correct;
    int			n_blocks_correct;
    int			quickfinish;
    int			n_blocks_to_criterion;
    int			times_reached_criterion;
    double		percent_times_reached_criterion; 
    double		overall_accuracy;
    double		avg_blocks_to_criterion;
    double		avg_clusters;
    vector<int>		cluster_freq;
    
    int			fit_learning_curve;
    int			fit_blocks_to_criterion;
    int			fit_overall_accuracy;
    int			fit_reached_criterion;
    int			fit_item_relationship_matrix;
    
    int			n_relationship_matrix;
    vector<double>	relationship_matrix[10];
    
    vector<int>		last_items_correct;
    vector<double>	learning_curve;
    double		item_matrix_vc[10];
    double		item_matrix_dotprod[10];
    
    int			animation_snapshot;
    string		animation_path;
    int			frameid;
    int			runid;
    int			randomize_files_per_item;	

};

typedef struct problemData SUSTAINProblemData;

class SUSTAINModel : public COGError {

    public:
			
	    void	Setup			(const char *filename);
	    void	SetPGA			(COGPga *pga);
	    void	PrintProblems		();
	    void	CleanUp			();
	    
	    double	Simulate		();
	    void	OutputFit		(int i);
	    void	RunModelOnItems		(vector<int> &order, int i, int fileindex);
	    
	    int		CheckStopCriterion	(int i);
	    void	UpdateStopCriterion	(int i);
			
    private:
    
	    void	ReadInProblem		(int i);
	    void	ReadInputFiles		(int i);
	    void	ReadFileIntoVector	(const char *fn, vector<double> &data);
	    void	GetProblemSettings	(int i);
	    
	    void	SetUpDataWatchers	();
	    void	FixUpDataWatchers	();
	    void	RunModelGeneral		();
	    double	EvaluateFit		();
	    
	    void	ItemRelationshipMatrix	(vector<double> &modeldata);
	    double	vectorCos		(vector<double> &v1, vector<double> &v2);
	    double	dotProd			(vector<double> &v1, vector<double> &v2);
	    
	    void	OutputExtraAnalysis	(const char *fn, int i);
	    void	RunAnalysis		(int i);
	    void	RandomShuffleArray	(vector<int> &array);
	    
	    
	    
	// private data
	SUSTAINNetwork			*network;
	vector<SUSTAINPosition>		inputItems;	// input dimensions
	COGParser			runscript;
	int				n_problems;
	int				cp;
	SUSTAINProblemData		pd[500];
	COGPga				*pga_obj;
};

#endif

