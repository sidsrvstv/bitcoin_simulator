Siddharth Srivastava - 6316 6628
Nanda Kishore - 6239 6049

# BitcoinSimulator

**Module description**

The module `User` creates an actor(GenServer) for User. Its state has its wallet and starts a blockchain server (another GenServer). All the methods of BlockChain server are accesed through User. 

The module `BlockChainServer` is a GenServer for BlockChain> Every user has its own BlockChainServer instance. Its initial state is the genesis block. It is a list of Block servers.

The module `Block` is a GenServer which forms the primary data structure in our system. Its initial state is basically a map which contains, `data` which is a list of `Transaction` objects. `Data` is made of original transaction, miner reward and miner transaction fees. `Block` also contains a key for hash to previous block, a key to store hash of its self, and a key for storing the nonce value.


The module `Transaction` creates a struct for the transaction. This struct holds public key of the recipient in `to` and public key of the sender in `from` and the number of bitcoins being transferred in `amount`. This module also has methods to sign a transaction and verify a signed transaction.

The module `Wallet` creates a struct for the wallet. This struct hold the public key and private key of the user to whom this wallet belongs in `pub_key` and `priv_key`. The module also has a method to get balance of the user by parsing the entire blockchain and calculating his balance.

## Installation

Please run the following commands to run the application
$> mix deps.get
The above command because our app uses two dependencies, gproc and rsaex

$> mix compile


$> mix test


## TestCase description

Each testcase has been given a meaningful header and comments have been added. We have added testcases to check 
1. transactions being added to blockchain
2. correctness of hashes
3. transaction signatures and verifications
4. createing transactions


