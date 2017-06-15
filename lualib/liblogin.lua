local skynet = require "skynet"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local nodeconf = runconf[skynet.getenv("nodename")]

local MAX_LOGIN_NUM = nodeconf.login_num

local M = {}
local function init()
    log.debug("init liblogin")

    M.login = {}
    for i = 1, MAX_LOGIN_NUM do
        M.login[i] = skynet.newservice("logind")
    end
end

local next_id = 1
local function fetch_login()
    next_id = next_id + 1
    next_id = next_id % MAX_LOGIN_NUM + 1
    return M.login[next_id]
end

function M.register(msg)
    local login = fetch_login()
    assert(login)
    return skynet.call(login, "lua", "register", msg)
end

function M.login(msg)
    local login = fetch_login()
    assert(login)
    return skynet.call(login, "lua", "login", msg)
end

skynet.init(init)

return M


