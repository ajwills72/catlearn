![catlearn logo](catlearn-logo.png)

Catlearn is an archive of formal models and simulations of categorization and associative learning in psychology. 

# Getting started

Some introductory materials on _catlearn_:

- [a 20-minute video](http://www.willslab.org.uk/vid/catlearn-intro.mp4)

- [a full-length article](http://www.willslab.org.uk/pubs/wills2016plm.pdf)

- [handouts for a half-day tutorial](http://www.willslab.org.uk/icps2017/index.html)

## Mailing list

Join the [catlearn-package](https://lists.r-forge.r-project.org/mailman/listinfo/catlearn-package) e-mail list to get occasional information on updates to the catlearn package.

## Installation

Installation instructions are [here](https://github.com/ajwills72/catlearn).

# Current contents

The latest stable version of catlearn contains the following:

## Models

### Category learning

- ALCOVE (_slpALCOVE_), see also our [description of ALCOVE](desc-alcove.pdf)

- COVIS (_slpCOVIS_)
	
- DIVA (_slpDIVA_)
	
- EXIT (_slpEXIT_)
	
- GCM (_stsimGCM_)

- SUSTAIN (_slpSUSTAIN_)

### Contingency learning
	
- Bush-Mosteller (_slpBM_)
		
- MBMF: model-based, model-free hybrid (_slpMBMF_)
	
- Rescorla-Wagner (_slpRW_)
	
	
## Simulations

Simulations of several dataset-model combinations (e.g. krus96exit is a simulation of the krus96 dataset with the slpEXIT model). In some cases:

- the optimization routines are available (functions ending _opt_). 

- functions to generate input representations for the models are separately available, to facilitate re-use (functions ending _train_).

- functions to automatically test the ordinal adequacy of the model fit are included (functions ending _oat_). These functions also produce summary output for the relevant simulation.

- functions to plot model predictions are included (functions ending _plot_).

### Inverse base-rate effect (_krus96_)

- krus96exit
	
- krus96train

### Stimulus frequency effect (_nosof88_)

- nosof88exalcove_opt
	
- nosof88oat
	
- nosof88protoalcove_opt
	
- nosof88train
	
### Type I-VI problems (_nosof94_)

- nosof94bnalcove
	
- nosof94exalcove_opt
	
- nosof94oat

- nosof95plot
	
- nosof94sustain
	
- nosof94train
	
### Category size (_shin92_)

- shin92exalcove_opt
	
- shin92oat
	
- shin92protoalcove_opt
	
- shin92train
	
## Support functions:

- act2probat (convert output model activation to a predicted rating).

# Contribute to catlearn

If you'd like to contribute to this project by adding models,
datasets, or simulations to the catlearn package,
contact the package maintainer. See also: [contributing to catlearn](intro-catlearn.pdf)

# Invite us to give a talk or workshop

The Catlearn Research Group are keen to talk about the catlearn
project to any interested party (academic or non-academic). Why not
invite us to give a talk or run a workshop where you are? We do not
charge an appearance fee, but would prefer it if you were able to
reimburse our travel expenses, including accommodation.

The Catlearn Research Group are based in the United Kingdom,
[Plymouth University](http://www.openstreetmap.org/way/42361939)

Previous talks and workshops have included:

### 2019

Andy Wills will be giving a couple of talks about catlearn in Europe in Q2.

### 2018 

**Progress in modelling through distributed collaboration**.
_Andy Wills_. 19th June 2018.
International Category Learning Symposium, Plymouth, UK.

**An introduction to the Open Models project**.
_Andy Wills_. 28th March 2018.
Associative Learning Symposium, Gregynog, Wales.

### 2017 

**An introduction to the Open Models project**.
_Andy Wills_. 27th October 2017.
School of Psychology, Cardiff University, UK. 

**A Practical Introduction to Distributed Collaboration for Formal Modeling**.
_Andy Wills and Charlotte Edmunds_, 22nd July 2017. 50th Annual Meeting of the Society for Mathematical Psychology, University of Warwick, UK.

**Progress in learning theory through distribute collaboration**. _Andy Wills_, 11th April 2017. Associative Learning Symposium, Gregynog, Wales.

**A Practical Introduction to Distributed Collaboration for Formal Modeling**.
_Andy Wills_, 23rd March 2017. International Convention of Psychological Science, Vienna, Austria.

**Progress in modelling through distributed collaboration**. _Andy Wills_, Jan 2017. Experimental Psychology Society, London, UK.

**Introduction to catlearn**. _Andy Wills_. 26th Jan 2017. School of Psychology, Plymouth University, UK.

# Roadmap

The current plan for version 0.7 is:

- New functions:

	- slpATRIUM (Inkster, Schlegelmilch)

	- slpMack75 (Dome)
	
	- Datasets and simulations (Dome, Spicer, Wills)

- Enhanced functions:

	- slpSUSTAIN (Dome)
	
	- slpEXIT (Inkster, Schlegelmlich, Wills)

Further plans currently seeking a developer include: 

- Models: Actor-critic, Esber-Haselgrove, McLaren-Mackintosh, PMEGCM-RT, Rational Model, SAMBA, Temporal-difference model

- Re-implement in C/C++ for speed: slpDIVA, slpMBMF

## Timetable

Contributors should provide their working, tested, Rd-documented code by **1st September 2019** if it is to be included in version 0.7.

We aim to release version 0.7 to CRAN by _30th September 2019_. 

# History

Dates of CRAN releases, along with email-list announcements:

- Version 0.6 ("Fried chicken")

	- 2019-02-18: Version 0.6.1 [announcement](announce/version-0.6.1-email.txt).

	- 2018-07-17: Version 0.6 [announcement](announce/version-0.6-email.txt).

- Version 0.5 ("Excellent bacon") 

	- 2017-12-11: [announcement](announce/version-0.5-email.txt).
	
- Version 0.4 ("Dinky doughnut")

	- 2017-02-23: [announcement](announce/version-0.4-email.txt).

- Version 0.3 ("Cream cake") 

	- 2016-08-18: [announcement](announce/version-0.3-email.txt).

# References

- Wills, A.J., & Pothos, E.M. (2012). On the adequacy of currennt empirical evaluations of formal models of categorization. _Psychological Bulletin, 138,_ 102-125.

- Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster, A.B.(2017). Progress in modeling through distributed collaboration: Concepts, tools, and category-learning examples.  _The Psychology of Learning and Motivation_.

# Credits

The catlearn logo image credit: Elouise Wills. 
<a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/80x15.png" /></a>




