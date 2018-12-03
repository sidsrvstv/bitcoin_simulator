defmodule BitcoinSimulator do
  @moduledoc """
  BitcoinSimulator
  """

  @doc """
  parse inputs - check if users entered are integer
  """
  def main do
    total_users = System.argv()
    if is_integer(total_users) do
      total_users
      |> launch_network()
    else
      IO.puts "Number of users should be integer"
    end

  end

  @doc """
  generate public, private keys for all users
  launch users with alias as public key
  store all public keys in a list
  """
  def launch_network(n) do
    public_keys = for i <- 1..n do
      wallet = Wallet.init
      pub_key = Map.fetch!(wallet, :pub_key)
      priv_key = Map.fetch!(wallet, :priv_key)
      User.start_link({pub_key, priv_key})
      pub_key
    end

  end

end

BitcoinSimulator.main
