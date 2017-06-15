return {
    TEST = true,
    version = "1.0.0",

    node1 = {
        -- 当前节点控制台监听端口
        debug_console_port = 8801,
        -- agent 池配置
        agentpool = {
            name = "agent", -- 要启动缓存的 agent 文件名
            maxmun = 2,     -- 池的最大容量
            recyremove = 0, -- 如果池的最大容量都用完之后， 后续扩展的容量在回收时是否删除，0：不删除 1：删除
        },

        db = {
            
           db_type = "mongodb", 
           host = "127.0.0.1",
           db_name = "test",
           dbproxy_num = 2,
        },

        login_num = 2,    

        watchdog = {
            port = 8899,
            maxclient = 1024,
            nodelay = true,
        }
    },
}
