local skynet = require "skynet"

local M = {}

local agentpool
local function init()
    agentpool = skynet.queryservice("agentpool")
end


function M.get()
    return skynet.call(agentpool, "lua", "get")
end

function M.recycle(agent)
    return skynet.call(agentpool, "lua", "recycle", agent)
end

skynet.init(init)

return M


