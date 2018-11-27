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

  def mine_block(name, transaction) do
    GenServer.call(via_tuple(name), {:mine_block, transaction})
  end

  def get_user_publickey(name) do
    GenServer.call(via_tuple(name), :get_pk)
  end

  def get_balance(name) do
    {:ok, balance} = GenServer.call(via_tuple(name), :get_balance)
    balance
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
    # {:ok, name_sk} = RsaEx.generate_private_key
    # {:ok, name_pk} = RsaEx.generate_public_key(name_sk)

    {:ok, block_pid} = BlockChainServer.start_link(wallet.priv_key)
    state = %{:wallet => wallet,
              :blockchain => block_pid
    }

    {:ok, state}
  end

  def handle_call({:carryout_transaction, transaction}, _from, state) do

  end

  def handle_call(:get_pk, _from, state) do
    {:ok, {:ok, Map.fetch!(state, :pk)}, state}
  end

  def handle_call(:get_balance, _from, state) do

  end

end
