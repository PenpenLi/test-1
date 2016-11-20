-- Melee ['melei] 乱斗界面

local fight = require("app.fight.Fight")

local MeleeScene = class("MeleeScene", cc.load("mvc").ViewBase)
MeleeScene.RESOURCE_FILENAME = "Daluandou.csb"

local text_name
local text_zhanli
local text_killNum

function MeleeScene:onCreate(param)
    self.app_ = mm.app
    self.time = param.time
    mm.data.time.serverTime = param.serverTime
    self.campKillNum = param.campKillNum
    self.meleeKillNum = param.meleeKillNum
    self.autoShowFinalResult = param.autoShowFinalResult
    self.meleeStatus = param.meleeStatus

    self.scene = self:getChildByName("Scene")
    self.singleMeleeEnd = true

    self.paneldi = cc.CSLoader:createNode("Daluandoudi.csb")
    self:addChild(self.paneldi, MoGlobalZorder[2000003])
    self:addBarrageLayer()

    local image_1 = self.paneldi:getChildByName("Image_01"):getChildByName("Image_1")
    text_name = image_1:getChildByName("Text_1")
    text_zhanli = image_1:getChildByName("Text_1_0")
    text_killNum = self.scene:getChildByName("Text_killNum")

    -- 钻石
    self.diamondText = self.scene:getChildByName("zuanshitext")

    self:updateDi()
    self.talkBtn = self.paneldi:getChildByName("liaotianbtn")
    gameUtil.setBtnEffect(self.talkBtn)
    self.talkBtn:addTouchEventListener(handler(self, self.talkBtnCbk))

    self.scene:getChildByName("Text_next_kaishi1"):setVisible(false)
    self.scene:getChildByName("Text_next_kaishi"):setVisible(false)

    mm.data.time.meleeTime = self.time

    self.meleeBtn = self.scene:getChildByName("Button_melee")
    self.meleeBtn:addTouchEventListener(handler(self, self.meleeBtnCbk))
    gameUtil.setBtnEffect(self.meleeBtn)

    self.rankBtn = self.scene:getChildByName("Image_duanwei")
    self.rankBtn:setTouchEnabled(true)
    self.rankBtn:addTouchEventListener(handler(self, self.rankBtnCbk))

    self.rankBtn = self.scene:getChildByName("Node_duanwei")
    -- 添加排行榜特效
    -- gameUtil.addArmatureFile("res/Effect/uiEffect/phb/phb.ExportJson")
    -- local item_play = ccs.Armature:create("phb")
    -- local duanwei = ccs.Skin:create("res/icon/jiemian/bt_paihang.png")
    -- local text_bone = item_play:getBone("phb")
    -- text_bone:addDisplay(duanwei, 0)
    -- self.rankBtn:addChild(item_play, 10)
    -- item_play:getAnimation():playWithIndex(0)

    local item_play = gameUtil.createSkeAnmion( {name = "phb",scale = 1} )
    item_play:setAnimation(0, "stand", true)
    self.rankBtn:addChild(item_play, 10)

    schedule(self, function()
        if mm.data.time.meleeTime > 0 then
            self.scene:getChildByName("Text_next_kaishi1"):setString(util.timeFmt(mm.data.time.meleeTime))
            self.scene:getChildByName("Text_next_kaishi1"):setVisible(true)
            self.scene:getChildByName("Text_next_kaishi"):setVisible(true)
        else
            self.scene:getChildByName("Text_next_kaishi1"):setVisible(false)
            self.scene:getChildByName("Text_next_kaishi"):setVisible(false)
        end

        if self.meleeStatus == 2 then
            self.scene:getChildByName("Text_next_kaishi"):setString("乱斗进行中")
        else
            self.scene:getChildByName("Text_next_kaishi"):setString("离乱斗开启")
        end
        if self.joinMeleeRewardTime then
            if self.joinMeleeRewardTime == 0 then
                self.joinMeleeRewardTime = nil
                -- 弹出参战奖励页面
                local JoinMeleeRewardLayer = require("src.app.views.layer.JoinMeleeRewardLayer").new({dropTab = self.dropTab, dropResID = self.dropResID, addKillNum = self.addKillNum})
                self:addChild(JoinMeleeRewardLayer, MoGlobalZorder[2999999])
                local size  = cc.Director:getInstance():getWinSize()
                JoinMeleeRewardLayer:setContentSize(cc.size(size.width, size.height))
                ccui.Helper:doLayout(JoinMeleeRewardLayer)
            else
                self.joinMeleeRewardTime = self.joinMeleeRewardTime - 1
            end
        end
    end, 1)

    self.storeBtn = self.scene:getChildByName("Button_8")
    self.storeBtn:addTouchEventListener(handler(self, self.storeBtnCbk))
    gameUtil.setBtnEffect(self.storeBtn)

    self.blessBtn = self.scene:getChildByName("Button_zhufu")
    self.blessBtn:addTouchEventListener(handler(self, self.blessBtnCbk))
    gameUtil.setBtnEffect(self.blessBtn)

    self.blessEndBtn = self.scene:getChildByName("Button_zhufu1")
    self.blessEndBtn:addTouchEventListener(handler(self, self.blessBtnCbk))
    gameUtil.setBtnEffect(self.blessEndBtn)
    
    self.joinFightBtn = self.scene:getChildByName("Button_zhandou")
    self.joinFightBtn:addTouchEventListener(handler(self, self.joinFightBtnCbk))
    gameUtil.setBtnEffect(self.joinFightBtn)

    self.joinFightWaitBtn = self.scene:getChildByName("Button_zhandou1")
    self.joinFightWaitBtn:addTouchEventListener(handler(self, self.joinFightWaitBtnCbk))
    gameUtil.setBtnEffect(self.joinFightWaitBtn)

    self.scene:getChildByName("Panel_right"):addTouchEventListener(handler(self, self.jinshouzhiBtnCbk))
    self.scene:getChildByName("Panel_right"):setTouchEnabled(true)

    self.scene:getChildByName("Button_tuhao"):addTouchEventListener(handler(self, self.saveTheWorldTemp))
    self.scene:getChildByName("Image_8"):getChildByName("Text_6"):setString(0)

    self.blessText = self.scene:getChildByName("Text_7")
    self.blessText:setString("")
    self.joinFightText = self.scene:getChildByName("Text_8")
    self.joinFightText:setString("")
    
    self:refreshJoinFight()
    self:refreshBless()
    
    self:addTiBu()

    self:reSetUnit()

    self.app_.clientTCP:addEventListener("notifyMeleeEndResult",mm.notifyMeleeEndResult)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

    local showResultBtn = self.paneldi:getChildByName("Button_14")
    showResultBtn:setVisible(false)
    showResultBtn:addTouchEventListener(handler(self, self.showFinalResultCbk))
    gameUtil.setBtnEffect(showResultBtn)


    self:updateUI()

    if self.autoShowFinalResult == 0 and self.meleeStatus ~= 2 then
        self:showFinalResult( nil )
    end
end

function MeleeScene:updateUI( )
    local image_1 = self.paneldi:getChildByName("Image_01"):getChildByName("Image_1")
    local showResultBtn = self.paneldi:getChildByName("Button_14")
    if self.meleeStatus == 2 then
        image_1:setVisible(true)
        showResultBtn:setVisible(false)
    else
        image_1:setVisible(false)
        showResultBtn:setVisible(true)
    end

    local needMoney = nil
    local sundryRes = INITLUA:getSundryRes()
    for k,v in pairs(sundryRes) do
        if v.Namekey == "IHaveMoney" then
            needMoney = v.Value
            break
        end
    end
    if needMoney == nil then
        needMoney = 5000
    end
    self.scene:getChildByName("Image_8"):getChildByName("Text_6"):setString(needMoney)
end

function MeleeScene:refreshJoinFight()
    if self.meleeStatus == 3 or self.meleeStatus == 1 then
        self.joinFightText:setString("00:00:00")
        self.joinFightText:setVisible(false)
        local tempRes = INITLUA:getExchangeByType( MM.EChangeToType.CHANGERTO_luandoucanzhan )
        local needMoney = tempRes[1].ConsumeDiamond
        self.joinFightBtn:setVisible(true)
        self.joinFightWaitBtn:setVisible(false)
        self.scene:getChildByName("Image_6"):getChildByName("Text_6"):setString(needMoney)
        return
    end

    local lastMeleeTime = mm.data.playerExtra.lastMeleeTime
    local reliveTimes = mm.data.playerExtra.reliveTimes
    local meleeTimes = mm.data.playerExtra.meleeTimes
    local noCDStatus = mm.data.playerExtra.noCDStatus
    local noCDTimes = mm.data.playerExtra.noCDTimes
    local noCDStatusMeleeTimes = mm.data.playerExtra.noCDStatusMeleeTimes

    local nextMeleeTimes = reliveTimes + 1
    local sundry = INITLUA:getSundryRes()
    
    local inCDTime = true
    local needCDTime = 0
    local cdInfo = {}
    for k,v in pairs(sundry) do
        if v.Namekey == "meleeCDTime" then
            table.insert(cdInfo, v)
        end
    end

    local function sortRule(a, b)
        return a.Value < b.Value
    end
    table.sort( cdInfo, sortRule )

    if meleeTimes >= #cdInfo then
        local index = #cdInfo
        needCDTime = cdInfo[index].Value
    elseif meleeTimes <= 0 then
        needCDTime = cdInfo[1].Value
    else
        needCDTime = cdInfo[meleeTimes].Value
    end

    local currentTime = mm.data.time.serverTime
    local usedTime = currentTime - lastMeleeTime

    if usedTime >= needCDTime then
        inCDTime = false
    else
        mm.data.time.meleeCDTime = needCDTime - usedTime
    end

    if noCDStatus == 0 and noCDTimes > 0 and noCDStatusMeleeTimes > 0 then
        ------春哥时间------
        self.joinFightText:setString("00:00:00")
        self.joinFightText:setVisible(false)
        self.joinFightBtn:setVisible(true)
        self.joinFightWaitBtn:setVisible(false)
        self.scene:getChildByName("Image_6"):setVisible(false)
    else
        if inCDTime == true then
            self.joinFightText:setVisible(true)
            self.joinFightText:setString("00:00:00")

            schedule(self, function()
                if mm.data.time.meleeCDTime > 0 then
                    self.joinFightText:setString(util.timeFmt(mm.data.time.meleeCDTime))
                else
                    self:refreshJoinFight()
                end
            end, 1)

            self.joinFightBtn:setVisible(false)
            self.joinFightWaitBtn:setVisible(true)

            local needMoney = 0
            local tempRes = INITLUA:getExchangeByType( MM.EChangeToType.CHANGERTO_luandoucanzhan )
            for k,v in pairs(tempRes) do
                if v.Times == nextMeleeTimes then
                    needMoney = v.ConsumeDiamond
                    break
                end
            end

            self.scene:getChildByName("Image_6"):getChildByName("Text_6"):setString(needMoney)
            self.scene:getChildByName("Image_6"):setVisible(true)
        else
            self.joinFightText:setVisible(false)
            self.joinFightBtn:setVisible(true)
            self.joinFightWaitBtn:setVisible(false)
            self.scene:getChildByName("Image_6"):setVisible(false)
        end
    end

    
end

function MeleeScene:refreshBless()
    if self.meleeStatus == 3 or self.meleeStatus == 1 then
        local tempRes = INITLUA:getExchangeByType( MM.EChangeToType.CHANGERTO_luandouzhufu )
        local function sortRule(a, b)
            return a.Times > b.Times
        end
        table.sort( tempRes, sortRule )

        local needMoney = tempRes[1].ConsumeDiamond

        self.blessText:setString("")
        self.blessEndBtn:setVisible(false)
        self.scene:getChildByName("Image_7"):getChildByName("Text_6"):setString(needMoney)
        return
    end

    local currentBlessTimes = mm.data.playerExtra.blessTimes

    if currentBlessTimes == nil then
        currentBlessTimes = 0
    end
    local nextBlessTimes = currentBlessTimes + 1

    local tempRes = INITLUA:getExchangeByType( MM.EChangeToType.CHANGERTO_luandouzhufu )
    local function sortRule(a, b)
        return a.Times > b.Times
    end
    table.sort( tempRes, sortRule )

    local maxTimes = tempRes[1].Times

    if currentBlessTimes >= maxTimes then
        --祝福达到上限
        local blessValue = 0
        for k,v in pairs(tempRes) do
            blessValue = blessValue + v.Fold
        end
        self.blessText:setString(blessValue.."%")
        self.blessBtn:setVisible(false)
        self.blessEndBtn:setVisible(true)
        self.scene:getChildByName("Image_7"):setVisible(false)
        return
    end

    local needMoney = 0
    for k,v in pairs(tempRes) do
        if v.Times == nextBlessTimes then
            needMoney = v.ConsumeDiamond
            break
        end
    end

    local blessValue = gameUtil.getBlessValue( currentBlessTimes )
    self.blessText:setString(blessValue.."%")
    self.blessBtn:setVisible(true)
    self.blessEndBtn:setVisible(false)
    self.scene:getChildByName("Image_7"):getChildByName("Text_6"):setString(needMoney)
    self.scene:getChildByName("Image_7"):setVisible(true)
end

function MeleeScene:reSetUnit(  )
    --A阵营
    for i=1,5 do
        local node = self.scene:getChildByName("a_"..i)
        node:setPosition(mm.unitPosA[i].x, mm.unitPosA[i].y)
    end



    --B阵营
    for i=1,5 do
        local node = self.scene:getChildByName("b_"..i)
        node:setPosition(mm.unitPosB[i].x, mm.unitPosB[i].y)
    end
end

function MeleeScene:showFinalResult( result )
    if result == nil then
        mm.req("getFinalResultData",{type = 0})
        return
    end
    if mm.data.finalResultData == nil then
        mm.req("getFinalResultData",{type = 0})
        return
    end

    -- local status = result.status
    -- local campKillNum = 
    -- local campForce = result.
    -- local playerKillNum = result.
    -- local playerLocalRank = result.
    -- local playerWorldRank = result.

    -- self.paneldi:getChildByName("Button_14"):setVisible(true)
    if self.finalResultUI ~= nil then
        self.finalResultUI:removeFromParent()
        self.finalResultUI = nil
    end

    self.finalResultUI = cc.CSLoader:createNode("Daluandoushengfu.csb")
    self:addChild(self.finalResultUI, MoGlobalZorder[2000009])
    local size  = cc.Director:getInstance():getWinSize()
    self.finalResultUI:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.finalResultUI)

    local infoNode = self.finalResultUI:getChildByName("Image_bg"):getChildByName("Image_bg01")

    local okBtn = self.finalResultUI:getChildByName("Image_bg"):getChildByName("Button_ok")
    local closeBtn = self.finalResultUI:getChildByName("Image_bg"):getChildByName("Button_1")
    okBtn:addTouchEventListener(handler(self, self.closeFinalResultCbk))
    closeBtn:addTouchEventListener(handler(self, self.closeFinalResultCbk))
    gameUtil.setBtnEffect(okBtn)
    gameUtil.setBtnEffect(closeBtn)

    local statusPic = self.finalResultUI:getChildByName("Image_bg"):getChildByName("Image_1")
    if result.status ~= "win" then
        statusPic:loadTexture("res/UI/jm_shibai1.png")
    end
    
    infoNode:getChildByName("Text_2"):setString(result.campKillNum)
    infoNode:getChildByName("Text_4"):setString(result.campForce)
    infoNode:getChildByName("Text_6"):setString(result.playerKillNum)
    infoNode:getChildByName("Text_8"):setString(result.playerLocalRank + 1)
    infoNode:getChildByName("Text_10"):setString(result.playerWorldRank + 1)

    self.blessBtn:setVisible(true)
    self.blessEndBtn:setVisible(false)
    
