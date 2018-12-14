defmodule BitcoinSimulatorTest do
  use ExUnit.Case

  test "transaction between two parties with from user as miner" do
    Consensus.start_link()
    BlockChainServer.start_link()

    public_keys = for _ <- 1..2 do
      wallet = Wallet.init()
      public_key = Map.fetch!(wallet, :pub_key)
      private_key = Map.fetch!(wallet, :priv_key)
      User.start_link({public_key, private_key})
      from =  nil
      to = public_key
      amount = 50
      transaction = Transaction.init(to, from, amount)
      reward = Transaction.init(nil, nil, 0)
      fee = Transaction.init(nil, nil, 0)
      data = [transaction, reward, fee]
      {:ok, block} = BlockChainServer.mine_block(data)
      BlockChainServer.add_block(block)
      public_key
    end
    Topology.start_link(public_keys)

    user1 = Enum.at(public_keys, 0)
    user2 = Enum.at(public_keys, 1)
    from = user1
    to = user2
    amount = 20
    transaction = Transaction.init(to, from, amount)

    # going to give the transaction to only user1, so it is going to mine it
    # user1 balance should be = 50 - 20 + 10 + 2 - 2 = 40BTC
    # because: user1 balance - tx amount + miner reward + fee(because it mines) - fee(as it is the originator of tx)
    User.handle_transaction(user1, transaction)
    :timer.sleep(1000)
    User.handle_transaction(user2, transaction)

    Consensus.reset()

    assert User.get_balance(user1) == 40.0



  end


  test "transaction between two parties with to user as miner" do
    Consensus.start_link()
    BlockChainServer.start_link()

    public_keys = for _ <- 1..2 do
      wallet = Wallet.init()
      public_key = Map.fetch!(wallet, :pub_key)
      private_key = Map.fetch!(wallet, :priv_key)
      User.start_link({public_key, private_key})
      from =  nil
      to = public_key
      amount = 50
      transaction = Transaction.init(to, from, amount)
      reward = Transaction.init(nil, nil, 0)
      fee = Transaction.init(nil, nil, 0)
      data = [transaction, reward, fee]
      {:ok, block} = BlockChainServer.mine_block(data)
      BlockChainServer.add_block(block)
      public_key
    end
    Topology.start_link(public_keys)

    user1 = Enum.at(public_keys, 0)
    user2 = Enum.at(public_keys, 1)
    from = user1
    to = user2
    amount = 20
    transaction = Transaction.init(to, from, amount)

    # going to give the transaction to only user1, so it is going to mine it
    # user1 balance should be = 50 + 20 + 10 + 2  = 82BTC
    # because: user2 balance + tx amount + miner reward + fee(because it mines)
    User.handle_transaction(user2, transaction)
    :timer.sleep(1000)
    User.handle_transaction(user1, transaction)

    Consensus.reset()

    assert User.get_balance(user2) == 82.0


  end

  test "transaction between multiple parties" do
    Consensus.start_link()
    BlockChainServer.start_link()

    public_keys = for _ <- 1..4 do
      wallet = Wallet.init()
      public_key = Map.fetch!(wallet, :pub_key)
      private_key = Map.fetch!(wallet, :priv_key)
      User.start_link({public_key, private_key})
      from =  nil
      to = public_key
      amount = 50
      transaction = Transaction.init(to, from, amount)
      reward = Transaction.init(nil, nil, 0)
      fee = Transaction.init(nil, nil, 0)
      data = [transaction, reward, fee]
      {:ok, block} = BlockChainServer.mine_block(data)
      BlockChainServer.add_block(block)
      public_key
    end
    Topology.start_link(public_keys)

    user1 = Enum.at(public_keys, 0)
    user2 = Enum.at(public_keys, 1)
    user3 = Enum.at(public_keys, 2)
    user4 = Enum.at(public_keys, 3)
    from = user1
    to = user2
    amount = 20
    transaction = Transaction.init(to, from, amount)

    # going to give the transaction to only user1, so it is going to mine it
    # user1 balance should be = 50 - 20 + 10 + 2 - 2 = 40BTC
    # because: user1 balance - tx amount + miner reward + fee(because it mines) - fee(as it is the originator of tx)
    User.handle_transaction(user4, transaction)
    :timer.sleep(1000)
    User.handle_transaction(user1, transaction)
    User.handle_transaction(user2, transaction)
    User.handle_transaction(user3, transaction)

    Consensus.reset()

    # user4 mines the transaction so gets 10 BTC as reward + 2 BTC as fee
    assert User.get_balance(user4) == 62.0
    # user1 balance = 50 - 20 -2 (fee) = 28.0
    assert User.get_balance(user1) == 28.0
    # user2 balance = 50 + 20
    assert User.get_balance(user2) == 70.0
    # user3 balance has no change, therefore = 50
    assert User.get_balance(user3) == 50.0

  end


  test "multiple transactions between multiple parties" do
    Consensus.start_link()
    BlockChainServer.start_link()

    public_keys = for _ <- 1..4 do
      wallet = Wallet.init()
      public_key = Map.fetch!(wallet, :pub_key)
      private_key = Map.fetch!(wallet, :priv_key)
      User.start_link({public_key, private_key})
      from =  nil
      to = public_key
      amount = 50
      transaction = Transaction.init(to, from, amount)
      reward = Transaction.init(nil, nil, 0)
      fee = Transaction.init(nil, nil, 0)
      data = [transaction, reward, fee]
      {:ok, block} = BlockChainServer.mine_block(data)
      BlockChainServer.add_block(block)
      public_key
    end
    Topology.start_link(public_keys)

    user1 = Enum.at(public_keys, 0)
    user2 = Enum.at(public_keys, 1)
    user3 = Enum.at(public_keys, 2)
    user4 = Enum.at(public_keys, 3)

    from = user1
    to = user2
    amount = 20
    transaction1 = Transaction.init(to, from, amount)
    User.handle_transaction(user4, transaction1)
    :timer.sleep(1000)
    User.handle_transaction(user1, transaction1)
    User.handle_transaction(user2, transaction1)
    User.handle_transaction(user3, transaction1)

    Consensus.reset()

    from = user3
    to = user1
    amount = 10
    transaction2 = Transaction.init(to, from, amount)
    User.handle_transaction(user2, transaction2)
    :timer.sleep(1000)
    User.handle_transaction(user4, transaction2)
    User.handle_transaction(user3, transaction2)
    User.handle_transaction(user1, transaction2)

    # Accounts
    # User1 = 50 - 20 (txn1) - 2 (fee txn1) + 10 (txn2)  = 38
    # User2 = 50 + 20 (txn1) + 10 (miner txn2) + 1 (fee txn2) = 81
    # User3 = 50 - 10 (txn2) - 1 (fee txn1) = 39
    # User4 = 50 + 10 (miner tx1) + 2 (fee txn1) = 62
    Consensus.start_link()

    assert User.get_balance(user1) == 38.0

    assert User.get_balance(user2) == 81.0

    assert User.get_balance(user3) == 39.0

    assert User.get_balance(user4) == 62.0



  end






end
