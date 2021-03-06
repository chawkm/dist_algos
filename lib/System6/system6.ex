# Robert Holland (rh2515) and Chris Hawkes (ch3915)

defmodule System6 do
  @n 5
  @faulty_peer 3

  def main(timeout, max_broadcasts, reliability \\ 100, local \\ true) do
    faulty_termination_time = 5
    termination_times = List.replace_at(List.duplicate(:infinity, @n), @faulty_peer, faulty_termination_time)
    id_peer_map = if local do
      for x <- 0..(@n - 1), into: %{}, do: {x, spawn(Peer6, :start, [x, self(), reliability, Enum.at(termination_times, x)])}
    else
      for x <- 0..(@n - 1), into: %{}, do: {x, Node.spawn(:'peer#{x}@peer#{x}.localdomain', Peer6, :start, [x, self(), reliability, Enum.at(termination_times, x)])}
    end

    peers = for {_, p} <- id_peer_map do p end

    # Send each peer the list of peers
    for p <- peers do send p, { :peers, peers, id_peer_map } end

    # Collect bindings of Peers to PL links
    pl_map = collect_pls(@n, %{})

    # Send to each PL the mapping from Peer to PL
    bind_pls(pl_map)

    # Notify peers to begin broadcasting
    for p <- peers do send p, { :broadcast, max_broadcasts, timeout} end
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
