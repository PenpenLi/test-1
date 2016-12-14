local FightScene = class("FightScene", cc.load("mvc").ViewBase)
FightScene.RESOURCE_FILENAME = "FightScene.csb"


-- INITLUA = require("app.models.initLua")
PEIZHI = require("app.res.peizhi")
-- INITLUA:fightSceneLoad()
local fight = require("app.fight.Fight")
fight:init()
local PlayFight = require("app.fight.PlayFight")

require("app.views.mmExtend.gameUtil")

require("app.views.mmExtend.MoGlobalZorder")

gameTimer = require("app/views/mmExtend/Timer")
gameTimer:new()
--玩家阵营始终为 1

-- Guide = require("app/models/guide")



require("app.res.MoResConstants")

-- G_BossTable = require("app.res.BossRes")
-- G_LvTable = require("app.res.LvRes")
-- G_PetTable = require("app.res.PetRes")

bossTable = require("app.res.bossTableRes")
equipTable = require("app.res.equipTableRes")
goldTable = require("app.res.goldTableRes")
materialTable = require("app.res.materialTableRes")
petTable = require("app.res.petTableRes")
equipLvTable = require("app.res.equipLvTableRes")


local CheckpointCount = 9 --每一关小怪个数
local BossTime = 30 --boss的击杀时间


local size  = cc.Director:getInstance():getWinSize()

-- mm.data.player = {
--     {id = 10000001, lv = 1, skillLv = 1, eq01 = 1, eq02 = 1, eq03 = 1, },
-- }

