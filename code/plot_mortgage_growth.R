# This script plots county level changes in mortgage approval rates and number
# of applications between two years. An accompanying file called "map.html"
# walks through each section of the code and how it can be used in different
# ways


# clear environment
rm(list = ls())

# Inputs ------------------------------------------------------------------

VAR = "n_county" 
YEARS = c(2010, 2015)
 
# Setup -------------------------------------------------------------------

# set working directory
setwd("~/Dropbox/Thesis/Code Sample/") 

# Load required packages
install.packages("pacman")
library(pacman)
p_load(tidyverse, stringr, rgdal, ggthemes, glue, socviz)

# Load Data ---------------------------------------------------------------

# Load County FIPS codes
fips <- read.table(file="input/national_county.csv",
                   sep=",", quote = "",
                   colClasses = c("character","character","character",
                                  "character","factor"),
                   col.names = c("state_abbr","fips1","fips2",
                                 "county_name","class.code"))

# concatenate to single fips code
fips$fips <- as.numeric(paste0(fips$fips1, fips$fips2))

# load county level mortgage data
load("input/county_data.rda")

# filter to relevant years
data <- county_data %>% 
  filter(as_of_year %in% YEARS)

# get column position of variable of interest
var_pos = match(VAR, colnames(county_data))

# Calculate rate of change
change <- data %>% 
  group_by(fips) %>% 
  arrange(as_of_year) %>% 
  rename(variable = var_pos) %>% 
  filter(!(variable == 0 & as_of_year == min(YEARS))) %>% 
  summarize(
    change_rate = (last(variable, order_by = as_of_year) -
                          first(variable, order_by = as_of_year)) / 
      first(variable, order_by = as_of_year)
    ) %>% 
  ungroup()

change$change_rate = change$change_rate * 100

# filter out outliers (1st and 100 percentiles)
change <- change %>% 
  filter(ntile(change_rate, 100) <= 99 & ntile(change_rate, 100) >= 1)


# Map ---------------------------------------------------------------------

# create discrete intervals for mapping based on 8 equally weighted groups
change.qt <- quantile(change$change_rate, 
                    probs = seq(0, 1, .125))

# adjust rounding interval based on standard deviation
interval = ifelse(sd(change$change_rate, na.rm = T) <= 20, 2, 5)

# round group limits
change.qt <- floor(change.qt / interval) * interval

# create labels for the discrete groups
labels <- c()

for (i in 1:(length(change.qt) - 1)) {
  
  if (i == 1) {
    
    labels[i] <- glue("< {change.qt[[i+1]]}")
    
  } else if (i == length(change.qt) - 1) {
    
    labels[i] <- glue("> {change.qt[[i]]}")
    
  } else {
    
  labels[i] <- glue("{change.qt[[i]]} - {change.qt[[i+1]]}")
  
  }
}

# "cut" data into discrete groups
change$change_ntiles <- cut(change$change_rate,
                               breaks = change.qt,
                               include.lowest = T)

# merge variable of interest with county-level shape file from socviz.co
county_full <- county_map %>% 
  mutate(id = as.numeric(id)) %>% 
  left_join(change, by = c("id" = "fips"))

# plot the map
p <- ggplot(data = county_full,
            mapping = aes(x = long, y = lat,
                          fill = change_ntiles, 
                          group = group))

p1 <- p + geom_polygon(color = "gray70", size = 0.05) +
  coord_equal()

p2 <- p1 + scale_fill_brewer(palette="Blues",
                             labels = labels)

p2 + theme_map() +
  guides(fill = guide_legend(nrow = 1, keywidth = 2,
                             keyheight = 2)) + 
  theme(legend.text=element_text(size = 12),
        legend.position = "bottom") +
  labs(fill = "")

# export as png
ggsave(glue("output/county_map_{VAR}_{YEARS[1]} to {YEARS[2]}.png"),
       width = 14, height = 10)
