local sprotoparser = require "app.net.sprotoparser"

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

.base{
    id              0 : integer
    uid             1 : string
    qudao           2 : string
    areaId          3 : integer
    gold            4 : integer
    diamond         5 : integer
    nickName        6 : string
    stage           7 : integer
}

.pet{
    id              0 : integer
    lv              1 : integer
    skillLv         2 : integer
    xinLv           3 : integer
    eq01            4 : integer
    eq02            5 : integer
    eq03            6 : integer
}

.master{
    lv              0 : integer
    skillLv         1 : integer
    eq01            2 : integer
    eq02            3 : integer
    eq03            4 : integer
}

.equip{
    id              0 : integer
    lv              1 : integer
    user            2 : integer
    param1          3 : integer
    param2          4 : integer
}

login 2 {
    request {
        qudao       0 : string
        uid         1 : string
        areaId      2 : integer
    }
    response {
        result      0 : integer
        base        1 : base
        master      2 : master
        pet         3 : *pet
        equip       4 : *equip
    }
}

randomname 3 {
    request {
        
    }
    response {
        result      0 : integer
        nickName    1 : string
    }
}

newchar 4 {
    request {
        nickName    0 : string
    }
    response {
        result      0 : integer
    }
}

masterlevelup 5 {
    request {

    }
    response {
        result      0 : integer
    }
}

petlevelup 6 {
    request {
        id          0 : integer
    }
    response {
        result      0 : integer
    }   
}

petstarup 7 {
    request {
        id          0 : integer
    }
    response {
        result      1 : integer
    }
}

skillup 8 {
    request {
        id          0 : integer
    }
    response {
        result      0 : integer
    }
}

equiplevelup 9 {
    request {
        id          0 : integer
    }
    response {
        result      0 : integer
        param1      2 : integer
        param2      3 : integer
    }
}

wearequip 10 {
    request {
        id          0 : integer
        eqId        1 : integer
    }
    response {
        result      0 : integer
    }
}

killmonster 11 {
    request {

    }
    response {
        result      0 : integer
        gold        1 : integer
    }
}

stageaccount 12 {
    request {
    
    }
    response {
        result      0 : integer
        gold        1 : integer
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
