defmodule BEB do
    def start app do
        receive do
            {:bind, pl_map} -> next(app, pl_map)
        end
    end

    def next(app, pl_map) do
        receive do
            {:beb_broadcast, message} ->
                for {_, pl} <- pl_map do
                    send pl, {:pl_send, app, message}
                end
            {:pl_deliver, from, message} ->
                send app, {:beb_deliver, from, message}
        end
        next(app, pl_map)
    end
end