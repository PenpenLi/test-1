local FightScene = class("FightScene", cc.load("mvc").ViewBase)
FightScene.RESOURCE_FILENAME = "FightScene.csb"


INITLUA = require("app.models.initLua")
PEIZHI = require("app.res.peizhi")
INITLUA:fightSceneLoad()
local fight = require("app.fight.Fight")
local PlayFight = require("app.fight.PlayFight")
local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")
local PA = require("src.app.views.mmExtend.preciousAssetHelper") -- 至宝助手
CJH = require("src.app.views.mmExtend.chouJiangHelper") -- 抽奖助手
local CJH = CJH

local mm = mm
local cc = cc
local handler = handler
require("app.views.mmExtend.gameUtil")

require("app.views.mmExtend.MoGlobalZorder")

gameTimer = require("app/views/mmExtend/Timer")
gameTimer:new()
--玩家阵营始终为 1

Guide = require("app/models/guide")

IOS_S = true -- ios送审

function FightScene:onCreate()

    
    print("FightScene:onCreate()    ========================          !!!!!!!!!!!!!        ")
    self.t1 = os.clock()
    
    mm.GuildScene = self

    mm.musicOpen = cc.UserDefault:getInstance():getIntegerForKey("musicOpen")
    if mm.musicOpen == 0 then
        AudioEngine.playMusic("res/sounds/music/Fight.mp3", true)
    else
        AudioEngine.stopMusic(true)
    end

    self.t2 = os.clock()
    
    self.state = "idle"

    mm.GuildId = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideId",10001)
    mm.GuildId = 999999
    
    self:addBarrageLayer()

    -- if mm.GuildId == 10001 and gameUtil.getPlayerLv(mm.data.playerinfo.exp) > 2 then
    --     mm.GuildId = 999999
    --     cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId",mm.GuildId)
    --     cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId20",1)
    --     cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId22",1)
    --     cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId25",1)
    --     cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId30",1)
    -- end

    -- if gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= 16 then
    --     mm.GuildId = 999999
    --     cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId",mm.GuildId)
    -- end

    mm.onePlayAddGold = mm.onePlayAddGold or 0
    mm.onePlayAddExp = mm.onePlayAddExp or 0
    mm.onePlayaddExppool = mm.onePlayaddExppool or 0

    self.t3 = os.clock()

    -- self.fight = fight:new()
    -- self.fight:setPosition(CC_DESIGN_RESOLUTION.width * 0.5,CC_DESIGN_RESOLUTION.height * 0.5 - 12)
    -- self:addChild(self.fight)
    
    --self.fight:addMonster()

    mm.puTongZhen = {}
    if not mm.data.playerFormation or #mm.data.playerFormation <= 0 then
        mm.puTongZhen = self:getUnitIDA()
    else
        for i=1,#mm.data.playerFormation do
            if mm.data.playerFormation[i].type == 1 then
                for j=1,#mm.data.playerFormation[i].formationTab do
                    table.insert(mm.puTongZhen, mm.data.playerFormation[i].formationTab[j].id)
                end
            end
        end
    end

    self.t4 = os.clock()

    self.scene = self:getChildByName("Scene")

    self:taptapInit()
    

    self.scene:getChildByName("Text_next_fight"):setVisible(false)
    self.scene:getChildByName("fntNode"):setLocalZOrder(1000000)
    self.scene:getChildByName("NodeLayer"):setLocalZOrder(500000)
    ccui.Helper:doLayout(self.scene)
    mm.TishiNode = self.scene:getChildByName("fntNode")
    mm.self = self
    self:initUnit()

    self:setLocalZOrder(MoGlobalZorder[2000000])
    self.scene:setLocalZOrder(MoGlobalZorder[1000000])
    
    self.paneldi = cc.CSLoader:createNode("fightDiLayer.csb")
    self:addChild(self.paneldi, MoGlobalZorder[2000003])

    self.scene:getChildByName("Panel_left"):addTouchEventListener(handler(self, self.buzhenBtnCbk))
    self.scene:getChildByName("Panel_left"):setTouchEnabled(true)
    self.PanelLeft = self.scene:getChildByName("Panel_left")

    mm.GuildScene.PanelGuildTime = self.scene:getChildByName("Panel_Guild_time")

    self.t5 = os.clock()

    -- 上阵加号特效添加
    -- gameUtil.addArmatureFile("res/Effect/uiEffect/tjjs/tjjs.ExportJson")
    -- local upZhen = ccs.Armature:create("tjjs")
    -- self.scene:getChildByName("Panel_left"):addChild(upZhen, 100)
    -- local size = self.scene:getChildByName("Panel_left"):getContentSize()
    -- upZhen:setPosition(size.width/2, size.height*0.5)
    -- upZhen:setScale(2)
    -- upZhen:getAnimation():playWithIndex(0)
    -- self.upZhen = upZhen
    -- self:setUpZhen()

    local size = self.scene:getChildByName("Panel_left"):getContentSize()
    local upZhen = gameUtil.createSkeAnmion( {name = "tjjs",scale = 2} )
    upZhen:setAnimation(0, "stand", true)
    self.scene:getChildByName("Panel_left"):addChild(upZhen, 100)
    upZhen:setPosition(size.width/2, size.height*0.5)
    self.upZhen = upZhen
    self:setUpZhen()


    self.scene:getChildByName("Panel_right"):addTouchEventListener(handler(self, self.jinshouzhiBtnCbk))
    self.scene:getChildByName("Panel_right"):setTouchEnabled(true)

    self.PanelRight = self.scene:getChildByName("Panel_right")

    self.scene:getChildByName("Text_jishi"):setVisible(false) -- 金手指时间显示

    self.lianshenNode = self.scene:getChildByName("lianshenNode")
    self.lianshen = 1
    self.pklianshen = 3
    if self.lianshen and self.lianshen > 0 then
        self.lianshenNode:setVisible(true)
        self.lianshenNode:getChildByName("imgbg"):loadTexture("res/icon/jiemian/icon_liansheng4.png")
        self.lianshenNode:getChildByName("lianShenNumtext"):setString(self.lianshen)

    end

    -- local iconImg = self.scene:getChildByName("Image_icon")
    -- local camp = mm.data.playerinfo.camp
    -- if 1 == camp then
    --     iconImg:loadTexture("res/icon/head/L023.png")
    -- else
    --     iconImg:loadTexture("res/icon/head/D074.png")
    -- end

    -- local vipImg = self.scene:getChildByName("Button_vip")
    -- gameUtil.addArmatureFile("res/Effect/uiEffect/vip/vip.ExportJson")
    -- local anime = ccs.Armature:create("vip")
    -- local animation = anime:getAnimation()
    -- vipImg:addChild(anime,-10)
    -- anime:setPosition(vipImg:getContentSize().width*0.5,vipImg:getContentSize().height*0.5)
    -- animation:play("vip")

    self.t6 = os.clock()

    -- 初始化按钮
    self:initBtn()

    self.t20 = os.clock()

    if mm.data.meleeStatus == 3 then
        --self.meleeBtn:setVisible(false)
    elseif mm.data.meleeStatus == 2 then
    elseif mm.data.meleeStatus == 1 then
    end

    self.myZhenNode = {}
    for i=1,5 do
        self.myZhenNode[i] = self.scene:getChildByName("hero"..i)
    end
    self:updateFrameUI()

    self:addTiBu()

    self.t21 = os.clock()

    --zhan
    local UnitTa = self:getUnitIDA()
    local UnitTb = self:getUnitIDB()
    fight:init({scene = self, unitTA = mm.puTongZhen, unitTB = UnitTb})
    --self:nextFight()
    -- local function aaa( ... )
    --     fight:cteateSkillSequence()
        --PlayFight:init({scene = self, fight = fight})
    -- end
    -- performWithDelay(self,aaa, 5)
    
    --zhan
    
    -- self.fightTick = nil

    self.t22 = os.clock()


    -- if mm.GuildId == 10001 then
    if true then
        -- fight:initNode()
        -- fight:initBattlefield({scene = self, unitTA = mm.puTongZhen, myplayerHero = mm.data.playerHero, typeA = 1,
        -- unitTB = UnitTb, diplayerHero = mm.data.playerHero, typeB = 1, GuaiWu = 1,
        -- })
        self:nnff()
    else
        performWithDelay(self, function()
            self:nextFight()
            PlayFight:init({scene = self, fight = fight})
        end, 1.5)

        
    end
    
    self.t23 = os.clock()

    self:updatereDate()

    self.t7 = os.clock()
    
    --self:loadstage()
    
    --cc.Director:getInstance():getScheduler():setTimeScale(0.6)

    mm.app = self.app_

    mm.hertTime = 0
    mm.startCheckHeartBeat(  ) 
    self.app_.clientTCP:addEventListener("heartbeat",mm.HeartBeatBack)
    self.app_.clientTCP:addEventListener("fiveRefreshNotify",mm.fiveRefreshNotify)
    self.app_.clientTCP:addEventListener("closeArea",mm.closeArea)
    self.app_.clientTCP:addEventListener("closeFunction",mm.closeFunction)
    self.app_.clientTCP:addEventListener("mailnotify",mm.mailNotify)
    self.app_.clientTCP:addEventListener("talk",mm.talk)
    self.app_.clientTCP:addEventListener("recharge",mm.recharge)
    self.app_.clientTCP:addEventListener("forbidLogin",mm.forbidLogin)
    self.app_.clientTCP:addEventListener("forbidTalk",mm.forbidTalk)
    self.app_.clientTCP:addEventListener("notifyStatus",mm.notifyStatus)
    
    schedule(self, self.updatereDate, 2)

    schedule(self, self.updateTime, 1)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))

    self:addListener()

    self.scene:setAnchorPoint(cc.p(0.5,0.5))
    local size  = cc.Director:getInstance():getWinSize()
    self.scene:setPosition(size.width * 0.5, size.height * 0.5)


    self.t8 = os.clock()
    

    self.ppp = {}
    self.ppp.x = self.scene:getPositionX()
    self.ppp.y = self.scene:getPositionY()

    self.goldText = self.scene:getChildByName("jinzitext")
    self.goldText:setString(mm.data.playerinfo.gold)
    self.goldTextNum = mm.data.playerinfo.gold
    self:scheduleUpdate()

    local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    local hasRaidsTimes = mm.data.playerExtra.hasRaidsTimes
    if hasRaidsTimes > 99 then
        hasRaidsTimes = 99
    end
    -- local allRaidsTimes = INITLUA:getVIPTabById( vipLv ).GoldFingerTimes
    local raidsText = self.scene:getChildByName("Button_shouzhi"):getChildByName("Image_1"):getChildByName("Text_1")
    raidsText:setString(hasRaidsTimes)

    self:checkIsRank()

    self.scene:getChildByName("Image_duanwei"):addTouchEventListener(handler(self, self.athleticsBtnCbk))
    self.scene:getChildByName("Image_duanwei"):setTouchEnabled(true)
    mm.GuildScene.duanweiBtn = self.scene:getChildByName("Image_duanwei")

    self.isnextFight = true

    mm.PanelGuideBtn =  self.scene:getChildByName("Panel_guide")
    local function begGuide( ... )
        if mm.GuildId >= 10001 and mm.GuildId < 10007 and gameUtil.getPlayerLv(mm.data.playerinfo.exp) < 30 then
            Guide:startGuildById(10001, self.scene:getChildByName("Panel_guide"))
        else
            mm.GuildId = 999999    
        end


        if self.touchlayer then
             self.touchlayer:removeFromParent()
        end
    end

    if gameUtil.getPlayerLv(mm.data.playerinfo.exp) > 30 then
         mm.GuildId = 999999
        cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "guideJinShouZhi",1)
        cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "guideJingYan",1)
    end

    begGuide()
    -- self:pinbi()

    local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    if vipLv >= 9 then
        performWithDelay(self, function()
            local tab = {}
            tab.type = 5
            tab.playerid = mm.data.playerinfo.id
            tab.message = "VIP."..vipLv..mm.data.playerinfo.nickname.."带着一身神装闪亮登场!!快来膜拜吧!"
            mm.req("talk",tab)
        end, 1)
    end

    mm.req("refreshEvent",{type=0})

    self.t9 = os.clock()

    -- 经验抽奖时间请求：
    self:initJingYanChouJingReminder()
    -- 至宝信息初始化
    self:initPreciousReminder()
    -- 定时提醒
    self:reminderInit()

    self.scene:getChildByName("Button_7"):setVisible(true)
    -- self.scene:getChildByName("Button_8"):setVisible(false)

    self.scene:getChildByName("Text_ranktime"):setVisible(false)

    self.isluoduoyindao = 1

    self.t10 = os.clock()

    self:goldUpdate()


    self:TapTapUI()
end

function FightScene:TapTapUI()

    local tianshiNode = self.scene:getChildByName("Node_tianshi")
    local id = 1278227504
    local skeletonNode = gameUtil.createSkeletonAnimationForUnit(gameUtil.getHeroTab(id).Src..".json", gameUtil.getHeroTab(id).Src..".atlas",1)
    tianshiNode:addChild(skeletonNode)
    skeletonNode:setPosition(0,0)
    skeletonNode:setScale(0.8)
    skeletonNode:setAnimation(0, "stand", true)
    self.tianShiSkeletonNode = skeletonNode


    self.scene:getChildByName("Button_Battle01"):setVisible(false)
    self.scene:getChildByName("Button_melee"):setVisible(false)
    self.scene:getChildByName("Button_jingjichang"):setVisible(false)
    self.scene:getChildByName("Button_Battle02"):setVisible(false)


    print("TapTapUI          "..#mm.puTongZhen)
    game.speedBuff = 1

    game.skillBtnTab = {}
    for i=1,#mm.puTongZhen do
        local id = mm.puTongZhen[i]
        print("TapTapUI   id       "..id)
        local HeroRes = gameUtil.getHeroTab( id )

        local skillId = HeroRes.Skills[1]
        local skillRes = gameUtil.getHeroSkillTab( skillId )
        local skillIconRes = skillRes.sicon

        print("TapTapUI   skillId       "..skillId)

        print("TapTapUI   skillIconRes       "..skillIconRes)

        local iconImageView = ccui.ImageView:create()
        iconImageView:loadTexture(skillIconRes..".png")  
        iconImageView:setTouchEnabled(true)
        iconImageView:addTouchEventListener(handler(self, self.SkillBtnCbk))
        iconImageView:setTag(id)
        game.skillBtnTab[id] = {}
        game.skillBtnTab[id].can = false


        self.scene:getChildByName("Node_skill_0"..i):addChild(iconImageView)

    end


end

function FightScene:SkillBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 

        local id = widget:getTag()
        print("TapTapUI   SkillBtnCbk       "..id)
        game.skillBtnTab[id].can = true

        local function aaa( ... )
            widget:setTouchEnabled(true)
            widget:setBright(true)
            widget:setScale(1)
        end
        widget:setTouchEnabled(false)
        widget:setBright(false)
        widget:setScale(0.8)
        
        performWithDelay(self,aaa, math.random(6,10))

    end

end

function FightScene:goldUpdate()
    local function goldTime( dt )
        local curGold = self.goldTextNum
        if self.mbGold and self.mbGold > curGold and self.mbGold < 1000000 then
            if ( self.mbGold - curGold ) < 5 then
                self.goldText:setString(self.mbGold)
                self.goldTextNum = self.mbGold
            else
                local jianGeGold = math.floor((self.mbGold - curGold) / 8)
                self.goldText:setString(curGold + jianGeGold)
                self.goldTextNum = curGold + jianGeGold
            end
        else
            self.goldText:setString(gameUtil.dealNumber(mm.data.playerinfo.gold))
            self.goldTextNum = mm.data.playerinfo.gold
        end

        if self.NodeTimeNum > 0 and self.curBloodText then
            self.NodeTimeNum = self.NodeTimeNum - dt
            self.NodeTimeBar:setPercent(math.ceil(self.NodeTimeNum / 30 * 100))
            self.curBloodText:setString( string.format("%.2f", self.NodeTimeNum))

            if self.NodeTimeNum <= 0 then
                --时间到，失败
                fight:setTimeZero()
            end
        else

        end
        
    end
    self.goldTick =  self:getScheduler():scheduleScriptFunc(goldTime, 0.064,false)


end

function FightScene:updateMoWuBtn()
    local wuStageRes = INITLUA:getStageResById(1093677361)
    local playerLv = gameUtil.getPlayerLv(mm.data.playerinfo.exp)
    if wuStageRes.LevelLowerLimit > playerLv then
        -- gameUtil.setGRAY(self.wumianBtn:getVirtualRenderer():getSprite())
        self.wumianBtn:setBright(false)
    else
        -- gameUtil.clearGRAY(self.wumianBtn:getVirtualRenderer():getSprite())
        self.wumianBtn:setBright(true)
    end

    local moStageRes = INITLUA:getStageResById(1093677105)
    if moStageRes.LevelLowerLimit > playerLv then
        -- gameUtil.setGRAY(self.momianBtn:getVirtualRenderer():getSprite())
        self.momianBtn:setBright(false)
    else
        -- gameUtil.clearGRAY(self.momianBtn:getVirtualRenderer():getSprite())
        self.momianBtn:setBright(true)
    end

    if 20 > playerLv then
        self.jjcBtn:setBright(false)
    else
        self.jjcBtn:setBright(true)
    end
end

function FightScene:upPlayerLv()
    self.playerLv = gameUtil.getPlayerLv(mm.data.playerinfo.exp)
    local defaultLv = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "PlayerLv",1)
    if self.playerLv > 17 and self.playerLv > defaultLv then
        local tab = {
                        scene = self, 
                        oldLv = defaultLv,
                        newLv = self.playerLv,
                    }

        local playerLvUpLayer = require("src.app.views.layer.playerLvUpLayer").new(tab)
        self:addChild(playerLvUpLayer, MoGlobalZorder[2999999])
        cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "PlayerLv",self.playerLv)
    else
        cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "PlayerLv",self.playerLv)
    end

    self:updateMoWuBtn()
end

