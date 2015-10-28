require('enet')

Network = {}

Network.DefaultUsername = "John Cena"
Network.DefaultPort = 8888
Network.TickRate = 10
Network.LerpTime = 1 / Network.TickRate

NetworkState = {
	None = 0,
	Client = 1,
	Server = 2
}

local host, server, state = nil, nil, NetworkState.None
local usernames = {}

function Network.getState()
	return state
end

function Network.getServerState()
	if server then
		return server:state()
	end

	return "disconnected"
end

function Network.getPing(id)
	if Network.getState() == NetworkState.Client then
		return server:last_round_trip_time() / 1000
	elseif Network.getPeerByID(id) then
		return Network.getPeerByID(id):last_round_trip_time() / 1000
	end

	return 0
end

function Network.getID()
	if Network.getState() == NetworkState.Client then
		return server:connect_id()
	end

	return 0
end

function Network.setUsername(id, username)
	if Network.getState() ~= NetworkState.None then
		usernames[id] = username

		if Network.getState() == NetworkState.Server then
			Network.broadcast("SetUsername", {
				id,
				username
			})
		end
	end
end

function Network.getUsername(id)
	return usernames[id] or Network.DefaultUsername
end

function Network.getUsernames()
	return pairs(usernames)
end

function Network.host(port)
	if Network.getState() == NetworkState.None then
		host = enet.host_create('*:' .. (port or Network.DefaultPort), 8, 2)

		if host then
			state = NetworkState.Server
			Network.setUsername(Network.getID(), Settings.get('network_username'))
		end

		return host ~= nil
	end

	return false
end

function Network.connect(address, port)
	if Network.getState() == NetworkState.None then
		host = enet.host_create()
		server = host:connect(address .. ':' .. (port or Network.DefaultPort), 2)

		server:timeout(5, 5000, 10000)

		state = NetworkState.Client
	end
end

function Network.getPeerCount(state)
	if Network.getState() == NetworkState.Server then
		local count = 0

		for index = 1, host:peer_count() do
			if host:get_peer(index):state() == (state or "connected") then
				count = count + 1
			end
		end

		return count
	end

	return 0
end

function Network.getPeers(state)
	if Network.getState() == NetworkState.Server then
		local peers = {}

		for index = 1, host:peer_count() do
			if host:get_peer(index):state() == (state or "connected") then
				table.insert(peers, host:get_peer(index))
			end
		end

		return table.iterator(peers)
	end

	return function()
		return nil
	end
end

function Network.getPeer(index)
	if Network.getState() == NetworkState.Server and index < host:peer_count() then
		return host:get_peer(index)
	end

	return nil
end

function Network.getPeerByID(id)
	for peer in Network.getPeers() do
		if peer:connect_id() == id then
			return peer
		end
	end

	return peer
end

function Network.getEvents()
	return function()
		if Network.getState() ~= NetworkState.None then
			return host:service()
		end
	end
end

function Network.send(event, data, peer, channel, flag)
	if state ~= NetworkState.None then
		peer = peer or server

		peer:send(MessagePack.pack({event, data}))
	end
end

function Network.broadcast(event, data, channel, flag)
	if state == NetworkState.Server then
		host:broadcast(MessagePack.pack({event, data}), channel, flag)
	end
end

function Network.close()
	if state ~= NetworkState.None then
		if server then
			server:disconnect_now()
		else
			for peer in Network.getPeers() do
				peer:disconnect_now()
			end
		end

		host:destroy()

		host = nil
		server = nil
		usernames = {}

		state = NetworkState.None
	end
end
