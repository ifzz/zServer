local skynet = require "skynet"
require "skynet.manager"
local log = require "log"
    
local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

skynet.start(function()
	log.debug("Server start version: " .. runconf.version)

    skynet.uniqueservice("debug_console", nodeconf.debug_console_port)
    log.debug("start debug_console in port: " .. nodeconf.debug_console_port)

    log.debug("start setupd...")
    skynet.newservice("setupd")

    log.debug("start dbproxyd...")
    for i = 1, nodeconf.dbproxy_num do
        local name = string.format(".dbproxyd%d", i)
        local p = skynet.newservice("dbproxyd")
        skynet.call(p, "lua", "start", nodeconf.db)
        skynet.name(name, p)
    end

    log.debug("start centerd...")
    for i = 1, nodeconf.centerd_num do
        local name = string.format(".centerd%d", i)
        local p = skynet.newservice("centerd")
        skynet.name(name, p)
    end

    log.debug("start logind...")
    for i = 1, nodeconf.login_num do 
        local name = string.format(".logind%d", i)
        local p = skynet.newservice("logind")
        skynet.name(name, p)
    end

    log.debug("start agent pool...")
    local agentname = "wsagent"
    local maxnum = 10
    local recyremove = 2
    local brokecachelen = 10
    agentpool = skynet.uniqueservice("agentpool", agentname, maxnum, recyremove, brokecachelen)

    local watchdogconf = nodeconf.watchdog
    local watchdog = skynet.newservice("wswatchdog")
    skynet.call(watchdog, "lua", "start", {
        port = watchdogconf.port,
        maxclient = watchdogconf.maxclient,
        nodelay = watchdogconf.nodelay
    })
    log.debug("start wswatchdog in port: " .. watchdogconf.port) 

    skynet.newservice("testd")

    skynet.exit()
end)


