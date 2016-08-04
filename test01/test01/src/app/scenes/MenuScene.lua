require("app.layers.BackgroundLayer")

require("app/res/BeastTableRes")
require("app/res/BossTableRes")
require("app/res/CheckpointTableRes")

local AdBar = import("..views.AdBar")
local BubbleButton = import("..views.BubbleButton")




local MenuScene = class("MenuScene", function()
    return display.newPhysicsScene("MenuScene")
end)


local STICK_POS_FIXED = true

local EDGESEGMENTNUMBER = 100

GROUND_TAG   = 1
PLAYER_TAG   = 2


local scheduler = cc.Director:getInstance():getScheduler()

local stick_event = {
    notify_to_stick_event_began = "stick.event_began",
    notify_to_stick_event_moved = "stick.event_moved",
    notify_to_stick_event_ended = "stick.event_ended"
}

function MenuScene:ctor(id)
    local id = id
    self.checkId = id
    self.checkTab = CheckpointTable[self.checkId]
    print(" MenuScene:ctor   "..id)
    --倒计时
    self.ebdTime = 60
    self.bossNum = 0


    self:createCamera()

    self.speed = 10
    
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()


    self.world = self:getPhysicsWorld()

    self.world:setGravity(cc.p(0, -1000.0))

    -- self.world:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)


    self.ground = display.top * 4 / 10 - 30

    self.layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0))
    self:addChild(self.layerColor)

    local function onTouchBegan(touch, event)
        
        local location = touch:getLocation()
        -- print("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
        -- self:on_touch("began", location.x, location.y)
        return true
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        -- print("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
        -- self:on_touch("moved", location.x, location.y)
        return true
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        -- print("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
        -- self:on_touch("ended", location.x, location.y)
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self.layerColor:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.layerColor)



    self:addMap()

    -- self.backgroundLayer = BackgroundLayer.new()
    --     :addTo(self)
    -- self.backgroundLayer:startGame()



    self.touch_enable_ = true
    self.stick_pos_ = { x=100, y=100 }

    self.treePos = {x = 1100, y = self.ground}

    
    -- self:init_data("ui/yaogan01.png", "ui/yaogan02.png", 0.016)
    self.rate_ = 0.016

    self.monster =  {}
    -- self:addMonster({blood = 10000})

    self:addCastle()

    self:addSpineboy()

    self:addUI()

    self:addEdgeSegment()

    self:start_monster_scheduler()

    self.gameTime = 0
    self.gameMonSterNum = 0

    self.initChuMonsterTimes = self.checkTab["M01_time"]
    self.chuMonsterTimes = self.checkTab["M01_time"]
    self.chuMonsterNum = self.checkTab["M01_num"]

    

    appCurScene = self

    
end

function MenuScene:onEnter()

end

function MenuScene:toJieSuan()
    print(" MenuScene:onCleanup()  ================ ")
    self:stop_monster_scheduler()
    self:stop_scheduler()
    self.spineboy:endChuli()
    self.spineboy:stop_scheduler()
end

function MenuScene:onExit()
    print(" MenuScene:onExit()  ================ ")
end

function MenuScene:addTimer( ... )

end

function MenuScene:addBoss( ... )
    if self.checkTab["B01_ID"] > 0 then
        self:chuMonster({weizi = 1, isBoss = true})
    end
end

function MenuScene:onEndTimer( dt )
    self.ebdTime = self.ebdTime - dt
    -- print(string.format("self.ebdTime  ---- %02d",self.ebdTime))
    if self.ebdTime < 0 then
        self.ebdTime = 0
        
        print("00000")
        local isAllDie = true
        for k,v in pairs(self.monster) do
            print("1111111")
            if v and  not v:IsDie() then
               isAllDie = false
            end
        end
        if isAllDie then
            self:gameOver(true)
        end
    end
    self.timeLabel:setString(string.format("%d",self.ebdTime))

    if self.ebdTime < 15 and  self.bossNum == 0 then
        self.bossNum = 1
        self:addBoss()
    end

end




--     
--     local action2 = cc.MoveBy:create(0.2, cc.p(0,-50))

--     local action3 = cc.ScaleTo:create(0.2,1)
--     local action4 = cc.MoveBy:create(0.2, cc.p(0,50))

--     local action5 = cc.Spawn:create(action1, action2)
--     local action6 = cc.Spawn:create(action3, action4)

--     local action7 = cc.Sequence:create(action5, action6)

--     self.mapSprite:runAction(action7)

function MenuScene:Shake( ... )
    local t = {}
    t[1] = self.mapSprite
    t[2] = self.mapYuanSprite
    for i=1,2 do
        local action1 = cc.ScaleTo:create(0.1,1.05)

        local action2 = cc.MoveBy:create(0.1, cc.p(10,10))
        local action3 = cc.MoveBy:create(0.1, cc.p(-20,-20))
        local action4 = cc.MoveBy:create(0.1, cc.p(10,10))

        local action12 = cc.MoveBy:create(0.1, cc.p(10,10))
        local action13 = cc.MoveBy:create(0.1, cc.p(-20,-20))
        local action14 = cc.MoveBy:create(0.1, cc.p(10,10))

        local action5 = cc.ScaleTo:create(0.1,1)

        local function hurtBack( ... )
            self.shakeImage:setVisible(false)
        end

        local action6 = cc.Sequence:create(action1, action2, action3, action4, action12, action13, action14, action5, cc.CallFunc:create(hurtBack))
        t[i]:runAction(action6)
    end
    

    self.shakeImage:setVisible(true)
    
end

function MenuScene:addCastle()
    self.castleInitBlood = 100
    self.castleBlood = 100
    self.castle = display.newSprite("ui/dizuo/di_01.png")
    self.castle:setAnchorPoint(cc.p(0.5, 0))
    self.mapSprite:addChild(self.castle)
    self.castle:setPosition(self.treePos.x, self.treePos.y)
    self.castle:setCameraMask(cc.CameraFlag.USER7)

    self.flower = display.newSprite("ui/flower/F_01_01.png")
    self.flower:setAnchorPoint(cc.p(0.5, 0))
    self.castle:addChild(self.flower)
    self.flower:setPosition(self.castle:getContentSize().width * 0.5, self.castle:getContentSize().height )
    self.flower:setCameraMask(cc.CameraFlag.USER7)

    -- self.castle:setScale(0.3)

    self:createCastleProgress()

    local gq = display.newSprite("ui/bt_zhaozi.png")
    gq:setAnchorPoint(cc.p(0.5, 0))
    self.castle:addChild(gq)
    gq:setPosition(self.castle:getContentSize().width * 0.5, self.castle:getContentSize().height - 30)
    gq:setCameraMask(cc.CameraFlag.USER7)

end



function MenuScene:createCastleProgress()
    print("createCastleProgress    1 ")
    self.fill = {}
    local pos = {}
    local h = self.treePos.y + self.castle:getContentSize().height + self.flower:getContentSize().height
    pos[1] = {x = self.treePos.x - 50 , y = h - 25}
    pos[2] = {x = self.treePos.x, y = h}
    pos[3] = {x = self.treePos.x + 50, y = h - 25}
    for i=1,3 do
        print("createCastleProgress    1 " ..i)
        local blood = 100 -- 1
        local progressbg = display.newSprite("ui/xt_di.png") -- 2
        -- progressbg:setScale(scale)
        self.fill[i] = display.newProgressTimer("ui/xt_hong.png", display.PROGRESS_TIMER_BAR)  -- 3

        self.fill[i]:setMidpoint(cc.p(0, 0.5))   -- 4
        self.fill[i]:setBarChangeRate(cc.p(1.0, 0))   -- 5
        -- 6
        self.fill[i]:setPosition(progressbg:getContentSize().width/2, progressbg:getContentSize().height/2) 
        progressbg:addChild(self.fill[i])
        self.fill[i]:setPercentage(blood) -- 7

        -- 8
        progressbg:setAnchorPoint(cc.p(0.5, 0))
        self.mapSprite:addChild(progressbg)
        progressbg:setPosition(pos[i].x, pos[i].y )
        progressbg:setCameraMask(cc.CameraFlag.USER7)
    end

    
end



function MenuScene:setCastleProPercentage(Percentage)
      -- 9
    if Percentage >= 0 and Percentage <= 33 then
        self.fill[1]:setPercentage(Percentage / 33 * 100)
        self.fill[2]:setPercentage(0)
        self.fill[3]:setPercentage(0)
    elseif Percentage > 33 and Percentage <= 67 then
        self.fill[1]:setPercentage(100)
        self.fill[2]:setPercentage((Percentage - 33) / 33 * 100)
        self.fill[3]:setPercentage(0)
    elseif Percentage > 67 and Percentage <= 100 then
        self.fill[1]:setPercentage(100)
        self.fill[2]:setPercentage(100)
        self.fill[3]:setPercentage((Percentage - 67) / 33 * 100)
    end

end

function MenuScene:ackCastle(blood)
    self.castleBlood = self.castleBlood - blood
    if self.castleBlood > 0 then
        self:setCastleProPercentage(math.ceil(100 * (self.castleBlood / self.castleInitBlood)))
    else
        if not self.isOver then
            self:gameOver(false)
        end
    end


end

function MenuScene:gameOver(isSuccess)
    self:toJieSuan()
    local checkId = self.checkId
    local jieguo = isSuccess
    appInstance:enterjieSuanScene(jieguo,checkId)
end

function MenuScene:backMainBtnCbk()  
    print(" enterBtnCbk ")
    
end



function MenuScene:createCamera()
    self._layer = cc.Layer:create()
    self:addChild(self._layer)

    if self._camera01 == nil then
        print(" createCamera   +++++===============     ")
        self._camera01 = cc.Camera:createPerspective(60.0,display.width/display.height, 0, 500)
        self._camera01:setCameraFlag(cc.CameraFlag.USER6)
        self:addChild(self._camera01)
        self._camera01:setPosition3D(cc.vec3(display.width*0.5, display.height*0.5, 450))
        self._camera01:lookAt(cc.vec3(display.width*0.5, display.height*0.5,0), cc.vec3(0, 1, 0))
    end

    if self._camera02 == nil then
        print(" createCamera   +++++===============     ")
        self._camera02 = cc.Camera:createPerspective(60.0,display.width/display.height, 0, 500)
        self._camera02:setCameraFlag(cc.CameraFlag.USER4)
        self:addChild(self._camera02)
        self._camera02:setPosition3D(cc.vec3(display.width*0.5, display.height*0.5, 450))
        self._camera02:lookAt(cc.vec3(display.width*0.5, display.height*0.5,0), cc.vec3(0, 1, 0))
    end


    if self._camera == nil then
        print(" createCamera   +++++===============     ")
        self._camera = cc.Camera:createPerspective(60.0,display.width/display.height, 0, 1000)
        self._camera:setCameraFlag(cc.CameraFlag.USER7)
        self:addChild(self._camera)
        self._camera:setPosition3D(cc.vec3(display.width*0.5, display.height*0.5, 450))
        self._camera:lookAt(cc.vec3(display.width*0.5, display.height*0.5,0), cc.vec3(0, 1, 0))
    end

    

    -- self:setCameraMask(2)

end

function MenuScene:addEdgeSegment()
    local w = self.mapSprite:getContentSize().width
    local h1 = display.top * 8 / 10
    local h2 = self.ground


    -- local sky = display.newNode()
    -- local bodyTop = cc.PhysicsBody:createEdgeSegment(cc.p(0, h1-EDGESEGMENTNUMBER), cc.p(w, h1-EDGESEGMENTNUMBER), cc.PhysicsMaterial(0.0, 0.0, 0.0), EDGESEGMENTNUMBER)
    -- sky:setPhysicsBody(bodyTop)
    -- self:addChild(sky)
    -- bodyTop:setCategoryBitmask(0x1000)
    -- bodyTop:setContactTestBitmask(0x0000)
    -- bodyTop:setCollisionBitmask(0x0001)


    local ground = display.newNode()
    local bodyBottom = cc.PhysicsBody:createEdgeSegment(cc.p(-500, h2-EDGESEGMENTNUMBER), cc.p(w + 500, h2-EDGESEGMENTNUMBER), cc.PhysicsMaterial(0.0, 0.0, 0.0), EDGESEGMENTNUMBER)
    ground:setPhysicsBody(bodyBottom)
    self.mapSprite:addChild(ground)
    bodyBottom:setCategoryBitmask(0x1000)
    bodyBottom:setContactTestBitmask(0x0001)
    bodyBottom:setCollisionBitmask(0x0011)
    ground:setTag(GROUND_TAG)
    ground:setCameraMask(cc.CameraFlag.USER7)


end

function MenuScene:addUI( ... )

    self.shakeImage = ccui.ImageView:create()
    self.shakeImage:loadTexture("image/red.png")
    self.shakeImage:setTouchEnabled(false)
    self.shakeImage:setVisible(false)
    self:addChild(self.shakeImage)
    self.shakeImage:setPosition(display.cx,display.cy)
    self.shakeImage:setAnchorPoint(cc.p(0.5, 0.5))

    local leftBtn = ccui.ImageView:create()
    leftBtn:loadTexture("ui/left.png")
    leftBtn:setTouchEnabled(true)
    self:addChild(leftBtn)
    leftBtn:setPosition(display.left + 50,display.bottom)
    leftBtn:addTouchEventListener(handler(self, self.leftCbk))
    leftBtn:setAnchorPoint(cc.p(0, 0))

    local minBtn = ccui.ImageView:create()
    minBtn:loadTexture("ui/bt_fangxiang_normal.png")
    minBtn:setTouchEnabled(false)
    self:addChild(minBtn)
    minBtn:setPosition(display.left + 180,display.bottom + 35)
    minBtn:setAnchorPoint(cc.p(0.5, 0.5))

    local rightBtn = ccui.ImageView:create()
    rightBtn:loadTexture("ui/right.png")
    rightBtn:setTouchEnabled(true)
    self:addChild(rightBtn)
    rightBtn:setPosition(display.left + 200,display.bottom)
    rightBtn:addTouchEventListener(handler(self, self.rightCbk))
    rightBtn:setAnchorPoint(cc.p(0, 0))

    self.skill00Button = cc.ui.UIPushButton.new({normal = "ui/skill00.png"})
    :align(display.BOTTOM_RIGHT, display.right, display.bottom)
    :addTo(self)
    self.skill00Button:onButtonClicked(function(tag)
        self:skill00BtnCbk()
    end)

    self.skill01Button = cc.ui.UIPushButton.new({normal = "ui/skill01.png", pressed = "ui/skill02.png", disabled = "ui/skill02.png"})
    :align(display.BOTTOM_RIGHT, display.right - 135, display.bottom)
    :addTo(self)
    self.skill01Button:onButtonClicked(function(tag)
        self:skill01BtnCbk()
    end)
    

    self.skill02Button = cc.ui.UIPushButton.new({normal = "ui/skill01.png", pressed = "ui/skill02.png", disabled = "ui/skill02.png"})
    :align(display.BOTTOM_RIGHT, display.right - 105, display.bottom + 80 )
    :addTo(self)
    self.skill02Button:onButtonClicked(function(tag)
        self:skill02BtnCbk()
    end)

    self.skill03Button = cc.ui.UIPushButton.new({normal = "ui/skill01.png", pressed = "ui/skill02.png", disabled = "ui/skill02.png"})
    :align(display.BOTTOM_RIGHT, display.right - 30, display.bottom + 115 )
    :addTo(self)
    self.skill03Button:onButtonClicked(function(tag)
        -- self:jumpBtnCbk()
    end)

    -- self.skill00Button = BubbleButton.new({
    --     image = "ui/skill00.png",
    --     sound = GAME_SFX.tapButton,
    --     prepare = function()
    --         audio.playSound(GAME_SFX.tapButton)
    --         self.skill00Button:setButtonEnabled(false)
    --     end,
    --     listener = function()
    --         self:skill00BtnCbk()
    --     end,
    -- })
    -- :align(display.BOTTOM_RIGHT, display.right, display.bottom)
    -- :addTo(self)

    self.jumpButton = cc.ui.UIPushButton.new({normal = "ui/jump.png"})
    :align(display.BOTTOM_CENTER, display.left + 180 , display.bottom + 85)
    :addTo(self)
    self.jumpButton:onButtonClicked(function(tag)
        self:jumpBtnCbk()
    end)

    self.zt1Button = cc.ui.UIPushButton.new({normal = "ui/bt_zanting_normal.png"})
    :align(display.LEFT_TOP, display.left + 30 , display.top - 20)
    :addTo(self)
    self.zt1Button:onButtonClicked(function(tag)
        -- self:jumpBtnCbk()
    end)

    self.timeLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = tostring(self.ebdTime),
            font  = "font/huakang.TTF",
            size = 40,
        })
        :align(display.LEFT_TOP, display.left + 130 , display.top - 45)
        :addTo(self)


    self.zt2Button = cc.ui.UIPushButton.new({normal = "ui/bt_zanting_press.png"})
    :align(display.LEFT_TOP, display.left + 30 , display.top - 120)
    :addTo(self)
    self.zt2Button:onButtonClicked(function(tag)
        -- self:jumpBtnCbk()
    end)
    self.timeLabel:setVisible(false)


    self:createNuQiProgress()

    local nuQiBg = ccui.ImageView:create()
    nuQiBg:loadTexture("ui/bt_nuqi1_normal.png")
    nuQiBg:setTouchEnabled(false)
    self:addChild(nuQiBg)
    nuQiBg:setPosition(display.right , display.top)
    nuQiBg:setAnchorPoint(cc.p(1, 1))

    self:createMonsterProgress()
    


