# RSS

The RSS feed is a handy way to get your local news right on your mirror. One feature that is even more handy within the feeds is the phone accessible QR code that you can show beside your news.

*Note: Reading the QR from your phone might be harder as QRs are quite close. If your having difficulties, check your phone's app store if it has an app that let's you scan multiple QR at once.*

Feeds are fetched by the Server every 15 minutes (not configurable at the moment but we nice to have the capabilities). The server then notifies the views and it gets updated. A cycling of the visible news occurs every 25 seconds (yet not configurable yet).

## QR Codes

Depending on your monitor, large url's QR code might create pixelated QR code and make them hard to read. That's why we provided a URL shortener so it creates smaller QR codes.

### The thing with short ULRs

At the moment, the easiest way I wound to support url shortening is by using url shortening module (by default [Bitly](https://bitly.com)). However, free plans only allow for 1000 url to be generated per month. While it's enough for my usage, it might not be for you.

So help me to help you, if you use another server for url shortening that you would like Snowhite to support, feel free to open an issue on [Snowhite's repo](https://github.com/nicklayb/snowhite/issues) and we'll do our best to support it. You can even make a PR if you feel comfortable enough.

## Options

- `feeds`: (`[feed]`, required) List of RSS feeds to fetch
  - `feed`: A tuple `{name, feed_url}`.
- `persist_app`: (`atom`, required) Your app's atom name. This is required so the dets can be persisted. If your project is called `MyAwesomeProject`, then the atom name should be `my_awesome_project` and the dets will be persisted in the app's privs.
- `visible_news`: (`integer`, optional) Sets the number of news to be visible on the page; fallbacks to `3`
- `qr_codes`: (`boolean`, optional) Flags to toggle the use of QR codes; fallbacks to `true`
- `short_link`: (`boolean`, optional) Flags to toggle the shortening of the urls; fallbacks to `true`

## Server

As QR generation quite greedy, the server holds instances of `RssItem` of the every rss feed item with QR codes already generated. They are simply displayed as SVG in the page.

### Another url shortener

In case you have a different way to shorten your URLs, you can implement the `Snowhite.Modules.Rss.UrlShortener` behaviour and provide your own implementation through the following config

```elixir
config :snowhite, Snowhite.Modules.Rss.UrlShortener, url_shortener: MyApp.MyShortener
```
