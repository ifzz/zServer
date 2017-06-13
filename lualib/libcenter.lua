local skynet = require "skynet"
local log = require "log"
local env = require "env"

local M = env.dispatch

local players = {}
function M.login(id, data)
    local watchdog = data.watchdog
    local player = players[id]
    if player then
        if not player.waiting then
            player.waiting = true
            skynet.call(player.watchdog, "lua", "close", player.fd)
            player.waiting = false
        end
        return false
    end
    players[id] = data
    return true
end

function M.logout(id)
    players[id] = nil
end

