defmodule BEB4 do
    def start(app, system, peers_list) do
        pl = spawn(PL_lossy, :start, [self(), 50])
        send system, {:pl, app, pl}

        next(app, pl, peers_list)
    end

    def next(app, pl, peers_list) do
        receive do
            {:beb_broadcast, message} ->
                for peer <- peers_list do
                    send pl, {:pl_send, peer, app, message}
                end
            {:pl_deliver, from, message} ->
                send app, {:beb_deliver, from, message}
        end
        next(app, pl, peers_list)
    end
end
