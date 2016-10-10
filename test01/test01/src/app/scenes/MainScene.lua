

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self:initUI()
    self:addCard()

    self:schedule(handler(self, self.onDrawUpgradeTimer),0.016)
end



function MainScene:initUI()  
    self.Bg = display.newSprite("res/mainUI/mainBg.jpg")
    self.Bg:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.Bg)
    self.Bg:setPosition(display.cx, display.cy)



    -- self.enterButton = cc.ui.UIPushButton.new({normal = "res/loginUI/bm_kaishi.png", 
    --                                                 pressed = "res/loginUI/bm_kaishi.png", 
    --                                                 disabled = "res/loginUI/bm_kaishi.png"})
    -- :align(display.CENTER, display.cx, display.height * 0.25)
    -- :addTo(self)
    -- self.enterButton:onButtonClicked(function(tag)
    --     self:enterBtnCbk()
    -- end)

    self.shopButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bt_shop.png", 
                                                    pressed = "res/mainUI/bt_shop.png", 
                                                    disabled = "res/mainUI/bt_shop.png"})
    :align(display.BOTTOM_LEFT, display.left + 10, display.bottom + 10)
    :addTo(self)
    self.shopButton:onButtonClicked(function(tag)
        self:shopBtnCbk()
    end)

    self.shopButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bt_shop.png", 
                                                    pressed = "res/mainUI/bt_shop.png", 
                                                    disabled = "res/mainUI/bt_shop.png"})
    :align(display.BOTTOM_LEFT, display.left + 200, display.bottom + 10)
    :addTo(self)
    self.shopButton:onButtonClicked(function(tag)
        self:shopBtnCbk()
    end)

    self.warriorButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bt_warrior.png", 
                                                    pressed = "res/mainUI/bt_warrior.png", 
                                                    disabled = "res/mainUI/bt_warrior.png"})
    :align(display.BOTTOM_LEFT, display.left + 390, display.bottom + 10)
    :addTo(self)
    self.warriorButton:onButtonClicked(function(tag)
        self:warriorBtnCbk()
    end)

    self.taskButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bt_task.png", 
                                                    pressed = "res/mainUI/bt_task.png", 
                                                    disabled = "res/mainUI/bt_task.png"})
    :align(display.BOTTOM_LEFT, display.left + 580, display.bottom + 10)
    :addTo(self)
    self.taskButton:onButtonClicked(function(tag)
        self:taskBtnCbk()
    end)

    self.rankButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bt_ranked.png", 
                                                    pressed = "res/mainUI/bt_ranked.png", 
                                                    disabled = "res/mainUI/bt_ranked.png"})
    :align(display.BOTTOM_LEFT, display.left + 200, display.bottom + 10)
    :addTo(self)
    self.rankButton:onButtonClicked(function(tag)
        self:rankBtnCbk()
    end)

    --------------
        local editBox2 = cc.ui.UIInput.new({
            image = "res/mainUI/bm_xinxi2.png",
            size = cc.size(219, 38),
            x = display.cx,
            y = display.cy,
            listener = function(event, editbox)
                if event == "began" then
                    -- self:onEditBoxBegan(editbox)
                elseif event == "ended" then
                    -- self:onEditBoxEnded(editbox)
                elseif event == "return" then
                    -- self:onEditBoxReturn(editbox)
                    local name = editbox:getText()

                    local reqTab = {uid = game.uid, name = name}
                    game.clientTCP:send("rename", reqTab, handler(self, self.renameBack))


                elseif event == "changed" then
                    -- self:onEditBoxChanged(editbox)
                else
                    printf("EditBox event %s", tostring(event))
                end
            end
        })
        editBox2:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
        editBox2:setPosition(800,30)
        self:addChild(editBox2)
    ------------

    self.setButton = cc.ui.UIPushButton.new({normal = "res/loginUI/bt_shezhi.png", 
                                            pressed = "res/loginUI/bt_shezhi.png", 
                                            disabled = "res/loginUI/bt_shezhi.png"})
    :align(display.TOP_RIGHT, display.right - 10, display.top - 10)
    :addTo(self)
    self.setButton:onButtonClicked(function(tag)
        self:setBtnCbk()
    end)

    --money
        self.moneyButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bm_xinxi2.png", 
                                                pressed = "res/mainUI/bm_xinxi2.png", 
                                                disabled = "res/mainUI/bm_xinxi2.png"})
        :align(display.TOP_RIGHT, display.right - 90, display.top - 30)
        :addTo(self)
        self.moneyButton:onButtonClicked(function(tag)
            self:moneyBtnCbk()
        end)

        local addImg = ccui.ImageView:create()
        addImg:loadTexture("res/mainUI/bt_zengjia.png")
        self:addChild(addImg)
        addImg:setPosition(display.right - 280,display.top - 45)
        addImg:setAnchorPoint(cc.p(0.5, 0.5))

        local label = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = "220000",
            font  = "font/huakang.TTF",
            size = 24,
        })
        :align(display.CENTER_LEFT, display.right - 250, display.top - 45)
        :addTo(self)

        local moneyImg = ccui.ImageView:create()
        moneyImg:loadTexture("res/mainUI/bt_zuanshi.png")
        self:addChild(moneyImg)
        moneyImg:setPosition(display.right - 110,display.top - 45)
        moneyImg:setAnchorPoint(cc.p(0.5, 0.5))
    --

    --gold
        self.goldButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bm_xinxi2.png", 
                                                pressed = "res/mainUI/bm_xinxi2.png", 
                                                disabled = "res/mainUI/bm_xinxi2.png"})
        :align(display.TOP_RIGHT, display.right - 320, display.top - 30)
        :addTo(self)
        self.goldButton:onButtonClicked(function(tag)
            self:goldBtnCbk()
        end)

        local addImg = ccui.ImageView:create()
        addImg:loadTexture("res/mainUI/bt_zengjia.png")
        self:addChild(addImg)
        addImg:setPosition(display.right - 510,display.top - 45)
        addImg:setAnchorPoint(cc.p(0.5, 0.5))

        local label = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = "220000",
            font  = "font/huakang.TTF",
            size = 24,
        })
        :align(display.CENTER_LEFT, display.right - 480, display.top - 45)
        :addTo(self)

        local goldImg = ccui.ImageView:create()
        goldImg:loadTexture("res/mainUI/bt_jinbi.png")
        self:addChild(goldImg)
        goldImg:setPosition(display.right - 340,display.top - 45)
        goldImg:setAnchorPoint(cc.p(0.5, 0.5))
    --

    --tili
        self.tiliButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bm_xinxi2.png", 
                                                pressed = "res/mainUI/bm_xinxi2.png", 
                                                disabled = "res/mainUI/bm_xinxi2.png"})
        :align(display.TOP_RIGHT, display.right - 540, display.top - 30)
        :addTo(self)
        self.tiliButton:onButtonClicked(function(tag)
            self:tiliBtnCbk()
        end)

        local addImg = ccui.ImageView:create()
        addImg:loadTexture("res/mainUI/bt_zengjia.png")
        self:addChild(addImg)
        addImg:setPosition(display.right - 730,display.top - 45)
        addImg:setAnchorPoint(cc.p(0.5, 0.5))

        local label = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = "220000",
            font  = "font/huakang.TTF",
            size = 24,
        })
        :align(display.CENTER_LEFT, display.right - 700, display.top - 45)
        :addTo(self)

        local tiliImg = ccui.ImageView:create()
        tiliImg:loadTexture("res/mainUI/bt_tili.png")
        self:addChild(tiliImg)
        tiliImg:setPosition(display.right - 560,display.top - 45)
        tiliImg:setAnchorPoint(cc.p(0.5, 0.5))
    --

    --左上角等级
    self.headButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bm_xinxi1.png", 
                                                    pressed = "res/mainUI/bm_xinxi1.png", 
                                                    disabled = "res/mainUI/bm_xinxi1.png"})
    :align(display.LEFT_TOP, - 30, display.top + 10)
    :addTo(self)
    self.headButton:onButtonClicked(function(tag)
        self:headBtnCbk()
    end)

    self:createProgress()

    local lvlabel = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "22",
        font  = "font/huakang.TTF",
        size = 22,
    })
    :align(display.LEFT_TOP, 32, display.top - 25)
    :addTo(self)

    local namelabel = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "zuofei",
        font  = "font/huakang.TTF",
        size = 30,
    })
    :align(display.BOTTOM_LEFT, 110, display.top - 35)
    :addTo(self)
    self.namelabel = namelabel
    self.namelabel:setString(game.playerInfo.base.name)

    local explabel = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "22/100",
        font  = "font/huakang.TTF",
        size = 18,
    })
    :align(display.LEFT_TOP, 110, display.top - 40)
    :addTo(self)

    self.huayuanButton = cc.ui.UIPushButton.new({normal = "res/mainUI/bt_huayuan.png", 
                                                pressed = "res/mainUI/bt_huayuan.png", 
                                                disabled = "res/mainUI/bt_huayuan.png"})
    :align(display.CENTER, display.right - 250, display.top * 0.45)
    :addTo(self)
    self.huayuanButton:onButtonClicked(function(tag)
        self:huayuanBtnCbk()
    end)

    local huabgImg = ccui.ImageView:create()
    huabgImg:loadTexture("res/mainUI/bm_hua1.png")
    self:addChild(huabgImg)
    huabgImg:setPosition(display.right - 230,display.top * 0.45 + 30)
    huabgImg:setAnchorPoint(cc.p(0.5, 0.5))

    local huaImg = ccui.ImageView:create()
    huaImg:loadTexture("res/mainUI/bm_hua.png")
    self:addChild(huaImg)
    huaImg:setPosition(display.right - 240,display.top * 0.45 - 50)
    huaImg:setAnchorPoint(cc.p(0.5, 0.5))

    local qipaoImg = ccui.ImageView:create()
    qipaoImg:loadTexture("res/mainUI/bm_qipao.png")
    self:addChild(qipaoImg)
    qipaoImg:setPosition(display.right - 240,display.top * 0.45 + 160)
    qipaoImg:setAnchorPoint(cc.p(0.5, 0.5))

    local jinbiImg = ccui.ImageView:create()
    jinbiImg:loadTexture("res/mainUI/bt_jinbi.png")
    self:addChild(jinbiImg)
    jinbiImg:setPosition(display.right - 240,display.top * 0.45 + 160)
    jinbiImg:setAnchorPoint(cc.p(0.5, 0.5))

