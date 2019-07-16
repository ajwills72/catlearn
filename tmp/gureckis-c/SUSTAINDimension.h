/*
    SUSTAINDimension.h
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

#ifndef SUSTAINDIMENSION_H
#define SUSTAINDIMENSION_H 1

#include "COG.h"
#include <vector.h>


// type of input dimensions
#define NOMINAL 	0
#define CONTINUOUS 	1
#define DOT_IGNORE	2
#define DOT_DIMENSION	3

// flavor of input dimension, are you are category label?
#define NORMAL_DIMENSION 0
#define CATEGORY_LABEL  1


// status for dimensions
#define UNKNOWN		0
#define	KNOWN		1
#define	MISSING		2
#define ALWAYS_WRONG	3
#define ALWAYS_RIGHT	4

class SUSTAINNetwork;
class SUSTAINCluster;

class SUSTAINDimension : public COGError {
    friend class SUSTAINNetwork;
    friend class SUSTAINCluster;
    friend double Distance (SUSTAINDimension &op1, SUSTAINDimension &op2);
    public:
			SUSTAINDimension	(char type, double max, double min, int nVals, double i_lambda);
		void	SetValue		(double n, char stat);
		void	SetValue		(double n);
		void	SetStatus 		(char stat);
    SUSTAINDimension&	operator=		(const SUSTAINDimension &from); // overload equality
    //double		DistanceTo 		(const SUSTAINDimension &op2); // calculate distance
    //double		operator-		(const SUSTAINDimension &op2); // overload subtraction operator
		//void	PrintMe			(void);
                        ~SUSTAINDimension	();
			
	double		lambda; 	// the lambda attention parameter on this dimension
	
    private:
    
	// private data
	int		type; 		// type of dimensions (nominal, continuous, etc..)
	int		status; 	// status of dimensions (known or unknown, etc..)
	int		flavor;		// flavor of dimensions (category label or normal)
	double		max;  		// the maxium value along that dimension
	double		min;  		// the minimum value along that dimensions
	int		nVals;		// the number of values along that dimension
	vector<double>	dimensionRep; 	// the internal representation of the dimension
};

typedef vector<SUSTAINDimension> SUSTAINPosition; 

#endif