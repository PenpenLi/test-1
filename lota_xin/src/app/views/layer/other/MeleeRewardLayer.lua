local MeleeRewardLayer = class("MeleeRewardLayer", require("app.views.mmExtend.LayerBase"))
MeleeRewardLayer.RESOURCE_FILENAME = "Jinglishuoming.csb"

function MeleeRewardLayer:onCreate(param)

    self.Node = self:getResourceNode()
    local backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    gameUtil.setBtnEffect(backBtn)
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    local bg = self.Node:getChildByName("Image_bg")
    self.ListView = bg:getChildByName("Image_listView"):getChildByName("ListView_1")

    self:initWinner()

    self:initSelfQufu()

    -- self:initAllQufu()

    -- self:initQu()

    -- self:initRule()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function MeleeRewardLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function MeleeRewardLayer:onEnter()

end

function MeleeRewardLayer:onExit()
    
end

function MeleeRewardLayer:createTitle(str)
    local title = cc.CSLoader:createNode("LiBaoItemTitle.csb")
    local custom_item = ccui.Layout:create()
    title:getChildByName("Text"):setString(str)
    custom_item:addChild(title)
    custom_item:setContentSize(title:getContentSize())
    return custom_item
end

function MeleeRewardLayer:translateData(resTab)
    local showTab = {}
    showTab.equip = {}
    showTab.hunshi = {}
    showTab.item = {}
    showTab.extra = {}

    if mm.data.playerinfo.camp == 1 then
        for k,v in pairs(resTab.LOLMeleeEquip) do
            local equipRes = INITLUA:getEquipByid(v)
            equipRes.num = resTab.LOLMeleeEquipNum[k]
            if equipRes.EquipType == MM.EEquipType.ET_HunShi then
                table.insert(showTab.hunshi, equipRes)
            else
                table.insert(showTab.equip, equipRes)
            end
        end
        showTab.skin = resTab.LolMeleeSkinID
    else
        for k,v in pairs(resTab.DOTAMeleeEquip) do
            local equipRes = INITLUA:getEquipByid(v)
            equipRes.num = resTab.DOTAMeleeEquipNum[k]
            if equipRes.EquipType == MM.EEquipType.ET_HunShi then
                table.insert(showTab.hunshi, equipRes)
            else
                table.insert(showTab.equip, equipRes)
            end
        end
        showTab.skin = resTab.DotaMeleeSkinID
    end

    for k,v in pairs(resTab.MeleeItem) do
        local itemRes = INITLUA:getItemByid(v)
        itemRes.num = resTab.MeleeItemNum[k]
        table.insert(showTab.item, itemRes)
    end

    local function sort_rule(a, b)
        return a.Quality > b.Quality
    end
    table.sort(showTab.equip, sort_rule)
    table.sort(showTab.hunshi, sort_rule)
    table.sort(showTab.item, sort_rule)

    if resTab.Melee_Diamond ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_zuanshi.png"
        temp.num = resTab.Melee_Diamond
        table.insert(showTab.extra, temp)
    end
    if resTab.Melee_Gold ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_jinbi.png"
        temp.num = resTab.Melee_Gold
        table.insert(showTab.extra, temp)
    end
    if resTab.Melee_Honors ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_rongyu.png"
        temp.num = resTab.Melee_Honors
        table.insert(showTab.extra, temp)
    end
    if resTab.Melee_SkillPoint ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_jinengdian.png"
        temp.num = resTab.Melee_SkillPoint
        table.insert(showTab.extra, temp)
    end
    if resTab.Melee_GoldFingerTimes ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_jinshouzhi.png"
        temp.num = resTab.Melee_GoldFingerTimes
        table.insert(showTab.extra, temp)
    end
    if resTab.Melee_Goldmelee ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_luandoubi.png"
        temp.num = resTab.Melee_Goldmelee
        table.insert(showTab.extra, temp)
    end
    return showTab
end

