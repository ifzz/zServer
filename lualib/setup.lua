local skynet = require "skynet"
local builder = require "skynet.datasheet.builder"
local datasheet = require "skynet.datasheet"
local log = require "log"
local env = require "env"

local M = env.dispatch

local list = {
    "test",
    "item",
}

local function update()
    skynet.timeout(100, 
        function() 
            print("update all") 
            M.update_all()  
            update()
        end )
end

local reload = require "reload"
local function init()
    for k, v in pairs(list) do
        local conf = reload.loadmod(v)
        builder.new(v, conf)
    end
    update()
end


function M.update_all()
    for k, v in pairs(list) do
        local conf = reload.loadmod(v)
        builder.update(v, conf)
    end
end

function M.update(name)
    local conf = require(name)
    builder.update(v, conf)
end

skynet.init(init)

