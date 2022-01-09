transmission-daemon -f

{ok, server_pid} = Transmission.start_link("http://localhost:9091/transmission/", "transmission", "transmission")

client=Transmission.Api.new("http://localhost:9091/transmission/", "transmission", "transmission")

