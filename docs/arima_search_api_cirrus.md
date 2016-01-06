# Search Metrics - Cirrus API usage modeled with ARIMA

The basic premise is that once we figure out the parameters (number of terms of each component) in an [autoregressive integrated moving average (ARIMA) model](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average), the values of the terms' coefficients can be estimated daily and a prediction for the next day can be made. The models may be reassessed quarterly to see whether the number of autoregressive or moving average terms needs to be changed.

After experimenting with different ARIMA models in [the **explorer** app](https://github.com/bearloga/branch/tree/master/explorer), we decided on ARIMA(0,1,2)x(2,1,1) w/ period of 7 as the best one -- decided by [Akaike Information Criterion (AIC)](https://en.wikipedia.org/wiki/Akaike_information_criterion).

The predictions above have been backfilled. That is, we go back *n* days and fit a model using all the data up until then, and then go day by day until we get caught up with the present.
