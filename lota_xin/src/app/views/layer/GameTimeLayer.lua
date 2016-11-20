local GameTimeLayer = class("GameTimeLayer", require("app.views.mmExtend.LayerBase"))
GameTimeLayer.RESOURCE_FILENAME = "Huodong_teshu3.csb"

function GameTimeLayer:onEnter()
    --self:init()

    mm.req("getActivityInfo",{type=0})
end

function GameTimeLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function GameTimeLayer:onExit()
    
end

function GameTimeLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function GameTimeLayer:init(param)
    mm.req("readActivity",{type=0,activityId = tonumber(param.activityId)})
    
    self.activityId = tostring(param.activityId)
    self.scene = param.scene
    self.Node = self:getResourceNode()
    
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    --[[
    if k == "gold" then
        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinbi.png", v)
    elseif k == "diamond" then
        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", v)
    elseif k == "honor" then
        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_rongyu.png", v)--占用
    end
    --]]
    local topNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_9")
   
    local heroId = "L085"
    if mm.data.playerinfo.camp == 2 then
        heroId = "D084"
    end
    heroid = util.getNumFormChar(heroId, 4)
    local HeroRes = gameUtil.getHeroTab( heroid )
    local res = HeroRes.Src

    local heroNode = topNode:getChildByName("Panel_1"):getChildByName("Node_2")
    local skeletonNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)

    local heroScale = 1.0
    local height = topNode:getContentSize().height
    local posY = heroNode:getPositionY()
    local temp = height - posY
    local heroHeight = 300
    heroScale = temp/heroHeight
    
    skeletonNode:update(0.012)
    skeletonNode:setAnimation(0, "stand", true)
    skeletonNode:setScale(1.5)
    skeletonNode:setName("Hero")
    heroNode:addChild(skeletonNode)


    self.opButton = self.Node:getChildByName("Image_bg"):getChildByName("Button_2")
    self.opButton:addTouchEventListener(handler(self, self.opButtonCbk))
    gameUtil.setBtnEffect(self.opButton)

    self:updateUI()  
end

function GameTimeLayer:updateUI( )
    local itemNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_18")
    local ListView = itemNode:getChildByName("ListView_1")
    ListView:removeAllItems()
    local record = json.decode(mm.data.activityRecord)
    
    self.status = "ready"

   
    local activityInfoRes = INITLUA:getActivtyListRes()
    local activityId = tonumber(self.activityId)
    local activityInfo = activityInfoRes[activityId]

    local finishCondition = activityInfo.finish

    if finishCondition == 0 then
        finishCondition = activityInfo.Buff
    end
    --------------------------目前只考虑限制条件1-----------------------------
    local currentRecord = nil
    for k,v in pairs(record) do
        if v.activityId == self.activityId then
            currentRecord = v
        end
    end
    if currentRecord == nil then
        self.opButton:setVisible(true)
        self.opButton:setTitleText("已领完")
        self.status = "finish"
        return
    end

    local targetValue1 = activityInfo.ActCondition1
    local maxIndex = 0
    local maxTempIndex = 0
    local targetTime = nil

    if currentRecord.reward and #currentRecord.reward > 0 then
        for targetKey,targetValue in pairs(targetValue1) do
            maxIndex = maxIndex + 1
            for key,value in pairs(currentRecord.reward) do
                for reKey,reValue in pairs(value) do
                    if reKey == tostring(targetValue) then
                        if reValue == "fuckTrue" then
                            targetTime = targetValue
                            maxTempIndex = maxIndex
                        end
                    end
                end
            end
        end
        if targetTime == nil then
            targetTime = targetValue1[1]
            self.status = "ready"
            maxTempIndex = 1
        elseif maxTempIndex >= maxIndex then
            targetTime = targetValue1[maxIndex]
            self.status = "finish"
            maxTempIndex = maxIndex
        else
            maxTempIndex = maxTempIndex + 1
            targetTime = targetValue1[maxTempIndex]
            self.status = "ready"
        end
    else
        maxTempIndex = 1
        targetTime = targetValue1[1]
        self.status = "ready"
    end


    if self.status == "finish" then
        self.opButton:setVisible(true)
        self.opButton:setTitleText("已领完")
    else
        self.opButton:setVisible(true)
        self.opButton:setTitleText("领取")
    end

    local reward = {}
    local rewardID = activityInfo.Act_GiftType
    local index = maxTempIndex  ---------------------------------------------当前level------------------------------------

    local activtyRewardRes = INITLUA:getActivtyRewardRes()
    for k,v in pairs(activtyRewardRes) do
        if v.RewardGroupID == rewardID and index == v.ActR_Lv then
            reward = v
            break
        end
    end
    
    local num = -1
    local width = 120
    local height = (itemNode:getContentSize().height - 84) * 0.5

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
                size.width = size.width * 1.3
                custom_item:setContentSize(size)
                custom_item:setTouchEnabled(true)
                custom_item:addTouchEventListener(handler(self, self.showItem))
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
                size.width = size.width * 1.3
                custom_item:setContentSize(size)
                custom_item:setTouchEnabled(true)
                custom_item:addTouchEventListener(handler(self, self.showItem))
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
                size.width = size.width * 1.3
                custom_item:setContentSize(size)
                custom_item:setTouchEnabled(true)
                custom_item:addTouchEventListener(handler(self, self.showItem))
                ListView:pushBackCustomItem(custom_item)
            end
        end
    end

    if reward.Act_Gold > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinbi.png", reward.Act_Gold)
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.3
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    if reward.Act_Diamond > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", reward.Act_Diamond)
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.3
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end
    if reward.Act_Honors > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_rongyu.png", reward.Act_Honors)--占用
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.3
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    if reward.Act_SkillPoint > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinengdian.png", reward.Act_SkillPoint)--占用
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.3
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    if reward.Act_GoldFingerTimes > 0 then
        local currentItem = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinshouzhi.png", reward.Act_GoldFingerTimes)--占用
        currentItem:setAnchorPoint(cc.p(0.0,0.0))
        local custom_item = ccui.Layout:create()

        custom_item:addChild(currentItem)
        local size = currentItem:getContentSize()
        size.width = size.width * 1.3
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end

    local sundryRes = INITLUA:getSundryRes()
    local srcMoney = sundryRes[1093677105].Value

    local titleText = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_1_1")
    titleText:setString("游戏时间奖励")

    local gameTitleText = self.Node:getChildByName("Image_bg"):getChildByName("Image_9"):getChildByName("Text_2")
    local minTime = math.floor(targetTime / 60)
    gameTitleText:setString("游戏"..minTime.."分钟")

    local gameTimeText = self.Node:getChildByName("Image_bg"):getChildByName("Image_9"):getChildByName("Text_4")

    local time = targetTime - (os.time() - currentRecord.value)
    local timeStr = self:getTime(time)
    gameTimeText:setString("("..timeStr..")")

    local function countTime( ... )
        time = time - 1
        if time <= 0 then
            self.opButton:setBright(true)
        else
            self.opButton:setBright(false)
        end
        timeStr = self:getTime(time)
        gameTimeText:setString("("..timeStr..")")
    end
    gameTimeText:stopActionByTag(9999)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(countTime),cc.DelayTime:create(1)))
    action:setTag(9999)
    gameTimeText:runAction(action)

