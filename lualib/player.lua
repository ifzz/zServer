
local Player = {}

Player.__index = Player

function Player.new(o)
    local o = o or {}
    setmetatable(o, Player)
    return o
end


return Player

