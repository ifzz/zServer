local skynet = require "skynet"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

skynet.start(function()
	log.debug("Server start version: " .. runconf.version)
    skynet.uniqueservice("debug_console", nodeconf.debug_console_port)

    local db = skynet.newservice("db")
    local dbconf = nodeconf.db
    skynet.call(db, "lua", "start", dbconf)
    local test_data = {test="hello world"}
    skynet.call(db, "lua", "insert", "test", test_data)

    skynet.exit()
end)
