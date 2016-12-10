--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local RewardResultLayer = class("RewardResultLayer", require("app.views.mmExtend.LayerBase"))
RewardResultLayer.RESOURCE_FILENAME = "jiangliLayer.csb"


function RewardResultLayer:onCleanup()
    --self:clearAllGlobalEventListener()
end

function RewardResultLayer:onEnter()

end

function RewardResultLayer:onExit()

end

function RewardResultLayer:onCreate(param)
    self:init(param)

    --self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function RewardResultLayer:init(param)
    self.rewardID = param.rewardID
    self.scene = param.scene

    self:initLayerUI()
end

function RewardResultLayer:initLayerUI( )
    self.Node = self:getResourceNode()

    self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(false)
    self.Node:getChildByName("Image_bg"):getChildByName("Image_2"):setVisible(false)
    self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1"):setVisible(false)
    self.Node:getChildByName("Image_bg"):getChildByName("Text_Num2"):setVisible(false)

    local button = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    button:addTouchEventListener(handler(self, self.closeClick))
    gameUtil.setBtnEffect(button)

    local ListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("ListView")
    local reward = nil
    local rewardRes = INITLUA:getActivtyRewardRes()
    
    for k,v in pairs(rewardRes) do
        if v.ID == self.rewardID then
            reward = v
        end
    end

    local num = -1

    local actItems = reward.ActItem
    if actItems ~= nil then
        for i=1,#actItems do
            local itemID = actItems[i]
            local itemNum = reward.ActItemNum[i]
            local item = INITLUA:getItemByid( itemID )
            if item ~= nil then
                local currentItem = gameUtil.createItemWidget(itemID , itemNum)
                currentItem:setAnchorPoint(cc.p(0.0,0.0))
                local custom_item = ccui.Layout:create()

                custom_item:addChild(currentItem)
                custom_item:setTag(itemID)
                custom_item.itemType = 2
                local size = currentItem:getContentSize()
                size.width = size.width * 1.1
                custom_item:setContentSize(size)
                -- custom_item:setTouchEnabled(true)
                -- custom_item:addTouchEventListener(handler(self, self.showItem))
                ListView:pushBackCustomItem(custom_item)
            end
        end
    end

    if mm.data.playerinfo.camp == 2 then
        local actItems = reward.DOTAActEquip
        if actItems ~= nil then
            for i=1,#actItems do
                local itemID = actItems[i]
                local itemNum = reward.DOTAActEquipNum[i]

                local currentItem = gameUtil.createEquipItem(itemID , itemNum)
                currentItem:setAnchorPoint(cc.p(0.0,0.0))
                local custom_item = ccui.Layout:create()

                custom_item:addChild(currentItem)
                custom_item:setTag(itemID)
                custom_item.itemType = 0
                local size = currentItem:getContentSize()
                size.width = size.width * 1.1
                custom_item:setContentSize(size)
                -- custom_item:setTouchEnabled(true)
                -- custom_item:addTouchEventListener(handler(self, self.showItem))
                ListView:pushBackCustomItem(custom_item)
            end
        end
    else
        local actItems = reward.LOLActEquip
        if actItems ~= nil then
            for i=1,#actItems do
                local itemID = actItems[i]
                local itemNum = reward.LOLActEquipNum[i]

                local currentItem = gameUtil.createEquipItem(itemID , itemNum)
                currentItem:setAnchorPoint(cc.p(0.0,0.0))
                local custom_item = ccui.Layout:create()

                custom_item:addChild(currentItem)
                custom_item:setTag(itemID)
                custom_item.itemType = 0
                local size = currentItem:getContentSize()
                size.width = size.width * 1.1
                custom_item:setContentSize(size)
                -- custom_item:setTouchEnabled(true)
                -- custom_item:addTouchEventListener(handler(self, self.showItem))
                ListView:pushBackCustomItem(custom_item)
            end
        end
    end

    if mm.data.playerinfo.camp == 2 then
        if reward.DotaSkinID > 0 then
            local item = INITLUA:getSkinByID(reward.DotaSkinID)
            
            local currentItem = gameUtil.createIconWithNum(item.Icon..".png", 1)
            currentItem:setScale(1.35)
            currentItem:setAnchorPoint(cc.p(0.0,0.0))
            local custom_item = ccui.Layout:create()

            custom_item:addChild(currentItem)
            local size = currentItem:getContentSize()
            size.width = size.width * 1.1
            custom_item:setContentSize(size)
            ListView:pushBackCustomItem(custom_item)
        end
    else

        if reward.LolSkinID > 0 then
            local item = INITLUA:getSkinByID(reward.LolSkinID)

            local currentItem = gameUtil.createIconWithNum(item.Icon..".png", 1)
            currentItem:setScale(1.35)
            currentItem:setAnchorPoint(cc.p(0.0,0.0))
            local custom_item = ccui.Layout:create()

            custom_item:addChild(currentItem)
            local size = currentItem:getContentSize()
            size.width = size.width * 1.1
            custom_item:setContentSize(size)
            ListView:pushBackCustomItem(custom_item)
        end
    end

    if reward.Act_Gold > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinbi.png", reward.Act_Gold)
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.1
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    if reward.Act_Diamond > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", reward.Act_Diamond)
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.1
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end
    if reward.Act_Honors > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_rongyu.png", reward.Act_Honors)--占用
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.1
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    if reward.Act_SkillPoint > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinengdian.png", reward.Act_SkillPoint)--占用
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.1
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    if reward.Act_GoldFingerTimes > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinshouzhi.png", reward.Act_GoldFingerTimes)--占用
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.1
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(false)
    self.Node:getChildByName("Image_bg"):getChildByName("Image_2"):setVisible(false)
    self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1"):setVisible(false)
    self.Node:getChildByName("Image_bg"):getChildByName("Text_Num2"):setVisible(false)

    if reward.Act_PlayerExp > 0 then
        self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1"):setString(reward.Act_PlayerExp)
        self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1"):setVisible(true)
        self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):loadTexture("res/UI/icon_EXPzhandui.png")
        self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(true)
    end

    if reward.Act_ExpPool > 0 then
        if reward.Act_PlayerExp > 0 then
            self.Node:getChildByName("Image_bg"):getChildByName("Text_Num2"):setString(reward.Act_ExpPool)
            self.Node:getChildByName("Image_bg"):getChildByName("Text_Num2"):setVisible(true)
            self.Node:getChildByName("Image_bg"):getChildByName("Image_2"):loadTexture("res/UI/icon_EXPjingyanchi.png")
            self.Node:getChildByName("Image_bg"):getChildByName("Image_2"):setVisible(true)
        else
            self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1"):setString(reward.Act_ExpPool)
            self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1"):setVisible(true)
            self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):loadTexture("res/UI/icon_EXPjingyanchi.png")
            self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(true)

        end
    end

end

function RewardResultLayer:closeClick(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end


return RewardResultLayer


