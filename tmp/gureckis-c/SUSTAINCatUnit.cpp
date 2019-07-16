/*
    SUSTAINCatUnit.cpp
    cogc++
    Created by Todd Gureckis (gureckis@love.psy.utexas.edu) on Sat Feb 19 2002.
 
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

#include "SUSTAINCatUnit.h"

SUSTAINCatUnit::SUSTAINCatUnit ()
{
    activation = 0.0;
    probability = 0.0;
}

void
SUSTAINCatUnit::SetActivation (double n)
{
    activation = n;
}

void
SUSTAINCatUnit::SetProbability (double n)
{
    probability = n;
}

double
SUSTAINCatUnit::GetActivation (void)
{
    return activation;
}

double
SUSTAINCatUnit::GetProbability (void)
{
    return probability;
}

void
SUSTAINCatUnit::SetStatus (char stat)
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

int
SUSTAINCatUnit::GetStatus (void)
{
    return status;
}

/*
void	
SUSTAINCatUnit::PrintMe (void)
{
    cout << "activation = " << activation << endl;
    cout << "probability = " << probability << endl;
    cout << "state = " << status << endl;
}
*/

SUSTAINCatUnit::~SUSTAINCatUnit ()
{
}
