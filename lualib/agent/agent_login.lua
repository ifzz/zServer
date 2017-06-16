local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libdbproxy = require "libdbproxy"
local tool = require "tool"

local player = {}

local function load_data(cname, uid)
    local ret = libdbproxy.findOne(uid, cname)
    log.debug("cname: " .. cname .. " uid:" .. uid .. " ret: " .. tool.dump(ret))

    ret = ret or {}
    setmetatable(ret, {
                        __newindex = function(t, k, v)
                                        t.dirty = true
                                        rawset(t, k, v)
                                    end})
    return ret
end

local function load_all_data()
    local ret = {}
    ret.player = "dump"
    ret.item = "dump"
    for k, v in pairs(ret) do
        ret[k] = load_data(k, player.uid)
    end
    return ret
end


local function save_data()
    local data = player.data
    for k, v in pairs(data) do
        if v.dirty then
            v.dirty = nil

            libdbproxy.update(player.uid, k, v)
        end
    end
end

function env.login(account)

    -- 从数据库里加载数据
    player = {
                id = skynet.self(),
                uid = account.uid,
                account = account,
            }

    player.data = load_all_data()
end


function env.logout(account)
    -- 保存数据
    save_data()
end

function env.get_player()
    return player
end

function env.get_playerdata()
    return player.data
end


