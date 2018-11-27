defmodule PoolMine do
  use GenServer

  #------------#
  # Client API #
  #------------#

  def start_link(list) do
    GenServer.start_link(__MODULE__, list, name: __MODULE__)
  end

  def mine_block(__MODULE__, data) do
    GenServer.call(__MODULE__, :pool_mine)
  end

  #------------#
  # Server API #
  #------------#

  def init(list) do
    state = []
    for i <- 0..length(list)-1 do
      BlockChainServer.start_link(Enum.at(list, i))
      state = state ++ [i]
    end
    {:ok, state}
  end

  def handle_call(:pool_mine, _from, state) do
    nonce = 0
    # {:ok, last_block} = get_latest_block(name)
    # previous_hash = Map.fetch!(last_block, :hash)
    # items = tx_data ++  [previous_hash]  # tx_data is [timestamp, data]
    # {:ok, block_pid} = BlockServer.start_link(items)
    # for i <- 0..length(state)-1 do
    #   BlockServer.pool_mine(block_pid, {nonce + 100*i, _from})
    # end
    {:ok, :ok, state}
  end




end
