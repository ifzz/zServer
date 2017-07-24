local skynet = require "skynet"
local queue = require "skynet.queue"
local log = require "log"
local env = require "env"

local M = env.dispatch

local users = {}
--users[uid]={
--	watchdog
--	fd
--	agent （register_agent之后）
--	node  （register_agent之后）	
--}
local rooms = {}
--rooms[id]={
--	room
--	node
--}


function M.login(uid, data)
    local user = users[uid]
    if not user then
        users[uid] = data
        return true
    end
    skynet.call(user.watchdog, "lua", "close", user.fd)
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

--register_agent
function M.register_agent(uid, data)
	if not users[uid] then
		return false
	end
	log.debug("center register_agent: " .. uid.." "..data.agent)
	users[uid].agent = data.agent
	users[uid].node = data.node
end

--register_room
function M.register_room(id, data)
	if not users[uid] then
		return false
	end
	log.debug("center register_agent: " .. uid.." "..data.agent)
	users[uid].agent = data.agent
	users[uid].node = data.node
end

--broadcast msg to all player
function M.broadcast_msg(uid, data)
	for uid, uid_data in pairs(users) do
		log.debug("center broadcast_msg send to: " .. uid)
		M.send_agent(uid, "send", data)
	end
end

--发送
function M.send(node, adress, cmd, data)
	if node == skynet.getenv("nodename") then
		skynet.send(adress, "lua", cmd, data)
	else 
		cluster.send(node, adress, cmd, data)
	end
end

--发送给某个agent
function M.send_agent(uid, cmd, data)
	local uid_data = users[uid]
	--未登陆
	if not uid_data then
		log.debug("center send_agent not uid_data " .. uid)
		return
	end
	--未生成agent
	if not uid_data.node then
		log.debug("center send_agent not uid_data.node " .. uid)
		return
	end
	local node = uid_data.node
	M.send(node, uid_data.agent, cmd, data)
end

--发给某个agent的watchdog
function M.send_watchdog(uid, cmd, data)
	local uid_data = users[uid]
	--未登陆
	if not uid_data then
		log.debug("center send_watchdog not uid_data " .. uid)
		return
	end
	--未生成agent
	if not uid_data.node then
		log.debug("center send_watchdog not uid_data.node " .. uid)
		return
	end
	local node = uid_data.node
	M.send(node, uid_data.watchdog, cmd, data)
end