end

function MeleeScene:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getMeleeList" then
            self.meleeList = event.t.direninfo
            self.campForce = event.t.campForce
            self:updateDi()

            if self.isoOnEnter then
                self.isoOnEnter = nil
                local difangInfo = self.meleeList[1]
                self:initFight(difangInfo)
            end
        elseif event.code == "killMelee" then
            if self.meleeStatus ~= 3 and self.meleeStatus ~= 1 then
                self.meleeKillNum = event.t.meleeKillNum
                self.campKillNum = event.t.campKillNum
                self.campForce = event.t.campForce
                self:updateDi()
            end
        elseif event.code == "notifyStatus" then
            self.meleeStatus = event.t.meleeStatus
            mm.data.time.meleeTime = event.t.time
            mm.data.time.serverTime = event.t.serverTime

            if self.meleeStatus == 2 then
                self.meleeKillNum = 0
                self.campKillNum = 0
                self.campForce = 0
                mm.data.playerExtra.blessTimes = 0
            end

            self:updateUI()
            self:refreshBless()
            self:refreshJoinFight()
        elseif event.code == "blessMelee" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                self.campForce = event.t.campForce
                self:updateDi()
            end
            self:refreshBless()
            gameUtil:addTishi( {p = self, s = MoGameRet[event.t.code]})
        elseif event.code == "joinMelee" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                mm.data.time.serverTime = event.t.serverTime

                self.meleeKillNum = event.t.meleeKillNum
                self.campKillNum = event.t.campKillNum
                self.dropTab = event.t.dropTab or {}
                self.dropResID = event.t.dropResID
                self.joinMeleeRewardTime = 3
                self.addKillNum = event.t.addKillNum
                self.campForce = event.t.campForce
                
                self.singleMeleeEnd = false

                self:updateDi()
                self:beginJSZ()
                self:play()
            else
                self.singleMeleeEnd = true
            end
           
            self:refreshJoinFight()
            gameUtil:addTishi( {p = self, s = MoGameRet[event.t.code]})
        elseif event.code == "notifyMeleeEndResult" or event.code == "getFinalResultData" then
            mm.data.finalResultData = event.t
            self:showFinalResult(event.t)
        elseif event.code == "saveTheWorld" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                mm.data.time.serverTime = event.t.serverTime

                self.campForce = event.t.campForce
                self:refreshBless()
                self:refreshJoinFight()
                self:updateDi()
            else
                gameUtil:addTishi( {p = self, s = MoGameRet[event.t.code]})
            end
        end
    end
