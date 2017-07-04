local skynet = require "skynet"
local log = require "log"

local function testmysql()
    local mysql = require "mysqldb"
    local conf = {
        host = "127.0.0.1",
        port = "3306",
        database = "test",
        --user = "root",
        --password = "root"
    }
    assert(mysql.start(conf)) 

    local data = {
        id = 2,
        name = "test",
        key1 = "keyt2",
        tname = {
            k = "k",
            test = "test",
       }
    }
    mysql.replace("test", data)
end

skynet.start(function()
    log.debug("start test...")
    testmysql() 
    log.debug("end test...")
    skynet.exit()
end)