function FightScene:pinbi( ... )
    local function onTouchBegan(touch, event)
        
        local location = touch:getLocation()
        event:stopPropagation()
        return true
    end

    if not self.touchlayer then
        local touchlayer = cc.Layer:create()
        self:addChild(touchlayer, MoGlobalZorder[2999999])
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher = touchlayer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchlayer)
        self.touchlayer = touchlayer
    end
end

    

function FightScene:updateRankUI(canUp)
    print("updateRankUI  ============     ")

    local canUp = canUp
    if canUp then
        local anime = gameUtil.createSkeAnmion( {name = "js",scale = 1} )
        anime:setAnimation(0, "stand", true)
        anime:setName("jsanime")
        self.scene:getChildByName("Node_duanwei"):removeAllChildren()
        self.scene:getChildByName("Node_duanwei"):addChild(anime,10)
        return
    end
    local res = "icon1"
    local curDuanWei = tonumber(mm.data.curDuanWei)
    if curDuanWei == 1093677105 
        or curDuanWei == 1093677106 
        or curDuanWei == 1093677107 
        or curDuanWei == 1093677108 
        or curDuanWei == 1093677109 then
        res = "icon1"
    elseif curDuanWei == 1093677110 
        or curDuanWei == 1093677111 
        or curDuanWei == 1093677112 
        or curDuanWei == 1093677113 
        or curDuanWei == 1093677360 then
        res = "icon2"
    elseif curDuanWei == 1093677361 
        or curDuanWei == 1093677362 
        or curDuanWei == 1093677363 
        or curDuanWei == 1093677364 
        or curDuanWei == 1093677365 then
        res = "icon3"
    elseif curDuanWei == 1093677366 
        or curDuanWei == 1093677367 
        or curDuanWei == 1093677368 
        or curDuanWei == 1093677369 
        or curDuanWei == 1093677616 then
        res = "icon4"
    elseif curDuanWei == 1093677617 
        or curDuanWei == 1093677618 
        or curDuanWei == 1093677619 
        or curDuanWei == 1093677620 
        or curDuanWei == 1093677621 then
        res = "icon5"
    elseif curDuanWei == 1093677622  then
        res = "ds"
    elseif curDuanWei == 1093677623 then
        res = "zqwz"
    else
        curDuanWei = 1093677105
        res = "icon1"
    end
    print("updateRankUI  ============     "..res)

    local anime = gameUtil.createSkeAnmion( {name = res, scale = 1.4} )
    anime:setAnimation(0, "stand", true)
    self.scene:getChildByName("Node_duanwei"):removeAllChildren()
    self.scene:getChildByName("Node_duanwei"):addChild(anime,10)
    anime:setName('duanwei')
    anime:setTag(curDuanWei)

    if res ~= "ds" and res ~= "zqwz" then
        local index = INITLUA:getDropOutRes()[curDuanWei]['RankIconNum']
        anime:setAttachment(res .."=",res .."=" ..index )
    end

end

function FightScene:addLoadingLayer( ... )

    g_fightLoadingLayer = cc.CSLoader:createNode("hei.csb")
    self:addChild(g_fightLoadingLayer, MoGlobalZorder[2999999])

    g_fightLoadingLayer:getChildByName("Panel"):setTouchEnabled(false)
    g_fightLoadingLayer:getChildByName("Image"):setTouchEnabled(false)
    g_fightLoadingLayer:getChildByName("Panel"):setScale(CC_DESIGN_RESOLUTION.height / 960)
    g_fightLoadingLayer:getChildByName("Image"):setScale(CC_DESIGN_RESOLUTION.height / 960)

    g_fightLoadingLayer:getChildByName("Text"):setVisible(true)
    g_fightLoadingLayer:setVisible(false)
    
end

function FightScene:addTiBu( ... )
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

function FightScene:updateTiBu( myFormation, myplayerHero, diFormation, diplayerHero )

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


function FightScene:setUpZhen()
    local formationNum = 1
    for i=1,#mm.data.playerFormation do
        if mm.data.playerFormation[i].type == 1 then
            formationNum = #mm.data.playerFormation[i].formationTab
        end
    end

    local HeroNum = #mm.data.playerHero
    if HeroNum > formationNum and formationNum < 5 then
        self.upZhen:setVisible(true)
    else
        self.upZhen:setVisible(false)
    end
end

function FightScene:addListener()
    self.listeners = {}
    local function eventCustomListener1( ... )
        
    end
    self.listeners[1] = cc.EventListenerCustom:create("event_come_to_background",eventCustomListener1)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[1], 1)

    local function eventCustomListener2( ... )
        mm.req("guaJiReward", {type = 1})

        game.iscometoforeground = true
        performWithDelay(self, function()
            game.iscometoforeground = false
        end, 3)

    end
    self.listeners[2] = cc.EventListenerCustom:create("event_come_to_foreground",eventCustomListener2)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[2], 1)

    local function eventCustomListener3( ... )
       -- self:captureScreenAndShare()
    end
    self.listeners[3] = cc.EventListenerCustom:create("shake_event",eventCustomListener3)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[3], 1)

    local function eventCustomListener4( ... )
        print("-----------------------推送信息返回----------------------")
        local userData =  SDKUtil:getPushMessageInfo()
        print("-----------------------推送信息返回----------------------"..userData)
        local t = json.decode(userData)
        --[[
        public static final String push_message_alias_key = "alias";
        public static final String push_message_content_key = "content";
        public static final String push_message_description_key = "description";
        public static final String push_message_extra_key = "extra";
        public static final String push_message_messageid_key = "messageid";
        public static final String push_message_messagetype_key = "messagetype";
        public static final String push_message_notifyid_key = "notifyid";
        public static final String push_message_notifytype_key = "notifytype";
        public static final String push_message_passThrough_key = "passThrough";
        public static final String push_message_title_key = "title";
        public static final String push_message_topic_key = "topic";
        public static final String push_message_useraccount_key = "useraccount";
        --]]

        local content = json.decode(t.content)
        local actionType = content.actionType
        print("-----------------------推送信息返回----------------------"..actionType)
        if actionType == "jumpTo" then
            local actionDes = content.actionDes
            self:jumpToLayer(actionDes)
        elseif actionType == "xxx" then
            
        end
    end
    self.listeners[4] = cc.EventListenerCustom:create("push_message",eventCustomListener4)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[4], 1)

    local function eventCustomListener5( ... )
       fight:initNode()
        mm.self = nil
        Guide:GuildEnd()
        self.app_:run("LoginSceneFinal")
    end
    self.listeners[5] = cc.EventListenerCustom:create("login_data_refesh",eventCustomListener5)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[5], 1)

end

function FightScene:updateFrameUI( ... )
    local HeroTab = mm.data.playerHero
    for i=1,#HeroTab do
        HeroTab[i].lv = gameUtil.getHeroLv(HeroTab[i].exp, HeroTab[i].jinlv)
    end
    for i=1,#self.myZhenNode do
        self.myZhenNode[i]:removeAllChildren()
        -- local dImageView = ccui.ImageView:create()
        -- dImageView:loadTexture("res/UI/jm_hero.png")
        -- self.myZhenNode[i]:addChild(dImageView)

        if mm.puTongZhen[i] then
            local tab = nil
            for j=1,#mm.data.playerHero do
                if mm.puTongZhen[i] == mm.data.playerHero[j].id then
                    tab = util.copyTab(mm.data.playerHero[j])
                    break
                end
            end
            if tab then
                local item = gameUtil.createItem(tab)
                self.myZhenNode[i]:addChild(item)
                item:addTouchEventListener(handler(self, self.notSceCbk))
                item:setAnchorPoint(cc.p(0.5,0.5))
                item:setPosition(self.myZhenNode[i]:getContentSize().width*0.5, self.myZhenNode[i]:getContentSize().height*0.5)
            end
        end
    end

    self:updatereDate()
end

function FightScene:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "recharge" then
            ----------充值更新钻石------------
            if event.t.type == 0 then
                local currentPalyer = mm.data.playerinfo
                local playerInfo = event.t.playerinfo
                local checkPass = false
                local hasRaidsTimes = event.t.hasRaidsTimes
                if hasRaidsTimes > 99 then
                    hasRaidsTimes = 99
                end

                mm.data.playerExtra.pkTimes = event.t.pkTimes
                
                local raidsText = self.scene:getChildByName("Button_shouzhi"):getChildByName("Image_1"):getChildByName("Text_1")
                raidsText:setString(hasRaidsTimes)
                if playerInfo.id == currentPalyer.id then
                    ------------需要更新UI------------
                    checkPass = true
                end
                if checkPass == true then
                    mm.data.playerinfo = playerInfo
                    
                    self:updatereDate()

                    if device.platform == "android" then
                        ---------TODO---------------
                    elseif device.platform == "ios" then
                        local infoTab = json.decode(event.t.info)
                        local info = {}
                        info.submitType = "PayConfirm"
                        info.acAccount_ios = infoTab.uid
                        info.orderId_ios = infoTab.orderid
                        info.itemPrice_ios = infoTab.money
                        info = json.encode(info)

                        SDKUtil:submitExtendData(info) 
                    end
                    self:showRechargeHint(event.t.num)
                end
            end
        elseif event.code == "readMail" then
            mm.data.noReadNum = event.t.num
        elseif event.code == "mailnotify" then
            mm.data.noReadNum = event.t.num
        elseif event.code == "meleeEnter" then
            self:meleeEnterBack(event.t)
        elseif event.code == "saveFormation" then
            print("checkIsRank            000000000000000     ")
            self:checkIsRank()
        elseif event.code == "guaJiReward" then
            if event.t.type ~= 1 then

                local top5 = self:getTop5(mm.data.dropTab)

                mm.GuildScene:upPlayerLv()

                local tab = {
                                scene = self, 
                                RaidsTimes = mm.data.guajiTime, 
                                exp = mm.data.addExp,
                                gold = mm.data.addGold, 
                                poolExp = mm.data.addPoolExp,
                                wupinA =    mm.data.guajiWuPin,
                                wupinB = {},
                                top5 = top5,
                                type = 1,
                                allDropTab = mm.data.dropTab,
                            }

                local JSZjiangliLayer = require("src.app.views.layer.JSZjiangliLayer").new(tab)
                -- self:addChild(JSZjiangliLayer, MoGlobalZorder[2000002])

                if mm.GuildId == 10015 then
                    self:addChild(JSZjiangliLayer, MoGlobalZorder[2000002])
                else
                    self:addChild(JSZjiangliLayer, MoGlobalZorder[2999999])
                end

            end
            
        elseif event.code == "fiveRefreshNotify" then
            local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
            local hasRaidsTimes = mm.data.playerExtra.hasRaidsTimes
            if hasRaidsTimes > 99 then
                hasRaidsTimes = 99
            end
            -- local allRaidsTimes = INITLUA:getVIPTabById( vipLv ).GoldFingerTimes
            local raidsText = self.scene:getChildByName("Button_shouzhi"):getChildByName("Image_1"):getChildByName("Text_1")
            raidsText:setString(hasRaidsTimes)
            --gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "fiveRefreshNotify",z = 3000})
        elseif event.code == "notifyStatus" then
            if event.t.meleeStatus == 1 then -- 预备
                self.meleeBtn:setVisible(true)
            elseif event.t.meleeStatus == 2 then -- 开启
                self.meleeBtn:setVisible(true)
            elseif event.t.meleeStatus == 3 then -- 结束
                self.meleeBtn:setVisible(true)
            end
        elseif event.code == "Raids" then
            if mm.RaidsTwoHour then
                self.RaidsGuajiWuPin = mm.data.RaidsGuajiWuPin
                self.RaidsAddPoolExp = mm.data.RaidsAddPoolExp
                self.RaidsAddGold = mm.data.RaidsAddGold
                self.RaidsAddExp = mm.data.RaidsAddExp
                self.RaidsGuajiTime = mm.data.guajiTime
                self.RaidsDropTab = mm.data.RaidsDropTab
                mm.RaidsTwoHour = false

                print("Raidsmm.GuildIdmm.GuildIdmm.GuildIdmm.GuildId   "..mm.GuildId)
                if mm.GuildId == 10039 then
                    cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "guideJinShouZhi",1)
                    self.scene:getChildByName("Text_jishi"):setVisible(true)
                    self.scene:getChildByName("Text_jishi"):setString("05:00")
                -- elseif mm.GuildId == 10040 or mm.GuildId == 10041  then
                    
                else

                    self:readyGo()
                end
                --self.beginRaids = true
            elseif mm.RaidsDianji then
                self.RaidsDianJIGuajiWuPin = mm.data.RaidsGuajiWuPin
                self.RaidsDianJIAddPoolExp = mm.data.RaidsAddPoolExp
                self.RaidsDianJIAddGold = mm.data.RaidsAddGold
                self.RaidsDianJIAddExp = mm.data.RaidsAddExp
                self.RaidsDianJIGuajiTime = mm.data.guajiTime
                self.RaidsDianJIDropTab = mm.data.RaidsDropTab
                mm.RaidsDianji = false

                if self.RaidsDianJIDropTab and #self.RaidsDianJIDropTab > 0 then
                    for k,v in pairs(self.RaidsDianJIDropTab) do
                        local ishas = false
                        if self.RaidsDropTab == nil then self.RaidsDropTab = {} end
                        for k1,v1 in pairs(self.RaidsDropTab) do
                            if v1.id == v.id then
                                v.num = v.num + v1.num
                                ishas = true
                                break
                            end
                        end
                        if not ishas then
                            table.insert(self.RaidsDropTab,v)
                        end
                    end
                end

                mm.GuildScene:upPlayerLv()

                local top5 = self:getTop5(self.RaidsDropTab)

                local tab = {
                    scene = self, 
                    RaidsTimes = self.RaidsGuajiTime + self.RaidsDianJIGuajiTime, 
                    exp = self.RaidsAddExp + self.RaidsDianJIAddExp,
                    gold = self.RaidsAddGold + self.RaidsDianJIAddGold,
                    poolExp = self.RaidsAddPoolExp + self.RaidsDianJIAddPoolExp,
                    wupinA =    self.RaidsGuajiWuPin,
                    wupinB = self.RaidsDianJIGuajiWuPin,
                    top5 = top5,
                    allDropTab = self.RaidsDropTab,
                }

                local JSZjiangliLayer = require("src.app.views.layer.JSZjiangliLayer").new(tab)
                self:addChild(JSZjiangliLayer, MoGlobalZorder[2000002])


                self.RaidsGuajiWuPin = nil
                self.RaidsAddPoolExp = nil
                self.RaidsAddGold = nil
                self.RaidsAddExp = nil
                self.RaidsGuajiTime = nil
                self.RaidsDianJIGuajiWuPin = nil
                self.RaidsDianJIAddPoolExp = nil
                self.RaidsDianJIAddGold = nil
                self.RaidsDianJIAddExp = nil
                self.RaidsDianJIGuajiTime = nil

                self.isnextFight = true
                performWithDelay(self, function ()
                    -- body
                    self:clearUnit()
                    
                    self:nextFight()
                end, 0.5)


            end
        elseif event.code == "talk" then
            self:ReceiveTalk(event.t)
        elseif event.code == "rankUp" then
            self:playDuanWei()
            -- self:updateRankUI()

            self.curRankUp = mm.data.curDuanWei

            if #mm.Layout == 0 then
                self:backFightScene()
            end
            
            performWithDelay(self, function ()
                self:checkIsRank()
            end, 1)
        elseif event.code == "closeArea" then
            local WarningLayer = require("src.app.views.layer.WarningLayer").new({app_ = self.app_, fight = fight})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(WarningLayer, MoGlobalZorder[2000002])
            WarningLayer:setContentSize(cc.size(size.width, size.height))
            WarningLayer:setPosition(cc.p(0, 0))
            ccui.Helper:doLayout(WarningLayer)
        elseif event.code == "forceLogout" then
            local WarningLayer = require("src.app.views.layer.WarningLayer").new({app_ = self.app_, fight = fight, forceLogout = true})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(WarningLayer, MoGlobalZorder[2000002])
            WarningLayer:setContentSize(cc.size(size.width, size.height))
            WarningLayer:setPosition(cc.p(0, 0))
            ccui.Helper:doLayout(WarningLayer)
        elseif event.code == "forbidLogin" then
            local WarningLayer = require("src.app.views.layer.WarningLayer").new({app_ = self.app_, fight = fight, lockEndTime = event.t.lockEndTime})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(WarningLayer, MoGlobalZorder[2000002])
            WarningLayer:setContentSize(cc.size(size.width, size.height))
            WarningLayer:setPosition(cc.p(0, 0))
            ccui.Helper:doLayout(WarningLayer)
        elseif event.code == "getActivityInfo" then
            if event.t.type == 0 then
                mm.data.activityInfo = event.t.activityInfo
                mm.data.activityRecord = event.t.activityRecord
                mm.data.publicActivityExtraInfo = event.t.publicActivityExtraInfo

                self:refreshActivityHint()
                self:refreshActivityNew()
            end
        elseif event.code == "rewardActivity" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                mm.data.activityInfo = event.t.activityInfo
                mm.data.activityRecord = event.t.activityRecord
                mm.data.publicActivityExtraInfo = event.t.publicActivityExtraInfo

                self:refreshActivityHint()
                self:refreshActivityNew()

                self:showRewardResult(event.t.rewardID)
            end
        elseif event.code == "buyFund" then
            if event.t.type == 0 then
                mm.data.playerinfo = event.t.playerinfo
                mm.data.playerExtra = event.t.playerExtra
                mm.data.activityRecord = event.t.activityRecord

                self:refreshActivityHint()
                self:refreshActivityNew()
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
               self:refreshActivityNew()
            end
        elseif event.code == "refreshEvent" then
            if event.t.type == 0 then
                mm.data.eventData = event.t.data
                local tempData = mm.data.eventData

                for k,v in pairs(tempData) do
                    if v.key == "storeGreenPoint" then
                        if v.value == "fuckTrue" then
                            gameUtil.addGreenPoint(self.shangchengBtn)
                        else
                            gameUtil.removeGreenPoint(self.shangchengBtn)
                        end
                        break
                    end
                end
            end
        elseif event.code == "luckdraw" then
            self:fetchTimeFromLuckDraw(event.t)
        elseif event.code == "getItem" then
            PA:setupNewItems(mm.data.playerItem)
        end
        if mm.data.noReadNum > 0 then
            gameUtil.addRedPoint(self.moreBtn)
        else
            gameUtil.removeRedPoint(self.moreBtn)
        end


        --检测是否可以晋升
        if event.code == "heroLevelUp"
            or event.code == "heroUpXin"
            or event.code == "heroUpPinJie"
            or event.code == "heroHeChen"
            or event.code == "heroUpequip"
            or event.code == "skillup"
            --todo pk
        then
            self:updatereDate()
            performWithDelay(self, function ()
                self:checkIsRank()
            end, 0.2)

        elseif event.code == "fiveRefreshNotify" then
            local Anime = self.scene:getChildByName("Node_duanwei"):getChildByName("duanwei")
            local tag = 0
            if Anime then
                tag = Anime:getTag()
            end
            if tonumber(tag) ~= mm.data.curDuanWei then
                -- self:playDuanWei()
                self:checkIsRank()
                
                self.curRankUp = event.t.myMaxRank

                if self.curRankUp and (not mm.Layout or #mm.Layout == 0)  then
                    self:backFightScene()
                end
            end
        end


    end
    if event.name == EventDef.UI_MSG then
        if event.code == "refreshMainUI" then
            self:updatereDate()
        elseif event.code == "CountHeroDiedTime" then
            if self.HeroDiedTab == nil then
                self.HeroDiedTab = {}
            end
            local tab = {}
            tab.heroId = event.heroId
            tab.camp = event.camp
            table.insert(self.HeroDiedTab, tab)
        elseif event.code == "closePkLayer" then
            self.pkLayerFlag = nil
            local str = ""
            if event.flag == 3 then
                self.nextFightTextTag = 1
            elseif event.flag == 4 or event.flag == 5 then
                self.nextFightTextTag = 2
            elseif event.flag == 10 then
                self.nextFightTextTag = 10
            elseif event.flag == 20 then
                self.nextFightTextTag = 20
            else
                self.nextFightTextTag = 0
            end
            if self.nextFightTextTag == 1 then
                local stageRes = INITLUA:getStageResById(mm.diFangZhen.stageId)
                str = stageRes.StageName
                self.scene:getChildByName("Text_next_fight"):setVisible(true)
            elseif self.nextFightTextTag == 2 then
                str = mm.diFangZhen.nickname
                self.scene:getChildByName("Text_next_fight"):setVisible(true)
            elseif self.nextFightTextTag == 10 then
                str = mm.diFangZhen.nickname
                self.scene:getChildByName("Text_next_fight"):setVisible(true)
            elseif self.nextFightTextTag == 20 then
                str = mm.diFangZhen.nickname
                self.scene:getChildByName("Text_next_fight"):setVisible(true)
            else
                self.scene:getChildByName("Text_next_fight"):setVisible(false)

                if mm.GuildId == 10205 then
                    Guide:GuildEnd()
                elseif mm.GuildId == 10308 then
                    -- Guide:GuildEnd()
                    -- self.isluoduoyindao = 1
                elseif mm.GuildId == 10408 then
                    Guide:GuildEnd()
                end

                
            end
            self.scene:getChildByName("Text_next_fight"):setString(MoGameRet[990010]..str)

            mm.GuildScene.nextFightTextBtn = self.scene:getChildByName("Text_next_fight")
        elseif event.code == "openPkLayer" then
            self.pkLayerFlag = true
        elseif event.code == "jumpToLayer" then
            self:jumpToLayer(event.layerName, event.param)
        elseif event.code == "vipGift" then
            -- vip礼包添加红点
            if gameUtil.canBuyGift() == 1 then
                gameUtil.addRedPoint(self.goldBtn, 0.95, 0.9)
            else
                gameUtil.removeRedPoint(self.goldBtn)
            end
        elseif event.code == "storeRefreshed" then
            local needPoint = self.checkStorePoint()
            if needPoint == true then
                gameUtil.addGreenPoint(self.shangchengBtn)
            else
                gameUtil.removeGreenPoint(self.shangchengBtn)
            end
        end
    end
end


function FightScene:mailShuaxin( ... )
    if mm.data.noReadNum > 0 then
        gameUtil.addRedPoint(self.moreBtn)
    else
        gameUtil.removeRedPoint(self.moreBtn)
    end
end


function FightScene:backFightScene( ... )
    if self.curRankUp then
        local JinjichenggongLayer = require("src.app.views.layer.JinjichenggongLayer").new()
        if mm.GuildId == 15003 or mm.GuildId == 15053 then
            self:addChild(JinjichenggongLayer, MoGlobalZorder[2000003])
        else
            self:addChild(JinjichenggongLayer, MoGlobalZorder[2900000])
        end
        self.curRankUp = nil    
    end

    mm.GuildScene:checkGuild()
end

function FightScene:backFightSceneBackup( ... )
    game:dispatchEvent({name = EventDef.UI_MSG, code = "backFightSceneBackup"}) 
end

function FightScene:jumpToLayer( name, param )
    if name == "youjianLayer" then
        if gameUtil.isFunctionOpen(closeFuncOrder.MAIL_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.youjianLayer",
                            resName = "youjianLayer",params = {app = self.app_, typeLayer = 1, scene = self}} )
    elseif name == "Chongzhi" then
        if gameUtil.isFunctionOpen(closeFuncOrder.RECHARGE_ENTER) == true then
            local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(PurchaseLayer, MoGlobalZorder[2999999])
            PurchaseLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(PurchaseLayer)
        end

    elseif name == "ShangChengLayer" then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        if gameUtil.isFunctionOpen(closeFuncOrder.SHOP_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        local toLayer = 1
        if param then
            toLayer = param.typeLayer
        end
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ShangChengLayer",
                            resName = "ShangChengLayer",params = {typeLayer = toLayer, scene = self}} )
    elseif name == "HeroListLayer" then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end
        gameUtil.removeRedPoint(self.heroBtn)
        -- local BagLayer = require("src.app.views.layer.BagLayer").create({app = self.app_, typeLayer = 1, scene = self })
        -- local size  = cc.Director:getInstance():getWinSize()
        -- mm.pushLayoer( {scene = self, layer = BagLayer, clear = 1, zord = 50} )
        -- BagLayer:setContentSize(cc.size(size.width, size.height))
        -- ccui.Helper:doLayout(BagLayer)

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.HeroListLayer",
                             resName = "HeroListLayer",params = {app = self.app_}} )
    elseif name == "PKLayer" then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        if self.pkLayerFlag ~= nil then
            self.pkLayerFlag = nil
            mm.popLayer()
            return
        end
        
        -- 如果正在PK战斗中，不让查看pk界面
        if mm.PkTiShi ~= nil then
            gameUtil:addTishi({p = self.scene, s = MoGameRet[990018]})
            self.pkLayerFlag = nil
            mm.popLayer()
            return
        end

        if self.pkLayerFlag == nil then
            self.pkLayerFlag = true

            if gameUtil.isFunctionOpen(closeFuncOrder.PK_ENTER) == false then
                gameUtil:addTishi({s = MoGameRet[990047]})
                return
            end
            
            mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.PKLayer",
                                 resName = "PKLayer",params = {app = self.app_, typeLayer = 1, scene = self, hintText = param.hintText }} )
        end
    elseif name == "Jingyanchoujiang" then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        if gameUtil.isFunctionOpen(closeFuncOrder.HERO_LIST_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.JingYanChouJiangLayer",
                             resName = "JingYanChouJiangLayer",params = {app = self.app_, scene = self}} )
    elseif name == "TalkLayer" then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end
        local TalkLayer = require("src.app.views.layer.TalkLayer").new(self.app_)
        TalkLayer:setName("TalkLayer")
        local size  = cc.Director:getInstance():getWinSize()
        --mm.pushLayoer( {scene = self, layer = TalkLayer, zord = 2000} )
        self:addChild(TalkLayer, MoGlobalZorder[2000002])
        TalkLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(TalkLayer)
    elseif name == "StageDetailLayer" then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        local stageID = nil
        if param then
            if param.stageID then
                stageID = param.stageID
                local playerLv = gameUtil.getPlayerLv(mm.data.playerinfo.exp)
                local stageRes = INITLUA:getStageResById(stageID)

                if stageRes.LevelLowerLimit > playerLv then
                    local hintText = stageRes.LevelLowerLimit..MoGameRet[990020]
                    gameUtil:addTishi({s = hintText})
                    return
                end
            elseif param.stageType then
                -- local stageInfo = gameUtil.getShowStageInfoWithOutOpenDay(3)
                local stageInfo = gameUtil.getShowStageInfoWithOutOpenDay(param.stageType)
                stageID = stageInfo.ID
            end
        end
        if stageID == nil then
            return
        end

        local curStageRes = INITLUA:getStageResById(stageID)
        local order = closeFuncOrder.PK_ENTER
        if curStageRes.StageType == MM.EStageType.STAD then
            order = closeFuncOrder.PK_AD
        elseif curStageRes.StageType == MM.EStageType.STAP then
            order = closeFuncOrder.PK_AP
        elseif curStageRes.StageType == MM.EStageType.STGirl then
            order = closeFuncOrder.PK_GIRL
        elseif curStageRes.StageType == MM.EStageType.STBeast then
            order = closeFuncOrder.PK_BEAST
        elseif curStageRes.StageType == MM.EStageType.STBattle then
            order = closeFuncOrder.PK_BATTLE
        end

        if gameUtil.isFunctionOpen(order) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.StageDetailLayer",
                             resName = "StageDetailLayer",params = {app = self.app_, stageId = stageID}} )
    elseif name == "JJCLayer" then
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.JJCLayer",
                             resName = "JJCLayer",params = {app = self.app_, scene = self}} )
    elseif name == "HeroLayer" then
        local heroId = gameUtil.GetStarMaxHeroId()
        gameUtil:goToSomeWhere( self, "HeroLayer", {app = self.app_, heroId = heroId, LayerTag = 3})
    elseif name == "PVPLayer" then
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.PVPLayer",
                            resName = "PVPLayer",params = {app = self.app_, typeLayer = 1, scene = self }} )
    end
