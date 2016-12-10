local JJCLayer = class("JJCLayer", require("app.views.mmExtend.LayerBase"))
JJCLayer.RESOURCE_FILENAME = "JJCLayer.csb"

require("app.res.rankawardRes")
require("app.res.ChangeRes")

function JJCLayer:onCreate(param)
    self.param = param
    self.Node = self:getResourceNode()

    -- ok按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    


    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

    mm.req("getTianTiInfo",{type=0})

    self.baohuasction = performWithDelay(self,function( ... )
        mm.GuildId = 99999
        Guide:GuildEnd()
    end, 2)
end

function JJCLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getTianTiInfo" then
            print("JJCLayer getTianTiInfo      "..json.encode(event.t))
            self:addJJCAreanLayer(event.t)

            self:stopAction(self.baohuasction)
            
            if mm.GuildId == 10701 then
                performWithDelay(self,function( ... )
                    if self.yidaoTiaoZhanBtn then
                        Guide:startGuildById(10702, self.yidaoTiaoZhanBtn)
                    else
                        mm.GuildId = 99999
                        Guide:GuildEnd()
                    end
                end, 0.2)
            end
    
        elseif event.code == "challengeTianTi" then
            print("tiaozhanBtnCbk ===========  1111 "..event.t.diamondType)
            if event.t.type == 1 then
                gameUtil:addTishi({s = MoGameRet[990401]})
                return
            end

            if event.t.diamondType == 0 then
                local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_, type = 10, Info = event.t.direninfo})
                local size  = cc.Director:getInstance():getWinSize()
                self:addChild(BuZhenLayer)
                BuZhenLayer:setContentSize(cc.size(size.width, size.height))
                ccui.Helper:doLayout(BuZhenLayer)
            elseif event.t.diamondType == 1 then
                gameUtil:addTishi({p = self, s = MoGameRet[990001]})
            elseif event.t.diamondType == 2 then
                local VIPTIPS = require("src.app.views.layer.VIPTIPS").new({scene = self, str = "今日购买竞技次数已不足"})
                self:addChild(VIPTIPS, MoGlobalZorder[2000002])

            else
                gameUtil:addTishi({p = self, s = MoGameRet[900001]})
            end
        elseif event.code == "getPlayerInfo" then
            print("checkPlayer            2222222222222222222       ")
            local zhanli = 0
            for k,v in pairs(self.msgInfo) do
                if self.checkId == v.id then
                    zhanli = v.score
                    break
                end
            end
         
            local zhenrongchakanLayer = require("src.app.views.layer.zhenrongchakan").new({info = event.t, zhanli = zhanli, zztype = 10})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(zhenrongchakanLayer)
            zhenrongchakanLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(zhenrongchakanLayer)
        end
    end

end

function JJCLayer:onEnter()

    

end

function JJCLayer:onExit()

end

--[[
--]]

