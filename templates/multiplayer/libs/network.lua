local enet = require("enet")
local binser = require("libs/binser")
local timer = require("libs/timer")

local network = {}

network.canDisconnect = false

function network.connect(address, port)
  network.host = enet.host_create()
  network.server = network.host:connect(address .. ":" .. port)
end

function network.disconnect(data)
  network.send({
    action = "disconnect",
    data = data
  })

  network.canDisconnect = true
  timer.after(1, function() love.event.quit() end)
end

function network.send(data)
  local serialized = binser.serialize(data)
  network.server:send(serialized)
end

function network.update(dt)
  timer.update(dt)

  local event = network.host:service(100)

  if event then
    if event.type == "connect" then
      onConnection(event.peer)
    elseif event.type == "disconnect" then
      onDisconnection(event.peer)
    elseif event.type == "receive" then
      local deserialized = binser.deserializeN(event.data, 1)
      onMessage(deserialized)
    end
  end
end

return network