end

function FightScene:showRewardResult( rewardId )
    local rewardResultLayer = require("src.app.views.layer.RewardResultLayer").new( {rewardID = rewardId, scene = self} )
    self:addChild(rewardResultLayer, MoGlobalZorder[2999999])
end

function FightScene:playDuanWei()
    self.scene:getChildByName("Panel_heibg_2"):setVisible(true)
    self.scene:getChildByName("Panel_heibg_2"):setLocalZOrder(MoGlobalZorder[1000003])
    self.scene:getChildByName("Node_duanwei"):setLocalZOrder(MoGlobalZorder[1000003])

    local up_play = gameUtil.createSkeAnmion( {name = "dwsj",scale = 1} )
    up_play:setAnimation(0, "stand", false)
    up_play:setScale(2)

    local posX = self.scene:getChildByName("Node_duanwei"):getPositionX()
    local posY = self.scene:getChildByName("Node_duanwei"):getPositionY()
    self.scene:addChild(up_play, MoGlobalZorder[1000003])
    local size = self.scene:getChildByName("Node_duanwei"):getContentSize()
    up_play:setPosition(posX, posY + 25)

    performWithDelay(self,function( ... )
        up_play:removeFromParent()
        self.scene:getChildByName("Panel_heibg_2"):setVisible(false)
        self.scene:getChildByName("Node_duanwei"):setLocalZOrder(MoGlobalZorder[1000003])
    end, 0.6)

end

function FightScene:getTop5( tab1, top5 )
    local top5 = top5 or {}
    if tab1 == nil or #tab1 == 0 then
        return top5
    end
    for k,v in pairs(tab1) do
        local id = v.id
        local type = v.type
        local num = v.num
        local pingjia = 0
        if MM.EDropType.DT_HunShi == type then
            local tab = INITLUA:getEquipByid(id)
            if not tab then
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "id 不在装备表",z = 3000})
            end
            pingjia = tab.eq_rate

        elseif type == MM.EDropType.DT_LinJian or
                type == MM.EDropType.DT_HeChenPin or
                type == MM.EDropType.DT_JuanZhou or
                type == MM.EDropType.DT_SuiPian then
                local tab = INITLUA:getEquipByid(id)
                if not tab then
                    gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "id 不在装备表",z = 3000})
                end
                pingjia = tab.eq_rate

        elseif type == MM.EDropType.DT_jingyandan then
        else
        end

        if not pingjia then
            pingjia = 0
        end

        if #top5 < 5 then
            table.insert(top5, {id = id, pingjia = pingjia, type = type , num = num})
        else
            for index=1,#top5 do
                if pingjia > top5[index].pingjia then
                    table.remove(top5)
                    table.insert(top5, {id = id, pingjia = pingjia, type = type , num = num})
                    break
                end
            end
        end
        table.sort(top5,function(left,right)
            return left.pingjia > right.pingjia
        end)

        

    end
    return top5
end

function FightScene:readyGo( ... )
    self.readygoNode = self.scene:getChildByName("readygoNode")
    self.jszBtn:setTouchEnabled(false)

    local function play( ... )
        self.lianshenNode:getChildByName("imgbg"):setVisible(false)
        self.lianshenNode:getChildByName("lianShenNumtext"):setVisible(false)

        -- 添加ready go特效
        -- gameUtil.addArmatureFile("res/Effect/uiEffect/rdgo/rdgo.ExportJson")
        -- local rdGo = ccs.Armature:create("rdgo")
        -- self:addChild(rdGo, MoGlobalZorder[2000002])
        -- local size = cc.Director:getInstance():getWinSize()
        -- rdGo:setPosition(size.width/2, size.height*0.8)
        -- rdGo:setScale(1.3)
        -- rdGo:getAnimation():playWithIndex(0)

        local rdGo = gameUtil.createSkeAnmion( {name = "rdgo",scale = 1} )
        rdGo:setAnimation(0, "stand", false)
        self:addChild(rdGo, MoGlobalZorder[2000002])
        local size = cc.Director:getInstance():getWinSize()
        rdGo:setPosition(size.width/2, size.height*0.8)

        self.scene:getChildByName("Panel_heibg"):setVisible(true)



        local time = 0
        local jishi = self.scene:getChildByName("Text_jishi")
        jishi:setVisible(true)
        jishi:setString("05:00")
        local dtime = 0
        local function showTime(dt)
            dtime = dtime + dt
            if dtime >= 5 then
                jishi:setVisible(false)
                self.isnextFight = true
                if self.shouzhiImg then
                    self.shouzhiImg:stopAllActions()
                    self.shouzhiImg:removeFromParent()
                    self.shouzhiImg = nil
                end
                self.jszBtn:setTouchEnabled(true)
                coroutine.resume(self.co, self)

                self:getScheduler():unscheduleScriptEntry(self.jszTick)
                return
            end
            jishi:setString(string.format("%02d:%02d", math.floor((5000 - dtime * 1000)/1000), (5000 - dtime * 1000)%100)  )
        end

        -- local function animationEventEnd(armatureBack, movementType, movementID)
        --     if movementType == ccs.MovementEventType.complete then
        --         performWithDelay(self,function( ... )
        --             rdGo:removeFromParent()
        --             self:beginJSZ()
        --             self.scene:getChildByName("Panel_heibg"):setVisible(false)
        --             self.jszTick =  self:getScheduler():scheduleScriptFunc(showTime, 0.064,false)
        --             self.lianshenNode:getChildByName("imgbg"):setVisible(true)
        --             self.lianshenNode:getChildByName("lianShenNumtext"):setVisible(true)
                    
        --         end, 0.01)
        --     end
        -- end
        -- rdGo:getAnimation():setMovementEventCallFunc(animationEventEnd)
        performWithDelay(self,function( ... )
            -- rdGo:removeFromParent()
            self:beginJSZ()
            self.scene:getChildByName("Panel_heibg"):setVisible(false)
            self.jszTick =  self:getScheduler():scheduleScriptFunc(showTime, 0.064,false)
            self.lianshenNode:getChildByName("imgbg"):setVisible(true)
            self.lianshenNode:getChildByName("lianShenNumtext"):setVisible(true)
            
        end, 1.2)


        local icon_jinshouzhi = ccui.ImageView:create()
        icon_jinshouzhi:loadTexture("res/UI/icon_jinshouzhi.png")
        self:addChild(icon_jinshouzhi, MoGlobalZorder[2800000])
        icon_jinshouzhi:setPosition(self.readygoNode:getPositionX(),self.readygoNode:getPositionY())
        self.shouzhiImg = icon_jinshouzhi

        local action = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0,-30)),cc.MoveBy:create(0.2, cc.p(0,30)) ))
        icon_jinshouzhi:runAction(action)


        self.initlianshen = self.lianshen

        coroutine.yield()

        mm.RaidsDianji = true
        mm.req("Raids",{type=0, time = self.lianshen - self.initlianshen})
    end

    self.co = coroutine.create(function()
        play()
    end)
    coroutine.resume(self.co, self)

end


function FightScene:updateTime( ... )
    self.scene:getChildByName("Text_ranktime"):setVisible(true)
    if mm.data.ranktime > 0 then
        self.scene:getChildByName("Text_ranktime"):setString("晋升冷却:".. util.timeFmt(mm.data.ranktime))
        self.canRankUp = false
        self:checkIsRank()
    else
        local curZhanli = gameUtil.getPlayerForce()
        local curRank = mm.data.curDuanWei
        local DropOutTab = INITLUA:getDropOutRes()
        local torank = DropOutTab[tonumber(curRank)]['RankUpID']
        self.torank = torank
        if tonumber(torank) ~= 0 then
            local needZhanli = DropOutTab[tonumber(torank)]['RankFightNum']
            --当前段位小于钻石5 战斗力大于晋升所需的战斗力
            if tonumber(curRank) < 1093677617  then
                self.scene:getChildByName("Text_ranktime"):setString("晋升战力:".. needZhanli)
                if curZhanli > needZhanli then
                    self.canRankUp = true
                    self:checkIsRank(true)
                end
            else
                self.scene:getChildByName("Text_ranktime"):setVisible(false)
            end
        else
            self.scene:getChildByName("Text_ranktime"):setVisible(false)
        end
    end
end