end

function MeleeScene:onEnter()
    mm.guaJiReward = false
    mm.data.finalResultData = nil

    mm.req("getMeleeList",{getType = 0})
    self.isoOnEnter = true
end

function MeleeScene:onExit()
    
end

function MeleeScene:updateDi()

    text_name:setString("阵营击杀："..self.campKillNum)
    text_killNum:setString("个人击杀："..self.meleeKillNum)
    self.diamondText:setText(gameUtil.dealNumber(mm.data.playerinfo.diamond))
    if self.campForce == nil then
        text_zhanli:setString("")
    else
        text_zhanli:setString("阵营战力："..gameUtil.dealNumber(self.campForce))
    end
end

function MeleeScene:addBarrageLayer() 
    
    local BarrageLayer1 = require("src.app.views.layer.BarrageLayer").new({tag = "MeleeScene"})
    self:addChild(BarrageLayer1, MoGlobalZorder[2999999])
    local size  = cc.Director:getInstance():getWinSize()
    BarrageLayer1:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(BarrageLayer1)
end

function MeleeScene:showSaveTheWorldWindow( )
    if self.saveTheWorldWindow ~= nil then
        self.saveTheWorldWindow:removeFromParent()
        self.saveTheWorldWindow = nil
    end
    self.saveTheWorldWindow = cc.CSLoader:createNode("Querenkuang.csb")
    self:addChild(self.saveTheWorldWindow, MoGlobalZorder[2000002])
    local size  = cc.Director:getInstance():getWinSize()
    self.saveTheWorldWindow:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.saveTheWorldWindow)

    local rootNode = self.saveTheWorldWindow:getChildByName("Image_bg")
    rootNode:getChildByName("Text_time"):setString("是否为全部本阵营玩家提供一次战斗机会（下次参战无CD）？")
    rootNode:getChildByName("Text_2"):setString("土豪救世")
    local noBtn = rootNode:getChildByName("Button_ok")
    noBtn:addTouchEventListener(handler(self, self.closeSaveTheWorldCbk))
    gameUtil.setBtnEffect(noBtn)

    local okBtn = rootNode:getChildByName("Button_6")
    okBtn:addTouchEventListener(handler(self, self.saveTheWorldCbk))
    gameUtil.setBtnEffect(okBtn)
