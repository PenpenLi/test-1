local JoinMeleeRewardLayer = class("JoinMeleeRewardLayer", require("app.views.mmExtend.LayerBase"))
JoinMeleeRewardLayer.RESOURCE_FILENAME = "JoinMeleeRewardLayer.csb"

function JoinMeleeRewardLayer:onCreate(param)
    self.Node = self:getResourceNode()
    self.dropTab = param.dropTab
    self.dropResID = param.dropResID
    self.addKillNum = param.addKillNum

    local image_bg = self.Node:getChildByName("Image_bg")

    local Button_ok = image_bg:getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    gameUtil.setBtnEffect(Button_ok)

    image_bg:getChildByName("Image_bg01"):getChildByName("Text_zhantimes"):setString(self.addKillNum)

    self.dropRes = INITLUA:getResWithId("Rewardmelee", self.dropResID)
    if self.dropRes.Melee_PlayerExp == 0 then
        image_bg:getChildByName("Image_gold"):setVisible(false)
        image_bg:getChildByName("Text_exp"):setVisible(false)
    else
        image_bg:getChildByName("Image_gold"):setVisible(true)
        image_bg:getChildByName("Text_exp"):setVisible(true)
        image_bg:getChildByName("Text_exp"):setString(self.dropRes.Melee_PlayerExp)
    end

    if self.dropRes.Melee_ExpPool == 0 then
        image_bg:getChildByName("Image_exp"):setVisible(false)
        image_bg:getChildByName("Text_exppool"):setVisible(false)
    else
        image_bg:getChildByName("Image_exp"):setVisible(true)
        image_bg:getChildByName("Text_exppool"):setVisible(true)
        image_bg:getChildByName("Text_exppool"):setString(self.dropRes.Melee_ExpPool)
    end

    self.ListView = image_bg:getChildByName("Image_ListView"):getChildByName("ListView")

    self:dealList()
end

function JoinMeleeRewardLayer:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function JoinMeleeRewardLayer:dealList()
    local showTab = {}
    showTab.equip = {}
    showTab.hunshi = {}
    showTab.item = {}
    showTab.extra = {}

    for k,v in pairs(self.dropTab) do
        if v.type == 1 then -- 装备
            local res = INITLUA:getEquipByid(v.id)
            res.num = v.num
            table.insert(showTab.equip, res)
        elseif v.type == 2 then -- 道具
            local res = INITLUA:getItemByid(v.id)
            res.num = v.num
            table.insert(showTab.item, res)
        elseif v.type == 3 then -- 魂石
            local res = INITLUA:getEquipByid(v.id)
            res.num = v.num
            table.insert(showTab.hunshi, res)
        elseif v.type == 4 then -- 皮肤
            showTab.skin = v.id
        end
    end

    local function sort_rule(a, b)
        return a.Quality > b.Quality
    end
    table.sort(showTab.equip, sort_rule)
    table.sort(showTab.hunshi, sort_rule)
    table.sort(showTab.item, sort_rule)

    if self.dropRes.Melee_Diamond ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_zuanshi.png"
        temp.num = self.dropRes.Melee_Diamond
        table.insert(showTab.extra, temp)
    end
    if self.dropRes.Melee_Gold ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_jinbi.png"
        temp.num = self.dropRes.Melee_Gold
        table.insert(showTab.extra, temp)
    end
    if self.dropRes.Melee_Honors ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_rongyu.png"
        temp.num = self.dropRes.Melee_Honors
        table.insert(showTab.extra, temp)
    end
    if self.dropRes.Melee_SkillPoint ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_jinengdian.png"
        temp.num = self.dropRes.Melee_SkillPoint
        table.insert(showTab.extra, temp)
    end
    if self.dropRes.Melee_GoldFingerTimes ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_jinshouzhi.png"
        temp.num = self.dropRes.Melee_GoldFingerTimes
        table.insert(showTab.extra, temp)
    end
    if self.dropRes.Melee_Goldmelee ~= 0 then
        local temp = {}
        temp.iconSrc = "res/icon/jiemian/icon_luandoubi.png"
        temp.num = self.dropRes.Melee_Goldmelee
        table.insert(showTab.extra, temp)
    end

    self:dealUI(showTab)
end

function JoinMeleeRewardLayer:dealUI(showTab)
    if showTab.skin and showTab.skin ~= 0 then
        local image = gameUtil.createSkinIcon(showTab.skin)
        self.ListView:pushBackCustomItem(image)
    end

    for k,v in pairs(showTab.hunshi) do
        local image = gameUtil.createEquipItem(v.ID, v.num)
        self.ListView:pushBackCustomItem(image)
    end

    for k,v in pairs(showTab.equip) do
        local image = gameUtil.createEquipItem(v.ID, v.num)
        self.ListView:pushBackCustomItem(image)
    end

    for k,v in pairs(showTab.item) do
        local image = gameUtil.createItemWidget(v.ID, v.num)
        self.ListView:pushBackCustomItem(image)
    end

    for k,v in pairs(showTab.extra) do
        local image = gameUtil.createIconWithNum(v.iconSrc, v.num)
        image:setAnchorPoint(cc.p(0, 0))
        self.ListView:pushBackCustomItem(image)
    end
end

function JoinMeleeRewardLayer:onEnter()
    
end

function JoinMeleeRewardLayer:onExit()
    
end

function JoinMeleeRewardLayer:onEnterTransitionFinish()
    
end

function JoinMeleeRewardLayer:onExitTransitionStart()
    
end

function JoinMeleeRewardLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return JoinMeleeRewardLayer