end

function MenuScene:createNuQiProgress()
    local blood = 100 -- 1
    local progressbg = display.newSprite("ui/bt_nuqi_normal.png") -- 2
    -- progressbg:setScale(scale)
    self.fillNuQi = display.newProgressTimer("ui/bt_nuqi_press.png", display.PROGRESS_TIMER_BAR)  -- 3

    self.fillNuQi:setMidpoint(cc.p(0, 0.5))   -- 4
    self.fillNuQi:setBarChangeRate(cc.p(1.0, 0))   -- 5
    -- 6
    self.fillNuQi:setPosition(progressbg:getContentSize().width/2, progressbg:getContentSize().height/2) 
    progressbg:addChild(self.fillNuQi)
    self.fillNuQi:setPercentage(blood) -- 7

    -- 8
    progressbg:setAnchorPoint(cc.p(1, 1))
    self:addChild(progressbg)
    progressbg:setPosition(display.right - 50 , display.top )
    -- progressbg:setCameraMask(cc.CameraFlag.USER7)

    self.nuQi = 100
end

function MenuScene:setNuQiProPercentage(Percentage)
    self.fillNuQi:setPercentage(Percentage)  -- 9
end

function MenuScene:addNuQi(num)
    -- print(" MenuScene:addNuQi(num)   "..num)
    self.nuQi = self.nuQi + num
    if self.nuQi > 100 then
        self.nuQi = 100
    elseif self.nuQi < 0 then
        self.nuQi = 0
    end

    -- print(" MenuScene:addNuQi(num)self.nuQi   "..self.nuQi)

    self:setNuQiProPercentage(self.nuQi)

    if self.nuQi < 50 then
        self.skill01Button:setButtonEnabled(false)
    else
        self.skill01Button:setButtonEnabled(true)
    end

    if self.nuQi < 100 then
        self.skill02Button:setButtonEnabled(false)
    else
        self.skill02Button:setButtonEnabled(true)
    end

    if self.nuQi < 100 then
        self.skill03Button:setButtonEnabled(false)
    else
        self.skill03Button:setButtonEnabled(true)
    end

