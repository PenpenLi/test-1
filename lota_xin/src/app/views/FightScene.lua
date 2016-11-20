local FightScene = class("FightScene", cc.load("mvc").ViewBase)
FightScene.RESOURCE_FILENAME = "FightScene.csb"


INITLUA = require("app.models.initLua")
PEIZHI = require("app.res.peizhi")
INITLUA:fightSceneLoad()
local fight = require("app.fight.Fight")
local PlayFight = require("app.fight.PlayFight")

require("app.views.mmExtend.gameUtil")

require("app.views.mmExtend.MoGlobalZorder")

gameTimer = require("app/views/mmExtend/Timer")
gameTimer:new()
--玩家阵营始终为 1

Guide = require("app/models/guide")

require("app.res.PreciousUpRes")


local size  = cc.Director:getInstance():getWinSize()

function FightScene:onCreate()

    self.scene = self:getChildByName("Scene")
    self.scene:setAnchorPoint(cc.p(0.5,0.5))
    self.scene:setPosition(size.width * 0.5, size.height * 0.5)


    --添加弹幕层
    self:addBarrageLayer()
    --初始化普通阵
    self:initPuTongZhen()

    --点击初始化相关数据
    self:taptapInit()

    self.scene:getChildByName("Button_buzhen"):addTouchEventListener(handler(self, self.buzhenBtnCbk))

    self.scene:getChildByName("Panel_tap"):addTouchEventListener(handler(self, self.jinshouzhiBtnCbk))
    self.scene:getChildByName("Panel_tap"):setTouchEnabled(true)

    --zhan

    self:nnff()


    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))

    self:addListener()

    self:TapTapUI()

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


    end
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

function FightScene:nnff(  )
    print("YYYYY         11111111111111111111111111    isOverisOverisOverisOverisOver       1111")

    if self.NodeTimeNum > 0 then
        local nnffID = cc.UserDefault:getInstance():getIntegerForKey(mm.data.playerinfo.id .. "nnffID",1)
        cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "nnffID",nnffID + 1)
    end

    fight:initNode()
    fight:initBattlefield({scene = self, unitTA = mm.puTongZhen, myplayerHero = mm.data.playerHero, typeA = 1,
                    unitTB = self:nnffInit(), diplayerHero = mm.data.playerHero, typeB = 1, GuaiWu = 1, nnffInfo = self:nnffInfo()
                    })
    self.curNnffId = self.curNnffId + 1
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

function FightScene:buzhenBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if gameUtil.getPlayerLv(mm.data.playerinfo.exp) > 1 then
            local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_})
            self:addChild(BuZhenLayer, MoGlobalZorder[2000002])
            BuZhenLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(BuZhenLayer)
        end
    end
end

--点击初始化相关数据
function FightScene:taptapInit( ... )
    self.curNnffId = 1
    self.NodeTimeNum = 0

    self.Node_Time = self.scene:getChildByName("Node_Time")
end

--弹幕
function FightScene:addBarrageLayer()
    local BarrageLayer = require("src.app.views.layer.BarrageLayer").new({tag = "FightScene"})
    BarrageLayer:setName("BarrageLayer")
    self:addChild(BarrageLayer, MoGlobalZorder[2999999])
    local size  = cc.Director:getInstance():getWinSize()
    BarrageLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(BarrageLayer)
end

--初始化普通阵
function FightScene:initPuTongZhen()
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
end


return FightScene