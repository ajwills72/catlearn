/*
    SUSTAINCluster.h
    cogc++
    Created by Todd Gureckis (gureckis@love.psy.utexas.edu) on Sat Feb 17 2002.
 
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

#ifndef SUSTAINCLUSTER_H
#define SUSTAINCLUSTER_H 1

#include "COG.h"
#include "SUSTAINDimension.h"
#include "SUSTAINCatUnit.h"


class SUSTAINCluster : public COGError {

    public:
			SUSTAINCluster		(SUSTAINPosition &, SUSTAINCatUnits &, int id);
		//void	PrintMe			();
			~SUSTAINCluster		();
			    
	// data data
	int				ident;
	double				activation;
	double 				output;
	vector<double>			connections;
	//double				connections[500];
	vector<double>			distance;
	//double				distance[500];
	SUSTAINPosition			position;	// position in input dimension space
};

typedef vector<SUSTAINCluster> SUSTAINClusters;
#endif

