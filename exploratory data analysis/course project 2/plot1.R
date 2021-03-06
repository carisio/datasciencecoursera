rm(list=ls())
#################################################################
#  COURSE PROJECT 2. QUESTION 1:
# Have total emissions from PM2.5 decreased in the United States 
# from 1999 to 2008? Using the base plotting system, make a plot
# showing the total PM2.5 emission from all sources for each of
# the years 1999, 2002, 2005, and 2008.

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

# To answer question, we need to sum all the emissions per year
# The tapply function can be used to apply the function sum in the
# emission_data$Emissions, using the emission_data$year as group types:
sum_per_year <- tapply(emission_data$Emissions, emission_data$year, sum)

# Plot the data using the base ploting system. Change labels and set a grid.
# To show the trending, also plot the linear regression:
png("plot1.png", width=480, height=480)
plot(as.integer(names(sum_per_year)), sum_per_year, 
     xlab="Year", ylab="Total PM2.5 emissions (Tons)", 
     main="Total emissions in the U.S.",
     pch=20)
grid(NULL, NULL, lty=6, col="gray")
regression <- lm (sum_per_year ~ as.integer(names(sum_per_year)))
abline(regression, col="red")
dev.off()