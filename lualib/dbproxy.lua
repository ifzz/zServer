local skynet = require "skynet"
local log = require "log"
local env = require "env"

local M = env.dispatch

local db
function M.start(conf)
    local db_type = conf.db_type
    db = require(db_type) 
    db.start(conf)
end

function M.findOne(cname, selector, field_selector)
    return db.findOne(cname, selector, field_selector)
end

function M.find(cname, selector, field_selector)
    return db.find(cname, selector, field_selector)
end

function M.update(cname, selector, update)
    return db.update(cname, selector, update)
end

function M.insert(cname, data)
    return db.insert(cname, data)
end

function M.delete(cname, selector)
    return db.delete(cname, selector)
end

