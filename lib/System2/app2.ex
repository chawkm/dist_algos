defmodule App2 do
    def start(n, system) do
        pl = spawn(PL, :start, [self()])
        send system, {:pl, self(), pl}

        receive do
            { :peers, peers_list, pmap } ->
                state = %{:id => n, :peers => peers_list, :pmap => pmap, :pl => pl}
                state = wait_begin_broadcast(state)
                next(state)
        end
    end

def wait_begin_broadcast(state) do
  receive do
    {:broadcast, max_broadcasts, timeout} ->
        Process.send_after(self(), :timeout, timeout)
        sent = for p <- state[:peers], into: %{}, do: {p, 0}
        received = for p <- state[:peers], into: %{}, do: {p, 0}

        state |> Map.put(:sent, sent)
              |> Map.put(:received, received)
              |> Map.put(:max_broadcasts, max_broadcasts)
              |> Map.put(:curr_broadcast, state[:peers])
  end
end

def next(state) do
    new_state = receive do
        :timeout ->
            finish(state)
        {:pl_deliver, q, :message} ->
            update_in(state, [:received, q], &(&1 + 1))
    after
        0 ->
            case state do
                %{:curr_broadcast => []} ->
                    state = update_in(state, [:max_broadcasts], &(&1 - 1))
                    if state[:max_broadcasts] <= 0 do
                        # Spin wait until timeout
                        state
                    else
                        put_in(state, [:curr_broadcast], state[:peers])
                    end
                %{:curr_broadcast => [p | ps]} ->
                    send state[:pl], {:pl_send, p, self(), :message}
                    state |> update_in([:sent, p], &(&1 + 1))
                          |> put_in([:curr_broadcast], ps)
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
