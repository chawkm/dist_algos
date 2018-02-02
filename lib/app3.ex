defmodule App3 do
    def start(n, system) do
        beb = spawn(BEB, :start, [self()])
        send system, {:beb, self(), beb}

        receive do
            { :peers, peers_list, pmap } ->
                state = %{:id => n, :peers => peers_list, :pmap => pmap, :beb => beb}
                next(state)
        end
    end

def next(state) do
    new_state = receive do
        {:broadcast, max_broadcasts, timeout} ->
            Process.send_after(self(), :timeout, timeout)
            sent = for p <- state[:peers], into: %{}, do: {p, 0}
            received = for p <- state[:peers], into: %{}, do: {p, 0}

            state |> Map.put(:sent, sent)
                  |> Map.put(:received, received)
                  |> Map.put(:max_broadcasts, max_broadcasts)
                  |> Map.put(:curr_broadcast, state[:peers])
        :timeout ->
            finish(state)
        {:beb_deliver, q, :message} ->
            update_in(state, [:received, q], &(&1 + 1))
    after
        0 ->
            if state[:max_broadcasts] <= 0 do
                state
            else
                send state[:beb], {:beb_broadcast, :message}
                update_in(state, [:max_broadcasts], &(&1 - 1))
            end
    end
    next(new_state)
end

def finish(%{:id => id, :sent => sent, :received => received} = state) do
    # Print {sent, received} order in order of peer number
    vals = for n <- 0..4 do "{#{sent[state[:pmap][n]]}, #{received[state[:pmap][n]]}}" end
    IO.puts "#{id}: " <>  Enum.join(vals, " ")
    exit(:shutdown)
end

end