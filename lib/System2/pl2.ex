# Robert Holland (rh2515) and Chris Hawkes (ch3915)

defmodule PL do
    def start do
        # Receive binding to app
        app = receive do
          {:app, app} -> app
        end

        # Receive map of Peers to PLs
        receive do
            {:bind, pl_map} -> next(app, pl_map)
        end
    end

    def next(app, pl_map) do
        receive do
            {:pl_send, to, from, message} -> # Send message to Peer's PL
                send pl_map[to], {:pl_deliver, from, message}
            {:pl_deliver, from, message} -> # Relay message to app
                send app, {:pl_deliver, from, message}
        end
        next(app, pl_map)
    end
end
