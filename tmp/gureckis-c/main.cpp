/*
    SUSTAIN: A network model of category learning
    Copyright (C) 2002  Todd M. Gureckis

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

#include <iostream>
#include <stdlib.h>
#include <time.h>
#include "common.h"
#include "COG.h"
#include "SUSTAINModel.h"
#include <mpi.h>

// define the evaluation function
double evaluate(PGAContext *ctx, int p, int pop);

COGPga mypga;
SUSTAINModel sustain;

int 
main ( int argc, char * argv[] ) 
{    

    int run_pga = FALSE;
    
    // process command line options here
    // get model setup option
    // get pga option
    if(argc == 1) {
	cout << "usage: sustain <modelfile> <pgafile (optional)>" << endl;
	exit(1);
    }
    
    if(argc > 2) {
	run_pga = TRUE;
    }
    
    // seed random number generator
    srand (time (NULL));
    
   // cout << "Hello, welcome to COG the general purpose cognitive modeling system!" << endl;
   
   if(run_pga) {
   
	MPI_Init(&argc, &argv);
	int myid;
	
	MPI_Comm_rank(MPI_COMM_WORLD, &myid);
	
	
   	mypga.SetUp(argc, argv, argv[2]);
	sustain.SetPGA(&mypga);
	sustain.Setup(argv[1], argv[0]);
	
	if(myid == 0) {
	    cout << "Running in pga mode" << endl;
	}
	
	mypga.Run(evaluate);
	
	MPI_Finalize();
    }
    else {
	
	sustain.Setup(argv[1], argv[0]);
        
	double mse = sustain.Simulate();
	
	cout << "rmserror = " << mse << endl;
    }


    //cout << "Shutting down COG" << endl;
}

double
evaluate(PGAContext *ctx, int p, int pop)
{
    //cout << "Running evaluation function" << endl;
    mypga.SetPPop(p, pop);
    return sustain.Simulate();
}
