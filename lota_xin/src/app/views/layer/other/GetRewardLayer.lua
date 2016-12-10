local GetRewardLayer = class("GetRewardLayer", require("app.views.mmExtend.LayerBase"))
GetRewardLayer.RESOURCE_FILENAME = "jiangliLayer.csb"

function GetRewardLayer:onCreate(param)

    local itemId = param.id
    
    self.LiBaoId = INITLUA:getItemByid(itemId).GiftID

    self.dropTab = param.dropTab or {}
    self.Node = self:getResourceNode()

    local okBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    gameUtil.setBtnEffect(okBtn)
    okBtn:addTouchEventListener(handler(self, self.okBtnCbk))

    self.ListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("ListView")

    local Text_Num1 = self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1")
    local Text_Num2 = self.Node:getChildByName("Image_bg"):getChildByName("Text_Num2")
    local libaoRes = INITLUA:getLiBaoResById(self.LiBaoId)
    Text_Num1:setString(libaoRes.GiftExpPool)
    Text_Num2:setString(libaoRes.GiftExp)

    self:getItemData()
    self:showItem()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function GetRewardLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function GetRewardLayer:onEnter()
    
end

function GetRewardLayer:onExit()
    
end

function GetRewardLayer:getItemData()
    self.equipTab = {}
    self.hunshiTab = {}
    self.itemTab = {}
    for k,v in pairs(self.dropTab) do
        if v.type == 1 and v.num > 0 then
            local equipRes = INITLUA:getEquipByid(v.id)
            equipRes.num = v.num
            table.insert(self.equipTab, equipRes)
        elseif v.type == 2 and v.num > 0 then
            local equipRes = INITLUA:getEquipByid(v.id)
            equipRes.num = v.num
            table.insert(self.hunshiTab, equipRes)
        elseif v.type == 3 and v.num > 0 then
            local equipRes = INITLUA:getItemByid(v.id)
            equipRes.num = v.num
            table.insert(self.itemTab, equipRes)
        end
    end
    local function sort_rule(a, b)
        return a.Quality > b.Quality
    end
    table.sort(self.equipTab, sort_rule)
    table.sort(self.hunshiTab, sort_rule)
    table.sort(self.itemTab, sort_rule)

    self.extraTab = {}
    local libaoRes = INITLUA:getLiBaoResById(self.LiBaoId)
    if libaoRes.GiftGold ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_jinbi.png"
        temp.num = libaoRes.GiftGold
        table.insert(self.extraTab, temp)
    end
    if libaoRes.GiftDiamond ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_zuanshi.png"
        temp.num = libaoRes.GiftGold
        table.insert(self.extraTab, temp)
    end
    if libaoRes.GiftHonour ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_rongyu.png"
        temp.num = libaoRes.GiftGold
        table.insert(self.extraTab, temp)
    end
end

function GetRewardLayer:showItem()
    if #self.equipTab > 0 then
        for k,v in pairs(self.equipTab) do
            local item = gameUtil.createEquipItem(v.ID, v.num)
            local custom_item = ccui.Layout:create()
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)
        end
    end
    if #self.hunshiTab > 0 then
        for k,v in pairs(self.hunshiTab) do
            local item = gameUtil.createEquipItem(v.ID, v.num)
            local custom_item = ccui.Layout:create()
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)
        end
    end
    if #self.itemTab > 0 then
        for k,v in pairs(self.itemTab) do
            local item = gameUtil.createItemWidget(v.ID, v.num)
            local custom_item = ccui.Layout:create()
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)
        end
    end
    if #self.extraTab > 0 then
        for k,v in pairs(self.extraTab) do
            local item = gameUtil.createItemByIcon(v.iconSrc, v.num)
            local custom_item = ccui.Layout:create()
            item:setAnchorPoint(cc.p(0, 0))
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)
        end
    end
end

function GetRewardLayer:okBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function GetRewardLayer:onEnterTransitionFinish()
    
end

function GetRewardLayer:onExitTransitionStart()
    
end

function GetRewardLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return GetRewardLayer