local skynet = require "skynet"

local MAX_CENTER_COUNT = 1
local M = {}

local centers = {}
local function init()
   for i = 1, i < MAX_CENTER_COUNT do
    centers[i] = skynet.newserverice("centerd")
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

