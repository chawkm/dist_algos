defmodule Peer2 do

  def start(id, system) do
    {peers_list, id_peer_map} = receive do
      {:peers, peers_list, id_peer_map} -> {peers_list, id_peer_map}
    end

    # Spawn an App, PL
    pl = spawn(PL, :start, [])
    app = spawn(App2, :start, [id, peers_list, id_peer_map, pl, self()])

    # Bind the App and PL together
    send pl, {:app, app}
    send system, {:pl, self(), pl}

    # Relay broadcast message to app
    receive do
      {:broadcast, max_broadcasts, timeout} -> send app, {:broadcast, max_broadcasts, timeout}
    end

    # Wait for termination message from System
    receive do
      {:terminate} -> Process.exit(self(), "Received termination signal from System.")
    end
  end

end
