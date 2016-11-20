--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local DropItemLayer = class("DropItemLayer", require("app.views.mmExtend.LayerBase"))
DropItemLayer.RESOURCE_FILENAME = "duanweiguize_SL.csb"

function DropItemLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function DropItemLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function DropItemLayer:onEnter()
    if mm.GuildId == 15006 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(15007, self.backBtn)
        end, 0.01)
    end
end

function DropItemLayer:onExit()
    
end

function DropItemLayer:onEnterTransitionFinish()
    
end

function DropItemLayer:onExitTransitionStart()
    
end

function DropItemLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function DropItemLayer:init(key)
    --添加node事件
    self.Node = self:getResourceNode()

    -- 关闭按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self:initLayerUI(key)

end

function DropItemLayer:initLayerUI( key )
    local ListView = self.Node:getChildByName("ListView")

    local dropOutRes = INITLUA:getDropOutRes()

    local dropListRes = INITLUA:getDropListRes()
    
    -- local itemRate50 = {value={},type=50}
    -- local itemRate55 = {value={},type=55}
    -- local itemRate60 = {value={},type=60}
    -- local itemRate65 = {value={},type=65}
    -- local itemRate70 = {value={},type=70}

    local canDropTab = {}
    for k,v in pairs(dropOutRes) do
        if v.ID <= key then
            local canDropIdTab = v.LOLRankDrop
            if mm.data.playerinfo.camp ~= 1 then
                canDropIdTab = v.DotaRankDrop
            end
            for k1,v2 in pairs(canDropIdTab) do
                table.insert(canDropTab, v2)
            end
        end

    end



    self.dropTab = {}
    local ishas = {}

    for k,v in pairs(dropListRes) do
        local iscan = 0
        for k1,v1 in pairs(canDropTab) do
            if v.DropFrom == v1 then
                iscan = 1
            end
        end

        if v.EquipCamp == mm.data.playerinfo.camp then
            if v.ItemID ~= 0 then
                -- local itemRate = {}
                -- itemRate.ItemID = v.ItemID
                -- itemRate.RankPower = v.RankPower  
                -- if v.Rate50 ~= 0 then
                --     table.insert(itemRate50.value, itemRate)
                -- elseif v.Rate55 ~= 0 then
                --     table.insert(itemRate55.value, itemRate)
                -- elseif v.Rate60 ~= 0 then
                --     table.insert(itemRate60.value, itemRate)
                -- elseif v.Rate65 ~= 0 then
                --     table.insert(itemRate65.value, itemRate)
                -- elseif v.Rate70 ~= 0 then
                --     table.insert(itemRate70.value, itemRate)
                -- end
                self.dropTab[v.DropType] = self.dropTab[v.DropType] or {}
                ishas[v.DropType] = ishas[v.DropType] or {}
                if not ishas[v.DropType][v.ItemID] then
                    ishas[v.DropType][v.ItemID] = #self.dropTab[v.DropType] + 1
                    table.insert(self.dropTab[v.DropType], {ItemID = v.ItemID, type = v.DropType, can = iscan}) 

                else
                    if iscan == 1 then
                        local index = ishas[v.DropType][v.ItemID]
                        self.dropTab[v.DropType][index] = {ItemID = v.ItemID, type = v.DropType, can = iscan}
                    end
                end
            end
        end
    end

    local sortRules = {
        {
            func = function(v)
                
                return v.can
            end,
            isAscending = false,      
        },
        {
            func = function(v)
                return INITLUA:getEquipByid( v.ItemID ).Quality
            end,
            isAscending = true,


        },

    }
    -- itemRate50.value = util.powerSort(itemRate50.value, sortRules)
    -- itemRate55.value = util.powerSort(itemRate55.value, sortRules)
    -- itemRate60.value = util.powerSort(itemRate60.value, sortRules)
    -- itemRate65.value = util.powerSort(itemRate65.value, sortRules)
    -- itemRate70.value = util.powerSort(itemRate70.value, sortRules)
   
    for k,v in pairs(self.dropTab) do
        self.dropTab[k] = util.powerSort(v, sortRules)
    end

    -- local allItemList = {}
    -- table.insert(allItemList, itemRate70)
    -- table.insert(allItemList, itemRate65)
    -- table.insert(allItemList, itemRate60)
    -- table.insert(allItemList, itemRate55)
    -- table.insert(allItemList, itemRate50)
    local size  = cc.Director:getInstance():getWinSize()

    for k,v in pairs(self.dropTab) do
        local custom_item = ccui.Layout:create()
        local itemHeight = 84 * 1.2
        local itemWidth = 84
        local num = #v

        local offsetY = itemHeight*0.3
        local offsetX = itemWidth*0.3

        local custom_Tit = ccui.Layout:create()
        local title = cc.CSLoader:createNode("LiBaoItemTitle.csb") 
        custom_Tit:addChild(title)

        local all = 0
        for k,v in pairs(v) do
            all = all + 1
        end

        local count = 0
        for k1,v1 in pairs(v) do
            
            count = count + 1
            local equip = INITLUA:getEquipByid(v1.ItemID)

            if equip then
                local item = gameUtil.createEquipItem(v1.ItemID,0)
                item:setAnchorPoint(cc.p(0.0,0.0))
                
                itemHeight = item:getContentSize().height * 1.3
                itemWidth = item:getContentSize().width * 1.1
                custom_item:addChild(item)

                offsetY = itemHeight*0.3
                offsetX = itemWidth*0.3
                
                local tempY = math.floor((all/5) + 1) * itemHeight + offsetY
                local tempX = (size.width-itemWidth*5-offsetX*4) * 0.5 + itemWidth * 0.2
                item:setPosition(tempX + itemWidth* 1.2 * ((count-1)%5), tempY - offsetY  - itemHeight * ((math.floor((count-1)/5))+1))

                if v1.can == 0 then 
                    gameUtil.setGRAY(item:getChildByName("icon"):getVirtualRenderer():getSprite())
                    if item:getChildByName("ditu") then
                        gameUtil.setGRAY(item:getChildByName("ditu"):getVirtualRenderer():getSprite())
                    end
                    if item:getChildByName("pin") then
                        gameUtil.setGRAY(item:getChildByName("pin"):getVirtualRenderer():getSprite())
                    end
                    if item:getChildByName("hunshiImage") then
                        gameUtil.setGRAY(item:getChildByName("hunshiImage"):getVirtualRenderer():getSprite())
                    end
                end
            end

            
            if v1.type == 0 then
                title:getChildByName("Text"):setString("装备")
            elseif v1.type == 3 then
                title:getChildByName("Text"):setString("魂石")
            end
        end

        title:setAnchorPoint(cc.p(0.5, 0.2))
        title:setScale(1.5)
        title:setPositionX(size.width/2 - 10)
        custom_Tit:setContentSize(cc.size(ListView:getContentSize().width,title:getContentSize().height))
        ListView:pushBackCustomItem(custom_Tit)


        local H = math.floor((count/5) + 1) * itemHeight + offsetY
        custom_item:setContentSize(size.width,H) 

        ListView:pushBackCustomItem(custom_item)
    end
end

function DropItemLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
        if mm.GuildId == 15007 then
            mm:clearLayer()
            Guide:startGuildById(10025, mm.GuildScene.jingyanBtn)
        end

    end
end

return DropItemLayer


