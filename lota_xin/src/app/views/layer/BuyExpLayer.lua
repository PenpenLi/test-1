local BuyExpLayer = class("BuyExpLayer", require("app.views.mmExtend.LayerBase"))
BuyExpLayer.RESOURCE_FILENAME = "Jingyan.csb"

function BuyExpLayer:onCreate()
    self.Node = self:getResourceNode()

    
    self.buyOneBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    gameUtil.setBtnEffect(self.buyOneBtn)
    self.buyOneBtn:addTouchEventListener(handler(self, self.byOneBtnCbk))


    self.buyTenBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_NO")
    gameUtil.setBtnEffect(self.buyTenBtn)
    self.buyTenBtn:addTouchEventListener(handler(self, self.buyTenBtnCbk))


    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_2")
    self.backBtn:addTouchEventListener(handler(self, self.backCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

    local centerImage = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Panel_1"):getChildByName("Image_1")
    centerImage.notItem = true
    centerImage.isVisible = true

    self.moveNode = {}
    
    table.insert(self.moveNode, centerImage)

    self:initItems(20)

    self:refresh()
end

function BuyExpLayer:onEnter()
    
end

function BuyExpLayer:onExit()
    game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshTaskInfo"})
end

function BuyExpLayer:refresh( )
    -- local png = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Panel_1"):getChildByName("Image_1")
    -- local x , y = png:getPosition()
    -- png:setPosition(x,y+100)

    local expLevel = mm.data.playerExtra.exchangeExpPoolLevel
    local expDayTimes = mm.data.playerExtra.exchangeExpDayTimes
    if expLevel == nil then
        expLevel = 0
    end
    if expDayTimes == nil then
        expDayTimes = 0
    end
    
    local tenNeedDiamond = 0
    for i=1,10 do
        local exchangeInfo = INITLUA:getExchangeByLevel(expLevel + i, 1)
        tenNeedDiamond = tenNeedDiamond + exchangeInfo.ConsumeDiamond
    end

    local exchangeInfo = INITLUA:getExchangeByLevel(expLevel + 1, 1)
    local oneNeedDiamond = exchangeInfo.ConsumeDiamond

    self.buyOneBtn:getChildByName("Text_3"):setString(oneNeedDiamond)
    self.buyTenBtn:getChildByName("Text_3"):setString(tenNeedDiamond)

    local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    local vipInfo = INITLUA:getVIPTabById(vipLv)
    local maxTimes = vipInfo.ExpPoorTimes
    --local currentTimes = maxTimes - 
    local timesText = self.Node:getChildByName("Image_bg"):getChildByName("Text_Num")
    --timesText:setString("今日剩余次数 "..expDayTimes.."/"..maxTimes)
    timesText:setString("今日剩余次数 "..(maxTimes-expDayTimes))
end

function BuyExpLayer:initItems(num)
    local diamond = 0
    local crit = 0
    local exp = 0

    self.panel = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Panel_1")

    for i=1,num do
        local item = cc.CSLoader:createNode("JingyanLayer.csb")
        item:setContentSize(item:getContentSize().width,item:getContentSize().height)
        --item:setTag(tag)
        item:setAnchorPoint(cc.p(0,0.5))
        self.panel:addChild(item,99999)

        local offsetX = (self.panel:getContentSize().width - item:getContentSize().width) / 2
        item:setPosition(offsetX, -item:getContentSize().height*0.3)
        self.moveY = item:getContentSize().height*0.6

        item:getChildByName("Text_2"):setString(diamond)
        item:getChildByName("Text_3"):setString("暴击X"..crit)
        item:getChildByName("Text_2_0"):setString(exp)

        item:setVisible(false)
        item.isVisible = false
        item.notItem = false

        table.insert(self.moveNode, item)
    end
end

function BuyExpLayer:addItem(expInfo)
    local diamond = expInfo.diamond
    local crit = expInfo.crit
    local exp = expInfo.exp

    for k,v in pairs(self.moveNode) do
        if v.isVisible == false and v.notItem == false then
            v:getChildByName("Text_2"):setString(diamond)
            v:getChildByName("Text_3"):setString("暴击X"..crit)
            v:getChildByName("Text_2_0"):setString(exp)

            v:setPositionY(-v:getContentSize().height*0.3)
            v:setVisible(true)
            v.isVisible = true
            break
        end
    end
    self:moveItem()
end

function BuyExpLayer:moveItem()
    for k,v in pairs(self.moveNode) do
        local x , y = v:getPosition()
        if y > self.panel:getContentSize().height * 1.3 then
            v:setVisible(false)
            v.isVisible = false
        elseif v.isVisible == true then
            local scaleAction = cc.ScaleTo:create(0.1,1.0)
            v:runAction(scaleAction)

            local function flyBack( ... )
                v.moving = false
            end
            local move = cc.MoveBy:create(0.3, cc.p(0, self.moveY))
            local action = cc.Sequence:create(move, cc.CallFunc:create(flyBack))
            cc.Director:getInstance():getActionManager():addAction(action, v, true)
            v.moving = true
        end
    end
end

function BuyExpLayer:buyExpBack( event )
    if event.t.type == 0 then
        if event.t.buyExpInfo ~= nil then
            local index = 0
            for k,v in pairs(event.t.buyExpInfo) do
                self:addItem(v)
            end
        end
        if event.t.playerExtra ~= nil then
            mm.data.playerExtra = event.t.playerExtra
        end
        if event.t.playerinfo ~= nil then
            mm.data.playerinfo = event.t.playerinfo
        end
        game:dispatchEvent({name = EventDef.UI_MSG, code = "ExpGouMai"})
        self:refresh()
    end
    local text = gameUtil.GetMoGameRetStr( event.t.code )
    if event.t.code == 990001 then
        gameUtil.showChongZhi( self, 1 )
    elseif event.t.code == 990013 then
        gameUtil:addTishi({p = mm.scene(), s = text, z = 1000000})
    end
end

function BuyExpLayer:byOneBtnCbk( widget, touchkey)
    for k,v in pairs(self.moveNode) do
        if v.moving == true then
            return
        end
    end
    if touchkey == ccui.TouchEventType.ended then
        local buyItemInfo = {}
        buyItemInfo.itemNum = 1  -----只买一个

        mm.req("buySomeThing",{getType = 1, buyType = 1, buyItemInfo = buyItemInfo})
    end
end

function BuyExpLayer:buyTenBtnCbk( widget, touchkey)
    for k,v in pairs(self.moveNode) do
        if v.moving == true then
            return
        end
    end
    if touchkey == ccui.TouchEventType.ended then
        local buyItemInfo = {}
        buyItemInfo.itemNum = 10  -----只买一个

        mm.req("buySomeThing",{getType = 1, buyType = 1, buyItemInfo = buyItemInfo})
    end
end

function BuyExpLayer:backCbk( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function BuyExpLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function BuyExpLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "buySomeThing" then
            self:buyExpBack(event)
        end
    end
end

return BuyExpLayer