end

function MenuScene:createMonsterProgress()
    self.monsterProgress = ccui.ImageView:create()
    self.monsterProgress:loadTexture("ui/bt_jindu.png")
    self.monsterProgress:setTouchEnabled(false)
    self:addChild(self.monsterProgress)
    self.monsterProgress:setPosition(display.right * 0.5,display.top - 50)
    self.monsterProgress:setAnchorPoint(cc.p(0.5, 0.5))

    self.monsterImg = ccui.ImageView:create()
    self.monsterImg:loadTexture("ui/bt_jindubiao.png")
    self.monsterImg:setTouchEnabled(false)
    self.monsterProgress:addChild(self.monsterImg)
    self.monsterImg:setPosition(30,40)
    self.monsterImg:setAnchorPoint(cc.p(0.5, 0.5))

    self.monsterImg:runAction(cc.MoveBy:create(60, cc.p(110,0)))
end


function MenuScene:leftCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.began then 
        self:start_scheduler()
        self.angle_ = 179
    elseif touchkey == ccui.TouchEventType.moved then 

    elseif touchkey == ccui.TouchEventType.ended or touchkey == ccui.TouchEventType.canceled then 
        self:endScheduler()
    end
end

function MenuScene:rightCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.began then 
        self:start_scheduler()
        self.angle_ = 1
    elseif touchkey == ccui.TouchEventType.moved then 

    elseif touchkey == ccui.TouchEventType.ended or touchkey == ccui.TouchEventType.canceled then 
        self:endScheduler()
    end
