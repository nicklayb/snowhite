ASSETS_FOLDER=assets

.PHONY: dev
dev:
	iex -S mix run dev.exs

.PHONY: deps
deps: mix-deps nodejs-deps

.PHONY: mix-deps
mix-deps:
	mix deps.get

.PHONY: nodejs-deps
nodejs-deps:
	npm install --prefix $(ASSETS_FOLDER)

.PHONY: secret
secret:
	mix phx.gen.secret 64

.PHONY: test
test:
	mix test