function JJCLayer:addJJCAreanLayer( t )
    self.t = t
    self.msgInfo = {}
    for i=1,#t.topTenInfo do
        t.topTenInfo[i].type = 1
        table.insert(self.msgInfo, t.topTenInfo[i])
    end
    for i=1,#t.fightInfo do
        t.fightInfo[i].type = 2
        table.insert(self.msgInfo, t.fightInfo[i])
    end
    t.selfInfo.type = 3
    table.insert(self.msgInfo, t.selfInfo)

    self.myRank = t.selfInfo.rank
    mm.data.playerTaskProc.TianTiLadder = self.myRank

    for k,v in pairs(rankaward) do
        if self.myRank == v.RankAwardRange[1] or (self.myRank >= v.RankAwardRange[1] and v.RankAwardRange[2] and self.myRank <= v.RankAwardRange[2]) then
            self.RankAwardGold = v.RankAwardGold
            self.RankAwardGlory = v.RankAwardGlory
        end
    end

    if not self.RankAwardGlory then
        print(" rank error   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!         ")
    end

    if not self.ContentLayer then
        local JJCAreanLayer = cc.CSLoader:createNode("JJCAreanLayer.csb")
        self.ContentLayer = JJCAreanLayer
        self:addChild(JJCAreanLayer)
        local size  = cc.Director:getInstance():getWinSize()
        JJCAreanLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(JJCAreanLayer)

        local iconBiaoti = JJCAreanLayer:getChildByName("Image_4")
        local win_playQuan = gameUtil.createSkeAnmion( {name = "sl", scale = 1, zdyName = "slJJC"} )
        win_playQuan:setAnimation(0, "stand03", false)
        iconBiaoti:addChild(win_playQuan,-1)
        win_playQuan:setPosition(iconBiaoti:getContentSize().width*0.5, iconBiaoti:getContentSize().height*0.5)
        win_playQuan:setScale(0.8)
        self.win_playQuan = win_playQuan

    end

    local JJCAreanLayer = self.ContentLayer


    local guizheBtn = JJCAreanLayer:getChildByName("Button_3") 
    guizheBtn:addTouchEventListener(handler(self, self.guizheBtnCbk))
    gameUtil.setBtnEffect(guizheBtn)

    -- ok按钮
    local storeBtn = JJCAreanLayer:getChildByName("Button_guize")
    storeBtn:addTouchEventListener(handler(self, self.storeBtnCbk))
    gameUtil.setBtnEffect(storeBtn)
    gameUtil.setBtnEffect(storeBtn)

    local rongyuImageView = gameUtil.createOTItem("res/icon/jiemian/icon_rongyu.png", self.RankAwardGlory)
    JJCAreanLayer:getChildByName("Bottom"):getChildByName("ItemImage_1"):addChild(rongyuImageView)

    local jinbiImageView = gameUtil.createOTItem("res/icon/jiemian/icon_jinbi.png", self.RankAwardGold)
    JJCAreanLayer:getChildByName("Bottom"):getChildByName("ItemImage_2"):addChild(jinbiImageView)

    local btnshuaxin = JJCAreanLayer:getChildByName("Bottom"):getChildByName("Button_1")
    btnshuaxin:addTouchEventListener(handler(self, self.shuaxinBtnCbk))
    gameUtil.setBtnEffect(btnshuaxin)
    print("self.upTime     ============     00000 t.challengeTimes   "..t.challengeTimes)
    JJCAreanLayer:getChildByName("Bottom"):getChildByName("Text_1"):setString(string.format("剩余次数：%d / 5", t.challengeTimes))

    local timeText = JJCAreanLayer:getChildByName("Bottom"):getChildByName("Text_2")
    print("self.upTime     ============     00000 t.challengeTimes   "..t.challengeTimes)
    if t.challengeTimes >= 5 then
        timeText:setString("下次回复：次数已满")
    else
        if t.refreshTianTiTime > 0 then
            self.upTime = t.refreshTianTiTime + 3
            if not self.hasSchedule then
                schedule(self, self.updateTime, 1)
                self.hasSchedule = true
            end
            self.runTime = true
        else
            self.runTime = false
        end
    end



    local ScrollView = JJCAreanLayer:getChildByName("ScrollView") 
    self.HeroListView = ScrollView



    self:initHeroUIBack(t)

end

