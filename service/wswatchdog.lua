local skynet = require "skynet"
local log = require "log"
local protopack = require "protopack"
local websocket = require"websocket"
local liblogin = require "liblogin"


local gate
local SOCKET = {}
local agents = {}

-- agent 池的名字
local agentpool = ...

---------------------------socket数据处理----------------------------
local sock_handler = {}
sock_handler.login = function (fd, msg)
    local ret = liblogin.login(msg)
    if ret then
        agents[fd] = skynet.call(agentpool, "lua", "get")
        skynet.call(agents[fd], "lua", "start", 
                    {
                        gate = gate, 
                        fd = fd, 
                        watchdog = skynet.self(), 
                        account = ret,
                    })
        
        log.info("verify account %s success!", msg.account)
    end

	SOCKET.send(fd, "login", {ret=ret})
end

sock_handler.register = function (fd, msg)
    local ret = liblogin.register(msg)
	SOCKET.send(fd, "register", {ret = ret})
end

------------------------ socket消息开始 -----------------------------
function SOCKET.open(fd, addr)
	log.info("New client from : %s", addr)
	skynet.call(gate,"lua","accept",fd)
end

local function close_agent(fd)
    local a = agents[fd]
	agents[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)

        -- recycle agent
		skynet.call(agentpool, "lua", "recycle", a)
	end
end

function SOCKET.close(fd)
	log.info("socket close fd=%d", fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	log.info("socket error fd = %d msg = %s",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	log.info("socket warning fd=%d size=%d", fd, size)
end

function SOCKET.data(fd, data)
	local name, msg = protopack.unpack(data)
	print(name)
	sock_handler[name](fd, msg)
end

function SOCKET.send(fd, cmd, msg)
	local data = protopack.pack(cmd, msg)
	websocket:send_text(fd,data)
end

------------------------ socket消息结束-----------------------------

local CMD = {}
function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)
	gate = skynet.newservice("wsgate")
end)

