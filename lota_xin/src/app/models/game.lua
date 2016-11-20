
EventDef = require("app.models.EventDef")

local game = class("game",require("cocos.framework.components.event"))

function game:ctor( ... )
    self:init_()
end

--[[--
    消息分发
]]
function game.dispatchGlobalEvent(event)
    game:dispatchEvent(event)
end

--[[--
    注册消息listener
]]
function game.addGlobalEventListener(eventName, listener, tag)
    return game:addEventListener(eventName, listener, tag)
end

--[[--
    注销消息listener
]]
function game.removeGlobalEventListener(eventName, key)
    game:removeEventListener(eventName, key)
end



return game