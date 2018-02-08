# Robert Holland (rh2515) and Chris Hawkes (ch3915)

defmodule Peer3 do

  def start(id, system) do
    {peers_list, id_peer_map} = receive do
      {:peers, peers_list, id_peer_map} -> {peers_list, id_peer_map}
    end

    # Spawn an App, PL
    pl = spawn(PL, :start, [])
    beb = spawn(BEB3, :start, [pl, peers_list, self()])
    app = spawn(App3, :start, [id, peers_list, id_peer_map, beb])

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
      {:terminate} -> Process.exit(self(), "Received termination signal from System.")
    end
  end

end
