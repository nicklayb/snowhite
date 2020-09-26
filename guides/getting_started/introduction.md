# Introduction

## Getting started with the template

The best way to get started with Snowhite is by using the [snowhite-template](https://github.com/nicklayb/snowhite) repository. It contains a fresh Phoenix repo but configured to use Snowhite inside.

It also includes a `rename` mix task so you can name the repo however you want.

```elixir
mix rename SomeOtherName
```

## Adding Snowhite to an existing project

If you want to add Snowhite to an existing project, there some things that needs to be configured in the first place. The following guide should guide you through this whole process.

### Creating the Snowhite module

You must create the Snowhite module with at least a default profile to get started. Either copy paste both `Snowhite.Profiles` and `Snowhite.Profiles.Default` from the template or refer to the guide to make them manually.

### Creating the routing

Open your router module, import the builder and use the macro like the following:
```elixir
defmodule MyAppWeb.Router do
  # ...
  import Snowhite, only: [snowhite_router: 1]

  # or scope it however you want
  snowhite_router(SnowhiteTemplate.Profiles)
 end
```

### Add the application supervisor

In the application file of you project, you need to reference your profile's application supervisor (the `ApplicationSupervisor` module is generated)

Example:
```elixir
defmodule SnowhiteTemplate.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: SnowhiteTemplate.PubSub},
      SnowhiteTemplateWeb.Endpoint,
      SnowhiteTemplate.Profiles.ApplicationSupervisor     # <-------
    ]

    opts = [strategy: :one_for_one, name: SnowhiteTemplate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SnowhiteTemplateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

```

### Import assets

Even though CSS is not really a requirement, we do believe that it'll get you started more easily.

In `assets/js/app.scss` add the following:
```scss
@import "../../deps/snowhite/assets/css/app.scss"
```

In `assets/js/app.js` make sure to have at least the following live view setup.

```js
import "../css/app.scss"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

liveSocket.connect()

window.liveSocket = liveSocket
```
*(There is nothing special to do here if you already setup live views)*
