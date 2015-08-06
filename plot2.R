#To run script, type "source("plot2.R")" in console

#Housekeeping
rm(list=ls())
#install.packages("data.table") #uncomment if you do not have data.table installed

#Check for data, download if necessary
if("household_power_consumption.txt" %in% dir() == FALSE){
    fileUrl<- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
    download.file(fileUrl, destfile = "ElectricPowerConsuption.zip", method = "curl") #method not necessary in Windows
    unzip("ElectricPowerConsuption.zip")
}

#Read in data, subset for Feb 1&2, 2007, combine
library(data.table)
ElecFread <- fread("household_power_consumption.txt", 
                   sep=";", 
                   nrows=2075259, 
                   header="auto", 
                   na.strings="NA",
                   colClasses="character")
ElecFreadFeb1 <- ElecFread[Date == "1/2/2007"]
ElecFreadFeb2 <- ElecFread[Date == "2/2/2007"]
Feb_data <- rbind(ElecFreadFeb1, ElecFreadFeb2)

#Format Date/Time object
DateTime <- as.POSIXct(paste(Feb_data$Date, Feb_data$Time), format= "%d/%m/%Y %H:%M:%S")

#Subset measures data, remove "?"'s, make columns numeric
keeps<- subset(Feb_data, select = -c(1,2))
keeps[keeps == "\\?"] <-NA
numeric_keeps <- transform(keeps, Global_active_power = as.numeric(Global_active_power),
                    Global_reactive_power = as.numeric(Global_reactive_power),
                    Voltage = as.numeric(Voltage),
                    Global_intensity = as.numeric(Global_intensity),
                    Sub_metering_1 = as.numeric(Sub_metering_1),
                    Sub_metering_2 = as.numeric(Sub_metering_2),  
                    Sub_metering_3 = as.numeric(Sub_metering_3))

#Cleaned data combined
Data_clean <- cbind(DateTime, numeric_keeps)

#Plot2
png(filename = "plot2.png", width = 480, height = 480)
plot(Data_clean$DateTime, Data_clean$Global_active_power,
     type = "l",
     xlab = "",
     ylab = "Global Active Power (kilowatts)")
dev.off()