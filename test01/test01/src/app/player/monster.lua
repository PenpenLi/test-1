

local monster = class("monster", function ()
    return display.newSprite()
end)

local math2d = require("math2d")

local GameObject = cc.GameObject

function monster:ctor( ... )

    local body = cc.PhysicsBody:createBox(self:getContentSize(), cc.PHYSICSBODY_MATERIAL_DEFAULT, cc.p(0,0))

    self:setPhysicsBody(body)
    

    local skeletonNode = sp.SkeletonAnimation:create("spine/monster1/monster1.json", "spine/monster1/monster1.atlas", 0.6)
    skeletonNode:setScale(0.4)
    -- skeletonNode:setPosition(960 * 0.5 , 640 * 0.5)
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "run", true)
    self.skeletonNode = skeletonNode

    self:addStateMachine()


    self.speed = 1
    self.ackDistance = 5
    self.blood = 100
    
end

function monster:getSkeletonNode()
    return self.skeletonNode
end

function monster:doEvent(event)
    self.fsm:doEvent(event)
end

function monster:doEventForce(event)
    self.fsm:doEventForce(event)
end


function monster:getState()
    return self.fsm:getState()
end

function monster:setAckToState(ackToState)
    self.ackToState = ackToState or "idle"
end

function monster:getAckToState()
    local a =  self.ackToState or "idle"
    self.ackToState = "idle"
    return a
end


function monster:addStateMachine()
    self.fsm = {}
    GameObject.extend(self.fsm):addComponent("components.behavior.StateMachine"):exportMethods()

    self.fsm:setupState({
        initial = "run",

        events = {
            {name = "run", from = {"idle", "hurt"}, to = "run"},
            {name = "idle", from = {"run", "hurt"}, to = "idle"},
            {name = "hurt", from = {"run", "idle"}, to = "hurt"},
            -- {name = "walk", from = {"walk", "idle", "hurt"}, to = "walk"},
        },

        callbacks = {
            onenteridle = function ()
                print(" setAnimation(0, idle, true) ")
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:setAnimation(0, "idle", true)
            end,

            onenterrun = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:setAnimation(0, "run", true)
            end,

            onenterhurt = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:setAnimation(0, "hurt", true)

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    print("ackBackackBack  ackBackackBack")
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent("run")
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            end,

            -- onenterwalk = function ()
            --     self.skeletonNode:setToSetupPose()
            --     self.skeletonNode:setAnimation(0, "run", true)

            -- end,


        },
    })
end

function monster:update()
    if self.targetPos and self:getState() == "run" then

        local cp = cc.p(self:getPosition())
        local d = math2d.dist(cp.x, cp.y, self.targetPos.x, self.targetPos.y)
        if d < self.ackDistance then
            -- self:doEvent("run")
        else
            if cp.x < self.targetPos.x then
                self:setPosition(cp.x + self.speed, cp.y)
                self:setScaleX(1)
            else
                self:setPosition(cp.x - self.speed, cp.y)
                self:setScaleX(-1)
            end
        end
    end
end

function monster:setTargetPos( t )
    self.targetPos = t
end

function monster:beHit(playerCp, state, ackDistance)
    local cp = cc.p(self:getPosition())
    local cp = self:getParent():convertToWorldSpace(cp)
    print(" behurt    cp.x  "..cp.x)
    print(" behurt  playerCp.x  "..playerCp.x)
    print(" behurt    cp.x  "..state)
    local d = math2d.dist(cp.x, cp.y, playerCp.x, playerCp.y)

    if cp.x >= playerCp.x and  state == 1 and d < ackDistance then
        print(" behurt    cp.x  1111111111111111")
        self:doEvent("hurt")
    elseif cp.x < playerCp.x and  state == -1 and d < ackDistance then
        print(" behurt    cp.x  2222222222222222222")
        self:doEvent("hurt")
    end
end



return monster


