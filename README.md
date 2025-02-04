#R

This directory contains R code for fitting earthquake occurrence models to paleo-earthquake data. The package R2JAGS is used to fit the models using Bayesian MCMC methods.

Models that attempt to fit real paleo-earthquake data are in the sub-directory models. These include the JAGS models with filenames of the form `invgauss_<name>.jags` which contain the model structure. Files of the form `fit_invgauss_<name>.R` are used to pass data to the `.jags` model, call it and produce some basic plots of the outputs.

Additional plots summarising model outputs are made using the scripts `plot_density_<name>.R` and `plot_posterior_multiple_<name>.R`. 

This code support the following publication:
Griffin, J.D., Wang, T., Stirling, M.W. and Gerstenberger, M.C. 2025. Forecasting recurrent large earthquakes from paleoearthquake and fault displacement data. *Journal of Geophysical Research: Solid Earth 130*, e2024JB029671. [https://doi.org/10.1029/2024JB029671] (https://doi.org/10.1029/2024JB029671)