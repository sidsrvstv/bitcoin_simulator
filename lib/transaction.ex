defmodule Transaction do
    # defstruct to: nil,
    #           from: nil,
    #           amount: 0,
    
    def init(to, from, amount, priv_key) do
        msg = get_message(to, from, amount)
        signature = sign(msg, priv_key)
        signature
    end

    def get_message(to, from, amount) do
        #concat and sign
        concat = to <> from <> Integer.to_string(amount)
        :crypto.hash(:sha256, concat) |> Base.encode16
    end

    def sign(msg, priv_key) do
        {:ok, signature} = RsaEx.sign(msg, priv_key)
        signature
    end

    def check_valid_signature(to, from, amount, signature, pub_key) do
        msg = get_message(to, from, amount) #Not sure if we need to get message here.
        if from != pub_key do
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