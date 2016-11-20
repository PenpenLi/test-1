local ActivityMGBaseLayer = class("ActivityMGBaseLayer", require("app.views.mmExtend.LayerBase"))
ActivityMGBaseLayer.RESOURCE_FILENAME = "Huodong_changguidi.csb"

function ActivityMGBaseLayer:onEnter()
    --self:init()

    mm.req("getActivityInfo",{type=0})
end

function ActivityMGBaseLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function ActivityMGBaseLayer:onExit()
    
end

function ActivityMGBaseLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ActivityMGBaseLayer:init(param)
    self.scene = param.scene
    self.childId = param.childId
    self.Node = self:getResourceNode()
    
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self.baseLayer = cc.CSLoader:createNode("Huodong_changgui_4.csb")
    self:addChild(self.baseLayer)
    local size  = cc.Director:getInstance():getWinSize()
    self.baseLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.baseLayer)

    self:initTopListView()
    self:updateUI()  
end

function ActivityMGBaseLayer:getTime( time )
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

function ActivityMGBaseLayer:getTaskProgress( activity )
    for k,v in pairs(self.activityRecord) do
        if v.activityId == tostring(activity.ID) then
            return v.value
        end
    end
    return 0
end

function ActivityMGBaseLayer:getItem( activity, targetValue1, index )
    local aProgress = self:getTaskProgress( activity )
    local taskItem = nil

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
    local isFinished = false
    if activity.finish == MM.Efinish.Act_FightTop then
        local serverOpenTime = os.time()
        for k,v in pairs(game.severList) do
            if v.Areaid == tostring(mm.data.playerinfo.qufu) then
                serverOpenTime = tonumber(v.openTime)
                break
            end
        end

        local time = 0
        local serverDate = serverOpenTime
        local cycleTime = tonumber(activity.cycleTime)
        local workTime = tonumber(activity.workTime)
        local continueTime = tonumber(activity.continueTime)
        local currentTime = os.time()
        time = serverDate + cycleTime * 24 * 3600 + workTime + continueTime - currentTime
        if time <= 0 then
            if index >= 4 then
                local limitNum = activity.ActCondition1[index + 1] 
                if aProgress >= targetValue1 and aProgress < limitNum then
                    isFinished = true
                else
                    isFinished = false
                end
            elseif aProgress == targetValue1 then
                isFinished = true
            else
                isFinished = false
            end
        else
            isFinished = false
        end
    else
        isFinished = aProgress >= targetValue1
    end
    

    if isFinished then
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
        if reward == nil or reward.ActButton == "" or reward.ActButton == nil then
            local button = taskItem:getChildByName("Button_1")
            button:setContentSize(cc.size(150,70))
            -- button:setScale(0.5)
            button:setVisible(false)
            button:setTitleText("")
        else
            local button = taskItem:getChildByName("Button_1")
            button:setContentSize(cc.size(150,70))
            -- button:setScale(0.5)
            button:setVisible(true)
            button:setTitleText(reward.ActButton)
            button:setTouchEnabled(false)
        end

        local targetValue1Str = gameUtil.dealNumberShort( targetValue1 )
        local aProgressStr = gameUtil.dealNumberShort( aProgress )
        taskItem:getChildByName("Text_lingqu"):setString(aProgressStr.."/"..targetValue1Str)

        status = "progress"
    end
    taskItem:setTag(targetValue1)

    -- local rootNode = taskItem:getChildByName("Image_bg")
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

    local ListView = self.baseLayer:getChildByName("Image_ditu"):getChildByName("ListView")
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
                -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
                -- currentItem:setScale(0.6)

                -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)

                -- currentItem.itemType = 2
                -- currentItem.itemID = itemID
                -- currentItem.itemNum = itemNum
                -- currentItem.listView = ListView

                -- currentItem:setSwallowTouches(false)
                -- currentItem:setTouchEnabled(true)
                -- currentItem:addTouchEventListener(handler(self, self.itemClick))

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
                -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
                -- currentItem:setScale(0.6)

                -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)

                -- currentItem.itemType = 0
                -- currentItem.itemID = itemID
                -- currentItem.itemNum = itemNum
                -- currentItem.listView = ListView

                -- currentItem:setSwallowTouches(false)
                -- currentItem:setTouchEnabled(true)
                -- currentItem:addTouchEventListener(handler(self, self.itemClick))
                -- rootNode:addChild(currentItem)

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

                cellNum = cellNum + 1
                local currentItem = gameUtil.createEquipItem(itemID , itemNum)
                -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
                -- currentItem:setScale(0.6)

                -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)

                -- currentItem.itemType = 0
                -- currentItem.itemID = itemID
                -- currentItem.itemNum = itemNum
                -- currentItem.listView = ListView

                -- currentItem:setSwallowTouches(false)
                -- currentItem:setTouchEnabled(true)
                -- currentItem:addTouchEventListener(handler(self, self.itemClick))
                -- rootNode:addChild(currentItem)

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
        -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
        -- currentItem:setScale(0.6)

        -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)

        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item2:setContentSize(size)
    end

    if reward.Act_Diamond > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", reward.Act_Diamond)
        -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
        -- currentItem:setScale(0.6)

        -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item3:setContentSize(size)
    end

    if reward.Act_Honors > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_rongyu.png", reward.Act_Honors)--占用
       -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
        -- currentItem:setScale(0.6)

        -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item4:setContentSize(size)
    end

    if reward.Act_SkillPoint > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinengdian.png", reward.Act_SkillPoint)--占用
        -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
        -- currentItem:setScale(0.6)

        -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
        itemIndex = itemIndex + 1
        local itemBGTemp = itemBGList[itemIndex]
        itemBGTemp:setVisible(true)
        itemBGTemp:addChild(currentItem)
        -- local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        -- item5:setContentSize(size)
    end

    if reward.Act_GoldFingerTimes > 0 then
        cellNum = cellNum + 1
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinshouzhi.png", reward.Act_GoldFingerTimes)--占用
        -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
        -- currentItem:setScale(0.6)

        -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
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
            -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
            currentItem:setScale(1.3)

            -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
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
            -- currentItem:setAnchorPoint(cc.p(0.5,0.5))
            currentItem:setScale(1.3)

            -- currentItem:setPosition(itemBgX + (itemWidth * cellNum), itemBgY)
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


    -- rootNode:setTouchEnabled(false)
    taskItem:setSwallowTouches(false)

    return taskItem, status
