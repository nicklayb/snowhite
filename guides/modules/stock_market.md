# Stock market

This module displays stock prices and changes for a day. It can work with almost any provider as long as you provide the right adapter. So far, the only provided adapter is the [Finnhub](https://finnhub.io) one.

You **need** to provide an environment variable called `FIHNNHUB_API_KEY` with you Finnhub's api key if you are planning to use the Finnhub adapter.

Stocks are polled every 5 minutes.

## Options

- `symbols`: (`[string]`, required) List of symbols you want to poll, in example: `symbols: ["AAPL", "MSFT"]` for Apple and Microsoft stocks.
- `adapter`: (`module`, optional) Adapter to use to call the stock markets, defaults to Finnhub.
- `adapter_options`: {`keyword list`, optional} If the adapter you want to use needs options, you can provide them using that option.
