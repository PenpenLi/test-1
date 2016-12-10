local ActivityWFBaseLayer = class("ActivityWFBaseLayer", require("app.views.mmExtend.LayerBase"))
ActivityWFBaseLayer.RESOURCE_FILENAME = "Huodong_changguidi.csb"

function ActivityWFBaseLayer:onEnter()
    --self:init()

    mm.req("getActivityInfo",{type=0})
end

function ActivityWFBaseLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function ActivityWFBaseLayer:onExit()
    
end

function ActivityWFBaseLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ActivityWFBaseLayer:init(param)
    self.scene = param.scene
    self.Node = self:getResourceNode()
    
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self:initTopListView()
    self:updateUI()
    self:updateExtraUI()  
end

function ActivityWFBaseLayer:initView( )
    -- body
end

function ActivityWFBaseLayer:getTime( time )
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

function ActivityWFBaseLayer:getTaskProgress( activity )
    for k,v in pairs(self.activityRecord) do
        if v.activityId == tostring(activity.ID) then
            return v.value
        end
    end
    return 0
end

function ActivityWFBaseLayer:getItem( activity, targetValue1, index )
    local aProgress = self:getTaskProgress( activity )
    local taskItem = nil

    -- taskItem = cc.CSLoader:createNode("chengjiuNOitem1.csb")
    -- local status = "progress"
    -- return taskItem, status
    ---[[
    local activtyRewardRes = INITLUA:getActivtyRewardRes()
    local activtyListRes = INITLUA:getActivtyListRes()
    local reward = {}
    local rewardID = nil

    for k,v in pairs(activtyListRes) do
        if tostring(v.ID) == self.currentId then
            rewardID = v.Act_GiftType
            break
        end
    end
    for k,v in pairs(activtyRewardRes) do
        if v.RewardGroupID == rewardID and index == v.ActR_Lv then
            reward = v
            break
        end
    end

    local status = "progress"
    if aProgress >= targetValue1 then
        local find = false
        for k,v in pairs(self.activityRecord) do
            if tostring(v.activityId) == self.currentId then
                if v.reward then
                    for key,value in pairs(v.reward) do
                        for reKey,reValue in pairs(value) do
                            if reKey == tostring(targetValue1) then
                                if reValue == "fuckTrue" then
                                    find = true
                                    break
                                end
                            end
                        end
                        if find == true then
                            break
                        end
                    end
                end
                break
            end
        end
        if find == true then
            local tempItem = cc.CSLoader:createNode("HuodongNOitem.csb")
            taskItem = tempItem:getChildByName("Image_bg"):clone()
            -- taskItem:setAnchorPoint(cc.p(0.5,1.0))
            -- local rootNode = taskItem:getChildByName("Image_bg")
            local button = taskItem:getChildByName("Button_1")
            button:setContentSize(cc.size(150,70))
            -- button:setScale(0.5)
            button:setVisible(false)
            taskItem:getChildByName("Text_lingqu"):setString("已领取")

            status = "finish"
        else
            local tempItem = cc.CSLoader:createNode("HuodongYesItem.csb")
            taskItem = tempItem:getChildByName("Image_bg"):clone()
            -- taskItem:setAnchorPoint(cc.p(0.5,1.0))
            status = "reward"
        end
    else
        local tempItem = cc.CSLoader:createNode("HuodongNOitem.csb")
        taskItem = tempItem:getChildByName("Image_bg"):clone()
        -- taskItem:setAnchorPoint(cc.p(0.5,1.0))
        -- local rootNode = taskItem:getChildByName("Image_bg")
        if reward.ActButton == "" then
            local button = taskItem:getChildByName("Button_1")
            button:setContentSize(cc.size(150,70))
            button:setVisible(false)
        else
            local button = taskItem:getChildByName("Button_1")
            button:setContentSize(cc.size(150,70))
            button:setVisible(true)
            button:setTouchEnabled(false)
            button:setTitleText(reward.ActButton)
        end
        
        local targetValue1Str = gameUtil.dealNumberShort( targetValue1 )
        local aProgressStr = gameUtil.dealNumberShort( aProgress )

        taskItem:getChildByName("Text_lingqu"):setString(aProgressStr.."/"..targetValue1Str)
        status = "progress"
    end
    taskItem:setTag(targetValue1)

    local taskbiao = taskItem:getChildByName("Text_biao")
    taskbiao:setString(reward.ActTitle)
    local taskName = taskItem:getChildByName("Text_name")
    taskName:setString(reward.ActSecondTitle)
    taskName:setPositionX(taskbiao:getPositionX() + taskbiao:getContentSize().width + 5)
    
    -- taskItem:getChildByName("Text_exp1"):setVisible(false)
    -- taskItem:getChildByName("Text_exp2"):setVisible(false)
    -- taskItem:getChildByName("Image_2"):setVisible(false)
    -- taskItem:getChildByName("Image_3"):setVisible(false)
    


    local actItems = reward.ActItem
    local itemBg = taskItem:getChildByName("Image_eq01")
    local itemBgX, itemBgY = itemBg:getPosition()
    local itemWidth = itemBg:getContentSize().width * 1.2

    local itemBGList = {}
    for i=1,5 do
        local item = taskItem:getChildByName("Image_eq0"..i)
        item:setTouchEnabled(false)
        -- item:setSwallowTouches(false)
        item:setVisible(false)
        table.insert(itemBGList, item)
    end

    local cellNum = -1
    local itemIndex = 0
    if actItems ~= nil then
        for i=1,#actItems do
            local itemID = actItems[i]
            local itemNum = reward.ActItemNum[i]
            local item = INITLUA:getItemByid( itemID )
            if item ~= nil then

                cellNum = cellNum + 1
                local currentItem = gameUtil.createItemWidget(itemID , itemNum)

                itemIndex = itemIndex + 1
                local itemBGTemp = itemBGList[itemIndex]
                itemBGTemp:setTouchEnabled(true)
                itemBGTemp:setVisible(true)
                itemBGTemp:addChild(currentItem)
                itemBGTemp:addTouchEventListener(handler(self, self.itemClick))

                itemBGTemp.itemType = 2
                itemBGTemp.itemID = itemID
                itemBGTemp.itemNum = itemNum
                itemBGTemp.listView = ListView
            end
        end
    end

    if mm.data.playerinfo.camp == 2 then
        local actItems = reward.DOTAActEquip
        if actItems ~= nil then
            for i=1,#actItems do
                local itemID = actItems[i]
                local itemNum = reward.DOTAActEquipNum[i]

                cellNum = cellNum + 1
                local currentItem = gameUtil.createEquipItem(itemID , itemNum)
                
                itemIndex = itemIndex + 1
                local itemBGTemp = itemBGList[itemIndex]
                itemBGTemp:setTouchEnabled(true)
                itemBGTemp:setVisible(true)
                itemBGTemp:addChild(currentItem)
                itemBGTemp:addTouchEventListener(handler(self, self.itemClick))

                itemBGTemp.itemType = 1
                itemBGTemp.itemID = itemID
                itemBGTemp.itemNum = itemNum
                itemBGTemp.listView = ListView
            end
        end
    else
        local actItems = reward.LOLActEquip
        if actItems ~= nil then
            for i=1,#actItems do
                local itemID = actItems[i]
                local itemNum = reward.LOLActEquipNum[i]

                cellNum = cellNum + 0
                local currentItem = gameUtil.createEquipItem(itemID , itemNum)
                
                itemIndex = itemIndex + 1
                local itemBGTemp = itemBGList[itemIndex]
                itemBGTemp:setTouchEnabled(true)
                itemBGTemp:setVisible(true)
                itemBGTemp:addChild(currentItem)
                itemBGTemp:addTouchEventListener(handler(self, self.itemClick))

                itemBGTemp.itemType = 1
                itemBGTemp.itemID = itemID
                itemBGTemp.itemNum = itemNum
                itemBGTemp.listView = ListView
            end
        end
    end

    if reward.Act_Gold > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinbi.png", reward.Act_Gold)
        
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
    end

    if reward.Act_Diamond > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", reward.Act_Diamond)
        
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
    end

    if reward.Act_Honors > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_rongyu.png", reward.Act_Honors)--占用
       
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
    end

    if reward.Act_SkillPoint > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinengdian.png", reward.Act_SkillPoint)--占用
        
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
    end

    if reward.Act_GoldFingerTimes > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinshouzhi.png", reward.Act_GoldFingerTimes)--占用
        
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
    end

    if mm.data.playerinfo.camp == 2 then
        if reward.DotaSkinID > 0 then
            cellNum = cellNum + 1
            local item = INITLUA:getSkinByID(reward.DotaSkinID)
            local currentItem = gameUtil.createIconWithNum(item.Icon..".png", 1)
            currentItem:setScale(1.3)

            itemIndex = itemIndex + 1
            local itemBGTemp = itemBGList[itemIndex]
            itemBGTemp:setVisible(true)
            itemBGTemp:setTouchEnabled(true)
            itemBGTemp:addChild(currentItem)
            itemBGTemp:addTouchEventListener(handler(self, self.itemClick))

            itemBGTemp.itemType = 3
            itemBGTemp.itemID = item.ID
            itemBGTemp.itemNum = 1
            itemBGTemp.listView = ListView
        end
    else

        if reward.LolSkinID > 0 then
            cellNum = cellNum + 1
            local item = INITLUA:getSkinByID(reward.LolSkinID)

            local currentItem = gameUtil.createIconWithNum(item.Icon..".png", 1)
            currentItem:setScale(1.3)

            itemIndex = itemIndex + 1
            local itemBGTemp = itemBGList[itemIndex]
            itemBGTemp:setVisible(true)
            itemBGTemp:setTouchEnabled(true)
            itemBGTemp:addChild(currentItem)
            itemBGTemp:addTouchEventListener(handler(self, self.itemClick))

            itemBGTemp.itemType = 3
            itemBGTemp.itemID = item.ID
            itemBGTemp.itemNum = 1
            itemBGTemp.listView = ListView
        end
    end
    -- if reward.Act_PlayerExp > 0 then
    --     taskItem:getChildByName("Text_exp1"):setString(reward.Act_PlayerExp)
    --     taskItem:getChildByName("Text_exp1"):setVisible(true)
    --     taskItem:getChildByName("Image_2"):loadTexture("res/UI/icon_EXPzhandui.png")
    --     taskItem:getChildByName("Image_2"):setVisible(true)
    -- end

    -- if reward.Act_ExpPool > 0 then
    --     if reward.Act_PlayerExp > 0 then
    --         taskItem:getChildByName("Text_exp2"):setString(reward.Act_ExpPool)
    --         taskItem:getChildByName("Text_exp2"):setVisible(true)
    --         taskItem:getChildByName("Image_3"):loadTexture("res/UI/icon_EXPjingyanchi.png")
    --         taskItem:getChildByName("Image_3"):setVisible(true)
    --     else
    --         taskItem:getChildByName("Text_exp1"):setString(reward.Act_ExpPool)
    --         taskItem:getChildByName("Text_exp1"):setVisible(true)
    --         taskItem:getChildByName("Image_2"):loadTexture("res/UI/icon_EXPjingyanchi.png")
    --         taskItem:getChildByName("Image_2"):setVisible(true)
    --     end
    -- end

    taskItem:setSwallowTouches(false)

    return taskItem, status
end

function ActivityWFBaseLayer:itemClick(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local tag = widget:getTag()
        local itemInfo = {}
        itemInfo.itemID = widget.itemID
        itemInfo.itemType = widget.itemType
        local windowLayer = require("src.app.views.layer.ItemWindow").new({param = itemInfo})
        local size  = cc.Director:getInstance():getWinSize()
        self.scene:addChild(windowLayer, MoGlobalZorder[2999999])
        windowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(windowLayer)

        -- local size  = cc.Director:getInstance():getWinSize()
        -- self.scene:addChild(PurchaseLayer, MoGlobalZorder[2999999])
        -- PurchaseLayer:setContentSize(cc.size(size.width, size.height))
        -- ccui.Helper:doLayout(PurchaseLayer)
    end
end

function ActivityWFBaseLayer:initTopListView()
    self.topListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_shang"):getChildByName("ListView_Hero")

    local activityInfo = json.decode(mm.data.activityInfo)
    local activityInfoRes = INITLUA:getActivtyListRes()
    local activityTypeRes = INITLUA:getActivtyTypeRes()

    local currentActivity = {}
    local buffActivity = false
    for k,v in pairs(activityInfo) do
        local activityId = tonumber(v.activityId)
        local activity = activityInfoRes[activityId]
        local activityType = activityTypeRes[activity.ActID]
        
        if activityType.ActTypeName == "Wonderful" then
            if activity.finish ~= MM.Efinish.Act_null then
                table.insert(currentActivity, activity)
            elseif buffActivity == false then
                buffActivity = true
                table.insert(currentActivity, activity)
            end
        end
    end

    self.topListView:removeAllItems()
    self.currentId = nil

    for k,v in pairs(currentActivity) do
        local custom_item = ccui.Layout:create()
        local iconPath = "icon/jiemian/"..v.activityIcon..".png"
        if v.finish == MM.Efinish.Act_null then
            iconPath = "icon/jiemian/bt_meirifuli.png"
        end
        local Image_icon = self:createTopIcon(iconPath)
        if self.currentId == nil then
            self.selectHeroKuang = ccui.ImageView:create()
            self.selectHeroKuang:loadTexture("res/UI/jm_hero_select.png")
            self.selectHeroKuang:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)
            Image_icon:addChild(self.selectHeroKuang)
            self.currentId = tostring(v.ID)
        end
        custom_item:setTouchEnabled(true)
        custom_item:addTouchEventListener(handler(self, self.updateActivityClick))
        custom_item:setTag(v.ID)
        custom_item:addChild(Image_icon)
        custom_item:setContentSize(Image_icon:getContentSize())
        self.topListView:pushBackCustomItem(custom_item)
    end

    mm.req("readActivity",{type=0,activityId = tonumber(self.currentId)})
end

function ActivityWFBaseLayer:updateActivity( widget, activityId )
    mm.req("readActivity",{type=0,activityId = tonumber(activityId)})

    self.currentId = tostring(activityId)
    self.selectHeroKuang:removeFromParent()

    self.selectHeroKuang = ccui.ImageView:create()
    self.selectHeroKuang:loadTexture("res/UI/jm_hero_select.png")
    self.selectHeroKuang:setPosition(widget:getContentSize().width/2, widget:getContentSize().height/2)
    widget:addChild(self.selectHeroKuang)

    self:updateUI()
    self:updateExtraUI()
end

function ActivityWFBaseLayer:updateActivityClick(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local activityId = widget:getTag()
        self:updateActivity( widget, activityId )
    end
end

function ActivityWFBaseLayer:createTopIcon( path )
    local Image_icon = ccui.ImageView:create()
    -- Image_icon:setName("TouXiang")
    Image_icon:loadTexture(path)
    Image_icon:setAnchorPoint(cc.p(0, 0))
    return Image_icon
end

function ActivityWFBaseLayer:updateExtraUI( )
    local activtyListRes = INITLUA:getActivtyListRes()
    local index = tonumber(self.currentId)
    local currentAcRes = activtyListRes[index]

    local finishCondition = currentAcRes.finish

    if finishCondition == MM.Efinish.Act_null then
        finishCondition = currentAcRes.Buff
    else
        local info = json.decode(mm.data.publicActivityExtraInfo)

        if MM.Efinish.Act_UseDiamondNum == finishCondition then   ---消耗钻石
            local selfNum = info.selfCampDiamond or 0
            local enemyNum = info.enemyCampDiamond or 0

            self:updateExtraItem( selfNum, enemyNum, "消耗钻石:", "消耗钻石:")
        elseif MM.Efinish.Act_UseGoldNum == finishCondition then   ---金币消耗
            local selfNum = info.selfCampCoin or 0
            local enemyNum = info.enemyCampCoin or 0

            self:updateExtraItem( selfNum, enemyNum, "消耗金币:", "消耗金币:")
        elseif MM.Efinish.Act_UseEquipNum == finishCondition then   ---装备消耗
            local selfNum = info.selfCampEquip or 0
            local enemyNum = info.enemyCampEquip or 0

            self:updateExtraItem( selfNum, enemyNum, "消耗装备:", "消耗装备:")
        elseif MM.Efinish.Act_SkillPointTimes == finishCondition then   ---消耗技能点
            local selfNum = info.selfCampSkillPoint or 0
            local enemyNum = info.enemyCampSkillPoint or 0

            self:updateExtraItem( selfNum, enemyNum, "消耗技能点:", "消耗技能点:")
        elseif MM.Efinish.Act_BuyTimes == finishCondition then   ---购买商城次数
            local selfNum = info.selfCampBuyStoreNum or 0
            local enemyNum = info.enemyCampBuyStoreNum or 0

            self:updateExtraItem( selfNum, enemyNum, "商城购买:", "商城购买:")
        elseif MM.Efinish.Act_StoneTimes == finishCondition then   ---消耗魂石
            local selfNum = info.selfCampHunshiNum or 0
            local enemyNum = info.enemyCampHunshiNum or 0

            self:updateExtraItem( selfNum, enemyNum, "消耗魂石:", "消耗魂石:")
        elseif MM.Efinish.Act_UseExpPoolNum == finishCondition then   ---消耗经验池
            local selfNum = info.selfCampExpPoolNum or 0
            local enemyNum = info.enemyCampExpPoolNum or 0

            self:updateExtraItem( selfNum, enemyNum, "消耗经验池:", "消耗经验池:")
        elseif MM.Efinish.Act_AfterPlayerLv == finishCondition then   ---购买基金
            local extraNode = self.baseLayer:getChildByName("Image_4")
            local rewardDiamondText = extraNode:getChildByName("Text_zuan")
            local buyDiamondText = extraNode:getChildByName("Text_huafei")
            local vipText = extraNode:getChildByName("Text_vip")
            local buyButton = extraNode:getChildByName("Button_2")
            gameUtil.setBtnEffect(buyButton)

            local sundryRes = INITLUA:getSundryRes()
            local rewardDiamondNum = sundryRes[1093677106].Value
            local buyDiamondNum = sundryRes[1093677108].Value
            local vipNum = sundryRes[1093677107].Value
            rewardDiamondText:setString(rewardDiamondNum)
            buyDiamondText:setString(buyDiamondNum)
            vipText:setString("VIP"..vipNum.."可购买")

            if  mm.data.playerExtra.buyFundRecord == "fuckTrue" then
                buyButton:setTitleText("已购买")
                buyButton:setTouchEnabled(false)
            else
                buyButton:setTitleText("购买")
                buyButton:setTouchEnabled(true)
            end
            buyButton:addTouchEventListener(handler(self, self.buyFundClick))

            local leftNode = self.baseLayer:getChildByName("Text_mai1")
            local rightNode = self.baseLayer:getChildByName("Text_mai2")

            local selfNum = info.selfCampBuyFundNum or 0
            local enemyNum = info.enemyCampBuyFundNum or 0

            leftNode:setString("购买:"..selfNum)
            rightNode:setString("购买:"..enemyNum)
        end
    end
end

function ActivityWFBaseLayer:updateExtraItem( leftNum, rightNum, leftText, rightText)
    local extraNode = self.baseLayer:getChildByName("Image_4")
    local selfText = extraNode:getChildByName("Text_3")
    local enemyText = extraNode:getChildByName("Text_3_0")

    local selfNum = leftNum or 0
    local enemyNum = rightNum or 0
    local total = selfNum + enemyNum

    selfText:setString(leftText..selfNum)
    enemyText:setString(rightText..enemyNum)
    local progress1 = extraNode:getChildByName("Image_1"):getChildByName("LoadingBar_1")
    local progress2 = extraNode:getChildByName("Image_1"):getChildByName("LoadingBar_2")
    local percent = 50
    if total == 0 then
        percent = 50
    else
        percent = (selfNum/total) * 100
    end
    progress1:setPercent(percent)
    progress2:setPercent(100-percent)

    local itemBg = extraNode:getChildByName("Node_1")

    itemBg:setVisible(false)
    local itemBgX, itemBgY = itemBg:getPosition()
    local itemWidth = 50 * 1.1

    local tempx,tempy = extraNode:getPosition()

    local activityRewardRes = INITLUA:getActivtyRewardRes()
    local activtyListRes = INITLUA:getActivtyListRes()

    local reward = {}
    local rewardID = nil

    for k,v in pairs(activtyListRes) do
        if tostring(v.ID) == self.currentId then
            rewardID = v.Act_GiftType2
            break
        end
    end
    for k,v in pairs(activityRewardRes) do
        if v.RewardGroupID == rewardID then
            reward = v
            break
        end
    end

    local actItems = reward.ActItem

    local cellNum = -1
    if actItems ~= nil then
        for i=1,#actItems do
            local itemID = actItems[i]
            local itemNum = reward.ActItemNum[i]
            local item = INITLUA:getItemByid( itemID )
            if item ~= nil then

                cellNum = cellNum + 1
                local currentItem = gameUtil.createItemWidget(itemID , itemNum)
                currentItem:setAnchorPoint(cc.p(0.5,0.5))
                currentItem:setScale(0.6)

                currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
                extraNode:addChild(currentItem)

                -- local size = currentItem:getContentSize()
                -- size.width = size.width * 1.3
                -- item2:setContentSize(size)
            end
        end
    end

    if mm.data.playerinfo.camp == 2 then
        local actItems = reward.DOTAActEquip
        if actItems ~= nil then
            for i=1,#actItems do
                local itemID = actItems[i]
                local itemNum = reward.DOTAActEquipNum[i]

                cellNum = cellNum + 1
                local currentItem = gameUtil.createEquipItem(itemID , itemNum)
                currentItem:setAnchorPoint(cc.p(0.5,0.5))
                currentItem:setScale(0.6)

                currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
                extraNode:addChild(currentItem)
            end
        end
    else
        local actItems = reward.LOLActEquip
        if actItems ~= nil then
            for i=1,#actItems do
                local itemID = actItems[i]
                local itemNum = reward.LOLActEquipNum[i]

                cellNum = cellNum + 1
                local currentItem = gameUtil.createEquipItem(itemID , itemNum)
                currentItem:setAnchorPoint(cc.p(0.5,0.5))
                currentItem:setScale(0.6)

                currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
                extraNode:addChild(currentItem)
            end
        end
    end

    if reward.Act_Gold > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinbi.png", reward.Act_Gold)
        currentItem:setAnchorPoint(cc.p(0.5,0.5))
        currentItem:setScale(0.6)

        currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        extraNode:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item2:setContentSize(size)
    end

    if reward.Act_Diamond > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", reward.Act_Diamond)
        currentItem:setAnchorPoint(cc.p(0.5,0.5))
        currentItem:setScale(0.6)

        currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        extraNode:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item3:setContentSize(size)
    end

    if reward.Act_Honors > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_rongyu.png", reward.Act_Honors)--占用
       currentItem:setAnchorPoint(cc.p(0.5,0.5))
        currentItem:setScale(0.6)

        currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        extraNode:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item4:setContentSize(size)
    end

    if reward.Act_SkillPoint > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinengdian.png", reward.Act_SkillPoint)--占用
        currentItem:setAnchorPoint(cc.p(0.5,0.5))
        currentItem:setScale(0.6)

        currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        extraNode:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item5:setContentSize(size)
    end

    if reward.Act_GoldFingerTimes > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinshouzhi.png", reward.Act_GoldFingerTimes)--占用
        currentItem:setAnchorPoint(cc.p(0.5,0.5))
        currentItem:setScale(0.6)

        currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        extraNode:addChild(currentItem)
    end
end

function ActivityWFBaseLayer:updateUI( )
    if self.baseLayer then
        self.baseLayer:removeFromParent()
    end
    
    local activityInfo = json.decode(mm.data.activityInfo)
    self.activityRecord = json.decode(mm.data.activityRecord)

    local activtyListRes = INITLUA:getActivtyListRes()
    local index = tonumber(self.currentId)
    local activity = activtyListRes[index]


    local activityTemplet = activity.activityTemplet..".csb"
    self.baseLayer = cc.CSLoader:createNode(activityTemplet)
    self:addChild(self.baseLayer)
    local size  = cc.Director:getInstance():getWinSize()
    self.baseLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.baseLayer)


    local ListView = self.baseLayer:getChildByName("Image_ditu"):getChildByName("ListView")
    ListView:removeAllItems()


    local finishCondition = activity.finish

    if finishCondition == MM.Efinish.Act_null then
        -- finishCondition = MM.EBuff.ActBuff_DoubleGold
        -- MM.EBuff = {
        --     ActBuff_null        =   0,
        --     ActBuff_DoubleGold      =   1,
        --     ActBuff_DoubleExp       =   2,
        --     ActBuff_DoubleExpPool       =   3,
        --     ActBuff_DoubleLucky     =   4,
        -- }
        local textNode = self.baseLayer:getChildByName("Image_4"):getChildByName("Text_sb")
        textNode:setString("每天都有不同的福利，记得常来看看！")
        local totalNum = 0
        local buffActivityList = {}
        for k,v in pairs(activityInfo) do
            local activityId = tonumber(v.activityId)
            local tempData = activtyListRes[activityId]
            if tempData.finish == MM.Efinish.Act_null then
                table.insert(buffActivityList, tempData)
                totalNum = totalNum + 1
            end
        end
        -- totalNum = 10
        local size = ListView:getContentSize()
        --创建商品ItemView
        local row = math.ceil(totalNum / 3)
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
                 local itemInfo = buffActivityList[index]
                 local buffItem = self:getBuffItem( itemInfo )

                 local itemHeight = buffItem:getContentSize().height
                 local itemWidth = buffItem:getContentSize().width

                local offsetX = (size.width-itemWidth*3)/4
                 buffItem:setPosition(itemWidth*(j-1) + offsetX * (j),0)

                 custom_item:setContentSize(cc.size(size.width, itemHeight))
                 custom_item:addChild(buffItem)
            end
            ListView:pushBackCustomItem(custom_item)
        end
    else
        --------------------------目前只考虑限制条件1-----------------------------
        local targetValue1 = activity.ActCondition1
        local extraInfo = json.decode(mm.data.publicActivityExtraInfo)
        local totalNum = 0
        local firstReward = 0

        for k,v in pairs(targetValue1) do
            local currentItem, status = self:getItem( activity, v, k)
            local custom_item = ccui.Layout:create()

            custom_item:addChild(currentItem)
            custom_item:setTag(v)
            custom_item.actLevel = k
            custom_item:setTouchEnabled(true)

			currentItem.targetValue = v
			currentItem.actLevel = k
			
            totalNum = totalNum + 1
            if finishCondition == MM.Efinish.Act_AfterPlayerLv then
                if mm.data.playerExtra.buyFundRecord == "fuckTrue" then
                    if status == "reward" then
                        currentItem:addTouchEventListener(handler(self, self.getRewardCbk))
                        if firstReward == 0 then
                            firstReward = totalNum
                        end
                    elseif status == "progress" then
                        currentItem:addTouchEventListener(handler(self, self.jumpTo))
                    end
                else
                    currentItem:addTouchEventListener(handler(self, self.hintBuyFund))
                end
            else
                if status == "reward" then
                    currentItem:addTouchEventListener(handler(self, self.getRewardCbk))
                    if firstReward == 0 then
                        firstReward = totalNum
                    end
                elseif status == "progress" then
                    currentItem:addTouchEventListener(handler(self, self.jumpTo))
                end
            end

            local size = currentItem:getContentSize()
            -- size.width = size.width * 1.3
            custom_item:setContentSize(size)
            ListView:pushBackCustomItem(custom_item)
        end
        if totalNum == 0 or firstReward == 0 then
            firstReward = 0
            totalNum = 1
        end

        local leftNum = totalNum - firstReward
        
        if firstReward > 2 then
            local percent = (firstReward*1.0) / (totalNum*1.0) * 100
            -- percent = 100
            if percent <= 80 then
                percent = percent - 10 
            end
            ListView:forceDoLayout()
            if leftNum < 3 then
                ListView:jumpToPercentVertical(100)
            else
                ListView:jumpToPercentVertical(percent)
            end
        end

        local serverOpenTime = os.time()
        for k,v in pairs(game.severList) do
            if v.Areaid == tostring(mm.data.playerinfo.qufu) then
                serverOpenTime = tonumber(v.openTime)
                break
            end
        end
        
        if finishCondition == MM.Efinish.Act_AfterPlayerLv then
            
        else
            local time = 0
            if activity ~= nil then
                if activity.cycleType == MM.EcycleType.Open then --开服活动
                    local serverDate = serverOpenTime
                    local cycleTime = tonumber(activity.cycleTime)
                    local workTime = tonumber(activity.workTime)
                    local continueTime = tonumber(activity.continueTime)
                    local currentTime = os.time()
                    
                    time = serverDate + cycleTime * 24 * 3600 + workTime + continueTime - currentTime
                    if time <= 0 then
                        time = 0
                    end
                elseif activity.cycleType == MM.EcycleType.Once then --单次活动
                elseif activity.cycleType == MM.EcycleType.Hour then --没小时活动
                elseif activity.cycleType == MM.EcycleType.Week then --每周活动
                elseif activity.cycleType == MM.EcycleType.Mouth then --每月活动 
                    local cycleTime = tonumber(activity.cycleTime)
                    local currentTime = os.time()

                    local startDate = os.date("*t", currentTime)
                    startDate.day = cycleTime
                    startDate.hour = 0
                    startDate.min = 0
                    startDate.sec = 0

                    local endTime = os.time(startDate) + tonumber(activity.workTime) + tonumber(activity.continueTime)

                    time = endTime - currentTime
                    if time <= 0 then
                        time = 0
                    end
                end
            end
            local refreshTime = self.baseLayer:getChildByName("Text_mai1")
            local timeStr = self:getTime(time)
            refreshTime:setString("活动剩余时间: "..timeStr)

            local function countTime( ... )
                time = time - 1
                if time <= 0 then
                    time = 0
                end
                timeStr = self:getTime(time)
                refreshTime:setString("活动剩余时间: "..timeStr)
            end
            refreshTime:stopActionByTag(9999)
            local action = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(countTime),cc.DelayTime:create(1)))
            action:setTag(9999)
            refreshTime:runAction(action)

            local timeReward = 0
            if activity ~= nil then
                if activity.cycleType == MM.EcycleType.Open then --开服活动
                    local serverDate = serverOpenTime
                    local cycleTime = tonumber(activity.cycleTime)
                    local workTime = tonumber(activity.workTime)
                    local rewardTime = tonumber(activity.rewardTime)
                    local currentTime = os.time()
                    
                    timeReward = serverDate + cycleTime * 24 * 3600 + workTime + rewardTime - currentTime
                    if timeReward <= 0 then
                        timeReward = 0
                    end
                elseif activity.cycleType == MM.EcycleType.Once then --单次活动
                elseif activity.cycleType == MM.EcycleType.Hour then --没小时活动
                elseif activity.cycleType == MM.EcycleType.Week then --每周活动
                elseif activity.cycleType == MM.EcycleType.Mouth then --每月活动
                    local currentTime = os.time()
                    local cycleTime = tonumber(activity.cycleTime) 
                    local startDate = os.date("*t", currentTime)
                    startDate.day = cycleTime
                    startDate.hour = 0
                    startDate.min = 0
                    startDate.sec = 0

                    local endTime = os.time(startDate) + tonumber(activity.workTime) + tonumber(activity.rewardTime)

                    timeReward = endTime - currentTime
                    if timeReward <= 0 then
                        timeReward = 0
                    end
                end

                
            end
            local refreshRewardTime = self.baseLayer:getChildByName("Text_mai2")
            if timeReward == time then
                refreshRewardTime:setVisible(false)
            else
                refreshRewardTime:setVisible(true)
            end

            local timeRewardStr = self:getTime(timeReward)
            refreshRewardTime:setString("领奖剩余时间: "..timeRewardStr)

            local function countTime( ... )
                timeReward = timeReward - 1
                if timeReward <= 0 then
                    timeReward = 0
                end
                timeRewardStr = self:getTime(timeReward)
                refreshRewardTime:setString("领奖剩余时间: "..timeRewardStr)
            end
            refreshRewardTime:stopActionByTag(9999)
            local rewardAction = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(countTime),cc.DelayTime:create(1)))
            rewardAction:setTag(9999)
            refreshRewardTime:runAction(rewardAction)
        end
    end
