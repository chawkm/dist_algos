# Robert Holland (rh2515) and Chris Hawkes (ch3915)

defmodule System1 do
  @moduledoc """
  Documentation for System1.
  """

  @doc """
  Hello world.

  ## Examples

      iex> System1.hello
      :world

  """
  #@timeout 1_000
  #@max_broadcasts 50_000
  @n 5

  def main(timeout, max_broadcasts, reliability \\ 100, local \\ true) do
    #N = 5
    # peers = for x <- 0..(@n - 1) do spawn(Peer, :start, [x]) end
    # server = Node.spawn(:'node2@container2.localdomain', Server, :start, [])
    # IO.puts :net_adm.ping(:'peer1@peer1.localdomain')
    pmap = if local do
      for x <- 0..(@n - 1), into: %{}, do: {x, spawn(Peer1, :start, [x])}
    else
      for x <- 0..(@n - 1), into: %{}, do: {x, Node.spawn(:'peer#{x}@peer#{x}.localdomain', Peer1, :start, [x])}
    end
    # pmap = for x <- 0..(@n - 1), into: %{}, do: {x, spawn(Peer1, :start, [x])}
    peers = for {_, p} <- pmap do p end
    for p <- peers do send p, { :peers, peers, pmap } end

    for p <- peers do send p, { :broadcast, max_broadcasts, timeout} end
    #send Enum.at(peers, 0), {:hello}
    # send server, { :bind }
  end
end
