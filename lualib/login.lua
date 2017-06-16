local skynet = require "skynet"
local log = require "log"
local env = require "env"
local dbproxy = require "libdbproxy"
local libcenter = require "libcenter"
local tool = require "tool"

local M = env.dispatch

function M.register(msg)
    local account = msg.account
    local password = msg.password
    local ret = dbproxy.findOne(nil, "account", {account=account})
    if ret then
        return false
    end
    local uid = dbproxy.incr("account") 
    local data = {
        uid = uid,
        account = account,
        password = password
    }
    local ret = dbproxy.insert(nil, "account", data) 
    return true, data
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

        if libcenter.login(uid, data) then
            --print("ret: " .. tool.dump(ret))
            return true, ret
        end
        return false
    end

    local ret, data = M.register(msg)
    if ret then
        print("test: " .. tool.dump(data))
        return true, data
    end

    return false
end


