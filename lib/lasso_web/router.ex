defmodule LassoWeb.Router do
  use LassoWeb, :router
  import Plug.BasicAuth
  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "script-src 'self' 'unsafe-eval' 'unsafe-inline'; img-src 'self'"
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admins_only do
    plug :basic_auth, Application.compile_env(:lasso, :basic_auth)
  end

  scope "/", LassoWeb do
    pipe_through :browser

    get "/", PageController, :index

    delete "/admin/lasso/:uuid", LassoViewController, :delete
    post "/admin/lasso/", LassoViewController, :new

    get "/lasso/:uuid/view", LassoViewController, :show
  end

  scope "/admin" do
    pipe_through [:browser, :admins_only]
    live_dashboard "/", metrics: LassoWeb.Telemetry
  end

  # The `get` here gets flagged by Sobelow as a potential for  "CSRF via Action Reuse"
  # It does not matter if a user can trigger the post request in this scenario.
  scope "/lasso", LassoWeb do
    get "/:uuid", LassoController, :request
    put "/:uuid", LassoController, :request
    post "/:uuid", LassoController, :request
    delete "/:uuid", LassoController, :request
    patch "/:uuid", LassoController, :request
    options "/:uuid", LassoController, :request
  end
end
