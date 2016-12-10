local ShouChongLayer = class("ShouChongLayer", require("app.views.mmExtend.LayerBase"))
ShouChongLayer.RESOURCE_FILENAME = "Huodong_teshu2.csb"

local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")

function ShouChongLayer:onEnter()
    --self:init()

    mm.req("getActivityInfo",{type=0})
end

function ShouChongLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function ShouChongLayer:onExit()
    
end

function ShouChongLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ShouChongLayer:init(param)
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
   
    local heroId = "L005"
    if mm.data.playerinfo.camp == 2 then
        heroId = "D005"
    end
    heroid = util.getNumFormChar(heroId, 4)
    local HeroRes = gameUtil.getHeroTab( heroid )
    local res = HeroRes.Src

    local heroNode = topNode:getChildByName("Panel_1"):getChildByName("Node_2")
    local skeletonNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    skeletonNode:setScale(1.5)

    local heroScale = 1.0
    local height = topNode:getContentSize().height
    local posY = heroNode:getPositionY()
    local temp = height - posY
    local heroHeight = 300
    heroScale = temp/heroHeight
    
    --skeletonNode:setPosition(topNode:getContentSize().width * 0.25, topNode:getContentSize().height * 0.2)
    skeletonNode:update(0.012)
    skeletonNode:setAnimation(0, "stand", true)
    skeletonNode:setScale(heroScale)
    skeletonNode:setName("Hero")
    heroNode:addChild(skeletonNode)

    local skillId = HeroRes.Skills[1]
    local skillRes = gameUtil.getHeroSkillTab( skillId )
    local skillIconRes = skillRes.sicon
    local skillIconNode = topNode:getChildByName("Node_1")
    local skillImageView = ccui.ImageView:create()
    skillImageView:loadTexture(skillIconRes..".png")
    skillIconNode:addChild(skillImageView)

    topNode:getChildByName("Text_2"):setString(skillRes.Name)
    topNode:getChildByName("Text_2_0"):setString(skillRes.Desc)

    topNode:getChildByName("Panel_1"):getChildByName("Image_13"):getChildByName("Text_9"):setString(HeroRes.Name)

    local itemNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_18")


    self.opButton = self.Node:getChildByName("Image_bg"):getChildByName("Button_2")
    self.opButton:addTouchEventListener(handler(self, self.opButtonCbk))
    gameUtil.setBtnEffect(self.opButton)

    self:updateUI()  
end

