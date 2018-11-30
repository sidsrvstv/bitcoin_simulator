defmodule BitcoinSimulatorTest do
  use ExUnit.Case

  setup do
    {:ok, blockchain} = BlockChainServer.start_link("1") # referring to blockchain by number ("1") not pid in code
    {:ok, server: blockchain}
  end

  test "add transactions and check length of blockchain" do
    tx1 = ["seller: Alice, buyer: Bob, amount = 10"]
    tx2 = ["seller: Alice, buyer: Charlie, amount = 20"]
    tx3 = ["seller: Bob, buyer: Charlie, amount = 15"]

    {:ok, block1} = BlockChainServer.mine_block("1", tx1) # mine block
    BlockChainServer.add_block("1",block1) # add block to blockchain

    {:ok, block2} = BlockChainServer.mine_block("1", tx2)
    BlockChainServer.add_block("1",block2)

    {:ok, block3} = BlockChainServer.mine_block("1", tx3)
    BlockChainServer.add_block("1",block3)


    assert BlockChainServer.get_lenght_of_chain("1") == {:ok, 4} # genesis block is added upon initialization

  end

  test "correctness of hashes" do
    tx = ["seller: Bob, buyer: Charlie, amount = 10"]
    {:ok, block} = BlockChainServer.mine_block("1", tx)
    BlockChainServer.add_block("1",block)

    {:ok, block} = BlockChainServer.get_latest_block("1")
    data = Map.fetch!(block, :data)
    previous_hash = Map.fetch!(block, :previous_hash)
    nonce = Map.fetch!(block, :nonce)

    difficulty = 2
    target = String.duplicate("0", difficulty)
    calculated_hash = [data, previous_hash, Kernel.inspect(nonce)]
    |> Utils.calculate_hash

    assert String.slice(calculated_hash, 0..difficulty-1) == target

  end

  test "calculated hash is same as stored hash" do
    tx = ["seller: Bob, buyer: Charlie, amount = 10"]
    {:ok, block} = BlockChainServer.mine_block("1", tx)
    BlockChainServer.add_block("1",block)

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

  test "wallet keys" do
    wallet = Wallet.init()

    txt = "message"

    {:ok, encrypted_txt} = RsaEx.encrypt(txt, {:private_key, wallet.priv_key})

    {:ok, decrypted_txt} = RsaEx.decrypt(encrypted_txt, {:public_key, wallet.pub_key})

    assert decrypted_txt == txt
  end


  test "transaction scenario 1" do
    # start users
    User.start_link("alice") # please note that in all transactions are in terms of hashes i.e. public keys
    User.start_link("bob") # anonymity is maintained, the names are for convinience

    from = "None"
    {:ok, to_alice} = User.get_publickey("alice")
    {:ok, to_bob} = User.get_publickey("bob")
    amount = 10

    txn_alice = Transaction.init(to_alice, from, amount)
    txn_bob = Transaction.init(to_bob, from, amount)

    # for starting the system, we are going to add a few blocks for giving starting credit to users
    # data1 = Kernel.inspect(txn_alice)
    {:ok, block} = User.mine_block("alice", txn_alice)
    User.add_block("alice",block)
    User.add_block("bob",block)

    # data2 = Kernel.inspect(txn_bob)
    {:ok, block} = User.mine_block("alice", txn_bob)
    User.add_block("alice",block)
    User.add_block("bob",block)

    assert User.get_lenght_of_chain("alice") == User.get_lenght_of_chain("bob")
  end

end
