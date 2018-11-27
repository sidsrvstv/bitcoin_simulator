defmodule BlockServer do
  use GenServer

  #------------#
  # Client API #
  #------------#

  @doc """
    start the Block server
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @doc """
    returns state of block
  """
  def get_block_info(block_pid) do
    GenServer.call(block_pid, :get_state)
  end

  @doc """
    calculates hash encoding
  """
  def calculate_current_hash(block_pid) do
    GenServer.call(block_pid, :get_hash)
  end

  @doc """
    mine block routine, current difficulty set to 2, can increase or decrease it
  """
  def mine_block(block_pid) do
    nonce = 0
    {:ok, "block mined", state} = GenServer.call(block_pid, {:mine_block, nonce}, 100_000)
    {:ok, state}
  end

  def pool_mine(block_pid, nonce) do
    {:ok, "block mined", state} = GenServer.cast(block_pid, {:mine_block, nonce})
    {:ok, state}
  end


  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one block, with dummy data and the dummy hash of previous block
  """
  def init([data, previous_hash]) do
    current_hash = [data, previous_hash, "0"]
    |> Utils.calculate_hash
    state = %{:data => data,
              :previous_hash => previous_hash,
              :nonce => 0,
              :hash => current_hash,
              :miner_reward => 0
    }

    {:ok, state}
  end

  def handle_call({:mine_block, nonce}, _from, state) do
    data = Map.fetch!(state, :data)
    previous_hash = Map.fetch!(state, :previous_hash)
    hash = Map.fetch!(state, :hash)

    difficulty = 2

    {:ok, {final_hash, final_nonce}} = mine({data, previous_hash, hash}, nonce, difficulty)
    state1 = Map.put(state, :nonce, final_nonce)
    state2 = Map.put(state1, :hash, final_hash)
    state3 = Map.put(state2, :miner_reward, 10)

    {:reply, {:ok, "block mined", state3}, state3}
  end

  def handle_cast({:mine_block, nonce}, state) do
    data = Map.fetch!(state, :data)
    previous_hash = Map.fetch!(state, :previous_hash)
    hash = Map.fetch!(state, :hash)

    difficulty = 2

    {:ok, {final_hash, final_nonce}} = mine({data, previous_hash, hash}, nonce, difficulty)
    state1 = Map.put(state, :nonce, final_nonce)
    state2 = Map.put(state1, :hash, final_hash)
    state3 = Map.put(state2, :miner_reward, 10)

    {:noreply, state3}
  end

  def handle_call(:get_hash , _from, state) do
    data = Map.fetch!(state, :data)
    previous_hash = Map.fetch!(state, :previous_hash)
    nonce = Map.fetch!(state, :nonce)

    hash = [data, previous_hash, Kernel.inspect(nonce)]
    |> Utils.calculate_hash

    {:reply, {:ok, hash}, state}
  end

  def handle_call(:get_state, _from, state) do
      {:reply, {:ok, state}, state}
  end

  defp mine({data, previous_hash, hash}, nonce, difficulty) do
    # IO.inspect hash
    target = String.duplicate("0", difficulty)
    if String.slice(hash, 0..difficulty-1) != target do # RHS length i.e. "00" here equals difficulty
      new_hash = [data, previous_hash, Kernel.inspect(nonce)]
      |> Utils.calculate_hash
      mine({data, previous_hash, new_hash}, nonce + 1, difficulty)
    else
      {:ok, {hash, nonce-1}}
    end

  end


end
