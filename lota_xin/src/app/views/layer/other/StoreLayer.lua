local StoreLayer = class("StoreLayer", require("app.views.mmExtend.LayerBase"))
StoreLayer.RESOURCE_FILENAME = "SCchoujiangLayer.csb"

function StoreLayer:onEnter()

end

function StoreLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function StoreLayer:onExit()
    
end

function StoreLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function StoreLayer:randomItem( totalPercent )
    local randomValue = math.random(1, totalPercent)
    for k,v in pairs(self.readyItemList) do
        if v and randomValue >= v.randomRange[1] and randomValue <= v.randomRange[2] then
            table.insert(self.showItem, v)
            self.readyItemList[k] = nil
            return
        end
    end
    self:randomItem(totalPercent)
end

function StoreLayer:init(param)
    mm.app.clientTCP:addEventListener("autoRefreshStoreInfo",mm.autoRefreshStoreInfo)
    mm.app.clientTCP:addEventListener("recharge",mm.recharge)
    --添加node事件
    self.scene = param.scene
    self.storeInfo = param.param
    self.Node = self:getResourceNode()
    self.needRecordTime = param.needRecordTime
    
    -- 刷新按钮
    self.resetBtn = self.Node:getChildByName("Button_chushou")
    gameUtil.setBtnEffect(self.resetBtn)
    self.resetBtn:addTouchEventListener(handler(self, self.resetBtnCbk))

    local refreshNode = self.Node:getChildByName("Image_miaoshukuang")
    local decNode = refreshNode:getChildByName("Text_src")

    local text = gameUtil.GetMoGameRetStr( 990004 )
    decNode:setString(text)

    self.moreCoinsBtn = self.Node:getChildByName("Image_3")
    self.moreCoinsBtn:setTouchEnabled(true)
    self.moreCoinsBtn:addTouchEventListener(handler(self, self.moreCoinsBtnCbk))
    self.moreDiamondBtn = self.Node:getChildByName("Image_a")
    self.moreDiamondBtn:setTouchEnabled(true)
    self.moreDiamondBtn:addTouchEventListener(handler(self, self.moreDiamondBtnCbk))


    game.storeXinYunBtn = self.Node:getChildByName("Panel_xinyun")
    game.storeshuaxinBtn = self.Node:getChildByName("Image_miaoshukuang")

    self:refreshUI()
    self:refreshStore()
end

function StoreLayer:refreshUI( )
    self:refreshMoney()
    self:refreshItem()
end

function StoreLayer:refreshMoney( )
    -- 资产信息
    local playerInfo = mm.data.playerinfo
    local Money1Num = self.Node:getChildByName("Text_2")
    
    local ID = self.storeInfo.storeID
    local shopRes = INITLUA:getShopListRes()
    ID = util.getNumFormChar(ID, 4)
    
    local shop = shopRes[ID]

    if shop.Money1 == 1 then
        self.Node:getChildByName("Image_4"):loadTexture("res/UI/pc_jinbi.png")
        Money1Num:setString(playerInfo.gold)
    elseif shop.Money1 == 2 then
        self.Node:getChildByName("Image_4"):loadTexture("res/UI/pc_zuanshi.png")
        Money1Num:setString(playerInfo.diamond)
    elseif shop.Money1 == 3 then
        self.Node:getChildByName("Image_4"):loadTexture("res/UI/pc_rongyu.png")
        Money1Num:setString(playerInfo.honor)
    elseif shop.Money1 == 4 then
        self.Node:getChildByName("Image_4"):loadTexture("res/UI/pc_PKbi.png")
        Money1Num:setString(playerInfo.pkCoin)
    end
    
    local Money2Num = self.Node:getChildByName("Text_3")
    if shop.Money2 == 1 then
        self.Node:getChildByName("Image_b"):loadTexture("res/UI/pc_jinbi.png")
        Money2Num:setString(playerInfo.gold)
    elseif shop.Money2 == 2 then
        self.Node:getChildByName("Image_b"):loadTexture("res/UI/pc_zuanshi.png")
        Money2Num:setString(playerInfo.diamond)
    elseif shop.Money2 == 3 then
        self.Node:getChildByName("Image_b"):loadTexture("res/UI/pc_rongyu.png")
        Money2Num:setString(playerInfo.honor)
    elseif shop.Money2 == 4 then
        self.Node:getChildByName("Image_b"):loadTexture("res/UI/pc_PKbi.png")
        Money2Num:setString(playerInfo.pkCoin)
    end

    -- 幸运值
    local luckyValue = playerInfo.luckyValue
    if luckyValue == nil then
        luckyValue = 0
    end
    local luckyNum = self.Node:getChildByName("Text_3_0")
    luckyNum:setString(luckyValue)
    -- 幸运值进度
    local luckyBar = self.Node:getChildByName("LoadingBar_1")
    local percent = math.ceil(luckyValue / 1000)
    luckyBar:setPercent(percent)
