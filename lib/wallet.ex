defmodule Wallet do
    defstruct priv_key: nil,
              public_key: nil
    
    def init() do
        {:ok, sk} = RsaEx.generate_private_key
        {:ok, pk} = RsaEx.generate_public_key(sk)

        %Wallet{priv_key: sk, public_key: pk}
    end

    def get_balance() do
        
    end
end