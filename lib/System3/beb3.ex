defmodule BEB3 do
    def start(pl, peers_list, peer) do
        app = receive do
          {:app, app} -> app
        end

        next(app, pl, peers_list, peer)
    end

    def next(app, pl, peers_list, peer) do
        receive do
            {:beb_broadcast, message} ->
                for p <- peers_list do
                    send pl, {:pl_send, p, peer, message}
                end
            {:pl_deliver, from, message} ->
                send app, {:beb_deliver, from, message}
        end
        next(app, pl, peers_list, peer)
    end
end