end

function GameTimeLayer:getTime( time )
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

function GameTimeLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getActivityInfo" then
            if event.t.type == 0 then
                mm.data.activityInfo = event.t.activityInfo
                mm.data.activityRecord = event.t.activityRecord
                mm.data.publicActivityExtraInfo = event.t.publicActivityExtraInfo
                self:updateUI()
            end
        elseif event.code == "rewardActivity" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                mm.data.activityInfo = event.t.activityInfo
                mm.data.activityRecord = event.t.activityRecord
                mm.data.publicActivityExtraInfo = event.t.publicActivityExtraInfo
                self:updateUI()
                --event.t.conditionValue
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "领取完成", z = 999999})
            else
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "领取失败", z = 999999})
                --mm:popLayer()
            end
        end
    end
end

function GameTimeLayer:showItem(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local tag = widget:getTag()
        local itemInfo = {}
        itemInfo.itemID = tag
        itemInfo.itemType = widget.itemType

        local windowLayer = require("src.app.views.layer.ItemWindow").new({param = itemInfo})
        local size  = cc.Director:getInstance():getWinSize()

        self.scene:addChild(windowLayer, 999999)
        windowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(windowLayer)
    end
end

function GameTimeLayer:opButtonCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local record = json.decode(mm.data.activityRecord)

        local activityInfoRes = INITLUA:getActivtyListRes()
        local activityId = tonumber(self.activityId)
        local activityInfo = activityInfoRes[activityId]

        local finishCondition = activityInfo.finish

        if finishCondition == 0 then
            finishCondition = activityInfo.Buff
        end

        local currentRecord = nil
        for k,v in pairs(record) do
            if v.activityId == self.activityId then
                currentRecord = v
            end
        end
        if currentRecord == nil then
            return
        end
        --------------------------目前只考虑限制条件1-----------------------------
        local targetValue1 = activityInfo.ActCondition1
        local maxIndex = 0
        local maxTempIndex = 0
        local targetTime = nil
        if currentRecord.reward and #currentRecord.reward > 0 then
            for targetKey,targetValue in pairs(targetValue1) do
                maxIndex = maxIndex + 1
                for key,value in pairs(currentRecord.reward) do
                    for reKey,reValue in pairs(value) do
                        if reKey == tostring(targetValue) then
                            if reValue == "fuckTrue" then
                                targetTime = targetValue
                                maxTempIndex = maxIndex
                            end
                        end
                    end
                end
            end
            if targetTime == nil then
                targetTime = targetValue1[1]
                self.status = "ready"
                maxTempIndex = 1
            elseif maxTempIndex >= maxIndex then
                targetTime = targetValue1[maxIndex]
                self.status = "finish"
                maxTempIndex = nil
            else
                maxTempIndex = maxTempIndex + 1
                targetTime = targetValue1[maxTempIndex]
                self.status = "ready"
            end
        else
            maxTempIndex = 1
            targetTime = targetValue1[1]
            self.status = "ready"
        end

        if self.status == "finish" then
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "已领取完成 不需要再领取", z = 999999})
        else
            local gameTime = os.time() - currentRecord.value
            if gameTime >= targetTime then
                mm.req("rewardActivity",{type=1, activityId = self.activityId, conditionValue = targetTime, actLevel = maxTempIndex})
            else
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "游戏时间未达到！", z = 999999})
            end
        end
    end
end

function GameTimeLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm:popLayer()
    end
end

return GameTimeLayer
