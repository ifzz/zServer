local skynet = require "skynet"
local log = require "log"
local env = require "env"

local M = env.dispatch

local db = ".db"

local id 
local function get_id_from_db(key)
    local ret = skynet.call(db, "lua", "findOne", key, {"id"})
    assert(ret)
    return ret.id
end

local function update_id_to_db(key)
    local ret = skynet.call(db, "lua", "update", key, {id=id})
    assert(ret)
    return ret
end

local function get_id(key)
    if not id then
        id = get_id_from_db(key)
    end
    id = id + 1
    update_id_to_db(key)
end

function M.register(msg)
    local account = msg.account
    local password = msg.password
    local ret = skynet.call(db, "lua", "findOne", "account", {"account"})
    if ret then
        return false
    end
    get_id("account_key")
    local ret = skynet.call(db, "lua", "insert", "account", 
                            {
                                id=id,
                                account=account,
                                password=password,
                            })
    return true
end

function M.login(msg)
    local account = msg.account
    local password = msg.password
    local ret = skynet.call(db, "lua", "findOne", "account")
    if ret and ret.password == password then
        return true, ret.id
    end
    return false
end


