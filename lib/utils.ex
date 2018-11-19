defmodule Utils do
  @doc """
    calculate hash
  """
  def calculate_hash(inputs) do
    :crypto.hash(:sha256, inputs) |> Base.encode16
  end
end
