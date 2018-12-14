defmodule Coord do
    @derive [Poison.Encoder]
    defstruct [:x, :y]
end

defmodule Graph do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: :graph)
    end

    def add_transaction(data) do
        GenServer.call(:graph, {:add_transaction, data})
    end

    def update_balance(data) do
        GenServer.call(:graph, {:update_balance, data})
    end

    def nonce(data) do
        GenServer.call(:graph, {:nonce, data})
    end

    def init(_) do
        state = %{ :transactions => [], :balance => Map.new(), :nonce => [], :counter => 1}

        {:ok, state}
    end

    def handle_call({:nonce, data}, _from, state) do
        nonce_obj = %Coord{x: Map.get(state, :counter), y: data}

        state = Map.put(state, :nonce, state.nonce ++ [nonce_obj])
        state = Map.put(state, :counter, state.counter+1)

        #IO.inspect state.nonce

        File.write("./priv/data/nonce.json", Poison.encode!(state.nonce), [:json])

        {:reply, :ok, state }
    end

    def handle_call({:add_transaction, data}, _from, state) do
        transaction = %Coord{x: :os.system_time(:milli_seconds), y: data}
        state = Map.put(state, :transactions, state.transactions ++ [transaction])

        IO.inspect state.transactions

        File.write("./priv/data/transaction_time.json", Poison.encode!(state.transactions), [:json])

        {:reply, :ok, state }
    end

    def handle_call({:update_balance, data}, _from, state) do
        # IO.inspect state
        # IO.puts  "+++"
        user = Enum.at(data, 0)
        amount = Enum.at(data, 1)
        map_balance = Map.fetch!(state, :balance)
        new_map_balance = Map.put(map_balance, user, amount) # replaces old if present else just adds new key
        new_state = Map.put(state, :balance, new_map_balance) # replace old map with new

        # IO.inspect new_state
        # IO.puts "+++"

        # state =
        # if get_in(state, [:balance, data[0]]) == nil do
        #     put_in(state, [:balance, data[0]], data[1])
        # else
        #     put_in(state, [:balance, data[0]], data[1])
        # end

        # IO.inspect state.balance
        all_users = Map.keys(new_map_balance)
        # keys = Map.get(state, :balance)
        # IO.inspect keys
        # IO.puts "-----"
        balance_arr = add_bal([], all_users, new_map_balance)

        File.write("./priv/data/balance.json", Poison.encode!(balance_arr), [:json])

        {:reply, :ok, new_state }
    end

    def add_bal(list, [], _state) do
        list
    end

    def add_bal(list, keys, map) do
        [key | tail] = keys

        bal = Map.fetch!(map, key)
        # bal = get_in(state, [:balance, key])
        bal_obj = %Coord{x: key, y: bal}
        # IO.puts "#{key} == #{bal}"
        # IO.puts "+++++++++++++++"
        list = list ++ [bal_obj]
        add_bal(list, tail, map)
    end
end
