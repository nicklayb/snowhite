# Changelog

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
