

local monster = class("monster", function ()
    return display.newSprite()
end)

local math2d = require("math2d")

local scale = 0.6

local GameObject = cc.GameObject

function monster:ctor( t )

    self.scene = t.parent

    local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.0, 0.0, 0.0)
    local body = cc.PhysicsBody:createBox(self:getContentSize(), MATERIAL_DEFAULT, cc.p(0,0))
    body:setCategoryBitmask(0x0111)
    body:setContactTestBitmask(0x1111)
    body:setCollisionBitmask(0x1001)
    
    if t.isBoss then
        scale = 2
        print("boss::: "..t.path..".json")
    else
        scale = 0.6
    end
    

    local skeletonNode = sp.SkeletonAnimation:create(t.path..".json", t.path..".atlas", 1)
    skeletonNode:setScale(scale)
    -- skeletonNode:setPosition(960 * 0.5 , 640 * 0.5)
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "run", true)
    self.skeletonNode = skeletonNode

    -- local skeletonNode01 = sp.SkeletonAnimation:create(t.peishiPath..".json", t.peishiPath..".atlas", 1)
    -- skeletonNode01:setScale(scale)
    -- skeletonNode01:setPosition(0 , 50)
    -- self:addChild(skeletonNode01)
    -- skeletonNode01:setAnimation(0, "idle", true)
    -- self.skeletonNode01 = skeletonNode01

    self:setPhysicsBody(body)

    self:addStateMachine()

    self.isDie = false

    self.speed = t.speed
    self.ackDistance = 20
    self.initBlood = t.blood
    self.blood = t.blood

    self.deaAmPos = {x = 0, y = 50}

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
            {name = "dead", from = {"run", "idle", "hurt"}, to = "dead"},
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

                self:getPhysicsBody():setVelocity(cc.p(0, 200))
                print(" setVelocitysetVelocitysetVelocity     ===============   setVelocity")

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:doEvent("run")
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)


            end,

            onenterdead = function ()
                self.skeletonNode:setToSetupPose()
                self.skeletonNode:setAnimation(0, "dead", true)
                self:addGold()

                local skeletonNode = self.skeletonNode
                local function ackBack()
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    self:die()
                end

                skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

                skeletonNode:registerSpineEventHandler(function (event)
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                    if event.eventData.name == "dea" then
                        print("dea  dea dea dea dea dea dea dea")
                        self:playDeaAm()
                    end
                end, sp.EventType.ANIMATION_EVENT)

            end,

            -- onenterwalk = function ()
            --     self.skeletonNode:setToSetupPose()
            --     self.skeletonNode:setAnimation(0, "run", true)

            -- end,


        },
    })
end

function monster:addGold( ... )
    print("addGold    1111111111")
    local cp = cc.p(self:getPosition())
    for i=1,2 do
        local jibiNode = cc.Node:create()
        self.scene.mapSprite:addChild(jibiNode)
        jibiNode:setPosition(cp.x, cp.y)

        local jinbiImageView = display.newSprite("res/mainUI/bt_jinbi.png")
        jibiNode:addChild(jinbiImageView)
        jinbiImageView:setName("jinbi")
        jinbiImageView:setScale(0.6)    
        jinbiImageView:setPosition(0, 0)
        self:jinbiFly(jinbiImageView , appCurScene.flower, jibiNode)
        jibiNode:setCameraMask(cc.CameraFlag.USER7)
        jinbiImageView:setCameraMask(cc.CameraFlag.USER7)

        print("addGold    22222222")
    end
end



function monster:jinbiFly(  jinbi, uiJinbi , jibiNode)
    local function fly( ... )
        local function flyBack( ... )

            local function performWithDelay1(node, callback, delay)
                print("1111")
                local delay = cc.DelayTime:create(delay)
                local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
                node:runAction(sequence)
                return sequence
            end

            -- "res/effect/jb/jb.ExportJson"
           local skeletonNode = sp.SkeletonAnimation:create("res/effect/jb/jb_0000.json", "res/effect/jb/jb_0000.atlas", 1)
            skeletonNode:setPosition(70 , 0)
            uiJinbi:addChild(skeletonNode)
            skeletonNode:setAnimation(0, "zs", false)
            skeletonNode:setCameraMask(cc.CameraFlag.USER7)
            performWithDelay1(uiJinbi, function( ... )
                skeletonNode:removeFromParent()
                
                jibiNode:removeFromParent()
            end, 0.4)

            
        end

        local xcam = appCurScene._camera:getPosition3D()
        print("xxxxx xcam "..xcam.x)
        local x, y = jinbi:getPosition()
        local p0 = jinbi:getParent():convertToWorldSpace(cc.p(x, y))
        print("xxxxx p0.x "..p0.x)
        print("xxxxx p0.y "..p0.y)
       
        print("xxxxx  wwwwwwwwwwwwwww     p0.x "..p0.x)
        local x, y = uiJinbi:getPosition()
        local p1 = uiJinbi:getParent():convertToWorldSpace(cc.p(x, y))
        print("xxxxx p1.x "..p1.x)
        print("xxxxx p1.y "..p1.y)
        local mx = p1.x - p0.x
        local my = p1.y - p0.y
        local bezier = {
            cc.p(0, 0),
            cc.p(mx + math.random(-200,200), math.random(100,200)),
            cc.p(mx, my),
        }
        local bezierForward = cc.BezierBy:create(0.8, bezier)


        jibiNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(10,20) * 0.01),bezierForward, cc.CallFunc:create(flyBack) ))
    end
    local b = 1.5
    local mx = math.random(-40 * b,40 * b)
    local my = 0--math.random(-40 * b,30 * b)
    local bezier = {
        cc.p(0, 0),
        cc.p(mx * 0.5, math.random(160 * b,180 * b)),
        cc.p(mx, my),
    }
    local time = math.random(40,70) * 0.01
    local bezierForward = cc.BezierBy:create(time, bezier)
    local actionTo = cc.RotateTo:create(time, mx * (45/(360 * b)))
    local spawn = cc.Spawn:create(bezierForward, actionTo)

    jibiNode:runAction(cc.Sequence:create(
                spawn, 
                cc.MoveBy:create(0.1,cc.p(0,20)),
                cc.MoveBy:create(0.1,cc.p(0,-20)),
                cc.MoveBy:create(0.05,cc.p(0,10)),
                cc.MoveBy:create(0.05,cc.p(0,-10)), 
                cc.CallFunc:create(fly)))