function JJCLayer:checkPlayer(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if mm.GuildId ~= 10701 and mm.GuildId ~= 10702 and mm.GuildId ~= 10703 then
            local tag = widget:getTag()
            print("checkPlayer            1111111111111111111       "..tag)
            self.checkId = tag
            mm.req("getPlayerInfo",{playerid = tag})
        end
    end
end

function JJCLayer:shuaxinBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if not self.req then 
            mm.req("getTianTiInfo",{type=1})
            self.req = true
            local function aaa( ... )
                self.req = nil
            end
            performWithDelay(self,aaa, 5)
        else
            gameUtil:addTishi({s = MoGameRet[990401]})
        end
        
    end
end

function JJCLayer:getNeedMoney( userTimes )
    local needMoney  = 50
    for k,v in pairs(Change) do
        if v. ChangeType == 1 and userTimes >= v.ChangeRange[1] and userTimes <= v.ChangeRange[2] then
            needMoney = v.ChangeConsumeDiamond
        end
    end
    return needMoney
end

function JJCLayer:updateTime()
    if self.runTime then
        self.upTime = self.upTime - 1
        if self.upTime <= 0 then
            mm.req("getTianTiInfo",{type=0})
            self.runTime = false
        end
        local timeText = self.ContentLayer:getChildByName("Bottom"):getChildByName("Text_2")
        timeText:setString("下次回复：".. util.timeFmt(self.upTime))
    end
end

function JJCLayer:setItemInfo(node, table)


    if table.camp == 1 then
        node:getChildByName("Image_icon"):loadTexture("res/icon/head/L023.png")
    else
        node:getChildByName("Image_icon"):loadTexture("res/icon/head/D074.png")
    end

    if table.camp == 1 then
        node:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhilol_select.png")
    else
        node:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhidota_select.png")
    end

    node:getChildByName("Text_name"):setString(table.nickname)

    node:getChildByName("Text_zhanli"):setString("战力："..table.score)

    if table.rank < 4 then
        node:getChildByName("RankImage"):loadTexture("res/icon/jiemian/icon_paihang_"..table.rank..".png")
        node:getChildByName("Text_ranking"):setVisible(false)
    else
        node:getChildByName("RankImage"):loadTexture("res/icon/jiemian/icon_paihang_4.png")

        local textNode = node:getChildByName("Text_ranking")
        textNode:setText(table.rank)
        textNode:setVisible(true)

        textNode:setFontSize(45)

        if table.rank > 99 then
            textNode:setFontSize(36)
        end
    end


    local tiaozhanBtn = node:getChildByName("ButtonTiaozhan")
    if table.type == 2 then
        tiaozhanBtn:setVisible(true)
        tiaozhanBtn:setTag(table.id)
        tiaozhanBtn:addTouchEventListener(handler(self, self.tiaozhanBtnCbk))
        gameUtil.setBtnEffect(tiaozhanBtn)
        node:getChildByName("Text"):setVisible(true)

        self.yidaoTiaoZhanBtn = tiaozhanBtn
    else
        tiaozhanBtn:setVisible(false)
        node:getChildByName("Text"):setVisible(false)
    end



end

function JJCLayer:initHeroUIBack(t)



    local function fun( i, table, cell, cellIndex )
        cell:removeAllChildren()
        local node = gameUtil.getCSLoaderObj({name = "JJCAreanItem.csb", type = "CSLoader"})
        node:setSwallowTouches(false)
        cell:addChild(node)

        node:addTouchEventListener(handler(self, self.checkPlayer))
        node:setTag(table.id)

        self:setItemInfo(node, table)
    end

    self.HeroListView:removeAllChildren()
    gameUtil.setSollowViewNewTest(self.HeroListView, 8, 10, self.msgInfo, 110, nil, fun, nil, {})


end

function JJCLayer:tiaozhanBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm.GuildId = 99999
        Guide:GuildEnd()    

        local id = widget:getTag()
        if (mm.diFangZhen and mm.diFangZhen.diType and 10 == mm.diFangZhen.diType) or (mm.curDiZhen and mm.curDiZhen.diType and mm.curDiZhen.diType == 10) then
            gameUtil:addTishi({s = MoGameRet[990066]})
            return
        end

        
        print("tiaozhanBtnCbk ===========  0000 "..self.t.challengeTimes)

        if self.t.challengeTimes > 0 then
            print("tiaozhanBtnCbk ===========  1111 ")
            mm.req("challengeTianTi",{playerid = id, diamondType = 0})
        else
            print("tiaozhanBtnCbk ===========  2222 ")
            local needMoney = self:getNeedMoney( self.t.buychallengeTimes + 1 )
            local PkByMoneyLayer = require("src.app.views.layer.PkByMoneyLayer").new({num = needMoney, id = id})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(PkByMoneyLayer, 50)
            PkByMoneyLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(PkByMoneyLayer)

            
        end
    end
end

function JJCLayer:guizheBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local JJCRules = require("src.app.views.layer.JJCRules").new()
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(JJCRules, 50)
        JJCRules:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(JJCRules)
    end
end

function JJCLayer:heroDetailBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
       
    end
end

function JJCLayer:selectCbk( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
   
    end
end

function JJCLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function JJCLayer:storeBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local param = {}
        param.typeLayer = 2
        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = "ShangChengLayer", param = param})
    end
end

function JJCLayer:onCleanup()

    self:clearAllGlobalEventListener()
end

return JJCLayer
