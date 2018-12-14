defmodule BitcoinUiWeb.Router do
  use BitcoinUiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BitcoinUiWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/anotherGraph", PageController, :index
    get "/transactiontime", PageController, :chart
    get "/userbalance", PageController, :ubal
    get "/nonce", PageController, :nonce
    get "/total", PageController, :total
    get "/test", PageController, :index
    get "/myChart", PageController, :index
    get "/hello", PageController, :index
    get "/hello/:messenger", PageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", BitcoinUiWeb do
  #   pipe_through :api
  # end
end