end

function ActivityWFBaseLayer:getBuffItem( itemInfo )
    local buffItem = cc.CSLoader:createNode("Shangpin.csb")
    local resStr = "res/icon/jiemian/icon_SC_1.png"
    buffItem:getChildByName("Image_1"):loadTexture(resStr)

    buffItem:getChildByName("Image_3"):loadTexture("res/icon/jiemian/icon_putong.png")
    buffItem:getChildByName("Image_3"):setScale(1.6)
    local itemIcon = cc.Sprite:create("res/icon/jiemian/"..itemInfo.activityIcon..".png")
    itemIcon:setAnchorPoint(cc.p(0.0, 0.0))

    buffItem:getChildByName("Image_2"):addChild(itemIcon)
    local buffValue = itemInfo.ActCondition1[1]
    buffItem:getChildByName("Text_3"):setString(buffValue.."%")

    local reward = nil
    local rewardResList = INITLUA:getActivtyRewardRes()
    for k,v in pairs(rewardResList) do
        if v.RewardGroupID == itemInfo.Act_GiftType then
            reward = v
            break
        end
    end

    if reward == nil then
        buffItem:getChildByName("Text_1"):setString("ERROR")
        buffItem:getChildByName("Text_6"):setVisible(false)
    else
        buffItem:getChildByName("Text_1"):setString(reward.ActTitle)
        buffItem:getChildByName("Text_6"):setVisible(true)
        buffItem:getChildByName("Text_6"):setString(reward.ActSecondTitle)
    end

    buffItem:getChildByName("Image_4"):setVisible(false)
    buffItem:getChildByName("Text_2"):setVisible(false)
    buffItem:getChildByName("Text_4"):setVisible(false)

    buffItem:getChildByName("Image_1"):setTouchEnabled(false)
    return buffItem
