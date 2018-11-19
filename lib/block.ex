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
    GenServer.call(block_pid, :mine_block, 100_000)
  end

  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one block, with index or position of block, timestamp,
    data and the hash of previous block
  """
  def init([timestamp, data, previous_hash]) do

    current_hash = [timestamp, data, previous_hash]
    |> Utils.calculate_hash

    state = %{:timestamp => timestamp,
              :data => data,
              :previous_hash => previous_hash,
              :hash => current_hash
    }

    {:ok, state}
  end


  def handle_call(pattern, _from, state) do
    timestamp = Map.fetch!(state, :timestamp)
    data = Map.fetch!(state, :data)
    previous_hash = Map.fetch!(state, :previous_hash)
    hash = Map.fetch!(state, :hash)
    case pattern do
      :get_hash -> # function to re calculate hash
        hash = [timestamp, data, previous_hash]
        |> Utils.calculate_hash

        {:reply, {:ok, hash}, state}

      :get_state -> # function to return current state
        {:reply, {:ok, state}, state}

      :mine_block  -> # function for mining, substring of hash checked, if not matched, nonce incremented
                      # then hash is recalculated. New nonce and hash are updated in state
        difficulty = 2
        IO.inspect hash
        nonce = "0"
        mine({timestamp, data, previous_hash, hash}, nonce, difficulty)
        {:reply, {:ok, "block mined"}, state}
    end
  end

  defp mine({timestamp, data, previous_hash, hash}, nonce, difficulty) do
    IO.inspect hash
    if String.slice(hash, 0..difficulty-1) != "00" do
      new_hash = [timestamp, data, previous_hash, nonce]
      |> Utils.calculate_hash
      mine({timestamp, data, previous_hash, new_hash}, nonce <> "0", difficulty)
    end
    {:ok}

  end


end
