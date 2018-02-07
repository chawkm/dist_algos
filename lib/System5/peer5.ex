defmodule Peer5 do

  def start(id, system, reliability, termination_time) do
    if termination_time != :infinity do
      Process.send_after(self(), :terminate, termination_time)
    end

    {peers_list, id_peer_map} = receive do
      {:peers, peers_list, id_peer_map} -> {peers_list, id_peer_map}
    end

    # Spawn an App, PL
    pl = spawn(PL_lossy, :start, [reliability])
    beb = spawn(BEB4, :start, [pl, peers_list, self()])
    app = spawn(App5, :start, [id, peers_list, id_peer_map, beb])

    # Bind the App and BEB together, and BEB and PL together
    send beb, {:app, app}
    send pl, {:app, beb}

    # Notify system which peers link to which PLs
    send system, {:pl, self(), pl}

    # Relay broadcast message to app
    receive do
      {:broadcast, max_broadcasts, timeout} -> send app, {:broadcast, max_broadcasts, timeout}
    end

    # Wait for termination message from System
    receive do
      :terminate ->
        send app, :terminate
        Process.exit(pl, "Faulty process closing PL link")
        Process.exit(self(), "Received termination signal from System.")
    end
  end

end
