# Robert Holland (rh2515) and Chris Hawkes (ch3915)

defmodule Peer6 do

  def start(id, system, reliability, termination_time) do
    if termination_time != :infinity do
      Process.send_after(self(), :terminate, termination_time)
    end

    {peers_list, id_peer_map} = receive do
      {:peers, peers_list, id_peer_map} -> {peers_list, id_peer_map}
    end

    # Spawn lower components
    pl  = spawn(PL_lossy, :start, [reliability])
    beb = spawn(BEB6, :start, [pl, peers_list, self()])
    erb = spawn(ERB, :start, [beb])
    app = spawn(App6, :start, [id, peers_list, id_peer_map, erb])


    # Bind the App, BEB and ERB together
    send beb, {:caller, erb}
    send pl, {:app, beb}
    send erb, {:app, app}

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
