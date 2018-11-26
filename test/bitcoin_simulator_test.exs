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
    BlockChainServer.get_latest_block()

    BlockChainServer.add_block(tx2)
    BlockChainServer.get_latest_block()

    BlockChainServer.add_block(tx3)
    BlockChainServer.get_latest_block()

    assert BlockChainServer.get_lenght_of_chain() == {:ok, 4} # genesis block is added upon initialization

  end


end
