local skynet = require "skynet"
local log = require "log"
local env = require "env"

local M = env.dispatch

function M.enter_room(msg)
    local service = skynet.call(".room_mgr", "lua", "enter", msg)
    env.service["room"] = service  
end

function M.leave_room(msg)
    env.service["room"] = nil
end





