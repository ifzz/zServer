local skynet = require "skynet"
local mongo = require "mongo"
local bson = require "bson" 
local log = require "log"
local tool = require "tool"

local M = {}

local db
function M.start(conf)
    local host = conf.host
    local db_name = conf.db_name
    local db_client = mongo.client({host = host})
    db = db_client[db_name]
end

function M.findOne(cname, selector, field_selector)
	return db[cname]:findOne(selector, field_selector)
end

function M.find(cname, selector, field_selector)
	return db[cname]:find(selector, field_selector)
end

function M.update(cname, selector, update, upsert)
	local collection = db[cname]
	
	collection:update(selector, update, upsert)
	local r = db:runCommand("getLastError")
	if r.err ~= bson.null then
        skynet.error("update err: " .. r.err)
		return false, r.err
	end

	if r.n <= 0 then
		skynet.error("mongodb update "..cname.." failed")
	end
	 skynet.error("update finish")
	return true, r.err
end

local function db_help(cmd, cname, ...)
    local c = db[cname]
    c[cmd](c, ...)
    local r = db:runCommand('getLastError')
    local ok = r and r.ok == 1 and r.err == bson.null
    if not ok then
        skynet.error(v.." failed: ", r.err, tname, ...)
    end
    return ok, r.err   
end

function M.insert(cname, data)
    return db_help("safe_insert", cname, data)
end

function M.delete(cname, selector)
    return db_help("delete", cname, selector)
end

function M.incr(key)
    local cname = "tb_key"
    local ret = M.findOne(cname, {key=key}, {uuid=1})
    local id = 0
    if ret then
        id = ret.uuid
    end
    id = id + 1
    ret = M.update(cname, {key=key}, {key=key, uuid=id}, true)
    assert(ret)
    assert(id)
    return id
end

return M

