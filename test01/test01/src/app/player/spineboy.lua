

local spineboy = class("spineboy", function ()
    return display.newSprite()
end)


local GameObject = cc.GameObject

function spineboy:ctor( ... )

    local body = cc.PhysicsBody:createBox(self:getContentSize(), cc.PHYSICSBODY_MATERIAL_DEFAULT, cc.p(0,0))

    self:setPhysicsBody(body)
    

    local skeletonNode = sp.SkeletonAnimation:create("spine/hero/hero.json", "spine/hero/hero.atlas", 0.6)
    skeletonNode:setScale(0.5)
    -- skeletonNode:setPosition(960 * 0.5 , 640 * 0.5)
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "idle", true)
    self.skeletonNode = skeletonNode

    self:addStateMachine()
    
end

function spineboy:getSkeletonNode()
    return self.skeletonNode
end

function spineboy:doEvent(event)
    self.fsm:doEvent(event)
end

function spineboy:doEventForce(event)
    self.fsm:doEventForce(event)
end


function spineboy:getState()
    return self.fsm:getState()
end

function spineboy:setAckToState(ackToState)
    self.ackToState = ackToState or "idle"
end

function spineboy:getAckToState()
    local a =  self.ackToState or "idle"
    self.ackToState = "idle"
    return a
end


function spineboy:addStateMachine()
    self.fsm = {}
    GameObject.extend(self.fsm):addComponent("components.behavior.StateMachine"):exportMethods()

    self.fsm:setupState({
        initial = "idle",

        events = {
            {name = "run", from = {"idle", "attack1", "jump1", "jump2"}, to = "run"},
            {name = "jump1", from = {"idle", "run"}, to = "jump1"},
            {name = "jump2", from = {"idle", "walk", "run", "jump1"}, to = "jump2"},
            {name = "idle", from = { "jump1", "jump2", "run", "attack1", "attack2", "attack3"}, to = "idle"},
            {name = "attack1", from = {"run", "jump1", "jump2", "idle", "attack2", "attack3"}, to = "attack1"},
            {name = "attack2", from = {"run", "jump1", "jump2", "idle", "attack1", "attack3"}, to = "attack2"},
            {name = "attack3", from = {"run", "jump1", "jump2", "idle", "attack1", "attack2"}, to = "attack3"},
        },

        callbacks = {
            onenteridle = function ()
                print(" setAnimation(0, idle, true) ")
                self.skeletonNode:setAnimation(0, "idle", true)
            end,

            onenterrun = function ()
                self.skeletonNode:setAnimation(0, "run", true)
            end,

            onenterjump1 = function ()
                self.skeletonNode:setAnimation(0, "jump1", false)
            end,

            onenterjump2 = function ()
                self.skeletonNode:setAnimation(0, "jump2", false)
            end,

            

            onenterattack1 = function ()
                self.skeletonNode:setAnimation(0, "attack1", false)
                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent(self:getAckToState())
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)
            end,

            onenterattack2 = function ()
                self.skeletonNode:setAnimation(0, "attack2", false)

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent(self:getAckToState())
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            end,

            onenterattack3 = function ()
                self.skeletonNode:setAnimation(0, "attack3", false)

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent(self:getAckToState())
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)
            end,

        },
    })
end



return spineboy



                -- self.skeletonNode:registerSpineEventHandler(function (event)
                --     self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
            
                --     print(string.format("[spine] %d event: %s, %d, %f, %s", 
                --               event.trackIndex,
                --               event.eventData.name,
                --               event.eventData.intValue,
                --               event.eventData.floatValue,
                --               event.eventData.stringValue))
                -- end, sp.EventType.ANIMATION_EVENT)


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