

local monster = class("monster", function ()
    return display.newSprite()
end)

local math2d = require("math2d")

local scale = 0.4

local GameObject = cc.GameObject

function monster:ctor( t )

    local body = cc.PhysicsBody:createBox(self:getContentSize(), cc.PHYSICSBODY_MATERIAL_DEFAULT, cc.p(0,0))

    self:setPhysicsBody(body)
    

    local skeletonNode = sp.SkeletonAnimation:create("spine/monster1/monster1.json", "spine/monster1/monster1.atlas", 0.6)
    skeletonNode:setScale(scale)
    -- skeletonNode:setPosition(960 * 0.5 , 640 * 0.5)
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "run", true)
    self.skeletonNode = skeletonNode

    self:addStateMachine()

    self.isDie = false

    self.speed = 1
    self.ackDistance = 5
    self.initBlood = t.blood
    self.blood = t.blood

    self:createProgress()
    
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

function monster:beHit(playerCp, state, ackDistance, ackHurt)
    local cp = cc.p(self:getPosition())
    local cp = self:getParent():convertToWorldSpace(cp)
    print(" behurt    cp.x  "..cp.x)
    print(" behurt  playerCp.x  "..playerCp.x)
    print(" behurt    cp.x  "..state)
    local d = math2d.dist(cp.x, cp.y, playerCp.x, playerCp.y)

    if cp.x >= playerCp.x and  state == 1 and d < ackDistance then
        print(" behurt    cp.x  1111111111111111")
        self:doEvent("hurt")
        self:piaoXue(ackHurt)
    elseif cp.x < playerCp.x and  state == -1 and d < ackDistance then
        print(" behurt    cp.x  2222222222222222222")
        self:doEvent("hurt")
        self:piaoXue(ackHurt)
    end
end

function monster:piaoXue(ackHurt)
    self.blood = self.blood - ackHurt
    print(" self.blood  "..self.blood)
    if self.blood > 0 then
        self:setProPercentage(math.ceil(100 * (self.blood / self.initBlood)))
    else
        self:die()
    end
end

function monster:die()
    self:setVisible(false)
    self.isDie = true
end

function monster:IsDie( ... )
    return self.isDie
end

function monster:createProgress()
    local blood = 100 -- 1
    local progressbg = display.newSprite("ui/xt_di.png") -- 2
    progressbg:setScale(scale)
    self.fill = display.newProgressTimer("ui/xt_hong.png", display.PROGRESS_TIMER_BAR)  -- 3

    self.fill:setMidpoint(cc.p(1, 0.5))   -- 4
    self.fill:setBarChangeRate(cc.p(1.0, 0))   -- 5
    -- 6
    self.fill:setPosition(progressbg:getContentSize().width/2, progressbg:getContentSize().height/2) 
    progressbg:addChild(self.fill)
    self.fill:setPercentage(blood) -- 7

    -- 8
    progressbg:setAnchorPoint(cc.p(0.5, 0))
    self:addChild(progressbg)
    progressbg:setPosition(cc.p(0,40))
end

function monster:setProPercentage(Percentage)
    self.fill:setPercentage(Percentage)  -- 9
end


return monster


