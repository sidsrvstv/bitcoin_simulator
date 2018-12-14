defmodule Person do
  @derive [Poison.Encoder]
  defstruct [:name, :age]
end

defmodule BitcoinUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      BitcoinUiWeb.Endpoint
      # Starts a worker by calling: BitcoinUi.Worker.start_link(arg)
      # {BitcoinUi.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BitcoinUi.Supervisor]
    Supervisor.start_link(children, opts)

    # spawn(BitcoinUi.Application, :generate_random_values,[])
    # spawn(BitcoinUi.Application, :generate_random_values2,[])
    total_users = ["100"] #System.argv()
    
    BitcoinSimulator.main(total_users)

    {:ok, self()}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BitcoinUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
