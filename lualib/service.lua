local skynet = require "skynet"
local log = require "log"
local env = require "env"

skynet.start(function()
    skynet.dispatch("lua", function(session, addr, cmd, ...)

        local function ret(ok, ...)
            if not ok then
                skynet.ret()
            else
                skynet.retpack(...)
            end
        end

        local f = env.dispatch[cmd]
        if not f then
            log.error("cmd(%s) is not found, %s", cmd, debug.traceback())
            return
        end

        ret(xpcall(f, debug.traceback, ...))
    end)

    if env.init then
        env.init()
    end
end)

