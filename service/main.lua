local skynet = require "skynet"
local cluster = require "skynet.cluster"
local log = require "log"
require "skynet.manager"
    
local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service
local nodename = skynet.getenv("nodename")

skynet.start(function()
	log.debug("Server start version: " .. runconf.version)
	--集群信息
	cluster.reload(runconf.cluster)
	cluster.open(nodename)
	--开启debug_console服务
	for i,v in pairs(servconf.debug_console) do
		if nodename == v.node then
			skynet.uniqueservice("debug_console", v.port)
			log.debug("start debug_console in port: " .. v.port.."...")
		end
	end
	--开启热更新模块
    log.debug("start setupd...")
    skynet.newservice("setupd")
	--开启dbproxyd服务
    for i,v in pairs(servconf.dbproxy) do
		local name = string.format("dbproxyd%d", i)
		if nodename == v.node then
			local p = skynet.newservice("dbproxyd")
			skynet.call(p, "lua", "start", servconf.dbproxy_common)
			skynet.name(name, p)
			log.debug("start "..name.."...")
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
    end
	--开启centerd服务
	for i,v in pairs(servconf.center) do
		local name = string.format("centerd%d", i)
		if nodename == v.node then
			local p = skynet.newservice("centerd")
			skynet.name(name, p)
			log.debug("start "..name.."...")
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
    end
	--开启login服务
	for i,v in pairs(servconf.login) do
		local name = string.format("logind%d", i)
		if nodename == v.node then
			local p = skynet.newservice("logind")
			skynet.name(name, p)
			log.debug("start "..name.."...")
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
    end
	--开启agentpool服务
	for i,v in pairs(servconf.agentpool) do
		if nodename == v.node then
			local agentname = servconf.agentpool_common.name
			local maxnum = servconf.agentpool_common.maxnum
			local recyremove = servconf.agentpool_common.recyremove
			local brokecachelen = servconf.agentpool_common.brokecachelen
			agentpool = skynet.uniqueservice("agentpool", agentname, maxnum, recyremove, brokecachelen)
			log.debug("start agent pool...")
		end
	end
	--开启watchdog服务
	for i,v in pairs(servconf.watchdog) do
		if nodename == v.node then
			local maxclient = servconf.watchdog_common.maxclient
			local nodelay = servconf.watchdog_common.nodelay
			local watchdog = skynet.newservice("wswatchdog")
			skynet.call(watchdog, "lua", "start", {
				port = v.port,
				maxclient = maxclient,
				nodelay = nodelay
			})
			log.debug("start wswatchdog in port: " .. v.port) 
		end
	end
	--room_mgr
	
	
	--测试
    --skynet.uniqueservice("testd")
	--skynet.newservice("exitd")
    --skynet.newservice("monitord")
    --log.debug("=== test monitor ===")
    --require "skynet.manager"
    --skynet.monitor("monitord")
    --log.debug("=== end test monitor ===")
    
    skynet.exit()
end)


