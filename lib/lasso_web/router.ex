defmodule LassoWeb.Router do
  use LassoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LassoWeb do
    pipe_through :browser

    get "/", PageController, :index

    post "/lasso/", LassoController, :new
    get "/lasso/:uuid", LassoController, :show
  end

  # Other scopes may use custom stacks.
  scope "/hooks", LassoWeb do
    get "/:uuid", HookController, :get
    put "/:uuid", HookController, :put
    post "/:uuid", HookController, :post
    delete "/:uuid", HookController, :delete
    patch "/:uuid", HookController, :patch
  end
end
