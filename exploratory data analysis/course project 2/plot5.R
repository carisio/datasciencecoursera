rm(list=ls())

#################################################################
#  COURSE PROJECT 2. QUESTION 5:
# How have emissions from motor vehicle sources changed from 
# 1999-2008 in Baltimore City?

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

# Select only the data about motor vehicle source.
# I'm assuming that this is all the SSC codes with 
# "vehicle" in the SSC.Level.Two column
index_motor_veh_related <- grepl(code_table$SCC.Level.Two, 
        pattern = "vehicle", ignore.case = T)
motor_veh_related <- code_table[index_motor_veh_related,"SCC"]
emission_data <- emission_data[emission_data$SCC %in% motor_veh_related,]

# Group total emissions per year:
sum_per_year <- tapply(emission_data$Emissions, emission_data$year, sum)

# Plot the data using the base ploting system. Change labels and set a grid.
# To show the trending, also plot the linear regression:
png("plot5.png", width=480, height=480)
plot(as.integer(names(sum_per_year)), sum_per_year, 
     xlab="Year", ylab="Total PM2.5 emissions (Tons)", 
     main="Total emissions for motor vehicle sources in Baltmore City",
     pch=20)
grid(NULL, NULL, lty=6, col="gray")
regression <- lm (sum_per_year ~ as.integer(names(sum_per_year)))
abline(regression, col="red")
dev.off()