function FightScene:updatereDate( ... )


    local hasRaidsTimes = mm.data.playerExtra.hasRaidsTimes --已经使用次数
    -- local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    -- local allRaidsTimes = INITLUA:getVIPTabById( vipLv ).GoldFingerTimes
    if hasRaidsTimes > 99 then
        hasRaidsTimes = 99
    end
    local raidsText = self.scene:getChildByName("Button_shouzhi"):getChildByName("Image_1"):getChildByName("Text_1")
    raidsText:setString(hasRaidsTimes)

    -- 金币
    
    self.mbGold = mm.data.playerinfo.gold

    -- 钻石
    self.diamondText = self.scene:getChildByName("zuanshitext")
    self.diamondText:setText(gameUtil.dealNumber(mm.data.playerinfo.diamond))

    local allZhanli = 0
    for i=1,5 do
        if mm.puTongZhen[i] then
            for j=1,#mm.data.playerHero do
                if mm.puTongZhen[i] == mm.data.playerHero[j].id then
                    tab = util.copyTab(mm.data.playerHero[j])
                    local zhanli = gameUtil.Zhandouli( tab ,mm.data.playerHero, mm.data.playerExtra.pkValue)
                    if zhanli then
                        allZhanli = allZhanli + zhanli
                    end
                end
            end
           
        end
    end

    -- self.zhandouliText = self.scene:getChildByName("shenbingtext")
    -- self.zhandouliText:setText("战斗力：" .. allZhanli)

    -- --经验池
    -- self.scene:getChildByName("Image_jingyan"):setLocalZOrder(30)
    -- self.expPool = self.scene:getChildByName("LoadingBar_jingyan")
    -- self.expPool:setLocalZOrder(28)
    -- local expValue = mm.data.playerinfo.exppool or 0
    -- local num = expValue / (PEIZHI.EXP_POOL_BASE + mm.data.playerinfo.level * PEIZHI.EXP_POOL_ADD) * 100
    -- self.expPool:setPercent(100-num)
    -- if self.ExpAnime == nil then
    --     gameUtil.addArmatureFile("res/Effect/uiEffect/exp/exp.ExportJson")
    --     self.ExpAnime = ccs.Armature:create("exp")
    --     self.ExpAnime:setScale(0.8)
    --     self.ExpAnime:setAnchorPoint(cc.p(0.5, 1))
    --     self.scene:addChild(self.ExpAnime, MoGlobalZorder[1000003])
    --     self.ExpAnime:setPosition(self.expPool:getPositionX()-4, self.expPool:getPositionY()-2)
    -- end
    -- -- if self.ExpAnime2 == nil then
    -- --     gameUtil.addArmatureFile("res/Effect/uiEffect/exp02/exp02.ExportJson")
    -- --     self.ExpAnime2 = ccs.Armature:create("exp02")
    -- --     self.ExpAnime2:setAnchorPoint(cc.p(0.5, 1))
    -- --     self.scene:addChild(self.ExpAnime2,29)
    -- -- end
    -- local animation = self.ExpAnime:getAnimation()
    -- -- local animation2 = self.ExpAnime2:getAnimation()
    -- -- animation:play("exp")

    -- -- if num ~= 100 then
    -- --     local offset = num / 100
    -- --     self.ExpAnime2:setPosition(self.expPool:getPositionX(), self.expPool:getContentSize().height*offset)
    -- --     animation2:play("exp02")
    -- -- end

    -- 有任务奖励可领取的时候显示小红点
    local flag = 0
    self.taskLayerTag = 2
    local taskRes = INITLUA:getTaskRes()
    for k,v in pairs(taskRes) do
        if gameUtil.CanShow(v) then
            local aProgress = gameUtil.GetTaskProgress(v)
            local taskConditionValue = v.TaskConditionValue

            local finish = false
            if v.TaskType == MM.ETaskType.TT_RankLevel then
                if aProgress <= taskConditionValue and aProgress ~= 0 then
                    finish = true
                end
            else
                if aProgress >= taskConditionValue then
                    finish = true
                end
            end

            if finish == true then 
                gameUtil.addRedPoint(self.chengjiuBtn)
                flag = 1
                self.taskLayerTag = v.TaskClassify
                break
            end
        end
    end
    if flag == 0 then
        gameUtil.removeRedPoint(self.chengjiuBtn)
    end

    -- 有装备可穿的时候添加小红点
    local flag = 0
    for i=1,#mm.data.playerHero do
        local eqTab = mm.data.playerHero[i].eqTab
        local jinTab = gameUtil.getEquipId( mm.data.playerHero[i].id, mm.data.playerHero[i].jinlv )
        if jinTab == nil then
            cclog("装备表资源错误！！！")
        end
        for j=1,6 do
            local t = gameUtil.getHeroEqByIndex( eqTab, j )
            local eqId = jinTab.EquipEx[j]
            local eqRes = INITLUA:getEquipByid(eqId)
            if t == nil or t.eqIndex == nil or t.eqId == nil then
                if gameUtil.isHasEquip( eqId ) and gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= eqRes.eq_needLv then
                    gameUtil.addRedPoint(self.heroBtn)
                    flag = 1
                    break
                end
            end
        end
        if flag == 1 then
            break
        end
    end
    -- 英雄可升星 添加红点
    local needAddXingRedPoint = false
    for k,v in pairs(mm.data.playerHero) do
        if gameUtil.canShengXing(v.id, v.xinlv) == 1 then
            gameUtil.addRedPoint(self.heroBtn)
            needAddXingRedPoint = true
            break
        end
    end
    if mm.data.playerExtra.skillNum >= 10 then
        needAddXingRedPoint = true
    end
    if needAddXingRedPoint == true then
        game:dispatchEvent({name = EventDef.UI_MSG, code = "addXingRedPoint"})
    end

    if flag == 0 then
        gameUtil.removeRedPoint(self.heroBtn)
    end

    if gameUtil.canZhaoHuan() == 1 then
        gameUtil.addRedPoint(self.heroBtn)
    end

    -- vip礼包添加红点
    if gameUtil.canBuyGift() == 1 then
        gameUtil.addRedPoint(self.goldBtn)
    end

    -- local lv = gameUtil.getPlayerLv(mm.data.playerinfo.exp)

    -- if lv >= 22 then
    --     if mm.data.playerExtra.pkTimes > 0 then
    --         gameUtil.addRedPoint(self.stageBtn)
    --     else
    --         gameUtil.removeRedPoint(self.stageBtn)
    --     end
    -- end

    self:setUpZhen()

    
end


function FightScene:checkGuild( ... )
    local lv = gameUtil.getPlayerLv(mm.data.playerinfo.exp)

    if lv >= 20 and lv < 30 then
        local GuideIdjingji = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideIdjingji",0)
        if GuideIdjingji ~= 1 then
            mm:clearLayer()
            cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideIdjingji",1)
            Guide:startGuildById(10701, mm.GuildScene.jjcBtn)
            
        end
    end

    -- if lv >= 20 and lv < 22 then
    --     local GuideId20 = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideId20",0)
    --     if GuideId20 ~= 1 then
    --         mm:clearLayer()
    --         cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId20",1)
    --         Guide:startGuildById(10101, mm.GuildScene.shangchengBtn)
            
    --     end
    -- elseif lv >= 22 and lv < 25 then
    --     local GuideId22 = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideId22",0)
    --     if GuideId22 ~= 1 then
    --         mm:clearLayer()
    --         cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId22",1)
    --         Guide:startGuildById(10201, mm.GuildScene.stageBtn)
            
    --     end
    -- elseif lv >= 25 and lv < 30 then
    --     local GuideId25 = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideId25",0)
    --     if GuideId25 ~= 1 then
    --         mm:clearLayer()
    --         cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId25",1)
    --         Guide:startGuildById(10301, mm.GuildScene.stageBtn)
            
    --     end
    -- elseif lv >= 30 and lv < 35 then
    --     local GuideId30 = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideId30",0)
    --     if GuideId30 ~= 1 then
    --         mm:clearLayer()
    --         cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId30",1)
    --         Guide:startGuildById(10401, mm.GuildScene.stageBtn)
            
    --     end
    -- elseif lv >= 35 and lv < 40 then
    --     local GuideId35 = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideId35",0)
    --     if GuideId35 ~= 1 then
            
    --         cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId35",1)
    --         local item01 = nil
    --         local item02 = nil
    --         local item03 = nil
    --         for k,v in pairs(mm.data.playerItem) do
    --             if v.id == 1227895609 and v.num >= 16 then
    --                 item01 = true
    --             end
    --             if v.id == 1513107504 and v.num >= 5 then
    --                 item02 = true
    --             end
    --             if v.id == 1513107505 and v.num >= 1 then
    --                 item03 = true
    --             end
    --         end
    --         if item01 and item02 and item03 then
    --             mm:clearLayer()
    --             Guide:startGuildById(10501, mm.GuildScene.heroBtn)
    --         end
            
    --     end
    -- elseif lv >= 45 and lv < 50 then
    --     local GuideIdjingji = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideId45",0)
    --     if GuideId45 ~= 1 then
    --         mm:clearLayer()
    --         cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId45",1)
    --         Guide:startGuildById(10601, mm.GuildScene.stageBtn)
            
    --     end
    -- end
end

function FightScene:checkIsRank( ... )
    --战斗力刷新，可升段则提醒
    local curZhanli = gameUtil.getPlayerGuaJiForce()
    local curRank = mm.data.curDuanWei
    local DropOutTab = INITLUA:getDropOutRes()

    if tonumber(curRank) == 1093677623 then
        self.canRankUp = false
        self:updateRankUI(nil)
        return
    end

    local torank = DropOutTab[tonumber(curRank)]['RankUpID']
    self.torank = torank
    print("updateRankUI  =======   "..torank)
    if tonumber(torank) ~= 0 then
        local needZhanli = DropOutTab[tonumber(torank)]['RankFightNum']
        --当前段位小于钻石5 战斗力大于晋升所需的战斗力
        if tonumber(curRank) < 1093677617 and curZhanli > needZhanli and mm.data.ranktime <= 0 then
            self.canRankUp = true
            self:updateRankUI(true)
        else
            self.canRankUp = false
            self:updateRankUI(nil)
        end
    end
end

local testId = 1278227254
local testId01 = 1278227254

function FightScene:getUnitIDA( ... )
    local TA = {1278226736, 1278226740, 1278226995, 1278227254, 1278227512}
    local TA = {1278226736, 1278226740, 1278226995}
    --local TA = {testId, testId, testId, testId, testId}
    return TA
end

function FightScene:getUnitIDB( ... )
    local camp = mm.data.playerinfo.camp
    local num = math.random(1,3)
    local TB = {1278227766}
    
    if 1 == camp then
        -- local tab = {1144010804, 1144009528, 1144010548, 1144009784, 1144010038}
        -- for i=1,num do
        --     table.insert(TB,tab[i])
        -- end
        TB = {1144009526}
    else
        -- local tab = {1278226736, 1278226740, 1278226995, 1278227254, 1278227512}
        -- for i=1,num do
        --     table.insert(TB,tab[i])
        -- end
        TB = {1278227254}
    end
    
    --local TB = {testId01, testId01, testId01, testId01, testId01}
    return TB
end

function FightScene:beginJSZ( ... )
        self.isnextFight = false
        fight:initNode()
        self:addUnit()
end

function FightScene:anOnceNextFight( ... )
    self:clearUnit()
    self:reSetUnit()
    self:nextFight()
    self:stopActionByTag(500)
    self:stopActionByTag(501)
end

function FightScene:jszBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.began then
        widget:getChildByName("Image_1"):setScale(0.7)
    elseif touchkey == ccui.TouchEventType.canceled then
        widget:getChildByName("Image_1"):setScale(1)
    elseif touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(13)
        widget:getChildByName("Image_1"):setScale(1)
        if gameUtil.isFunctionOpen(closeFuncOrder.GOLD_FINGER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end
        if not self.isnextFight then
            return
        end
        local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
        local hasRaidsTimes = mm.data.playerExtra.hasRaidsTimes 
        local RaidsTimes = mm.data.playerExtra.RaidsTimes--已经使用次数
        -- local allRaidsTimes = INITLUA:getVIPTabById( vipLv ).GoldFingerTimes --总次数
        if hasRaidsTimes > 0 then
            local guideJinShouZhi =  cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "guideJinShouZhi",0)
            print("guideJinShouZhi    "..guideJinShouZhi)
            if 0 == guideJinShouZhi then
                mm.GuildId = 10037
            end


            local JSZshiyong = require("src.app.views.layer.JSZshiyong").new({scene = self, RaidsTimes = RaidsTimes, hasRaidsTimes = hasRaidsTimes})
            self:addChild(JSZshiyong, MoGlobalZorder[2000002])
        else
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "提升VIP等级增加次数"})
        end
    end
end

function FightScene:getJSZIDB( ... )
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

function FightScene:initUnit(  )
    mm.unitPosA = {}
    mm.unitPosB = {}
    --A阵营
    for i=1,5 do
        local node = self.scene:getChildByName("a_"..i)
        mm.unitPosA[i] = {}
        mm.unitPosA[i].x = node:getPositionX()
        mm.unitPosA[i].y = node:getPositionY()
    end

    --B阵营
    for i=1,5 do
        local node = self.scene:getChildByName("b_"..i)
        mm.unitPosB[i] = {}
        mm.unitPosB[i].x = node:getPositionX()
        mm.unitPosB[i].y = node:getPositionY()
    end
end

function FightScene:reSetUnit(  )
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

function FightScene:addUnit(  )
    self:reSetUnit()

    local unitTA = mm.puTongZhen

    self.jszNodeA = {}

    --B阵营
    for i=1,5 do
        if unitTA[i] then
            local node = self.scene:getChildByName("a_"..i)
            
            local skeletonNode = gameUtil.createSkeletonAnimation(gameUtil.getHeroTab(unitTA[i]).Src..".json", gameUtil.getHeroTab(unitTA[i]).Src..".atlas",1)
            self:addChild(skeletonNode, MoGlobalZorder[2000002])
            skeletonNode:setName("skeletonNode")
            skeletonNode:update(0.012)
            skeletonNode:setAnimation(0, "stand", true)
            skeletonNode:setPosition(node:getPositionX(),node:getPositionY())
            skeletonNode:setScaleX(0.6)
            skeletonNode:setScaleY(0.6)

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
            
            local skeletonNode = gameUtil.createSkeletonAnimation(gameUtil.getHeroTab(unitTB[i]).Src..".json", gameUtil.getHeroTab(unitTB[i]).Src..".atlas",1)
            self:addChild(skeletonNode, MoGlobalZorder[2000002])
            skeletonNode:setName("skeletonNode")
            skeletonNode:update(0.012)
            skeletonNode:setScaleX(-0.6)
            skeletonNode:setScaleY(0.6)
            skeletonNode:setAnimation(0, "stand", true)
            skeletonNode:setPosition(node:getPositionX(),node:getPositionY())
            skeletonNode:setTag(unitTB[i])
            self.jszNode[i] = skeletonNode
        end
    end
end

function FightScene:clearUnit(  )
    if self.jszNodeA then
        for k,v in pairs(self.jszNodeA) do
            v:removeFromParent()
        end
    end

    if self.jszNode then
        for k,v in pairs(self.jszNode) do
            v:removeFromParent()
        end
    end
end


function FightScene:addBarrageLayer() 
    
    local BarrageLayer = require("src.app.views.layer.BarrageLayer").new({tag = "FightScene"})
    BarrageLayer:setName("BarrageLayer")
    self:addChild(BarrageLayer, MoGlobalZorder[2999999])
    local size  = cc.Director:getInstance():getWinSize()
    BarrageLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(BarrageLayer)
end

function FightScene:onEnter() 
    if mm.guaJiReward == nil then
        local function begGuide( ... )

            if mm.data.guajiWuPin and mm.GuildId ~= 10001 then

                mm.GuildScene:upPlayerLv()

                local top5 = self:getTop5(mm.data.dropTab)

                local tab = {
                                scene = self, 
                                RaidsTimes = mm.data.guajiTime, 
                                exp = mm.data.addExp,
                                gold = mm.data.addGold, 
                                poolExp = mm.data.addPoolExp,
                                wupinA =    mm.data.guajiWuPin,
                                wupinB = {},
                                top5 = top5,
                                type = 1,
                                allDropTab = mm.data.dropTab,
                            }
                local JSZjiangliLayer = require("src.app.views.layer.JSZjiangliLayer").new(tab)
                self:addChild(JSZjiangliLayer, MoGlobalZorder[2999999])

            end

            self:addLoadingLayer()

            self:checkIsRank()

            self:showGuide()

            self.curRankUp = mm.data.myMaxRank
            self:backFightScene()  
        end
        performWithDelay(self,begGuide, 0.01)
    else
        mm.guaJiReward = nil


        local function getDiRenListBack( event )
            if event.type == 0 then
                mm.direninfo = util.copyTab(event.direninfo)
                fight:initNode()
                self:reSetUnit()
                self:nextFight()
            else
            end
        end
        self.app_.clientTCP:send("getDiRenList",{type=0},getDiRenListBack)
    end
    
end

function FightScene:showGuide( ... )
    -- Guide:btnGuild(self.heroBtn)
end

function FightScene:onCleanup() 
    self:getScheduler():unscheduleScriptEntry(self.goldTick)
    if self.listeners ~= nil then 
        for k,v in pairs(self.listeners) do
           self:getEventDispatcher():removeEventListener(v)
        end
    end

    self:clearAllGlobalEventListener()
end

