local Attribute = class("Attribute", require("app.views.mmExtend.LayerBase"))
Attribute.RESOURCE_FILENAME = "Attribute.csb"

function Attribute:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function Attribute:globalEventsListener( event )
    
    if event.name == EventDef.SERVER_MSG then

    end
end

function Attribute:onEnter()
    
end

function Attribute:onExit()
    
end

function Attribute:onEnterTransitionFinish()
    
end

function Attribute:onExitTransitionStart()
    
end

function Attribute:onCleanup()
    
    self:clearAllGlobalEventListener()
end

function Attribute:init(param)

    self.tab = param.tab

    -- TODO::这谁写的。。。干嘛要复制一次
    self.t = {}
    self.t.id = self.tab.id
    self.t.exp = self.tab.exp
    self.t.xinlv = self.tab.xinlv
    self.t.jinlv = self.tab.jinlv
    self.t.lv = gameUtil.getHeroLv(self.t.exp, self.t.jinlv)
    self.t.eqTab = self.tab.eqTab
    self.t.preciousInfo = self.tab.preciousInfo
    self.t.skinInfo = self.tab.skinInfo

    self.Node = self:getResourceNode()
    
    self.Node:getChildByName("Panel_touch"):addTouchEventListener(handler(self, self.backBtnCbk))

    local heroRes = gameUtil.getHeroTab(self.t.id)
    local imgBg = self.Node:getChildByName("Image_bg")
    local imgBg01 = imgBg:getChildByName("Image_bg01")
    local touxiang = gameUtil.createTouXiang(self.tab)
    touxiang:setPositionY(touxiang:getContentSize().height * 0.5)
    imgBg:getChildByName("Image_touxiang"):addChild(touxiang)
    imgBg:getChildByName("Text_name"):setString(heroRes.Name)


    imgBg:getChildByName("Text_zizhi"):setString("资质：")
    local aptitudeImg = ccui.ImageView:create()
    aptitudeImg:setAnchorPoint(cc.p(0,0.5))
    aptitudeImg:loadTexture("res/UI/".."aptitude_"..heroRes.aptitude..".png")
    imgBg:getChildByName("Text_zizhi"):addChild(aptitudeImg)

    local textSize = imgBg:getChildByName("Text_zizhi"):getContentSize()
    aptitudeImg:setPositionX(textSize.width + 10)
    aptitudeImg:setPositionY(textSize.height * 0.5)

    imgBg:getChildByName("Text_content"):setString(heroRes.Hero_Desc)
    local backBtn = imgBg:getChildByName("Button_back")
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(backBtn)

    local allZhanli = gameUtil.Zhandouli( self.tab ,mm.data.playerHero, mm.data.playerExtra.pkValue)
    local Zhanli = gameUtil.Zhandouli( self.tab ,mm.data.playerHero, mm.data.playerExtra.pkValue, false)
    imgBg01:getChildByName("Text_zhanli"):setString("战力："..allZhanli)
    imgBg01:getChildByName("Text_zhanli_Tip1"):setString("阵容战力："..Zhanli)
    imgBg01:getChildByName("Text_zhanli_Tip2"):setString("替补战力："..allZhanli - Zhanli)


    local allHeroTiBuBeiLvXiShu = gameUtil.allHeroTiBuBeiLvXiShu( mm.data.playerHero )

    local hpText = imgBg01:getChildByName("Text_01")
    local hpNum = gameUtil.hpMBAck( self.t )
    hpNum = gameUtil.HpTBXZ( hpNum, allHeroTiBuBeiLvXiShu )
    hpText:setText("生命值：".. math.ceil(hpNum))

    local wufangText = imgBg01:getChildByName("Text_02")
    local wufangNum = gameUtil.wufangMBAck( self.t )
    wufangText:setText("物理减免：".. string.format("%.2f", wufangNum/(wufangNum+10000)*100 ).."%")

    local mofangText = imgBg01:getChildByName("Text_03")
    local mofangNum = gameUtil.mofangMBAck( self.t )
    mofangText:setText("法术减免：".. string.format("%.2f", mofangNum/(mofangNum+10000)*100 ).."%")

    local ackText = imgBg01:getChildByName("Text_04")
    local ackNum = gameUtil.heroMBAck( self.t )
    ackNum = gameUtil.AckTBXZ( ackNum, allHeroTiBuBeiLvXiShu )
    ackText:setText("攻击力：".. math.ceil(ackNum))

    local speedText = imgBg01:getChildByName("Text_05")
    local speedNum = gameUtil.speedMBAck( self.t )
    speedText:setText("速度：".. math.ceil(speedNum))--  .."+".. string.format("%0.2f",speedtbNum))

    local critText = imgBg01:getChildByName("Text_06")
    local critNum = gameUtil.critMBAck( self.t )
    critText:setText("暴击概率：".. string.format("%0.2f",(critNum/100)).."%")--  .."+".. string.format("%0.2f",CritTBXZ))

    -- local dodgeText = imgBg01:getChildByName("Text_07")
    -- local dodgeNum = gameUtil.dodgeMBAck( { heroid = self.heroId, lv = self.lv, xinlv = self.xinlv, jinlv = self.jinlv, eqTab = self.eqTab} )
    -- local DodgeTBXZ = gameUtil.DodgeTBXZ( alllv, allxinlv )
    -- dodgeText:setText("闪避:".. string.format("%0.2f",dodgeNum)  .." + ".. string.format("%0.2f",DodgeTBXZ))

    local nameText = imgBg:getChildByName("Text_name")
    local c, vv = gameUtil.getColor(self.t.jinlv)
    nameText:setColor(c)        
    if vv > 0 then
        nameText:setText(gameUtil.getHeroTab( self.t.id ).Name .. "+" .. vv)
    else
        nameText:setText(gameUtil.getHeroTab( self.t.id ).Name)
    end

end



function Attribute:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return Attribute
