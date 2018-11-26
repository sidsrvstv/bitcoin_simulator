defmodule User do
  use GenServer

  #------------#
  # Client API #
  #------------#

  @doc """
    start the user actor
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end




  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:user_name, name}}}
  end

  #------------#
  # Server API #
  #------------#

  @doc """
    initialize one blockchain, the first block called the genesis block is put in place
    state is list of maps
  """
  def init(name) do
    {:ok, name_sk} = RsaEx.generate_private_key
    {:ok, name_pk} = RsaEx.generate_public_key(name_sk)

    {:ok, block_pid} = BlockChainServer.start_link(name)
    state = %{:sk => name_sk,
              :pk => name_pk,
              :blockchain => name
    }

    {:ok, state}
  end

end
