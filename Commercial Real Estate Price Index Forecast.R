library(readxl)
library(dplyr)
library(ggplot2)
library(GGally)
library(rbokeh)
library(tseries)
library(xts)
library(zoo)
library(forecast)
library(urca)
library(rmarkdown)
library(seas)
library(seasonal)
library(xlsx)
library(rio)

# Set the work directory that contains the data
setwd('C:\\Users\\Steven\\Desktop\\Economic Data')

# Read all of the files into R and designate assignments
com_real <- read_excel('GREENSTREETINDEX_UNADJ.xlsx', sheet = 2, col_names = TRUE, skip = 9)

print(com_real)

DPI <- read_excel('REALUSDPI2018_SADJ.xls', col_names = TRUE, skip = 10)

CPI <- read_excel('USCPI2018_UNADJ.xls', col_names = TRUE, skip = 10)

GDP <- read_excel('USGDP2018_SADJ.xls', col_names = TRUE, skip = 10)

INT <- read_excel('USINT2018_UNADJ.xls', col_names = TRUE, skip = 10)

MAN <- read_excel('USMAN2018_SADJ.xls', col_names = TRUE, skip = 10)

EMP <- read_excel('USUNEMP2018_SADJ.xls', col_names = TRUE, skip = 10)

# Remove columns and Rename column headers

# Market Index
str(com_real)
com_real$"All Property" <- NULL
colnames(com_real)[colnames(com_real)=="Core Sector"] <- "Market Index"
str(com_real)

# DPI
str(DPI)
colnames(DPI)[colnames(DPI)=="observation_date"] <- "Date"
colnames(DPI)[colnames(DPI)=="A229RX0Q048SBEA"] <- "DPI"
str(DPI)

# CPI
str(CPI)
colnames(CPI)[colnames(CPI)=="observation_date"] <- "Date"
colnames(CPI)[colnames(CPI)=="CPALTT01USQ657N"] <- "CPI"
str(CPI)

# GDP
str(GDP)
colnames(GDP)[colnames(GDP)=="observation_date"] <- "Date"
#colnames(GDP)[colnames(GDP)=="GDP"] <- "GDP"
str(GDP)

# INT
str(INT)
colnames(INT)[colnames(INT)=="observation_date"] <- "Date"
colnames(INT)[colnames(INT)=="FEDFUNDS"] <- "FED Interest Rate"
str(INT)

# MAN
str(MAN)
colnames(MAN)[colnames(MAN)=="observation_date"] <- "Date"
colnames(MAN)[colnames(MAN)=="IPGMFSQ"] <- "Manufacturing Index"
str(MAN)

# EMP
str(EMP)
colnames(EMP)[colnames(EMP)=="observation_date"] <- "Date"
colnames(EMP)[colnames(EMP)=="UNRATE"] <- "Unemployment Rate"
str(EMP)


# Convert all data frames to time series objects and convert monthly data to quarterly data.


# Monthly to quarterly
COMREAL_MONTHLY_TS <- ts(com_real, start=1998, frequency = 12)
COMREAL_TS <- aggregate(COMREAL_MONTHLY_TS[, "Market Index"], FUN = "mean", nfrequency=4)
str(COMREAL_TS)
print(COMREAL_TS)

DPI_TS <- ts(DPI[, "DPI"], start=c(1947, 1), frequency = 4)
str(DPI_TS)
print(DPI_TS)

CPI_TS <- ts(CPI[, "CPI"], start=c(1960,1), frequency = 4)
str(CPI_TS)
print(CPI_TS)

GDP_TS <- ts(GDP[, "GDP"], start=c(1947, 1), frequency = 4)
str(GDP_TS)
print(GDP_TS)

INT_MONTHLY_TS <- ts(INT, start=c(1954, 7), frequency = 12)
INT_TS <- aggregate(INT_MONTHLY_TS[, "FED Interest Rate"], FUN = "mean", nfrequency=4)
str(INT_TS)
print(INT_TS)

MAN_TS <- ts(MAN[, "Manufacturing Index"], start=c(1972, 1), frequency = 4)
str(MAN_TS)
print(MAN_TS)

EMP_MONTHLY_TS <- ts(EMP, start=1948, frequency = 12)
EMP_TS <- aggregate(EMP_MONTHLY_TS[, "Unemployment Rate"],FUN = "mean", nfrequency=4)
str(EMP_TS)
print(EMP_TS)


# Subset the timeseries to match the date range of the Market Index series
# Market Index series begins Q1 of 1998 and ends Q4 of 2018, but all other series only extend to 2018 Q3

COMREAL_SUB <- window(COMREAL_TS, start=c(1998,1), end=c(2018,3))
print(COMREAL_SUB)

DPI_SUB <- window(DPI_TS, start=c(1998,1), end=c(2018,3))
print(DPI_SUB)

CPI_SUB <- window(CPI_TS, start=c(1998,1), end=c(2018,3))
print(CPI_SUB)

GDP_SUB <- window(GDP_TS, start=c(1998,1), end=c(2018,3))
print(GDP_SUB)

INT_SUB <- window(INT_TS, start=c(1998,1), end=c(2018,3))
print(INT_SUB)

MAN_SUB <- window(MAN_TS, start=c(1998,1), end=c(2018,3))
print(MAN_SUB)