end

function ActivityMGBaseLayer:itemClick(widget,touchkey)
    if touchkey == ccui.TouchEventType.began then
        local listView = widget.listView
        if listView then
            local pos = listView:getInnerContainerPosition()
            widget.pY = pos.y
        end
    elseif touchkey == ccui.TouchEventType.ended then
        local listView = widget.listView
        if listView then
            local pos = listView:getInnerContainerPosition()
            local deltaY = math.abs(widget.pY - pos.y)
            if deltaY > 25 then
                return
            end

            local tag = widget:getTag()
            local itemInfo = {}
            itemInfo.itemID = widget.itemID
            itemInfo.itemType = widget.itemType
            local windowLayer = require("src.app.views.layer.ItemWindow").new({param = itemInfo})
            local size  = cc.Director:getInstance():getWinSize()
            self.scene:addChild(windowLayer, MoGlobalZorder[2999999])
            windowLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(windowLayer)
        end
    end
end

function ActivityMGBaseLayer:initTopListView()
    self.topListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_shang"):getChildByName("ListView_Hero")

    local activityInfo = json.decode(mm.data.activityInfo)
    local activityInfoRes = INITLUA:getActivtyListRes()
    local activityTypeRes = INITLUA:getActivtyTypeRes()

    self.currentActivityList = {}
    for k,v in pairs(activityInfo) do
        local activityId = tonumber(v.activityId)
        local activity = activityInfoRes[activityId]
        local activityType = activityTypeRes[activity.ActID]

        if activityType.ActTypeName == "Merge" then
            table.insert(self.currentActivityList, activity)
        end
    end

    self.topListView:removeAllItems()
    self.currentId = nil

    for k,v in pairs(self.currentActivityList) do
        local custom_item = ccui.Layout:create()
        local iconPath = "icon/jiemian/"..v.activityIcon..".png"
        local Image_icon = self:createTopIcon(iconPath)
        -- if self.currentId == nil and v.activityTypeChild == self.childId then
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

function ActivityMGBaseLayer:updateActivity( widget, activityId )
    mm.req("readActivity",{type=0,activityId = tonumber(activityId)})

    self.currentId = tostring(activityId)
    self.selectHeroKuang:removeFromParent()

    self.selectHeroKuang = ccui.ImageView:create()
    self.selectHeroKuang:loadTexture("res/UI/jm_hero_select.png")
    self.selectHeroKuang:setPosition(widget:getContentSize().width/2, widget:getContentSize().height/2)
    widget:addChild(self.selectHeroKuang)

    -- self:initTopListView()
    self:updateUI()
end

