local skynet = require "skynet"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

local dbconf = nodeconf.db

local MAX_DBPROXY_COUNT = dbconf.dbproxy_num

local M = {}

local function init()
    log.debug("init libdbproxy")
    M.dbproxy = {}
    for i = 1, MAX_DBPROXY_COUNT do
        local dbproxy = skynet.newservice("dbproxyd")
        skynet.call(dbproxy, "lua", "start", dbconf)
        M.dbproxy[i] = dbproxy 
    end
end

local next_id = 1
local function next_dbproxy()
    next_id = next_id + 1
    next_id = next_id % MAX_DBPROXY_COUNT + 1
    return M.dbproxy[next_id]
end

local function fetch_dbproxy(key)
    if type(key) == "number" then
        local id = key % MAX_DBPROXY_COUNT + 1 
        return M.dbproxy[id]
    else
        return next_dbproxy()
    end
end

function M.findOne(key, cname, selector, field_selector)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "findOne", cname, selector, field_selector)
end

function M.find(key, cname, selector, field_selector)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "find", cname, selector, field_selector)
end

function M.update(key, cname, selector, update)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "update", cname, selector, field_selector)
end

function M.insert(key, cname, data)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "insert", cname, data)
end

function M.delete(key, cname, selector)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "delete", cname, selector)
end

function M.inc(key)
    local db = fetch_dbproxy(1)
    assert(db)
    return skynet.call(db, "lua", "inc", key)
end

skynet.init(init)

return M


