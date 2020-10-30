# Plotting Mortgage Applications and Approval Rates Across U.S. Counties
County-level plots of U.S. mortgage applications and variables

This R code takes county-level data on the change in number of home-purchase mortgage applications and mortgage approval rates in a county and plots them on a map. The data are sourced from the Home Mortgage Disclosure Act’s (HMDA) annually released datasets. I use an intermediate version of these datasets, for years 2010 through 2015, aggregated to the county level.

In R script called “plot_mortgage_growth.R”, you can edit the following section of code to adjust which measure - approval rates or number of applications - you wish to plot, and between which years. The n_county variable represents the number of mortgage applications, and the approval_rate variable is the fraction of these applications that were originated loans (the approval rate), in percentage points.

Here, as an illustration, I plot the change in the number of mortgage applications, between the years 2010 and 2015, as used in my thesis.
