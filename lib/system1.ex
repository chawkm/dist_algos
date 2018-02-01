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
  @timeout 1_000
  @max_broadcasts 10_000_000
  @n 5

  def main do
    #N = 5
    # peers = for x <- 0..(@n - 1) do spawn(Peer, :start, [x]) end
    # server = Node.spawn(:'node2@container2.localdomain', Server, :start, [])
    pmap = for x <- 0..(@n - 1), into: %{}, do: {x, spawn(Peer, :start, [x])}
    peers = for {x, p} <- pmap do p end
    for p <- peers do send p, { :peers, peers, pmap } end

    for p <- peers do send p, { :broadcast, @max_broadcasts, @timeout} end
    #send Enum.at(peers, 0), {:hello}
    # send server, { :bind }
  end
end