function FightScene:nextFight( ... )
    if self.isnextFight == false then
        return
    end
    local diZhen = nil
    local diZhu = nil
    local diType = nil 
    if mm.diFangZhen then
        diZhen = mm.diFangZhen.formation
        diZhu = mm.diFangZhen.zhuZhen
        diType = mm.diFangZhen.diType
        mm.PkTiShi = 1
    end
    local allZhanli = 0
    local nickname = nil
    local diPlayerInfo = nil
    print("nextFight         1111111111")
    self.curDiZhen = util.copyTab(mm.diFangZhen)
    mm.curDiZhen = self.curDiZhen
    local diplayerHero = mm.data.playerHero

    self.nextFightTextTag = 0 -- 记录下场战斗的提示文字类型
    if (diZhen == nil or #diZhen == 0) then
    end
    local direnPkValue = nil
    if (diZhen == nil or #diZhen == 0) and mm.direninfo then
        print("nextFight         222222222")
        mm.puTongZhen = {}
        mm.zhuZhen = {}
        for k,v in pairs(mm.data.playerFormation) do
            if v.type == 1 then
                for x, y in pairs(v.formationTab) do
                    table.insert(mm.puTongZhen, y.id)
                end
                if v.helpFormationTab and #v.helpFormationTab > 0 then
                    for x, y in pairs(v.helpFormationTab) do
                        table.insert(mm.zhuZhen, y.id)
                    end
                end
                break
            end
        end

        self.nextFightTextTag = 0
        diZhen = {}
        diZhu = {}
        if mm.direnIndex > #mm.direninfo then
            mm.direnIndex = 1
        end
        local difangInfo = mm.direninfo[mm.direnIndex]
        self.difangInfo  = difangInfo
        direnPkValue = self.difangInfo.pkValue
        local difangForm = difangInfo.playerFormation
        if difangForm then
            diPlayerInfo = difangInfo.playerinfo
            nickname = difangInfo.playerinfo.nickname

            -- if self.fntnode then
            --     self.fntnode:removeFromParent()
            --     self.fntnode = nil
            -- end
            -- self.fntnode =  gameUtil.createFont("fonts/huakang.TTF", 40, str, cc.c3b(255, 0, 0), 10)
            -- self.scene:getChildByName("fntNode"):addChild(self.fntnode)

            local f = {}
            local z = {}
            for i=1,#difangForm do
                if difangForm[i].type == 1 then
                    f = difangForm[i].formationTab
                    z = difangForm[i].helpFormationTab
                end
            end
            if f then
                for i=1,#f do
                    table.insert(diZhen,f[i].id)
                end
                if z then
                    for k,v in pairs(z) do
                        table.insert(diZhu,v.id)
                    end
                end
                diplayerHero = difangInfo.playerHero

                mm.direnIndex = mm.direnIndex + 1
                if mm.direnIndex > #mm.direninfo then
                    local function getDiRenListBack( event )
                        if event.type == 0 then
                            mm.direninfo = util.copyTab(event.direninfo)
                            mm.direnIndex = 1
                        else
                            mm.direninfo = nil
                            mm.direnIndex = nil
                            mm.diFangZhen = nil
                        end
                    end
                    if self.app_.clientTCP then
                        self.app_.clientTCP:send("getDiRenList",{type=0},getDiRenListBack)
                    end
                end
            end

        else
            mm.direnIndex = mm.direnIndex + 1
        end
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
        
        self.scene:getChildByName("Image_2"):loadTexture("res/FightBg/ground_lvdi.png")
        self.scene:getChildByName("Image_4"):loadTexture("res/FightBg/land_guaji.png")
        self.scene:getChildByName("Image_5"):loadTexture("res/FightBg/sky_lvdi.png")
    else
        print("nextFight         333333333333")
        if mm.diFangZhen.diType and mm.diFangZhen.diType == 3 then
            self.nextFightTextTag = 1
            local stageRes = INITLUA:getStageResById(mm.diFangZhen.stageId)
            for i=1,#stageRes.StageEnemy do
                local enemyRes = INITLUA:getMonsterResById(stageRes.StageEnemy[i])
                allZhanli = allZhanli + enemyRes.monster_power
            end
            nickname = stageRes.StageName

            mm.puTongZhen = {}
            mm.zhuZhen = {}
            local chapter = 1
            if stageRes.StageType == MM.EStageType.STUpLevel then
                chapter = 1
            else
                chapter = stageRes.StageType + 100
            end
            for k,v in pairs(mm.data.playerFormation) do
                if v.type == chapter then
                    for x, y in pairs(v.formationTab) do
                        table.insert(mm.puTongZhen, y.id)
                    end
                    if v.helpFormationTab and #v.helpFormationTab > 0 then
                        for x, y in pairs(v.helpFormationTab) do
                            table.insert(mm.zhuZhen, y.id)
                        end
                    end
                    break
                end
            end
        elseif mm.diFangZhen.diType == 10 then
            print("nextFight         555555555")
            self.nextFightTextTag = 2
            allZhanli = mm.diFangZhen.zhandouli
            nickname = mm.diFangZhen.nickname
            diPlayerInfo = mm.diFangZhen.playerInfo
            diplayerHero = mm.diplayerHero

            mm.puTongZhen = {}
            mm.zhuZhen = {}
            for k,v in pairs(mm.data.playerFormation) do
                if v.type == 10 then
                    for x, y in pairs(v.formationTab) do
                        table.insert(mm.puTongZhen, y.id)
                    end
                    if v.helpFormationTab and #v.helpFormationTab > 0 then
                        for x, y in pairs(v.helpFormationTab) do
                            table.insert(mm.zhuZhen, y.id)
                        end
                    end
                    break
                end
            end
        -- elseif mm.diFangZhen.diType == 10 then
        --     print("nextFight         555555555 20")
        --     self.nextFightTextTag = 2
        --     allZhanli = mm.diFangZhen.zhandouli
        --     nickname = mm.diFangZhen.nickname
        --     diPlayerInfo = mm.diFangZhen.playerInfo
        --     diplayerHero = mm.diplayerHero

        --     mm.puTongZhen = {}
        --     for k,v in pairs(mm.data.playerFormation) do
        --         if v.type == 10 then
        --             for x, y in pairs(v.formationTab) do
        --                 table.insert(mm.puTongZhen, y.id)
        --             end
        --             break
        --         end
        --     end

        else
            print("nextFight         444444444444")
            self.nextFightTextTag = 2
            allZhanli = mm.diFangZhen.zhandouli
            nickname = mm.diFangZhen.nickname
            diPlayerInfo = mm.diFangZhen.playerInfo
            diplayerHero = mm.diplayerHero

            mm.puTongZhen = {}
            mm.zhuZhen = {}
            for k,v in pairs(mm.data.playerFormation) do
                if v.type == 2 then
                    for x, y in pairs(v.formationTab) do
                        table.insert(mm.puTongZhen, y.id)
                    end
                    if v.helpFormationTab and #v.helpFormationTab then
                        for x, y in pairs(v.helpFormationTab) do
                            table.insert(mm.zhuZhen, y.id)
                        end
                    end
                    break
                end
            end
        end
        game:dispatchEvent({name = EventDef.UI_MSG, code = "closePkLayer", flag = 1})

        self.scene:getChildByName("Image_2"):loadTexture("res/FightBg/ground_rongyan.png")
        self.scene:getChildByName("Image_4"):loadTexture("res/FightBg/land_rongyan.png")
        self.scene:getChildByName("Image_5"):loadTexture("res/FightBg/sky_rongyan.png")
    end

    self:updateFrameUI()
    -- local str = ""
    -- if mm.data.playerinfo.camp == 1 then
    --     str = "D狗 ".. nickname
    -- else
    --     str = "L狗 ".. nickname
    -- end
    --self.scene:getChildByName("nametext_0"):setString(str)
    if self.VSLayer ~= nil then
        self.VSLayer:removeFromParent()
    end

    print("yyyyyyyyyyyyyyyyyy   000  "..self.isluoduoyindao)
    self.VSLayer = require("src.app.views.layer.VSLayer").new({scene = self, zhandouli = allZhanli, nickname = nickname, diPlayerInfo = diPlayerInfo, isluoduoyindao = self.isluoduoyindao})
    self:addChild(self.VSLayer, MoGlobalZorder[2000001])
    -- local size  = cc.Director:getInstance():getWinSize()
    -- self.VSLayer:setContentSize(cc.size(size.width, size.height))
    -- ccui.Helper:doLayout(self.VSLayer)

    if self.isluoduoyindao and self.isluoduoyindao == 4 then
        local dtime = 0
        local function closeyindao(dt)
            dtime = dtime + dt
            if dtime >= 8 then
                self.isluoduoyindao = 0
                if game.ydnode then
                    game.ydnode:setVisible(false)
                end
                self:getScheduler():unscheduleScriptEntry(self.ldyd)
                return
            end
        end
        self.ldyd =  self:getScheduler():scheduleScriptFunc(closeyindao, 0.064,false)
    end

    fight:initNode()

    -- fight:initBattlefield({scene = self, unitTA = mm.puTongZhen or self:getUnitIDA(),zhuZhenA = mm.zhuZhen, myplayerHero = mm.data.playerHero, myPkValue = mm.data.playerExtra.pkValue, typeA = 1,
    --     unitTB = diZhen or self:getUnitIDB(),zhuZhenB = diZhu,diplayerHero = diplayerHero or mm.data.playerHero, diPkValue = direnPkValue, typeB = diType or 1
    --     })


    
    self:updateTiBu(mm.puTongZhen, mm.data.playerHero, diZhen, diplayerHero)

    mm.diFangZhen = nil


    -- local function aaa( ... )
    --     fight:cteateSkillSequence()
    -- end
    -- performWithDelay(self,aaa, 5)

    --fight:cteateSkillSequence()
    

    -- local bg01 = {
    --     {"sky_xuedi.png","land_xuedi.png","ground_xuedi.png"},
    --     {"sky_lvdi.png","land_lvdi.png","ground_lvdi.png"},
    --     {"sky_rongyan.png","land_rongyan.png","ground_rongyan.png"},
    -- }
    
    -- local rr = math.random(1,3)
    -- self.scene:getChildByName("Image_5"):loadTexture("res/FightBg/"..bg01[rr][1])
    -- self.scene:getChildByName("Image_4"):loadTexture("res/FightBg/"..bg01[rr][2])
    -- self.scene:getChildByName("Image_2"):loadTexture("res/FightBg/"..bg01[rr][3])

end


function FightScene:nnffInit(  )

    if not self.herpNNFF then
        self.herpNNFF = {}
        for k,v in pairs(LOL) do
            if v.Nation ~= 9 then
                table.insert(self.herpNNFF,v.ID)
            end
        end

        for k,v in pairs(DOTA) do
            if v.Nation ~= 9 then
                table.insert(self.herpNNFF,v.ID)
            end
        end
    end

    local num = math.random(1,#self.herpNNFF)
    local TB = {self.herpNNFF[num]}
    return TB
end

function FightScene:nnffInfo(  )
    print("YYYYY         11111111111111111111111111    nnffInfo              111  ")
    local tab = {}
    local nnffID = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "nnffID",1)
    print("YYYYY         11111111111111111111111111    nnffInfo              111  "..nnffID)
    tab.blood = 5000 + nnffID * 1000 + math.random(3000, 5000) 
    tab.size = 1
    tab.time = 0
    if self.curNnffId > 1 then
        tab.blood = 5000 + nnffID * 3000 + math.random(3000, 5000) 
        self.curNnffId = 0
        tab.size = 1.2
        tab.time = 30

        self:showBlood()
    else
        self.NodeTimeNum = 0
        self.Node_Time:setVisible(false)
    end

    return tab
end

function FightScene:showBlood( ... )

    if not self.NodeTimeBar then

        local imageView = ccui.ImageView:create()
        imageView:loadTexture("res/UI/jm_xuetiaodi.png")
        self.Node_Time:addChild(imageView)


        local loadingBar = ccui.LoadingBar:create()
        loadingBar:loadTexture("res/UI/jm_xuetiao_hong.png")
        loadingBar:setPercent(100)
        self.Node_Time:addChild(loadingBar)
        loadingBar:setVisible(true)
        self.NodeTimeBar = loadingBar

        self.curBloodText = ccui.Text:create("30", "fonts/huakang.TTF", 30)
        self.curBloodText:setColor(cc.c3b(205, 149, 12))
        self.curBloodText:setPosition(cc.p(-50,10))
        self.NodeTimeBar:addChild(self.curBloodText)
    else
        self.NodeTimeBar:setVisible(true)
    end

    self.NodeTimeNum = 30
    self.Node_Time:setVisible(true)
end

function FightScene:taptapInit( ... )
    self.curNnffId = 1
    self.NodeTimeNum = 0

    self.Node_Time = self.scene:getChildByName("Node_Time")
end


function FightScene:nnff(  )
    print("YYYYY         11111111111111111111111111    isOverisOverisOverisOverisOver       1111")

    if self.NodeTimeNum > 0 then
        local nnffID = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "nnffID",1)
        cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "nnffID",nnffID + 1)
    end

    fight:initNode()
    local UnitTa = self:getUnitIDA()
    local UnitTb = self:getUnitIDB()
    fight:init({scene = self, unitTA = mm.puTongZhen, unitTB = UnitTb})
    fight:initBattlefield({scene = self, unitTA = mm.puTongZhen, myplayerHero = mm.data.playerHero, typeA = 1,
                    unitTB = self:nnffInit(), diplayerHero = mm.data.playerHero, typeB = 1, GuaiWu = 1, nnffInfo = self:nnffInfo()
                    })
    self.curNnffId = self.curNnffId + 1
end

function FightScene:beginShake( btime,etime )
    --self.scene:setScale(1.03)
    
    self.shakeDt = 0
    self.shakeD = 0.09
    self.shakeTime = 0
    self.shakeETime = etime
    self.shakeBTime = btime
    self.isShake = 1
end

function FightScene:endShake( ... )
    self.scene:setScale(1)
    self.scene:setPosition(self.ppp)
    self.isShake = false
    
end

function FightScene:scheduleUpdate( ... )
    -- 开始更新逻辑
    local function update(dt) self:fightLogic(dt) end
    self:scheduleUpdateWithPriorityLua(update, 0)
end

function FightScene:fightLogic( dt )
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

function FightScene:shakePos(pos, level)
    if level == nil then
        level = 30
    end
    local x = self:randomWithRange(pos.x-level, pos.x+level)
    local y = self:randomWithRange(pos.y-level, pos.y+level)
    return cc.p(x, y)
end

function FightScene:randomWithRange(l, r)
    return math.random(l,r)
end

function FightScene:addTalkMsg( msg )
    local tab = {}

    mm.talkMsg = mm.talkMsg or {}
    mm.talkMsg[4] = mm.talkMsg[4] or {}


    local guajiresult = "战斗胜利 - "
    if msg.result ~= 1 then
        guajiresult = "战斗失败 - "
    end

    local guajileixin = "(挂机战斗)"
    local stageT
    if msg.stageId and msg.stageId > 0 then
        stageT = INITLUA:getStageResById(msg.stageId)
        guajileixin = "(" .. stageT.StageName .. ")"
    end


    local startDate = os.date("*t", os.time())
    local tt = string.format('%02.0f:%02.0f:%02.0f', startDate.hour, startDate.min, startDate.sec)
    local t = {a = guajiresult, b = tt, c = guajileixin, guajiResult = msg.result, str = guajiresult .. tt .. guajileixin}
    tab.biaoti = t

    if msg.addGold and msg.addGold > 0 then
        local t = {a = "金币: ", b = msg.addGold, str = "金币: " .. msg.addGold}
        tab.addGold = t
    end

    if msg.addExp and msg.addExp > 0 then
        local t = {a = "战队经验: ", b = msg.addExp, str = "战队经验: " .. msg.addExp}
        tab.addExp = t
    end

    if msg.addExppool and msg.addExppool > 0 then
        local t = {a = "经验池经验: ", b = msg.addExppool, str = "经验池经验: " .. msg.addExppool}
        tab.addExppool = t
    end

    if msg.addhonors and msg.addhonors > 0 then
        local t = {a = "荣誉: ", b = msg.addhonors, str = "荣誉: " .. msg.addhonors}
        tab.addhonors = t
    end

    if stageT then
        StageType = stageT.StageType
        if StageType ~= MM.EStageType.STUpLevel then
            local t = {a = "PK币: ", b = 100, str = "PK币: " .. 100}
            tab.pkbi = t
        end

    end

    if msg.dropTab and #msg.dropTab > 0 then
        tab.drop = {}
        for k,v in pairs(msg.dropTab) do
            local name = nil
            local wupinT = nil
            if v.type == 2 then
                wupinT = INITLUA:getItemByid( v.id )
                name = wupinT.Name
            else
                wupinT = INITLUA:getEquipByid( v.id )
                name = wupinT.Name
            end
            if name and v.num > 0 then
                local t = {a = name, b = v.num, wupinT = wupinT, str = name .. " x " .. v.num}
                table.insert(tab.drop, t)
            end
        end
        
    end 

    table.insert(mm.talkMsg[4], tab)
end
  
