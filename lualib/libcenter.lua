local skynet = require "skynet"
local env = require "env"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service
local MAX_CENTER_COUNT = #servconf.center


local M = {}
local centers = {}

local function init()
   for i = 1, MAX_CENTER_COUNT do
    centers[i] = string.format("centerd%d", i)
   end
end

local function fetch_centerd(uid)
    local id = uid % MAX_CENTER_COUNT + 1
    return centers[id]
end

function M.login(uid, data)
    local centerd = fetch_centerd(uid)
    assert(centerd)
    return skynet.call(centerd, "lua", "login", uid, data)
end

function M.logout(uid)
    local centerd = fetch_centerd(uid)
    assert(centerd)
    return skynet.call(centerd, "lua", "logout", uid)
end

--register_agent
function M.register_agent(uid, data)
    local centerd = fetch_centerd(uid)
    assert(centerd)
    return skynet.call(centerd, "lua", "register_agent", uid, data)
end

--broadcast msg to all centers
function M.broadcast(uid, cmd, data)
	for i = 1, MAX_CENTER_COUNT do
		log.debug("centerlib broadcast_msg send to: " .. i)
		skynet.send(centers[i], "lua", cmd, uid, data)
   end
end

skynet.init(init)

--发送给某个agent
function M.send_agent(uid, cmd, data)
	local centerd = fetch_centerd(uid)
	assert(centerd)
	skynet.send(centerd, "lua", "send_agent", uid, cmd, data)
end

--发送给某个agent的watchdog
function M.send_watchdog(uid, cmd, data)
	local centerd = fetch_centerd(uid)
	assert(centerd)
	skynet.send(centerd, "lua", "send_watchdog", uid, cmd, data)
end

return M


