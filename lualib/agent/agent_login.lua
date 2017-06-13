local skynet = require "skynet"
local log = require "log"
local env = require "env"

local player = {}

local function load_data(cname, uid)
    local ret = skynet.call(".db", "lua", "findOne", cname, {uid=uid})
    setmetatable(ret, {
                        __newindex = function(t, k, v)
                                        t.dirty = true
                                        rawset(t, k, v)
                                    end})
end

local function load_all_data()
    local ret = {}
end

local function save_data()
    local data = player.data
    for k, v in pairs(data) do
        if v.dirty then
            v.dirty = nil
            skynet.call(".db", "lua", "update", k, v)
        end
    end
end

function env.login(account)
    skynet.call(".center", "lua", "login", {})
    -- 从数据库里加载数据
    player = {
                id = skynet.self(),
                account = account,
            }

    player.data = {}
end


function env.logout(account)
    -- 保存数据
    save_data()

    skynet.call(".center", "lua", "logout", account)
end

function env.get_player()
    return player
end

function env.get_playerdata()
    return player.data
end


