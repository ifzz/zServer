local skynet = require "skynet"
local builder = require "skynet.datasheet.builder"
local datasheet = require "skynet.datasheet"
local log = require "log"
local env = require "env"

local M = env.dispatch

local function update()
    skynet.timeout(100, 
        function() 
            M.update_all()  
            update()
        end )
end

local function dir(path)
    local lfs = require "lfs"
    local ret = {}
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local file = string.match(file, "(%w+)%.lua")
            if file then
                table.insert(ret, file)
            end
        end
    end
    return ret
end

local reload = require "reload"
local function init()
    local list = dir("config")
    for k, v in pairs(list) do
        log.debug("init " .. v .. " conf")
        local conf = reload.loadmod(v)
        builder.new(v, conf)
    end
end


function M.update_all()
    for k, v in pairs(list) do
        local conf = reload.loadmod(v)
        builder.update(v, conf)
        log.debug("update conf: " .. v)
    end
end

function M.update(name)
    local conf = reload.loadmod(name)
    builder.update(name, conf)
    log.debug("update conf: " .. name)
end

skynet.init(init)



