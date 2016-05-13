
local AdBar = import("..views.AdBar")
local BubbleButton = import("..views.BubbleButton")

local MenuScene = class("MenuScene", function()
    return display.newPhysicsScene("MenuScene")
end)


local STICK_POS_FIXED = true

local EDGESEGMENTNUMBER = 10


local scheduler = cc.Director:getInstance():getScheduler()

local stick_event = {
    notify_to_stick_event_began = "stick.event_began",
    notify_to_stick_event_moved = "stick.event_moved",
    notify_to_stick_event_ended = "stick.event_ended"
}

function MenuScene:ctor()
    
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()


    self.world = self:getPhysicsWorld()

    self.world:setGravity(cc.p(0, -200.0))

    self.world:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)


    self.ground = display.top * 4 / 10

    self.layerColor = cc.LayerColor:create(cc.c4b(0,0,0,120))
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

    self.touch_enable_ = true
    self.stick_pos_ = { x=100, y=100 }

    
    -- self:init_data("ui/yaogan01.png", "ui/yaogan02.png", 0.016)
    self.rate_ = 0.016


    self:addSpineboy()

    self:addUI()

    self:addEdgeSegment()

end

function MenuScene:onEnter()
end

function MenuScene:addEdgeSegment()
    local w = self.mapSprite:getContentSize().width
    local h1 = display.top * 8 / 10
    local h2 = self.ground


    local sky = display.newNode()
    local bodyTop = cc.PhysicsBody:createEdgeSegment(cc.p(0, h1-EDGESEGMENTNUMBER), cc.p(w, h1-EDGESEGMENTNUMBER), cc.PhysicsMaterial(0.0, 0.0, 0.0), EDGESEGMENTNUMBER)
    sky:setPhysicsBody(bodyTop)
    self:addChild(sky)
    bodyTop:setCategoryBitmask(0x1000)
    bodyTop:setContactTestBitmask(0x0000)
    bodyTop:setCollisionBitmask(0x0001)


    local ground = display.newNode()
    local bodyBottom = cc.PhysicsBody:createEdgeSegment(cc.p(0, h2-EDGESEGMENTNUMBER), cc.p(w, h2-EDGESEGMENTNUMBER), cc.PhysicsMaterial(0.0, 0.0, 0.0), EDGESEGMENTNUMBER)
    ground:setPhysicsBody(bodyBottom)
    self:addChild(ground)
    bodyBottom:setCategoryBitmask(0x1000)
    bodyBottom:setContactTestBitmask(0x0001)
    bodyBottom:setCollisionBitmask(0x0011)

end

function MenuScene:addUI( ... )



    local leftBtn = ccui.ImageView:create()
    leftBtn:loadTexture("ui/left.png")
    leftBtn:setTouchEnabled(true)
    self:addChild(leftBtn)
    leftBtn:setPosition(display.left + 50,display.bottom)
    leftBtn:addTouchEventListener(handler(self, self.leftCbk))
    leftBtn:setAnchorPoint(cc.p(0, 0))

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
    :align(display.BOTTOM_RIGHT, display.right , display.bottom + 120)
    :addTo(self)
    self.jumpButton:onButtonClicked(function(tag)
        self:jumpBtnCbk()
    end)




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
    if state == "idle" or state == "run" or state == "jump1" or state == "jump2"  then
        self:endScheduler()
        self.spineboy:doEvent("attack1")
    elseif state == "attack1" then
        to = "attack2"
    elseif state == "attack2" then
        to = "attack3"
    elseif state == "attack3" then
        to = "attack1"
    end

    self.spineboy:setAckToState(to)
    

end

function MenuScene:skill01BtnCbk()
    self.spineboy:doEvent("run")
end

function MenuScene:skill02BtnCbk()
    self.spineboy:doEvent("run")
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

    self:endScheduler()
    self.spineboy:doEvent("jump1")


    self.spineboy:getPhysicsBody():setVelocity(cc.p(0, 200))

end


function MenuScene:addSpineboy( ... )
    local spineboy = require("app/player/spineboy").new()
    spineboy:setPosition(display.cx , display.cy)
    self:addChild(spineboy)
    self.spineboy = spineboy
end

function MenuScene:moveSpineboy( d_x, d_y )
    local cp = cc.p(self.spineboy:getPosition())
    local mapX = self.mapSprite:getPositionX()
    local mapWidth = self.mapSprite:getContentSize().width
    if d_x > 0 and cp.x >= display.cx and ( (mapX + mapWidth - d_x) >= display.width) then
        self.mapSprite:setPositionX(self.mapSprite:getPositionX() - d_x)
    elseif d_x < 0 and cp.x <= display.cx and (mapX- d_x) < 0 then
        self.mapSprite:setPositionX(self.mapSprite:getPositionX() - d_x)
    else
        if (cp.x + d_x) > 0 and (cp.x + d_x) < display.width then
            self.spineboy:setPositionX(cp.x + d_x) 
        end
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

        self.spineboy:doEvent("jump2")
    else
        self.spineboy:doEvent("run")

    end


end

function MenuScene:addMap( ... )
    local mapNode = cc.Node:create()
    mapNode:setAnchorPoint(cc.p(0, 0))
    self:addChild(mapNode)

    self.mapSprite = display.newSprite("ui/bg_01.png")
    self.mapSprite:setAnchorPoint(cc.p(0, 0))
    mapNode:addChild(self.mapSprite)


end

function MenuScene:stickEvent( angle )
    local speed = 3
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
