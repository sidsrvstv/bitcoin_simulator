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

  @doc """
    listen for transactions
    Once a transaction has been recieved:
      verify
      mine
        broadcast if successfully mined
        stop if someone else mines first
  """
  def transaction_polling(name, transaction) do
    case verify_transaction(name, transaction ) do
      {:ok} -> mine_block(name, transaction)
      {:error} -> IO.puts "Not enough balance, transaction disallowed"
    end
  end

  def mine_block(name, transaction) do
    {:ok, block} = BlockChainServer.mine_block(name, transaction)
    case mined_blocks_polling(name, transaction) do
      {:ok} ->
        broadcast_message(name, :block_mined)
        BlockChainServer.add_block(name, block)
    end
  end

  def verify_transaction(name, transaction) do
    # pass
  end

  def mined_blocks_polling(name, transaction) do
    # pass
  end

  def broadcast_message(name, message) do
    # pass
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
    {:ok, block_pid} = BlockChainServer.start_link(name)
    state = block_pid
    {:ok, state}
  end

end