function MeleeRewardLayer:addShowItem(showTab, showText)
    local itemNum = #showTab.equip + #showTab.hunshi + #showTab.item + #showTab.extra
    if showTab.skin ~= 0 then
        itemNum = itemNum + 1
    end

    local hang = math.ceil(itemNum/4)
    for i=1,hang do
        local item = cc.CSLoader:createNode("JinaglishuomingItem.csb")
        local custom_item = ccui.Layout:create()
        custom_item:addChild(item)
        custom_item:setContentSize(item:getContentSize())
        self.ListView:pushBackCustomItem(custom_item)
        if i == 1 then
            item:getChildByName("Text_1"):setString(showText)
        else
            item:getChildByName("Text_1"):setString("")
        end
        local begin = 1
        if showTab.skin ~= 0 then
            begin = 2
            -- 第一个添加皮肤
            local skinIcon = gameUtil.createSkinIcon(showTab.skin)
            local icon = item:getChildByName("Image_1")
            skinIcon:setContentSize(icon:getContentSize())
            icon:setTag(showTab.skin)
            icon:setName("4")
            icon:addChild(skinIcon)
            icon:setSwallowTouches(false)
            icon:setTouchEnabled(true)
            icon:addTouchEventListener(handler(self, self.showGoods))
        end
        for j=begin,4 do
            local index = (i-1)*4+j
            if index <= #showTab.hunshi then
                local index2 = index
                local equipRes = showTab.hunshi[index2]
                local image = gameUtil.createEquipItem(equipRes.ID, equipRes.num)
                local icon = item:getChildByName("Image_"..j)
                icon:setTag(equipRes.ID)
                icon:setName("2")
                icon:addChild(image)
                icon:setTouchEnabled(true)
                icon:setSwallowTouches(false)
                icon:addTouchEventListener(handler(self, self.showGoods))

            elseif index <= #showTab.hunshi + #showTab.equip then
                local index2 = index - #showTab.hunshi
                local equipRes = showTab.equip[index2]
                local image = gameUtil.createEquipItem(equipRes.ID, equipRes.num)
                local icon = item:getChildByName("Image_"..j)
                icon:setTag(equipRes.ID)
                icon:setName("1")
                icon:addChild(image)
                icon:setSwallowTouches(false)
                icon:setSwallowTouches(false)
                icon:setTouchEnabled(true)
                icon:addTouchEventListener(handler(self, self.showGoods))

            elseif index <= #showTab.hunshi + #showTab.equip + #showTab.item then
                local index2 = index - #showTab.hunshi - #showTab.equip
                local equipRes = showTab.item[index2]
                local image = gameUtil.createItemWidget(equipRes.ID, equipRes.num)
                local icon = item:getChildByName("Image_"..j)
                icon:setTag(equipRes.ID)
                icon:setName("3")
                icon:addChild(image)
                icon:setSwallowTouches(false)
                icon:setTouchEnabled(true)
                icon:addTouchEventListener(handler(self, self.showGoods))

            elseif index <= #showTab.hunshi + #showTab.equip + #showTab.item + #showTab.extra then
                local index2 = index - #showTab.hunshi - #showTab.equip - #showTab.item
                local equipRes = showTab.extra[index2]
                local image = gameUtil.createIconWithNum(equipRes.iconSrc, equipRes.num)
                image:setAnchorPoint(cc.p(0, 0))
                local icon = item:getChildByName("Image_"..j)
                icon:addChild(image)
                icon:setSwallowTouches(false)

            else
                local icon = item:getChildByName("Image_"..j)
                icon:setVisible(false)
                icon:setSwallowTouches(false)
            end
        end
    end
end

