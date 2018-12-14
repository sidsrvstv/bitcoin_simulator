defmodule Topology do
  use GenServer

  def start_link(keys) do
    GenServer.start_link(__MODULE__, keys, name: :topology)
  end

  def get_neighbors(node) do
    {:ok, neighbors} = GenServer.call(:topology, {:get_neighbors, node} )
    # IO.puts "here-->\n"
    # IO.inspect neighbors
    # exit(:shutdown)
    neighbors
  end

  def get_all_nodes do
    {:ok, nodes} = GenServer.call(:topology, :get_all)
    nodes
  end

  def get_number_of_nodes do
    {:ok, number} = GenServer.call(:topology, :get_count)
    number
  end
  def init(keys) do
    state = keys
    {:ok, state}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call(:get_count, _from, state) do
    {:reply, {:ok, length(state)}, state}
  end

  def handle_call({:get_neighbors, node}, _from, state) do
    neighborsList =  Enum.filter(state, fn x -> x != node end)
    {:reply, {:ok, neighborsList}, state}
  end


end