end

function StoreLayer:refreshItem()
    local items = mm.data.playerItem
    local refreshItemNum = 0
    local refreshItemID = util.getNumFormChar("I007", 4)
    
    if items then
        for k,v in pairs(items) do
            if v.id == refreshItemID then
                refreshItemNum = v.num
                break
            end
        end
    end
    local refreshNum = self.Node:getChildByName("Text_shuaxin")
    -- refreshItemNum = 0
    if refreshItemNum <= 0 then
        local refreshTimes = mm.data.playerExtra.refreshStoreTimes
        if refreshTimes == nil then
            self.Node:getChildByName("Image_2"):loadTexture("res/UI/icon_shuanxin.png")
            refreshNum:setString("剩余: "..refreshItemNum)
        else
            self.Node:getChildByName("Image_2"):loadTexture("res/UI/pc_zuanshi.png")
            local diamondList = INITLUA:getExchangeByType(MM.EChangeToType.CHANGERTO_shuaxinshangcheng)
            --排序
            function sortRules( a, b )
                return a.Times > b.Times
            end
            table.sort(diamondList, sortRules)
            local maxTimes = diamondList[1].Times
            local needDiamond = diamondList[1].ConsumeDiamond
            
            if refreshTimes < maxTimes then
                for k,v in pairs(diamondList) do
                    if refreshTimes == v.Times then
                        needDiamond = v.ConsumeDiamond
                        break
                    end
                end
            end 
            refreshNum:setString(needDiamond)
        end

        

    else
        self.Node:getChildByName("Image_2"):loadTexture("res/UI/icon_shuanxin.png")
        refreshNum:setString("剩余: "..refreshItemNum)
    end

    local viplevel = gameUtil.getPlayerVipLv( mm.data.playerinfo.vipexp )
    local vipInfo = gameUtil.getVipInfoByLevel( viplevel )
    local refreshTimes = mm.data.playerExtra.refreshStoreTimes
    local Text_shuaxin_shangxian = self.Node:getChildByName("Text_shuaxin_shangxian")
    cclog("viplevel   "..viplevel)
    if Text_shuaxin_shangxian then
        Text_shuaxin_shangxian:setString("钻石刷新上限："..vipInfo.shangchengshuaxin - refreshTimes + 1 )
    end
end

function StoreLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getStoreInfo" then

        elseif event.code == "buySomeThing" then
            self:dealRefreshMessage( event )
        elseif event.code == "refreshStoreInfo" then
            self:dealRefreshMessage( event )
            if event.t.type ~= 0 then
                local text = gameUtil.GetMoGameRetStr( event.t.code )
                gameUtil:addTishi({p = self.scene, s = text, z = 1000000})
            else
                if event.t.code == 990060 then
                    gameUtil.showChongZhi( self, event.t.code )
                end
            end
        elseif event.code == "autoRefreshStoreInfo" then
            self:dealRefreshMessage( event )
        elseif event.code == "recharge" then
            self:refreshMoney()
        end
    end