end

function MeleeScene:closeSaveTheWorldCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self.saveTheWorldWindow:removeFromParent()
        self.saveTheWorldWindow = nil
    end
end

function MeleeScene:saveTheWorldCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm.req("saveTheWorld",{type = 0})

        self.saveTheWorldWindow:removeFromParent()
        self.saveTheWorldWindow = nil
    end
end

function MeleeScene:talkBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        local TalkLayer = require("src.app.views.layer.TalkLayer").new(self.app_)
        TalkLayer:setName("TalkLayer")
        local size  = cc.Director:getInstance():getWinSize()
        --mm.pushLayoer( {scene = self, layer = TalkLayer, zord = 2000} )
        self:addChild(TalkLayer, MoGlobalZorder[2000002])
        TalkLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(TalkLayer)
    end
end

function MeleeScene:closeFinalResultCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.finalResultUI then
            self.finalResultUI:removeFromParent()
            self.finalResultUI = nil
        end
    end
end

function MeleeScene:saveTheWorldTemp(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then

        if self.meleeStatus == 3 then
            gameUtil:addTishi( {p = self, s = "活动已经结束"})
            return
        end
        if self.meleeStatus == 1 then
            gameUtil:addTishi( {p = self, s = "活动还未开始"})
            return
        end
        local needMoney = nil
        local sundryRes = INITLUA:getSundryRes()
        for k,v in pairs(sundryRes) do
            if v.Namekey == "IHaveMoney" then
                needMoney = v.Value
                break
            end
        end
        if needMoney == nil then
            needMoney = 5000
        end
        if mm.data.playerinfo.diamond < needMoney then
            gameUtil.showChongZhi(self, 1)
            return
        end
        
        self:showSaveTheWorldWindow()
    end
end

function MeleeScene:showFinalResultCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:showFinalResult(mm.data.finalResultData)
    end
end

function MeleeScene:meleeBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        fight:initNode()
        mm.app:pop()
        self.meleeBtn:setTouchEnabled(false)
    end
end

function MeleeScene:storeBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.LuanDouShangCheng",
                            resName = "LuanDouShangCheng",params = {typeLayer = 1, scene = self}} )
    end
