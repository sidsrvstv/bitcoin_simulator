defmodule BitcoinSimulatorTest do
  use ExUnit.Case

  setup do
    {:ok, blockchain} = BlockChainServer.start_link("1")
    {:ok, server: blockchain}
  end

  test "add transactions and check length of blockchain" do
    tx1 = ["seller: Alice, buyer: Bob, amount = 10"]
    tx2 = ["seller: Alice, buyer: Charlie, amount = 20"]
    tx3 = ["seller: Bob, buyer: Charlie, amount = 15"]
    BlockChainServer.add_block("1",tx1)
    # BlockChainServer.get_latest_block()

    BlockChainServer.add_block("1",tx2)
    # BlockChainServer.get_latest_block()

    BlockChainServer.add_block("1",tx3)
    # BlockChainServer.get_latest_block()

    assert BlockChainServer.get_lenght_of_chain("1") == {:ok, 4} # genesis block is added upon initialization

  end

  test "correctness of hashes" do
    tx = ["seller: Bob, buyer: Charlie, amount = 10"]
    BlockChainServer.add_block("1",tx)

    {:ok, block} = BlockChainServer.get_latest_block("1")
    data = Map.fetch!(block, :data)
    previous_hash = Map.fetch!(block, :previous_hash)
    nonce = Map.fetch!(block, :nonce)

    difficulty = 2
    target = "00"
    calculated_hash = [data, previous_hash, Kernel.inspect(nonce)]
    |> Utils.calculate_hash

    assert String.slice(calculated_hash, 0..difficulty-1) == target

  end

  test "calculated hash is same as stored hash" do
    tx = ["seller: Bob, buyer: Charlie, amount = 10"]
    BlockChainServer.add_block("1",tx)

    {:ok, block} = BlockChainServer.get_latest_block("1")
    data = Map.fetch!(block, :data)
    previous_hash = Map.fetch!(block, :previous_hash)
    nonce = Map.fetch!(block, :nonce)
    hash = Map.fetch!(block, :hash)
    calculated_hash = [data, previous_hash, Kernel.inspect(nonce)]
    |> Utils.calculate_hash

    assert hash == calculated_hash

  end

  test "transaction signature and verification" do
    {:ok, bob_sk} = RsaEx.generate_private_key
    {:ok, bob_pk} = RsaEx.generate_public_key(bob_sk)

    {:ok, alice_sk} = RsaEx.generate_private_key
    {:ok, alice_pk} = RsaEx.generate_public_key(alice_sk)

    to = alice_pk
    from = bob_pk
    amount = 10

    txn = Transaction.init(to, from, amount)
    txn_sign = Transaction.sign_transaction(txn, bob_sk)

    {atom, verify} = Transaction.check_valid_signature(txn, txn_sign, bob_pk)

    assert atom == :ok
  end

  test "creating transaction" do
    {:ok, bob_sk} = RsaEx.generate_private_key
    {:ok, bob_pk} = RsaEx.generate_public_key(bob_sk)

    {:ok, alice_sk} = RsaEx.generate_private_key
    {:ok, alice_pk} = RsaEx.generate_public_key(alice_sk)

    to = alice_pk
    from = bob_pk
    amount = 10

    txn = Transaction.init(to, from, amount)
    assert txn.amount == 10 and txn.to == alice_pk and txn.from == bob_pk
  end


end