end

function ActivityWFBaseLayer:getTime( time )
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

function ActivityWFBaseLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getActivityInfo" then
            if event.t.type == 0 then
                mm.data.activityInfo = event.t.activityInfo
                mm.data.activityRecord = event.t.activityRecord
                mm.data.publicActivityExtraInfo = event.t.publicActivityExtraInfo
                self:updateUI()
                self:updateExtraUI()
                self:updateTopView()
            end
        elseif event.code == "rewardActivity" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                mm.data.activityInfo = event.t.activityInfo
                mm.data.activityRecord = event.t.activityRecord
                mm.data.publicActivityExtraInfo = event.t.publicActivityExtraInfo

                self:updateUI()
                self:updateExtraUI()
                self:updateTopView()

                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "领取完成", z = 999999})
            else
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "领取失败", z = 999999})
                --mm:popLayer()
            end
        elseif event.code == "buyFund" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                mm.data.activityRecord = event.t.activityRecord
                self:updateUI()
                self:updateExtraUI()
                self:updateTopView()
            end
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = MoGameRet[event.t.code], z = 999999})
        elseif event.code == "readActivity" then
            if event.t.type == 0 then
               local info = json.decode(mm.data.activityRecord)
               for k,v in pairs(info) do
                    if v.activityId == tostring(event.t.activityId) then
                        info[k].read = true
                        break
                    end
               end
               mm.data.activityRecord = json.encode(info)
               self:updateTopView()
            end
        end
    end
