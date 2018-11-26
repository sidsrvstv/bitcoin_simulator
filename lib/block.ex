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
    {:ok, "block mined", state} = GenServer.call(block_pid, :mine_block, 100_000)
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


  def handle_call(pattern, _from, state) do
    data = Map.fetch!(state, :data)
    previous_hash = Map.fetch!(state, :previous_hash)
    hash = Map.fetch!(state, :hash)
    nonce = Map.fetch!(state, :nonce)
    case pattern do
      :get_hash -> # function to re calculate hash
        hash = [data, previous_hash, Kernel.inspect(nonce)]
        |> Utils.calculate_hash

        {:reply, {:ok, hash}, state}

      :get_state -> # function to return current state
        {:reply, {:ok, state}, state}

      :mine_block  -> # function for mining, substring of hash checked, if not matched, nonce incremented
                      # then hash is recalculated. New nonce and hash are updated in state
        difficulty = 2
        nonce = 0
        {:ok, {final_hash, final_nonce}} = mine({data, previous_hash, hash}, nonce, difficulty)
        state1 = Map.put(state, :nonce, final_nonce)
        state2 = Map.put(state1, :hash, final_hash)
        state3 = Map.put(state2, :miner_reward, 10)
        # IO.inspect state3
        {:reply, {:ok, "block mined", state3}, state3}
    end
  end

  defp mine({data, previous_hash, hash}, nonce, difficulty) do
    # IO.inspect hash
    if String.slice(hash, 0..difficulty-1) != "00" do # RHS length i.e. "00" here equals difficulty
      new_hash = [data, previous_hash, Kernel.inspect(nonce)]
      |> Utils.calculate_hash
      mine({data, previous_hash, new_hash}, nonce + 1, difficulty)
    else
      {:ok, {hash, nonce-1}}
    end

  end


end
