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

png("plot4.png", width=480, height=480)
# Set the plot region to a (2,2) matrix
par(mfrow=c(2,2))

# First PLOT (top-left corner)
# The global active power is loaded as string. Convert it to numeric
power_consumption$Global_active_power <- 
            as.numeric(power_consumption$Global_active_power)

# set the locale to English.
# In some systems, the default locale is not english. So, the xlabel
# will be written in other language. To avoid this, set it to english:
Sys.setlocale("LC_TIME", "English")

# Use the lubridate file to convert the time and add it to the date:
library(lubridate)
time <- hms(power_consumption$Time)
date_time <- power_consumption$Date + time

# Make the plot:
plot(date_time, power_consumption$Global_active_power, type="l",
            xlab="",
            ylab="Global Active Power")

# Second plot: top-right corner
# Convert voltage to numeric:
voltage <- as.numeric(power_consumption$Voltage)
# Make the plot
plot(date_time, voltage, type="l",
            xlab="datetime",
            ylab="Voltage")

# Third plot: bottom-left corner
# To generate plot 3, we should convert all the sub_metering to
# numeric values (it is loaded as strings)
sm1 <- as.numeric(power_consumption$Sub_metering_1)
sm2 <- as.numeric(power_consumption$Sub_metering_2)
sm3 <- as.numeric(power_consumption$Sub_metering_3)
# First, we plot the black line (sub_metering_1)
plot(date_time, sm1, type="l", xlab="", ylab="Energy sub metering")
# Second, we add the sub_metering_2 plot with blue line
points(date_time, sm2, type="l", col="blue")
# Third, we add the sub_metering_3 plot with red line
points(date_time, sm3, type="l", col="red")
# Finally, the legend is added to the top right corner of the plot
legend("topright", col=c("black", "blue", "red"), lty=1,
            legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

# Fourth plot: bottom-right corner
reactive_power <- as.numeric(power_consumption$Global_reactive_power)
plot(date_time, reactive_power, type="l",
     xlab="datetime",
     ylab="Global_reactive_power")
dev.off()