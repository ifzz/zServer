local skynet = require "skynet"
local log = require "log"
local websocket = require"websocket"
local protopack = require "protopack"
local env = require "env"

require "libstring"
require "agent_init"

local CMD = {}

local gate
local watchdog
local fd
local account


local default_dispath
local service_dispatch
local dispatch

function default_dispatch(cmd, msg)
    local cb = env.dispatch[cmd]
    if type(cb) ~= "function" then
        log.error("cb is not function, cmd = %s, str = %s", cmd, str)
        return
    end

    local isok, ret = pcall(cb, msg)
    if not isok then
        log.error("handle msg error, cmd = %s, str = %s", cmd, str)
        return
    end
    return ret 
end

function service_dispatch(service_name, cmd, msg)
    local service = env.service[service_name]
    if not service then
        log.error("service name(%s) is not exist, cmd = %s", service_name, cmd)
        return
    end

    local ret = skynet.call(service, "lua", cmd, msg)
    return ret 
end

function dispatch(_, _, str)
    local cmd, msg = protopack.unpack(str)
    local cmdlist = string.split(cmd, ".") 
    local length = #cmdlist
    local ret
    if length == 2 then
        ret = service_dispath(cmdlist[1], cmdlist[2], msg)
    elseif length == 1 then
        ret = default_dispath(cmd, msg)
    end
    if ret then
        CMD.send(ret)
    end
end

skynet.register_protocol{
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
	dispatch = dispatch, 
}

function CMD.start(conf)
	gate = conf.gate
	fd = conf.fd
	watchdog = conf.watchdog
    account = conf.account
	skynet.call(gate,"lua","forward",fd)

    env.login(account)
end

function CMD.disconnect()
	skynet.error("agent exit!")

    env.logout(account)

    skynet.call(watchdog, "lua", "close", fd)
end

function CMD.send(msg)
    local cmd = msg.cmd
	local data = protopack.pack(cmd, msg)
	websocket:send_text(fd, data)
end

skynet.start(function()
	skynet.dispatch("lua",function(_,_,cmd,...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
end)