end

function StoreLayer:dealRefreshMessage( event )
    self.needRecordTime = true
    local info = event.t.storeInfo
    local playerInfo = event.t.playerinfo
    if playerInfo ~= nil then
        mm.data.playerinfo = playerInfo 
    end

    local playerExtra = event.t.playerExtra
    if playerExtra ~= nil then
        mm.data.playerExtra = playerExtra
    end

    local playerItem = event.t.playerItem
    if playerItem ~= nil then
        mm.data.playerItem = playerItem 
        self:refreshItem()
    end

    if info ~= nil then
        for i,v in ipairs(info) do
            if self.storeInfo.storeID == v.storeID then
                self.storeInfo = v
                self:refreshStore()
                break
            end
        end
    end
end

function StoreLayer:refreshStore( )
    if self.storeInfo == nil then
        return
    end
    if self.storeInfo.storeItems == nil then
        return
    end
    
    local playerInfo = mm.data.playerinfo


    local totalNum = #self.storeInfo.storeItems
    
    local ListView = self.Node:getChildByName("ListView")
    ListView:removeAllItems()
    ListView:setScrollBarEnabled(false)
    local size = ListView:getContentSize()

    --创建商品ItemView
    local row = math.ceil(totalNum/3)
    local index = 0
    for i=1,row do
        local custom_item = ccui.Layout:create()
        if i == row then
            num = (totalNum - (i-1)*3)
        else
            num = 3
        end
        for j=1,num do
             index = index + 1
             local itemInfo = {}
             for k,v in pairs(self.storeInfo.storeItems) do
                if index == v.showIndex then
                    itemInfo = v
                    break
                end
             end
             local item = require("src.app.views.layer.StoreItemLayer").new({scene = self.scene, info = itemInfo})
             local itemHeight = item:getContentSize().height
             local itemWidth = item:getContentSize().width
             local offsetX = (size.width-itemWidth*3)/4
             item:setPosition((size.width/3)*(j-1) + offsetX * (j-1),0)

             custom_item:setContentSize(cc.size(size.width, itemHeight))
             custom_item:addChild(item)

            if i == 2 and j == 1 then
                game.storeItemBtn = item:getResourceNode():getChildByName("Image_1")
            end
        end
        ListView:pushBackCustomItem(custom_item)
    end

    local ID = self.storeInfo.storeID
    local shopRes = INITLUA:getShopListRes()
    ID = util.getNumFormChar(ID, 4)
    --local shopItem = shopRes[ID]
    ---[[
    local timeTable = self.storeInfo.refreshTime

    table.sort(timeTable)
    local time = timeTable[1]
    if time < 0 then
        time = timeTable[2]
    end
    if self.needRecordTime == false then
        local recordTime = gameUtil.getStoreRecordTime(self.storeInfo.storeID)
        local currentTime = os.time()
        local disTime = currentTime - recordTime
        time = time - disTime
    end


    -- 刷新时间
    local refreshNode = self.Node:getChildByName("Image_miaoshukuang")
    local refreshTime = refreshNode:getChildByName("Text_name")
    local timeStr = self:getTime(time)
    refreshTime:setString("刷新时间: "..timeStr)

    local function countTime( ... )
        time = time - 1
        timeStr = self:getTime(time)
        refreshTime:setString("刷新时间: "..timeStr)
    end
    refreshTime:stopActionByTag(9999)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(countTime),cc.DelayTime:create(1)))
    action:setTag(9999)
    refreshTime:runAction(action)

    self:refreshItem()

    self:refreshUI()
    --]]
end

function StoreLayer:getTime( time )
    if time <= 0 then
        return "00:00:00"
    end
    local hour = math.floor(time / 3600)
    local min = math.floor((time - (3600 * hour)) / 60)
    local sec = time - (3600 * hour) - (min * 60)
    local timeStr = "00:00:00"
    if hour < 10 then
        hour = "0"..hour
    end
    if min < 10 then
        min = "0"..min
    end
    if sec < 10 then
        sec = "0"..sec
    end
    return hour..":"..min..":"..sec
