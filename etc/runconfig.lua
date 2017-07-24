return {
    TEST = true,
    version = "1.0.0",
	
	--集群地址配置
	cluster = {
		node1 = "127.0.0.1:2528", 
		node2 = "127.0.0.1:2529",
	},
	
	--各个服务配置
	service = {
		--debug_console服务
		--每个节点都需要配置一个
		debug_console = {
			[1] = {port=8701, node = "node1"},
			[2] = {port=8702, node = "node2"},
		},
		
		--watchdog服务
		--每个节点都需要配置一个
		watchdog_common = {maxclient = 1024, nodelay = true},
		watchdog = {
			[1] = {port = 8798,  node = "node2"},
			[2] = {port = 8799,  node = "node1"},
		},
		--center服务
		center = {
			[1] = {node = "node1"},
			[2] = {node = "node1"},
		},
		--login服务
		login = {
			[1] = {node = "node1"},
			[2] = {node = "node1"},
		},
		--dbproxy服务
		dbproxy_common = {db_type = "mongodb",host = "127.0.0.1",db_name = "test"},
		dbproxy = {
			[1] = {node = "node1"},
			[2] = {node = "node1"},
		},
		--agentpool服务
		--每个有agent的节点需要开启
		--agentpool_common.name 要启动缓存的 agent 文件名
        --agentpool_common.maxmun 池的最大容量
        --agentpool_common.recyremove 如果池的最大容量都用完之后， 后续扩展的容量在回收时是否删除，0：不删除 1：删除
		agentpool_common = {name = "wsagent", maxnum = 10, recyremove = 2, brokecachelen=10},
		agentpool = {
			[1] = {node = "node2"},
			[2] = {node = "node1"},
		},
    },
}
