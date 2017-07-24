local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libdbproxy = require "libdbproxy"
local tool = require "tool"

local player = {}

local InitPlayerCMD = {}
function InitPlayerCMD.init_player_data()
    local ret = {}
    local now = os.time()
    ret.login_time = now
    ret.register_time = now
    return ret
end

local function get_init_data(cname)
    local funname = string.format("init_%s_data", cname)
    local func = InitPlayerCMD[funname]
    assert(type(func) == "function")
    return func()
end

local function load_data(cname, uid)
    local ret = libdbproxy.findOne(uid, cname, {uid=uid})
    log.debug("===load_data cname: " .. cname .. " uid:" .. uid .. " ret: " .. tool.dump(ret))
 
    ret = ret or get_init_data(cname)
	ret.dirty = ret.dirty or true
	ret.uid = uid
    setmetatable(ret, {
                        __newindex = function(t, k, v)
                                        t.dirty = true
                                        rawset(t, k, v)
                                    end})
    return ret
end

local function load_all_data()
    local ret = {}
    ret.player = true
    for k, v in pairs(ret) do
        ret[k] = load_data(k, player.uid)
    end
    return ret
end


local function save_data()

    local data = player.data
	data.player.name = "ada"
	
    for k, v in pairs(data) do
        if v.dirty then
            v.dirty = nil
			local select = {uid=player.uid}
            libdbproxy.update(player.uid, k, select, v, true)
        end
    end
end

function env.login(account)

    log.debug("=== test login ===")

    -- 从数据库里加载数据
    player = {
                id = skynet.self(),
                uid = account.uid,
                account = account,
            }

    player.data = load_all_data()
	--初始化数据
	player.data.player.login_time = os.time()
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