function FightScene:jiesuan( t )
    if self.isnextFight == false then
        return
    end

    mm.PkTiShi = nil
    local result = t.result
    local lastKillUnitTime =  t.lastKillUnitTime
    local overTime = t.overTime

    local function fightBack( msg )
        local type = msg.type
        if type == 0 then
            g_fightLoadingLayer:stopAllActions()
            mm.data.playerinfo = msg.playerinfo or {}
            mm.data.playerEquip = msg.playerEquip or {}
            mm.data.playerItem = msg.playerItem or {}
            mm.data.playerHunshi = msg.playerHunshi or {}
            mm.data.playerHero = msg.playerHero or {}
            mm.data.playerStage = msg.playerStage or {}
            mm.data.playerExtra.pkValue = msg.pkValue
            mm.data.ranktime = msg.ranktime or mm.data.ranktime
            local result   = msg.result
            local addExp = msg.addExp or 0
            local addGold = msg.addGold or 0
            local addMoney = msg.addMoney or 0
            local diFinfo = util.copyTab(self.difangInfo) or {}
            local stageId = msg.stageId
            local addExppool = msg.addExppool or 0


            mm.onePlayAddGold = mm.onePlayAddGold + addGold
            mm.onePlayAddExp = mm.onePlayAddExp + addExp 
            mm.onePlayaddExppool = mm.onePlayaddExppool + addExppool
            local TalkMsgTab = msg
            TalkMsgTab.addGold = mm.onePlayAddGold
            TalkMsgTab.addExp = mm.onePlayAddExp
            TalkMsgTab.addExppool = mm.onePlayaddExppool
            self:addTalkMsg(TalkMsgTab)

            mm.onePlayAddGold = 0
            mm.onePlayAddExp = 0
            mm.onePlayaddExppool = 0
            
            if stageId and stageId > 0 and result == 1 then
                StageType = INITLUA:getStageResById(stageId)['StageType']
                if StageType == MM.EStageType.STUpLevel then
                    for k,v in pairs(INITLUA:getDropOutRes()) do
                        local camp = mm.data.playerinfo.camp
                        if 1 == camp then
                            if v['LStageID'] == stageId then
                                mm.req("rankUp",{type=0, toRank = v['ID']})
                                break
                            end
                        else
                            if v['DStageID'] == stageId then
                                mm.req("rankUp",{type=0, toRank = v['ID']})
                                break
                            end
                        end
                        
                    end
                else
                    local tab = {
                                    scene = self, 
                                    exp = addExp,
                                    gold = addGold, 
                                    poolExp = msg.addExppool,
                                    dropTab = msg.dropTab,
                                    result = result,
                                    allDropTab = msg.dropTab,
                                    stageId = msg.stageId,
                                    StageType = StageType,
                                }
                    if StageType == MM.EStageType.STBattle then
                        tab.exp = 0
                        tab.poolExp = 0
                    end                
                    local TiaoZhanGhengGongLayer = require("src.app.views.layer.TiaoZhanGhengGongLayer").new(tab)
                    self:addChild(TiaoZhanGhengGongLayer, MoGlobalZorder[2999999])

                    if not self.talkBtn:getChildByName("newHint") then
                        gameUtil.addNewImg( self.talkBtn )
                    else
                        self.talkBtn:getChildByName("newHint"):setVisible(true)
                    end
                end
            end

            if msg.fightType == 10 and msg.enemyid and msg.enemyid > 1 and result == 1 then
                local JJCWinLayer = require("src.app.views.layer.JJCWinLayer").new({before = msg.startIndex,after = msg.endIndex, honor = msg.addHonor})
                self:addChild(JJCWinLayer, MoGlobalZorder[2999999])
            end

            print(" fightTypefightTypefightType    "..msg.fightType)

            if msg.fightType == 20 and msg.enemyid and msg.enemyid > 1 and result == 1 then
                -- gameUtil:addTishi({s = MoGameRet[990501]})
                if game.jujiZhanli then
                    local JUJIWin = require("src.app.views.layer.JUJIWin").new({})
                    self:addChild(JUJIWin, MoGlobalZorder[2999999])
                end

                print(" fightTypefightTypefightType    "..msg.enemyid)
                print(" fightTypefightTypefightType    "..result)

                print("yyyyyyyyyyyyyyyyyy   111  "..self.isluoduoyindao)
                local GuideIdjuji = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "GuideIdjuji",0)
                print("yyyyyyyyyyyyyyyyyy   111 GuideIdjuji "..GuideIdjuji)
                if GuideIdjuji ~= 1 then
                    self.isluoduoyindao = 4
                    cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideIdjuji",1)
                else
                    self.isluoduoyindao = 999
                end
            end

            local fightResultLayer = require("src.app.views.layer.AccountLayer").new({scene = self, result = result, dropTab = msg.dropTab})
            self.scene:getChildByName("NodeLayer"):addChild(fightResultLayer)
            self.scene:getChildByName("NodeLayer"):setLocalZOrder(MoGlobalZorder[1000003])
            local size  = cc.Director:getInstance():getWinSize()
            fightResultLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(fightResultLayer)

            self:updatereDate()

        else

        end
    end
    local stageId = 0
    local diType = 1
    local emId = 1
    if self.curDiZhen ~= nil then
        stageId = self.curDiZhen.stageId or 0
        diType = self.curDiZhen.diType or 1
        local pkType = self.curDiZhen.pkType
        if diType == 10 then
            emId = self.curDiZhen.playerInfo.id
        elseif diType == 20 then
            emId = self.curDiZhen.playerInfo.id
        end

        if pkType == 20 then
            diType = 20
        end
    end

    if result == 1 then
        self.lianshen = self.lianshen + 1
    else
        self.lianshen = 0
    end

    self:updateLianShen( 1 )

    local failtime = overTime - lastKillUnitTime
    if self.app_.clientTCP then
        print(emId .. " =============jiesuan ======= "..diType)
        self.app_.clientTCP:send("fight",{type=diType,result=result,enemyid=emId,heroDiedTab = self.HeroDiedTab, stageId = stageId, failtime = failtime, userAction = game.userAction},fightBack)
    end
    self.HeroDiedTab = nil
    self.curDiZhen = nil
    mm.curDiZhen = nil

    -- if g_fightLoadingLayer then
    --     g_fightLoadingLayer:setVisible(true)
    --     performWithDelay(g_fightLoadingLayer,function( ... )
    --         g_fightLoadingLayer:getChildByName("Text"):setVisible(true)
    --     end , 5)
    -- end
end

function FightScene:refreshBlood( t )
    local curABlood = t.curABlood 
    local initABlood = t.initABlood 
    local curBBlood = t.curBBlood 
    local initBBlood = t.initBBlood 
    
    game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshBlood", curABlood = curABlood, initABlood = initABlood,curBBlood = curBBlood,initBBlood = initBBlood})
end

function FightScene:zhandouBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        

        mm:clearLayer()

        -- self:nextFight()
        -- self:jiesuan()

        -- if self.state == "idle" then
        --     self.fightTick = self:getScheduler():scheduleScriptFunc(function(step)
        --         self.fight:update(step)
        --     end, 0.03,false)
    
        --     self.state = "fight"
            
        --     self.zhandouBtn:setTitleText("暂停")
        --     self.fight:zhandou()
        -- else 
        --     self.state = "idle"
        --     self.zhandouBtn:setTitleText("战斗")
        --     self:getScheduler():unscheduleScriptEntry(self.fightTick)
        -- end


        --game:dispatchEvent({name = EventDef.UI_MSG, code = "aaa"})
    end
end

function FightScene:raidsBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local RaidsLayer = require("src.app.views.layer.RaidsLayer").create()
        self:addChild(RaidsLayer, MoGlobalZorder[2000002])
        local size  = cc.Director:getInstance():getWinSize()
        RaidsLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(RaidsLayer)
    end
end

function FightScene:heroBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        gameUtil.addUserAction(1)

        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end
        gameUtil.removeRedPoint(self.heroBtn)
        if gameUtil.isFunctionOpen(closeFuncOrder.HERO_LIST_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        if mm.HeroLayer then
            mm.HeroLayer:removeFromParent()
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.HeroListLayer",
                             resName = "HeroListLayer",params = {app = self.app_}} )
    end
end

function FightScene:paihangBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        gameUtil.addUserAction(11)
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.PaiHangLayer",
                             resName = "PaiHangLayer",params = {app = self.app_}} )
    end
end

function FightScene:talkBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(14)
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        local isNew = false
        if self.talkBtn and self.talkBtn:getChildByName("newHint") and self.talkBtn:getChildByName("newHint"):isVisible() then
            isNew = true
        end

        local TalkLayer = require("src.app.views.layer.TalkLayer").new({isNew = isNew})
        TalkLayer:setName("TalkLayer")
        local size  = cc.Director:getInstance():getWinSize()
        --mm.pushLayoer( {scene = self, layer = TalkLayer, zord = 2000} )
        self:addChild(TalkLayer, MoGlobalZorder[2000002])
        TalkLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(TalkLayer)


        
    end
end

function FightScene:detalkBtnNew()
    if self.talkBtn:getChildByName("newHint") then
        self.talkBtn:getChildByName("newHint"):setVisible(false)
    end
end

function FightScene:athleticsBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        
        if (self.canRankUp or mm.GuildId == 15051 ) and mm.GuildId ~= 15005 then
            -- if mm.PkTiShi ~= nil then
            --     gameUtil:addTishi({p = self.scene, s = MoGameRet[990065]})
            --     return
            -- end

            local curZhanli = gameUtil.getPlayerForce()
            local curRank = mm.data.curDuanWei
            local DropOutTab = INITLUA:getDropOutRes()
            local torank = DropOutTab[tonumber(curRank)]['RankUpID']
            local camp = mm.data.playerinfo.camp
            local stageId = 0
            if 1 == camp then
                stageId = DropOutTab[tonumber(torank)]['LStageID']
            else
                stageId = DropOutTab[tonumber(torank)]['DStageID']
            end

            if gameUtil.isFunctionOpen(closeFuncOrder.BUZHEN_ENTER) == false then
                gameUtil:addTishi({s = MoGameRet[990047]})
                return
            end
            if (mm.diFangZhen and stageId == mm.diFangZhen.stageId) or (mm.curDiZhen and stageId == mm.curDiZhen.stageId) then
                gameUtil:addTishi({s = MoGameRet[990066]})
                return
            end
            local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_, type = 1, Info = stageId})
            self:addChild(BuZhenLayer, MoGlobalZorder[2000002])
            gameUtil.addUserAction(8)
            return
        end

        self:jumpToLayer("PVPLayer", {})
    end
end

function FightScene:stageBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        gameUtil.addUserAction(3)
        -- if mm.PkTiShi ~= nil then
        --     gameUtil:addTishi({p = self.scene, s = MoGameRet[990065]})
        --     return
        -- end
        local param = {}
        param.stageType = 3
        self:jumpToLayer("StageDetailLayer", param)
    end
end

function FightScene:chengjiuBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(2)

        if gameUtil.isFunctionOpen(closeFuncOrder.TASK_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end
        gameUtil.removeRedPoint(self.chengjiuBtn)


        --多少级钱直接进任务
        if gameUtil.getPlayerLv(mm.data.playerinfo.exp) < 16 then
            self.taskLayerTag = 1
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ChengJiuLayer",
                             resName = "ChengJiuLayer",params = {app = self.app_, typeLayer = self.taskLayerTag, scene = self}} )
        
        gameUtil.playUIEffect( "Mainbutton_Click" )
    end
end

function FightScene:jingyanBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.began then
        -- self.scene:getChildByName("Image_jingyan"):setScale(0.85)
        -- self.scene:getChildByName("LoadingBar_jingyan"):setScale(0.85)
    elseif touchkey == ccui.TouchEventType.canceled then
        -- self.scene:getChildByName("Image_jingyan"):setScale(1)
        -- self.scene:getChildByName("LoadingBar_jingyan"):setScale(1)
    elseif touchkey == ccui.TouchEventType.ended then 
        gameUtil.addUserAction(15)
        -- self.scene:getChildByName("Image_jingyan"):setScale(1)
        -- self.scene:getChildByName("LoadingBar_jingyan"):setScale(1)
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end

        if gameUtil.isFunctionOpen(closeFuncOrder.HERO_LIST_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        local guideJingYan =  cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "guideJingYan",0)
        print("guideJingYan    "..guideJingYan)
        if 0 == guideJingYan then
            mm.GuildId = 10025
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.JingYanChouJiangLayer",
                             resName = "JingYanChouJiangLayer",params = {app = self.app_, scene = self}} )


        

        
    end
end


function FightScene:jjcBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(10)
        local playerLv = gameUtil.getPlayerLv(mm.data.playerinfo.exp)
        if playerLv > 19  then
            self:jumpToLayer("JJCLayer")
        else
            gameUtil:addTishi({s = MoGameRet[990067]})
        end
    end
end

function FightScene:shangchengBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(4)
        self:jumpToLayer("ShangChengLayer")
    end
end

function FightScene:getTwoNodeCP( unitA, unitB)
    local x = unitB:getPositionX() - unitA:getPositionX()
    local y = unitB:getPositionY()  - 
                (unitA:getPositionY() )
    return cc.p(x,y)
end

function FightScene:getTwoPosXY( unitA, unitB )
    local bp = cc.p(unitB:getPosition())
    local ap = cc.p(unitA:getPosition())
    local v =  cc.pSub(bp, ap)
    local Angel = - math.deg(cc.pToAngleSelf(v)) 
    return Angel
end

function FightScene:jinshouzhiBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if not fight:UnitB1() then
            return
        end

        local skillTab = gameUtil.getHeroSkillTab( 1278357552 )
        local texiaoEffect = skillTab.texiaoEffect 

        local unitA = self.scene:getChildByName("Node_tianshi")
        local unitB = self.scene:getChildByName("b_1")
         
        local skeletonNode = self.tianShiSkeletonNode
        

        local function playTouSewu( ... )
            print("     playTouSewuplayTouSewu ###########    11111111      ")
            skeletonNode:setAnimation(0, "attack", false)
            skeletonNode:setTimeScale(3)
            local function ackBack()
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    skeletonNode:setAnimation(0, "stand", true)
                    -- skeletonNode:setRotation(0)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            print("     playTouSewuplayTouSewu ###########    2222222222      ")


            if fight:UnitB1() then
                fight:UnitB1():setPiaoxue(-100, 0, MM.EDamageStyle.Wuli, true)
            end


        end
        


        self.co = coroutine.create(function()
            playTouSewu()
        end)
        coroutine.resume(self.co, self)



        -- if gameUtil.isFunctionOpen(closeFuncOrder.GOLD_FINGER) == false then
        --     gameUtil:addTishi({s = MoGameRet[990047]})
        --     return
        -- end

        -- if self.isnextFight then
        --     return
        -- end

        -- if self.shouzhiImg then
        --     self.shouzhiImg:stopAllActions()
        --     self.shouzhiImg:removeFromParent()
        --     self.shouzhiImg = nil
        -- end

        -- local uiJinbi = self.scene:getChildByName("Image_jinbi")

        -- local unitTB = self.curUnitTB

        -- local tab = {1,2,3,4,5}
        -- local newtab = {}
        -- local index = 1
        -- for k,v in pairs(tab) do
        --     table.insert(newtab,math.random(1,index) , v)
        --     index = index + 1
        -- end
        
        -- --gameUtil.tableLuanXu( tab )

        -- for i=1,5 do
        --     if unitTB[i] then
        --         local node = self.scene:getChildByName("b_"..i)
        --         local DieNode = node:getChildByName("DieTeXiao")
        --         if DieNode then
        --             DieNode:setAnimation(0, "mb", false)
        --         else
        --             local str = "res/Effect/yingxiong/gongyong/t_sw/t_sw"
        --             local DieNode = gameUtil.createSkeletonAnimation(str..".json", str..".atlas",1)
        --             node:addChild(DieNode)
        --             DieNode:setAnimation(0, "mb", false)
        --             DieNode:setName("DieTeXiao")
        --             DieNode:setTimeScale(2)
        --         end

        --         local skeletonNode = self.jszNode[i]--node:getChildByName("skeletonNode")
        --         if skeletonNode then
        --             --skeletonNode:removeFromParent()
                    
        --             local index = newtab[i]
                    
        --             local node = self.scene:getChildByName("b_"..index)
        --             skeletonNode:setPosition(node:getPositionX(), node:getPositionY())
        --             skeletonNode:setVisible(false)

        --             performWithDelay(self,function( ... )
        --                 skeletonNode:setVisible(true)
        --             end , 0.01)

        --             --skeletonNode:setName("sn")
        --             --gameUtil.graySprite( skeletonNode )

        --             local heroid = skeletonNode:getTag()
        --             local str = util.getStrFormNum(heroid, 4)

        --             local jinbiImageView = ccui.ImageView:create()
        --             jinbiImageView:loadTexture("res/hero/heroImage/"..str..".png")
        --             skeletonNode:addChild(jinbiImageView)
        --             jinbiImageView:setName("heroImage")
        --             jinbiImageView:setScale(0.4)    
        --             jinbiImageView:setPosition(0,50)

        --             self:unitFly(jinbiImageView)

        --         else
                    
        --         end

        --         for i=1,2 do
        --             local jibiNode = cc.Node:create()
        --             node:addChild(jibiNode)

        --             local jinbiImageView = ccui.ImageView:create()
        --             jinbiImageView:loadTexture("res/UI/pc_jinbi.png")
        --             jibiNode:addChild(jinbiImageView)
        --             jinbiImageView:setName("jinbi")
        --             jinbiImageView:setScale(0.6)    
        --             jinbiImageView:setPosition(0,50)
        --             self:jinbiFly(jinbiImageView , uiJinbi, jibiNode)

        --         end
        --     end
        -- end
        
        -- self.lianshen = self.lianshen + 1  
        -- self:updateLianShen(1)
    end
end

function FightScene:goldBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(17)
        if gameUtil.isFunctionOpen(closeFuncOrder.GOLD_EXCHANGE) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end
        local DianjinshouLayer = require("src.app.views.layer.DianjinshouLayer").new({})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(DianjinshouLayer, MoGlobalZorder[2999999])
        DianjinshouLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(DianjinshouLayer)
    end
end

