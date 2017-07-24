local skynet = require "skynet"
local log = require "log"
local libcenter = require "libcenter"

function M.create_room(id)
	local p = skynet.newservice("movegame")
	local data = {
		room = p,
		node=skynet.getenv("nodename"),
	}
	libcenter.register_room(id, data)
end

function 



