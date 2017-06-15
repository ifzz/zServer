local skynet = require "skynet"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

skynet.start(function()
	log.debug("Server start version: " .. runconf.version)

    skynet.uniqueservice("debug_console", nodeconf.debug_console_port)
    log.debug("start debug_console in port: " .. nodeconf.debug_console_port)

    local watchdogconf = nodeconf.watchdog
    local watchdog = skynet.newservice("wswatchdog")
    skynet.call(watchdog, "lua", "start", {
        port = watchdogconf.port,
        maxclient = watchdogconf.maxclient,
        nodelay = watchdogconf.nodelay
    })
    log.debug("start wswatchdog in port: " .. watchdogconf.port) 

    skynet.exit()
end)
