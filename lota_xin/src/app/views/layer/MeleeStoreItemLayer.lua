--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local MeleeStoreItemLayer = class("MeleeStoreItemLayer", require("app.views.mmExtend.LayerBase"))
MeleeStoreItemLayer.RESOURCE_FILENAME = "Shangpin.csb"


function MeleeStoreItemLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function MeleeStoreItemLayer:onEnter()

end

function MeleeStoreItemLayer:onExit()

end

function MeleeStoreItemLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function MeleeStoreItemLayer:init(param)
    self.param = param
    self.scene = param.scene
    self.itemInfo = param.info
    self:initLayerUI()
end

function MeleeStoreItemLayer:initLayerUI( )
    -- local xxxx = os.clock()
    self.Node = self:getResourceNode()
    self.Node:getChildByName("Text_6"):setVisible(false)
    self.Node:getChildByName("Text_3"):setVisible(false)
    self.Node:getChildByName("Image_3"):setVisible(false)

    local itemID = self.itemInfo.id
    local storeItemRes = INITLUA:getShopMeleeItemRes()

    local storeItem = storeItemRes[itemID]
    local shopItemID = storeItem.ShopItemID
    local shopItemType = storeItem.ShopType
    -- 如果是绝版，播放特效
    if storeItemRes.ShopItemLv == MM.EShopItemLv.SIL_Jueban then
        -- 添加物品边缘特效
        -- gameUtil.addArmatureFile("res/Effect/uiEffect/sg/sg.ExportJson")
        -- local item_play = ccs.Armature:create("sg")
        -- self.Node:getChildByName("Image_1"):addChild(item_play, 10)
        -- item_play:setAnchorPoint(cc.p(0.5, 0.5))
        -- local size = self.Node:getChildByName("Image_1"):getContentSize()
        -- item_play:setPosition(size.width/2, size.height/2)
        -- --item_play:setScale(size.width/item_play:getContentSize().width, size.height/item_play:getContentSize().height)
        -- item_play:setScale(2)
        -- item_play:getAnimation():playWithIndex(0)

        local item_play = gameUtil.createSkeAnmion( {name = "sg",scale = 0.75} )
        item_play:setAnimation(0, "stand", false)
        self.Node:getChildByName("Image_1"):addChild(item_play, 10)
        item_play:setAnchorPoint(cc.p(0.5, 0.5))
        local size = self.Node:getChildByName("Image_1"):getContentSize()
        item_play:setPosition(size.width/2, size.height/2)
    end

    -- 物品数量
    local itemNum = storeItem.shopmelee_buy
    if shopItemType == 0 or shopItemType == 1 then
        local equip = INITLUA:getEquipByid(shopItemID)
        if equip then
            local itemNode = gameUtil.createEquipItem( shopItemID , itemNum)
            local eqIcon = self.Node:getChildByName("Image_2"):addChild(itemNode)
            
            self.item_name = self.Node:getChildByName("Text_1")
            self.item_name:setString(equip.Name)
        end
    elseif shopItemType == 2 then
        local item = INITLUA:getItemByid(shopItemID)
        if item then
            local itemNode = gameUtil.createItemWidget(shopItemID , itemNum)
            local eqIcon = self.Node:getChildByName("Image_2"):addChild(itemNode)
            
            self.item_name = self.Node:getChildByName("Text_1")
            self.item_name:setString(item.Name)
        end
    else
        cclog("ERROR======ERROR======ERROR=========ERROR")
    end
    
    self.item_bg = self.Node:getChildByName("Image_1")
    local bgType = storeItem.ShopItemLv + 1
    local resStr = "res/icon/jiemian/icon_SC_"..bgType..".png"
    self.item_bg:loadTexture(resStr)
    
    self.item_bg:addTouchEventListener(handler(self, self.itemBtnCbk))
    self:setContentSize(self.item_bg:getContentSize())
    self.item_bg:setSwallowTouches(false)


    self.itemPriceIcon = self.Node:getChildByName("Image_4")
    self.itemPriceIcon:loadTexture("res/UI/pc_luandoubi.png")
    
    self.itemPriceIcon:setAnchorPoint(cc.p(0, 0.5))
    self.itemPrice = self.Node:getChildByName("Text_2")


    self.itemPrice:setString(storeItem.shopmelee_cost)
    self.itemPrice:setAnchorPoint(cc.p(0, 0.5))
    local textWidth = self.itemPrice:boundingBox().width + self.itemPriceIcon:getContentSize().width
    local itemBGWidth = self.item_bg:getContentSize().width
    local offsetX = (itemBGWidth - textWidth)*0.5
    self.itemPriceIcon:setPositionX(offsetX)
    self.itemPrice:setPositionX(offsetX + self.itemPriceIcon:getContentSize().width)


    self.leftNum = self.Node:getChildByName("Text_4")
    self.leftNum:setString("剩余:"..self.itemInfo.num)
end

function MeleeStoreItemLayer:refreshItem()
    self.leftNum:setString("剩余:"..self.itemInfo.num)
end

function MeleeStoreItemLayer:itemBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 

        local itemID = self.itemInfo.id
        local storeItemRes = INITLUA:getShopMeleeItemRes()
        local storeItem = storeItemRes[itemID]

        if self.itemInfo.num < storeItem.shopmelee_buy then
            gameUtil:addTishi({p = self.scene, s = "剩余数量不足，全服刷新后可购买", z = 1000000, f = 30})
            return
        end
        --达到购买条件则弹出购买确认窗口
        local windowLayer = require("src.app.views.layer.MeleeStoreItemWindow").new({param = self.itemInfo})
        local size  = cc.Director:getInstance():getWinSize()

        self.scene:addChild(windowLayer)
        windowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(windowLayer)
    end
end

function MeleeStoreItemLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "buyMeleeStoreItem" then
            local info = event.t.buyItemInfo
            if info == nil then
                return
            end
            
            if info.itemID == self.itemInfo.id then
                for k,v in pairs(event.t.meleeStoreInfo) do
                    if v.id == self.itemInfo.id then
                        self.itemInfo = v
                        break
                    end
                end
                
                self:refreshItem()
            end
        end
    end
end

return MeleeStoreItemLayer


