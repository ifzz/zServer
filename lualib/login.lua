local skynet = require "skynet"
local log = require "log"
local env = require "env"
local dbproxy = require "libdbproxy"

local M = env.dispatch

function M.register(msg)
    local account = msg.account
    local password = msg.password
    local ret = dbproxy.findOne(nil, "account", {account=account})
    if ret then
        return false
    end
    local id = dbproxy.inc("account") 
    local ret = dbproxy.insert(nil, "account", 
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
    local ret = dbproxy.findOne(nil, "account", {account=account})
    if ret and ret.password == password then
        return true, ret.id
    end
    return false
end


