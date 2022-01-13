# Changelog

## 2.0.0

### Deprecations

#### RSS now News

Removed the `Rss` module for a `News` module. The `News` module is a drop in replacement as it defaults to RSS. You can just change the following

```elixir
register_module(:top_left, Snowhite.Modules.Rss, ...)
# to
register_module(:top_left, Snowhite.Modules.News, ...)
```

It nows supports other adapter than RSS. It comes with a JSON one but you can implement the one you want for XML as an example.

## 1.1.0

### New

- Module options can now be globally defined using `configure/1` macro in Profiles. Example:

```elixir
configure(locale: "fr")

register_module(:top_left, Snowhite.Modules.Clock) # Will be french
register_module(:top_left, Snowhite.Modules.Clock, locale: "en") # Will be english
```

## 1.0.0

### Deprecations

- `Snowhite.Helpers.Decoder` has been deprecated in favor of [Starchoice](https://github.com/nicklayb/starhoice). This library is basically what the helper was giving us but from it's own package and bit better written.
