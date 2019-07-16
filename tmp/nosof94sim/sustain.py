#!/usr/bin/python
####
# simple SUSTAIN code (psych review version)
# programmed: July 12, 2004 
# updated: Oct. 1, 2007
# author: Todd Gureckis (gureckis@nyu.edu)
####

####
#  this code is provided to researchers interested in working
#  with SUSTAIN.  i make no claim that this code is the most efficient
#  or clear way to do things.  the primary simulation code used for
#  papers on SUSTAIN is done in C++.  This python version is just to
#  provide interested parties with a simple version of the code for
#  their own investigations.
#
#  the code doesn't provide any file input routines or any other bells and whistles.  
#  the model is just simply applied to the shepard, hovland, jenkins 
#  (1961) replication by nosofsky, et al. (1993) as reported in
#
#   Love, B.C., Medin, D.L, and Gureckis, T.M (2004) SUSTAIN: A Network Model 
#   of Category Learning.  Psychological Review, 11, 309-332.
#
#  note:
#  i use a lot of functional programming so for the uninitiated:
#  map(f, x) where x is a list, will return [f(x[0]), f(x[1]), ...]
#  so map(lambda y: y+2, x) will return [x[0]+2, x[1]+2, x[2]+2, ...]
#  it's a simple error-free way to iterate (as opposed to for loops) and is 
#  optimized in many cases by the interpreter to be fast.  the trade off
#  is that it can be conceptually bulky at times because a single line can 
#  accomplish so much.
# 

#  to run, just ./sustain.py
#  it will output mean/modal number of clusters for each problem
#  along with the final RMSError of the model compared to the human data
#  also, it will output a file 'shepard1.dat' with the learning curves
#  for all six problems for plotting

#  any questions should be addressed to todd gureckis 
#  (gureckis@love.psy.utexas.edu)
####

###########################################################
# import modules 
###########################################################

import os, sys
import math
import tempfile
from time import sleep
from fpconst import *
import string
# from Numeric import *
# from MLab import *
from numpy import *
from sets import *
from random import random, randint, shuffle

###########################################################
# defines 
###########################################################
# this is the abstract structure of the six shepard problems
# for simplicity they are just defined to be arrays instead of
# read in from a file.  note that i invert the columns of these
# matricies so that the first value in each column is always 0.
# this arbitrary mapping makes the code simpler.

		
six_problems = [ [ [0,0,0,0], # type 1
                   [0,0,1,0], 
                   [0,1,0,0], 
                   [0,1,1,0], 
                   [1,0,0,1], 
                   [1,0,1,1], 
                   [1,1,0,1], 
                   [1,1,1,1] ],
          
                 [ [0,0,0,0], # type 2
                   [0,0,1,0], 
                   [0,1,0,1], 
                   [0,1,1,1], 
                   [1,0,0,1], 
                   [1,0,1,1], 
                   [1,1,0,0], 
                   [1,1,1,0] ],

                 [ [0,0,0,0], # type 3
                   [0,0,1,0], 
                   [0,1,0,0], 
                   [0,1,1,1], 
                   [1,0,0,1], 
                   [1,0,1,0], 
                   [1,1,0,1], 
                   [1,1,1,1] ],
          
                 [ [0,0,0,0], # type 4
                   [0,0,1,0], 
                   [0,1,0,0], 
                   [0,1,1,1], 
                   [1,0,0,0], 
                   [1,0,1,1], 
                   [1,1,0,1], 
                   [1,1,1,1] ],
          
                 [ [0,0,0,0], # type 5 
                   [0,0,1,0], 
                   [0,1,0,0], 
                   [0,1,1,1], 
                   [1,0,0,1], 
                   [1,0,1,1], 
                   [1,1,0,1], 
                   [1,1,1,0] ],
          
                 [ [0,0,0,0], # type 6
                   [0,0,1,1], 
                   [0,1,0,1], 
                   [0,1,1,0], 
                   [1,0,0,1], 
                   [1,0,1,0], 
                   [1,1,0,0], 
                   [1,1,1,1] ] ]
          
