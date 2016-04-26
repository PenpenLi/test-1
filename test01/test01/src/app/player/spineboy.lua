

local spineboy = class("spineboy", function ()
    return display.newSprite()
end)


local GameObject = cc.GameObject

function spineboy:ctor( ... )
    

    local skeletonNode = sp.SkeletonAnimation:create("spine/spineboy.json", "spine/spineboy.atlas", 0.6)
    skeletonNode:setScale(0.5)
    -- skeletonNode:setPosition(960 * 0.5 , 640 * 0.5)
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "idle", true)
    self.skeletonNode = skeletonNode

    self:addStateMachine()
    
end

function spineboy:doEvent(event)
    self.fsm:doEvent(event)
end

function spineboy:addStateMachine()
    self.fsm = {}
    GameObject.extend(self.fsm):addComponent("components.behavior.StateMachine"):exportMethods()

    self.fsm:setupState({
        initial = "idle",

        events = {
            {name = "walk", from = {"idle", "jump", "run"}, to = "walk"},
            {name = "jump", from = {"idle", "walk", "run"}, to = "jump"},
            {name = "idle", from = {"walk", "jump", "run"}, to = "idle"},
            {name = "run", from = {"walk", "jump", "idle"}, to = "run"},
            {name = "hit", from = {"walk", "jump", "idle"}, to = "hit"},
        },

        callbacks = {
            onenteridle = function ()
                self.skeletonNode:setAnimation(0, "idle", true)
            end,

            onenterwalk = function ()
                self.skeletonNode:setAnimation(0, "walk", true)
            end,

            onenterjump = function ()
                self.skeletonNode:setAnimation(0, "jump", true)
            end,

            onenterrun = function ()
                self.skeletonNode:setAnimation(0, "run", true)
            end,

            onenterhit = function ()
                self.skeletonNode:setAnimation(0, "hit", true)
            end,
        },
    })
end



return spineboy




-- local Player = class("Player", function ()
--     return display.newSprite("icon.png")
-- end)

-- function Player:ctor()
--     self:addStateMachine()
-- end

-- function Player:doEvent(event)
--     self.fsm:doEvent(event)
-- end

-- function Player:addStateMachine()
--     self.fsm = {}
--     cc.GameObject.extend(self.fsm):addComponent("components.behavior.StateMachine"):exportMethods()

--     self.fsm:setupState({
--         initial = "idle",

--         events = {
--             {name = "move", from = {"idle", "jump"}, to = "walk"},
--             {name = "attack", from = {"idle", "walk"}, to = "jump"},
--             {name = "normal", from = {"walk", "jump"}, to = "idle"},
--         },

--         callbacks = {
--             onenteridle = function ()
--                 local scale = CCScaleBy:create(0.2, 1.2)
--                 self:runAction(CCRepeat:create(transition.sequence({scale, scale:reverse()}), 2))
--             end,

--             onenterwalk = function ()
--                 local move = CCMoveBy:create(0.2, ccp(100, 0))
--                 self:runAction(CCRepeat:create(transition.sequence({move, move:reverse()}), 2))
--             end,

--             onenterjump = function ()
--                 local jump = CCJumpBy:create(0.5, ccp(0, 0), 100, 2)
--                 self:runAction(jump)
--             end,
--         },
--     })
-- end

-- return Player