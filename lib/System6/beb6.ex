# Robert Holland (rh2515) and Chris Hawkes (ch3915)

defmodule BEB6 do
    def start(pl, peers_list, peer) do
        caller = receive do
          {:caller, caller} -> caller
        end

        next(caller, pl, peers_list, peer)
    end

    def next(caller, pl, peers_list, peer) do
        receive do
            {:beb_broadcast, message} ->
                for p <- peers_list do
                    send pl, {:pl_send, p, peer, message}
                end
            {:pl_deliver, from, message} ->
                send caller, {:beb_deliver, from, message}
        end
        next(caller, pl, peers_list, peer)
    end
end