function ActivityMGBaseLayer:updateActivityClick(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local activityId = widget:getTag()
        self:updateActivity( widget, activityId )
    end
end

function ActivityMGBaseLayer:createTopIcon( path )
    local Image_icon = ccui.ImageView:create()
    -- Image_icon:setName("TouXiang")
    Image_icon:loadTexture(path)
    Image_icon:setAnchorPoint(cc.p(0, 0))
    return Image_icon
end

function ActivityMGBaseLayer:updateUI( )
    local ListView = self.baseLayer:getChildByName("Image_ditu"):getChildByName("ListView")
    ListView:removeAllItems()

    self.activityRecord = json.decode(mm.data.activityRecord)
    
    local activtyListRes = INITLUA:getActivtyListRes()
    local index = tonumber(self.currentId)
    local activity = activtyListRes[index]

    local finishCondition = activity.finish

    if finishCondition == 0 then
        finishCondition = activity.Buff
    end
    --------------------------目前只考虑限制条件1-----------------------------
    local targetValue1 = activity.ActCondition1
    -- Act_FightTop
    local totalNum = 0
    local firstReward = 0

    for k,v in pairs(targetValue1) do
        if activity.finish == MM.Efinish.Act_FightTop then
            if k == #targetValue1 then
                break
            end
        end
        local currentItem, status = self:getItem( activity, v, k)
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        custom_item:setTag(v)
        custom_item.actLevel = k
        custom_item:setTouchEnabled(true)

		currentItem.targetValue = v
        currentItem.actLevel = k
        
        totalNum = totalNum + 1
        if status == "reward" then
            currentItem:addTouchEventListener(handler(self, self.getRewardCbk))
            if firstReward == 0 then
                firstReward = totalNum
            end
        elseif status == "progress" then
            currentItem:addTouchEventListener(handler(self, self.jumpTo))
        end

        local size = currentItem:getContentSize()
        -- size.width = size.width * 1.3
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    local serverOpenTime = os.time()
    for k,v in pairs(game.severList) do
        if v.Areaid == tostring(mm.data.playerinfo.qufu) then
            serverOpenTime = tonumber(v.openTime)
            break
        end
    end

    local time = 0
    if activity ~= nil then
        local serverDate = serverOpenTime
        local cycleTime = tonumber(activity.cycleTime)
        local workTime = tonumber(activity.workTime)
        local continueTime = tonumber(activity.continueTime)
        local currentTime = os.time()
        time = serverDate + cycleTime * 24 * 3600 + workTime + continueTime - currentTime
        if time <= 0 then
            time = 0
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
        local serverDate = serverOpenTime
        local cycleTime = tonumber(activity.cycleTime)
        local workTime = tonumber(activity.workTime)
        local rewardTime = tonumber(activity.rewardTime)
        local currentTime = os.time()
        
        timeReward = serverDate + cycleTime * 24 * 3600 + workTime + rewardTime - currentTime
        if timeReward <= 0 then
            timeReward = 0
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
end

function ActivityMGBaseLayer:getTime( time )
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

function ActivityMGBaseLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getActivityInfo" then
            if event.t.type == 0 then
                mm.data.activityInfo = event.t.activityInfo
                mm.data.activityRecord = event.t.activityRecord
                mm.data.publicActivityExtraInfo = event.t.publicActivityExtraInfo

                self:updateUI()
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
                self:updateTopView()

                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "领取完成", z = 999999})
            else
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "领取失败", z = 999999})
                --mm:popLayer()
            end
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

function ActivityMGBaseLayer:getRewardCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local targetValue = widget.targetValue
        local actLevel = widget.actLevel
        mm.req("rewardActivity",{type=1, activityId = self.currentId, conditionValue = targetValue, actLevel = actLevel})
    end
end

function ActivityMGBaseLayer:jumpTo(widget,touchkey)
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
            -- mm.popLayer()
            -- self:removeFromParent()
        end
    end
end

function ActivityMGBaseLayer:updateTopView()
    local items = self.topListView:getItems()
    for k,v in pairs(items) do
        local itemID = v:getTag()
        local ActTypeName = "Merge"
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
                -- self.wonderfulActivityBtn:addChild(newHint)
            else
                gameUtil.removeNewPoint(v)
            end
        end
    end
end

function ActivityMGBaseLayer:checkActivityRedPoint( ActTypeName , checkActivityId)
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
                    if finishCondition == 0 then
                        finishCondition = activity.Buff
                    end

                    --------------------------目前只考虑限制条件1-----------------------------
                    local targetValue1 = activity.ActCondition1
                    
                    --------战力排行特殊处理---------
                    local isFinished = false
                    if activity.finish == MM.Efinish.Act_FightTop then
                        local serverOpenTime = os.time()
                        for k,v in pairs(game.severList) do
                            if v.Areaid == tostring(mm.data.playerinfo.qufu) then
                                serverOpenTime = tonumber(v.openTime)
                                break
                            end
                        end
                        
                        local time = 0
                        local serverDate = serverOpenTime
                        local cycleTime = tonumber(activity.cycleTime)
                        local workTime = tonumber(activity.workTime)
                        local continueTime = tonumber(activity.continueTime)
                        local currentTime = os.time()
                        time = serverDate + cycleTime * 24 * 3600 + workTime + continueTime - currentTime
                        if time <= 0 then
                            for k,v in pairs(targetValue1) do
                                if k == #targetValue1 then
                                    break
                                end
                                local targetNum = targetValue1[k]
                                if k >= 4 then
                                    local aProgress = recordValue.value
                                    local limitNum = targetValue1[k + 1] 
                                    if aProgress >= targetNum and aProgress < limitNum then
                                        local find = ""
                                        if recordValue.reward then
                                            for key,value in pairs(recordValue.reward) do
                                                for reKey,reValue in pairs(value) do
                                                    if reKey == tostring(targetNum) then
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
                                elseif aProgress == targetNum then
                                    local find = ""
                                    if recordValue.reward then
                                        for key,value in pairs(recordValue.reward) do
                                            for reKey,reValue in pairs(value) do
                                                if reKey == tostring(targetNum) then
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
                        return false
                    end

                    -------------------------------普通处理------------------------
                    
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

function ActivityMGBaseLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm:popLayer()
    end
end

return ActivityMGBaseLayer
