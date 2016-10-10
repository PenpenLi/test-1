local sprotoparser = require "app/net/sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

handshake 1 {
	response {
		msg 0  : string
	}
}

quit 2 {}

.playerBase {
	did			0 : string
	uid			1 : integer
	nickname	2 : string
	gold		3 : integer
	diamond		4 : integer
	stamina		5 : integer
}

.item {
	id 		0 : integer
	num		1 : integer
}

.stage {
	chapter		0 : integer
	section		1 : integer
}

.playerInfo {
	base		0 : playerBase
	item		1 : *item
	stage 		2 : *stage
}

.dropTab {
	gold		0 : integer
	item		1 : *item
}

login 3 {
	request {
		did		0 : string
	}
	response {
		playerInfo		0 : playerInfo
	}
}

rename 4 {
	request {
		uid		0 : string
		name    1 : string
	}
	response {
		result	0 : integer
		name    1 : string
	}
}

stageStart 5 {
	request {
		uid		0 : string
		stageId	1 : integer
	}
	response {
		result		0 : integer
		stamina		1 : integer
	}
}

stageAccount 6 {
	request {
		uid		0 : string
		stageId	1 : integer
		result	2 : integer
	}
	response {
		result		0 : integer
		dropTab		1 : dropTab
	}
}

.record{
	optName			0 : string		# 操作玩家名字
	optType			1 : integer		# 操作类型  1、偷 2、帮助
	optIndex		2 : integer		# 操作植物下标
	optResult		3 : integer		# 操作结果  （增益值或减益值）
	optTime			4 : integer		# 操作时间
}

.flower{
	id 			0 : integer
	index 		1 : integer
	beginTime	2 : integer
	state 		3 : integer 	# 0、无法操作    1、可以收取    2、可以帮助
	helpCount	4 : integer
	stealCount	5 : integer
}

.friendState{
	uid 		0 : string
	name 		1 : string
	type 		2 : integer   # 0、无法操作    1、可以偷    2、可以帮助
	level		3 : integer
}

gardenEnter 7 {
	request {
	}
	response {
		playerGarden	0 : *flower
		friendList		1 : *friendState
		record			2 : *record
		item 			3 : *item
	}
}

friendGarden 8 {
	request {
		uid 			0 : string
	}
	response {
		playerGarden	0 : *flower
	}
}

gatherFlower 9 {
	request {
		uid		0 : string
		index 	2 : integer
	}
	response {
		result 		0 : integer
		gold 		1 : integer
		dropTab		2 : dropTab
		index       3 : index
		diamond	    4 : integer
		addgold	    5 : integer
		adddiamond	6 : integer
	}
}

stealFlower 10 {
	request {
		uid		0 : string
		index 	2 : integer
	}
	response {
		result 		0 : integer
		gold 		1 : integer
	}
}

helpFlower 11 {
	request {
		uid		0 : string
		index 	1 : integer
	}
	response {
		result 		0 : integer
		stamina 	1 : integer
	}
}

cutFlowerTime 12 {
	request {
		index 	1 : integer
	}
	response {
		result 		0 : integer
		flower	    1 : flower
	}
}

getNewLand 13 {
	request {
		index 	1 : integer
	}
	response {
		result 		0 : integer
	}
}

plantLand 14 {
	request {
		index	1 : integer
		id		2 : integer
	}
	response {
		result		0 : integer
		flower	    1 : flower
	}
}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}

notifyStamina 2 {
	request {
		stamina 	0 : integer
	}
}

notifyFlower 3 {
	request {
		index 	0 : integer
	}
}

]]

return proto
