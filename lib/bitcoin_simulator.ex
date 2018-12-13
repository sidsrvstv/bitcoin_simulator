defmodule BitcoinSimulator do
  @moduledoc """
  BitcoinSimulator
  """

  @doc """
  parse inputs - check if users entered are integer
  """
  def main do
    total_users = System.argv()
    case total_users do
      [n, x] -> create_users(n,x)
      _ -> IO.puts "Wrong arguments"
    end
  end

  @doc """
  generate public, private keys for all users
  launch users with alias as public key
  store all public keys in a list
  create empty transactions for miners to mine and introduce bitcoin in system
  """
  def create_users(users, number_txn) do
    n = String.to_integer(users)
    public_keys = for _ <- 1..n do
      wallet = Wallet.init
      pub_key = Map.fetch!(wallet, :pub_key)
      priv_key = Map.fetch!(wallet, :priv_key)
      User.start_link({pub_key, priv_key})
      pub_key
    end
    Topology.start_link(public_keys)  # this actor can be reached out for list of user keys and neighbors
    create_transactions(number_txn)
  end

  @doc """
  first create a set of empty transactions, users who mine it get some BTC and thats how BTC
  is introduced in the system
  Next a set of transactions are introduced between random users, amount is fixed as of now
  System exits after the designated number of transactions are completed
  """
  def create_transactions(x) do
    nodes = Topology.get_all_nodes()

    Consensus.start_link()
    BlockChainServer.start_link()

    introduce_bitcoins(nodes)

    number_of_transactions = String.to_integer(x)

    for j <- 1..number_of_transactions do
      from = Enum.random(nodes)
      to = Enum.random(nodes)
      amount = :rand.uniform(1)
      transaction = Transaction.init(to, from, amount)
      User.get_balance(from)
      # exit(:shutdown)
      if User.get_balance(from) < amount do
        IO.puts "Not enough balance for #{transaction}"
      else
        if from != to do
          broadcast_transaction(transaction)
          IO.puts "Transaction no #{j} done"
        else
          IO.puts "Transaction no #{j} was invalid"
        end
        print_user_balance(nodes)
      end
      Consensus.reset()
    end
    # IO.inspect BlockChainServer.get_lenght_of_chain()
    # IO.inspect BlockChainServer.get_full_chain()
    IO.puts "All Transactions are over\n"
  end

  def broadcast_transaction(transaction) do
    n = Topology.get_all_nodes()
    nodes = Enum.shuffle(n)
    Enum.each nodes, fn(key) ->
      User.handle_transaction(key, transaction)
    end
  end

  def introduce_bitcoins(nodes) do
    Enum.each nodes, fn(key) ->
      from =  nil
      to = key
      amount = 50
      transaction = Transaction.init(to, from, amount)
      reward = Transaction.init(nil, nil, 0)
      fee = Transaction.init(nil, nil, 0)
      data = [transaction, reward, fee]
      {:ok, block} = BlockChainServer.mine_block(data)
      BlockChainServer.add_block(block)
    end
  end

  def print_user_balance(nodes) do
    filename = "user_balance.txt"
    Enum.each nodes, fn(key) ->
      balance = User.get_balance(key)
      File.write(filename, "#{key} ====== #{balance}\n", [:append])
    end
    File.write(filename, "=================================================\n\n", [:append])
  end

end

BitcoinSimulator.main
