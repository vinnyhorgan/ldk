-- CONFIGURATION
PORT = 3000
DEBUG = true
MAX_CLIENTS = 10

function love.load()
  enet = require("enet")
  binser = require("libs/binser")
  inspect = require("libs/inspect")
  log = require("libs/log")

  host = enet.host_create("localhost:" .. PORT, MAX_CLIENTS)

  log.info("Server started on port " .. PORT)
end

function debugPrint(text)
  if DEBUG then
    log.debug(text)
  end
end

function love.update(dt)
  local event = host:service(100)

  if event then
    if event.type == "connect" then
      debugPrint(tostring(event.peer) .. " connected.")
    elseif event.type == "disconnect" then
      debugPrint(tostring(event.peer) .. " disconnected.")
    elseif event.type == "receive" then
      local deserialized = binser.deserializeN(event.data, 1)
      debugPrint("New message received: " .. inspect(deserialized))

      host:broadcast(event.data)

      -- SERVER COMMANDS
      if deserialized.action == "disconnect" then
        event.peer:disconnect()
      elseif deserialized.action == "peers" then
        for i = 1, MAX_CLIENTS do
          local peer = host:get_peer(i)
          print(tostring(peer), peer:state())
        end
      end
    end
  end
end
