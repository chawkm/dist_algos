defmodule PL_lossy do
    def start(app, loss) do
        receive do
            {:bind, pl_map} -> next(app, pl_map, loss)
        end
    end

    def next(app, pl_map, loss) do
        receive do
            {:pl_send, to, from, message} ->
                if :rand.uniform(100) <= loss do
                  send pl_map[to], {:pl_deliver, from, message}
                end
            {:pl_deliver, from, message} ->
                send app, {:pl_deliver, from, message}
        end
        next(app, pl_map, loss)
    end
end