six_problems_env = [ ['k','k','k','?'],
		             ['k','k','k','?'],
	                 ['k','k','k','?'],
		             ['k','k','k','?'],
		             ['k','k','k','?'],
		             ['k','k','k','?'],
		             ['k','k','k','?'],
		             ['k','k','k','?'] ]
		             
# the human data from nosofsky, et al. replication
humandata = [ [0.211, 0.025, 0.003, 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
			  [0.378, 0.156, 0.083, 0.056, 0.031, 0.027, 0.028, 0.016, 0.016, 0.008, 0., 0.002, 0.005, 0.003, 0.002, 0.],
			  [0.459, 0.286, 0.223, 0.145, 0.081, 0.078, 0.063, 0.033, 0.023, 0.016, 0.019, 0.009, 0.008, 0.013, 0.009, 0.013],
			  [0.422, 0.295, 0.222, 0.172, 0.148, 0.109, 0.089, 0.062, 0.025, 0.031, 0.019, 0.025, 0.005, 0., 0., 0.],
			  [0.472, 0.331, 0.23, 0.139, 0.106, 0.081, 0.067, 0.078, 0.048, 0.045, 0.05, 0.036, 0.031, 0.027, 0.016, 0.014],
			  [0.498, 0.341, 0.284, 0.245, 0.217, 0.192, 0.192, 0.177, 0.172, 0.128, 0.139, 0.117, 0.103, 0.098, 0.106, 0.106] ]
          
###########################################################
# SUSTAIN Class
###########################################################
class SUSTAIN:

	###########################################################
	# __init__: initializes and reset the network structure
	###########################################################
	def __init__(self, r, beta, d, threshold, learn, initalphas):
		
		self.R = r
		self.BETA = beta
		self.D = d
		self.THRESHOLD = threshold
		self.LEARN = learn
		self.LAMBDAS = initalphas
		
		self.clusters = []
		self.activations = []
		self.connections = []
		self.catunitacts = []
		self.coutputs = []
		
		self.maxValue = 0.0
		self.minValue = 0.0
		
	###########################################################
	# stimulate: present item and env for forward stimulation
	###########################################################
	def stimulate(self, item, env):
	
		itemflat = resize(item,(1,len(item)*len(item[0])))[0]
		self.maxValue = max(itemflat)
		self.minValue = min(itemflat)
		
		# this binary mask will block out queried or missing dims from the calcs
		maskhash = {'k':1,'?':0,'m':0}
		mask = array(map(lambda x:maskhash[x],env),float64)
		
		# compute distances between item and each cluster (Equation #4 in Psych Review)
		self.distances = []
		for cluster in self.clusters:
			self.distances.append(array(map(lambda x,y: sum(abs(x-y))/2.0,item, cluster),float64))
		
		# compute activation of each cluser  (Equation #5 in Psych. Review)
		lambda2r = array(mask*pow(self.LAMBDAS,self.R),float64)
		sumlambda2r = sum(lambda2r)
		self.activations = []
		for clustdist in self.distances:
			 self.activations.append(sum(lambda2r*exp(-1.0*self.LAMBDAS*clustdist))/sumlambda2r)

		# calculate output of most activated cluster after competition (Equation #6 in Psych Review)
		if len(self.activations) > 0:
			a = array(map(lambda x: pow(x, self.BETA),self.activations),float64)
			b = sum(a)
			self.coutputs = map(lambda x,y: (float(x)*float(y))/float(b), a, self.activations)
			winnerindex = self.coutputs.index(max(self.coutputs))
			# passing winner's output over connection weights (Equation #7 in Psych Review)
			self.catunitacts = array(float(self.coutputs[winnerindex])*self.connections[winnerindex],float64)
			self.catunitacts = resize(self.catunitacts,(len(item),len(item[0])))
		else:
			# set all category unit outputs to zero
			self.catunitacts = resize(array([0.,0.]),(len(item),len(item[0])))
		
		# compute output probabilities via luce choice rule (Equation #8 in Psych Review)
		a = map(lambda x: exp(self.D*x), self.catunitacts)
		b = map(lambda x: sum(x), a)
		outputprobs = array(map(lambda x,y: x/y, a, b))
		
		# compute probability of making correct response
		outputprobs = array(map(lambda x,y: x*y, outputprobs, 1.0-mask))
		outputprobsflat = resize(outputprobs,(1,len(outputprobs)*len(outputprobs[0])))[0]
		probofcorrect = max(itemflat*outputprobsflat)
		
		# generate a response 
		if random() > probofcorrect:
			response = False
		else:
			response = True
			
		return [response, probofcorrect, outputprobs, self.catunitacts, self.activations, self.distances]
	
	###########################################################
	# learn: recruits cluster and updates weights
	###########################################################
	def learn(self, item, env):
	
		if len(self.clusters) == 0:
			# create new cluster
			self.clusters.append(item)
			self.connections.append(array([0.0]*len(item)*len(item[0])))
			self.stimulate(item,env)
			winnerindex = self.activations.index(max(self.activations))
			self.adjustcluster(winnerindex, item, env)
		else:
			# is most activated cluster in the correct category? (Equation #10 in Psych Review)
			winnerindex = self.activations.index(max(self.activations))
			
			# binary "masks" again force learning only on queried dimensions
			maskhash = {'k':0,'?':1,'m':0}
			mask = array(map(lambda x:maskhash[x],env),float64)
			maskitem = map(lambda x,y: x*y, item, mask)
			maskclus = map(lambda x,y: x*y, self.clusters[winnerindex], mask)
			tmpdist = map(lambda x,y: sum(abs(x-y))/2.0,maskitem, maskclus)
		
			if (max(self.activations) < self.THRESHOLD) or (sum(tmpdist) != 0.0): # (Equation #11 in Psych Review)
				# create new cluster
				self.clusters.append(item)
				self.connections.append(array([0.0]*len(item)*len(item[0])))
				self.stimulate(item,env)
				winnerindex = self.activations.index(max(self.activations))
				self.adjustcluster(winnerindex, item, env)
				
			else:
				self.adjustcluster(winnerindex, item, env)
				
		return [self.LAMBDAS, self.connections, self.clusters]
	
	
	###########################################################
	# humbleteach: adjusts winning cluster (Equation #9 in Psych Review)
	###########################################################
	def humbleteach(self, a, m):
		if ( ((m > self.maxValue) and (a == self.maxValue)) or 
		     ((m < self.minValue) and (a == self.minValue))):
			return 0
		else:
			return a - m
			
	###########################################################
	# adjustcluster: adjusts winning cluster
	###########################################################
	def adjustcluster(self, winner, item, env):
	
		catactsflat = resize(self.catunitacts,(1,len(self.catunitacts)*len(self.catunitacts[0])))[0]
		itemflat = resize(item,(1,len(item)*len(item[0])))[0]
		
		# find connection weight errors
		deltas = map(lambda x,y: self.humbleteach(x,y), itemflat, catactsflat)
		
		# mask to only update queried dimensions (Equation #14 in Psych Review)
		maskhash = {'k':0,'?':1,'m':0}
		mask = array(map(lambda x:maskhash[x],env),float64)
		deltas = map(lambda x,y: x*y, resize(deltas,(len(item),len(item[0]))), mask)
		deltas = resize(deltas, (1,len(item)*len(item[0])))[0]
		self.connections[winner] += self.LEARN*deltas*self.coutputs[winner]
		
		# update cluster position (Equation #12 in Psych Review)
		deltas = map(lambda x,y: x-y, item, self.clusters[winner])
		self.clusters[winner] = map(lambda x,y: x+(self.LEARN*y),self.clusters[winner],deltas) 
	
		# update lambdas (Equation #13 in Psych Review)
		a = map(lambda x,y: x*y, self.distances[winner], self.LAMBDAS)
		b = map(lambda x:exp(-1.0*x), a)
		#print map(lambda x,y: self.LEARN*x*(1.0-y), b, a)
		self.LAMBDAS += map(lambda x,y: self.LEARN*x*(1.0-y), b, a)

###########################################################
# END SUSTAIN Class
###########################################################

###########################################################
# mode : really BAD function to compute the mode of a list
# DO NOT REUSE THIS ANYWHERE SINCE IT DOESNT HANDLE TIES 
# OR ANYTHING ELSE.  i suggest SciPy
###########################################################
def mode(a):
	counts = {}
	for item in a:
		counts[item]=0
	for item in a:
		counts[item]+=1
	items = [(v,k) for k,v in counts.items()]
	items.sort()
	return items[-1][1]

###########################################################
# shepard_six : function to simulate sustain in this exp.
###########################################################
def shepard_six(data, env):

	nblocks = 32
	ntimes = 10
	
	lc = resize(array([0.0]), (len(data),nblocks))

	for problem in range(len(data)):

		print "Running problem ", problem+1
		# this converts the abstract structure of the problem into
		# the representational format described on page 314 of the 
		# Love, Medin, Gureckis (2004) Psychological Review article
		s = Set([])
		maxNDimValues = max(map(lambda x: len(s.union(Set(x))), transpose(data[problem])))
		valueMap = identity(maxNDimValues).astype(float64)
		trainingitems = map(lambda x: map(lambda y: valueMap[y], x), data[problem])
	
		clusters_report = []
		avgclus = 0.0
		for times in range(ntimes):
			# initialize model structure
			model = SUSTAIN(r = 9.01245, beta = 1.252233, d = 16.924073, 
							threshold = 0.0, learn = 0.092327,
							initalphas = array([1.0]*len(data[problem][0]),float64) )	
							
			nblockscorrect = 0
			quickfinish = False
			for i in range(nblocks):
				#print "block ", i
				randepoch = range(len(trainingitems)) # shuffle items presentations
				shuffle(randepoch)
				
				nitemscorrect = 0
				
				if nblockscorrect >= 4: # if reached criterion (4 blocks in a row with 100% acc)
					quickfinish = True;
		
				for j in randepoch:
					if not quickfinish: 
						[res,prob,outunits,outacts,act,dist] = model.stimulate(trainingitems[j], env[j])
						if res == True:
							nitemscorrect += 1
						lc[problem][i] += (1.0-prob)
						[lambdas, clus, conn] = model.learn(trainingitems[j],env[j])
					else: # if reached criterion, assume 100% for the rest of experiment
						nitemscorrect += 1;
			
				if (nitemscorrect == len(randepoch)) or quickfinish:
					nblockscorrect += 1
				else:
					nblockscorrect = 0
			clusters_report.append(len(model.clusters))
		print "meanclusters[", problem+1, "] = ", mean(array(clusters_report)), ", modeclusters[", problem+1, "] = ", mode(array(clusters_report))
		#print "errorcurve[", problem, "] = " , lc[problem]/(len(trainingitems)*ntimes)
				
				
	# this is clunky but it's just to organize the data to compute RMSError
	# output total RMS Error (have to average back the data to avg. error every two blocks)
	hd = resize(humandata,(1,len(humandata)*len(humandata[0])))[0]
	avgbacklc = map(lambda x: map(mean,resize(x,(len(x)/2,2))),lc)
	md = resize(avgbacklc,(1,len(avgbacklc)*len(avgbacklc[0])))[0]
	md = map(lambda x: x/(len(trainingitems)*ntimes), md)
	print "Total RMSError = ", sqrt(sum(map(lambda x,y: pow(x-y,2.0),md,hd))/(len(md)-1))

	# output learning curves for plotting
	myfile = open('shepard1.dat', 'w')
	for i in lc:
		for j in i:
			myfile.write(str(j/(len(trainingitems)*ntimes)) + ' ')
		myfile.write('\n')
	myfile.flush()
	myfile.close()
	print "Final learning curves written to 'shepard1.dat'"
	

###########################################################
# main
###########################################################
def main():
	shepard_six(six_problems, six_problems_env)
	
###########################################################
# let's start
###########################################################

if __name__ == '__main__':
    main()
