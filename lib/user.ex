defmodule User do
  use GenServer

  #------------#
  # Client API #
  #------------#

  @doc """
    start the user actor
  """
  def start_link({public_key, private_key}) do
    GenServer.start_link(__MODULE__, {public_key, private_key}, name: via_tuple(public_key))
  end

  def create_transaction(public_key, transaction) do
    GenServer.call(via_tuple(public_key), {:create_transaction, transaction, public_key})
  end

  def get_latest_block(public_key) do
    GenServer.call(via_tuple(public_key), :get_latest_block)
  end

  def add_block(public_key, block) do
    GenServer.call(via_tuple(public_key), {:add_block, block})
  end

  def mine_block(public_key, transaction) do
    GenServer.call(via_tuple(public_key), {:mine_block, transaction})
  end

  def get_balance(public_key) do
    {:ok, balance} = GenServer.call(via_tuple(public_key), {:get_balance, public_key})
    balance
  end

  def get_complete_blockchain(public_key) do
    GenServer.call(via_tuple(public_key), :get_blockchain)
  end

  def get_lenght_of_chain(public_key) do
    GenServer.call(via_tuple(public_key), :get_chainlength)
  end

  defp via_tuple(public_key) do
    {:via, :gproc, {:n, :l, {:user_name, public_key}}}
  end

  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one blockchain, the first block called the genesis block is put in place
    state is list of maps
  """
  def init({_public_key, private_key}) do

    BlockChainServer.start_link(private_key)
    state = %{:sent_vote => 0,
              :blockchain => private_key
    }

    {:ok, state}
  end

  def handle_call({:create_transaction, transaction, public_key}, _from, state) do
    customer = Map.fetch!(transaction, :from)
    reward = Transaction.init(public_key, "None", 10) # init(to, from, amount) # reward not from any user
    fee = Transaction.init(public_key, customer, 0.1) # init(to, from, amount)
    data = [transaction, reward, fee]
    {:reply, {:ok, data}, state}
  end

  def handle_call(:get_pk, _from, state) do
    wallet = Map.fetch!(state, :wallet)
    pk = Map.fetch!(wallet, :pub_key)
    {:reply, {:ok, pk}, state}
  end

  def handle_call({:add_block, block}, _from, state) do
    id = Map.fetch!(state, :blockchain)
    BlockChainServer.add_block(id,block)
    {:reply, :ok, state}
  end

  def handle_call({:mine_block, transaction}, _from, state) do
    id = Map.fetch!(state, :blockchain)
    {:ok, block} = BlockChainServer.mine_block(id, transaction)
    {:reply, {:ok, block}, state}
  end

  def handle_call(:get_chainlength, _from, state) do
    id = Map.fetch!(state, :blockchain)
    {:ok, len} = BlockChainServer.get_lenght_of_chain(id)
    {:reply, {:ok, len}, state}
  end

  def handle_call(:get_blockchain, _from, state) do
    id = Map.fetch!(state, :blockchain)
    {:ok, blockchain} = BlockChainServer.get_full_chain(id)
    {:reply, {:ok, blockchain}, state}
  end

  def handle_call(:get_latest_block, _from, state) do
    id = Map.fetch!(state, :blockchain)
    {:ok, block} = BlockChainServer.get_latest_block(id)
    {:reply, {:ok, block}, state}
  end

  def handle_call({:get_balance, public_key}, _from, state) do
    id = Map.fetch!(state, :blockchain )
    blockchain = BlockChainServer.get_full_chain(id) # list of blocks or maps
    balance = for i <- 1..length(blockchain) - 1 do
      block = Enum.at(blockchain, i)
      data = Map.fetch!(block, :data)
      cur_sum = for i <- 0..length(data) -1 do
        txn = Enum.at(data, i)
        add = if Map.fetch!(txn, :to) == public_key do
          Map.fetch!(txn, :amount)
        end
        sub = if Map.fetch!(txn, :from) == public_key do
          Map.fetch!(txn, :amount) * -1
        end
        add + sub
      end
      Enum.sum(cur_sum)
    end
    {:reply, {:ok, Enum.sum(balance)}, state}
  end

end
