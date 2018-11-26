defmodule BitcoinSimulatorTest do
  use ExUnit.Case

  setup do
    {:ok, blockchain} = BlockChainServer.start_link()
    {:ok, server: blockchain}
  end

  test "add transactions and check length of blockchain" do
    tx1 = ["seller: Alice, buyer: Bob, amount = 10"]
    tx2 = ["seller: Alice, buyer: Charlie, amount = 20"]
    tx3 = ["seller: Bob, buyer: Charlie, amount = 15"]
    BlockChainServer.add_block(tx1)
    # BlockChainServer.get_latest_block()

    BlockChainServer.add_block(tx2)
    # BlockChainServer.get_latest_block()

    BlockChainServer.add_block(tx3)
    # BlockChainServer.get_latest_block()

    assert BlockChainServer.get_lenght_of_chain() == {:ok, 4} # genesis block is added upon initialization

  end

  test "correctness of hashes" do
    tx = ["seller: Bob, buyer: Charlie, amount = 10"]
    BlockChainServer.add_block(tx)

    {:ok, block} = BlockChainServer.get_latest_block()
    data = Map.fetch!(block, :data)
    previous_hash = Map.fetch!(block, :previous_hash)
    nonce = Map.fetch!(block, :nonce)

    difficulty = 2
    target = "00"
    calculated_hash = [data, previous_hash, Kernel.inspect(nonce)]
    |> Utils.calculate_hash

    assert String.slice(calculated_hash, 0..difficulty-1) == target

  end

  test "calculated hash is stored hash" do
    tx = ["seller: Bob, buyer: Charlie, amount = 10"]
    BlockChainServer.add_block(tx)

    {:ok, block} = BlockChainServer.get_latest_block()
    data = Map.fetch!(block, :data)
    previous_hash = Map.fetch!(block, :previous_hash)
    nonce = Map.fetch!(block, :nonce)
    hash = Map.fetch!(block, :hash)
    calculated_hash = [data, previous_hash, Kernel.inspect(nonce)]
    |> Utils.calculate_hash

    assert hash == calculated_hash

  end


end