end

function ActivityWFBaseLayer:getRewardCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local targetValue = widget.targetValue
        local actLevel = widget.actLevel
        mm.req("rewardActivity",{type=1, activityId = self.currentId, conditionValue = targetValue, actLevel = actLevel})
    end
end

function ActivityWFBaseLayer:buyFundClick(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm.req("buyFund",{type=1})
    end
end

function ActivityWFBaseLayer:hintBuyFund(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "请先购买成长基金", z = 999999})
    end
end

function ActivityWFBaseLayer:jumpTo(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local actLevel = widget.actLevel
        local activityRewardRes = INITLUA:getActivtyRewardRes()
        local activtyListRes = INITLUA:getActivtyListRes()

        local reward = {}
        local rewardID = nil

        for k,v in pairs(activtyListRes) do
            if tostring(v.ID) == self.currentId then
                rewardID = v.Act_GiftType
                break
            end
        end
        for k,v in pairs(activityRewardRes) do
            if v.RewardGroupID == rewardID and actLevel == v.ActR_Lv then
                reward = v
                break
            end
        end

        if reward and reward.ActLayerPath ~= "" then
            game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = reward.ActLayerPath})
        end
    end
end

function ActivityWFBaseLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        -- self:removeFromParent()
        mm.popLayer()
    end
