Network = {}

local threads = {}

function Network.update()
	local k = 1

	while k <= #threads and threads[k] do
		if not coroutine.resume(threads[k]) then
			table.remove(threads, k)
		else
			k = k + 1
		end
	end
end

function Network.send(socket, data, callback)
	table.insert(threads, coroutine.create(function()
		local bytesSent, closed = 0, false

		while bytesSent < #data and not closed do
			local lastByte, error = socket:send(data, bytesSent)

			bytesSent = bytesSent + lastByte
			closed = error == 'closed'

			coroutine.yield()
		end

		callback(closed)
	end))
end

function Network.receive(socket, pattern, callback)
	table.insert(threads, coroutine.create(function()
		local data, error, closed = nil, nil, false

		while not data and not closed do
			data, error = socket:receive(pattern)

			closed = error == 'closed'

			coroutine.yield()
		end

		callback(data, closed)
	end))
end

while true do
	if #threads == 0 then
		love.timer.sleep(0.1)
	else
		Network.update()
	end
end
