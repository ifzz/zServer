local skynet = require "skynet"
local log = require "log"
local runconf = require(skynet.getenv("runconfig"))

local gametype = ...
local roomconf = runconf[gametype]

local MAX_PLAYER_COUNT = roomconf.max_player_count or 1
local players = {}

local function random_position()
    for i = 1, MAX_PLAYER_COUNT do
        if players[i] == nil then
            return i
        end
    end
end

local function can_enter(pos)
    if not pos then
        return false
    end
    if players[pos] then
        return false
    end
    return true
end

--
--
--
local CMD = {}
function CMD.enter(player, pos)
    if not pos then
        pos = random_position()
    end

    if not can_enter(pos) then
        return false
    end

    players[pos] = player
    return true, pos
end

function CMD.exit(pos)
    players[pos] = nil
end

function CMD.talk(msg)
    for i = 1, MAX_PLAYER_COUNT do
        local player = players[i]
        if player then
            skynet.send(player.agent, "lua", "send", msg)
        end
    end
end

skynet.start(function()
	skynet.dispatch("lua",function(session,source,cmd,...)
		local f = assert(CMD[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)
end)

