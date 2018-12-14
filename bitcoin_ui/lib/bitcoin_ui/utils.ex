defmodule Utils do
  @doc """
    calculate hash
  """
  def calculate_hash([data, hash, nonce ]) do
    inputs = [Kernel.inspect(data), hash, nonce ]
    :crypto.hash(:sha256, inputs) |> Base.encode16
  end

end
