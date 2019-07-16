/*
    SUSTAINCluster.cpp
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

#include "SUSTAINCluster.h"

//SUSTAINCluster::SUSTAINCluster (SUSTAINPosition& pos, SUSTAINCatUnits& outputs) : distance(pos.size(), 0.0), connections(outputs.size(), 0.0)
SUSTAINCluster::SUSTAINCluster (SUSTAINPosition& pos, SUSTAINCatUnits& outputs, int idnum)
{
    activation 	= 0.0;
    output 	= 0.0;
    ident	= idnum;
    
    // center it on pos  YOU NEED TO DEFINE EQUALITY BETWEEN TWO POINTS
    for (int i = 0; i < (int)pos.size(); i++) {
	position.push_back(pos[i]);
	distance.push_back(0.0); // initialize distance
    }
    
    for (int i = 0; i < (int)outputs.size(); i++) {
	connections.push_back(0.0); // init connections
    }
    
}

/*
void
SUSTAINCluster::PrintMe (void)
{
    cout <<  "activation " << activation << endl;
    cout <<  "output " << output << endl;
    cout << "connections " << endl;
    for (int i = 0; i < (int)connections.size(); i++) {
	cout << connections[i] << " ";
    }
    cout << endl;
    
    cout << "distances " << endl;
    for (int i = 0; i < (int)distance.size(); i++) {
	cout << distance[i] << " ";
    }
    cout << endl;
    
    
    for (int i = 0; i < (int)position.size(); i++) {
	position[i].Print();
    }
    
    
    output	= 0.0;
    
}
*/

SUSTAINCluster::~SUSTAINCluster ()
{
    position.clear();
    distance.clear();
    connections.clear();

}