end

function MenuScene:endScheduler() 
    self:stop_scheduler()
    self.angle_ = 0
    self.spineboy:doEvent("idle")
end


function MenuScene:skill00BtnCbk()  
    print("   =============skill00BtnCbk================ ")
    local state = self.spineboy:getState()
    print("   =============skill00BtnCbk=======state========= "..state)


    local to = "idle"
    if state == "idle" or state == "run" then
        -- self:endScheduler()
        self.spineboy:doEvent("attack1")
    elseif state == "jump1" or state == "jump2"  then
        -- self:stop_scheduler()
        -- self.angle_ = 0
        self.spineboy:doEvent("attack4")
        to = "idle"
    elseif state == "attack1" then
        to = "attack2"
    elseif state == "attack2" then
        to = "attack3"
    elseif state == "attack3" then
        to = "attack1"
    elseif state == "attack4" then
        return
    end

    self.spineboy:setAckToState(to)
    

end

function MenuScene:skill01BtnCbk()  
    local state = self.spineboy:getState()

    local to = "idle"
    self.spineboy:doEvent("skill1")

    self.spineboy:setAckToState(to)
    

end

function MenuScene:skill02BtnCbk()
    local state = self.spineboy:getState()

    local to = "idle"
    self.spineboy:doEvent("skill2")

    self.spineboy:setAckToState(to)
