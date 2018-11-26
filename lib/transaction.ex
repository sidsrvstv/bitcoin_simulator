defmodule Transaction do

    defstruct to: nil,
              from: nil,
              amount: 0

    def init(to_addr, from_addr, amt) do
        %Transaction{to: to_addr, from: from_addr, amount: amt}
    end

    def sign_transaction(txn, priv_key) do
        msg = get_message(txn)
        signature = sign(msg, priv_key)
        signature
    end

    def get_message(txn) do
        #concat and sign
        concat = txn.to <> txn.from <> Integer.to_string(txn.amount)
        :crypto.hash(:sha256, concat) |> Base.encode16
    end

    def sign(msg, priv_key) do
        {:ok, signature} = RsaEx.sign(msg, priv_key)
        signature
    end

    def check_valid_signature(txn, signature, pub_key) do
        msg = get_message(txn) #Not sure if we need to get message here.
        if txn.from != pub_key do
            err_msg = "One can only create transactions from their wallet."
            {:error, err_msg}
        else
            {:ok, valid} = RsaEx.verify(msg, signature, pub_key)
            if valid do
                {:ok, valid}
            else
                {:error, "Signature could not be verified."}
            end
        end
    end
end