end

function MainScene:renameBack(t)
    print(" GardenScene:renameBack()  ================1 ")
    dump(t)
    print(" GardenScene:renameBack()  ================2 ")

    self.namelabel:setString(t.name)
    game.playerInfo.base.name = t.name

end

function MainScene:createProgress()
    local blood = 100 -- 1
    local progressbg = display.newSprite("res/mainUI/bm_jingyantiao1.png") -- 2
    -- progressbg:setScale(scale)
    self.fill = display.newProgressTimer("res/mainUI/bm_jingyantiao.png", display.PROGRESS_TIMER_BAR)  -- 3

    self.fill:setMidpoint(cc.p(0, 0.5))   -- 4
    self.fill:setBarChangeRate(cc.p(1.0, 0))   -- 5
    -- 6
    self.fill:setPosition(progressbg:getContentSize().width/2, progressbg:getContentSize().height/2) 
    progressbg:addChild(self.fill)
    self.fill:setPercentage(blood) -- 7

    -- 8
    progressbg:setAnchorPoint(cc.p(0, 1))
    self:addChild(progressbg)
    progressbg:setPosition(78 , display.top - 40)
    -- progressbg:setCameraMask(cc.CameraFlag.USER7)

    self.nuQi = 100
end

function MainScene:setProPercentage(Percentage)
    self.fill:setPercentage(Percentage)  -- 9
