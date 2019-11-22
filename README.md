[![Github actions CI](https://github.com/vorce/lasso/workflows/Elixir%20CI/badge.svg)](https://github.com/vorce/lasso/actions) [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=vorce/lasso)](https://dependabot.com)

# Lasso

<img src="assets/static/images/lasso.svg" width="100" height="100" alt="Lasso logo" align="right" />

Inspect HTTP requests. Powered by [Phoenix](https://phoenixframework.org/) and [LiveView](https://github.com/phoenixframework/phoenix_live_view).

**Try it on [https://lasso.gigalixirapp.com](https://lasso.gigalixirapp.com)**.

### Thank you

- [webhookinbox.com](http://webhookinbox.com/) - inspiration for the whole project
- [ikonate](https://ikonate.com/) - beautiful svg icons

### A note on request headers

At the moment Lasso will display all headers it sees in the request, including ones added by things unrelated to the client making the request (such as load balancers, router etc that are infront of the deployed instance). This can be a bit confusing and something
that I'd like to improve.

## Start locally

- `mix deps.get`
- `cd assets && npm install && cd ..`
- `ADMIN_PASSWORD=foo iex -S mix phx.server`
- Go to [`localhost:4000`](http://localhost:4000) in your browser

### Admin area

There is a minimal admin page where you can see some stats about current lassos on [/admin](http://localhost:4000/admin). This page is protected by basic auth, the credentials can be configured in `config.exs`. By default the password is read from the environment variable `ADMIN_PASSWORD`.

## Building a release

Yay for [releases](https://hexdocs.pm/mix/Mix.Tasks.Release.html) in Elixir 1.9.
Phoenix has some [additional docs](https://github.com/phoenixframework/phoenix/blob/master/guides/deployment/releases.md) for being deployed in a release.

```bash
export SECRET_KEY_BASE=...
APP_NAME=lasso MIX_ENV=prod SECRET_SALT=... mix release
_build/prod/rel/lasso/bin/lasso start
```
