defmodule Peer1 do

def start(n) do
  receive do
    { :peers, peers_list, pmap } ->
        state = %{:id => n, :peers => peers_list, :pmap => pmap}
        state = wait_begin_broadcast(state)
        next(state)
  end
end

def wait_begin_broadcast(state) do
  receive do
      {:broadcast, max_broadcasts, timeout} ->
          # Start timeout
          Process.send_after(self(), :timeout, timeout)

          # Create variables to record messages sent and received
          sent = for p <- state[:peers], into: %{}, do: {p, 0}
          received = for p <- state[:peers], into: %{}, do: {p, 0}

          # Add relevant variables to the program state
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
        {:message, q} ->
            # Update state to declare another message was received from peer q
            update_in(state, [:received, q], &(&1 + 1))
    after
        0 ->
            case state do
                %{:curr_broadcast => []} ->
                    state = update_in(state, [:max_broadcasts], &(&1 - 1))
                    if state[:max_broadcasts] <= 0 do
                        # All messages broadcast, so spin wait until timeout
                        state
                    else
                        # Refill list of peers to broadcast to
                        put_in(state, [:curr_broadcast], state[:peers])
                    end
                %{:curr_broadcast => [p | ps]} ->
                    # Send message to the next peer in the broadcast list
                    send p, {:message, self()}
                    # Record that a message was sent to this peer
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
