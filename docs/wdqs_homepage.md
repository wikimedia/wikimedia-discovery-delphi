# Wikidata Query Service homepage traffic

The WDQS homepage ([query.wikidata.org](https://query.wikidata.org/)) is the best way to use WDQS. It includes examples and a host of other user-friendly features.

We studied multiple [autoregressive integrated moving average (ARIMA) model](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average) models using [the **explorer** app](https://github.com/bearloga/wmf-discovery-forecasting/tree/master/explorer), and settled on ARIMA(1,1,2)x(1,1,0) w/ period of 7 as the best one -- decided by [Akaike Information Criterion (AIC)](https://en.wikipedia.org/wiki/Akaike_information_criterion).

We also have a competing model that uses [Bayesian structural time series (BSTS)](https://en.wikipedia.org/wiki/Bayesian_structural_time_series), with weekly and monthly seasonalities and U.S. holiday effects.

**Note** that the "Reportupdater" annotation refers to when we switched [our data retrieval and processing codebase](https://phabricator.wikimedia.org/diffusion/WDGO/) to [Wikimedia Analytics' Reportupdater infrastructure](https://wikitech.wikimedia.org/wiki/Analytics/Reportupdater). See [T150915](https://phabricator.wikimedia.org/T150915) for more details.
