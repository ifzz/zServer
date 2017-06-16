local skynet = require "skynet"
local log = require "log"
local env = require "env"

skynet.start(function()
    skynet.dispatch("lua", function(session, addr, cmd, ...)
        local f = env.dispatch[cmd]
        if not f then
            log.error("cmd(%s) is not found", cmd)
            return
        end
        local ok, ret = pcall(f, ...)
        if not ok then
            log.error("call function(%s) fail, ret: %s", cmd, tostring(ret))
            return
        end 
        skynet.ret(skynet.pack(ret))
    end)

    if env.init then
        env.init()
    end
end)