end

function MenuScene:jumpBtnCbk()

    local h = self.ground
    local y = self.spineboy:getPositionY()
    print("   =============jumpBtnCbk==========h===== "..h)
    print("   =============jumpBtnCbk==========y===== "..y)
    if y > h then
        return 
    end

    -- local cp = self.spineboy:getPhysicsBody():getVelocity()
    -- print("   =============jumpBtnCbk==========cp.x===== "..cp.x)
    -- print("   =============jumpBtnCbk==========cp.y===== "..cp.y)

    local state = self.spineboy:getScaleX()
    print("   =============jumpBtnCbk================ "..state)

    -- self:endScheduler()
    self.spineboy:doEvent("idle")
    self.spineboy:doEvent("jump1")


    self.spineboy:getPhysicsBody():setVelocity(cc.p(0, 400))

    -- self:jumpScale()

end


-- function MenuScene:jumpScale( ... )
--     local action1 = cc.ScaleTo:create(0.2,0.95)
--     local action2 = cc.MoveBy:create(0.2, cc.p(0,-50))

--     local action3 = cc.ScaleTo:create(0.2,1)
--     local action4 = cc.MoveBy:create(0.2, cc.p(0,50))

--     local action5 = cc.Spawn:create(action1, action2)
--     local action6 = cc.Spawn:create(action3, action4)

