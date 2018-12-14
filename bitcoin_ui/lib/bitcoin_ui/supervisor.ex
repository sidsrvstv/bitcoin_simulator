# defmodule BlockChainSupervisor do
#   use Supervisor

#   def start_link do
#     # We are now registering our supervisor process with a name
#     # so we can reference it in the `start_user/1` function
#     Supervisor.start_link(__MODULE__, [], name: :user_supervisor)
#   end

#   def start_user(name) do
#     # And we use `start_child/2` to start a new BlockChainServer process
#     Supervisor.start_child(:user_supervisor, [name])
#   end

#   def init(_) do
#     children = [
#       worker(BlockChainServer, [])
#     ]

#     # no process is started during the Supervisor initialization,
#     # just when we call `start_child/2`
#     supervise(children, strategy: :simple_one_for_one)
#   end

# end