end

function MeleeScene:blessBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then

        if self.meleeStatus == 3 then
            gameUtil:addTishi( {p = self, s = "活动已经结束"})
            return
        end
        if self.meleeStatus == 1 then
            gameUtil:addTishi( {p = self, s = "活动还未开始"})
            return
        end

        mm.req("blessMelee",{type = 0})
    end
end

function MeleeScene:joinFightBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then

        if self.meleeStatus == 3 then
            gameUtil:addTishi( {p = self, s = "活动已经结束"})
            return
        end
        if self.meleeStatus == 1 then
            gameUtil:addTishi( {p = self, s = "活动还未开始"})
            return
        end

        if self.singleMeleeEnd == false then
            gameUtil:addTishi( {p = self, s = "乱斗还在进行中 请稍候"})
            return
        end

        self.singleMeleeEnd = false
        mm.req("joinMelee",{type = 0})
    end
end

function MeleeScene:joinFightWaitBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then

        if self.meleeStatus == 3 then
            gameUtil:addTishi( {p = self, s = "活动已经结束"})
            return
        end
        if self.meleeStatus == 1 then
            gameUtil:addTishi( {p = self, s = "活动还未开始"})
            return
        end

        if self.singleMeleeEnd == false then
            gameUtil:addTishi( {p = self, s = "乱斗还在进行中 请稍候"})
            return
        end
        self.singleMeleeEnd = false
        mm.req("joinMelee",{type = 0})
    end
end

function MeleeScene:rankBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local MeleeRankLayer = require("src.app.views.layer.MeleeRankLayer").new(self.app_)
        MeleeRankLayer:setName("MeleeRankLayer")
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(MeleeRankLayer, MoGlobalZorder[2000002])
        MeleeRankLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(MeleeRankLayer)
    end
end

function MeleeScene:onEnterTransitionFinish()
    
end

function MeleeScene:onExitTransitionStart()
    
end

function MeleeScene:onCleanup()
    self:clearAllGlobalEventListener()
end

function MeleeScene:initFight(difangInfo)
    self.ppp = {}
    self.ppp.x = self.scene:getPositionX()
    self.ppp.y = self.scene:getPositionY()

    local difangForm = difangInfo.playerFormation
    local diZhen = {}
    local f = {}
    for i=1,#difangForm do
        if difangForm[i].type == 1 then
            f = difangForm[i].formationTab
        end
    end
    if f then
        for i=1,#f do
            table.insert(diZhen,f[i].id)
        end
    end

    local allZhanli = 0
    local diplayerHero = difangInfo.playerHero
    for i=1,5 do
        if diZhen[i] then
            if diplayerHero == nil then

            end
            for j=1,#diplayerHero do
                if diZhen[i] == diplayerHero[j].id then
                    local tab = util.copyTab(diplayerHero[j])
                    local zhanli = gameUtil.Zhandouli( tab ,diplayerHero, difangInfo.pkValue)
                    if zhanli then
                        allZhanli = allZhanli + zhanli
                    end
                end
            end
        end
    end

    local currentBlessTimes = mm.data.playerExtra.blessTimes

    local myMeleeTab = {}
    myMeleeTab.zhufuTimes = currentBlessTimes
    myMeleeTab.X = 0.21

    local diMeleeTab = {}
    diMeleeTab.zhufuTimes = currentBlessTimes
    diMeleeTab.X = 0.21

    if self.VSLayer ~= nil then
        self.VSLayer:removeFromParent()
    end
    local nameStr = difangInfo.playerinfo.qufu.."."..difangInfo.playerinfo.nickname
    self.VSLayer = require("src.app.views.layer.VSLayer").new({scene = self, zhandouli = allZhanli, nickname = difangInfo.playerinfo.nickname, diPlayerInfo = difangInfo.playerinfo})
    self:addChild(self.VSLayer, MoGlobalZorder[2000001])

    -- fight:initNode()
    fight:initBattlefield({scene = self, unitTA = mm.puTongZhen, myplayerHero = mm.data.playerHero, myPkValue = mm.data.playerExtra.pkValue, typeA = 1,
        unitTB =  diZhen,diplayerHero = difangInfo.playerHero, diPkValue = difangInfo.pkValue, typeB = 1, fightType = 1, myMeleeTab = myMeleeTab, diMeleeTab = diMeleeTab
        })

    

    self:updateTiBu(mm.puTongZhen, mm.data.playerHero, diZhen, difangInfo.playerHero)



    mm.req("getMeleeList",{getType = 0})