function ShouChongLayer:updateUI( )
    local itemNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_18")
    local ListView = itemNode:getChildByName("ListView_1")
    ListView:removeAllItems()
    
    local record = json.decode(mm.data.activityRecord)
    
    self.status = "chongzhi"

   
    local activityInfoRes = INITLUA:getActivtyListRes()
    local activityId = tonumber(self.activityId)
    local activityInfo = activityInfoRes[activityId]

    local finishCondition = activityInfo.finish

    if finishCondition == 0 then
        finishCondition = activityInfo.Buff
    end
    --------------------------目前只考虑限制条件1-----------------------------
    local targetValue1 = activityInfo.ActCondition1[1]

    for k,v in pairs(record) do
        if v.activityId == self.activityId then
            if v.reward ~= nil and #v.reward > 0 then
                for key,value in pairs(v.reward) do
                    for reKey,reValue in pairs(value) do
                        if reKey == tostring(targetValue1) then
                            if reValue == "fuckTrue" then
                                self.opButton:setVisible(false)
                                self.status = "null"
                            else
                                if v.value >= targetValue1 then 
                                    self.opButton:setTitleText("领取")
                                    self.status = "lingqu"
                                else
                                    self.opButton:setTitleText("充值")
                                    self.status = "chongzhi"
                                end
                            end
                            break
                        end
                    end
                end
            else
                if v.value >= targetValue1 then 
                    self.opButton:setTitleText("领取")
                    self.status = "lingqu"
                else
                    self.opButton:setTitleText("充值")
                    self.status = "chongzhi"
                end
            end
        end
    end

    local exsitActivity = false
    local currentInfo = json.decode(mm.data.activityInfo)
    for k,v in pairs(currentInfo) do
        if v.activityId == self.activityId then
            exsitActivity = true
            break
        end
    end
    if exsitActivity == false then
        self.opButton:setVisible(false)
        self.status = "null"
    end

    local activtyRewardRes = INITLUA:getActivtyRewardRes()
    local reward = {}
    local rewardID = activityInfo.Act_GiftType
    for k,v in pairs(activtyRewardRes) do
        if v.RewardGroupID == rewardID and v.ActR_Lv == 1 then
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

    local srcMoneyNode = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_0_0")
    srcMoneyNode:setString(srcMoney)

    local srcMoneyNodeX = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_1")
    srcMoneyNodeX:setString("原价:")

    local srcMoneyNodeY = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_1_1")
    srcMoneyNodeY:setString("现价:充值任意金额免费领取")

    if self.status == "null" then
        local refreshTime = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_1_0")
        refreshTime:stopActionByTag(9999)
        refreshTime:setString("")
        self.opButton:setVisible(false)
    else
        if activityInfo.continueTime == 0 then
            local refreshTime = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_1_0")
            refreshTime:setString("")
            -- self.opButton:setVisible(false)
            return
        end
        local serverOpenTime = os.time()
        for k,v in pairs(game.severList) do
            if v.Areaid == tostring(mm.data.playerinfo.qufu) then
                serverOpenTime = tonumber(v.openTime)
                break
            end
        end
        if self.status == "chongzhi" then
            local time = 0
            if activityInfo ~= nil then
                local serverDate = serverOpenTime
                local cycleTime = tonumber(activityInfo.cycleTime)
                local workTime = tonumber(activityInfo.workTime)
                local continueTime = tonumber(activityInfo.continueTime)
                local currentTime = os.time()
                
                time = serverDate + cycleTime * 24 * 3600 + workTime + continueTime - currentTime
                if time <= 0 then
                    time = 0
                end
            end
            local refreshTime = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_1_0")
            local timeStr = self:getTime(time)
            refreshTime:setString("活动剩余时间: "..timeStr)

            local function countTime( ... )
                time = time - 1
                timeStr = self:getTime(time)
                refreshTime:setString("活动剩余时间: "..timeStr)

                if time <= 0 then 
                    self.opButton:setVisible(false)
                else
                    self.opButton:setVisible(true)
                end
            end
            refreshTime:stopActionByTag(9999)
            local action = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(countTime),cc.DelayTime:create(1)))
            action:setTag(9999)
            refreshTime:runAction(action)
        else
            local time = 0
            if activityInfo ~= nil then
                local serverDate = serverOpenTime
                local cycleTime = tonumber(activityInfo.cycleTime)
                local workTime = tonumber(activityInfo.workTime)
                local rewardTime = tonumber(activityInfo.rewardTime)
                local currentTime = os.time()

                time = serverDate + cycleTime * 24 * 3600 + workTime + rewardTime - currentTime
                if time <= 0 then
                    time = 0
                end
            end
            local refreshTime = self.Node:getChildByName("Image_bg"):getChildByName("Text_2_1_0")
            local timeStr = self:getTime(time)
            refreshTime:setString("领取剩余时间: "..timeStr)

            local function countTime( ... )
                time = time - 1
                timeStr = self:getTime(time)
                refreshTime:setString("领取剩余时间: "..timeStr)

                if time <= 0 then 
                    self.opButton:setVisible(false)
                else
                    self.opButton:setVisible(true)
                end
            end
            refreshTime:stopActionByTag(9999)
            local action = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(countTime),cc.DelayTime:create(1)))
            action:setTag(9999)
            refreshTime:runAction(action)
        end
    end
end

function ShouChongLayer:getTime( time )
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

function ShouChongLayer:globalEventsListener( event )
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


function ShouChongLayer:showItem(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local tag = widget:getTag()
        local itemInfo = {}
        itemInfo.itemID = tag
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

function ShouChongLayer:opButtonCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local record = json.decode(mm.data.activityRecord)
        local recordAC = false
        
        local activityInfo = {}
        local activityTable = json.decode(mm.data.activityInfo)
        for k,v in pairs(activityTable) do
            if v.activityId == self.activityId then
                activityInfo = v
                break
            end
        end

        local activityInfoRes = INITLUA:getActivtyListRes()
        local activityId = tonumber(activityInfo.activityId)
        local activity = activityInfoRes[activityId]

        local finishCondition = activity.finish

        if finishCondition == 0 then
            finishCondition = activity.Buff
        end

        local targetValue1 = activity.ActCondition1[1]

        for k,v in pairs(record) do
            if v.activityId == self.activityId then
                if v.value >= targetValue1 then 
                    mm.req("rewardActivity",{type=1, activityId = self.activityId, conditionValue = targetValue1, actLevel = 1})
                else
                    if gameUtil.isFunctionOpen(closeFuncOrder.RECHARGE_ENTER) == true then
                        local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})
                        local size  = cc.Director:getInstance():getWinSize()
                        self.scene:addChild(PurchaseLayer, MoGlobalZorder[2999999])
                        PurchaseLayer:setContentSize(cc.size(size.width, size.height))
                        ccui.Helper:doLayout(PurchaseLayer)
                    end
                    
                end
                recordAC = true
                break
            end
        end
        if recordAC == false then
            if gameUtil.isFunctionOpen(closeFuncOrder.RECHARGE_ENTER) == true then
                local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})
                local size  = cc.Director:getInstance():getWinSize()
                self.scene:addChild(PurchaseLayer, MoGlobalZorder[2999999])
                PurchaseLayer:setContentSize(cc.size(size.width, size.height))
                ccui.Helper:doLayout(PurchaseLayer)
            end
            
        end
    end
end

function ShouChongLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm:popLayer()
    end
end

return ShouChongLayer
