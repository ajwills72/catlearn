/*
    SUSTAINDimension.cpp
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

#include "SUSTAINDimension.h"

SUSTAINDimension::SUSTAINDimension (char t, double ma, double mi, int n, double i_lambda) : dimensionRep(n, 0.0)
{
    // set up default data
    if(t == 'c') {
	type = CONTINUOUS;
	flavor = NORMAL_DIMENSION;
	nVals = 1;
    }
    else if(t == 'n') {
	type = NOMINAL;
	flavor = NORMAL_DIMENSION;
	nVals = n;
    }
    else if(t == 'd') {
        type = DOT_IGNORE;
        flavor = NORMAL_DIMENSION;
        nVals = 1;
    }
    else if(t == 'D') {
        type = DOT_DIMENSION;
        flavor = NORMAL_DIMENSION;
        nVals = 1;
    }
    else if(t == 'N') {
	type = NOMINAL;
	flavor = CATEGORY_LABEL;
	nVals = n;
    }
    else if(t == 'C') {
	type = CONTINUOUS;
	flavor = CATEGORY_LABEL;
	nVals = 1;
    }
	    
    status = KNOWN; // just assume this for now
    max = ma;
    min = mi;
    lambda = i_lambda;
    
    // set up initial data to be all 0's
    /*
    if (type == NOMINAL) {
	for (int i = 0; i < nVals; i++) {
	    dimensionRep.push_back (0.0);
	}
    }
    else {
	dimensionRep.push_back (0.0);
    }
    */
    
}

void
SUSTAINDimension::SetValue (double n, char stat)
{
    SetValue(n);
    SetStatus(stat);
    
}

void
SUSTAINDimension::SetValue (double n)
{
    // check bounds, etc...    
    // clear current value
    if (type == NOMINAL) {
	int index = (int) n;
	for (int i = 0; i < nVals; i++) {
	    dimensionRep[i] = 0.0;
	}
        
	if ( (index >= 0) && (index < nVals) ) {
	   dimensionRep[index] = 1.0;
	}
	else {
	    // should COGError here
	    cout << "value " << index << " outside of accepted range for dimensions" << endl;
	    exit(0);
	}
    }
    else {
	dimensionRep[0] = n;
    }
}

void
SUSTAINDimension::SetStatus (char stat) 
{
    
    if (stat == 'k') {
	status = KNOWN;
    }
    else if (stat == '?') {
	status = UNKNOWN;
    }
    else if (stat == 'm') {
	status = MISSING;
    }
    else if (stat == '!') {
	status = ALWAYS_WRONG;
    }
    else if (stat == '*') {
	status = ALWAYS_RIGHT;
    }

}

SUSTAINDimension&
SUSTAINDimension::operator= (const SUSTAINDimension &from)
{
    type = from.type;
    status = from.status;
    max = from.max;
    min = from.min;
    nVals = from.nVals;

    for (int i = 0; i < nVals; i++) {
	dimensionRep[i] = from.dimensionRep[i];
    }
    
    return *this;
}	

double 
Distance (SUSTAINDimension &op1, SUSTAINDimension &op2) {
    
    
    if (op1.type != op2.type) {
	// error
	string errormsg = "cannot find the distance between two SUSTAINDimension of a different type. %s:%d";
	op1.COGErrorFatal (errormsg.c_str(), __FILE__, __LINE__);
    }
    
    if (op1.nVals != op2.nVals) {
	// error
	string errormsg = "cannot find the distance between two SUSTAINDimension with a different nVals.";
	op1.COGErrorFatal (errormsg.c_str(), __FILE__, __LINE__);
    }
    
    // calculate distance
    double sum=0.0;
    
    for (int i = 0; i < op1.nVals; i++) {
	sum += fabs(op1.dimensionRep[i] - op2.dimensionRep[i]);
    }
    
    // if type is continuous this will not be exectuted
    if (op1.nVals > 1) {
	sum /= 2.0;
    }
    
    return sum;
}

/*
double 
SUSTAINDimension::DistanceTo (const SUSTAINDimension &op2) {
    
    
    if (type != op2.type) {
	// error
	char errormsg[MAX_BUFLENGTH];
	sprintf(errormsg, "cannot find the distance between two SUSTAINDimension of a different type. %s:%d",
		 __FILE__, __LINE__);
	ERROR (errormsg);
    }
    
    if (nVals != op2.nVals) {
	// error
	char errormsg[MAX_BUFLENGTH];
	sprintf(errormsg, "cannot find the distance between two SUSTAINDimension with a different nVals. %s:%d",
		 __FILE__, __LINE__);
	ERROR (errormsg);
    }
    
    // calculate distance
    double sum=0.0;
    
    for (int i = 0; i < nVals; i++) {
	sum += fabs(dimensionRep[i] - op2.dimensionRep[i]);
    }
    
    // if type is continuous this will not be exectuted
    if (nVals > 1) {
	sum /= 2.0;
    }
    
    return sum;
}
*/

/*
double
SUSTAINDimension::operator- (const SUSTAINDimension &op2)
{
    return DistanceTo(op2);
}
*/

/*

void
SUSTAINDimension::PrintMe (void)
{

    cout << "==========================" << endl;
    cout << "type: ";
    if(type == NOMINAL) {
	cout << "NOMINAL";
    } 
    else if (type == CONTINUOUS) {
	cout << "CONTINUOUS";
    }
    cout << endl;
 
    cout << "status: ";
    if (type == KNOWN) {
	cout << "KNOWN";
    }
    else if (type == UNKNOWN) {
	cout << "UNKNOWN";
    }
    else if (type == MISSING) {
	cout << "MISSING";
    }
    cout << endl;
    
    cout << "max: " << max << endl;
    cout << "min: " << min << endl;
    cout << "nVals: " << nVals << endl;
    
    vector<double>::iterator p = dimensionRep.begin();
    vector<double>::iterator end = dimensionRep.end();
    
    while (p != end) {
	cout << *p << " ";
	p++;
    }
    cout << endl;
    
    cout << "==========================" << endl;
}
*/

SUSTAINDimension::~SUSTAINDimension ()
{
}

