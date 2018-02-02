defmodule Peer1 do
 

def start(n) do
  IO.puts ["Peer at ", DNS.my_ip_addr(), inspect(self())]
  receive do
    { :peers, peers_list, pmap } ->
        state = %{:id => n, :peers => peers_list, :pmap => pmap}
        next(state)
  end
end

def next(state) do
    new_state = receive do
        {:broadcast, max_broadcasts, timeout} ->
            # start timeout
            Process.send_after(self(), :timeout, timeout)
            #IO.puts ["received ", inspect(self()), max_broadcasts]
            sent = for p <- state[:peers], into: %{}, do: {p, 0}
            received = for p <- state[:peers], into: %{}, do: {p, 0}

            state |> Map.put(:sent, sent)
                  |> Map.put(:received, received)
                  |> Map.put(:max_broadcasts, max_broadcasts)
                  |> Map.put(:curr_broadcast, state[:peers])
            # state = Map.put(state, :max_broadcasts, max_broadcasts)
            # state = Map.put(state, :curr_broadcast, state[:peers]) #for p <- state[:peers] do: p)
            # state
        :timeout ->
            finish(state)
        {:message, q} ->
            update_in(state, [:received, q], &(&1 + 1))
    after
        0 ->
            case state do
                %{:curr_broadcast => []} ->
                    state = update_in(state, [:max_broadcasts], &(&1 - 1))
                    if state[:max_broadcasts] <= 0 do
                        #finish(state)
                        # Spin wait till timeout
                        state
                    else
                        put_in(state, [:curr_broadcast], state[:peers])
                    end
                %{:curr_broadcast => [p | ps]} -> 
                    send p, {:message, self()}
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