local skynet = require "skynet"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

skynet.start(function()
	log.debug("Server start version: " .. runconf.version)
    skynet.uniqueservice("debug_console", nodeconf.debug_console_port)

    skynet.exit()
end)
