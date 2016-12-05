local protoHeadsWithID = {
equipTableRes = {
	protoHead	=
	[[
	.Unit {
		ID 0 : *integer
		Name 1 : string
		Desc 2 : string
		Type 3 : *integer
		quality 4 : *integer
		iconSrc 5 : string
	}

	.equipTableBook {
		equipTable 0 : *Unit
	}
	]]
	,
	headName = "equipTable",
},
speedTableRes = {
	protoHead	=
	[[
	.Unit {
		LV 0 : *integer
		Attack01 1 : *integer
		Attack02 2 : *integer
		Attack03 3 : *integer
		Attack04 4 : *integer
		Attack05 5 : *integer
		Attack06 6 : *integer
		Attack07 7 : *integer
		Attack08 8 : *integer
		Attack09 9 : *integer
		Attack10 10 : *integer
		Crit01 11 : *integer
		Crit02 12 : *integer
		Crit03 13 : *integer
		Crit04 14 : *integer
		Crit05 15 : *integer
		Crit06 16 : *integer
		Crit07 17 : *integer
		Crit08 18 : *integer
		Crit09 19 : *integer
		Crit10 20 : *integer
		Speed01 21 : *integer
		Speed02 22 : *integer
		Speed03 23 : *integer
		Speed04 24 : *integer
		Speed05 25 : *integer
		Speed06 26 : *integer
		Speed07 27 : *integer
		Speed08 28 : *integer
		Speed09 29 : *integer
		Speed10 30 : *integer
	}

	.speedTableBook {
		speedTable 0 : *Unit
	}
	]]
	,
	headName = "speedTable",
},
materialTableRes = {
	protoHead	=
	[[
	.Unit {
		ID 0 : *integer
		Name 1 : string
		Desc 2 : string
		quality 3 : *integer
		iconSrc 4 : string
	}

	.materialTableBook {
		materialTable 0 : *Unit
	}
	]]
	,
	headName = "materialTable",
},
petTableRes = {
	protoHead	=
	[[
	.Unit {
		ID 0 : *integer
		Name 1 : string
		Pet_Desc 2 : string
		quality 3 : *integer
		Src 4 : string
		headSrc 5 : string
		materialID 6 : *integer
		callNum 7 : integer
		promotionNum 8 : integer
	}

	.petTableBook {
		petTable 0 : *Unit
	}
	]]
	,
	headName = "petTable",
},
}

local protoHeadsWithIDSlite = {
}

return {p=protoHeadsWithID, ps=protoHeadsWithIDSlite}