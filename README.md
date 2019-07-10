# Time Series Multiple Regression in R
## Scenario-Based Multiple Regression Forecast of the U.S. Real Estate Price Index

### Background
The Commercial Property Price Index was retrieved from [Green Street Advisors](https://www.greenstreetadvisors.com/insights/CPPI) and represents the “Core Sector Weights” which includes “apartment (25%), industrial (25%), office (25%), and retail (25%)” price indexes in the data. The economic data used for the predictor variables were retrieved from the Federal Reserve Economic Data [(FRED)]( https://fred.stlouisfed.org/), The Federal Reserve Bank of St. Louis’ online database for economic datasets. The predictor variables includes Disposable Personal Income (DPI), Consumer Price Index: All Goods (CPI), Gross Domestic Product (GDP), Federal Interest Rate (FED), Industrial Manufacturing Index (MAN), and the Unemployment Rate (EMP). Each dataset has been seasonally adjusted either beforehand by the FRED, or during the modeling process. Additionally, the datasets have been subset into quarterly measures and joined into a single time series object to produce a multiple regression model. The multiple regression model is scenario-based, meaning that the model is forecasted based on predetermined economic trends. In order to forecast stable economic conditions, a random walk with drift forecast has been produced on each predictor variable up to 21 lags (data points prior to the final period of 2018 Q3). The random walk with drift forecasting method extrapolates the trend from the previous periods and projects the predicted values based on that trend. Similarly, the model uses a trend estimated from the data points recorded during 2008 recession. This negative forecast replicates the extreme effects of a real recession on the commercial real estate price index. Finally, a cross-validation method ensures the model’s accuracy measured against the test set.  


### Summary


### Methodology


### Results


### Author
