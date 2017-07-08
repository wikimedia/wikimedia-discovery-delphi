# Cirrus API usage

Cirrus API is used to search for a particular term or phrase and getting back packages that contain that term in either the title *or* the page's content.

We studied multiple [autoregressive integrated moving average (ARIMA) model](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average) models using [the **explorer** app](https://github.com/bearloga/wmf-discovery-forecasting/tree/master/explorer), and settled on ARIMA(0,1,2)x(2,1,1) w/ period of 7 as the best one -- decided by [Akaike Information Criterion (AIC)](https://en.wikipedia.org/wiki/Akaike_information_criterion).

We also have two competing models:

- One that uses [Bayesian structural time series (BSTS)](https://en.wikipedia.org/wiki/Bayesian_structural_time_series), with weekly and monthly seasonalities and U.S. holiday effects.
- One that uses [Facebook's Prophet](https://facebookincubator.github.io/prophet/) forecasting procedure with weekly and yearly seasonalities.

**Note** that the "Reportupdater" annotation refers to when we switched [our data retrieval and processing codebase](https://phabricator.wikimedia.org/diffusion/WDGO/) to [Wikimedia Analytics' Reportupdater infrastructure](https://wikitech.wikimedia.org/wiki/Analytics/Reportupdater). See [T150915](https://phabricator.wikimedia.org/T150915) for more details.

<hr style="border-color: gray;">
<p style="font-size: small;">
  <strong>Link to this dashboard:</strong> <a href="https://discovery-experimental.wmflabs.org/forecast/">https://discovery-experimental.wmflabs.org/forecast/</a>
  | Page is available under <a href="https://creativecommons.org/licenses/by-sa/3.0/" title="Creative Commons Attribution-ShareAlike License">CC-BY-SA 3.0</a>
  | <a href="https://github.com/bearloga/wmf-delphi" title="Usage Forecasts Dashboard source code repository">Code</a> is licensed under <a href="https://github.com/bearloga/wmf-delphi/blob/master/LICENSE.md" title="MIT License">MIT</a>
  | Part of <a href="https://discovery-experimental.wmflabs.org/">Experimental Discovery Dashboards</a>
  | Forecasting Code available as part of <a href="https://github.com/wikimedia/wikimedia-discovery-golden" title="GitHub mirror of wikimedia/discovery/golden">this repository</a>
</p>