end

-- function MeleeScene:getUnitIDA( ... )
--     local TA = {1278226736, 1278226740, 1278226995, 1278227254, 1278227512}
--     return TA
-- end

-- function MeleeScene:getUnitIDB( ... )
--     local camp = mm.data.playerinfo.camp
--     local num = math.random(1,3)
--     local TB = {1278227766}
    
--     if 1 == camp then
--         TB = {1144009526}
--     else
--         TB = {1278227254}
--     end
--     return TB
-- end

function MeleeScene:beginShake( btime,etime )
    --self.scene:setScale(1.03)
    
    self.shakeDt = 0
    self.shakeD = 0.09
    self.shakeTime = 0
    self.shakeETime = etime
    self.shakeBTime = btime
    self.isShake = 1
end

function MeleeScene:endShake( ... )
    self.scene:setScale(1)
    self.scene:setPosition(self.ppp)
    self.isShake = false
    
end

function MeleeScene:scheduleUpdate( ... )
    -- 开始更新逻辑
    local function update(dt) self:fightLogic(dt) end
    self:scheduleUpdateWithPriorityLua(update, 0)
end

function MeleeScene:fightLogic( dt )
    -- if self.isShake and self.isShake <= 4 then
    if self.isShake then
        self.shakeDt = self.shakeDt + dt
        self.shakeTime = self.shakeTime + dt
        if self.shakeTime > self.shakeETime then
            self:endShake() 
        elseif self.shakeTime > self.shakeBTime and self.shakeTime < self.shakeETime then
            if self.shakeDt > self.shakeD then
                self.shakeDt = 0
                self.shakeD = self.shakeD
                
                self.scene:setPosition(self:shakePos(self.ppp, 5))
                self.isShake = self.isShake + 1
                
            end
        end
    end
    -- elseif self.isShake and self.isShake == 5 then 
    --     self:endShake()
    -- end
end

function MeleeScene:shakePos(pos, level)
    if level == nil then
        level = 30
    end
    local x = self:randomWithRange(pos.x-level, pos.x+level)
    local y = self:randomWithRange(pos.y-level, pos.y+level)
    return cc.p(x, y)
end

function MeleeScene:randomWithRange(l, r)
    return math.random(l,r)
end

function MeleeScene:refreshBlood( t )
    local curABlood = t.curABlood 
    local initABlood = t.initABlood 
    local curBBlood = t.curBBlood 
    local initBBlood = t.initBBlood 
    
    game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshBlood", curABlood = curABlood, initABlood = initABlood,curBBlood = curBBlood,initBBlood = initBBlood})
end

function MeleeScene:jiesuan( t )
    local result = t.result

    mm.req("fightResultMelee",{result = t.result})
end

function MeleeScene:nextFight()
    fight:initNode()
    local difangInfo = self.meleeList[1]
    self:initFight(difangInfo)
end


function MeleeScene:addTiBu( ... )
    local qizi_left = self.scene:getChildByName("Image_4"):getChildByName("qizi_left")

    self.tibuLeftSkeletonNode = gameUtil.createSkeletonAnimation("res/hero/guanzhong/l_4_qizhi/l_4_qizhi.json", "res/hero/guanzhong/l_4_qizhi/l_4_qizhi.atlas",0.6)
    qizi_left:addChild(self.tibuLeftSkeletonNode)
    self.tibuLeftSkeletonNode:setAnimation(0, "stand", true)
    
    

    local qizi_right = self.scene:getChildByName("Image_4"):getChildByName("qizi_right")

    self.tibuRightSkeletonNode = gameUtil.createSkeletonAnimation("res/hero/guanzhong/d_4_qizhi/d_4_qizhi.json", "res/hero/guanzhong/d_4_qizhi/d_4_qizhi.atlas",0.6)
    qizi_right:addChild(self.tibuRightSkeletonNode)
    self.tibuRightSkeletonNode:setAnimation(0, "stand", true)


    self.tibu_left = self.scene:getChildByName("Image_4"):getChildByName("tibu_l")
    self.tibu_right = self.scene:getChildByName("Image_4"):getChildByName("tibu_r")

end

