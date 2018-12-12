defmodule BlockChainServer do
  use GenServer

  #------------#
  # Client API #
  #------------#

  @doc """
    start the BlockChain server
  """
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :blockchain)
  end

  @doc """
    returns the state of the block on top of chain
  """
  def get_latest_block() do
    GenServer.call(:blockchain, :get_last)
  end

  @doc """
    function to add block
    new block is initialized with the data
    block is mined and then added to the top of chain
  """
  def add_block(block) do
    GenServer.call(:blockchain, {:add_block, block})
    write_transaction_to_file(block)
  end

  def mine_block(tx_data) do
    {:ok, last_block} = get_latest_block()
    previous_hash = Map.fetch!(last_block, :hash)
    GenServer.call(:blockchain, {:mine_block, {tx_data, previous_hash}}, 100_000)
  end


  def get_lenght_of_chain() do
    GenServer.call(:blockchain, :get_length)
  end

  def get_full_chain() do
    GenServer.call(:blockchain, :get_full_chain)
  end

  def write_transaction_to_file(block) do
    data = Map.fetch!(block, :data)
    # IO.inspect data
    filename = "transactions.txt"
    for i <- 0..length(data)-1 do
      if i == 0 do
        File.write(filename, "Transaction:\n", [:append])
      end
      if i == 1 do
        File.write(filename, "Reward:\n", [:append])
      end
      if i == 2 do
        File.write(filename, "Fee:\n", [:append])
      end
      tx = Enum.at(data, i)
      to = Map.fetch!(tx, :to)
      from = Map.fetch!(tx, :from)
      amount = Map.fetch!(tx, :amount)
      File.write(filename, "To: #{to}\n", [:append])
      File.write(filename, "From: #{from}\n", [:append])
      File.write(filename, "Amount: #{amount}\n", [:append])
      File.write(filename, "\n\n", [:append])
    end
    File.write(filename, "=================================================\n\n", [:append])
  end

  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one blockchain, the first block called the genesis block is put in place
    state is list of maps
  """
  def init(_) do
    # {:ok, block_pid} = BlockServer.start_link(["Genesis Block", "0"])
    # {:ok, state} = BlockServer.get_block_info(block_pid)
    state = Block.init(["Genesis Block", "0"])
    {:ok, [state]}
  end

  def handle_call(:get_last, _from, state) do
    {:reply, {:ok, List.last(state)}, state }
  end

  def handle_call(:get_length, _from, state) do
    {:reply, {:ok, length(state)}, state}
  end

  def handle_call(:get_full_chain, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:add_block, block}, _from, state) do
    # IO.inspect "reached till blochchain"
    new_state = state ++ [block]
    # IO.puts "blockchain-->"
    # IO.inspect new_state
    {:reply, :ok, new_state }
  end

  def handle_call({:mine_block, {data, previous_hash}}, _from, state) do
    {:ok, new_block} = Block.mine_block([data, previous_hash])  # spend time to mine block
    {:reply, {:ok, new_block}, state }
  end

end
