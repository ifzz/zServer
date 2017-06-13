local skynet = require "skynet"
local json = require "cjson"
local log = require "log"

local M = {}

function M.pack(cmd, msg)
    msg.cmd = cmd
    local str = json.encode(msg)
    return str
end

function M.unpack(data)
    local isok, t = pcall(json.decode, data)
    if not isok then
        log.error(string.format("unpack error, msg: %s", data))
        return
    end
    return t.cmd, t
end

return M


