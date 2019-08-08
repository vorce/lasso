defmodule LassoWeb.Router do
  use LassoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "script-src 'self' 'unsafe-eval' 'unsafe-inline'; img-src 'self'"
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LassoWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/admin", AdminController, :index

    delete "/admin/lasso/:uuid", LassoViewController, :delete
    post "/admin/lasso/", LassoViewController, :new

    get "/lasso/:uuid/view", LassoViewController, :show
  end

  scope "/lasso", LassoWeb do
    get "/:uuid", LassoController, :request
    put "/:uuid", LassoController, :request
    post "/:uuid", LassoController, :request
    delete "/:uuid", LassoController, :request
    patch "/:uuid", LassoController, :request
    options "/:uuid", LassoController, :request
  end
end
