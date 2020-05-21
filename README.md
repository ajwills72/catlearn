!!! DISCLAIMER

This is a developmental branch intended to implement Gluck and Bowers's
adaptive network extension of the LMS rule (Rescorla & Wagner, RW). Instead of
modifying the current RW implementation to deal with multiple outcomes,
which would involve some fairly significant changes to the way the function is currently
programmed, I decided to implement the Gluck and Bower adaptive LMS network
model. Modifying the current RW would essentially turn it into a connectionist
network, not unlike Gluck and Bowers LMS network. It would also involve the same
specifications and matrix operations, as already done by Gluck and Bower.

# catlearn
Formal Psychological Models of Categorization and Learning

Catlearn is an archive of formal models of categorization and
learning, plus benchmark datasets to test them against. It's also an
archive of simulations using those models. It's free and open source
software ... and always will be.

Catlearn is a package for R, and is very easy to install within that
environment. 
For a tutorial introduction to catlearn, and the Open Models
initiative more generally, see [Wills et al. (2017)](http://www.willslab.org.uk/pubs/wills2016plm.pdf).
There is also lots of information about catlearn on its  [website](https://ajwills72.github.io/catlearn).

## Installing the stable version
Make sure you're running the latest version of R and then type:

`install.packages('catlearn')`

and then

`library(catlearn)`.

## Installing the latest (unstable) version
If you're not sure what "unstable" means in this context, 
you probably want to install the **stable** version instead. If you're sure you want the unstable version, 
first install devtools and its dependencies. Then run:

`devtools::install_github("ajwills72/catlearn")`

