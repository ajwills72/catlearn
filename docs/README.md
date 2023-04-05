![catlearn logo](catlearn-logo.png)

[![](https://cranlogs.r-pkg.org/badges/grand-total/catlearn)](https://cran.r-project.org/package=catlearn)

Catlearn is an archive of formal models of categorization and associative learning in psychology. 

# Getting started

Some introductory materials on _catlearn_:

- [a 20-minute video](http://www.willslab.org.uk/vid/catlearn-intro.mp4)

- [a full-length article](http://www.willslab.org.uk/pubs/wills2016plm.pdf)

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

- DGCM (_slpDGCM_)

- DIVA (_slpDIVA_)

- EXIT and two 'dissected' versions thereof (_slpEXIT_, _slpNNCAG_ and _slpNNRAS_)

- GCM (_stsimGCM_)

- SUSTAIN (_slpSUSTAIN_)

### Contingency learning

- Bush-Mosteller (_slpBM_)

- Gluck & Bower (1988) (_slpLMSnet_)

- MBMF: model-based, model-free hybrid (_slpMBMF_)

- Mackintosh (1975) (_slpMack75_)

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

- nosof88exalcove

- nosof88exalcove_opt

- nosof88oat

- nosof88protoalcove

- nosof88protoalcove_opt

- nosof88train

### Type I-VI problems (_nosof94_)

- nosof94bnalcove

- nosof94exalcove

- nosof94exalcove_opt

- nosof94oat

- nosof95plot

- nosof94sustain

- nosof94train

### Category size (_shin92_)

- shin92exalcove

- shin92exalcove_opt

- shin92oat

- shin92protoalcove

- shin92protoalcove_opt

- shin92train

## Support functions

- act2probrat (convert output model activation to a predicted rating).

- convertSUSTAIN (convert nominal-dimension input representation to a 'padded' format)

- medin87train (input representation of Exp. 1 of Medin et al., 1987)

# Contribute to catlearn

If you'd like to contribute to this project by adding models,
datasets, or simulations to the catlearn package,
contact Andy Wills.

# Invite us to give a talk or workshop

The Catlearn Research Group are keen to talk about the catlearn project to any
interested party (academic or non-academic). Why not invite us to give a talk
or run a workshop where you are? We do not charge an appearance fee, but if you
would like us to be physically present (at an appropriate social distance), we
would prefer it if you were able to reimburse our travel expenses, including
accommodation.

The Catlearn Research Group are based in the United Kingdom,
[Plymouth University](http://www.openstreetmap.org/way/42361939)


# Roadmap

We aim to release version 1.1 to CRAN by 26th March 2024.

Contributions of working, tested, Rd-documented code are welcome for consideration at any time. Where code is ready for inclusion into catlearn, it will first be released to the community as an unstable point release of catlearn on github. On 12th March 2024, the latest unstable release on github will be used to check and build stable version 1.1 for release to CRAN. 

# History

Dates of CRAN releases, along with email-list announcements (from 0.7.2, see
[CHANGELOG](CHANGELOG.md) for more detail of changes):

- Version 1.1.x. ("Krispy Kreme") _future_

- Version 1.0.x ("Juicy Jam") _CURRENT_

  - 2023-04-04: Version 1.0. **stable release** on its way to CRAN. [announcement](announce/version-1.0-email.txt).

- Version 0.9.x ("Incredible Icing")

  - 2022-10-06: Version 0.9.3. Add slpDGCM - implementation of the similarity-dissimilarity generalized context model of Stewart & Morin (2007), and the variant used by O'Bryan et al. (2018).

  - 2022-09-22: Version 0.9.2. Enhancement to slpSUSTAIN: add probability of item being reported as 'old'.

  - 2022-03-28: Version 0.9.1. stable release on CRAN. [announcement](announce/version-0.9-email.txt).

  - 2022-03-25: Version 0.9 - Release to CRAN subsequently discovered to generate a warning when compiled with clang 14 on linux.

- Version 0.8.x ("Harmonious honey")

  - 2022-01-18: Version 0.8.3: edge-case installation bug fix (see changelog)

  - 2022-01-10: Version 0.8.2:  slpLMSnet documentation improvements, plus addition of ratio-rule response function as an option.

  - 2022-01-05: Version 0.8.1: slpNNCAG and slpNNRAS added, implements Models 4 and 5 from Paskewitz & Jones (2020).

  - 2020-09-16: Version 0.8: stable release on CRAN. [announcement](announce/version-0.8-email.txt).

- Version 0.7.x ("Gooey chocolate")

  - 2020-08-06: Version 0.7.5: slpLMSnet added, implements Gluck & Bower (1988).

  - 2020-07-01: Version 0.7.4: fix for slpSUSTAIN bug introduced in 0.7.2.

  - 2020-05-15: Version 0.7.3: slpALCOVE upgraded to include some checks for user errors in model specification.

  - 2020-05-13: Version 0.7.2: slpSUSTAIN upgraded to: (a) improve implementation of cluster recruitment in edge cases not covered in Love et al. (2004), and (b) add basic checking of common user errors.

  - 2019-10-10: Version 0.7.1: Stable release on CRAN. [announcement](announce/version-0.7.1-email.txt).

- Version 0.6.x ("Fried chicken")

  - 2019-10-03: Version 0.6.5: slpSUSTAIN uprgaded to include unsupervised category learning.

  - 2019-10-02: Version 0.6.4: slpMack75 added.

  - 2019-05-23: Version 0.6.3: slpEXIT converted to C++ for speed.

  - 2019-03-18: Version 0.6.2: Minor patch so packages tests work on R 3.6.0.

  - 2019-02-18: Version 0.6.1: Stable release on CRAN. Minor maintenance release.  [announcement](announce/version-0.6.1-email.txt).

  - 2018-07-17: Version 0.6: Stable release on CRAN. slpEXIT and slpSUSTAIN added.  [announcement](announce/version-0.6-email.txt).

- Version 0.5 ("Excellent bacon")

  - 2017-12-11: Stable release on CRAN [announcement](announce/version-0.5-email.txt).

- Version 0.4 ("Dinky doughnut")

  - 2017-02-23: Stable release on CRAN [announcement](announce/version-0.4-email.txt).

- Version 0.3 ("Cream cake")

  - 2016-08-18: Stable release on CRAN [announcement](announce/version-0.3-email.txt).

- Versions 0.1, 0.2 (not named)

  - These were internal development versions, never publicly released.

# References

- Wills, A.J., & Pothos, E.M. (2012). On the adequacy of currennt empirical evaluations of formal models of categorization. _Psychological Bulletin, 138,_ 102-125.

- Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster, A.B.(2017). Progress in modeling through distributed collaboration: Concepts, tools, and category-learning examples.  _The Psychology of Learning and Motivation_.

# Credits

The catlearn logo image credit: Elouise Wills. 
<a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/80x15.png" /></a>