function MeleeScene:updateTiBu( myFormation, myplayerHero, diFormation, diplayerHero )

    local formationNum = #myFormation

    local HeroNum = #myplayerHero
    
    local tibuNum = HeroNum - formationNum
    self.tibuLeftSkeletonNode:setAttachment("l_zuo=","l_zuo".. math.floor(tibuNum/10) )
    self.tibuLeftSkeletonNode:setAttachment("l_you=","l_you" .. math.floor(tibuNum%10))
    local leftIndex = 0
    if tibuNum >= 10 and tibuNum < 15 then
        leftIndex = 1
    elseif tibuNum >= 15 and tibuNum < 20 then
        leftIndex = 2
    elseif tibuNum >= 20 and tibuNum < 25 then
        leftIndex = 3
    elseif tibuNum >= 25 and tibuNum < 30 then
        leftIndex = 4
    elseif tibuNum >= 30 then
        leftIndex = 5
    end
    
    if leftIndex > 0 then
        self.tibuLeftSkeletonNode:setAttachment("l_qigan=","l_qigan_".. leftIndex )
        self.tibuLeftSkeletonNode:setAttachment("l_qimian=","l_qimian_".. leftIndex )

    end



    local ltb = tibuNum - 1
    if ltb > 7 then
        ltb = 7
    end

    self.tibu_left:removeAllChildren()
    for i=1,ltb do
        if i == 4 then
        else
            local name = "l_"..i.."_xiaobing"
            local res = "res/hero/guanzhong/"..name.."/"..name
            local sNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",0.6)
            self.tibu_left:addChild(sNode)
            sNode:setAnimation(0, "stand", true)
            sNode:setPosition(30 * i, math.random(0,20))
            sNode:setOpacity(120)
        end
        
    end

    local formationNum = #diFormation

    local HeroNum = #diplayerHero
    
    local tibuNum = HeroNum - formationNum

    local leftIndex = 0
    if tibuNum >= 10 and tibuNum < 15 then
        leftIndex = 1
    elseif tibuNum >= 15 and tibuNum < 20 then
        leftIndex = 2
    elseif tibuNum >= 20 and tibuNum < 25 then
        leftIndex = 3
    elseif tibuNum >= 25 and tibuNum < 30 then
        leftIndex = 4
    elseif tibuNum >= 30 then
        leftIndex = 5
    end
    if leftIndex > 0 then
        self.tibuRightSkeletonNode:setAttachment("d_qimutou=","d_qimutou_".. leftIndex )
        self.tibuRightSkeletonNode:setAttachment("d_qimutous=","d_qimutous_".. leftIndex )
        self.tibuRightSkeletonNode:setAttachment("d_qimian=","d_qimian_".. leftIndex )
    end

    local rtb = tibuNum - 1
    if rtb > 7 then
        rtb = 7
    end

    self.tibuRightSkeletonNode:setAttachment("d_zuo=","d_zuo".. math.floor(tibuNum/10) )
    self.tibuRightSkeletonNode:setAttachment("d_you=","d_you" .. math.floor(tibuNum%10))

    self.tibu_right:removeAllChildren()
    for i=1,rtb do
        if i == 4 then
        else
            local name = "d_"..i.."_xiaobing"
            local res = "res/hero/guanzhong/"..name.."/"..name
            local sNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",0.6)
            self.tibu_right:addChild(sNode)
            sNode:setAnimation(0, "stand", true)
            sNode:setPosition(-30 * i, math.random(0,20))
            sNode:setOpacity(120)
        end
        
    end

end

function MeleeScene:addUnit(  )
    self:reSetUnit()

    local unitTA = self:getJSZIDA()--mm.puTongZhen
    self.curUnitTA = unitTA
    self.jszNodeA = {}

    --B阵营
    for i=1,5 do
        if unitTA[i] then
            local node = self.scene:getChildByName("a_"..i)
            
            local skeletonNode = gameUtil.createSkeletonAnimation(gameUtil.getHeroTab(unitTA[i]).Src..".json", gameUtil.getHeroTab(unitTA[i]).Src..".atlas",0.6)
            self:addChild(skeletonNode, MoGlobalZorder[2000002])
            skeletonNode:setName("skeletonNode")
            skeletonNode:update(0.012)
            skeletonNode:setAnimation(0, "stand", true)
            skeletonNode:setPosition(node:getPositionX(),node:getPositionY())
            skeletonNode:setTag(unitTA[i])
            self.jszNodeA[i] = skeletonNode
        end
    end



    local unitTB = self:getJSZIDB()
    self.curUnitTB = unitTB
    self.jszNode = {}
    --B阵营
    for i=1,5 do
        if unitTB[i] then
            local node = self.scene:getChildByName("b_"..i)
            
            local skeletonNode = gameUtil.createSkeletonAnimation(gameUtil.getHeroTab(unitTB[i]).Src..".json", gameUtil.getHeroTab(unitTB[i]).Src..".atlas",0.6)
            self:addChild(skeletonNode, MoGlobalZorder[2000002])
            skeletonNode:setName("skeletonNode")
            skeletonNode:update(0.012)
            skeletonNode:setScaleX(-1) 
            skeletonNode:setAnimation(0, "stand", true)
            skeletonNode:setPosition(node:getPositionX(),node:getPositionY())
            skeletonNode:setTag(unitTB[i])
            self.jszNode[i] = skeletonNode
        end
    end
end

function MeleeScene:getJSZIDB( ... )
    local camp = mm.data.playerinfo.camp
    local TB = {1278227766}
    
    if 1 == camp then
        local tab = {1144009267, 1144009776, 1144009781, 1144010548, 1144010804}
        TB = tab
    else
        local tab = {1278226740, 1278226995, 1278227504, 1278227512, 1278227766}
        TB = tab
    end
    
    return TB
end

function MeleeScene:getJSZIDA( ... )
    local camp = mm.data.playerinfo.camp
    local TB = {1278227766}
    
    if 1 ~= camp then
        local tab = {1144009267, 1144009776, 1144009781, 1144010548, 1144010804}
        TB = tab
    else
        local tab = {1278226740, 1278226995, 1278227504, 1278227512, 1278227766}
        TB = tab
    end
    
    return TB
end

function MeleeScene:beginJSZ( ... )
        self.isnextFight = false
        local t1 = os.clock()
        fight:initNode()
        local t2 = os.clock()
        
        self:addUnit()
        local t3 = os.clock()
end

