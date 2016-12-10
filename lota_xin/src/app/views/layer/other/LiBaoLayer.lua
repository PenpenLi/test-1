local LiBaoLayer = class("LiBaoLayer", require("app.views.mmExtend.LayerBase"))
LiBaoLayer.RESOURCE_FILENAME = "Libao.csb"

function LiBaoLayer:onCreate(param)
    local itemId = param.id
    self.LiBaoId = INITLUA:getItemByid(itemId).GiftID
    self.Node = self:getResourceNode()
    self.dropTab = param.dropTab
    local backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    gameUtil.setBtnEffect(backBtn)
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    if self.dropTab == nil then
        self:initLiBaoInfo()
    else
        self:initDropTabInfo()
    end

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function LiBaoLayer:initLiBaoInfo()
    local bg = self.Node:getChildByName("Image_bg")
    self.ListView = bg:getChildByName("Image_listView"):getChildByName("ListView_1")
    local Text_Num1 = bg:getChildByName("Text_Num1")
    local Text_Num2 = bg:getChildByName("Text_Num2")
    local libaoRes = INITLUA:getLiBaoResById(self.LiBaoId)
    Text_Num1:setString(libaoRes.GiftExpPool)
    Text_Num2:setString(libaoRes.GiftExp)
    bg:getChildByName("Text_01"):setString(libaoRes.Name)

    local libaoResMap = INITLUA:getLiBaoMapResById(self.LiBaoId)
    self.equipTab = {}
    self.hunshiTab = {}
    self.itemTab = {}
    for k,v in pairs(libaoResMap) do
        if v.ItemID ~= 0 and (v.EquipCamp == mm.data.playerinfo.camp or v.EquipCamp == 9) then
            if v.LibaoDropType == MM.ELibaoDropType.LB_Equip then
                local equipRes = INITLUA:getEquipByid(v.ItemID)
                if equipRes.EquipType ~= MM.EEquipType.ET_HunShi then
                    table.insert(self.equipTab, equipRes)
                else
                    table.insert(self.hunshiTab, equipRes)
                end
            elseif v.LibaoDropType == MM.ELibaoDropType.LB_Item then
                local itemRes = INITLUA:getItemByid(v.ItemID)
                table.insert(self.itemTab, itemRes)
            end
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

    self:dealWithUI()
end

function LiBaoLayer:initDropTabInfo()
    local bg = self.Node:getChildByName("Image_bg")
    self.ListView = bg:getChildByName("Image_listView"):getChildByName("ListView_1")
    local Text_Num1 = bg:getChildByName("Text_Num1")
    local Text_Num2 = bg:getChildByName("Text_Num2")
    local libaoRes = INITLUA:getLiBaoResById(self.LiBaoId)
    Text_Num1:setString(libaoRes.GiftExpPool)
    Text_Num2:setString(libaoRes.GiftExp)
    bg:getChildByName("Text_01"):setString(libaoRes.Name)

    local libaoResMap = INITLUA:getLiBaoMapResById(self.LiBaoId)
    self.equipTab = {}
    self.hunshiTab = {}
    self.itemTab = {}
    for k,v in pairs(self.dropTab) do
        if v.type == 1 then
            local equipRes = INITLUA:getEquipByid(v.id)
            equipRes.num = v.num
            table.insert(self.equipTab, equipRes)
        elseif v.type == 2 then
            local equipRes = INITLUA:getEquipByid(v.id)
            equipRes.num = v.num
            table.insert(self.hunshiTab, equipRes)
        elseif v.type == 3 then
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

    self:dealWithUI()
end

