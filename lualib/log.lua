local skynet = require "skynet"
local logger = {}

local loglevel = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
}

local function init_log_level()
    if not logger._level then
        local level = skynet.getenv("log_level")
        local default_level = loglevel.debug
        local val

        if not level or not loglevel[level] then
            val = default_level
        else
            val = loglevel[level]
        end

        logger._level = val
    end
end

local function logmsg(loglevel, msg)
    skynet.error(msg)
end

function logger.set_log_level(level)
    local val = loglevel.debug

    if level and loglevel[level] then
        val = loglevel[level]
    end

    logger._level = val
end

function logger.debug(msg)
    if logger._level <= loglevel.debug then
        logmsg(loglevel.debug, msg)
    end
end

function logger.info(msg)
    if logger._level <= loglevel.info then
        logmsg(loglevel.info, msg)
    end
end

function logger.warn(msg)
    if logger._level <= loglevel.warn then
        logmsg(loglevel.warn, msg)
    end
end

function logger.error(msg)
    if logger._level <= loglevel.error then
        logmsg(loglevel.error, msg)
    end
end

skynet.init(init_log_level)

return logger

