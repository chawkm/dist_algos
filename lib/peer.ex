defmodule Peer do
 

def start(n) do
  IO.puts ["Peer at ", DNS.my_ip_addr(), inspect(self())]
  receive do
    { :peers, peers_list, pmap } ->
        state = %{:id => n, :peers => peers_list, :pmap => pmap}
        next(state)
  end
end

def next(state) do
    receive do
        {:broadcast, max_broadcasts, timeout} ->
            # start timeout
            Process.send_after(self(), :timeout, timeout)
            #IO.puts ["received ", inspect(self()), max_broadcasts]
            sent = for p <- state[:peers], into: %{}, do: {p, 0}
            received = for p <- state[:peers], into: %{}, do: {p, 0}

            state = Map.put(state, :sent, sent)
            state = Map.put(state, :received, received)
            state = Map.put(state, :max_broadcasts, max_broadcasts)
            broadcast(state)
    end
end

def broadcast(%{:max_broadcasts => 0} = state) do
    # Finished broadcasting only receive messages no
    # IO.puts "0"
    finish(state)
end

def broadcast(state) do
    state = send_all(state, state[:peers])
    # IO.puts "#{state[:max_broadcasts]}"
    broadcast(%{state | :max_broadcasts => state[:max_broadcasts] - 1})
end

def send_all(state, [p | peers]) do
    # IO.puts "send all #{inspect peers}"
    {new_state, tail} = receive do
        :timeout ->
            # IO.puts "timeout"
            finish(state)
        {:message, q} ->
            # received = %{received | q => received[q] + 1}
            {update_in(state, [:received, q], &(&1 + 1)), [p | peers]}
    after
        0 -> 
            send p, {:message, self()}
            # sent = %{sent | p => sent[p] + 1}
            {update_in(state, [:sent, p], &(&1 + 1)), peers}
            # {put_in(state, [:peers], peers)
    end
    send_all(new_state, tail)
end

# def send_all(state, [p | peers]) do
#     # IO.puts "send all #{inspect peers}"
#     {new_state, tail} = receive do
#         :timeout ->
#             IO.puts "timeout"
#             finish(state)
#         {:message, q} ->
#             # received = %{received | q => received[q] + 1}
#             {update_in(state, [:received, q], &(&1 + 1)), [p | peers]}
#     after
#         0 -> 
#             send p, {:message, self()}
#             # sent = %{sent | p => sent[p] + 1}
#             {update_in(state, [:sent, p], &(&1 + 1)), peers}
#             # {put_in(state, [:peers], peers)
#     end
#     send_all(new_state, tail)
# end

def send_all(state, []) do
    state
end

def finish(%{:id => id, :sent => sent, :received => received} = state) do
    # vals = for {key, val} <- sent do "{#{val}, #{received[key]}}" end
    vals = for n <- 0..4 do "{#{state[:sent][state[:pmap][n]]}, #{state[:received][state[:pmap][n]]}}" end
    IO.puts "#{id}: " <>  Enum.join(vals, " ")
    exit(:shutdown)
end

end