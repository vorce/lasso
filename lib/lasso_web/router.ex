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
    resources "/:uuid", HookController
  end
end