--     local action7 = cc.Sequence:create(action5, action6)

--     self.mapSprite:runAction(action7)
-- end

function MenuScene:addSpineboy( ... )
    local spineboy = require("app/player/spineboy").new({parent = self})
    spineboy:setPosition(self.mapWidth * 0.5 , display.height - 120)
    self.mapSprite:addChild(spineboy)
    self.spineboy = spineboy
    spineboy:setCameraMask(cc.CameraFlag.USER7)

end



function MenuScene:addMonster( t )
    print(" ==============addOneMonster======================= "..self.gameMonSterNum)
    local num = math.random(self.chuMonsterNum,self.chuMonsterNum + 2)
    if t.isBoss then
        num = 1
    end
    for i=1, num do
        local dx = math.random(30,80)
        print(" ==============addOneMonster==========dx============= "..dx)
        local pos = {x = t.chuPos.x + dx, y = t.chuPos.y}
        self:addOneMonster(pos, t)
    end
end

function MenuScene:addOneMonster( pos, t )
    local t = t or {}
    t.parent = self
    local monster = require("app/player/monster").new(t)
    -- math.randomseed(os.time())
    
    monster:setPosition(pos.x ,pos.y )
    self.mapSprite:addChild(monster)
    monster:setTargetPos( self.treePos )
    -- monster:doEvent("run")
    table.insert(self.monster, monster)

    monster:setCameraMask(cc.CameraFlag.USER7)
end

function MenuScene:moveSpineboy( d_x, d_y )
    local cp = cc.p(self.spineboy:getPosition())
    local mapX = self.mapSprite:getPositionX()
    local mapWidth = self.mapSprite:getContentSize().width
    -- if d_x > 0 and cp.x >= display.cx and ( (mapX + mapWidth - d_x) >= display.width) then
    --     self.mapSprite:setPositionX(self.mapSprite:getPositionX() - d_x)

    --     self.mapYuanSprite:setPositionX(self.mapYuanSprite:getPositionX() - d_x*0.5)
    -- elseif d_x < 0 and cp.x <= display.cx and (mapX- d_x) < 0 then
    --     self.mapSprite:setPositionX(self.mapSprite:getPositionX() - d_x)

    --     self.mapYuanSprite:setPositionX(self.mapYuanSprite:getPositionX() - d_x*0.5)
    -- else
    --     if (cp.x + d_x) > 0 and (cp.x + d_x) < display.width then
    --         self.spineboy:setPositionX(cp.x + d_x) 
    --     end
    -- end

    if cp.x >= 150 and cp.x <= mapWidth - 150 then

        local isHasMonster = false

        if cp.y > self.ground + 30 then

        else
            for k,v in pairs(self.monster) do
                if v and  not v:IsDie() then
                   local vx = v:getPositionX()
                   if d_x > 0 and vx > cp.x and vx < cp.x + d_x  then
                        isHasMonster = true
                    elseif d_x < 0 and  vx < cp.x and vx > cp.x + d_x then
                        isHasMonster = true
                   end
                end
                
            end
        end



        if not isHasMonster then
            self.spineboy:setPositionX(cp.x + d_x) 
        end
    elseif cp.x <= 150 then
        self.spineboy:setPositionX(150) 
    elseif cp.x >= mapWidth - 150 then
        self.spineboy:setPositionX(mapWidth - 150) 
    end

    

    -- print("  ==========moveSpineboy========= ")
    -- if (cp.y + d_y) > 0 and (cp.y + d_y + 200) < display.height then
    --     self.spineboy:setPositionY(cp.y + d_y) 
    -- end
    

    if d_x < 0 then
        self.spineboy:setScaleX(-1)  
    else
        self.spineboy:setScaleX(1)  
    end

    if cp.y > self.ground then
        -- if  self.spineboy:getState() ~= "attack4" then
        --     self.spineboy:doEvent("jump2")
        -- end
    else
        if  self.spineboy:getState() == "idle" then
            print("    hahahahahah  ============   hahahaahh ")
            self.spineboy:doEvent("run")
        end
    end


end

