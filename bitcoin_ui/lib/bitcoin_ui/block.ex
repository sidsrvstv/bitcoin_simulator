defmodule Block do

  defstruct data: nil,
            nonce: nil,
            previous_hash: nil,
            hash: nil

  def init([data, previous_hash]) do
    hash = [data, previous_hash, "0"]
    |> Utils.calculate_hash

    %Block{data: data,
          nonce: nil,
          previous_hash: previous_hash,
          hash: hash
    }
  end

  def mine_block([data, previous_hash]) do
    nonce = 0
    # nonce = :rand.uniform(10000)
    difficulty = 2
    state = Block.init([data, previous_hash])

    hash = [data, previous_hash, "0"]
    |> Utils.calculate_hash

    {:ok, {final_hash, final_nonce}} = mine({data, previous_hash, hash}, nonce, difficulty)

    Graph.nonce(final_nonce)

    state1 = Map.put(state, :nonce, final_nonce)
    state2 = Map.put(state1, :hash, final_hash)

    {:ok, state2}

  end

  defp mine({data, previous_hash, hash}, nonce, difficulty) do
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