function LiBaoLayer:dealWithUI()
    if #self.hunshiTab > 0 then
        local title = cc.CSLoader:createNode("LiBaoItemTitle.csb")
        local custom_item = ccui.Layout:create()
        title:getChildByName("Text"):setString("魂石")
        custom_item:addChild(title)
        custom_item:setContentSize(title:getContentSize())
        self.ListView:pushBackCustomItem(custom_item)
        local hang = math.ceil(#self.hunshiTab/4)
        for i=1,hang do
            local item = cc.CSLoader:createNode("LiBaoItem.csb")
            local custom_item = ccui.Layout:create()
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)

            for j=1,4 do
                local index = (i-1)*4+j
                if index <= #self.hunshiTab then
                    local equipRes = self.hunshiTab[(i-1)*4+j]
                    local image = gameUtil.createEquipItem(equipRes.ID, 0)
                    item:getChildByName("Image_"..j):addChild(image)
                else
                    item:getChildByName("Image_"..j):setVisible(false)
                end
            end
        end
    end
    if #self.equipTab > 0 then
        local title = cc.CSLoader:createNode("LiBaoItemTitle.csb")
        local custom_item = ccui.Layout:create()
        title:getChildByName("Text"):setString("装备")
        custom_item:addChild(title)
        custom_item:setContentSize(title:getContentSize())
        self.ListView:pushBackCustomItem(custom_item)
        local hang = math.ceil(#self.equipTab/4)
        for i=1,hang do
            local item = cc.CSLoader:createNode("LiBaoItem.csb")
            local custom_item = ccui.Layout:create()
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)

            for j=1,4 do
                local index = (i-1)*4+j
                item:getChildByName("Image_"..j):setEnabled(false)
                if index <= #self.equipTab then
                    local equipRes = self.equipTab[(i-1)*4+j]
                    local image = gameUtil.createEquipItem(equipRes.ID, 0)
                    item:getChildByName("Image_"..j):addChild(image)
                else
                    item:getChildByName("Image_"..j):setVisible(false)
                end
            end
        end
    end
    if #self.itemTab > 0 then
        local title = cc.CSLoader:createNode("LiBaoItemTitle.csb")
        local custom_item = ccui.Layout:create()
        title:getChildByName("Text"):setString("道具")
        custom_item:addChild(title)
        custom_item:setContentSize(title:getContentSize())
        self.ListView:pushBackCustomItem(custom_item)
        local hang = math.ceil(#self.itemTab/4)
        for i=1,hang do
            local item = cc.CSLoader:createNode("LiBaoItem.csb")
            local custom_item = ccui.Layout:create()
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)

            for j=1,4 do
                local index = (i-1)*4+j
                if index <= #self.itemTab then
                    local equipRes = self.itemTab[(i-1)*4+j]
                    local image = gameUtil.createItemWidget(equipRes.ID, 0)
                    item:getChildByName("Image_"..j):addChild(image)
                else
                    item:getChildByName("Image_"..j):setVisible(false)
                end
            end
        end
    end

    if #self.extraTab > 0 then
        local title = cc.CSLoader:createNode("LiBaoItemTitle.csb")
        local custom_item = ccui.Layout:create()
        title:getChildByName("Text"):setString("其他")
        custom_item:addChild(title)
        custom_item:setContentSize(title:getContentSize())
        self.ListView:pushBackCustomItem(custom_item)
        local hang = math.ceil(#self.extraTab/4)
        for i=1,hang do
            local item = cc.CSLoader:createNode("LiBaoItem.csb")
            local custom_item = ccui.Layout:create()
            custom_item:addChild(item)
            custom_item:setContentSize(item:getContentSize())
            self.ListView:pushBackCustomItem(custom_item)

            for j=1,4 do
                local index = (i-1)*4+j
                if index <= #self.extraTab then
                    local equipRes = self.extraTab[(i-1)*4+j]
                    local image = gameUtil.createItemByIcon(equipRes.iconSrc, equipRes.num)
                    image:setAnchorPoint(cc.p(0, 0))
                    item:getChildByName("Image_"..j):addChild(image)
                else
                    item:getChildByName("Image_"..j):setVisible(false)
                end
            end
        end
    end
end

function LiBaoLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function LiBaoLayer:onEnter()
    
end

function LiBaoLayer:onExit()
    
end

function LiBaoLayer:backBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function LiBaoLayer:onEnterTransitionFinish()
    
end

function LiBaoLayer:onExitTransitionStart()
    
end

function LiBaoLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return LiBaoLayer