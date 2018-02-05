defmodule PL_lossy do
    def start app do
        receive do
            {:bind, pl_map} -> next(app, pl_map)
        end
    end

    def next(app, pl_map) do
        receive do
            {:pl_send, to, from, message} ->
                send pl_map[to], {:pl_deliver, from, message}
            {:pl_deliver, from, message} ->
                send app, {:pl_deliver, from, message}
        end
        next(app, pl_map)
    end
end
