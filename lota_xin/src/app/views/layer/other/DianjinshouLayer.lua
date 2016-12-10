local DianjinshouLayer = class("DianjinshouLayer", require("app.views.mmExtend.LayerBase"))
DianjinshouLayer.RESOURCE_FILENAME = "Dianjinshou.csb"

function DianjinshouLayer:onCreate(param)
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

    if param.bTishi ~= nil then
        gameUtil:addTishi({p = self, s = MoGameRet[990002]})
    end
end

function DianjinshouLayer:onEnter()
    
end

function DianjinshouLayer:onExit()
    game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshTaskInfo"})
end

function DianjinshouLayer:refresh( )
    -- local png = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Panel_1"):getChildByName("Image_1")
    -- local x , y = png:getPosition()
    -- png:setPosition(x,y+100)

    local goldLevel = mm.data.playerExtra.exchangeGoldLevel
    local goldDayTimes = mm.data.playerExtra.exchangeGoldDayTimes
    if goldLevel == nil then
        goldLevel = 0
    end
    if goldDayTimes == nil then
        goldDayTimes = 0
    end
    
    
    local tenNeedDiamond = 0
    for i=1,10 do
        local exchangeInfo = INITLUA:getExchangeByLevel(goldLevel + i, 0)
        tenNeedDiamond = tenNeedDiamond + exchangeInfo.ConsumeDiamond
    end

    local exchangeInfo = INITLUA:getExchangeByLevel(goldLevel + 1, 0)
    local oneNeedDiamond = exchangeInfo.ConsumeDiamond

    self.buyOneBtn:getChildByName("Text_3"):setString(oneNeedDiamond)
    self.buyTenBtn:getChildByName("Text_3"):setString(tenNeedDiamond)

    local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    local vipInfo = INITLUA:getVIPTabById(vipLv)
    local maxTimes = vipInfo.BuyGoldTimes
    --local currentTimes = maxTimes - 
    local timesText = self.Node:getChildByName("Image_bg"):getChildByName("Text_Num")
    --timesText:setString("今日剩余次数 "..goldDayTimes.."/"..maxTimes)
    timesText:setString("今日剩余次数 "..(maxTimes-goldDayTimes))
end

function DianjinshouLayer:initItems(num)
    local diamond = 0
    local crit = 0
    local gold = 0

    self.panel = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Panel_1")

    for i=1,num do
        local item = cc.CSLoader:createNode("DianjinshouLayer.csb")
        item:setContentSize(item:getContentSize().width,item:getContentSize().height)
        --item:setTag(tag)
        item:setAnchorPoint(cc.p(0,0.5))
        self.panel:addChild(item,99999)

        local offsetX = (self.panel:getContentSize().width - item:getContentSize().width) / 2
        item:setPosition(offsetX, -item:getContentSize().height*0.3)
        self.moveY = item:getContentSize().height*0.6

        item:getChildByName("Text_2"):setString(diamond)
        item:getChildByName("Text_3"):setString("暴击X"..crit)
        item:getChildByName("Text_2_0"):setString(gold)

        item:setVisible(false)
        item.isVisible = false
        item.notItem = false

        table.insert(self.moveNode, item)
    end
end

function DianjinshouLayer:addItem(goldInfo)
    local diamond = goldInfo.diamond
    local crit = goldInfo.crit
    local gold = goldInfo.gold

    for k,v in pairs(self.moveNode) do
        if v.isVisible == false and v.notItem == false then
            v:getChildByName("Text_2"):setString(diamond)
            v:getChildByName("Text_3"):setString("暴击X"..crit)
            v:getChildByName("Text_2_0"):setString(gold)

            v:setPositionY(-v:getContentSize().height*0.3)
            v:setVisible(true)
            v.isVisible = true
            break
        end
    end
    self:moveItem()
end

function DianjinshouLayer:moveItem()
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

function DianjinshouLayer:buyGoldBack( event )
    if event.t.type == 0 then
        if event.t.buyGoldInfo ~= nil then
            for k,v in pairs(event.t.buyGoldInfo) do
                self:addItem(v)
            end
            --self:moveItem()
        end
        if event.t.playerExtra ~= nil then
            mm.data.playerExtra = event.t.playerExtra
        end
        if event.t.playerinfo ~= nil then
            mm.data.playerinfo = event.t.playerinfo
        end
        game:dispatchEvent({name = EventDef.UI_MSG, code = "BuyGoldBack"})
        self:refresh()
    end
    local text = gameUtil.GetMoGameRetStr( event.t.code )
    if event.t.code == 990001 then
        gameUtil.showChongZhi( self, 1 )
    elseif event.t.code == 990013 then
        gameUtil:addTishi({p = mm.scene(), s = text, z = 1000000})
    end
end

function DianjinshouLayer:byOneBtnCbk( widget, touchkey)
    for k,v in pairs(self.moveNode) do
        if v.moving == true then
            return
        end
    end
    if touchkey == ccui.TouchEventType.ended then
        local buyItemInfo = {}
        buyItemInfo.itemNum = 1  -----只买一个

        mm.req("buySomeThing",{getType = 1, buyType = 4, buyItemInfo = buyItemInfo})
    end
end

function DianjinshouLayer:buyTenBtnCbk( widget, touchkey)
    for k,v in pairs(self.moveNode) do
        if v.moving == true then
            return
        end
    end
    if touchkey == ccui.TouchEventType.ended then
        local buyItemInfo = {}
        buyItemInfo.itemNum = 10  -----只买一个

        mm.req("buySomeThing",{getType = 1, buyType = 4, buyItemInfo = buyItemInfo})
    end
end

function DianjinshouLayer:backCbk( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function DianjinshouLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function DianjinshouLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "buySomeThing" then
            self:buyGoldBack(event)
        end
    end
end

return DianjinshouLayer