end

function ActivityWFBaseLayer:updateTopView()
    local items = self.topListView:getItems()
    for k,v in pairs(items) do
        local itemID = v:getTag()
        local ActTypeName = "Wonderful"
        local redPoint = self:checkActivityRedPoint(ActTypeName, itemID)
        if redPoint then
            gameUtil.addRedPoint(v)
        else
            gameUtil.removeRedPoint(v)
        end
    end

    local activityRecord = json.decode(mm.data.activityRecord)
    for k,v in pairs(items) do
        local itemID = v:getTag()
        if v:getChildByName("redPoint") == nil then
            gameUtil.removeNewHint(v)
            needNewHint = false
            for key,value in pairs(activityRecord) do
                if value.activityId == tostring(itemID) then 
                    if value.read ~= true then
                        needNewHint = true
                    end
                    break
                end
            end

            if needNewHint then
                gameUtil.addNewPoint(v)
            else
                gameUtil.removeNewPoint(v)
            end
        end
    end
end

function ActivityWFBaseLayer:checkActivityRedPoint( ActTypeName , checkActivityId)
    local activityInfo = json.decode(mm.data.activityInfo)
    local activityInfoRes = INITLUA:getActivtyListRes()
    local activityTypeRes = INITLUA:getActivtyTypeRes()
    local activityTypeChildRes = INITLUA:getActivityTypeChildRes()
    local activityRecord = json.decode(mm.data.activityRecord)
    -- local needRedPoint = false

    for k,v in pairs(activityInfo) do
        local activityId = tonumber(v.activityId)
        if activityId == checkActivityId then
            local activity = activityInfoRes[activityId]
            local activityType = activityTypeRes[activity.ActID]

            for recordKey,recordValue in pairs(activityRecord) do
                local recordId = tonumber(recordValue.activityId)
                if recordId == activityId then
                    local finishCondition = activity.finish
                    if finishCondition == MM.Efinish.Act_null then
                        return false
                    end
                    --------------------------目前只考虑限制条件1-----------------------------
                    local targetValue1 = activity.ActCondition1
                    
                    for targetKey,targetValue in pairs(targetValue1) do
                        if recordValue.value >= targetValue then
                            local find = ""
                            if recordValue.reward then
                                for key,value in pairs(recordValue.reward) do
                                    for reKey,reValue in pairs(value) do
                                        if reKey == tostring(targetValue) then
                                            find = reValue
                                            break
                                        end
                                    end
                                    if find ~= "" then
                                        break
                                    end
                                end
                            end
                            if find == "" or find ~= "fuckTrue" then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

return ActivityWFBaseLayer