end

function MainScene:enterBtnCbk()  
	print(" enterBtnCbk ")
    
end

function MainScene:addCard()

    self.centerPos = {x = 300, y = 280}
    self.r = 180

    local cardImg = {"res/mainUI/bt_jingji.png", "res/mainUI/bt_shejiao.png", "res/mainUI/bt_tanxian.png"}

    local layer = display.newNode()
    layer:setContentSize(300, 300)

    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    layer:setTouchEnabled(true)
    layer:setTouchSwallowEnabled(false)
    self:addChild(layer)
    self.cardLayout = layer
    layer:setPosition(self.centerPos.x - 150, self.centerPos.y - 150)



    self.cards = {}
    
    self.angle = -90
    self.radius = 150
    self.radiusY = 150

    self.heightRatio = 120
    self.heightD = 0
    self.scaleRatio = 1


    --
    for index = 1,3 do

        local card = display.newSprite(cardImg[index])
        card:setAnchorPoint(cc.p(0.5, 0.5))

        local posX = self.centerPos.x + self.r * math.cos((index * 120 + self.angle) * math.pi /180)

        local posY = self.centerPos.y + self.r * math.sin((index * 120 + self.angle) * math.pi /180)*0.2

        local dy = math.sin((index * 120 + self.angle) * math.pi /180)
        local zorder = dy * 100 
        card:setLocalZOrder(100 - zorder)
        card:setOpacity(155 - zorder)
        card:setPosition(posX,posY)
        self:addChild(card)

        self.cards[index] = card

    end

    self.targetAngleTab = {}
    for i=-200,200 do
        table.insert(self.targetAngleTab, -90 + 120 * i)
    end


end