function FightScene:purchaseBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(widget:getTag())
        if gameUtil.isFunctionOpen(closeFuncOrder.RECHARGE_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end
        local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(PurchaseLayer, MoGlobalZorder[2999999])
        PurchaseLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(PurchaseLayer)
        -- self:showRechargeHint(410)
    end
end

function FightScene:closeRechargeHintLayer(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.rechargeHint then
            self.rechargeHint:removeFromParent()
            self.rechargeHint = nil
        end
    end
end

function FightScene:showRechargeHint( num )
    if self.rechargeHint then
        self.rechargeHint:removeFromParent()
        self.rechargeHint = nil
    end
    self.rechargeHint = cc.CSLoader:createNode("jiangliLayer.csb")

    -- self.rechargeHint:getChildByName("Image_bg"):getChildByName("Text_time"):setString("充值获得钻石")
    self.rechargeHint:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(false)
    self.rechargeHint:getChildByName("Image_bg"):getChildByName("Image_2"):setVisible(false)
    self.rechargeHint:getChildByName("Image_bg"):getChildByName("Text_Num1"):setVisible(false)
    self.rechargeHint:getChildByName("Image_bg"):getChildByName("Text_Num2"):setVisible(false)

    local button = self.rechargeHint:getChildByName("Image_bg"):getChildByName("Button_ok")
    button:addTouchEventListener(handler(self, self.closeRechargeHintLayer))
    gameUtil.setBtnEffect(button)

    local listView = self.rechargeHint:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("ListView")
    local item = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", num)

    local custom_item = ccui.Layout:create()
    custom_item:addChild(item)
    custom_item:setContentSize(item:getContentSize())
    item:setPositionX(listView:getContentSize().width * 0.5 - item:getContentSize().width * 0.5)
    listView:pushBackCustomItem(custom_item)

    local size  = cc.Director:getInstance():getWinSize()
    self:addChild(self.rechargeHint, MoGlobalZorder[2999999])
    self.rechargeHint:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.rechargeHint)

    mm.req("getActivityInfo",{type=0})
end

--type 1 普通
--type 2 pk
function FightScene:updateLianShen( type )
    if type == 1 then
        if self.lianshen and self.lianshen > 0 then
            local index = self.lianshen / 20 + 1
            if index > 5 then index = 5 end
            self.lianshenNode:setVisible(true)
            self.lianshenNode:getChildByName("imgbg"):loadTexture("res/icon/jiemian/icon_liansheng"..index..".png")
            self.lianshenNode:getChildByName("lianShenNumtext"):setString(self.lianshen)
        else

            self.lianshenNode:setVisible(false)
        end

    else
        if self.pklianshen and self.pklianshen > 0 then
            local index = self.pklianshen / 5 + 1
            if index > 5 then index = 5 end
            self.lianshenNode:setVisible(true)
            self.lianshenNode:getChildByName("imgbg"):loadTexture("res/icon/jiemian/icon_PKliansheng"..index..".png")
            self.lianshenNode:getChildByName("lianShenNumtext"):setString(self.pklianshen)
        else

            self.lianshenNode:setVisible(false)
        end

    end

    local scaleTo = cc.ScaleTo:create(0.05,2)
    local scaleTo1 = cc.ScaleTo:create(0.05,1)

    self.lianshenNode:getChildByName("lianShenNumtext"):runAction(cc.Sequence:create(
                scaleTo, 
                scaleTo1))
end

function FightScene:jinbiFly(  jinbi, uiJinbi , jibiNode)
    local function fly( ... )
        local function flyBack( ... )

            -- gameUtil.addArmatureFile("res/Effect/uiEffect/jb/jb.ExportJson")
            -- local anime = ccs.Armature:create("jb")
            -- local animation = anime:getAnimation()
            -- local btnSize = uiJinbi:getSize()
            -- --播放完动画之后卸载资源
            -- local function animationEventEnd(armatureBack, movementType, movementID)
            --     if movementType == ccs.MovementEventType.complete then
            --         performWithDelay(self,function( ... )
            --             anime:removeFromParent()
            --             gameUtil.removeArmatureFile("res/Effect/uiEffect/jb/jb.ExportJson")
                        
            --         end, 0.01)
            --     end
            -- end
            -- animation:setMovementEventCallFunc(animationEventEnd)
            -- uiJinbi:addChild(anime,10)
            -- anime:setAnchorPoint(cc.p(0.5,0.5))
            -- anime:setPosition(cc.p(30, 40))
            -- animation:playWithIndex(0)
            gameUtil.playUIEffect( "Gold_Get" )
            
            jinbi:removeFromParent()
            jibiNode:removeFromParent()
        end
    
        local x, y = jinbi:getPosition()
        local p0 = jinbi:getParent():convertToWorldSpace(cc.p(x, y))
        local x, y = uiJinbi:getPosition()
        local p1 = uiJinbi:getParent():convertToWorldSpace(cc.p(x, y))
        local mx = p1.x - p0.x
        local my = p1.y - p0.y
        local bezier = {
            cc.p(0, 0),
            cc.p(mx + math.random(-200,200), math.random(100,200)),
            cc.p(mx, my),
        }
        local bezierForward = cc.BezierBy:create(0.8, bezier)

        -- gameUtil.addArmatureFile("res/Effect/uiEffect/lizi/lizi.ExportJson")
        -- local particle = cc.ParticleSystemQuad:create("res/Effect/uiEffect/lizi/lizi.plist")
        -- jibiNode:addChild(particle, -1)
        -- particle:setPosition(cc.p(jinbi:getSize().width*0.5, jinbi:getSize().height*0.5))
        -- particle:setAutoRemoveOnFinish(true)
        -- particle:setDuration(1.2)

        jibiNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(10,20) * 0.01),bezierForward, cc.CallFunc:create(flyBack) ))
    end
    local b = 1.5
    local mx = math.random(-80 * b,80 * b)
    local my = math.random(-40 * b,30 * b)
    local bezier = {
        cc.p(0, 0),
        cc.p(mx * 0.5, math.random(160 * b,180 * b)),
        cc.p(mx, my),
    }
    local time = math.random(40,70) * 0.01
    local bezierForward = cc.BezierBy:create(time, bezier)
    local actionTo = cc.RotateTo:create(time, mx * (45/(360 * b)))
    local spawn = cc.Spawn:create(bezierForward, actionTo)

    jibiNode:runAction(cc.Sequence:create(
                spawn, 
                cc.MoveBy:create(0.1,cc.p(0,20)),
                cc.MoveBy:create(0.1,cc.p(0,-20)),
                cc.MoveBy:create(0.05,cc.p(0,10)),
                cc.MoveBy:create(0.05,cc.p(0,-10)), 
                cc.CallFunc:create(fly)))


end


function FightScene:unitFly( jibiNode)
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


function FightScene:buzhenBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if gameUtil.isFunctionOpen(closeFuncOrder.BUZHEN_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        if gameUtil.getPlayerLv(mm.data.playerinfo.exp) > 1 then
            local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(BuZhenLayer, MoGlobalZorder[2000002])
            BuZhenLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(BuZhenLayer)
        end
    end
end

function FightScene:mailbtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(5)
        self:jumpToLayer("youjianLayer")
    end
end

function FightScene:captureScreenAndShare( )
    --[[
    public static final String share_sdk_title_key = "title";
    public static final String share_sdk_title_url_key = "titleurl";
    public static final String share_sdk_text_key = "text";
    public static final String share_sdk_pic_path_key = "picpath";
    picurl
    public static final String share_sdk_url_key = "url";
    public static final String share_sdk_comment_key = "comment";
    public static final String share_sdk_site_url_key = "siteurl";
    public static final String share_sdk_site_key = "site";
    --]]
    --截屏回调方法  
    local function afterCaptured(succeed, outputFile)  
        if succeed then  
            local info = {}
            info.title = "LOTA方块战争"
            info.text = "MOBA大乱斗，你是支持撸啊撸还是刀塔呢！？#LOTA#"

            info.picurl = ""

            --local savePath = SystemUtil:getPicturePath()
            --info.picpath = savePath.."/mengmobile_picaaaa_mh1444797200816.jpg"
            info.picpath = outputFile
            -------weixin--------------url为空时 为分享图片!!-----
            info.url = ""
            info.url = "http://www.lolvsdota.cn/index.html"
            -----------QQ REN----------
            info.titleurl = "http://www.lolvsdota.cn/index.html"
            info.comment = "一起来玩吧!"
            info.siteurl = "http://www.lolvsdota.cn/index.html"
            info.site = ""

            info = json.encode(info)
            SDKUtil:shareSDK(info)
        else  
        end  
    end 
    local savePath = SystemUtil:getPicturePath()

    local fileName = savePath.."/any_layer.jpg"

    cc.utils:captureScreen(afterCaptured, fileName) 
end

function FightScene:bagBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        gameUtil.addUserAction(12)
        if self:getChildByName("TalkLayer") ~= nil then
            self:getChildByName("TalkLayer"):removeFromParent()
        end
        if self:getChildByName("JingYanLayer") ~= nil then
            self:getChildByName("JingYanLayer"):removeFromParent()
        end
        if gameUtil.isFunctionOpen(closeFuncOrder.BAG_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.BagLayer",
                             resName = "BagLayer",params = {}} )
    end
end

function FightScene:wonderfulActivityBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ActivityWFBaseLayer",
                                 resName = "ActivityWFBaseLayer",params = {scene = self}} )
        
        -- local ActivityWFBaseLayer = require("src.app.views.layer.ActivityWFBaseLayer").new({scene = self})
        -- local size  = cc.Director:getInstance():getWinSize()
        -- self:addChild(ActivityWFBaseLayer, MoGlobalZorder[2000002])
        -- ActivityWFBaseLayer:setContentSize(cc.size(size.width, size.height))
        -- ccui.Helper:doLayout(ActivityWFBaseLayer)
    end
end

function FightScene:standAloneBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        local targetId = util.getStrFormNum(tonumber(id), 4)
        
        if targetId == "A001" then
            -- if gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= 15 then
                mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ShouChongLayer",
                                     resName = "ShouChongLayer",params = {scene = self, activityId = id}} )
            -- end
        elseif targetId == "C001" then
            -- if gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= 15 then
                mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.GameTimeLayer",
                                     resName = "GameTimeLayer",params = {scene = self, activityId = id}} )
            -- end
        end
    end
end

function FightScene:mergeBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local childId = widget:getTag()
        --targetId = 1194340401
        
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ActivityMGBaseLayer",
                                 resName = "ActivityMGBaseLayer",params = {scene = self, childId = childId}} )
    end
end

function FightScene:initBtn( ... )
    -- 战斗按钮
    self.zhandouBtn = self.paneldi:getChildByName("fightbtn")
    self.zhandouBtn:addTouchEventListener(handler(self, self.zhandouBtnCbk))
    -- self.zhandouBtn:setVisible(false)

    -- 扫荡按钮
    -- self.raidsBtn = self.scene:getChildByName("Btn_Raids")
    -- self.raidsBtn:addTouchEventListener(handler(self, self.raidsBtnCbk))

    -- 邮件按钮
    -- self.mailbtn = self.scene:getChildByName("mailbtn")
    -- self.mailbtn:addTouchEventListener(handler(self, self.mailbtnCbk))
    -- gameUtil.setBtnEffect(self.mailbtn)

    -- 排行按钮
    -- self.ratebtn = self.scene:getChildByName("ratebtn")
    -- self.ratebtn:addTouchEventListener(handler(self, self.mailbtnCbk))
    -- gameUtil.setBtnEffect(self.ratebtn)

    -- 设置按钮
    -- self.setBtn = self.scene:getChildByName("setbtn")
    -- self.setBtn:addTouchEventListener(handler(self, self.mailbtnCbk))
    -- gameUtil.setBtnEffect(self.setBtn)

    -- 点金手按钮
    self.goldIconBtn = self.scene:getChildByName("Image_jinbi")
    self.goldIconBtn:addTouchEventListener(handler(self, self.goldBtnCbk))
    self.goldIconBtn:setTouchEnabled(true)

    self.diamondBtn = self.scene:getChildByName("Image_zuanshi")
    self.diamondBtn:addTouchEventListener(handler(self, self.purchaseBtnCbk))
    self.diamondBtn:setTouchEnabled(true)
    self.diamondBtn:setTag(18)
    

    --gameUtil.setBtnEffect(self.goldBtn)

    -- 充值按钮
    self.goldBtn = self.scene:getChildByName("Button_2")
    self.goldBtn:addTouchEventListener(handler(self, self.purchaseBtnCbk))
    self.goldBtn:setTouchEnabled(true)
    self.goldBtn:setTag(16)
    self.goldBtn:setLocalZOrder(99)
    --gameUtil.setBtnEffect(self.goldBtn)

    -- 金手指按钮
    self.jszBtn = self.scene:getChildByName("Button_shouzhi")
    self.jszBtn:addTouchEventListener(handler(self, self.jszBtnCbk))

    -- 背包按钮
    self.bagBtn = self.scene:getChildByName("Button_bag")
    self.bagBtn:addTouchEventListener(handler(self, self.bagBtnCbk))
    --gameUtil.setBtnEffect(self.bagBtn)

    -- 英雄按钮
    self.heroBtn = self.paneldi:getChildByName("juesebtn")
    self.heroBtn:addTouchEventListener(handler(self, self.heroBtnCbk))

    -- 聊天按钮
    self.talkBtn = self.paneldi:getChildByName("liaotianbtn")
    self.talkBtn:addTouchEventListener(handler(self, self.talkBtnCbk))
    gameUtil.setBtnEffect(self.talkBtn)

    -- 更多按钮
    self.moreBtn = self.paneldi:getChildByName("Button_more")
    self.moreBtn:addTouchEventListener(handler(self, self.mailbtnCbk))

    -- 关卡按钮
    self.stageBtn = self.paneldi:getChildByName("fightbtn")
    self.stageBtn:addTouchEventListener(handler(self, self.stageBtnCbk))

    local win_playQuan = gameUtil.createSkeAnmion( {name = "bs", scale = 1} )
    win_playQuan:setAnimation(0, "zs", true)
    self.stageBtn:addChild(win_playQuan,-1)
    win_playQuan:setPosition(self.stageBtn:getContentSize().width*0.5 - 1, self.stageBtn:getContentSize().height*0.5 - 8)
    win_playQuan:setScale(1)


    -- 成就按钮
    self.chengjiuBtn = self.paneldi:getChildByName("chengjiubtn")
    self.chengjiuBtn:addTouchEventListener(handler(self, self.chengjiuBtnCbk))

    -- 商城按钮
    self.shangchengBtn = self.paneldi:getChildByName("shangchengbtn")
    self.shangchengBtn:addTouchEventListener(handler(self, self.shangchengBtnCbk))

    -- 乱斗按钮
    self.meleeBtn = self.scene:getChildByName("Button_melee")
    self.meleeBtn:addTouchEventListener(handler(self, self.meleeBtnCbk))
    gameUtil.setBtnEffect(self.meleeBtn)
    self.meleeBtn:setVisible(false)

    -- local tempButton1Res = "res/UI/jm_zisuipian.png"
    -- local tempButton1 = gameUtil.createEquipItem(1127231545, 1, false)
    -- local tempButton1X,tempButton1Y = self.meleeBtn:getPosition()
    -- tempButton1:setPosition(cc.p(tempButton1X, tempButton1Y))
    -- self.scene:addChild(tempButton1)
    -- self.tempButton1 = tempButton1
    -- self.tempButton1:setTouchEnabled(true)
    -- self.tempButton1:addTouchEventListener(handler(self, self.momianBtnCbk))

    self.wumianBtn = self.scene:getChildByName("Button_Battle01")
    self.wumianBtn:addTouchEventListener(handler(self, self.wumianBtnCbk))
    self.wumianBtn:setTouchEnabled(true)
    gameUtil.setBtnEffect(self.wumianBtn)

    -- local tempButton2Res = "res/UI/jm_lansuipian.png"
    -- local tempButton2 = gameUtil.createEquipItem(1127231793, 1, false)
    -- local tempButton2X,tempButton2Y = self.meleeBtn:getPosition()
    -- tempButton2:setPosition(cc.p(tempButton2X + 150, tempButton2Y))
    -- self.scene:addChild(tempButton2)
    -- self.tempButton2 = tempButton2
    -- self.tempButton2:setTouchEnabled(true)
    -- self.tempButton2:addTouchEventListener(handler(self, self.wumianBtnCbk))

    self.momianBtn = self.scene:getChildByName("Button_Battle02")
    self.momianBtn:addTouchEventListener(handler(self, self.momianBtnCbk))
    self.momianBtn:setTouchEnabled(true)
    gameUtil.setBtnEffect(self.momianBtn)

        -- 竞技场
    self.jjcBtn = self.scene:getChildByName("Button_jingjichang")
    self.jjcBtn:addTouchEventListener(handler(self, self.jjcBtnCbk))
    gameUtil.setBtnEffect(self.jjcBtn)
     mm.GuildScene.jjcBtn = self.jjcBtn


    self:updateMoWuBtn()

    -- 布阵按钮
    -- self.buzhenBtn = self.scene:getChildByName("Button_buzhen")
    -- self.buzhenBtn:addTouchEventListener(handler(self, self.buzhenBtnCbk))
    -- gameUtil.setBtnEffect(self.buzhenBtn)

    -- 经验池按钮
    self.jingyanBtn = self.scene:getChildByName("Button_jingyan")
    self.jingyanBtn:setVisible(true)
    self.jingyanBtn:addTouchEventListener(handler(self, self.paihangBtnCbk))
    -- gameUtil.setBtnEffect(self.jingyanBtn)

    -- 经验抽奖按钮
    self.jingyanBtn = self.scene:getChildByName("Button_7")
    self.jingyanBtn:addTouchEventListener(handler(self, self.jingyanBtnCbk))
    gameUtil.setBtnEffect(self.jingyanBtn)




    
    self.scene:getChildByName("Button_1"):setVisible(false)
    self.scene:getChildByName("Button_6"):setVisible(false)

    -- 精彩活动按钮
    local tempWonderfulBtn = self.scene:getChildByName("Button_3")
    tempWonderfulBtn:setVisible(false)
    local wonderfulBtnX,wonderfulBtnY = tempWonderfulBtn:getPosition()

    local wonderfulBtnSrc = "res/UI/bt_huodong.png"
    self.wonderfulActivityBtn = ccui.ImageView:create()
    self.wonderfulActivityBtn:setAnchorPoint(cc.p(0.5,0.5))
    self.wonderfulActivityBtn:loadTexture(wonderfulBtnSrc)
    self.wonderfulActivityBtn:setPosition(wonderfulBtnX,wonderfulBtnY)
    self.wonderfulActivityBtn:setVisible(false)
    self.wonderfulActivityBtn:setTouchEnabled(true)
    self.wonderfulActivityBtn:addTouchEventListener(handler(self, self.wonderfulActivityBtnCbk))
    self.scene:addChild(self.wonderfulActivityBtn, MoGlobalZorder[1000003])


    self.t300 = os.clock()
    -- 所有活动按钮状态刷新

    local function refreshActivity( ... )
        self:refreshActivityHint()
        self:refreshActivityNew()
    end
    performWithDelay(self,refreshActivity, 2)

    

    self.t301 = os.clock()

    if mm.data.noReadNum == nil then
        mm.data.noReadNum = 0
    end
    if mm.data.noReadNum > 0 then
        gameUtil.addRedPoint(self.moreBtn)
    else
        gameUtil.removeRedPoint(self.moreBtn)
    end
end

function FightScene:ReceiveTalk(event)
    
end

