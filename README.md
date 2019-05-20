[![CircleCI](https://circleci.com/gh/vorce/lasso.svg?style=svg)](https://circleci.com/gh/vorce/lasso)

# Lasso

Inspect HTTP requests. Powered by [Phoenix](https://phoenixframework.org/) and [LiveView](https://github.com/phoenixframework/phoenix_live_view).

Try it on [https://lasso.gigalixirapp.com](https://lasso.gigalixirapp.com).

Lasso is very much inspired by [webhookinbox.com](http://webhookinbox.com/).

### A note on request headers

At the moment Lasso will display all headers it sees in the request, including ones added by things unrelated to the client making the request (such as load balancers, router etc that are infront of the deployed instance). This can be a bit confusing and something
that I'd like to improve.

## Start

- `mix deps.get`
- `cd assets && npm install && cd ..`
- `iex -S mix phx.server`
- Go to [`localhost:4000`](http://localhost:4000) in your browser
