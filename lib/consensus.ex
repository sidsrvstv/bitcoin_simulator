defmodule Consensus do
  use GenServer

  # SERVER API

  def start_link(args) do
    GenServer.start_link(__MODULE__,args , name: :consensus)
  end

  def send_vote( {public_key, block} ) do
    GenServer.call(:consensus, {:udpate_vote, public_key, block})
  end

  def get_voter_count do
    GenServer.call(:consensus, :get_voter_count)
  end

  def get_winner do
    GenServer.call(:consensus, :get_poll_winner)
  end


  # CLIENT API
  def init(_) do
    state = %{:max_votes => 0,
              :block => ""
    }
    {:ok, state}
  end

  def handle_call(:get_voter_count, _from, state) do
    {:reply, {:ok, length(Map.keys(state))}, state}
  end

  def handle_call(:get_winner, _from, state) do
    {:reply, {:ok, Map.fetch!(state, :block)}, state}
  end

  @doc """
  updating the vote count in state for corresponding public key
  """
  def handle_call({:update_vote, public_key, block}, _from, state) do
    new_state = if Map.has_key?(state, public_key) do
      public_key_map = Map.fetch!(state, public_key) # get the map of public key
      count = Map.fetch!(public_key_map, :count) # get the value of count from the above map, this is a nested map
      new_map = Map.put(public_key_map, :count, count + 1) # new map is old map with updated vote count
      s1 = Map.put(state, :public_key, new_map) # put this new map in new state map
      max_till_now = Map.fetch!(state, :max_votes) # get max in state till now
      state1 = if count + 1 > max_till_now do  # if this count exceeds previous best
        s2 = Map.put(s1, :max_votes, count + 1) # update state with max vote count
        s3 = Map.put(s2, :block, block) # update block of winner
        s3
      else
        s1
      end
      state1
    else
      new_map = %{public_key => %{:count => 1, :block => block }} # create a new map with count and block keys
      s1 = Map.put(state, public_key, new_map) # put it in state map
      max_till_now = Map.fetch!(state, :max_votes)
      state1 = if 1 > max_till_now do
        s2 = Map.put(s1, :max_votes, 1)
        s3 = Map.put(s2, :block, block)
        s3
      else
        s1
      end
      state1
    end

    {:reply, {:ok}, new_state}
  end




end
