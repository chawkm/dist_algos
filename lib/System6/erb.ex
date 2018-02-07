defmodule ERB do
    def start(beb) do
        app = receive do
          {:app, app} -> app
        end
        IO.puts inspect(app)
        next(app, beb, MapSet.new)
    end

    def next(app, beb, delivered) do
        receive do
            {:rb_broadcast, message} ->
                send beb, {:beb_broadcast, {:rb_data, Time.utc_now(), message}}
                next app, beb, delivered
            {:beb_deliver, from, {:rb_data, t, message} = rb_m} ->
                if MapSet.member? delivered, t do
                    next app, beb, delivered
                else
                    send app, {:rb_deliver, from, message}
                    send beb, {:beb_broadcast, rb_m}
                    next app, beb, MapSet.put(delivered, t)
                end
        end
    end
end
