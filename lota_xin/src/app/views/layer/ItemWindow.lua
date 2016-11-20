--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local ItemWindow = class("ItemWindow", require("app.views.mmExtend.LayerBase"))
ItemWindow.RESOURCE_FILENAME = "Scqueren.csb"

function ItemWindow:onCleanup()
    self:clearAllGlobalEventListener()
end


function ItemWindow:onEnter()
    
end

function ItemWindow:onExit()

end

function ItemWindow:onCreate(param)
    self:init(param.param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ItemWindow:init(itemInfo)
    self.itemInfo = itemInfo
    self:initLayerUI()
end

function ItemWindow:initLayerUI( )
    local itemID = self.itemInfo.itemID
    local itemType = self.itemInfo.itemType

    self.Node = self:getResourceNode()
    local rootNode = self.Node:getChildByName("Image_bg")

    
    local hasNum = 0
    if itemType == 0 then
        local equip = INITLUA:getEquipByid(itemID)
        if equip then

            for k,v in pairs(mm.data.playerEquip) do
                if v.id == itemID then
                    hasNum = v.num
                    break
                end
            end

            local equipNode = gameUtil.createEquipItem(itemID , 0)
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
            local hasItemNum = rootNode:getChildByName("Text_08")
            hasItemNum:setString("拥有"..hasNum.."件")
        end
    elseif itemType == 1 then
        local equip = INITLUA:getEquipByid(itemID)
        if equip then

            for k,v in pairs(mm.data.playerHunshi) do
                if v.id == itemID then
                    hasNum = v.num
                    break
                end
            end

            local equipNode = gameUtil.createEquipItem(itemID , 0)
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
            local hasItemNum = rootNode:getChildByName("Text_08")
            hasItemNum:setString("拥有"..hasNum.."件")
        end
    elseif itemType == 2 then
        local item = INITLUA:getItemByid(itemID)
        if item then

            for k,v in pairs(mm.data.playerItem) do
                if v.id == itemID then
                    hasNum = v.num
                    break
                end
            end

            local itemNode = gameUtil.createItemWidget(itemID , 0)
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
            local hasItemNum = rootNode:getChildByName("Text_08")
            hasItemNum:setString("拥有"..hasNum.."件")
        end
    elseif itemType == 3 then
        local item = INITLUA:getSkinByID(itemID)
        if item then
            local itemNode = gameUtil.createIconWithNum(item.Icon..".png", 1)
            itemNode:setScale(1.3)

            local itemIcon = rootNode:getChildByName("Image_1")
            itemIcon:addChild(itemNode)
        
            local itemName = rootNode:getChildByName("Text_name")
            itemName:setString(item.Name)

            local infoTextNode = rootNode:getChildByName("Image_bg01")
            local attText = infoTextNode:getChildByName("Text_01")
            local hpText = infoTextNode:getChildByName("Text_02")
            local speedText = infoTextNode:getChildByName("Text_03")
            local des = infoTextNode:getChildByName("Text_16")

            local desStr = ""
            if item.eq_gongji > 0 then
                desStr = "攻击+"..item.eq_gongji..","..item.SkinNote
            elseif item.eq_shenming > 0 then
                desStr = "生命+"..item.eq_shenming..","..item.SkinNote
            elseif item.eq_sudu > 0 then
                desStr = "速度+"..item.eq_sudu..","..item.SkinNote
            elseif item.eq_duosan > 0 then
                desStr = "躲闪+"..item.eq_duosan..","..item.SkinNote
            elseif item.eq_crit > 0 then
                desStr = "暴击+"..item.eq_crit..","..item.SkinNote
            elseif item.eq_hujia > 0 then
                desStr = "护甲+"..item.eq_hujia..","..item.SkinNote
            elseif item.eq_mokang > 0 then
                desStr = "魔抗+"..item.eq_mokang..","..item.SkinNote
            end

            des:setString(desStr)
            attText:setVisible(false)
            hpText:setVisible(false)
            speedText:setVisible(false)

            local hasItemNum = rootNode:getChildByName("Text_08")
            hasItemNum:setString("皮肤")
        end
    else
        cclog("ERROR======ERROR======ERROR=========ERROR")
    end

    rootNode:getChildByName("Text_2"):setVisible(false)
    rootNode:getChildByName("Image_21"):setVisible(false)
    rootNode:getChildByName("Text_3"):setVisible(false)

    self.buyBtn = rootNode:getChildByName("Button_7")
    self.buyBtn:setTitleText("确定")
    self.buyBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.buyBtn) 

    -- 关闭按钮
    self.backBtn = rootNode:getChildByName("Button_1")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    local equipAreaNode = rootNode:getChildByName("Panel_2")
    equipAreaNode:setVisible(false)
end

function ItemWindow:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return ItemWindow