function MenuScene:addMap( ... )
    local mapNode = cc.Node:create()
    mapNode:setAnchorPoint(cc.p(0, 0))
    self:addChild(mapNode)


    -- audio.playMusic("sound/background.mp3", true)


    self.mapBgSprite = display.newSprite("image/beijing/BJ_01.png")
    -- self.mapBgSprite:setContentSize(cc.size(1920,1280))
    self.mapBgSprite:setAnchorPoint(cc.p(0, 0))
    mapNode:addChild(self.mapBgSprite)
    self.mapBgSprite:setPosition3D(cc.vec3(0, 0, -300))
    self.mapBgSprite:setScaleX(50)
    self.mapBgSprite:setScaleY(2)
    self.mapBgSprite:setAnchorPoint(cc.p(0.5,0.5))
    self.mapBgSprite:setPosition(1100, display.height*0.5)

    self.mapBgSprite:setCameraMask(cc.CameraFlag.USER6)

    self.mapYuanSprite = display.newSprite("image/b2.png")
    self.mapYuanSprite:setAnchorPoint(cc.p(0, 0))
    mapNode:addChild(self.mapYuanSprite)
    self.mapYuanSprite:setCameraMask(cc.CameraFlag.USER4)
    self.mapYuanSprite:setPosition3D(cc.vec3(0, 0, -100))
    self.mapYuanSprite:setScale(1)
    self.mapYuanSprite:setAnchorPoint(cc.p(0.5,0.5))
    self.mapYuanSprite:setPosition(1100, display.height*0.45)


    self.mapSprite = display.newSprite("image/b1.png")
    self.mapSprite:setAnchorPoint(cc.p(0.5, 0.5))
    mapNode:addChild(self.mapSprite)
    self.mapSprite:setPosition(1100, display.height*0.5)
    self.mapSprite:setCameraMask(cc.CameraFlag.USER7)
    self.mapWidth = self.mapSprite:getContentSize().width


    local emitter = cc.ParticleSystemQuad:create("particles/dirt.plist")
    -- emitter:setBlendAdditive(false) 
    emitter:setPosition(display.cx, display.top)
    self:addChild(emitter, -3)


end

function MenuScene:stickEvent( angle )
    local speed = self.speed
    local d_posx = 0
    local d_posy = 0
    angle = math.floor(angle)
    if angle >= 0 and angle <= 90 then
        d_posx = speed * math.cos(math.rad(angle))
        d_posy = speed * math.sin(math.rad(angle))
    elseif  angle > 90 and angle <= 180 then
        d_posx = -speed * math.cos(math.rad(180 - angle))
        d_posy = speed * math.sin(math.rad(180 - angle))
    elseif  angle >= -90 and angle <= 0 then
        d_posx = speed * math.cos(math.rad(-angle))
        d_posy = -speed * math.sin(math.rad(-angle))
    elseif  angle > -180 and angle < -90 then
        d_posx = -speed * math.cos(math.rad(180 + angle))
        d_posy = -speed * math.sin(math.rad(180 + angle))
    end
    print(" d_posx "..d_posx)
    self:moveSpineboy(d_posx, d_posy)



    
end

-- function MenuScene:setCamera()
--     local cp = cc.p(self.spineboy:getPosition())
--     if cp.y > self.ground then
--         self._camera:setPosition3D(cc.vec3(display.width*0.5, display.height*0.5 + (cp.y - self.ground), 450 + (cp.y - self.ground)))
--     end
-- end

function MenuScene:start_monster_scheduler()
    self:stop_monster_scheduler()

    local update_func = function(dt)

        --
            -- self:setCamera()
        --

        self:onEndTimer(dt)


        self.gameTime = self.gameTime + dt
        if self.gameTime > self.chuMonsterTimes and self.ebdTime > 0 then
            self.gameTime = 0

            if self.gameTime < 15 then
                self.chuMonsterTimes = self.initChuMonsterTimes + math.random(4,5) * 0.1
            elseif self.gameTime > 15 and self.gameTime < 35 then
                self.chuMonsterTimes = self.initChuMonsterTimes + math.random(2,3) * 0.1
            else
                self.chuMonsterTimes = self.initChuMonsterTimes + math.random(1,2) * 0.1
            end

            self.gameMonSterNum = self.gameMonSterNum + 1

            local r = math.random(1,9)
            if r > 5 then
                self:chuMonster({weizi = 1})
            else
                self:chuMonster({weizi = -1})
            end

        end

        for k,v in pairs(self.monster) do
            if v and  not v:IsDie() then
               v:update()
            end
            
        end
    end

    self.monster_scheduler_id_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_func, self.rate_, false)
end

function MenuScene:stop_monster_scheduler()
    if self.monster_scheduler_id_ ~= nil then
        scheduler:unscheduleScriptEntry(self.monster_scheduler_id_)
        self.monster_scheduler_id_ = nil
    end
end