function MainScene:onTouch(event, x, y)
    print("event            "..event)
    if event=='began' then

        print("onTouchBegan: %0.2f, %0.2f", x, y)

        touchBeginPoint = {x = x, y = y}
        touchBegin = {x = x, y = y}

        self.isMove = true

        return true
    elseif event=='moved' then

        -- print("onTouchMoved: %0.2f, %0.2f", x, y)

        if touchBeginPoint then
            -- print(" angle ======== ".. ((x - touchBeginPoint.x) / (2 * math.pi * 150)) * 360)
            self.angle = self.angle + ((x - touchBeginPoint.x) / (2 * math.pi * 150)) * 360
            for index=1,3 do
                local card = self.cards[index]
           
                local posX = self.centerPos.x + self.r * math.cos((index * 120 + self.angle) * math.pi /180)
                local posY = self.centerPos.y + self.r * math.sin((index * 120 + self.angle) * math.pi /180) * 0.2

                local dy = math.sin((index * 120 + self.angle) * math.pi /180)
                local zorder = dy * 100 
                -- if index == 1 then 
                --     print("dy ==== "..dy)
                --     print("zorder ==== "..zorder)
                --     print("100 - zorder ==== "..(100 - zorder))
                -- end
                card:setLocalZOrder(100 - zorder)
                card:setOpacity(155 - zorder)
                card:setPosition(posX,posY)
            end
            
            touchBeginPoint = {x = x, y = y}
        end
    elseif event=='ended' then
        local d = math.abs(touchBeginPoint.x - touchBegin.x) + math.abs(touchBeginPoint.y - touchBegin.y)
        print("d ==== "..d)
        if d < 5 then
            --点击事件？
            local upZ = self.cards[1]:getLocalZOrder()
            local upI = 1
            for index=1,3 do
                local card = self.cards[index]
                local zorder = card:getLocalZOrder()
                if zorder > upZ then
                    upZ = zorder
                    upI = index
                end
            end
            self:cardBack(upI)
            print("upI ==== "..upI)
        end
        self.isMove = false

        
        self.targetAngle = self.targetAngleTab[1]
        local dd = math.abs(self.targetAngleTab[1] - self.angle)
        for i=1,#self.targetAngleTab do
            if math.abs(self.targetAngleTab[i] - self.angle) <= dd then
                self.targetAngle = self.targetAngleTab[i]
                dd = math.abs(self.targetAngleTab[i] - self.angle)
            end
        end
        
        self.speed = 10
        -- self.speed = (self.targetAngle - self.angle) * 0.5


    end
    -- return true
end

--[[
    local cardImg = {"res/mainUI/bt_tanxian.png", "res/mainUI/bt_shejiao.png", "res/mainUI/bt_jingji.png"}
]]
function MainScene:cardBack( index )
    if index == 1 then --
        
    elseif index == 2 then

    elseif index == 3 then
        appInstance:enterCheckpointScene()
    end
end

function MainScene:onDrawUpgradeTimer( ... )

    if self.angle ~= self.targetAngle and self.isMove == false then
        self.angle = self.angle + self.speed * 0.016 * 15
        local isOver = false
        if self.speed > 0 and self.angle > self.targetAngle then
            isOver = true
        end

        if self.speed < 0 and self.angle < self.targetAngle then
            isOver = true
        end
        
        if isOver then
            self.angle = self.targetAngle
        end


        for index=1,3 do
            local card = self.cards[index]
            local posX = self.centerPos.x + self.r * math.cos((index * 120 + self.angle) * math.pi /180)
            local posY = self.centerPos.y + self.r * math.sin((index * 120 + self.angle) * math.pi /180) * 0.2

            local dy = math.sin((index * 120 + self.angle) * math.pi /180)
            local zorder = dy * 100 
            if index == 1 then 
                print("dy ==== "..dy)
                print("zorder ==== "..zorder)
                print("100 - zorder ==== "..(100 - zorder))
            end
            card:setLocalZOrder(100 - zorder)
            card:setOpacity(155 - zorder)
            card:setPosition(posX,posY)
        end


    end

end

function MainScene:headBtnCbk()  

end

function MainScene:huayuanBtnCbk()  
    appInstance:enterGardenScene()
end

function MainScene:setBtnCbk()  

end

function MainScene:moneyBtnCbk()  

end

function MainScene:goldBtnCbk()  

end

function MainScene:tiliBtnCbk()  

end

function MainScene:shopBtnCbk()  

end

function MainScene:warriorBtnCbk()  

end

function MainScene:taskBtnCbk()  

end

function MainScene:rankBtnCbk()  
    appInstance:enterPaiHangScene()
end

return MainScene
