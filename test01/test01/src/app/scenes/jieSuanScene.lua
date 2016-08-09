

local jieSuanScene = class("jieSuanScene", function()
    return display.newScene("jieSuanScene")
end)

function jieSuanScene:ctor(jieguo, checkId)
    self.Bg = display.newSprite("res/loginUI/bm_beijing1.jpg")
    self.Bg:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.Bg)
    self.Bg:setPosition(display.cx, display.cy)

    self.win = jieguo
    self.checkId = checkId

    local nextId = CheckpointTable[self.checkId].NextID

    local curCheckPoint = cc.UserDefault:getInstance():getIntegerForKey("checkId", 1093677105)

    if nextId > curCheckPoint then
        cc.UserDefault:getInstance():setIntegerForKey("checkId", nextId)
    end

    -- self:toServer()
    
    print("jieSuanScene:ctor   "..self.checkId)
    self:addUI()
end



function jieSuanScene:toServer( ... )
    local req = {}
    req.uid = game.uid
    req.stageId = self.checkId

    if self.win then
        req.result = 0
    else
        req.result = 1
    end

    local function back( t )
        dump(t)
        
    end
    game.clientTCP:send("stageAccount",{did = req}, back)

end

function jieSuanScene:addUI( ... )
    
    self.huaImg = {}
    local img = ccui.ImageView:create()
    img:loadTexture("res/jieSuanUI/bt_hua_normal.png")
    img:setPosition(display.cx, display.cy + 200)
    img:setAnchorPoint(cc.p(0.5, 0.5))
    img:setTouchEnabled(false)
    self:addChild(img)
    self.huaImg[1] = img

    local imgBg = ccui.ImageView:create()
    imgBg:loadTexture("res/jieSuanUI/bt_hua_press.png")
    imgBg:setPosition(img:getContentSize().width * 0.5, img:getContentSize().height * 0.5)
    imgBg:setAnchorPoint(cc.p(0.5, 0.5))
    imgBg:setTouchEnabled(false)
    img:addChild(imgBg)

    local img = ccui.ImageView:create()
    img:loadTexture("res/jieSuanUI/bt_hua1_normal.png")
    img:setPosition(display.cx - 150, display.cy + 150)
    img:setAnchorPoint(cc.p(0.5, 0.5))
    img:setTouchEnabled(false)
    self:addChild(img)
    self.huaImg[2] = img

    local imgBg = ccui.ImageView:create()
    imgBg:loadTexture("res/jieSuanUI/bt_hua1_press.png")
    imgBg:setPosition(img:getContentSize().width * 0.5, img:getContentSize().height * 0.5)
    imgBg:setAnchorPoint(cc.p(0.5, 0.5))
    imgBg:setTouchEnabled(false)
    img:addChild(imgBg)

    local img = ccui.ImageView:create()
    img:loadTexture("res/jieSuanUI/bt_hua1_normal.png")
    img:setPosition(display.cx + 150, display.cy + 150)
    img:setAnchorPoint(cc.p(0.5, 0.5))
    img:setTouchEnabled(false)
    self:addChild(img)
    self.huaImg[3] = img
    img:setScaleX(-1)

    local imgBg = ccui.ImageView:create()
    imgBg:loadTexture("res/jieSuanUI/bt_hua1_press.png")
    imgBg:setPosition(img:getContentSize().width * 0.5, img:getContentSize().height * 0.5)
    imgBg:setAnchorPoint(cc.p(0.5, 0.5))
    imgBg:setTouchEnabled(false)
    img:addChild(imgBg)
  
    local textImg = ccui.ImageView:create()
    textImg:loadTexture("res/checkpointUI/bm_biaoti.png")
    self:addChild(textImg)
    textImg:setPosition(display.cx,display.cy + 50)
    textImg:setAnchorPoint(cc.p(0.5, 0.5))

    local textImg = ccui.ImageView:create()
    self:addChild(textImg)
    textImg:setPosition(display.cx,display.cy + 60)
    textImg:setAnchorPoint(cc.p(0.5, 0.5))
    if self.win then
        textImg:loadTexture("res/jieSuanUI/bt_win.png")
    else
        textImg:loadTexture("res/jieSuanUI/bt_lose.png")
    end


    for i=1,4 do
        local qipaoImg = ccui.ImageView:create()
        qipaoImg:loadTexture("res/mainUI/bm_qipao.png")
        self:addChild(qipaoImg)
        qipaoImg:setPosition(display.cx - 350 + 140 * i,display.cy - 50)
        qipaoImg:setAnchorPoint(cc.p(0.5, 0.5))

        local jinbiImg = ccui.ImageView:create()
        jinbiImg:loadTexture("res/mainUI/bt_jinbi.png")
        self:addChild(jinbiImg)
        jinbiImg:setPosition(display.cx - 350 + 140 * i,display.cy - 50)
        jinbiImg:setAnchorPoint(cc.p(0.5, 0.5))

        local label = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = "1234",
            font  = "font/huakang.TTF",
            size = 22,
        })
        :align(display.CENTER, display.cx - 350 + 140 * i,display.cy - 100)
        :addTo(self)
    end

    self.btn01Button = cc.ui.UIPushButton.new({normal = "res/jieSuanUI/bt_liebiao.png", 
                                                pressed = "res/jieSuanUI/bt_liebiao.png", 
                                                disabled = "res/jieSuanUI/bt_liebiao.png"})
    :align(display.CENTER, display.cx - 150, 100)
    :addTo(self)
    self.btn01Button:onButtonClicked(function(tag)
        self:btn01BtnCbk()
    end)
    
    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "List",
        font  = "font/huakang.TTF",
        size = 22,
    })
    :align(display.CENTER, display.cx - 150, 50)
    :addTo(self)

    self.btn02Button = cc.ui.UIPushButton.new({normal = "res/jieSuanUI/bt_next.png", 
                                                pressed = "res/jieSuanUI/bt_next.png", 
                                                disabled = "res/jieSuanUI/bt_next.png"})
    :align(display.CENTER, display.cx , 100)
    :addTo(self)
    self.btn02Button:onButtonClicked(function(tag)
        self:btn02BtnCbk()
    end)
    
    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "Next",
        font  = "font/huakang.TTF",
        size = 22,
    })
    :align(display.CENTER, display.cx , 50)
    :addTo(self)

    self.btn03Button = cc.ui.UIPushButton.new({normal = "res/jieSuanUI/bt_home.png", 
                                                pressed = "res/jieSuanUI/bt_home.png", 
                                                disabled = "res/jieSuanUI/bt_home.png"})
    :align(display.CENTER, display.cx + 150, 100)
    :addTo(self)
    self.btn03Button:onButtonClicked(function(tag)
        self:btn03BtnCbk()
    end)
    
    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "Home",
        font  = "font/huakang.TTF",
        size = 22,
    })
    :align(display.CENTER, display.cx + 150, 50)
    :addTo(self)

end



function jieSuanScene:backBtnCbk()  
    appInstance:enterMainScene()
end

function jieSuanScene:leftBtnCbk()  

end

function jieSuanScene:rightBtnCbk()  

end

function jieSuanScene:btn01BtnCbk()  
    appInstance:enterCheckpointScene()
end

function jieSuanScene:btn02BtnCbk()  
    if self.win then
        local id = CheckpointTable[self.checkId].NextID
        appInstance:enterMenuScene({id})
    else
        local id = self.checkId
        appInstance:enterMenuScene({id})
    end
end

function jieSuanScene:btn03BtnCbk()  
    appInstance:enterMainScene()
end

return jieSuanScene