function MenuScene:chuMonster( table )
    local t = {}
    if table.isBoss then
        local monsterId =  self.checkTab["B01_ID"]
        
        t.isBoss = table.isBoss
        t.monsterId = monsterId
        t.blood = math.floor(BossTable[monsterId].b_blood * (1 + self.checkTab["B01_b_add"]))
        t.speed = math.floor(BossTable[monsterId].b_speed * (1 + self.checkTab["B01_s_add"]))
        t.path = BossTable[monsterId].b_res
    else
        local index = math.random(1,2)
        local monsterId =  self.checkTab["M0"..index.."_ID"]
        print("monsterId " ..monsterId)
      
        t.monsterId = monsterId
        t.blood = math.floor(BeastTable[monsterId].b_blood * (1 + self.checkTab["M0"..index.."_b_add"]))
        t.speed = math.floor(BeastTable[monsterId].b_speed * (1 + self.checkTab["M0"..index.."_s_add"]))
        t.path = BeastTable[monsterId].m_res
    end
    
    if table.weizi > 0 then
        t.chuPos = {x = 2300 ,y = self.ground}
    else
        t.chuPos = {x = -200 ,y = self.ground}
    end

    
    self:addMonster(t)

    for k,v in pairs(self.monster) do
        if v:IsDie() then
            print("chuMonster ------  removeFromParent  ")
           v:removeFromParent()
           self.monster[k] = nil
        end
    end
end

function MenuScene:start_scheduler()
    self:stop_scheduler()

    local update_func = function(dt)
        if self.angle_ then
            print("angle_ : "..self.angle_)
            self:dispatchEvent({name = stick_event.notify_to_stick_event_moved, angle = self.angle_})

            

            self:stickEvent(self.angle_)
        end
    end

    self.scheduler_id_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_func, self.rate_, false)
end

function MenuScene:stop_scheduler()
    if self.scheduler_id_ ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduler_id_)
        self.scheduler_id_ = nil
    end
end

function MenuScene:init_data(bg, center, rate)
    self.rate_ = rate

    self.bg_ = display.newSprite(bg)
    assert(self.bg_)
    self.bg_size_ = self.bg_:getContentSize()
    self.bg_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
    self:addChild(self.bg_)

    self.center_ = display.newSprite(center)
    assert(self.center_)
    self.center_size_ = self.center_:getContentSize()
    self.center_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
    self:addChild(self.center_)

    if not STICK_POS_FIXED then
        self:switch_stick_status(false)
    end
end

function MenuScene:switch_stick_status(is_show)
    self.bg_:setVisible(is_show)
    self.center_:setVisible(is_show)
end



function MenuScene:on_touch(event, x, y)
    if not self.touch_enable_ then
        print("not self.touch_enable_ ....")
        return true
    end

    if event == 'began' then
        self.touch_start_ = { x = x, y = y }
        if STICK_POS_FIXED then
            local box = self.center_:getBoundingBox()
            if cc.rectContainsPoint(box, cc.p(x, y)) then
                self:start_scheduler()
                self:dispatchEvent({name = stick_event.notify_to_stick_event_began})
                self.is_touch_begin = true
                return true
            end
            self.is_touch_begin = false
            return false
        else
            self.stick_pos_.x = x
            self.stick_pos_.y = y
            self.bg_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
            self.center_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
            self:switch_stick_status(true)
            self:start_scheduler()
            self:dispatchEvent({name = stick_event.notify_to_stick_event_began})
        end
    elseif event == 'moved' then
        self.angle_ = math.atan2(y - self.stick_pos_.y, x - self.stick_pos_.x) * 180 / math.pi

        local bg_radis = self.bg_size_.width / 2;
        local distance_of_touchpoint_to_center = math.sqrt(
                (self.stick_pos_.x - x)*(self.stick_pos_.x - x) + (self.stick_pos_.y - y)*(self.stick_pos_.y - y))
        
        --print("bg_radis = %f\ndistance_of_touchpoint_to_center=%f\n", bg_radis, distance_of_touchpoint_to_center)

        if distance_of_touchpoint_to_center >= bg_radis then
            local dx = (x - self.stick_pos_.x) * (bg_radis / distance_of_touchpoint_to_center)
            local dy = (y - self.stick_pos_.y) * (bg_radis / distance_of_touchpoint_to_center)
            self.center_:setPosition(self.stick_pos_.x + dx, self.stick_pos_.y + dy)
        else
            self.center_:setPosition(x, y)
        end
    elseif event == 'ended' then
        self.center_:setPosition(self.stick_pos_.x, self.stick_pos_.y)

        if not STICK_POS_FIXED then
            self:switch_stick_status(false)
        end

        self.angle_ = nil
        self:stop_scheduler()
        self:dispatchEvent({name = stick_event.notify_to_stick_event_ended})

        if self.is_touch_begin then
            print("33 333is_touch_begin 3333333333333333333")
            self.spineboy:doEvent("idle")
        end

    end

    return true
end

return MenuScene