EMP_SUB <- window(EMP_TS, start=c(1998,1), end=c(2018,3))
print(EMP_SUB)


# Compute the seasonally adjusted times series for CPI, do not adjust FED Interest Rate

# View the decomposed timeseries 
CPI_SUB %>% decompose(type="additive") %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical Additive Decomposition
          of CPI")

# Better decomposition for economic data
CPI_SUB %>% seas(x11="") -> CPI_X11
autoplot(CPI_X11) +
  ggtitle("X11 Decomposition of CPI")

# The CPI dataset relfects a strong seasonal component that needs to be eliminated before fitting a regression model

autoplot(CPI_SUB, series="Data") +
  autolayer(trendcycle(CPI_X11), series="Trend") +
  autolayer(seasadj(CPI_X11), series="Seasonally Adjusted") +
  xlab("Year") + ylab("Consumer Price Index") +
  ggtitle("CPI Component Comparison") +
  scale_colour_manual(values=c("gray","blue","red"),
                      breaks=c("Data","Seasonally Adjusted","Trend"))

CPI_SADJ <- seasadj(CPI_X11)
print(CPI_SADJ)

# Export each dataset to a CSV file.

export(data.frame(COMREAL_SUB), "COMREAL_SUB.csv")

write.csv(data.frame(COMREAL_SUB), file = "COMREAL_SUB.csv", row.names = FALSE,
          col.names = TRUE)

# Now, all of the cleaned datasets need to be combined into a single dataset to fit the regression model

MODEL_SET <- ts.union(COMREAL_SUB, DPI_SUB, CPI_SADJ, GDP_SUB, INT_SUB, MAN_SUB, EMP_SUB)
print(MODEL_SET)

# Rename the colnames 

colnames(MODEL_SET) <- c("Markey Index", "DPI", "CPI", "GDP", "FED Interest Rate", "Manufacturing Index", "Unemployment")
colnames(MODEL_SET)
print(MODEL_SET)
str(MODEL_SET)

# View the relationship between the predictors

MODEL_SET %>%
  as.data.frame() %>%
  GGally::ggpairs()


# DF_MODEL_SET <- data.frame(MODEL_SET)
# sapply(DF_MODEL_SET, class)
# 
# typeof(DF_MODEL_SET[MAN_SUB])
# 
# summary(MODEL_SET)
# 
# print(MODEL_SET)

write.csv(data.frame(MODEL_SET), file = "MODEL_SET.csv", row.names = TRUE,
          col.names = TRUE)

FINAL_DATA <- read_excel('MODEL_SET.xlsX', col_names = TRUE)
print(FINAL_DATA)

FINAL_TS <- ts(FINAL_DATA,start=1998, frequency = 4)

print(FINAL_TS)

# Split the data for model validation (80/20 rule) 

trainData <- window(FINAL_TS, start=c(1998,1), end=c(2014, 1))
testData <- window(FINAL_TS, start=c(2014, 2), end=c(2018, 3))

# train_frame <- data.frame(trainData)

class(MODEL_SET)

ndiffs(FINAL_TS)

MODEL_STA <- diff(MODEL_SET, differences = 1)
class(MODEL_STA)

adf.test(MODEL_STA)

kpss.test(MODEL_STA)
autoplot(MODEL_STA)

class(trainData)

ndiffs(trainData)

train_diff <- diff(trainData, differences = 1)

fit1 <- tslm(COMREAL_SUB ~ DPI_SUB + GDP_SUB + INTL_SUB + MAN_SUB + EMP_SUB, data = trainData)
summary(fit1)

fit2 <- tslm(COMREAL_SUB ~ season + trend, data = trainData)
fcast2 <- forecast(fit2, h=18)
autoplot(fcast2)
accuracy()
checkresiduals(fit2)
print(testData)

checkresiduals(fit1)

fit3 <- tslm(COMREAL_SUB ~ DPI_SUB + GDP_SUB + INTL_SUB + MAN_SUB + EMP_SUB, data = train_diff)
checkresiduals(fit3)

facast3 <- forecast(fit3, h=18)



# R^2 is 0.9688, which means the model explains 96.8% of the variation in the index data

# Time plot of actual Market Index and predicted Market Index.

autoplot(trainData[, COMREAL_SUB], series="Data") +
  autolayer(fitted(fit1), series="Fitted") +
  xlab("Year") + ylab("") +
  ggtitle("Market Index Change") +
  guides(colour=guide_legend(title=" "))

# Actual Market Index plotted against fitted Market Index.

cbind(Data = MODEL_SET[,'COMREAL_SUB'],
      Fitted = fitted(fit1)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Data, y=Fitted)) +
  geom_point() +
  ylab("Fitted (fitted values)") +
  xlab("Data (actual values)") +
  ggtitle("Market Index Change") +
  geom_abline(intercept=0, slope=1)

# Produce a forecast

fcast1 <- forecast(fit1, h=18)
summary(fcast1)
class(fit1)

IndPred <- predict(fit1, testData)
class(IndPred)
print(IndPred)

Pred_frame <- data.frame(IndPred)
Pred_ts <- ts(Pred_frame, start=c(2014, 2), frequency = 4)
print(Pred_ts)



