local MeleeStoreLayer = class("MeleeStoreLayer", require("app.views.mmExtend.LayerBase"))
MeleeStoreLayer.RESOURCE_FILENAME = "LuandouchoujiangLayer.csb"

function MeleeStoreLayer:onEnter()
    --self:init()
    mm.req("getMeleeStore",{type = 0})
end

function MeleeStoreLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function MeleeStoreLayer:onExit()
    
end

function MeleeStoreLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function MeleeStoreLayer:init(param)
    mm.app.clientTCP:addEventListener("autoRefreshStoreInfo",mm.autoRefreshStoreInfo)
    --添加node事件
    self.refreshTotalTimes = 0 
    self.scene = param.scene
    self.fightStoreInfo = mm.lastFightStoreInfo
    self.refreshTime = mm.lastFightStoreRefreshTime
    self.Node = self:getResourceNode()

    
    local refreshNode = self.Node:getChildByName("Image_miaoshukuang")
    local decNode = refreshNode:getChildByName("Text_src")

    local text = gameUtil.GetMoGameRetStr( 990200 )
    decNode:setString(text)

    self.moreCoinsBtn = self.Node:getChildByName("Image_3")
    self.moreCoinsBtn:setTouchEnabled(true)
    self.moreCoinsBtn:addTouchEventListener(handler(self, self.moreCoinsBtnCbk))


    game.storeXinYunBtn = self.Node:getChildByName("Panel_xinyun")
    game.storeshuaxinBtn = self.Node:getChildByName("Image_miaoshukuang")

    self:refreshUI()
    self:refreshStore()
end

function MeleeStoreLayer:refreshUI( )
    -- 资产信息
    local coinValue = mm.data.playerinfo.meleeCoin
    if coinValue == nil then
        coinValue = 0
    end
    local coinNode = self.Node:getChildByName("Text_2")
    coinNode:setString(coinValue)
end

function MeleeStoreLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getMeleeStore" then
            if event.t.type == 0 then
                mm.lastMeleeStoreInfo = event.t.meleeStoreInfo
                mm.lastMeleeStoreRefreshTime = event.t.refreshTime
                mm.data.playerExtra.meleeWinTimes = event.t.meleeWinTimes

                self.fightStoreInfo = mm.lastMeleeStoreInfo
                self.refreshTime = mm.lastMeleeStoreRefreshTime
                self:refreshUI()
                self:refreshStore()
            end
        elseif event.code == "buyMeleeStoreItem" then
            if event.t.type == 0 then
                mm.lastMeleeStoreInfo = event.t.meleeStoreInfo
                mm.lastMeleeStoreRefreshTime = event.t.refreshTime

                if event.t.playerinfo ~= nil then
                    mm.data.playerinfo = event.t.playerinfo
                end
                if event.t.playerExtra ~= nil then
                    mm.data.playerExtra = event.t.playerExtra
                    mm.data.playerExtra.meleeWinTimes = event.t.meleeWinTimes
                end
                if event.t.playerHunshi ~= nil then
                    mm.data.playerHunshi = event.t.playerHunshi
                end
                if event.t.playerEquip ~= nil then
                    mm.data.playerEquip = event.t.playerEquip
                end
                if event.t.playerItem ~= nil then
                    mm.data.playerItem = event.t.playerItem
                end

                self.fightStoreInfo = mm.lastMeleeStoreInfo
                self.refreshTime = mm.lastMeleeStoreRefreshTime
                self:refreshUI()
                self:refreshStore()

            end
        end
    end
end

function MeleeStoreLayer:refreshStore( )
    if self.fightStoreInfo == nil then
        return
    end

    local playerInfo = mm.data.playerinfo
    local totalNum = #self.fightStoreInfo
    
    local ListView = self.Node:getChildByName("ListView")
    ListView:removeAllItems()
    local size = ListView:getContentSize()
    local storeItemRes = INITLUA:getShopMeleeItemRes()

    local function sortRule(a, b)
        local aRes = storeItemRes[a.id]
        local bRes = storeItemRes[b.id]
        return aRes.shopmeleecount < bRes.shopmeleecount
    end
    table.sort( self.fightStoreInfo, sortRule )

    local fightTimes = mm.data.playerExtra.meleeWinTimes
    if fightTimes == nil then
        fightTimes = 0
    end

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
            local itemInfo = self.fightStoreInfo[index]
            local tempInfo = {scene = self.scene, info = itemInfo}
            local item = nil

            local itemID = itemInfo.id
            local storeItem = storeItemRes[itemID]
            if fightTimes < storeItem.shopmelee_num then
                item = require("src.app.views.layer.MeleeStoreItemNoLayer").new(tempInfo)
            else
                item = require("src.app.views.layer.MeleeStoreItemLayer").new(tempInfo)
            end


            local itemHeight = item:getContentSize().height
            local itemWidth = item:getContentSize().width
            local offsetX = (size.width-itemWidth*3)/4

            local temp = (size.width/3)*(j-1) + offsetX * (j-1)

            item:setPosition((size.width/3)*(j-1) + offsetX * (j-1),0)

            custom_item:setContentSize(cc.size(size.width, itemHeight))
            custom_item:addChild(item)
        end
        ListView:pushBackCustomItem(custom_item)
    end

    local time = self.refreshTime + 2  --2秒延迟自动刷新
    -- 刷新时间
    local refreshNode = self.Node:getChildByName("Image_miaoshukuang")
    local refreshTime = refreshNode:getChildByName("Text_name")
    local timeStr = self:getTime(time)
    refreshTime:setString("刷新时间: "..timeStr)

    local function countTime( ... )
        time = time - 1
        if time <= 0 then
            time = 0
            self.refreshTime = 0
            refreshTime:stopActionByTag(9999)     
        end
        timeStr = self:getTime(time)
        refreshTime:setString("刷新时间: "..timeStr)
    end
    refreshTime:stopActionByTag(9999)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(countTime),cc.DelayTime:create(1)))
    action:setTag(9999)
    refreshTime:runAction(action)

    local function countTimeB( ... )
        local tempTime = os.time()
        if self.refreshTotalTimes > 5 then
            refreshTime:stopActionByTag(99999)
        end
        if tempTime % 2 == 0 and self.refreshTime == 0 then
            mm.req("getMeleeStore",{type = 0})
            self.refreshTotalTimes = self.refreshTotalTimes + 1
        end
    end
    refreshTime:stopActionByTag(99999)
    local actionB = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(countTimeB)))
    actionB:setTag(99999)
    refreshTime:runAction(actionB)
end

function MeleeStoreLayer:getTime( time )
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

function MeleeStoreLayer:moreCoinsBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then  
        
    end
end

function MeleeStoreLayer:updateLayer( ... )

end

return MeleeStoreLayer