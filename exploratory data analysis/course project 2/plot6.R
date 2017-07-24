rm(list=ls())

#################################################################
#  COURSE PROJECT 2. QUESTION 6:
# Compare emissions from motor vehicle sources in Baltimore City
# with emissions from motor vehicle sources in Los Angeles County,
# California (fips == "06037"). Which city has seen greater 
# changes over time in motor vehicle emissions?

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

# We need to use the fips == "24510" (Baltimore) and 
# fips == "06037" (Los Angeles):
emission_data_bm <- subset(x = emission_data, fips == "24510")
emission_data_la <- subset(x = emission_data, fips == "06037")

# Select only the data about motor vehicle source.
# I'm assuming that this is all the SSC codes with 
# "vehicle" in the SSC.Level.Two column
index_motor_veh_related <- grepl(code_table$SCC.Level.Two, 
    pattern = "vehicle", ignore.case = T)
motor_veh_related <- code_table[index_motor_veh_related,"SCC"]
emission_data_bm <- emission_data_bm[emission_data_bm$SCC %in% motor_veh_related,]
emission_data_la <- emission_data_la[emission_data_la$SCC %in% motor_veh_related,]

# Group total emissions per year:
sum_per_year_bm <- tapply(emission_data_bm$Emissions, emission_data_bm$year, sum)
sum_per_year_la <- tapply(emission_data_la$Emissions, emission_data_la$year, sum)

# Plot the data using the base ploting system. Change labels and set a grid.
# To show the trending, also plot the linear regression:
png("plot6.png", width=480, height=480)
plot(as.integer(names(sum_per_year_bm)), sum_per_year_bm, 
     ylim = range(sum_per_year_bm, sum_per_year_la),
     xlab="Year", ylab="Total PM2.5 emissions (Tons)", 
     main="Total emissions for motor vehicle sources in Baltmore City",
     pch=20)
points(as.integer(names(sum_per_year_la)), sum_per_year_la, pch=15)
legend(x=1999, y=4300, legend = c("Baltimore", "Los Angeles"), pch=c(20,15))
grid(NULL, NULL, lty=6, col="gray")
regression <- lm (sum_per_year_bm ~ as.integer(names(sum_per_year_bm)))
abline(regression, col="red")
regression <- lm (sum_per_year_la ~ as.integer(names(sum_per_year_la)))
abline(regression, col="red")
dev.off()