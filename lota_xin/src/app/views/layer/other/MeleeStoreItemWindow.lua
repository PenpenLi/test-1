--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local MeleeStoreItemWindow = class("MeleeStoreItemWindow", require("app.views.mmExtend.LayerBase"))
MeleeStoreItemWindow.RESOURCE_FILENAME = "Scqueren.csb"

function MeleeStoreItemWindow:onCleanup()
    self:clearAllGlobalEventListener()
end


function MeleeStoreItemWindow:onEnter()
    
end

function MeleeStoreItemWindow:onExit()

end

function MeleeStoreItemWindow:onCreate(param)
    self:init(param.param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function MeleeStoreItemWindow:init(itemInfo)
    self.itemInfo = itemInfo
    self:initLayerUI()
end

function MeleeStoreItemWindow:initLayerUI( )
    local itemID = self.itemInfo.id
    local storeItemRes = INITLUA:getShopMeleeItemRes()
    local storeItem = storeItemRes[itemID]
    local shopItemID = storeItem.ShopItemID
    local shopItemType = storeItem.ShopType

    self.Node = self:getResourceNode()
    local rootNode = self.Node:getChildByName("Image_bg")
    self.rootNode = rootNode
    
    local hasNum = 0
    if shopItemType == 0 then
        local equip = INITLUA:getEquipByid(shopItemID)
        if equip then
            for k,v in pairs(mm.data.playerEquip) do
                if v.id == shopItemID then
                    hasNum = v.num
                    break
                end
            end

            local equipNode = gameUtil.createEquipItem(shopItemID , 0)
            local itemIcon = rootNode:getChildByName("Image_1")
            itemIcon:addChild(equipNode)
        
            local itemName = rootNode:getChildByName("Text_name")
            itemName:setString(equip.Name)

            local infoTextNode = rootNode:getChildByName("Image_bg01")
            local attText = infoTextNode:getChildByName("Text_01")
            local hpText = infoTextNode:getChildByName("Text_02")
            local speedText = infoTextNode:getChildByName("Text_03")
            local des = infoTextNode:getChildByName("Text_16")

            if equip.EquipType == 3 then
                des:setString(equip.eqsrc)
                attText:setVisible(false)
                hpText:setVisible(false)
                speedText:setVisible(false)
            else
                des:setVisible(false)
                attText:setString("攻击: "..equip.eq_gongji)
                hpText:setString("血量: "..equip.eq_shenming)
                speedText:setString("速度: "..equip.eq_sudu)
            end
        end
    elseif shopItemType == 1 then
        local equip = INITLUA:getEquipByid(shopItemID)
        if equip then

            for k,v in pairs(mm.data.playerHunshi) do
                if v.id == shopItemID then
                    hasNum = v.num
                    break
                end
            end

            local equipNode = gameUtil.createEquipItem(shopItemID , 0)
            local itemIcon = rootNode:getChildByName("Image_1")
            itemIcon:addChild(equipNode)
        
            local itemName = rootNode:getChildByName("Text_name")
            itemName:setString(equip.Name)

            local infoTextNode = rootNode:getChildByName("Image_bg01")
            local attText = infoTextNode:getChildByName("Text_01")
            local hpText = infoTextNode:getChildByName("Text_02")
            local speedText = infoTextNode:getChildByName("Text_03")
            local des = infoTextNode:getChildByName("Text_16")

            des:setString(equip.eqsrc)
            attText:setVisible(false)
            hpText:setVisible(false)
            speedText:setVisible(false)
            -- attText:setString("攻击: "..equip.eq_gongji)
            -- hpText:setString("血量: "..equip.eq_shenming)
            -- speedText:setString("速度: "..equip.eq_sudu)
        end
    elseif shopItemType == 2 then
        local item = INITLUA:getItemByid(shopItemID)
        if item then

            for k,v in pairs(mm.data.playerItem) do
                if v.id == shopItemID then
                    hasNum = v.num
                    break
                end
            end

            local itemNode = gameUtil.createItemWidget(shopItemID , 0)
            local itemIcon = rootNode:getChildByName("Image_1")
            itemIcon:addChild(itemNode)
        
            local itemName = rootNode:getChildByName("Text_name")
            itemName:setString(item.Name)

            local infoTextNode = rootNode:getChildByName("Image_bg01")
            local attText = infoTextNode:getChildByName("Text_01")
            local hpText = infoTextNode:getChildByName("Text_02")
            local speedText = infoTextNode:getChildByName("Text_03")
            local des = infoTextNode:getChildByName("Text_16")

            des:setString(item.itemsrc)
            attText:setVisible(false)
            hpText:setVisible(false)
            speedText:setVisible(false)

            -- attText:setString("攻击: "..0)
            -- hpText:setString("血量: "..0)
            -- speedText:setString("速度: "..0)
        end
    else
        cclog("ERROR======ERROR======ERROR=========ERROR")
    end

    local goldNum = rootNode:getChildByName("Text_3")
    goldNum:setString(storeItem.shopmelee_cost)

    local hasItemNum = rootNode:getChildByName("Text_08")
    hasItemNum:setString("拥有"..hasNum.."件")

    local itemNum = rootNode:getChildByName("Text_2")
    itemNum:setString("购买"..storeItem.shopmelee_buy.."件")

    

    local itemPriceIcon = rootNode:getChildByName("Image_21")
    local res = "res/UI/pc_luandoubi.png"
    itemPriceIcon:loadTexture(res)


    self.buyBtn = rootNode:getChildByName("Button_7")
    self.buyBtn:addTouchEventListener(handler(self, self.buyBtnCbk))
    gameUtil.setBtnEffect(self.buyBtn) 

    -- 关闭按钮
    self.backBtn = rootNode:getChildByName("Button_1")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    local equipAreaNode = rootNode:getChildByName("Panel_2")
    equipAreaNode:setVisible(false)

    if shopItemType == 0 then
        local heroData = self:checkHintIds(shopItemID)
        if #heroData > 0 then
            local ListView = equipAreaNode:getChildByName("ListView_1")

            for k,v in pairs(heroData) do
                -- for i=1,10 do
                local custom_item = ccui.Layout:create()
                local heroIcon = gameUtil.createTouXiang( v )

                custom_item:setTouchEnabled(false)
                -- custom_item:addTouchEventListener(handler(self, self.updateActivityClick))
                -- custom_item:setTag(v.ID)
                custom_item:addChild(heroIcon)
                local size = heroIcon:getContentSize()
                size.width = size.width * 1.1
                custom_item:setContentSize(size)
                ListView:pushBackCustomItem(custom_item)
                -- end
            end
            equipAreaNode:setVisible(true)
        end
    end

end

function MeleeStoreItemWindow:checkHintIds( equipID )
    local heroData = {}
    for i=1,#mm.data.playerHero do
        local eqTab = mm.data.playerHero[i].eqTab
        local jinTab = gameUtil.getEquipId( mm.data.playerHero[i].id, mm.data.playerHero[i].jinlv )
        if jinTab == nil then
            cclog("装备表资源错误！！！")
        end
        for j=1,6 do
            local t = gameUtil.getHeroEqByIndex( eqTab, j )
            local eqId = jinTab.EquipEx[j]
            if t == nil and eqId == equipID then
                table.insert(heroData, mm.data.playerHero[i])
                break
            end
        end
    end
    return heroData
end

function MeleeStoreItemWindow:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "heroUpExp" then

        end

    end
end

function MeleeStoreItemWindow:buyBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local itemID = self.itemInfo.id
        local storeItemRes = INITLUA:getShopMeleeItemRes()
        local storeItem = storeItemRes[itemID]

        mm.req("buyMeleeStoreItem",{type = 0 , itemID = self.itemInfo.id, itemNum = storeItem.shopmelee_buy})

        self:removeFromParent()
    end
end

function MeleeStoreItemWindow:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return MeleeStoreItemWindow


