defmodule Wallet do
    defstruct priv_key: nil,
              pub_key: nil

    def init() do
        {:ok, sk} = RsaEx.generate_private_key
        {:ok, pk} = RsaEx.generate_public_key(sk)

        %Wallet{priv_key: sk, pub_key: pk}
    end

    def get_balance(pub_key, priv_key) do
        # blockchain = User.get_complete_blockchain(priv_key)
        # IO.inspect blockchain
        # balance = Enum.each blockchain, fn block ->
        #     curr = 0

        #     data = block.data
        #     IO.inspect data
            # val = Enum.each data fn(txn) ->
            #     tmp = 0
            #     a = if txn.to == pub_key do
            #         txn.amount
            #     else if txn.from == pub_key
            #         -txn.amount
            #     end
            #     tmp = tmp + a
            # end
            # curr = curr + val
            0

        # end

    end
end