function FightScene:refreshActivityHint()
    local activityInfo = json.decode(mm.data.activityInfo)
    local activityInfoRes = INITLUA:getActivtyListRes()
    local activityTypeRes = INITLUA:getActivtyTypeRes()
    local activityTypeChildRes = INITLUA:getActivityTypeChildRes()
    local activityRecord = json.decode(mm.data.activityRecord)

    -- 精彩活动按钮
    local wonderfulActivity = false
    local needRedPoint = false

    for k,v in pairs(activityInfo) do
        local activityId = tonumber(v.activityId)
        local activity = activityInfoRes[activityId]
        local activityType = activityTypeRes[activity.ActID]

        if activityType.ActTypeName == "Wonderful" then
            wonderfulActivity = true
            needRedPoint = self:checkActivityRedPoint(activityType.ActTypeName, activityId)
            if needRedPoint then
                break
            end
        end
    end

    self.wonderfulActivityBtn:setVisible(wonderfulActivity)
    
    if needRedPoint then
        gameUtil.addRedPoint(self.wonderfulActivityBtn)
    else
        gameUtil.removeRedPoint(self.wonderfulActivityBtn)
    end
    ----合并活动相关----
    local activityPositionx,activityPositiony = self.wonderfulActivityBtn:getPosition()
    ---[[
    -- 合并活动按钮
    if self.mergeBtn then 
        for k,v in pairs(self.mergeBtn) do
            v:removeFromParent()
        end
    end
    self.mergeBtn = {}
    local index = 0

    local mergeActivity = {}

    for k,v in pairs(activityInfo) do
        local activityId = tonumber(v.activityId)
        local activity = activityInfoRes[activityId]
        local activityType = activityTypeRes[activity.ActID]

        if activityType.ActTypeName == "Merge" then
            local exist = false
            for k,v in pairs(mergeActivity) do
                if k == activity.activityTypeChild then
                    exist = true
                    break
                end
            end
            if exist == false then
                mergeActivity[activity.activityTypeChild] = {}
            end
            table.insert(mergeActivity[activity.activityTypeChild], activityId)
        end
    end

    for k,v in pairs(mergeActivity) do
        local iconSrc = "icon/jiemian/bt_kaifu.png"
        iconSrc = "icon/jiemian/"..activityTypeChildRes[k].Childicon..".png"

        index = index + 1

        local btn = ccui.ImageView:create()
        btn:loadTexture(iconSrc)

        btn:setTag(k)
        -- btn.activityId = v
        btn:addTouchEventListener(handler(self, self.mergeBtnCbk))
        btn:setPositionX(activityPositionx)
        btn:setPositionY(activityPositiony - index*100)
        btn:setTouchEnabled(true)
        btn:setAnchorPoint(cc.p(0.5,0.5))

        --gameUtil.setBtEffect(btn)
        --, MoGlobalZorder[1000003]
        self.scene:addChild(btn, MoGlobalZorder[1000003])

        table.insert(self.mergeBtn, btn)

        for key,value in pairs(v) do
            local activityId = value
            local ActTypeName = "Merge"
            local redPoint = self:checkActivityRedPoint(ActTypeName, activityId)
            if redPoint then
                gameUtil.addRedPoint(btn)
                break
            else
                gameUtil.removeRedPoint(btn)
            end
        end
    end

    ---[[
    if self.standAloneBtn then 
        for k,v in pairs(self.standAloneBtn) do
            v:removeFromParent()
        end
    end
    -- 独立活动按钮
    self.standAloneBtn = {}
    for k,v in pairs(activityInfo) do
        local activityId = tonumber(v.activityId)
        local activity = activityInfoRes[activityId]
        local activityType = activityTypeRes[activity.ActID]

        local activityIcon = activity.activityIcon
        if activityType.ActTypeName == "StandAlone" then
            --------------------通过ActivityTypeChild表确定---TODO--------------------
            local iconsrc = "icon/jiemian/"..activityIcon..".png"
            -- iconsrc = "UI/bt_shouchong.png"
            index = index + 1

            local btn = ccui.ImageView:create()
            btn:loadTexture(iconsrc)

            btn:setTag(activityId)
            btn:addTouchEventListener(handler(self, self.standAloneBtnCbk))
            btn:setPositionX(activityPositionx)
            btn:setPositionY(activityPositiony - index*100)
            btn:setTouchEnabled(true)
            btn:setAnchorPoint(cc.p(0.5,0.5))

            --gameUtil.setBtEffect(btn)
            --, MoGlobalZorder[1000003]
            self.scene:addChild(btn, MoGlobalZorder[1000003])

            table.insert(self.standAloneBtn, btn)

            local redPoint = self:checkActivityRedPoint(activityType.ActTypeName, activityId)
            if redPoint then
                gameUtil.addRedPoint(btn)
            else
                gameUtil.removeRedPoint(btn)
            end
        end
    end
    --]]
end

function FightScene:checkActivityRedPoint( ActTypeName , checkActivityId)
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

                    --------------------------------游戏时间特殊处理--------------------------------------
                    if activity.finish == MM.Efinish.Act_PlayTimeToday then
                        local maxIndex = 0
                        local maxTempIndex = 0
                        local targetTime = nil
                        if recordValue.reward and #recordValue.reward > 0 then
                            for targetKey,targetValue in pairs(targetValue1) do
                                maxIndex = maxIndex + 1
                                for key,value in pairs(recordValue.reward) do
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
                            elseif maxTempIndex >= maxIndex then
                                targetTime = nil
                            else
                                maxTempIndex = maxTempIndex + 1
                                targetTime = targetValue1[maxTempIndex]
                            end
                        else
                            targetTime = targetValue1[1]
                        end
                        if targetTime == nil then
                            return false
                        end
                        local gameTime = os.time() - recordValue.value
                        if gameTime < targetTime then
                            return false
                        else
                            return true
                        end
                    end

                    if activity.finish == MM.Efinish.Act_null then
                        return false
                    end
                    -----------------------------------普通处理--------------------------------------------
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

function FightScene:refreshActivityNew()
    local activityInfo = json.decode(mm.data.activityInfo)
    local activityInfoRes = INITLUA:getActivtyListRes()
    local activityTypeRes = INITLUA:getActivtyTypeRes()
    local activityTypeChildRes = INITLUA:getActivityTypeChildRes()
    local activityRecord = json.decode(mm.data.activityRecord)

    -- 精彩活动按钮
    local needNewHint = false

    if self.wonderfulActivityBtn:getChildByName("redPoint") == nil then
        gameUtil.removeNewHint(self.wonderfulActivityBtn)

        for k,v in pairs(activityInfo) do
            local activityId = tonumber(v.activityId)
            local activity = activityInfoRes[activityId]
            local activityType = activityTypeRes[activity.ActID]

            if activity.finish ~= MM.Efinish.Act_null and activityType.ActTypeName == "Wonderful" then
                for key,value in pairs(activityRecord) do
                    if value.activityId == v.activityId then 
                        if value.read ~= true then
                            needNewHint = true
                            break
                        end
                    end
                end
                if needNewHint then
                    break
                end
            end
        end
        if needNewHint then
            local width = self.wonderfulActivityBtn:getContentSize().width
            local height = self.wonderfulActivityBtn:getContentSize().height
            gameUtil.addNewHint(self.wonderfulActivityBtn, "huodong", width * 0.5, height * 0.5)
            -- self.wonderfulActivityBtn:addChild(newHint)
        else
            gameUtil.removeNewHint(self.wonderfulActivityBtn)
        end
    end

    for itemKey,itemValue in pairs(self.mergeBtn) do
        if itemValue:getChildByName("redPoint") == nil then
            gameUtil.removeNewHint(itemValue)
            needNewHint = false

            local index = itemValue:getTag()
            local iconRes = activityTypeChildRes[index].Childicon

            for k,v in pairs(activityInfo) do
                local activityId = tonumber(v.activityId)
                local activity = activityInfoRes[activityId]
                local activityType = activityTypeRes[activity.ActID]

                if activityType.ActTypeName == "Merge" then
                    local tempIconRes = activityTypeChildRes[activity.activityTypeChild].Childicon
                    if tempIconRes == iconRes then
                        for key,value in pairs(activityRecord) do
                            if value.activityId == v.activityId then 
                                if value.read ~= true then
                                    needNewHint = true
                                    break
                                end
                            end
                        end
                        if needNewHint then
                            break
                        end
                    end
                end
            end

            if needNewHint then
                local index = itemValue:getTag()
                local iconRes = activityTypeChildRes[index].Childicon
                local hintRes = gameUtil.getNewHintRes( iconRes )

                local width = itemValue:getContentSize().width
                local height = itemValue:getContentSize().height
                gameUtil.addNewHint(itemValue, hintRes, width * 0.5, height * 0.5)
                -- self.wonderfulActivityBtn:addChild(newHint)
            else
                gameUtil.removeNewHint(itemValue)
            end
        end
    end

    for itemKey,itemValue in pairs(self.standAloneBtn) do
        if itemValue:getChildByName("redPoint") == nil then
            gameUtil.removeNewHint(itemValue)

            needNewHint = false
            local activityId = tonumber(itemValue:getTag())
            local activity = activityInfoRes[activityId]
            local activityType = activityTypeRes[activity.ActID]

            local activityIcon = activity.activityIcon
            
            for key,value in pairs(activityRecord) do
                if tostring(value.activityId) == tostring(activityId) then 
                    if value.read ~= true then
                        needNewHint = true
                    end
                    break
                end
            end
            if needNewHint then
                local hintRes = gameUtil.getNewHintRes( activityIcon )
                local width = itemValue:getContentSize().width
                local height = itemValue:getContentSize().height
                gameUtil.addNewHint(itemValue, hintRes, width * 0.5, height * 0.5)
            else
                gameUtil.removeNewHint(itemValue)
            end
        else

        end
    end

end

function FightScene:checkHeroHint( equipID )
    local heroIDs = {}
    for i=1,#mm.data.playerHero do
        local eqTab = mm.data.playerHero[i].eqTab
        local jinTab = gameUtil.getEquipId( mm.data.playerHero[i].id, mm.data.playerHero[i].jinlv )
        if jinTab == nil then
        end
        for j=1,6 do
            local t = gameUtil.getHeroEqByIndex( eqTab, j )
            local eqId = jinTab.EquipEx[j]
            if t == nil and eqId == equipID then
                table.insert(heroIDs, mm.data.playerHero[i].id)
                break
            end
        end
    end
    return heroIDs
end

function FightScene:checkStorePoint( )
    local storeInfo = mm.lastStoreInfo
    
    local storeItemRes = INITLUA:getShopItemListRes()

    for k,v in pairs(storeInfo) do
        local items = v.storeItems
        for itemKey,item in pairs(items) do
            local storeItem = storeItemRes[item.itemID]
            local shopItemID = storeItem.ShopItemID
            local shopItemType = storeItem.ShopType
            local shopItemStatus = item.status
            if shopItemType == 0 and shopItemStatus == 0 then
                for i=1,#mm.data.playerHero do
                    local heroInfo = mm.data.playerHero[i]
                    local eqTab = heroInfo.eqTab
                    local jinTab = gameUtil.getEquipId( heroInfo.id, heroInfo.jinlv)

                    if jinTab == nil then
                    end
                    for j=1,6 do
                        local t = gameUtil.getHeroEqByIndex( eqTab, j)
                        local eqId = jinTab.EquipEx[j]
                        if t == nil and eqId == shopItemID then
                            return true
                        end
                    end
                end
            end
        end
    end
    
    return false
end


-- function FightScene:loadstage()
--     for i= 1,5 do
--           self.fight:addUnit(0,i,1)
--         self.fight:addUnit(0,i,2)
--     end
-- end

function FightScene:initJingYanChouJingReminder()
    -- 消息请求：
    mm.req("luckdraw", {["type"] = "info", subtype = 1})
    local luckdrawTimeRecived = {} self.luckdrawTimeRecived = luckdrawTimeRecived
end

-- 至宝信息提醒
function FightScene:initPreciousReminder()
    local piFu = self.scene:getChildByName("Button_8")
    self.piFuBtn = piFu
    if piFu then
        piFu:addTouchEventListener(handler(self, self.piFuBtnCbk))
    end
    PA:setupNewItems(mm.data.playerItem)
end

function FightScene:piFuBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        
        if game.speedBuff == 1 then
            game.speedBuff = 3
        elseif game.speedBuff == 3 then
            game.speedBuff = 5
        else
            game.speedBuff = 1
        end

       --  if not PA:isPreciousOpen(self, true) then
       --      return
       --  end
       -- -- 开关，进去至宝，优先显示皮肤
       -- -- 如果是通过herolist则为false
       -- mm.isPiFuCheckMode = true 

       -- mm.pushLayoer( 
       --  {scene = self, 
       --  clear = 1, 
       --  zord = MoGlobalZorder[2000002], 
       --  res = "src.app.views.layer.HeroLayer",
       --  resName = "HeroLayer",
       --  params = {app = self.app_, heroId = 0, LayerTag = 1}} )

       -- gameUtil.removeRedPoint(self.piFuBtn)
    end
end

function FightScene:fetchTimeFromLuckDraw(data)
    gameUtil.removeRedPoint(self.jingyanBtn)

    if not data then
        return
    end

    local luckdrawInfo = data.luckdrawInfo
    if not luckdrawInfo then
        return
    end

    -- gold 类型，有结束计时的特点：
    local luckdrawTimeRecived = self.luckdrawTimeRecived
    if #luckdrawTimeRecived > 0 then
        luckdrawTimeRecived = {} self.luckdrawTimeRecived = luckdrawTimeRecived
    end

    local function intoMgr(t, name)
        table.insert(luckdrawTimeRecived, {time = t+1, name=name, endInClock=false})
    end

    local countFreeLuckDraw = 0
    if luckdrawInfo.restGoldTimes and luckdrawInfo.goldTime then
        if luckdrawInfo.restGoldTimes > 0 and luckdrawInfo.goldTime >= 0 then
            intoMgr(luckdrawInfo.goldTime, "gold")
        end
    end

    if luckdrawInfo.diamondTime then
        if luckdrawInfo.diamondTime >= 0 and luckdrawInfo.restDiamondTimes > 0 then
            intoMgr(luckdrawInfo.diamondTime, "diamond")
        end
    end

    -- if luckdrawInfo.enemyTime then
    --     if luckdrawInfo.enemyTime >= 0 then
    --         intoMgr(luckdrawInfo.enemyTime, "enemy")
    --     end
    -- end

    -- local jingyanBtn = self.jingyanBtn
    -- if not jingyanBtn then
    --     return
    -- end

    -- if countFreeLuckDraw > 0 then
    --     -- 红点   
    --     gameUtil.addRedPoint(jingyanBtn)
    --     --jingyanBtn.hasRedPoint = true
    -- else
    --     -- 提示移除
    --     gameUtil.removeRedPoint(jingyanBtn)
    -- end
end

function FightScene:meleeBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm.req("meleeEnter", {})
        self.meleeBtn:setTouchEnabled(false)
    end
end

function FightScene:momianBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(6)
        local param = {}
        param.stageID = 1093677105
        self:jumpToLayer("StageDetailLayer", param)
    end
end

function FightScene:wumianBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil.addUserAction(7)
        local param = {}
        param.stageID = 1093677361
        self:jumpToLayer("StageDetailLayer", param)
    end
end

function FightScene:meleeEnterBack(t)
    if t.type == 0 then
        fight:initNode()
        mm.app:push("MeleeScene", t)
    elseif t.type == 1 then
        gameUtil:addTishi({s = MoGameRet[990046]})
    end
    self.meleeBtn:setTouchEnabled(true)

end

local reminderUpdateTime = 10
function FightScene:reminderInit()
    local aNode = cc.Node:create()
    self:addChild(aNode)

    local action = cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(handler(self, self.reminderUpdate)), cc.DelayTime:create(reminderUpdateTime)))   
    aNode:runAction(action)

    self:reminderUpdate()
end

-- 
local preciousUpdateTime = 91
local preciousUpdateTimeMax = 90
function FightScene:reminderUpdate()
    -- 1
    local jingyanBtn = self.jingyanBtn
    for k,v in ipairs(self.luckdrawTimeRecived) do
        local time = v.time
        if time > 0 then
            time = time - reminderUpdateTime
            if time <= 0 then
                time = 0
                v.endInClock = true
            end
            v.time = time
        end

        -- 检查红点
        if time <= 0 then
            if v.endInClock and CJH:checkOpen(v.name) then
                v.endInClock = false
                if not gameUtil.hasResPoint(jingyanBtn) then
                    gameUtil.addRedPoint(jingyanBtn)
                end
            end
        end
    end


    -- 2
    preciousUpdateTime = preciousUpdateTime + reminderUpdateTime
    if preciousUpdateTime < preciousUpdateTimeMax then
        return
    end
    preciousUpdateTime = 0

    local heroBtn = self.heroBtn
    local hasRedPoint = gameUtil.hasResPoint(heroBtn)
    local hasRedPointOnPiFu = gameUtil.hasResPoint(self.piFuBtn)
    --if not hasRedPoint then
    local mm_data_playerHero = mm.data.playerHero
    local needRemid = false
    local needRemidOnFiPu = false
    if mm_data_playerHero and (not hasRedPoint or not hasRedPointOnPiFu) then
        for k,v in ipairs(mm_data_playerHero) do
            local preciousInfos = v.preciousInfo
            local skinInfo = v.skinInfo
            -- if not preciousInfos then
            --     preciousInfos = {{id=1,lv=25,order=0}}
            -- end
            local heroId = v.id
            if preciousInfos and not hasRedPoint and not needRemid then -- 至宝红点
                for i,var in ipairs(preciousInfos) do
                    if PA:canLiftOrderByTheWay(var, heroId) then
                        needRemid = true
                        break
                    end
                end
            end

            if skinInfo and not hasRedPointOnPiFu and not needRemidOnFiPu then
                local _collectList = skinInfo.collectList
                if _collectList and PA:hasOpenedNoUsedSkin(_collectList) then
                    needRemidOnFiPu = true
                end
            end
            if needRemid and needRemidOnFiPu then
                break
            end
        end
    end
    if needRemid then
        gameUtil.addRedPoint(heroBtn)
    end

    -- 皮肤按钮
    if needRemidOnFiPu then
        gameUtil.addRedPoint(self.piFuBtn)
    end
end

return FightScene