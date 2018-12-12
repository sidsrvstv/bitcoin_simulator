defmodule User do
  use GenServer

  #------------#
  # Client API #
  #------------#

  @doc """
    start the user actor
  """
  def start_link({public_key, private_key}) do
    GenServer.start_link(__MODULE__, {public_key, private_key}, name: via_tuple(public_key))
  end

  @doc """
  this is the function where a transaction gets created for a particular user
  transaction consists of the original transaction amount, miner reward and transaction fee
  then the block is mined
  after mining, the consensus happend on which user's block is to be accepted
  """
  def handle_transaction(public_key, transaction) do
    GenServer.call(via_tuple(public_key), {:handle_transaction, transaction, public_key}, 100_000 )
  end

  def get_latest_block(public_key) do
    GenServer.call(via_tuple(public_key), :get_latest_block)
  end

  # def add_block(public_key, block) do
  #   # IO.puts "arrived here"
  #   # IO.inspect block
  #   GenServer.call(via_tuple(public_key), {:add_block, block})
  # end

  @spec get_balance(any()) :: any()
  def get_balance(public_key) do
    {:ok, balance} = GenServer.call(via_tuple(public_key), {:get_balance, public_key})
    balance
  end

  # def get_complete_blockchain(public_key) do
  #   GenServer.call(via_tuple(public_key), :get_blockchain)
  # end

  # def get_lenght_of_chain(public_key) do
  #   GenServer.call(via_tuple(public_key), :get_chainlength)
  # end

  @doc """
  this is for receiving the block from a user who has mined
  """
  def mailbox(public_key, {key, block}) do
    GenServer.call(via_tuple(public_key), {:inbox, key, block} )
  end

  defp via_tuple(public_key) do
    {:via, :gproc, {:n, :l, {:user_name, public_key}}}
  end

  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one blockchain, the first block called the genesis block is put in place
    state is list of maps
  """
  def init({_public_key, _private_key}) do

    # BlockChainServer.start_link(private_key)
    state = %{:sent_vote => 0,
              :r_block => nil,
              :r_key => nil
    }

    {:ok, state}
  end

  def handle_call({:handle_transaction, transaction, public_key}, _from, state) do
    {:ok, data} = create_transaction(public_key, transaction)
    # id = Map.fetch!(state, :blockchain)
    # {:ok, block} = BlockChainServer.mine_block(id, data)
    {:ok, block} = BlockChainServer.mine_block(data)
    nodes = Topology.get_neighbors(public_key)
    new_state = if Map.fetch!(state, :r_key) == nil do
      Enum.each nodes , fn(key) ->
        User.mailbox(key, {public_key, block})
      end
      state1 = Map.put(state, :r_key, public_key) # reset after voting
      state2 = Map.put(state1, :r_block, block)
      state2
    else
      state
    end
    r_key = Map.fetch!(new_state, :r_key)
    r_block = Map.fetch!(new_state, :r_block)
    Consensus.send_vote(r_key, r_block)
    state1 = Map.put(new_state, :r_key, nil) # reset after voting
    state2 = Map.put(state1, :r_block, nil)

    {:reply, :ok, state2}

  end

  # def handle_call({:add_block, block}, _from, state) do
  #   # IO.inspect "reached till user"
  #   # exit(:shutdown)
  #   # id = Map.fetch!(state, :blockchain)
  #   # BlockChainServer.add_block(id, block)
  #   BlockChainServer.add_block(block)
  #   {:reply, :ok, state}
  # end

  def handle_call({:inbox, key, block}, _from, state) do
    state1 = Map.put(state, :r_key, key)
    state2 = Map.put(state1, :r_block, block)
    {:reply, :ok, state2}
  end

  defp create_transaction(public_key, transaction) do
    customer = Map.fetch!(transaction, :from)
    amount  = Map.fetch!(transaction, :amount)
    reward = Transaction.init(public_key, "None", 10) # init(to, from, amount) # reward not from any user
    fee = Transaction.init(public_key, customer, amount / 10) # init(to, from, amount)
    data = [transaction, reward, fee]
    {:ok, data}
  end

  # def handle_call(:get_chainlength, _from, state) do
  #   id = Map.fetch!(state, :blockchain)
  #   {:ok, len} = BlockChainServer.get_lenght_of_chain(id)
  #   {:reply, {:ok, len}, state}
  # end

  # def handle_call(:get_blockchain, _from, state) do
  #   id = Map.fetch!(state, :blockchain)
  #   {:ok, blockchain} = BlockChainServer.get_full_chain(id)
  #   {:reply, {:ok, blockchain}, state}
  # end

  # def handle_call(:get_latest_block, _from, state) do
  #   id = Map.fetch!(state, :blockchain)
  #   {:ok, block} = BlockChainServer.get_latest_block(id)
  #   {:reply, {:ok, block}, state}
  # end

  def handle_call({:get_balance, public_key}, _from, state) do
    # id = Map.fetch!(state, :blockchain )
    {:ok, blockchain} = BlockChainServer.get_full_chain() # list of blocks or maps
    balance = for i <- 1..length(blockchain) - 1 do
      block = Enum.at(blockchain, i)
      # IO.inspect block
      data = Map.fetch!(block, :data)
      # IO.puts "Siddharth"
      # IO.inspect data
      cur_sum = for i <- 0..length(data) -1 do
        txn = Enum.at(data, i)
        add = if Map.fetch!(txn, :to) == public_key do
          Map.fetch!(txn, :amount)
        else
          0
        end
        sub = if Map.fetch!(txn, :from) == public_key do
          Map.fetch!(txn, :amount) * -1
        else
          0
        end
        add + sub
      end
      Enum.sum(cur_sum)
    end
    # IO.inspect Enum.sum(balance)
    {:reply, {:ok, Enum.sum(balance)}, state}
  end

end
