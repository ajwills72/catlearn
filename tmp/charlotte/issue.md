---
  author: Lenard Dome
  title: Debugging Charlotte Edmunds' slpSUSTAIN simulation
  date: 18-09-2018
---
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

I think I figured it out.

# the main error message from st parameters

First, slpSUSTAIN, **being a state list processor, requires you to define both the first cluster and its weights** (which is on me, because I told you otherwise).
If set to NA, then each time the network is reset, a single cluster will be created,
centered on the stimulus presented on the current trial. In accord with your training
matrix,
the end of st should look something like this:

```R
st <- (...,
       w = NA,
       cluster = NA,
       colskip = 2)
```

> Your colskip was 3, but you only have 1 optional column `diff`. Colskip
> has to be set to **the number of optional column + ONE**, which is 2 in your case.

It is because the function checks the length of `w` and `cluster`,
and only then it checks if they are NA. If the values for each
dimension is NA, the temporary objects created by the function
will be filled with NAs (see [what else i found](#what-else-i-found)).
It is something to look at for later releases.

Back on track, if you don't define `cluster`, the function will not fill the first
cluster with any value and the object will be created `NULL`. So,
when the subfunction tries to calculate the stimulus distance from the the
cluster's position on **line 122** - it is the first instance where `cluster` is being
actively used, it needs a matrix instead of an empty object. And there
you get the error message:

```R
> slpSUSTAIN(st=st.all, tr=trlength[, -7], xtdo = TRUE)
  Error in matrix(0, nrow = nrow(cluster), ncol = length(unique(fac.dims))) :
  non-numeric matrix extent
```


# tr columns

You have an extra column in the end, `t`, which might be required
for other models in catlearn, but slpSUSTAIN uses 'ctrl' for indication of
supervised/unsupervised learning. So it is an optional column, which must
be placed between `ctrl` and the stimulus representation, `x1, x2, etc`. But you can leave it there and do something like this:

```R
slpSUSTAIN(st=st.all, tr=trlength[, -7], xtdo = TRUE)
```

Otherwise, you will have three dimensions for categories instead of two.

# what else i found

Assuming you have `cluster = NA` and weights as:

```R
w = matrix(rep(NA, 4), nrow = 1)
```

Then you get an error message something like:

```R
> slpSUSTAIN(st=st.all, tr=trlength[, -7], xtdo = TRUE)
  Error in if (target[fac.queried][t.queried] < 1) new.cluster <- TRUE :
  argument is of length zero
```
This means that because weights for each nominal spaces are set to NA, the output activations which are used in
calculating `target`, contain only NAs (see Eq.7 on line 132). So `NA < 1` will produce nothing, therefore
the argument length is zero. This is how i traced it back.

# end notes

It might be a good idea to look at the documentation again, to make sure
it is as straightforward as it could be, and maybe add some more stuff.
I wonder if it is possible to add more informative error messages to R
functions, although it is always an option to open an issue on Github.