function MeleeScene:killOnce( ... )
    if self.isnextFight then
        return
    end


    local unitTB = self.curUnitTB

    local tab = {1,2,3,4,5}
    local newtab = {}
    local index = 1
    for k,v in pairs(tab) do
        table.insert(newtab,math.random(1,index) , v)
        index = index + 1
    end
    
    --gameUtil.tableLuanXu( tab )

    for i=1,5 do
        if unitTB[i] then
            local node = self.scene:getChildByName("b_"..i)
            local DieNode = node:getChildByName("DieTeXiao")
            if DieNode then
                DieNode:setAnimation(0, "mb", false)
            else
                local str = "res/Effect/yingxiong/gongyong/t_sw/t_sw"
                local DieNode = gameUtil.createSkeletonAnimation(str..".json", str..".atlas",1)
                node:addChild(DieNode)
                DieNode:setAnimation(0, "mb", false)
                DieNode:setName("DieTeXiao")
                DieNode:setTimeScale(2)
            end

            local skeletonNode = self.jszNode[i]--node:getChildByName("skeletonNode")
            if skeletonNode then
                --skeletonNode:removeFromParent()
                
                local index = newtab[i]
                
                local node = self.scene:getChildByName("b_"..index)
                skeletonNode:setPosition(node:getPositionX(), node:getPositionY())
                skeletonNode:setVisible(false)

                performWithDelay(self,function( ... )
                    skeletonNode:setVisible(true)
                end , 0.01)

                --skeletonNode:setName("sn")
                --gameUtil.graySprite( skeletonNode )

                local heroid = skeletonNode:getTag()
                local str = util.getStrFormNum(heroid, 4)

                local jinbiImageView = ccui.ImageView:create()
                jinbiImageView:loadTexture("res/hero/heroImage/"..str..".png")
                skeletonNode:addChild(jinbiImageView)
                jinbiImageView:setName("heroImage")
                jinbiImageView:setScale(0.4)    
                jinbiImageView:setPosition(0,50)

                self:unitFly(jinbiImageView)
            else
                
            end

        
        end
    end


    local unitTA = self.curUnitTA

    for i=1,#unitTA do
        if unitTA[i] then
            local node = self.scene:getChildByName("a_"..i)
            local DieNode = node:getChildByName("DieTeXiao")
            if DieNode then
                DieNode:setAnimation(0, "mb", false)
            else
                local str = "res/Effect/yingxiong/gongyong/t_sw/t_sw"
                local DieNode = gameUtil.createSkeletonAnimation(str..".json", str..".atlas",1)
                node:addChild(DieNode)
                DieNode:setAnimation(0, "mb", false)
                DieNode:setName("DieTeXiao")
                DieNode:setTimeScale(2)
            end

            local skeletonNode = self.jszNodeA[i]--node:getChildByName("skeletonNode")
            if skeletonNode then
                --skeletonNode:removeFromParent()
                
                local index = newtab[i]
                
                
                local node = self.scene:getChildByName("a_"..index)
                skeletonNode:setPosition(node:getPositionX(), node:getPositionY())
                skeletonNode:setVisible(false)

                performWithDelay(self,function( ... )
                    skeletonNode:setVisible(true)
                end , 0.01)

                --skeletonNode:setName("sn")
                --gameUtil.graySprite( skeletonNode )

                local heroid = skeletonNode:getTag()
                
                local str = util.getStrFormNum(heroid, 4)

                local jinbiImageView = ccui.ImageView:create()
                jinbiImageView:loadTexture("res/hero/heroImage/"..str..".png")
                skeletonNode:addChild(jinbiImageView)
                jinbiImageView:setName("heroImage")
                jinbiImageView:setScale(0.4)    
                jinbiImageView:setPosition(0,50)

                self:unitFly(jinbiImageView)
            else

            end

        
        end
    end
        
end

function MeleeScene:play( ... )
    local time = 0
    local dtime = 0
    local function showTime(dt)
        dtime = dtime + dt
        if dtime >= 3 then
            self:clearUnit()
            self:nextFight()
            self:getScheduler():unscheduleScriptEntry(self.jszTick)
            self.singleMeleeEnd = true
            return
        end
        self:killOnce()
    end

    self.jszTick =  self:getScheduler():scheduleScriptFunc(showTime, 0.2,false)
end

function MeleeScene:clearUnit(  )
    for k,v in pairs(self.jszNodeA) do
        v:removeFromParent()
    end

    for k,v in pairs(self.jszNode) do
        v:removeFromParent()
    end
end

function MeleeScene:jinshouzhiBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 

        
       

    end
end

function MeleeScene:unitFly( jibiNode)
    local function fly( ... )
       jibiNode:removeFromParent()
    end
    local b = 2
    local mx = math.random(-80 * b,80 * b)
    local my = math.random(-80 * b,-60 * b)
    local bezier = {
        cc.p(0, 0),
        cc.p(mx * 0.5, math.random(160 * b,180 * b)),
        cc.p(mx, my),
    }
    local time = math.random(40,70) * 0.01
    local bezierForward = cc.BezierBy:create(time, bezier)
    local actionTo = cc.RotateTo:create(time, mx * (45/(80 * b)))
    local FadeOut = cc.FadeOut:create(time )
    local spawn = cc.Spawn:create(bezierForward, actionTo, FadeOut)

    jibiNode:runAction(cc.Sequence:create(
                spawn, 
                cc.CallFunc:create(fly)))


end

return MeleeScene