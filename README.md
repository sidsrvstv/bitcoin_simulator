Siddharth Srivastava - 6316 6628
Nanda Kishore - 6239 6049

# BitcoinSimulator

**Module description**

The module `User` creates an actor(GenServer) for User. Its state has its wallet and starts a blockchain server (another GenServer). All the methods of BlockChain server are accesed through User. 

The module `BlockChainServer` is a GenServer for BlockChain. Every user has its own BlockChainServer instance. Its initial state is the genesis block. It is a list of Block servers.

The module `Block` is a GenServer which forms the primary data structure in our system. Its initial state is basically a map which contains, `data` which is a list of `Transaction` objects. `Data` is made of original transaction, miner reward and miner transaction fees. `Block` also contains a key for hash to previous block, a key to store hash of its self, and a key for storing the nonce value.


The module `Transaction` creates a struct for the transaction. This struct holds public key of the recipient in `to` and public key of the sender in `from` and the number of bitcoins being transferred in `amount`. This module also has methods to sign a transaction and verify a signed transaction.

The module `Wallet` creates a struct for the wallet. This struct hold the public key and private key of the user to whom this wallet belongs in `pub_key` and `priv_key`. The module also has a method to get balance of the user by parsing the entire blockchain and calculating his balance.

Unit Test description
1) add transactions and check length of blockchain : This unit test creates three users. It creates some transactions among these users and user mine these transaction and checks the length of the blockchain.
2) correctness of hashes: This unit test creates two users and adds a transaction between them and mines the transaction. It then checks the correctness of the hash i.e., if the number of zeros are correct.
3) calculated hash is same as stored hash : This unit test creates two users and adds a transaction between them and mines the transaction. It then independently calculates the hash and checks if this is same as that in the block.
4) transaction signature and verification : This unit test creates a transaction, signs it and verifies if the signature is valid.
5) creating transaction : This unit test creates a transaction and check if the transaction has all object as per what we have given it.
6) wallet keys : This unit test create a wallet object and checks if private key and corresponding public are created.
7) "transaction scenario 1": This is scenerio test that creats two users, gives them an intial balance and creates a transaction between them and verifies the balance and block chain.
8) "invalid transaction" : This is scenerio test that creats two users, gives them an intial balance and creates an invalid transaction between them.
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


