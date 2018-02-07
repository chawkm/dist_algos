defmodule ERB do
    def start(beb) do
        app = receive do
          {:app, app} -> app
        end
        IO.puts inspect(app)
        next(app, beb, MapSet.new, 0)
    end

    def next(app, beb, delivered, n) do
        receive do
            {:rb_broadcast, message} ->
                send beb, {:beb_broadcast, {:rb_data, app, n, message}}
                next app, beb, delivered, (n + 1)
            {:beb_deliver, from, {:rb_data, _, _, message} = rb_m} ->
                if MapSet.member? delivered, rb_m do
                    next app, beb, delivered, n
                else
                    send app, {:rb_deliver, from, message}
                    send beb, {:beb_broadcast, rb_m}
                    next app, beb, MapSet.put(delivered, rb_m), n
                end
        end
    end
end
