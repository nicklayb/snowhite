ASSETS_FOLDER=assets

.PHONY: dev
dev:
	iex -S mix phx.server

.PHONY: deps
deps: mix-deps nodejs-deps

.PHONY: mix-deps
mix-deps:
	mix deps.get

.PHONY: nodejs-deps
nodejs-deps:
	npm install --prefix $(ASSETS_FOLDER)

secret:
	mix phx.gen.secret 64
