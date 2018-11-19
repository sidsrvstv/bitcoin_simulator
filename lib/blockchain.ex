defmodule BlockChainServer do
  use GenServer

  #------------#
  # Client API #
  #------------#

  @doc """
    start the BlockChain server
  """
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
    returns the state of the block on top of chain
  """
  def get_latest_block() do
    GenServer.call(__MODULE__, :get_last)
  end

  @doc """
    function to add block
    new block is initialized with the data
    block is mined and then added to the top of chain
  """
  def add_block(tx_data) do
    {:ok, last_block} = get_latest_block()
    previous_hash = Map.fetch!(last_block, :hash)
    items = tx_data ++  [previous_hash]  # tx_data is [timestamp, data]
    {:ok, new_block_pid} = BlockServer.start_link(items)
    GenServer.call(__MODULE__, {:add_block, new_block_pid}, 100_000)
  end

  @doc """
    checks the validity of the blockchain by recalculating hash and matching it with the one stored
    if value has been modified in the middle, the hash which depends upon previous hash too will now
    be different than the one stored making the blockchain invalid
  """
  def is_chain_valid() do
    {:ok, answer} = GenServer.call(__MODULE__, :is_chain_valid)
    answer
  end



  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one blockchain, the first block called the genesis block is put in place
    state is list of maps
  """
  def init(_) do
    {:ok, block_pid} = BlockServer.start_link([Kernel.inspect(NaiveDateTime.utc_now), "Genesis Block", "0"])
    {:ok, state} = BlockServer.get_block_info(block_pid)

    {:ok, [state]}
  end

  def handle_call(:get_last, _from, state) do
    {:reply, {:ok, List.last(state)}, state }
  end

  def handle_call(:is_chain_valid, _from, state) do
    result = %{:final => True}
    for i <- 1..length(state)-1 do
      current_block = Enum.at(state, i)

      c_timestamp = Map.fetch!(current_block, :timestamp)
      c_data = Map.fetch!(current_block, :data)
      c_previoushash = Map.fetch!(current_block, :previous_hash)
      items = [c_timestamp, c_data, c_previoushash]

      previous_block = Enum.at(state, i-1)

      if Map.fetch!(current_block, :hash) != Utils.calculate_hash(items) do
        Map.update!(result, :final, &(&1 = False))
      end
      if Map.fetch!(current_block, :previous_hash) != Map.fetch!(previous_block, :hash) do
        Map.update!(result, :final, &(&1 = False))
      end
    end
    {:reply, {:ok, Map.fetch!(result, :final)}, state}
  end

  def handle_call({:add_block, block_pid}, _from, state) do
    {:ok, block_info} = BlockServer.get_block_info(block_pid)
    BlockServer.mine_block(block_pid)  # spend time to mine block
    new_state = state ++ [block_info]
    {:reply, :ok, new_state }
  end


end
