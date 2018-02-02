defmodule System2 do
  @timeout 10_000
  @max_broadcasts 50_000
  @n 5

  def main do
    #N = 5
    # peers = for x <- 0..(@n - 1) do spawn(Peer, :start, [x]) end
    # server = Node.spawn(:'node2@container2.localdomain', Server, :start, [])
    pmap = for x <- 0..(@n - 1), into: %{}, do: {x, spawn(App2, :start, [x, self()])}
    pl_map = collect_pls(@n, %{})
    bind_pls(pl_map)

    peers = for {_, p} <- pmap do p end
    for p <- peers do send p, { :peers, peers, pmap } end

    for p <- peers do send p, { :broadcast, @max_broadcasts, @timeout} end
    #send Enum.at(peers, 0), {:hello}
    # send server, { :bind }
  end

  def collect_pls(0, pl_map) do
    pl_map
  end

  def collect_pls(n, pl_map) do
    new_pl_map = receive do
        {:pl, app, pl} -> Map.put(pl_map, app, pl)
    end
    collect_pls(n-1, new_pl_map)
  end

  def bind_pls(pl_map) do
    for {_, pl} <- pl_map do 
        send pl, {:bind, pl_map} 
    end
  end

end