rm(list=ls())

#################################################################
#  COURSE PROJECT 2. QUESTION 4:
# Across the United States, how have emissions from coal 
# combustion-related sources changed from 1999-2008?

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

# We only need the data about coal combustion-related sources.
# I'm assuming that when we find "Coal" or "coal" in the
# code_table$Short.Name, we also find these
# "coal combustion-related" sources.
index_coal_related <- grepl(code_table$Short.Name, pattern = "[Cc]oal")
codes_coal_related <- code_table[index_coal_related,"SCC"]
emission_data <- emission_data[emission_data$SCC %in% codes_coal_related,]

# Group total emissions per year:
sum_per_year <- tapply(emission_data$Emissions, emission_data$year, sum)

# Plot the data using the base ploting system. Change labels and set a grid.
# To show the trending, also plot the linear regression:
png("plot4.png", width=480, height=480)
plot(as.integer(names(sum_per_year)), sum_per_year, 
     xlab="Year", ylab="Total PM2.5 emissions (Tons)", 
     main="Total emissions for coal combustion-related sources",
     pch=20)
grid(NULL, NULL, lty=6, col="gray")
regression <- lm (sum_per_year ~ as.integer(names(sum_per_year)))
abline(regression, col="red")
dev.off()