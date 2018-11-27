defmodule User do
  use GenServer

  #------------#
  # Client API #
  #------------#

  @doc """
    start the user actor
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def carryout_transaction(name, transaction) do
    case GenServer.call(via_tuple(name), {:carryout_transaction, transaction}) do
      {:error, message} -> IO.puts message
      {:ok} ->  mine_block(name, transaction)
    end
  end

  def get_latest_block(name) do
    GenServer.call(via_tuple(name), :get_latest_block)
  end

  def add_block(name, block) do
    GenServer.call(via_tuple(name), {:add_block, block})
  end

  def mine_block(name, transaction) do
    GenServer.call(via_tuple(name), {:mine_block, transaction})
  end

  def get_publickey(name) do
    GenServer.call(via_tuple(name), :get_pk)
  end

  def get_balance(name) do
    {:ok, balance} = GenServer.call(via_tuple(name), :get_balance)
    balance
  end

  def get_complete_blockchain(name) do
    GenServer.call(via_tuple(name), :get_blockchain)
  end

  def get_lenght_of_chain(name) do
    GenServer.call(via_tuple(name), :get_chainlength)
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:user_name, name}}}
  end

  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one blockchain, the first block called the genesis block is put in place
    state is list of maps
  """
  def init(name) do
    wallet = Wallet.init

    {:ok, block_pid} = BlockChainServer.start_link(wallet.priv_key)
    state = %{:wallet => wallet,
              :blockchain => wallet.priv_key
    }

    {:ok, state}
  end

  def handle_call({:carryout_transaction, transaction}, _from, state) do
    wallet = Map.fetch!(state, :wallet)
    pk = Map.fetch!(wallet, :pub_key)
    sk = Map.fetch!(wallet, :priv_key)
    amount = Map.fetch!(transaction, :amount)
    if wallet.get_balance(pk, sk) >= amount do
      {:ok}
    else
      {:error, "insufficient balance"}
    end
  end

  def handle_call(:get_pk, _from, state) do
    wallet = Map.fetch!(state, :wallet)
    pk = Map.fetch!(wallet, :priv_key)
    {:reply, {:ok, pk}, state}
  end

  def handle_call({:add_block, block}, _from, state) do
    id = Map.fetch!(state, :blockchain)
    BlockChainServer.add_block(id,block)
    {:reply, :ok, state}
  end

  def handle_call({:mine_block, transaction}, _from, state) do
    id = Map.fetch!(state, :blockchain)
    IO.inspect id
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

end
