# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [dev] *SUSTAIN branch

### Added

- **slpSUSTAIN** [errors] - colskip: if it is too large, the user will get a
    more informative error ([@lenarddome](https://github.com/lenarddome))
- **slpSUSTAIN** [errors] - dimensions: if number of dimensions don't match
    up (lambda, w, cluster, or dims), receive an error message ([@lenarddome](https://github.com/lenarddome))
-  **slpSUSTAIN** [new features]  - tied activations: the model can select the
    cluster that was recruited earlier,
    or the model can select clusters with tied activations recently. See
    the documentation for slpSUSTAIN. ([@lenarddome](https://github.com/lenarddome))

### Changed

- **slpSUSTAIN** [fix] - cluster recruitment: on rare cases, the model might make the
  wrong response, and tries to recruit a cluster even though the cluster already exist.
  This has been fixed, see documentation notes. ([@lenarddome](https://github.com/lenarddome))
- **slpSUSTAIN** [fix]  - tied activations: on some cases, more than one cluster can
  have the same activations. The new default behaviour for slpSUSTAIN is to
  select one cluster randomly from those that have the same activations, but
  it can be changed by setting ties = "first" in its arguments. See documentation.
  ([@lenarddome](https://github.com/lenarddome))
- **slpSUSTAIN** [code] - code chunks: included code chunks for easier inspection

### Removed

- NONE

