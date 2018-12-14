
Siddharth Srivastava - 6316 6628
Nanda Kishore - 6239 6049

# BitcoinSimulator

**Distributed Protocol description**

Each user is a GenServer actor, and all of them are miners in our system. We decide which block gets added to the blockchain by holding a vote, thus establishing a distributed consensus. 

Everytime a transaction starts, it is broadcasted to all users and they would start mining. The Users check if they have received a message in their mailbox regarding someone else mining before them, if yes, they would discard their block. A voting is done to decide which block has reached the most users. This voting is overlooked by the actor `Consensus`, which decides the winner and the winning block is broadcasted to be added to the BlockChain. 


**Module Description**

In addition to User, BlockChain, Block, Transaction and Wallet modules, we introduce two new module called Topology and Consensus. It is an actor (GenServer) which contains all the public keys and can be accessed for getting a list of all keys, all neighboring keys (neighbors of a user). We use a full network topology, which implies that all users are connected to all other users. 
Consensus helps overlook voting for a particular transaction.

A brief description of the modules is as follows:

`Transaction` : The Transaction data strucure consisting of `from`, `to` and `amount` fields. 
`Wallet` : Responsible for generating public and private keys for users.
`Block` : A single unit of transaction, its a map which contains keys `data` which contains the transaction details consisting of orginal transaction, miner reward and transaction fee information. Miner reward and Transaction fees are `Transaction` type objects.
`BlockChain` : A list of Blocks
`User` : All users are genservers. A user is accessed through its public key. It is responsible for creating its own transaciton data, mining and broadcasting to all users messages and blocks.
`Consensus`: A GenServer which keeps tally of votes for every transaction. Every vote is a tuple of public_key and block which all users have received in their mailbox for a particular transaction. The winner of the voting is added to the blockchain. In case of ties, the block which had reached the consensus actor first is the winner
`Topology`: It maintains the network connection. It can be accessed to get list of all users keys and neigbors for a particular user.


All user balances are calculated by traversing the blockchain, no seperate fields for account balance are maintained. 


## Installation and Running

**For TestCases**
$> mix deps.get
The above command because our app has some dependencies.

$> mix compile
To compile the app

To run the tests, please use the following command
$> mix test test/bitcoin_simulator_test.exs 

** For Web Interface **

Please run the following commands to run the application
$> cd bitcoin_ui/

$> mix deps.get
The above command because our app has some dependencies.

$> mix phx.server

This starts pheonix server which also starts the simulation for 100 users. and also hosts the webpoints. After running this command, using your browser to visit localhost:4000 will show you the graphs we have built. 


The number of transactions has been hard coded in the code. We tried upto 100 Users and 1000 transactions for which our system took about 90 minutes to complete.

We also output several files to help the user see the results like 
	- transaction.txt which consists of every transaction that was valid. 
	- user_balance.txt which contains balance of all users after every valid transaction
	- miner_name.txt which tells which user was the miner for every valid transaction



## TestCase description

All users start with an initial balance of 50 BTC. These have been accounted for in the BlockChain.

1. "transaction between two parties with from user as miner" : This testcase has two users as transacting parties. Here I have deliberately given the transaction to one user later than the other to show the miner reward and the transaction fee. In this testcase, the `from` user is also the miner and gets the mining reward of 10BTC, is also charged a transaction fee of 10% of transaction amount but since it is the miner, it gets the fee back. The calculation has been shown in the comments for easier understanding.

2. "transaction between two parties with to user as miner" : This testcase is the same as above but with the miner changed from `from` user to `to` user. The calculation has been shown in the comments for easier understanding.

3. "transaction between multiple parties" : In this testcase, I hold a transaction between two parties but two others also present as miners. A non transacting party has been delibertely made to mine and the resulting balances of all 4 users have been shown. The calculation is present in the comments of the test case for understanding and verification.

4. "multiple transactions between multiple parties" : Here we show 2 transactions between 4 parties. The miners are deliberately made different. Calculations have been written down in comments for verification. 



