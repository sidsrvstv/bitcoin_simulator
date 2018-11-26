# BitcoinSimulator

**TODO: Add description**

The module `Transaction` creates a struct for the transaction. This struct holds public key of the recipient in `to` and public key of the sender in `from` and the number of bitcoins being transferred in `amount`. This module also has methods to sign a transaction and verify a signed transaction.

The module `Wallet` creates a struct for the wallet. This struct hold the public key and private key of the user to whom this wallet belongs in `pub_key` and `priv_key`. The module also has a method to get balance of the user by parsing the entire blockchain and calculating his balance.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bitcoin_simulator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bitcoin_simulator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bitcoin_simulator](https://hexdocs.pm/bitcoin_simulator).

