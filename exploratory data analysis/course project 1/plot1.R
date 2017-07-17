rm(list=ls())

# This script considers that the zip file is in the workspace
# directory

# Unzip the zip file and load all the date
fileName = "exdata_data_household_power_consumption.zip"
unzip(zipfile = fileName, exdir = ".")
all_data <- read.table("household_power_consumption.txt", 
                       sep = ";", header = TRUE,
                       stringsAsFactors = FALSE)

# The column Date is loaded as character vector (string).
# It is necessary to convert it to Date
all_data$Date <- as.Date(all_data$Date, format = "%d/%m/%Y")

# Subset the power_consumption from 2007-02-01 to 2007-02-02 and 
# remove the variable all_data
power_consumption <- subset(all_data,
                            Date >= "2007-02-01" & Date <= "2007-02-02")
rm(all_data)

# The global active power is loaded as string. Convert it to numeric
power_consumption$Global_active_power <- 
    as.numeric(power_consumption$Global_active_power)
# Generate plot 1:
png("plot1.png", width=480, height=480)
hist(power_consumption$Global_active_power, col="red", 
     xlab="Global Active Power (kilowats)",
     ylab="Frequency",
     main = "Global Active Power")
dev.off()