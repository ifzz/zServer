local skynet = require "skynet"
local log = require "log"
local env = require "env"
local dbproxy = require "libdbproxy"
local libcenter = require "libcenter"

local M = env.dispatch

function M.register(msg)
    local account = msg.account
    local password = msg.password
    local ret = dbproxy.findOne(nil, "account", {account=account})
    if ret then
        return false
    end
    local uid = dbproxy.incr("account") 
    local ret = dbproxy.insert(nil, "account", 
                            {
                                uid=uid,
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
        local uid = ret.uid
        local data = {
           watchdog = msg.watchdog,
           fd = msg.fd
        }

        local ret = libcenter.login(uid, data) 
        if ret then
            return true, ret
        end
        return false
    end
    return false
end


