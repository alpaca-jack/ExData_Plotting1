#To run script, type "source("plot4.R")" in console

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
                   na.strings="NA")
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

#Plot 4
png(filename = "plot4.png", width = 480, height = 480)
par(mfrow = c(2,2))
with(Data_clean, {
    plot(Data_clean$DateTime, Data_clean$Global_active_power,
         type = "l",
         xlab = "",
         ylab = "Global Active Power")
    plot(Data_clean$DateTime, Voltage,
         type = "l",
         xlab = "datetime",
         ylab = "Voltage")
    with(Data_clean, plot(DateTime, Sub_metering_1,
                          col = "black",
                          type = "n",
                          xlab = "",
                          ylab = "Energy sub metering"))
        with(Data_clean, points(DateTime, Sub_metering_1, col="black", type = "l"))
        with(Data_clean, points(DateTime, Sub_metering_2, col="red", type = "l"))
        with(Data_clean, points(DateTime, Sub_metering_3, col="blue", type = "l"))
        sub_col_names <- names(Data_clean)[6:8]
        legend("topright", lty=1, col = c("black", "red", "blue"), legend = sub_col_names, bty = "n")
    plot(Data_clean$DateTime, Data_clean$Global_reactive_power,
         type = "l",
         xlab = "datetime",
         ylab = "Global_reactive_power")
})
dev.off()