rm(list=ls())

#################################################################
#  COURSE PROJECT 2. QUESTION 3:
# Of the four types of sources indicated by the type (point, 
# nonpoint, onroad, nonroad) variable, which of these four sources 
# have seen decreases in emissions from 1999-2008 for 
# Baltimore City? Which have seen increases in emissions from 
# 1999-2008? Use the ggplot2 plotting system to make a plot answer
# this question.

# Download the file and unzip it to the working directory
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
download.file(url, destfile = "./pm25.zip", method="curl")
fileName = "pm25.zip"
unzip(zipfile = fileName, exdir = ".")

# There are two RDS files. One with the data (emission_data) and
# the other with the code table
emission_data <- readRDS("summarySCC_PM25.rds")
code_table <- readRDS("Source_Classification_Code.rds")

# Note: Columns of emission_data
# fips - A five-digit number (represented as a string) indicating the U.S. 
#        county
# SCC - The name of the source as indicated by a digit string (see source 
#       code classification table)
# Pollutant - A string indicating the pollutant
# Emissions - Amount of PM2.5 emitted, in tons
# type - The type of source (point, non-point, on-road, or non-road)
# year - The year of emissions recorded

# We only need information about fips == "24510".
# So, let's subset the original data:
emission_data <- subset(x = emission_data, fips == "24510")

# With ggplot, it is possible to answer the question builing a plot
# with four subsets (non-roud, nonpoint, on-road, point). And in each point,
# sum all the emissions.
#
# With the emission_data, set an aesthetic where x = year, y = Emissions.
# Fill the colors using the year (in each subplot, the same color shows the
# same year).
# Use geom_bar to sum all emissions per year. Note: geom_point() shows all
# the points for a given year. We want here a bar plot, like a histogram
# The facet is necessary to subset the groups
library(ggplot2)
png("plot3.png", width=480, height=480)
ggplot(emission_data, aes(x = factor(year), y = Emissions, fill=factor(year)))+
    geom_bar(stat="identity") + # Sum all emisssions per year
    guides(fill=FALSE) + # Remove legend
    facet_grid(.~type) + # Subset by type
    xlab("Year") + # X label
    ylab("Total emissions (Tons)") # Y label
dev.off()