function MeleeRewardLayer:showGoods(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        local type = tonumber(widget:getName())
        local GoodsShowLayer = require("src.app.views.layer.GoodsShowLayer").new({id = id, type = type})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(GoodsShowLayer, MoGlobalZorder[2000002])
        GoodsShowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(GoodsShowLayer)
    end
end

local function sort_func(a, b)
    return a.ID < b.ID
end

function MeleeRewardLayer:initWinner()
    local custom_item = self:createTitle("胜负奖励")
    self.ListView:pushBackCustomItem(custom_item)

    local rewardRes = INITLUA:getRewardMeleeResMapByType(MM.Emelleerewardtype.benzhenying)
    table.sort(rewardRes, sort_func)
    for k,v in pairs(rewardRes) do
        local showTab = self:translateData(v)
        local showText = ""
        if v.Meleequjian[1] == 1 then
            showText = "胜利"
        elseif v.Meleequjian[1] == 0 then
            showText = "失败"
        end
        self:addShowItem(showTab, showText)
    end
end

function MeleeRewardLayer:initSelfQufu()
    local custom_item = self:createTitle("本服击杀")
    self.ListView:pushBackCustomItem(custom_item)

    local rewardRes = INITLUA:getRewardMeleeResMapByType(MM.Emelleerewardtype.benfujisha)
    table.sort(rewardRes, sort_func)
    for k,v in pairs(rewardRes) do
        local showTab = self:translateData(v)
        local showText = ""
        if #v.Meleequjian == 1 then
            showText = "第"..v.Meleequjian[1].."名"
        else
            if v.Meleequjian[1] == 500 then
                showText = "大于500名"
            else
                showText = "第"..v.Meleequjian[1].."-"..v.Meleequjian[2].."名"
            end
        end
        self:addShowItem(showTab, showText)
    end
end

function MeleeRewardLayer:initAllQufu()
    local custom_item = self:createTitle("跨服击杀")
    self.ListView:pushBackCustomItem(custom_item)

    local rewardRes = INITLUA:getRewardMeleeResMapByType(MM.Emelleerewardtype.kuafujisha)
    table.sort(rewardRes, sort_func)
    for k,v in pairs(rewardRes) do
        local showTab = self:translateData(v)
        local showText = ""
        if #v.Meleequjian == 1 then
            showText = "第"..v.Meleequjian[1].."名"
        else
            if v.Meleequjian[1] == 500 then
                showText = "大于500名"
            else
                showText = "第"..v.Meleequjian[1].."-"..v.Meleequjian[2].."名"
            end
        end
        self:addShowItem(showTab, showText)
    end
end

function MeleeRewardLayer:initQu()
    local custom_item = self:createTitle("区击杀")
    self.ListView:pushBackCustomItem(custom_item)

    local rewardRes = INITLUA:getRewardMeleeResMapByType(MM.Emelleerewardtype.qujisha)
    table.sort(rewardRes, sort_func)
    for k,v in pairs(rewardRes) do
        local showTab = self:translateData(v)
        local showText = ""
        if #v.Meleequjian == 1 then
            showText = "第"..v.Meleequjian[1].."名"
        else
            if v.Meleequjian[1] == 500 then
                showText = "大于500名"
            else
                showText = "第"..v.Meleequjian[1].."-"..v.Meleequjian[2].."名"
            end
        end
        self:addShowItem(showTab, showText)
    end
end

function MeleeRewardLayer:initRule()
    local custom_item = self:createTitle("规则说明")
    self.ListView:pushBackCustomItem(custom_item)

    local rewardRes = INITLUA:getRewardMeleeResMapByType(MM.Emelleerewardtype.benzhenying)
    table.sort(rewardRes, sort_func)
    for k,v in pairs(rewardRes) do
        local showTab = self:translateData(v)
        local showText = ""
        if v.Meleequjian[1] == 1 then
            showText = "胜利"
        elseif v.Meleequjian[1] == 0 then
            showText = "失败"
        end
        self:addShowItem(showTab, showText)
    end
end

function MeleeRewardLayer:backBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function MeleeRewardLayer:onEnterTransitionFinish()
    
end

function MeleeRewardLayer:onExitTransitionStart()
    
end

function MeleeRewardLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return MeleeRewardLayer