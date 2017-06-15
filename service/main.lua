local skynet = require "skynet"
local log = require "log"
    
local libsetup = require "libsetup"

local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

skynet.start(function()
	log.debug("Server start version: " .. runconf.version)

    skynet.uniqueservice("debug_console", nodeconf.debug_console_port)
    log.debug("start debug_console in port: " .. nodeconf.debug_console_port)

<<<<<<< HEAD
    local watchdogconf = nodeconf.watchdog
    local watchdog = skynet.newservice("wswatchdog")
    skynet.call(watchdog, "lua", "start", {
        port = watchdogconf.port,
        maxclient = watchdogconf.maxclient,
        nodelay = watchdogconf.nodelay
    })
    log.debug("start wswatchdog in port: " .. watchdogconf.port) 
=======
    skynet.newservice("setupd")
    log.debug("start datasheetd, and sleep 10")
    local tool = require "tool" 
    local str = tool.dump(libsetup.item)
    print("=== str: " .. str)
    print("hello world")
    print(tool.dump(libsetup.test))
    skynet.sleep(2000)

    local str = tool.dump(libsetup.item)
    print("=== new str: " .. str)
  
    --[[
    local db = skynet.newservice("db")
    local dbconf = nodeconf.db
    skynet.call(db, "lua", "start", dbconf)
    local test_data = {test="hello world"}
    skynet.call(db, "lua", "insert", "test", test_data)
    --]]
>>>>>>> 42a4c0f963f8a1549e7e851babfc2cc8e5aaad73

    --skynet.exit()
end)
