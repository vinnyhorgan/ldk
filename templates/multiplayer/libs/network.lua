local socket = require("socket")
local binser = require("libs/binser")

local client = {}

function client:new(address, port)
  if address == "localhost" then
    self.address = "127.0.0.1"
  else
    self.address = address
  end

  self.id = love.math.random(1000000)
  self.port = port
  self.socket = socket.udp()
  self.socket:settimeout(0)
  self.socket:setpeername(self.address, self.port)
  self.connected = false
  self.timer = 0
  self:send({
    action = "connect",
    id = self.id
  })
end

function client:disconnect()
  self:send({
    action = "disconnect",
    id = self.id
  })
end

function client:send(data)
  local serialized = binser.serialize(data)
  self.socket:send(serialized)
end

function client:update(dt)
  if not self.connected then
    self.timer = self.timer + dt

    if self.timer > 5 then
      print("[WARNING] Trying to reconnect...")

      self:send({
        action = "connect",
        id = self.id
      })

      self.timer = 0
    end
  end

  repeat
    local data, msg = self.socket:receive()

    if data then
      local deserialized = binser.deserializeN(data)

      if deserialized.action == "new-connection" then
        if deserialized.id ~= self.id then
          if not onConnection then
            print("[WARNING] The onConnection callback is not defined!")
          else
            onConnection(deserialized.id)
          end
        else
          self.connected = true
        end
      elseif deserialized.action == "new-disconnection" then
        if not onDisconnection then
          print("[WARNING] The onDisconnection callback is not defined!")
        else
          onDisconnection(deserialized.id)
        end
      else
        if not onMessage then
          print("[WARNING] The onMessage callback is not defined!")
        else
          onMessage(deserialized)
        end
      end
    elseif msg ~= "timeout" then
      error("Network error: " .. tostring(msg))
    end
  until not data
end

local server = {}

function server:new(port)
  self.port = port
  self.socket = socket.udp()
  self.socket:settimeout(0)
  self.socket:setsockname("*", port)
  self.clients = {}
end

function server:send(data, clientId)
  local serialized = binser.serialize(data)

  if clientId == nil then
    for k, v in pairs(self.clients) do
      self.socket:sendto(serialized, v.address, v.port)
    end
  else
    for k, v in pairs(self.clients) do
      if v.id == clientId then
        self.socket:sendto(serialized, v.address, v.port)
      end
    end
  end
end

function server:update()
  local data, msg_or_ip, port_or_nil = self.socket:receivefrom()

  if data then
    local deserialized = binser.deserializeN(data)

    if deserialized.action == "connect" then
      local exists = false

      for k, v in pairs(self.clients) do
        if v.id == deserialized.id then
          exists = true
        end
      end

      if not exists then
        table.insert(self.clients, {
          id = deserialized.id,
          address = msg_or_ip,
          port = port_or_nil
        })
      end

      self:send({
        action = "new-connection",
        id = deserialized.id
      })
    elseif deserialized.action == "disconnect" then
      local index

      for k, v in pairs(self.clients) do
        if v.id == deserialized.id then
          index = k
        end
      end

      table.remove(self.clients, index)

      self:send({
        action = "new-disconnection",
        id = deserialized.id
      })
    else
      if not onMessage then
        print("[WARNING] The onMessage callback is not defined!")
      else
        onMessage(deserialized)
      end
    end
  elseif msg_or_ip ~= "timeout" then
    error("Network error: " .. tostring(msg_or_ip))
  end
end

return {
  client = client,
  server = server
}
