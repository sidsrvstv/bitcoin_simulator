defmodule BitcoinSimulatorTest do
  use ExUnit.Case
  doctest BitcoinSimulator

  test "greets the world" do
    assert BitcoinSimulator.hello() == :world
  end
end