-- mm.data.playerPet = {
--     {id = 101110001, lv = 3, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
--     {id = 101110002, lv = 6, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
--     {id = 101110003, lv = 11, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
--     {id = 101110004, lv = 19, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
--     {id = 101110005, lv = 10, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
-- }

mm.puTongZhen = {
        101110001,
        101110002,
        101110003,
        101110004,
        -- 101110005,
    }


mm.data.playerBag = {
    {id = 101110006, num = 10, },
    {id = 101110007, num = 20, },
    {id = 101110008, num = 15, },
}

game.qualityTab = {
    {str = "R"},
    {str = "S"},
    {str = "SR"},
    {str = "SSR"}
}


mm.data.playerHero = mm.data.playerPet

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

    --初始化主界面UI
    self:UIInit()

    -- self.scene:getChildByName("Button_buzhen"):addTouchEventListener(handler(self, self.buzhenBtnCbk))

    self.scene:getChildByName("Panel_tap"):addTouchEventListener(handler(self, self.jinshouzhiBtnCbk))
    self.scene:getChildByName("Panel_tap"):setTouchEnabled(true)

    --zhan

    self:nnff()


    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))

    self:addListener()

    self:TapTapUI()

    self:setCheckpointShow()

    self:timeUpdate()

    self:updatePublic()
end

function FightScene:updatePublic()
    self.goldText:setString(mm.data.base.gold)

    self.zhanliText:setString("战力：9999999")
end

function FightScene:onEnter() 
    game.G_FightScene = self
end

function FightScene:UIInit() 
    self.zhujueBtn = self.scene:getChildByName("Image_bottom"):getChildByName("Button_1")
    self.zhujueBtn:addTouchEventListener(handler(self, self.zhujueBtnCbk))

    self.petBtn = self.scene:getChildByName("Image_bottom"):getChildByName("Button_2")
    self.petBtn:addTouchEventListener(handler(self, self.petBtnCbk))

    self.scene:getChildByName("Text_nickName"):setString(mm.data.base.nickName)

    self.goldText = self.scene:getChildByName("Node_gold"):getChildByName("Text")
    self.zhanliText = self.scene:getChildByName("Text_zhanli")
end

function FightScene:zhujueBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.Player.PlayerLayer",
                            resName = "PlayerLayer",params = {}} )
    end
end

function FightScene:petBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm.pushLayoer( {scene = self, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.Pet.PetListLayer",
                            resName = "PetListLayer",params = {}} )
    end
end



function FightScene:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "killmonster" then
            self:updatePublic()
        elseif event.code == "stageaccount" then

            self:updatePublic()
        end
    end
    if event.name == EventDef.UI_MSG then
        if event.code == "refreshMainUI" then
        
        end
    end
end

function FightScene:timeUpdate()
    local function time( dt )
        if self.NodeTimeNum > 0 and self.curBloodText then
            self.NodeTimeNum = self.NodeTimeNum - dt
            self.NodeTimeBar:setPercent(math.ceil(self.NodeTimeNum / BossTime * 100))
            self.curBloodText:setString( string.format("%.2f", self.NodeTimeNum))

            if self.NodeTimeNum <= 0 then
                --时间到，失败
                fight:setTimeZero()
                --小于0就显示0
                self.curBloodText:setString( string.format("%.2f", 0))
            end
        else

        end
        
    end
    
    self.goldTick =  self:getScheduler():scheduleScriptFunc(time, 0.064,false)


end

function FightScene:setCheckpointShow()
    local num = mm.data.base.stage --cc.UserDefault:getInstance():getIntegerForKey(mm.data.player.id .. "nnffID",1)
    self.scene:getChildByName("Image_old"):getChildByName("Text"):setString(num - 1)
    self.scene:getChildByName("Image_now"):getChildByName("Text"):setString(num)
    self.scene:getChildByName("Image_new"):getChildByName("Text"):setString(num + 1)
end


function FightScene:jinshouzhiBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if not fight:UnitB1() then
            return
        end

        local unitA = self.scene:getChildByName("Node_tianshi")
        local unitB = self.scene:getChildByName("b_1")
         
        local skeletonNode = self.tianShiSkeletonNode
        local function attack( ... )
            print("  点击 杀    ")
            skeletonNode:setAnimation(0, "attack", false)
            skeletonNode:setTimeScale(3)
            local function ackBack()
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                    skeletonNode:setAnimation(0, "stand", true)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            if fight:UnitB1() then
                local hurt = (-1) * (mm.data.player.lv + mm.data.player.skillLv)
                fight:UnitB1():setPiaoxue(hurt, nil, 1, true)
            end
        end

        attack()
        -- self.co = coroutine.create(function()
        --     attack()
        -- end)
        -- coroutine.resume(self.co, self)


    end
end

function FightScene:nnffInit(  )
    self.herpNNFF = {
        101110001,
        101110002,
        101110003,
        101110004,
        101110005,
    }

    local num = math.random(1,#self.herpNNFF)
    local TB = {self.herpNNFF[num]}
    return TB
end

function FightScene:getBossBlood(lv)
    local id = 401110000 + lv
    return bossTable[id].blood
end

function FightScene:nnffInfo(  )
    local tab = {}
    local nnffID = mm.data.base.stage--cc.UserDefault:getInstance():getIntegerForKey(mm.data.player.id .. "nnffID",1)
    print("当前关卡  "..nnffID)
    tab.blood = self:getBossBlood(nnffID) * (0.5 +  self.curNnffId * 0.05)
    tab.size = 0.5
    tab.time = 0
    if self.curNnffId > CheckpointCount then
        tab.blood = self:getBossBlood(nnffID)
        self.curNnffId = 0
        tab.size = 0.8
        tab.time = BossTime

        self:showBlood()
    else
        self.NodeTimeNum = 0
        self.Node_Time:setVisible(false)
    end

    self:setCheckpointShow()

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

        self.curBloodText = ccui.Text:create(BBossTime, "fonts/huakang.TTF", 30)
        self.curBloodText:setColor(cc.c3b(205, 149, 12))
        self.curBloodText:setPosition(cc.p(-50,10))
        self.NodeTimeBar:addChild(self.curBloodText)
    else
        self.NodeTimeBar:setVisible(true)
    end

    self.NodeTimeNum = BossTime
    self.Node_Time:setVisible(true)
end

function FightScene:nnff(  )

    if self.NodeTimeNum > 0 then
        local nnffID = mm.data.base.stage--cc.UserDefault:getInstance():getIntegerForKey(mm.data.player.id .. "nnffID",1)
        -- cc.UserDefault:getInstance():setIntegerForKey(mm.data.player.id .. "nnffID",nnffID + 1)
        mm.req("stageaccount",{})
    else
        mm.req("killmonster",{})
    end

    fight:initNode()
    self:updateFormationInfo()
    fight:initBattlefield({scene = self, unitTA = mm.puTongZhen, myplayerHero = mm.data.playerHero, typeA = 1,
                    unitTB = self:nnffInit(), diplayerHero = mm.data.playerHero, typeB = 1, GuaiWu = 1, nnffInfo = self:nnffInfo()
                    })
    self.curNnffId = self.curNnffId + 1
end


function FightScene:TapTapUI()
    local res = "res/spine/playerRes/hero_1x/hero_1x"
    local tianshiNode = self.scene:getChildByName("Node_tianshi")
    local id = 101110001
    local skeletonNode = gameUtil.createSkeletonAnimationForUnit(res..".json", res..".atlas",1)
    tianshiNode:addChild(skeletonNode)
    skeletonNode:setPosition(0,0)
    skeletonNode:setScale(0.3)
    skeletonNode:setAnimation(0, "dle", true)
    self.tianShiSkeletonNode = skeletonNode


    game.speedBuff = 1

    
    self:updateFormationInfo()

end

function FightScene:updateFormationInfo( ... )
    game.skillBtnTab = {}
    print("TapTapUI          "..#mm.puTongZhen)
    for i=1,#mm.puTongZhen do
        local id = mm.puTongZhen[i]
        -- print("TapTapUI   id       "..id)
        -- local HeroRes = gameUtil.getHeroTab( id )

        -- local skillId = HeroRes.Skills[1]
        -- local skillRes = gameUtil.getHeroSkillTab( skillId )
        -- local skillIconRes = skillRes.sicon

        -- print("TapTapUI   skillId       "..skillId)

        -- print("TapTapUI   skillIconRes       "..skillIconRes)

        -- local iconImageView = ccui.ImageView:create()
        -- iconImageView:loadTexture(skillIconRes..".png")  
        -- iconImageView:setTouchEnabled(true)
        -- iconImageView:addTouchEventListener(handler(self, self.SkillBtnCbk))
        -- iconImageView:setTag(id)
        game.skillBtnTab[id] = {}
        game.skillBtnTab[id].can = false


        -- self.scene:getChildByName("Node_skill_0"..i):addChild(iconImageView)

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
        self.app_:run("LoginSceneFinal")
    end
    self.listeners[5] = cc.EventListenerCustom:create("login_data_refesh",eventCustomListener5)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[5], 1)

end

function FightScene:buzhenBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if gameUtil.getPlayerLv(mm.data.player.exp) > 1 then
            local BuZhenLayer = require("src.app.views.layer.Formation.BuZhenNewLayer").new({app = self.app_})
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
    -- mm.puTongZhen = {}
    -- if not mm.data.playerFormation or #mm.data.playerFormation <= 0 then
    --     mm.puTongZhen = self:getUnitIDA()
    -- else
    --     for i=1,#mm.data.playerFormation do
    --         if mm.data.playerFormation[i].type == 1 then
    --             for j=1,#mm.data.playerFormation[i].formationTab do
    --                 table.insert(mm.puTongZhen, mm.data.playerFormation[i].formationTab[j].id)
    --             end
    --         end
    --     end
    -- end
end


return FightScene