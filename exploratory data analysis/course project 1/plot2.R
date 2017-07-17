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

# To generate plot 2, it is necessary to set the locale to English.
# In some systems, the default locale is not english. So, the xlabel
# will be written in other language. To avoid this, set it to english:
Sys.setlocale("LC_TIME", "English")

# The global active power is loaded as string. Convert it to numeric
power_consumption$Global_active_power <- 
    as.numeric(power_consumption$Global_active_power)

# Use the lubridate file to convert the time and add it to the date:
library(lubridate)
time <- hms(power_consumption$Time)
date_time <- power_consumption$Date + time

# Make the plot:
png("plot2.png", width=480, height=480)
plot(date_time, power_consumption$Global_active_power, type="l",
     xlab="",
     ylab="Global Active Power (kilowats)")
dev.off()