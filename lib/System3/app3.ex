defmodule App3 do
    def start(n, system) do
        state = receive do
            { :peers, peers_list, pmap } ->
                %{:id => n, :peers => peers_list, :pmap => pmap}
        end

        beb = spawn(BEB, :start, [self(), system, state[:peers]])
        send system, {:beb, self(), beb}

        state = state |> Map.put(:beb, beb)

        updated_state = wait_begin_broadcast(state)
        next(updated_state)
    end

def wait_begin_broadcast(state) do
  receive do
      {:broadcast, max_broadcasts, timeout} ->
          # Start timeout
          Process.send_after(self(), :timeout, timeout)

          # Create variables to record messages sent and received
          received = for p <- state[:peers], into: %{}, do: {p, 0}

          # Add relevant variables to the program state
          state |> Map.put(:sent, 0)
                |> Map.put(:received, received)
                |> Map.put(:max_broadcasts, max_broadcasts)
                |> Map.put(:curr_broadcast, state[:peers])
  end
end

def next(state) do
    new_state = receive do
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
                state = update_in(state, [:sent], &(&1 + 1))
                update_in(state, [:max_broadcasts], &(&1 - 1))
            end
    end
    next(new_state)
end

def finish(%{:id => id, :sent => sent, :received => received} = state) do
    # Print {sent, received} order in order of peer number
    vals = for n <- 0..4 do "{#{sent}, #{received[state[:pmap][n]]}}" end
    IO.puts "#{id}: " <>  Enum.join(vals, " ")
    exit(:shutdown)
end

end
