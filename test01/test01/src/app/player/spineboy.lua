

local spineboy = class("spineboy", function ()
    return display.newSprite()
end)


local GameObject = cc.GameObject

function spineboy:ctor( t )
    self.parent = t.parent

    self.rate_ = 0.016

    self.ackDistance = 50
    self.ackHurt = 3000

    local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.0, 0.0, 0.0)

    local body = cc.PhysicsBody:createBox(self:getContentSize(), MATERIAL_DEFAULT, cc.p(0,0))

    self:setPhysicsBody(body)
    body:setCategoryBitmask(0x0111)
    body:setContactTestBitmask(0x1111)
    body:setCollisionBitmask(0x1001)
    

    local skeletonNode = sp.SkeletonAnimation:create("spine/hero/hero.json", "spine/hero/hero.atlas", 0.6)
    skeletonNode:setScale(0.5)
    -- skeletonNode:setPosition(960 * 0.5 , 640 * 0.5)
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "idle", true)
    self.skeletonNode = skeletonNode

    self:addStateMachine()



    self:setTag(PLAYER_TAG)

    self:start_scheduler()

    self:addCollision()
    
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
            {name = "run", from = {"idle", "attack1", "attack2", "attack3", "jump1", "jump2"}, to = "run"},
            {name = "jump1", from = {"idle", "run"}, to = "jump1"},
            {name = "jump2", from = {"idle", "walk", "run", "jump1", "attack4"}, to = "jump2"},
            {name = "idle", from = { "jump1", "jump2", "run", "attack1", "attack2", "attack3", "attack4"}, to = "idle"},
            {name = "attack1", from = {"run","idle", "attack2", "attack3"}, to = "attack1"},
            {name = "attack2", from = {"run", "idle", "attack1", "attack3"}, to = "attack2"},
            {name = "attack3", from = {"run", "idle", "attack1", "attack2"}, to = "attack3"},
            {name = "attack4", from = {"jump1", "jump2"}, to = "attack4"},
        },

        callbacks = {
            onenteridle = function ()
                print(" setAnimation(0, idle, true) ")
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "idle", true)
            end,

            onenterrun = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "run", true)
            end,

            onenterjump1 = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "jump1", false)
            end,

            onenterjump2 = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "jump2", false)
            end,

            

            onenterattack1 = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "attack1", false)
                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent(self:getAckToState())
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

                skeletonNode:registerSpineEventHandler(function (event)
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                    if event.eventData.name == "att" then
                        self:hit()
                    end
                end, sp.EventType.ANIMATION_EVENT)

                
            end,

            onenterattack2 = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "attack2", false)

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent(self:getAckToState())
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:registerSpineEventHandler(function (event)
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                    if event.eventData.name == "att" then
                        self:hit()
                    end
                end, sp.EventType.ANIMATION_EVENT)
            end,

            onenterattack3 = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "attack3", false)

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent(self:getAckToState())
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:registerSpineEventHandler(function (event)
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                    if event.eventData.name == "att" then
                        self:hit()
                    end
                end, sp.EventType.ANIMATION_EVENT)
            end,

            onenterattack4 = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                self.skeletonNode:setAnimation(0, "attack4", false)

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent(self:getAckToState())
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)
                
                skeletonNode:registerSpineEventHandler(function (event)
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                    if event.eventData.name == "att" then
                        self:hit()
                    end
                end, sp.EventType.ANIMATION_EVENT)
            end,

        },
    })
end

function spineboy:hit()
    local monster = self.parent.monster
    local cp = cc.p(self:getPosition())
    local state = self:getScaleX()
    for k,v in pairs(monster) do
        if v and  not v:IsDie() then
            v:beHit(cp, state, self.ackDistance, self.ackHurt)
        else

        end
    end
end

function spineboy:addCollision()

    local function contactLogic(node)
        if node:getTag() == GROUND_TAG then
            print("$$$$$$$$$$$$$     contactLogic =============== GROUND_TAG ")
        elseif node:getTag() == PLAYER_TAG then
            print("$$$$$$$$$$$$$     contactLogic =============== PLAYER_TAG ")
            self:doEvent("idle")
        end
    end

    local function onContactBegin(contact)
        print("$$$$$$$$$$$$$     onContactBegin =============== ")
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()

        contactLogic(a)
        contactLogic(b)
        return true
    end

    local function onContactSeperate(contact)
        print("$$$$$$$$$$$$$     onContactSeperate =============== ")
    end

    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    contactListener:registerScriptHandler(onContactSeperate, cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(contactListener, 1)
end


function spineboy:start_scheduler()
    self:stop_scheduler()

    local update_func = function(dt)
        self:updateScher()
    end

    self.scheduler_id_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_func, self.rate_, false)
end

function spineboy:stop_scheduler()
    if self.scheduler_id_ ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduler_id_)
        self.scheduler_id_ = nil
    end
end

function spineboy:updateScher( ... )
    local cp = self:getPhysicsBody():getVelocity()
    local y = cp.y
    -- print("$$$$$$$$$$$$$     updateScher =============== ".. tonumber(cp.y))
    local z,x = math.modf(y)
    -- print("$$$$$$$$$$$$$     updateScher =============Z== ".. z)
    -- print("$$$$$$$$$$$$$     updateScher =============x== ".. x)
    if  self:getState() ~= "attack4" then
        if z > 0 then
            self:doEvent("jump1")
        elseif z < 0 then 
            self:doEvent("jump2")
        else

        end
    end

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