end

function monster:playDeaAm()
    local skeletonNode = sp.SkeletonAnimation:create("spine/dea/dea.json", "spine/dea/dea.atlas", 1)
    -- skeletonNode:setScale(scale)
    skeletonNode:setPosition(self.deaAmPos.x , self.deaAmPos.y)
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "dea", true)
    skeletonNode:setCameraMask(cc.CameraFlag.USER7)
end

function monster:update()
    if self.targetPos and self:getState() == "run" then
        local spineboy = self.scene.spineboy
        local spineboycp = cc.p(spineboy:getPosition())

        local cp = cc.p(self:getPosition())
        local d = math2d.dist(cp.x, cp.y, self.targetPos.x, self.targetPos.y)

        local spineboyD = math2d.dist(cp.x, cp.y, spineboycp.x, spineboycp.y)

        if d < self.ackDistance then
            -- self:doEvent("run")
            self:doEvent("dead")
            self.scene:ackCastle(10)
            self.scene:Shake()

        else
            -- if cp.x < self.targetPos.x then
            --     print("111111111")
            -- end

            -- if ((spineboycp.x > cp.x and spineboyD > 15) or spineboycp.x < cp.x) then
            --     print("22222222")
            -- end

            -- if spineboycp.y > 30  + self.scene.ground then
            --     print("3333333")
            -- end

            if cp.x < self.targetPos.x and (((spineboycp.x > cp.x and spineboyD > 15) or spineboycp.x < cp.x) or spineboycp.y > 30  + self.scene.ground) then
                self:setPosition(cp.x + self.speed, cp.y)
                self:setScaleX(1)
                
            elseif cp.x > self.targetPos.x and (((spineboycp.x < cp.x and spineboyD > 15) or spineboycp.x > cp.x) or spineboycp.y > 30 + self.scene.ground) then
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
    -- print(" behurt    cp.x  "..cp.x)
    -- print(" behurt  playerCp.x  "..playerCp.x)
    -- print(" behurt    cp.x  "..state)
    local d = math2d.dist(cp.x, cp.y, playerCp.x, playerCp.y)

    if cp.x >= playerCp.x and  state == 1 and d < ackDistance then
        -- print(" behurt    cp.x  1111111111111111")
        self:doEvent("hurt")
        self:piaoXue(ackHurt)
        self:jitui(state)
    elseif cp.x < playerCp.x and  state == -1 and d < ackDistance then
        -- print(" behurt    cp.x  2222222222222222222")
        self:doEvent("hurt")
        self:piaoXue(ackHurt)
        self:jitui(state)
    end
end

function monster:jitui(state)
    local cp = cc.p(self:getPosition())
    local tx = math.random(20, 50) * state
    local ty = math.random(20, 50)
    local bezier = {
        cc.p(0, 0),
        cc.p(tx * 0.5 , ty),
        cc.p(tx, 0),
    }
    
    local bezierForward = cc.BezierBy:create(0.15, bezier)
    self:runAction(bezierForward)
end

function monster:piaoXue(ackHurt)
    self.blood = self.blood - ackHurt
    self:piaoXueLabel(ackHurt)
    -- print(" self.blood  "..self.blood)
    if self.blood > 0 then
        self:setProPercentage(math.ceil(100 * (self.blood / self.initBlood)))
    else
        self:doEvent("dead")
        self.scene:addNuQi(10)
    end
end

function monster:piaoXueLabel( ackHurt )
    local state = self:getScaleX()

    ackHurt = ackHurt

    local fut = "res/font/fnt_02.fnt"


    local hurtText = ccui.Text:create("", "fonts/huakang.TTF", 50)
    hurtText:setColor(cc.c3b(255, 0, 0))
    hurtText:setCameraMask(cc.CameraFlag.USER7)

    hurtText:setString("- "..ackHurt)
    hurtText:setScale(0.2)
    hurtText:setFlippedX(true)
    hurtText:setPositionY(150)
    self:addChild(hurtText)
    hurtText:setAnchorPoint(cc.p(0.5,1))
    local function hurtBack( ... )
        hurtText:removeFromParent()
    end
    local action1 = cc.Spawn:create(cc.ScaleTo:create(0.2,0.01),cc.MoveBy:create(0.2, cc.p(0,50)))

    hurtText:runAction( cc.Sequence:create(cc.ScaleTo:create(0.2,1), action1, cc.CallFunc:create(hurtBack)))

    
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
    progressbg:setPosition(cc.p(0,80))
    progressbg:setVisible(false)
end

function monster:setProPercentage(Percentage)
    self.fill:setPercentage(Percentage)  -- 9
end


return monster