end

function StoreLayer:resetBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.storeInfo == nil then
            return
        end

        local items = mm.data.playerItem
        local refreshItemNum = 0
        local refreshItemID = util.getNumFormChar("I007", 4)
        
        if items then
            for k,v in pairs(items) do
                if v.id == refreshItemID then
                    refreshItemNum = v.num
                    break
                end
            end
        end
        
        if refreshItemNum > 0 then
            mm.req("refreshStoreInfo",{type = 0, storeID = self.storeInfo.storeID})
        else
            local refreshTimes = mm.data.playerExtra.refreshStoreTimes
            if refreshTimes == nil then
                gameUtil:addTishi({p = self.scene, s = gameUtil.GetMoGameRetStr( 990006 ), z = 1000000})
            else
                local diamondList = INITLUA:getExchangeByType(MM.EChangeToType.CHANGERTO_shuaxinshangcheng)
                --排序
                function sortRules( a, b )
                    return a.Times > b.Times
                end
                table.sort(diamondList, sortRules)
                local maxTimes = diamondList[1].Times
                local needDiamond = diamondList[1].ConsumeDiamond
                
                if refreshTimes < maxTimes then
                    for k,v in pairs(diamondList) do
                        if refreshTimes == v.Times then
                            needDiamond = v.ConsumeDiamond
                            break
                        end
                    end
                end
                
                if mm.data.playerinfo.diamond >= needDiamond then
                    mm.req("refreshStoreInfo",{type = 0, storeID = self.storeInfo.storeID})
                else
                    local text = gameUtil.GetMoGameRetStr( 990001 )
                    gameUtil:addTishi({p = self.scene, s = text, z = 1000000})

                    local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})
                    local size  = cc.Director:getInstance():getWinSize()
                    self:addChild(PurchaseLayer, MoGlobalZorder[2999999])
                    PurchaseLayer:setContentSize(cc.size(size.width, size.height))
                    ccui.Helper:doLayout(PurchaseLayer)
                end
            end
        end
    end
end

function StoreLayer:moreCoinsBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then  
        local ID = self.storeInfo.storeID
        local shopRes = INITLUA:getShopListRes()
        ID = util.getNumFormChar(ID, 4)
        local shop = shopRes[ID]

        if shop.Money1 == 1 then
            local DianjinshouLayer = require("src.app.views.layer.DianjinshouLayer").new({})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(DianjinshouLayer, MoGlobalZorder[2999999])
            DianjinshouLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(DianjinshouLayer)
        elseif shop.Money1 == 2 then
            local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(PurchaseLayer, MoGlobalZorder[2999999])
            PurchaseLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(PurchaseLayer)
        elseif shop.Money1 == 3 then
            
        elseif shop.Money1 == 4 then
            local param = {}
            param.hintText = "消耗1PK点获得100PK币"
            game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = "PKLayer", param = param})
        end
    end
end

function StoreLayer:moreDiamondBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local ID = self.storeInfo.storeID
        local shopRes = INITLUA:getShopListRes()
        ID = util.getNumFormChar(ID, 4)

        local shop = shopRes[ID]
        if shop.Money2 == 1 then
            local DianjinshouLayer = require("src.app.views.layer.DianjinshouLayer").new({})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(DianjinshouLayer, MoGlobalZorder[2999999])
            DianjinshouLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(DianjinshouLayer)
        elseif shop.Money2 == 2 then
            local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(PurchaseLayer, MoGlobalZorder[2999999])
            PurchaseLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(PurchaseLayer)
        elseif shop.Money2 == 3 then
            
        elseif shop.Money2 == 4 then
            local param = {}
            param.hintText = "消耗1PK点获得100PK币"
            game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = "PKLayer", param = param})
        end
    end
end

function StoreLayer:updateLayer( ... )

end

return StoreLayer