local skynet = require "skynet"
local env = require "env"

local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

local M = {}

local centers = {}
local function init()
   for i = 1, nodeconf.centerd_num do
    centers[i] = string.format(".centerd%i", i)
   end
end

local function fetch_centerd(uid)
    local id = uid % MAX_CENTER_COUNT + 1
    return centers[id]
end

function M.login(uid, data)
    local centerd = fetch_centerd(uid)
    assert(centerd)
    return skynet.call(centerd, "lua", "login", uid, data)
end

function M.logout(uid)
    local centerd = fetch_centerd(uid)
    assert(centerd)
    return skynet.call(centerd, "lua", "logout", uid)
end

skynet.init(init)

return M

