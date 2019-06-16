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

    get "/lasso/:uuid/view", LassoController, :show
    post "/lasso/", LassoController, :new
  end

  scope "/lasso", LassoWeb do
    get "/:uuid", HookController, :request
    put "/:uuid", HookController, :request
    post "/:uuid", HookController, :request
    delete "/:uuid", HookController, :request
    patch "/:uuid", HookController, :request
    options "/:uuid", HookController, :request
  end

  # Other scopes may use custom stacks.
  # scope "/hooks", LassoWeb do
  #   get "/:uuid", HookController, :request
  #   put "/:uuid", HookController, :request
  #   post "/:uuid", HookController, :request
  #   delete "/:uuid", HookController, :request
  #   patch "/:uuid", HookController, :request
  #   options "/:uuid", HookController, :request
  # end
end
