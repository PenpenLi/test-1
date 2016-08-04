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
	item		0 : *item
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

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}
]]

return proto
