defmodule BitcoinSimulatorTest do
  use ExUnit.Case

  setup do
    {:ok, blockchain} = BlockChainServer.start_link()
    {:ok, server: blockchain}
  end

  test "add transactions and check last block" do
    tx1 = ["11/18/2018 9:00PM", "seller: sid, buyer: nanda, amount = 10"]
    tx2 = ["11/18/2018 9:30PM", "seller: sid, buyer: nanda, amount = 20"]
    tx3 = ["11/18/2018 10:00PM", "seller: nanda, buyer: sid, amount = 15"]
    BlockChainServer.add_block(tx1)
    BlockChainServer.get_latest_block()

    BlockChainServer.add_block(tx2)
    BlockChainServer.get_latest_block()

    BlockChainServer.add_block(tx3)
    BlockChainServer.get_latest_block()

    assert BlockChainServer.get_lenght_of_chain() == {:ok, 4} # genesis block is added upon initialization

  end


end
