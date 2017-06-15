local skynet = require "skynet"
local queue = require "skynet.queue"
local log = require "log"
local env = require "env"

local M = env.dispatch

local users = {}
function M.login(uid, data)
    local user = users[uid]
    if not user then
        users[uid] = data
        return true
    end
    skynet.call(user.watchdog, "lua", "close", data.fd)
    user = users[uid]
    if user then
        log.debug("have login uid: " .. uid)
        return false
    end
    users[uid] = data
    return true
end

function M.logout(uid)
    users[uid] = nil
end

