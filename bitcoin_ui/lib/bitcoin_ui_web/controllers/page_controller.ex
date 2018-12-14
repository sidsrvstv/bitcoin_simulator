defmodule BitcoinUiWeb.PageController do
  use BitcoinUiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def test(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Application.app_dir(:bitcoin_ui, "./priv/data/balance.json")
    |> File.read!)
  end
  def anotherGraph(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Application.app_dir(:bitcoin_ui, "priv/data/random2.json")
    |> File.read!)
  end
  def chart(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Application.app_dir(:bitcoin_ui, "priv/data/transaction_time.json")
    |> File.read!)
  end

  def nonce(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Application.app_dir(:bitcoin_ui, "priv/data/nonce.json")
    |> File.read!)
  end

  def total(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Application.app_dir(:bitcoin_ui, "priv/data/tot_bitcoin.json")
    |> File.read!)
  end

  def ubal(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Application.app_dir(:bitcoin_ui, "priv/data/balance.json")
    |> File.read!)
  end
end
