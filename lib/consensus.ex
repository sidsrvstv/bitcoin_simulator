defmodule Consensus do
  use GenServer

  # SERVER API

  def start_link do
    GenServer.start_link(__MODULE__,[] , name: :consensus)
  end

  @doc """
  receives votes from all users in the form of tuple
  {public_key, block}
  """
  def send_vote( public_key, block, voter_key ) do
    GenServer.call(:consensus, {:update_vote, public_key, block, voter_key }, 1000_000 )
  end

  def reset() do
    GenServer.call(:consensus, :reset)
  end

  # CLIENT API
  def init(_) do
    Process.flag(:trap_exit, true)
    state = %{:max_votes => 0,
              :vote_count => 0,
              :block => nil,
              :votes_of => []
    }
    {:ok, state}
  end

  def handle_info(:kill_me, state) do
    {:stop, :normal, state}
  end

  @doc """
  updating the vote count in state for corresponding public key
  if no of votes has equalled no of users, that is vote has come from all,
  get winner and broadcast
  """
  def handle_call({:update_vote, public_key, block, voter_key } , _from, state) do
    of = Map.fetch!(state, :votes_of)
    new = of ++ [voter_key]
    new = Map.put(state, :votes_of, new)
    state = new
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
      new_map = %{:count => 1, :block => block } # create a new map with count and block keys
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
    current_count = Map.fetch!(new_state, :vote_count) # checking how many votes cast
    final_state = Map.put(new_state, :vote_count, current_count + 1) # increasing the number of votes received
    if current_count + 1 == Topology.get_number_of_nodes() do # need to end when everyone cast their vote
      winner = Map.fetch!(state, :block)
      d = Map.fetch!(winner, :data)
      reward = Enum.at(d,1)
      u = Map.fetch!(reward, :to)
      File.write("miner_name.txt", "#{u}\n\n", [:append])
      # IO.inspect Map.fetch!(state, :votes_of)
      # votes = Map.fetch!(state, :max_votes)
      # IO.inspect votes
      BlockChainServer.add_block(winner)
    end

    {:reply, :ok, final_state}
  end

  def handle_call(:reset, _from, _state) do
    r_state = %{:max_votes => 0,
                  :vote_count => 0,
                  :block => nil,
                  :votes_of => []
      }

    {:reply, :ok, r_state}
  end

end
