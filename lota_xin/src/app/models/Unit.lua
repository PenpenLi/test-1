local Unit = class("Unit")
Unit.__index = Unit

local debug_xue = 0

local MONSTERTYPE = 3

function Unit.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, Unit)
    return target
end


function Unit:onEnter() 
    
end

function Unit:onExit()

end

function Unit.create(param)
    local node = param.node
    local layerCsb = Unit.extend(node) 
    if layerCsb then 
        layerCsb:init(param)
    end
    return layerCsb
end

function Unit:init(param)
    self.fight = param.fight
    self.unitid = param.unitid
    self.fScene = self.fight.fScene

    self.fightParam = param.fightParam
    self.campType = param.campType

    self.fightType = param.fightType
    self.meleeTab = param.meleeTab

    self.HeroId = param.HeroId
    ccfightLog(" ID ID ID ID ".. self.HeroId)
    self.playHero = param.playHero

    self.type = param.playType  -- 3 关卡

    self.GuaiWu = self.fightParam.GuaiWu

    self.zorder = param.zorder

    self.nnffInfo = param.nnffInfo

    self:setLocalZOrder(self.zorder)

    local heroTab = nil

    if self.type == MONSTERTYPE then
        --ccfightLog("关卡 怪物 ID ".. self.HeroId)
        self.monsterTab = INITLUA:getMonsterResById( self.HeroId )
        heroTab = {}
        heroTab.id = self.HeroId
        heroTab.lv = self.monsterTab.monster_lv
        heroTab.xinlv = self.monsterTab.chushixin
        heroTab.jinlv = self.monsterTab.monster_rank
        heroTab.exp  = 0
        heroTab.eqTab  = {}

    else

        if self.playHero  then
            for i=1,#self.playHero do
                if self.playHero[i].id == self.HeroId then
                    heroTab = self.playHero[i]
                    break
                end
            end
        end
        if not heroTab then
            heroTab = {}
            heroTab.id = self.HeroId
            heroTab.lv = 1
            heroTab.xinlv = 1
            heroTab.jinlv = 1
            heroTab.exp  = 0
            heroTab.eqTab  = {}
        end
    end
    self.heroTab = heroTab
    if self.heroTab.preciousInfo then
    else
    end



    heroTab.lv = gameUtil.getHeroLv(heroTab.exp, heroTab.jinlv)

    self:initValue(param)


    self.campType = param.campType
    local scale = param.scale
    local scaleX = param.scaleX
    self.index = param.index

    local delay = {0,0.5,0.8,1.0,1.1}

    local function addHero(  )
        self.skeletonNode = gameUtil.createSkeletonAnimationForUnit(self:getSRC( self.HeroId )..".json", self:getSRC( self.HeroId )..".atlas",1)
        self:addChild(self.skeletonNode)
        self.skeletonNode:setPosition(cc.p(0,0))
        
  
        if scaleX then 
            self.skeletonNode:setScaleX((-1)*scale) 
            self.skeletonNode:setScaleY(scale)
        else
            self.skeletonNode:setScaleX(scale)
            self.skeletonNode:setScaleY(scale)
        end

        self.skeletonNode:update(0.012)
        
        
        self.skeletonNode:setAnimation(0, "stand", true)


        self.nodeHeight = 125--self.skeletonNode:getBoundingBox().height

        local imageView = ccui.ImageView:create()
        imageView:loadTexture("res/UI/jm_xuetiaodi.png")
        self.skeletonNode:addChild(imageView)
        imageView:setPositionY(150)
        imageView:setVisible(false)
        self.barImageBg = imageView

        local barRes = ""
        if self.campType == CAMP_A_TYPE then
            barRes = "res/UI/jm_xuetiaolv.png"
        else
            barRes = "res/UI/jm_xuetiaohong.png"
        end
        local loadingBar = ccui.LoadingBar:create()
        loadingBar:setName("xueBar")
        loadingBar:loadTexture(barRes)
        loadingBar:setPercent(100)
        self.skeletonNode:addChild(loadingBar)
        loadingBar:setPositionY(150)
        loadingBar:setVisible(false)
        self.loadingBar = loadingBar
        self.barImageBg:setScale(self.loadingBar:getContentSize().width/self.barImageBg:getContentSize().width, self.loadingBar:getContentSize().height/self.barImageBg:getContentSize().height)

        local yiyinImageView = ccui.ImageView:create()
        yiyinImageView:loadTexture("res/UI/jm_yinying.png")
        self:addChild(yiyinImageView)
        yiyinImageView:setName("yinying")
        yiyinImageView:setLocalZOrder(-20)
        yiyinImageView:setScale(0.7)    

    end

    --添加出现特效
    -- if self.campType == 2 then
        local function addDrcx(  )
            local anime = gameUtil.createSkeAnmion( {name = "drcx",scale = 1} )
            anime:setAnimation(0, "stand", false)
            self:addChild(anime)
            anime:setOpacity(255)
            anime:update(0.012)
            gameUtil.playUIEffect( "Enemy_Birth" )
            anime:setScale(1)
        end


        
        self:runAction( cc.Sequence:create(cc.DelayTime:create(delay[self.index]), cc.CallFunc:create(addDrcx), cc.DelayTime:create(0.5), cc.CallFunc:create(addHero) ))

    -- elseif self.campType == 1 then
    --     local fuhuoPath = "res/Effect/yingxiong/gongyong/t_10/t_10"
    --     local fuhuoNode = gameUtil.createSkeletonAnimation(fuhuoPath..".json", fuhuoPath..".atlas",0.5)
    --     self:addChild(fuhuoNode)
    --     fuhuoNode:setAnimation(0, "mb", false)
    --     --fuhuoNode:setPosition(0,50)

    --     self:runAction( cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(addHero) ))
    -- end



    ccfightLog(" getHeroSkillsEx       siji  0005")
    

    

    if debug_xue == 1 then
        self.curBloodText = ccui.Text:create(math.ceil(self.curBlood), "fonts/huakang.TTF", 24)
        self.curBloodText:setFontName("curBloodText")
        self.curBloodText:setColor(cc.c3b(255, 255, 255))
        self.curBloodText:setPosition(cc.p(0,-20))
        self:addChild(self.curBloodText)
    end

end

function Unit:initValue(param)
    self.skillID = self:getHeroSkillsId()
    self.skillTAB = gameUtil.getHeroSkillTab( self.skillID )
    self.HeroSkillsEx = self:getHeroSkillsEx( self.HeroId )



    self.initialBlood = self:getInitialBlood()
    self.curBlood = self.initialBlood
    self.initialSpeed = self:getInitialSpeed()
    self.curSpeed = self.initialSpeed
    self.initialPos = 0
    self.curPos = self.initialPos
    self.skillType = self:getSkillType() --作用方
    self.skillObject = {1,2,3,4,5}
    self.effectType = 1
    self.initialAck = self:getInitialAck()
    self.curAck = self.initialAck
    self.initialDodge = self:getInitialDodge()
    self.curDodge = self.initialDodge
    self.initialCrit = self:getInitialCrit()
    self.curCrit = self.initialCrit
    self.initialWufang = self:getInitialWufang()--护甲
    self.curWufang = self.initialWufang
    self.initialMofang = self:getInitialMofang()--魔抗
    self.curMofang = self.initialMofang
    self.initialCritTimes = self:getInitialCritTimes()--暴击倍数
    self.curCritTimes = self.initialCritTimes
    self.initialArmorP = self:getInitialArmorP()--物理穿透
    self.curArmorP = self.initialArmorP
    self.initialMAP = self:getInitialMAP()--魔法穿透
    self.curMAP = self.initialMAP
    self.initialADParry = self:getInitialADParry()--物理格挡
    self.curADParry = self.initialADParry
    self.initialAPParry = self:getInitialAPParry()--法术格挡
    self.curAPParry = self.initialAPParry
    self.initialExemptAD = self:getInitialExemptAD()--物理减免
    self.curExemptAD = self.initialExemptAD
    self.initialExemptAP = self:getInitialExemptAP()--法术减免
    self.curExemptAP = self.initialExemptAP
    self.initialADRebound = self:getInitialADRebound()--物理反弹
    self.curADRebound = self.initialADRebound
    self.initialAPRebound = self:getInitialAPRebound()--法术反弹
    self.curAPRebound = self.initialAPRebound
    self.initialADxixue = self:getInitialADxixue()--物理吸血 普通攻击吸血
    self.curADxixue = self.initialADxixue
    self.initialRebirth = self:getInitialRebirth()--重生
    self.curRebirth = self.initialRebirth
    self.initialIgnoreAD = self:getInitialIgnoreAD()--物理免疫
    self.curIgnoreAD = self.initialIgnoreAD
    self.initialIgnoreAP = self:getInitialIgnoreAP()--魔法免疫
    self.curIgnoreAP = self.initialIgnoreAP
    self.initialADDeep = self:getInitialADDeep()--物理加深
    self.curADDeep = self.initialADDeep
    self.initialAPDeep = self:getInitialAPDeep()--法术加深
    self.curAPDeep = self.initialAPDeep


    self.actTimes = self:getInitActTimes()

    self.TriggerType, self.TrNum = self:initSkillTriggerType()

    self.binDongTime = 0

    self.silenceTime = 0

    self.xuanYunTime = 0

    self.yangTime = 0

    self.jihhuoTime = 0

    self.HuJiaTime = 0
    self.initHuJiaXue = 0
    self.HuJiaXue = 0

    self.WuLiHuDunTime = 0
    self.initWuLiHuDunXue = 0
    self.WuLiHuDunXue = 0

    ccfightLog(" getHeroSkillsEx       siji  0001")

end

function Unit:getInitBlood( ... )
    return self.initialBlood
end

function Unit:getExemptAD( ... )
    local gh_BP_ExemptAD = self:GH_Add( MM.EPassiveProperty.BP_ExemptAD).gh_BP_ExemptAD

    return self.curExemptAD + gh_BP_ExemptAD
end

function Unit:getExemptAP( ... )
    local gh_BP_ExemptAP = self:GH_Add( MM.EPassiveProperty.BP_ExemptAP).gh_BP_ExemptAP

    return self.curExemptAP
end

function Unit:getADParry( ... )
    local gh_BP_ADParry = self:GH_Add( MM.EPassiveProperty.BP_ADParry).gh_BP_ADParry

    return self.curADParry + gh_BP_ADParry
end

function Unit:getAPParry( ... )
    local gh_BP_APParry = self:GH_Add( MM.EPassiveProperty.BP_APParry).gh_BP_APParry

    return self.curAPParry + gh_BP_APParry
end

function Unit:getArmorP( ... )
    --光环
    local gh_BP_ArmorP = self:GH_Add( MM.EPassiveProperty.BP_ArmorP).gh_BP_ArmorP

    return self.curArmorP + gh_BP_ArmorP
end

function Unit:geMAP( ... )
    local gh_BP_MAP = self:GH_Add( MM.EPassiveProperty.BP_MAP).gh_BP_MAP

    return self.curWufang * (1 + gh_BP_MAP) 
end

function Unit:getADRebound( ... )
    local gh_BP_ADRebound = self:GH_Add( MM.EPassiveProperty.BP_ADRebound).gh_BP_ADRebound

    return self.curADRebound + gh_BP_ADRebound
end

function Unit:getAPRebound( ... )
    local gh_BP_APRebound = self:GH_Add( MM.EPassiveProperty.BP_APRebound).gh_BP_APRebound
    return self.curAPRebound + gh_BP_APRebound
end

function Unit:getADxixue( ... )
    local gh_BP_ADxixue = self:GH_Add( MM.EPassiveProperty.BP_ADxixue).gh_BP_ADxixue
    return self.curADxixue + gh_BP_ADxixue
end

function Unit:getRebirth( ... )
    return self.curRebirth
end

function Unit:setRebirth()
    self.curRebirth = 0
end

function Unit:getIgnoreAD()
    local gh_BP_IgnoreAD = self:GH_Add( MM.EPassiveProperty.BP_IgnoreAD).gh_BP_IgnoreAD
    return self.curIgnoreAD + gh_BP_IgnoreAD
end

function Unit:getIgnoreAP()
    local gh_BP_IgnoreAP = self:GH_Add( MM.EPassiveProperty.BP_IgnoreAP).gh_BP_IgnoreAP
    return self.curIgnoreAP + gh_BP_IgnoreAP
end

function Unit:getADDeep()
    local gh_BP_ADDeep = self:GH_Add( MM.EPassiveProperty.BP_ADDeep).gh_BP_ADDeep
    return self.curADDeep + gh_BP_ADDeep
end

function Unit:getAPDeep()
    local gh_BP_APDeep = self:GH_Add( MM.EPassiveProperty.BP_APDeep).gh_BP_APDeep
    return self.curAPDeep + gh_BP_APDeep
end

function Unit:getInitialAPDeep( ... )
    local APDeep = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        APDeep = APDeep + self:BPAPDeep( skillsExTab[i], SkillLv )
    end

    return APDeep
end

function Unit:getInitialADDeep( ... )
    local ADDeep = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        ADDeep = ADDeep + self:BPADDeep( skillsExTab[i], SkillLv )
    end

    return ADDeep
end

function Unit:getInitialIgnoreAP( ... )
    local IgnoreAP = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        IgnoreAP = IgnoreAP + self:BPIgnoreAP( skillsExTab[i], SkillLv )
    end

    return IgnoreAP
end

function Unit:getInitialIgnoreAD( ... )
    local IgnoreAD = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        IgnoreAD = IgnoreAD + self:BPIgnoreAD( skillsExTab[i], SkillLv )
    end

    return IgnoreAD
end

function Unit:getInitialRebirth( ... )
    local Rebirth = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        Rebirth = Rebirth + self:BPRebirth( skillsExTab[i], SkillLv )
    end

    return Rebirth
end

function Unit:getInitialADxixue( ... )
    local ADxixue = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        ADxixue = ADxixue + self:BPADxixue( skillsExTab[i], SkillLv )
    end

    return ADxixue
end

function Unit:getInitialAPRebound( ... )
    local APRebound = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        APRebound = APRebound + self:BPAPRebound( skillsExTab[i], SkillLv )
    end

    return APRebound
end

function Unit:getInitialADRebound( ... )
    local ADRebound = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        ADRebound = ADRebound + self:BPADRebound( skillsExTab[i], SkillLv )
    end

    return ADRebound
end

function Unit:getInitialExemptAP( ... )
    local ExemptAP = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        ExemptAP = ExemptAP + self:BPExemptAP( skillsExTab[i], SkillLv )
    end

    return ExemptAP
end

function Unit:getInitialExemptAD( ... )
    local ExemptAD = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        ExemptAD = ExemptAD + self:BPExemptAD( skillsExTab[i], SkillLv )
    end

    return ExemptAD
end

function Unit:getInitialAPParry( ... )
    local APParry = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        APParry = APParry + self:BPAPParry( skillsExTab[i], SkillLv )
    end

    return APParry
end

function Unit:getInitialADParry( ... )
    local ADParry = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        ADParry = ADParry + self:BPADParry( skillsExTab[i], SkillLv )
    end

    return ADParry
end

function Unit:getInitialMAP( ... )
    local MAP = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        MAP = MAP + self:BPMAP( skillsExTab[i], SkillLv )
    end

    return MAP
end

function Unit:getInitialArmorP( ... )
    local armorP = 0

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        armorP = armorP + self:BPArmorP( skillsExTab[i], SkillLv )
    end

    return armorP
end

function Unit:getInitialCritTimes( ... )
    local critTimes = 1.5

    local skillsExTab = self.HeroSkillsEx
    --todo
    for i=1,#skillsExTab do
        local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
        critTimes = critTimes + self:BPCrit( skillsExTab[i], SkillLv )
    end

    return critTimes
end

function Unit:BPLife( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Life then
        if SkillLv and SkillLv > 0 then
            return math.ceil(tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1))
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPAttack( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Attack then
        if SkillLv and SkillLv > 0 then
            return math.ceil(tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1))
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPCrit( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Crit then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPCrit( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Crit then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPSpeed( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Speed then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPArmor( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Armor then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPMA( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_MA then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPArmorP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ArmorP then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPMAP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_MAP then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPLifePre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_LifePre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPAttackPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_AttackPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPSpeedPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_SpeedPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPDADPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_DADPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPDAPPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_DAPPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPADParry( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADParry then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPAPParry( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_APParry then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPExemptAD( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ExemptAD then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPExemptAP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ExemptAP then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPADRebound( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADRebound then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPAPRebound( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_APRebound then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPADxixue( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADxixue then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPRebirth( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Rebirth then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPADDeep( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADDeep then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPAPDeep( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_APDeep then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPIgnoreAD( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_IgnoreAD then
        if SkillLv and SkillLv > 0 then
            return 1
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:BPIgnoreAP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_IgnoreAP then
        if SkillLv and SkillLv > 0 then
            return 1
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:getInitActTimes( ... )
    return self.skillTAB.actTimes
end

function Unit:getCurActTimes( ... )
    return self.actTimes
end

function Unit:getSkillTriggerType( ... )
    return self.TriggerType, self.TrNum
end

function Unit:setSkillTriggerType( TriggerType )
    self.TriggerType = TriggerType
end

function Unit:initSkillTriggerType( ... )
    local id = self:getHeroSkillsId()
    return gameUtil.getHeroSkillTab( id ).TriggerType, gameUtil.getHeroSkillTab( id ).TrNum
end

function Unit:getInitZorder( ... )
    return self.zorder
end

function Unit:getInitialMofang( ... )
    local mofangNum = 0
    if self.type == MONSTERTYPE then
        mofangNum = self.monsterTab.MoFang
    else
        mofangNum = gameUtil.mofangMBAck( { heroid = self.heroTab.id, lv = self.heroTab.lv, xinlv = self.heroTab.xinlv, jinlv = self.heroTab.jinlv, eqTab = self.heroTab.eqTab, preciousInfo = self.heroTab.preciousInfo, skinInfo = self.heroTab.skinInfo} )
        local skillsExTab = self.HeroSkillsEx
        --todo
        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            mofangNum = mofangNum + self:BPMA( skillsExTab[i], SkillLv )
        end
        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            mofangNum = mofangNum * (1 + self:BPDAPPre( skillsExTab[i], SkillLv )) 
        end

    end
    return mofangNum

end

function Unit:getMofang( ... )
    local curMofang = self.curMofang
    --添加光环护甲
    local gh_BP_MA = self:GH_Add( MM.EPassiveProperty.BP_MA).gh_BP_MA
    curMofang = curMofang + gh_BP_MA

    local gh_BP_DAPPre = self:GH_Add( MM.EPassiveProperty.BP_DAPPre).gh_BP_DAPPre
    curMofang = curMofang * (1 + gh_BP_DAPPre) 

    return curMofang
end

function Unit:getInitialWufang( ... )
    local wufangNum = 0
    if self.type == MONSTERTYPE then
        wufangNum =  self.monsterTab.WuFang
    else
        wufangNum = gameUtil.wufangMBAck( { heroid = self.heroTab.id, lv = self.heroTab.lv, xinlv = self.heroTab.xinlv,  jinlv = self.heroTab.jinlv, eqTab = self.heroTab.eqTab, preciousInfo = self.heroTab.preciousInfo, skinInfo = self.heroTab.skinInfo} )
        local skillsExTab = self.HeroSkillsEx
        --todo
        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            wufangNum = wufangNum + self:BPArmor( skillsExTab[i], SkillLv )
        end

        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            wufangNum = wufangNum * (1 + self:BPDADPre( skillsExTab[i], SkillLv )) 
        end

        
    end

    return wufangNum

end

function Unit:getWufang( ... )
    local curWufang = self.curWufang
    --添加光环护甲
    local gh_BP_Armor = self:GH_Add( MM.EPassiveProperty.BP_Armor).gh_BP_Armor
    curWufang = curWufang + gh_BP_Armor

    local gh_BP_DADPre = self:GH_Add( MM.EPassiveProperty.BP_DADPre).gh_BP_DADPre
    curWufang = curWufang * (1 + gh_BP_DADPre) 

    return curWufang
end

function Unit:getInitialCrit( ... )
    if self.type == MONSTERTYPE then
        return self.monsterTab.Crit
    end

    local critNum = gameUtil.critMBAck( { heroid = self.heroTab.id, lv = self.heroTab.lv, xinlv = self.heroTab.xinlv,  jinlv = self.heroTab.jinlv, eqTab = self.heroTab.eqTab, preciousInfo = self.heroTab.preciousInfo, skinInfo = self.heroTab.skinInfo} )
    
    if not critNum then
        ccfightLog("有没有  3    ")
    end

    return critNum

end

function Unit:getCrit( ... )
    return self.curCrit
end

function Unit:getInitialDodge( ... )
    if self.type == MONSTERTYPE then
        return self.monsterTab.Dodge
    end

    local dodgeNum = gameUtil.dodgeMBAck( { heroid = self.heroTab.id, lv = self.heroTab.lv, xinlv = self.heroTab.xinlv,  jinlv = self.heroTab.jinlv, eqTab = self.heroTab.eqTab, skinInfo = self.heroTab.skinInfo} )
    
    if not dodgeNum then
        ccfightLog("有没有  4    ")
    end

    return dodgeNum

end

function Unit:getDodge( ... )
    return self.curDodge
end

function Unit:getInitialAck( ... )
    local ackNum = 0
    if self.type == MONSTERTYPE then
        ackNum =  self.monsterTab.Attack
    else
        ackNum = gameUtil.heroMBAck( { heroid = self.heroTab.id, lv = self.heroTab.lv, xinlv = self.heroTab.xinlv,  jinlv = self.heroTab.jinlv, eqTab = self.heroTab.eqTab, preciousInfo = self.heroTab.preciousInfo, skinInfo = self.heroTab.skinInfo} )
        
        --替补修正，抢夺战力修正
        local myplayerHero = self.fightParam.myplayerHero
        local diplayerHero = self.fightParam.diplayerHero
        local myPkValue = self.fightParam.myPkValue
        local diPkValue = self.fightParam.diPkValue

        local heroTab = nil
        local pkValue = nil
        if self.campType == CAMP_A_TYPE then
            heroTab = myplayerHero
            pkValue =  myPkValue
        else
            heroTab = diplayerHero
            pkValue =  diPkValue
        end

        local allHeroTiBuBeiLvXiShu = gameUtil.allHeroTiBuBeiLvXiShu( heroTab )

        ackNum = gameUtil.AckTBXZ( ackNum, allHeroTiBuBeiLvXiShu, pkValue )


        local skillsExTab = self.HeroSkillsEx
        --被动固定
        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            ackNum = ackNum + self:BPAttack( skillsExTab[i], SkillLv )
        end

        --光环固定攻击
        local gh_BP_Attack = self:GH_Add( MM.EPassiveProperty.BP_Attack).gh_BP_Attack
        ackNum = ackNum + gh_BP_Attack
        
        --被动比例
        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            ackNum = ackNum * (1 + self:BPAttackPre( skillsExTab[i], SkillLv ))
        end

        --光环攻击比例
        local gh_BP_AttackPre = self:GH_Add( MM.EPassiveProperty.BP_AttackPre).gh_BP_AttackPre
        ackNum = ackNum * (1 + gh_BP_AttackPre)


        --修正攻击力 = 正常最终攻击力 * (1 + X * 当前祝福次数）
        --乱斗加成
        if self.fightType == 1 then 
            local zhufuTimes = self.meleeTab.zhufuTimes
            local X = self.meleeTab.X
            ackNum = ackNum * (1 + zhufuTimes * X) 
        end


    end
   
    return ackNum 

end

function Unit:getAck( ... )
    return self.curAck * (-1)--self.curAck
end

--[[
A→B物理伤害 = （A伤害基础值 + A技能附加值 + A技能附加值成长* A技能等级）* （1 - B物理减伤） * 波动随机值
A→B法术伤害 = （A伤害基础值 + A技能附加值 + A技能附加值成长* A技能等级）* （1 - B法术减伤） * 波动随机值

如果  (护甲>=0)
物理减伤 = 护甲/（ABS(护甲)+10000）
否则   
物理减伤 = 护甲/（ABS(护甲)+10000）*2

如果  (魔抗>=0)
魔法减伤 = 魔抗/（ABS(魔抗)+10000）
否则   
魔法减伤 = 魔抗/（ABS(魔抗)+10000）*2
]]
function Unit:getSkillAck( mbUnit ,skillid, TgType)
    local id = skillid --self:getHeroSkillsId()
    
    local skillTab = gameUtil.getHeroSkillTab( id )
    local skillLv = gameUtil.getHeroSkillLv( self.HeroId, skillid ,self:getHero())

    if skillTab.SkillEffType == MM.ESkillEffType.NormalACK then
        skillLv = 1
    end

    if skillLv == nil  then
        skillLv = 1
        --gameUtil:addTishi( {p = mm.scene(), f = 30, s = "error:技能等级为空 " , z = 1000})
    else
        --gameUtil:addTishi( {p = mm.scene(), f = 30, s = "skillLv： "..skillLv , z = 1000})
    end

    local SJMB_A = skillTab.SJMB_A
    local SZTYPE_A = skillTab.SZTYPE_A
    local fixedHurt_A = skillTab.fixedHurt_A
    local fuhao = skillTab.Operators
    local DamageStyle = skillTab.DamageStyle

    local Target = skillTab.Target


    local SJMB_B = skillTab.SJMB_B
    local SZTYPE_B = skillTab.SZTYPE_B
    local fixedHurt_B = skillTab.fixedHurt_B

    local fixedHurt_C = skillTab.fixedHurt_C
    local UfixedHurt_C = skillTab.UfixedHurt_C

    

    local baseHurt = nil
    local baseA = nil
    if fixedHurt_A > 0 then
        baseA = fixedHurt_A
    else
        local mbUt = self:getSjmbUnit(SJMB_A,mbUnit)
        if not mbUt then
            ccfightLog("mbUt作用方为空！！")
        end
        baseA = self:getSjmbNum(mbUt, SZTYPE_A)
        if not baseA then
            ccfightLog("baseA作用方为空！！")
        end
    end

    local baseB = nil
    if fixedHurt_B > 0 then
        baseB = fixedHurt_B
    else
        local mbUt = self:getSjmbUnit(SJMB_B,mbUnit)
        if not mbUt then
            ccfightLog("mbUt作用方为空！！")
        end
        baseB = self:getSjmbNum(mbUt, SZTYPE_B)
        if not baseB then
            ccfightLog("baseB作用方为空！！")
        end
    end

    local base = nil
    if fuhao == MM.EOperators.jia then
        base = baseA + baseB
    elseif fuhao == MM.EOperators.jian then
        base = baseA - baseB
    elseif fuhao == MM.EOperators.chen then
        base = baseA * baseB
    elseif fuhao == MM.EOperators.chu then
        base = baseA / baseB
    else 
        base = baseA
    end

    local wufang = mbUnit:getWufang()
    --物理穿透
    if self:getArmorP() > 0 then
        wufang = wufang - self:getArmorP()
    end
    local wujian = nil
    if wufang >= 0 then
        wujian = wufang / (math.abs(wufang) + 10000)
    else
        wujian = wufang / (math.abs(wufang) + 10000) * 2
    end

    local mofang = mbUnit:getMofang()
    --法术穿透
    if self:geMAP() > 0 then
        mofang = mofang - self:geMAP()
    end
    local mojian = nil
    if mofang >= 0 then
        mojian = mofang / (math.abs(mofang) + 10000)
    else
        mojian = mofang / (math.abs(mofang) + 10000) * 2
    end
    --[[
        A→B物理伤害 = （A伤害基础值 + A技能附加值 + A技能附加值成长* A技能等级）* （1 - B物理减伤） * 波动随机值
        A→B法术伤害 = （A伤害基础值 + A技能附加值 + A技能附加值成长* A技能等级）* （1 - B法术减伤） * 波动随机值
    ]]
    
    local hurt = nil
    local bodong = math.random(80,120) * 0.01
    if DamageStyle == MM.EDamageStyle.Wuli then
        hurt = (base + fixedHurt_C + UfixedHurt_C * (skillLv - 1)) * (1 - wujian) * bodong
    elseif DamageStyle == MM.EDamageStyle.Mofa then
        hurt = (base + fixedHurt_C + UfixedHurt_C * (skillLv - 1)) * (1 - mojian) * bodong
    elseif DamageStyle == MM.EDamageStyle.Shen then
        hurt = (base + fixedHurt_C + UfixedHurt_C * (skillLv - 1)) * bodong
    else
        hurt = (base + fixedHurt_C + UfixedHurt_C * (skillLv - 1)) * bodong
        ccfightLog("没有伤害类型？？？？？先用神圣代替")
    end

    ccfightLog("初始伤害: " .. hurt)
    local add = -1
    if Target == MM.ETarget.Friend or Target == MM.ETarget.me or Target == MM.ETarget.AllFriend  then
        add = 1
    elseif Target == MM.ETarget.Enemy then
        add = -1
    else
        ccfightLog("有些类型没有写")
    end
    ccfightLog("初始伤害1: " .. hurt)
    local beishu = 1
    if TgType then
        beishu = 2
    else
        beishu = 1
    end

    local wuliCrit = nil
    if skillTab.SkillEffType == MM.ESkillEffType.NormalACK then
        local crit = math.random(1, 10000)
        -- ccfightLog("普通攻击暴击1111111111111        "..crit)
        -- ccfightLog("普通攻击暴击2222222222222        "..self.curCrit)
        if crit < self.curCrit then
            beishu = self.curCritTimes
            wuliCrit = beishu
        end
        
    else

    end
    ccfightLog("初始伤害2: " .. hurt)
    --光环暴击倍率
    local gh_BP_Crit = self:GH_Add( MM.EPassiveProperty.BP_Crit).gh_BP_Crit
    beishu = beishu + gh_BP_Crit


    local hurt = math.ceil(hurt * add) * beishu
    ccfightLog("初始伤害3: " .. hurt)

    --计算物理免疫 魔法免疫
    local wumian = nil
    local momian = nil
    local IgnoreAD = mbUnit:getIgnoreAD()
    local IgnoreAP = mbUnit:getIgnoreAP()
    if skillTab.DamageStyle == MM.EDamageStyle.Wuli then
        
        --物理加深
        if self:getADDeep() > 0 then
            hurt = hurt * (1 + self:getADDeep())
        end

        --物理减免
        if mbUnit:getExemptAD() > 0 then
            hurt = hurt * (1 - mbUnit:getExemptAD())
            if hurt > 0 then
                hurt = -1
            end
        end

        --物理格挡
        if mbUnit:getADParry() > 0 and hurt < 0 then
            hurt = hurt + mbUnit:getADParry()
            if hurt > 0 then
                hurt = -1
            end
        end

        if IgnoreAD > 0 then
            ccfightLog("物免物免物免物免物免物免物免物免物免物免物免物免")
            hurt = 0
            wumian = 1
        end
        
    elseif skillTab.DamageStyle == MM.EDamageStyle.Mofa  then
        
        --法术加深
        if self:getAPDeep() > 0 then
            hurt = hurt * (1 + self:getAPDeep())
        end

        --法术减免
        if mbUnit:getExemptAP() > 0 then
            hurt = hurt * (1 - mbUnit:getExemptAP())
            if hurt > 0 then
                hurt = -1
            end
        end

        --法术格挡
        if mbUnit:getAPParry() > 0 and hurt < 0 then
            hurt = hurt + mbUnit:getAPParry()
            if hurt > 0 then
                hurt = -1
            end
        end

        if hurt < 0 and IgnoreAP > 0 then
            ccfightLog("魔免魔免魔免魔免魔免魔免魔免魔免魔免")
            hurt = 0
            momian = 1
        end
    elseif skillTab.DamageStyle == MM.EDamageStyle.Shen then
        --todo

    else
        gameUtil:addTishi( {p = mm.scene(), f = 30, s = "技能类型没填 物理 魔法 神圣" , z = 1000})
    end


    local myHurt = 0
    if hurt < 0 then
        --计算反弹
        local skillidTab = gameUtil.getHeroSkillTab( skillid )
        if skillidTab.DamageStyle == MM.EDamageStyle.Wuli then
            local ADRebound = mbUnit:getADRebound()
            if ADRebound > 0 then
                myHurt = hurt * ADRebound
            end

            
        elseif skillidTab.DamageStyle == MM.EDamageStyle.Mofa then
            local APRebound = mbUnit:getAPRebound()
            if APRebound > 0 then
                myHurt = hurt * APRebound
            end

        elseif skillidTab.DamageStyle == MM.EDamageStyle.Shen then
            --todo

        else
            gameUtil:addTishi( {p = mm.scene(), s = "技能类型没填 物理 魔法 神圣" , z = 1000})
        end

        --计算吸血
        if skillTab.SkillEffType == MM.ESkillEffType.NormalACK then
            local ADxixue = self:getADxixue()
            if ADxixue > 0 then
                myHurt = myHurt - hurt * ADxixue
            end
        end

    end

    ccfightLog("最终伤害: " .. hurt)

    if mm.GuildId == 10001 then
        hurt = hurt * 1000
    end

    return {
                hurt = hurt, 
                wuliCrit = wuliCrit,
                myHurt = myHurt,
                wumian = wumian,
                momian = momian,
                damageStyle = skillTab.DamageStyle
            }
end

function Unit:getSjmbUnit( SJMB, mbUnit )
    if SJMB == MM.ESJMB_B.zishen then
        return self
    elseif SJMB == MM.ESJMB_B.youjun then
        return mbUnit
    elseif SJMB == MM.ESJMB_B.diren then
        return mbUnit
    else
        ccfightLog("getSjmbUnit 不对啊")
    end
end

function Unit:getSjmbNum( mbUnit, a )



    if a == MM.ESZTYPE_B.DQSM then
        return mbUnit:getCurBlood()
    elseif a == MM.ESZTYPE_B.DQSMB then
        return mbUnit:getCurBlood() / mbUnit:getInitBlood()
    elseif a == MM.ESZTYPE_B.GJ then
        return mbUnit:getInitialAck()
    elseif a == MM.ESZTYPE_B.HJ then
        return mbUnit:getInitialWufang()
    elseif a == MM.ESZTYPE_B.MK then
        return mbUnit:getInitialMofang()
    elseif a == MM.ESZTYPE_B.SD then
        return mbUnit:getSpeed()
    elseif a == MM.ESZTYPE_B.MaxLife then    
        return mbUnit:getInitBlood()
    end
end

function Unit:getBinDongTime( ... )
    return self.binDongTime
end

function Unit:setBinDongTime( binDongTime )
     self.binDongTime = binDongTime
end

function Unit:getXuanYunTime( ... )
    return self.xuanYunTime
end

function Unit:setXuanYunTime( xuanYunTime )
     self.xuanYunTime = xuanYunTime
end

function Unit:getSilenceTime( ... )
    return self.silenceTime
end

function Unit:setSilenceTime( silenceTime )
     self.silenceTime = silenceTime
end

function Unit:getYangTime( ... )
    return self.yangTime
end

function Unit:setYangTime( yangTime )
     self.yangTime = yangTime
end

function Unit:getJiHuoTime( ... )
    return self.jihhuoTime
end

function Unit:setJiHuoTime( jihhuoTime )
     self.jihhuoTime = jihhuoTime
end

function Unit:getHuJiaTime( ... )
    return self.HuJiaTime
end

function Unit:setHuJiaTime( HuJiaTime )
     self.HuJiaTime = HuJiaTime
end

function Unit:getHuJiaXue( ... )
    return self.HuJiaXue
end

function Unit:setinitHuJiaXue( xue )
    self.HuJiaXue = xue
end

function Unit:setHuJiaXue( xue )
    -- ccfightLog("calculateCurBlood ====================111= "..self.HuJiaXue)
    self.HuJiaXue = self.HuJiaXue + xue
    if self.HuJiaXue <= 0 then
        self.HuJiaXue = 0
        local huJiaNode = self:getChildByName("HuJia")
        if huJiaNode then
            huJiaNode:removeFromParent()
            if self.hujiaBarImageBg then
                self.hujiaBarImageBg:setVisible(false)
            end
            if self.loadingHuJiaBar then
                self.loadingHuJiaBar:setVisible(false)
            end
        end
    end
end

function Unit:getWuLiHuDunTime( ... )
    return self.WuLiHuDunTime
end

function Unit:setWuLiHuDunTime( WuLiHuDunTime )
     self.WuLiHuDunTime = WuLiHuDunTime
end

function Unit:getWuLiHuDunXue( ... )
    return self.WuLiHuDunXue
end

function Unit:setinitWuLiHuDunXue( xue )
    self.WuLiHuDunXue = xue
end

function Unit:setWuLiHuDunXue( xue )
    self.WuLiHuDunXue = self.WuLiHuDunXue + xue
    if self.WuLiHuDunXue <= 0 then
        self.WuLiHuDunXue = 0
        local wuLiHuDunNode = self:getChildByName("WuLiHuDun")
        if wuLiHuDunNode then
            wuLiHuDunNode:removeFromParent()
            if self.wuLiHuDunBarImageBg then
                self.wuLiHuDunBarImageBg:setVisible(false)
            end
            if self.loadingWuLiHuDunBar then
                self.loadingWuLiHuDunBar:setVisible(false)
            end
        end
    end
end


function Unit:getSRC( HeroId )
    if self.type == MONSTERTYPE then
        return self.monsterTab.Src
    end

    if self.heroTab.skinInfo and self.heroTab.skinInfo.id and self.heroTab.skinInfo.id > 1 then
        local skinId = gameUtil.getHeroTab(HeroId).SkinId[self.heroTab.skinInfo.id]
        return skin[skinId].Src
    else
        return gameUtil.getHeroTab(HeroId).Src
    end
end

function Unit:getHeroId( ... )
    return self.HeroId
end

function Unit:getHeroName( ... )
    if self.type == MONSTERTYPE then
        return self.monsterTab.Name
    end
    local Name = gameUtil.getHeroTab(self:getHeroId()).Name

    return Name
end

function Unit:getHeroSkillsId( ... )
    if self.type == MONSTERTYPE then
        return self.monsterTab.Skills[1]
    end
    local SkillsId = gameUtil.getHeroTab(self:getHeroId()).Skills[1]

    return SkillsId
end

function Unit:getHeroPuGongId( ... )
    if self.type == MONSTERTYPE then
        return self.monsterTab.AttackAction
    end
    local PuGongId = gameUtil.getHeroTab(self:getHeroId()).AttackAction

    return PuGongId
end

function Unit:getCurSkillId( TgType,heroid  )
    print("getCurSkillId    heroid         "..heroid)

    local TgType =  game.skillBtnTab[heroid].can
    if TgType then
        id = self:getHeroSkillsId()
        game.skillBtnTab[heroid].can = false
    else
        id = self:getHeroPuGongId()
    end



    return id


    -- local id  = ""
    -- if TgType  then
    --     id = self:getHeroSkillsId()
    --     self.actTimes = self.actTimes - 1
    -- -- elseif self.TriggerType == (- MM.ETriggerType.TrXianshou) or
    -- --     self.TriggerType == (- MM.ETriggerType.TrFansha) or
    -- --        self.TriggerType == (- MM.ETriggerType.TrQiangrentou)   then
    -- --     id = self:getHeroPuGongId()
    -- else
    --     ccfightLog("当前时间当前时间当前时间 "..time)
    --     ccfightLog("沉默时间沉默时间沉默时间 "..self:getSilenceTime())
    --     local sid = self:getHeroSkillsId()
    --     local skillTab = gameUtil.getHeroSkillTab( sid )
    --     local gl = 10 - skillTab.AckProbability*10

    --     local r = math.random(1,10)
    --     if time <= self:getSilenceTime() then
    --         r = -1
    --     end
    --     if r > gl and self.actTimes > 0 then
    --         id = self:getHeroSkillsId()
    --         self.actTimes = self.actTimes - 1
    --     else
    --         id = self:getHeroPuGongId()
    --     end
    -- end

    -- --设置当前技能类型
    -- self.effectType = gameUtil.getHeroSkillTab( id ).Target

    -- return id
end

function Unit:getHeroSkillsEx( heroid )
    ccfightLog("hero id : ".. heroid)
    if self.type == MONSTERTYPE then
        return {}
    end
    return gameUtil.getHeroTab( heroid ).SkillsEx
end

function Unit:getSkillsEx()
    return self.HeroSkillsEx
end

-- todo
function Unit:getInitialBlood( ... )
    local hpNum = 0

    if self.GuaiWu == 1 and self.nnffInfo then
        hpNum = self.nnffInfo.blood or 5000
    elseif self.type == MONSTERTYPE then
        hpNum = self.monsterTab.HP
    else
        hpNum = gameUtil.hpMBAck( { heroid = self.heroTab.id, lv = self.heroTab.lv, xinlv = self.heroTab.xinlv,  jinlv = self.heroTab.jinlv, eqTab = self.heroTab.eqTab, preciousInfo = self.heroTab.preciousInfo, skinInfo = self.heroTab.skinInfo} )
        --替补修正，抢夺战力修正
        local myplayerHero = self.fightParam.myplayerHero
        local diplayerHero = self.fightParam.diplayerHero
        local myPkValue = self.fightParam.myPkValue
        local diPkValue = self.fightParam.diPkValue

        local heroTab = nil
        local pkValue = nil
        if self.campType == CAMP_A_TYPE then
            heroTab = myplayerHero
            pkValue =  myPkValue
        else
            heroTab = diplayerHero
            pkValue =  diPkValue
        end

        local allHeroTiBuBeiLvXiShu = gameUtil.allHeroTiBuBeiLvXiShu( heroTab )


        hpNum = gameUtil.HpTBXZ( hpNum, allHeroTiBuBeiLvXiShu, pkValue )


        local skillsExTab = self.HeroSkillsEx
        --todo
        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            hpNum = hpNum + self:BPLife( skillsExTab[i], SkillLv )
        end

        

        --添加光环血量
        local gh_bp_life = self:GH_Add( MM.EPassiveProperty.BP_Life).gh_bp_life
        hpNum = hpNum + gh_bp_life

        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            hpNum = hpNum * (1 + self:BPLifePre( skillsExTab[i], SkillLv )) 
        end

        --添加光环百分比加血
        local gh_bp_lifepre = self:GH_Add( MM.EPassiveProperty.BP_LifePre).gh_bp_lifepre
        hpNum = hpNum * (1 + gh_bp_lifepre) 


        --修正生命值 = 正常最终生命值 *(1 + X * 当前祝福次数）
        --乱斗加成
        if self.fightType == 1 then 
            local zhufuTimes = self.meleeTab.zhufuTimes
            local X = self.meleeTab.X
            hpNum = hpNum * (1 + zhufuTimes * X) 
        end


    end

    return math.floor(hpNum)
end

function Unit:GH_Add(PassivePropertytType)
    local myplayerHero = {}
    for k,v in pairs(self.fightParam.myplayerHero) do
        for i=1,#self.fightParam.unitTA do
            if v.id == self.fightParam.unitTA[i] then
                table.insert(myplayerHero, v)
            end
        end
    end

    local myZhuplayerHero = {}
    for k,v in pairs(self.fightParam.myplayerHero) do
        if self.fightParam.zhuZhenA and #self.fightParam.zhuZhenA > 0 then
            -- print(" GH_Add 11111111111111111111111  "..#self.fightParam.zhuZhenA)
            for i=1,#self.fightParam.zhuZhenA do
                -- print(" GH_Add 11111111111111111111111 "..self.fightParam.zhuZhenA[i])
                if v.id == self.fightParam.zhuZhenA[i] then
                    table.insert(myZhuplayerHero, v)
                end
            end
        end
    end

    local diplayerHero = {}
    for k,v in pairs(self.fightParam.diplayerHero) do
        for i=1,#self.fightParam.unitTB do
            if v.id == self.fightParam.unitTB[i] then
                table.insert(diplayerHero, v)
            end
        end
    end

    local diZhuplayerHero = {}
    for k,v in pairs(self.fightParam.diplayerHero) do
        if self.fightParam.zhuZhenB and #self.fightParam.zhuZhenB > 0 then
            for i=1,#self.fightParam.zhuZhenB do
                if v.id == self.fightParam.zhuZhenB[i] then
                    table.insert(diZhuplayerHero, v)
                end
            end
        end
    end

    -- local myplayerHero = self.fightParam.myplayerHero
    -- local diplayerHero = self.fightParam.diplayerHero
    local curMyHero = nil
    local curDiHero = nil
    local curMyUnit = nil
    local curDiUnit = nil
    local curMyZhu = nil
    local curDiZhu = nil
    if self.campType == CAMP_A_TYPE then--左边
        curMyHero = myplayerHero
        curDiHero = diplayerHero
        curMyUnit = self.fight.UnitA
        curDiUnit = self.fight.UnitB
        curMyZhu = myZhuplayerHero
        curDiZhu = diZhuplayerHero

    else--右边
        curMyHero = diplayerHero
        curDiHero = myplayerHero
        curMyUnit = self.fight.UnitB
        curDiUnit = self.fight.UnitA
        curMyZhu = diZhuplayerHero
        curDiZhu = myZhuplayerHero
    end

    local t = {}
    t.gh_bp_life = 0
    t.gh_bp_lifepre = 0
    t.gh_BP_Attack = 0
    t.gh_BP_AttackPre = 0
    t.gh_BP_Crit = 0
    t.gh_BP_Speed = 0
    t.gh_BP_SpeedPre = 0
    t.gh_BP_Armor = 0
    t.gh_BP_DADPre = 0
    t.gh_BP_MA = 0
    t.gh_BP_DAPPre = 0
    t.gh_BP_ArmorP = 0
    t.gh_BP_MAP = 0
    t.gh_BP_ADParry = 0
    t.gh_BP_APParry = 0
    t.gh_BP_ExemptAD = 0
    t.gh_BP_ExemptAP = 0
    t.gh_BP_ADRebound = 0
    t.gh_BP_APRebound = 0
    t.gh_BP_ADxixue = 0
    t.gh_BP_IgnoreAD = 0
    t.gh_BP_IgnoreAP = 0
    t.GH_BP_SkillPre = 0
    t.gh_BP_ADDeep = 0
    t.gh_BP_APDeep = 0

    -- 计算光环固定加血

    local function jisuan( hero,uint, EPTargetType,isZhu)
        local isYingXiang = false
        for k,v in pairs(hero) do
            local heroid = v.id
            local isLife = true
            for k,v in pairs(uint) do
                if v:getHeroId() == heroid then
                    if v:getCurBlood() and v:getCurBlood() <= 0 then
                        isLife = false
                    end
                end
            end

            if isLife then
                local skillsExTab = gameUtil.getHeroTab( heroid ).SkillsEx

                local CardSex = 0
                if self.type == MONSTERTYPE then
                    local monsterTab = INITLUA:getMonsterResById( self:getHeroId() )
                    CardSex = monsterTab.CardSex
                else
                    CardSex = gameUtil.getHeroTab( self:getHeroId() ).CardSex
                end

                if skillsExTab then
                    for i=1,#skillsExTab do
                        local SkillLv = gameUtil.getHeroSkillLv( heroid, skillsExTab[i],  hero)
                        local xinlv = v.xinlv
                        local xinADD = 1
                        if isZhu then
                            xinADD = xinADD * (1 + xinlv)
                        end
                        local curskillsExTab = INITLUA:getPassiveResById( skillsExTab[i] )
                        local isZuoYong = self:IsZuoYong( curskillsExTab.PTargetType,  self.index, CardSex)
                        if curskillsExTab.PTarget == EPTargetType and isZuoYong == true then
                            isYingXiang = true
                            if tonumber(curskillsExTab.PassiveProperty) == tonumber(PassivePropertytType) then
                                if tonumber(MM.EPassiveProperty.BP_Life) == tonumber(PassivePropertytType) then
                                    t.gh_bp_life = t.gh_bp_life + self:GH_BPLife( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_LifePre) == tonumber(PassivePropertytType) then
                                    t.gh_bp_lifepre = t.gh_bp_lifepre + self:GH_BPLifePre( skillsExTab[i],SkillLv ) *xinADD
                                    
                                elseif tonumber(MM.EPassiveProperty.BP_Attack) == tonumber(PassivePropertytType) then
                                    t.gh_BP_Attack = t.gh_BP_Attack + self:GH_BPAttack( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_AttackPre) == tonumber(PassivePropertytType) then
                                    t.gh_BP_AttackPre = t.gh_BP_AttackPre + self:GH_BPAttackPre( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_Crit) == tonumber(PassivePropertytType) then
                                    t.gh_BP_Crit = t.gh_BP_Crit + self:GH_BPCrit( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_Speed) == tonumber(PassivePropertytType) then
                                    t.gh_BP_Speed = t.gh_BP_Speed + self:GH_BP_Speed( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_SpeedPre) == tonumber(PassivePropertytType) then
                                    t.gh_BP_SpeedPre = t.gh_BP_SpeedPre + self:GH_BP_SpeedPre( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_Armor) == tonumber(PassivePropertytType) then
                                    t.gh_BP_Armor = t.gh_BP_Armor + self:GH_BP_Armor( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_DADPre) == tonumber(PassivePropertytType) then
                                    t.gh_BP_DADPre = t.gh_BP_DADPre + self:GH_BP_DADPre( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_MA) == tonumber(PassivePropertytType) then
                                    t.gh_BP_MA = t.gh_BP_MA + self:GH_BP_MA( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_DAPPre) == tonumber(PassivePropertytType) then
                                    t.gh_BP_DAPPre = t.gh_BP_DAPPre + self:GH_BP_DAPPre( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_ArmorP) == tonumber(PassivePropertytType) then
                                    t.gh_BP_ArmorP = t.gh_BP_ArmorP + self:GH_BP_ArmorP( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_MAP) == tonumber(PassivePropertytType) then
                                    t.gh_BP_MAP = t.gh_BP_MAP + self:GH_BP_MAP( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_ADParry) == tonumber(PassivePropertytType) then
                                    t.gh_BP_ADParry = t.gh_BP_ADParry + self:GH_BP_ADParry( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_APParry) == tonumber(PassivePropertytType) then
                                    t.gh_BP_APParry = t.gh_BP_APParry + self:GH_BP_APParry( skillsExTab[i],SkillLv ) *xinADD

                                elseif tonumber(MM.EPassiveProperty.BP_ExemptAD) == tonumber(PassivePropertytType) then
                                    t.gh_BP_ExemptAD = t.gh_BP_ExemptAD + self:GH_BP_ExemptAD( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_ExemptAP) == tonumber(PassivePropertytType) then
                                    t.gh_BP_ExemptAP = t.gh_BP_ExemptAP + self:GH_BP_ExemptAP( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_ADRebound) == tonumber(PassivePropertytType) then
                                    t.gh_BP_ADRebound = t.gh_BP_ADRebound + self:GH_BP_ADRebound( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_APRebound) == tonumber(PassivePropertytType) then
                                    t.gh_BP_APRebound = t.gh_BP_APRebound + self:GH_BP_APRebound( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_ADxixue) == tonumber(PassivePropertytType) then
                                    t.gh_BP_ADxixue = t.gh_BP_ADxixue + self:GH_BP_ADxixue( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_IgnoreAD) == tonumber(PassivePropertytType) then
                                    t.gh_BP_IgnoreAD = t.gh_BP_IgnoreAD + self:GH_BP_IgnoreAD( skillsExTab[i],SkillLv ) *xinADD

                                elseif tonumber(MM.EPassiveProperty.BP_IgnoreAP) == tonumber(PassivePropertytType) then
                                    t.gh_BP_IgnoreAP = t.gh_BP_IgnoreAP + self:GH_BP_IgnoreAP( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_SkillPre) == tonumber(PassivePropertytType) then
                                    --技能伤害
                                    -- t.GH_BP_SkillPre = t.GH_BP_SkillPre + self:GH_BP_SkillPre( skillsExTab[i],SkillLv )
                                elseif tonumber(MM.EPassiveProperty.BP_ADDeep) == tonumber(PassivePropertytType) then
                                    t.gh_BP_ADDeep = t.gh_BP_ADDeep + self:GH_BP_ADDeep( skillsExTab[i],SkillLv ) *xinADD
                                elseif tonumber(MM.EPassiveProperty.BP_APDeep) == tonumber(PassivePropertytType) then
                                    t.gh_BP_APDeep = t.gh_BP_APDeep + self:GH_BP_APDeep( skillsExTab[i],SkillLv ) *xinADD
                                    

                                    -- ccfightLog("光环 护甲 ----------------------------------------   skillsExTab[i] "..skillsExTab[i])
                                    -- ccfightLog("光环 护甲 ----------------------------------------   SkillLv "..SkillLv)
                                    -- ccfightLog("光环 护甲 ----------------------------------------   t.gh_BP_ArmorP "..t.gh_BP_ArmorP)
                                end
                            end
                                --todo
                        end
                    end
                end
            end
        end

    end
    jisuan( curMyHero, curMyUnit, MM.EPTarget.PFriend)
    jisuan( curDiHero, curDiUnit, MM.EPTarget.PEnemy)

    jisuan( curMyZhu, curMyUnit, MM.EPTarget.PFriend, true)
    jisuan( curDiZhu, curDiUnit, MM.EPTarget.PEnemy, true)
        

    -- ccfightLog("光环 血 ----------------------------------------   t.gh_bp_life "..t.gh_bp_life)
    -- ccfightLog("光环 比例血 ----------------------------------------   t.gh_bp_lifepre "..t.gh_bp_lifepre)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_Attack "..t.gh_BP_Attack)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_AttackPre "..t.gh_BP_AttackPre)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_Crit "..t.gh_BP_Crit)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_Speed "..t.gh_BP_Speed)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_SpeedPre "..t.gh_BP_SpeedPre)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_Armor "..t.gh_BP_Armor)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_DADPre "..t.gh_BP_DADPre)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_MA "..t.gh_BP_MA)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_DAPPre "..t.gh_BP_DAPPre)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_ArmorP "..t.gh_BP_ArmorP)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_MAP "..t.gh_BP_MAP)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_ADParry "..t.gh_BP_ADParry)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_APParry "..t.gh_BP_APParry)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_ExemptAD "..t.gh_BP_ExemptAD)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_ExemptAP "..t.gh_BP_ExemptAP)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_ADRebound "..t.gh_BP_ADRebound)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_APRebound "..t.gh_BP_APRebound)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_ADxixue "..t.gh_BP_ADxixue)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_IgnoreAD "..t.gh_BP_IgnoreAD)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_IgnoreAP "..t.gh_BP_IgnoreAP)
    -- ccfightLog("光环  ----------------------------------------   t.GH_BP_SkillPre "..t.GH_BP_SkillPre)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_ADDeep "..t.gh_BP_ADDeep)
    -- ccfightLog("光环  ----------------------------------------   t.gh_BP_APDeep "..t.gh_BP_APDeep)

    return t
end

function Unit:GH_BP_ADDeep( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADDeep then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_APDeep( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_APDeep then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_IgnoreAP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_IgnoreAP then
        if SkillLv and SkillLv > 0 then
            return 1
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_IgnoreAD( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_IgnoreAD then
        if SkillLv and SkillLv > 0 then
            return 1
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_ADxixue( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADxixue then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_ADRebound( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADRebound then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_APRebound( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_APRebound then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_ExemptAD( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ExemptAD then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_ExemptAP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ExemptAP then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_APParry( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_APParry then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_ADParry( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ADParry then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_MAP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_MAP then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_ArmorP( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_ArmorP then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_DAPPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_DAPPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_MA( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_MA then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_DADPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_DADPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_Armor( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Armor then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_SpeedPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_SpeedPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BP_Speed( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Speed then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BPCrit( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Crit then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BPAttackPre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_AttackPre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BPAttack( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Attack then
        if SkillLv and SkillLv > 0 then
            return math.ceil(tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1))
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:IsZuoYong( PTargetType,  index, CardSex)
    local isZuoYong = false

                        
    if PTargetType ==  MM.EPTargetType.Pall then  
        isZuoYong = true  
    elseif PTargetType ==  MM.EPTargetType.Pqian then
        if index == 1 or index == 2 then
            isZuoYong = true  
        end
    elseif PTargetType ==  MM.EPTargetType.Phou    then   
        if index == 1 or index == 2 then
        else
            isZuoYong = true  
        end
    elseif PTargetType ==  MM.EPTargetType.Pshang  then
       if index == 1 or index == 3 then
            isZuoYong = true  
        end
    elseif PTargetType ==  MM.EPTargetType.Pzhong  then
        if index == 1 or index == 2 or index == 5 then
            isZuoYong = true  
        end   
    elseif PTargetType ==  MM.EPTargetType.Pxia    then   
        if index == 2 or index == 4 then
            isZuoYong = true  
        end
    elseif PTargetType ==  MM.EPTargetType.Pboy    then  
        if CardSex == MM.ECardSex.Boy then
            isZuoYong = true
        end
    elseif PTargetType ==  MM.EPTargetType.Pgirl   then   
        if CardSex == MM.ECardSex.Girl then
            isZuoYong = true
        end
    elseif PTargetType ==  MM.EPTargetType.Pbeast  then   
        if CardSex == MM.ECardSex.Beast then
            isZuoYong = true
        end
    else

    end

    return isZuoYong
end

function Unit:GH_BPLifePre( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_LifePre then
        if SkillLv and SkillLv > 0 then
            return tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1)
        else
            return 0
        end
    else
        return 0 
    end
end

function Unit:GH_BPLife( SkillId,SkillLv )
    local tab = INITLUA:getPassiveResById( SkillId )
    local t = tab["PassiveProperty"]
    if t == MM.EPassiveProperty.BP_Life then
        if SkillLv and SkillLv > 0 then
            return math.ceil(tab["BPNum"] + tab["BPIncrement"] * (SkillLv - 1))
        else
            return 0
        end
    else
        return 0 
    end
end

-- todo
function Unit:getInitialSpeed( ... )
    local speed = 0
    if self.type == MONSTERTYPE then
        speed =  self.monsterTab.Speed
    else
        speed = gameUtil.speedMBAck( { heroid = self.heroTab.id, lv = self.heroTab.lv, xinlv = self.heroTab.xinlv,  jinlv = self.heroTab.jinlv, eqTab = self.heroTab.eqTab, preciousInfo = self.heroTab.preciousInfo, skinInfo = self.heroTab.skinInfo} )
        
        local skillsExTab = self.HeroSkillsEx
        --todo
        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            speed = speed + self:BPSpeed( skillsExTab[i], SkillLv )
        end

        for i=1,#skillsExTab do
            local SkillLv = gameUtil.getHeroSkillLv( self.HeroId, skillsExTab[i] )
            speed = speed * (1 + self:BPSpeedPre( skillsExTab[i], SkillLv )) 
        end

        
    end

    return speed
end

function Unit:clear( ... )
    self:stopAllActions()
    self:removeAllChildren()

    self.loadingHuJiaBar = nil
    self.loadingWuLiHuDunBar = nil
    self.HuJiaTime = 0
    self.HuJiaXue = 0
    self.initHuJiaXue = 0

    self.WuLiHuDunTime = 0
    self.WuLiHuDunXue = 0
    self.initWuLiHuDunXue = 0
end

function Unit:ReInitValue()
    self.curBlood = self.initialBlood
    self.binDongTime = 0
    self.silenceTime = 0
    self.xuanYunTime = 0
    self.yangTime = 0
    self.jihhuoTime = 0

    self.HuJiaTime = 0
    self.HuJiaXue = 0
    self.initHuJiaXue = 0

    self.WuLiHuDunTime = 0
    self.WuLiHuDunXue = 0
    self.initWuLiHuDunXue = 0
end

function Unit:getUnitid( ... )
    return self.unitid
end

function Unit:playSkillTongYongTeXiao( ... )
    local str = "res/Effect/yingxiong/gongyong/t_sf/t_sf"
    local shoujiNode = gameUtil.createSkeletonAnimation(str..".json", str..".atlas",1)
    self:addChild(shoujiNode)
    shoujiNode:setAnimation(0, "cu", false)
    shoujiNode:setLocalZOrder(-10)
    shoujiNode:setName("TongYongTeXiao")
    shoujiNode:setScale(0.25)
    local function ackPlayBack()
        self.fScene:getChildByName("Scene"):getChildByName("Panel_heibg"):setVisible(false)
        shoujiNode:setVisible(false)
    end
    local action = cc.Sequence:create(
                cc.DelayTime:create(0.67),
                cc.CallFunc:create(ackPlayBack)
            )
    shoujiNode:runAction(action)    

    self.fScene:getChildByName("Scene"):getChildByName("Panel_heibg"):setVisible(true)
    self.fScene:getChildByName("Scene"):getChildByName("Panel_heibg"):setTouchEnabled(false)
end

function Unit:playDieTeXiao( time )
    local str = "res/Effect/yingxiong/gongyong/t_sw/t_sw"
    local DieNode = gameUtil.createSkeletonAnimation(str..".json", str..".atlas",1)
    self:addChild(DieNode)
    DieNode:setAnimation(0, "mb", false)

    gameUtil.playEffect("res/sounds/effect/all/t_sw_start",false)

    --DieNode:setLocalZOrder(-10)
    DieNode:setName("DieTeXiao")
    local function ackPlayBack()
        DieNode:setVisible(false)
        self.barImageBg:setVisible(false)
        self.loadingBar:setVisible(false)
    end
    local action = cc.Sequence:create(
                cc.DelayTime:create(0.67),
                cc.CallFunc:create(ackPlayBack)
            )
    DieNode:runAction(action)    

    if self.fightType == 1 then 
        if self.campType == CAMP_B_TYPE then
            self:sendReward(time)
        end
    else
        if self.campType == CAMP_B_TYPE then
            local uiJinbi = self.fight.fScene.scene:getChildByName("Image_jinbi")
            self:sendReward(time)
            for i=1,math.random(5,6) do
                local jibiNode = cc.Node:create()
                self:addChild(jibiNode)

                local jinbiImageView = ccui.ImageView:create()
                jinbiImageView:loadTexture("res/UI/pc_jinbi.png")
                jibiNode:addChild(jinbiImageView)
                jinbiImageView:setName("jinbi")
                jinbiImageView:setScale(0.8)    
                jinbiImageView:setPosition(0,50)

                self:jinbiMove(jinbiImageView, uiJinbi, jibiNode)

                

            end

            -- local uiExp = self.fight.fScene.scene:getChildByName("Image_jingyan")
            -- local expNode = cc.Node:create()
            -- self:addChild(expNode)
            -- expNode:setPosition(0,0)
            -- self:expMove(expNode, uiExp)

            -- gameUtil.addArmatureFile("res/Effect/uiEffect/explizi/explizi.ExportJson")
            -- local particle = cc.ParticleSystemQuad:create("res/Effect/uiEffect/explizi/explizi.plist")
            -- expNode:addChild(particle, -1)
            -- particle:setPosition(cc.p(0, 0))
            -- particle:setAutoRemoveOnFinish(true)
            -- particle:setDuration(1.2)
        end
    end

end

function Unit:jinbiMove( jinbi, uiJinbi , jibiNode)
    local function fly( ... )
        local function flyBack( ... )
            local btnSize = uiJinbi:getSize()
        
            local anime = gameUtil.createSkeAnmion( {name = "jb",scale = 1} )
            anime:setAnimation(0, "stand", false)
            anime:setAnchorPoint(cc.p(0.5,0.5))
            anime:setPosition(cc.p(30, 40))

            uiJinbi:addChild(anime,10)

            performWithDelay(self,function( ... )
                anime:removeFromParent()
            end, 0.4)
            
            gameUtil.playUIEffect( "Gold_Get" )

            jinbi:removeFromParent()
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

        gameUtil.addArmatureFile("res/Effect/uiEffect/lizi/lizi.ExportJson")
        local particle = cc.ParticleSystemQuad:create("res/Effect/uiEffect/lizi/lizi.plist")
        jibiNode:addChild(particle, -1)
        particle:setPosition(cc.p(jinbi:getSize().width*0.5, jinbi:getSize().height*0.5))
        particle:setAutoRemoveOnFinish(true)
        particle:setDuration(1.2)

        jibiNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(10,20) * 0.01),bezierForward, cc.CallFunc:create(flyBack) ))
        
        gameUtil.playUIEffect( "Gold_Birth" )
    end

    local mx = math.random(-80,80)
    local my = math.random(-80,-60)
    local bezier = {
        cc.p(0, 0),
        cc.p(mx * 0.5, math.random(160,180)),
        cc.p(mx, my),
    }
    local bezierForward = cc.BezierBy:create(math.random(40,70) * 0.01, bezier)

    jibiNode:setVisible(false)

    jibiNode:runAction(cc.Sequence:create(
                cc.CallFunc:create(function( ... )
                    jibiNode:setVisible(true)
                end),
                bezierForward, 
                cc.MoveBy:create(0.1,cc.p(0,20)),
                cc.MoveBy:create(0.1,cc.p(0,-20)),
                cc.MoveBy:create(0.05,cc.p(0,10)),
                cc.MoveBy:create(0.05,cc.p(0,-10)), 
                cc.CallFunc:create(fly)))


end

function Unit:expMove( expNode, uiExp )
    local function fly( ... )
        ccfightLog("3333333333333333333333333333")
        local function flyBack( ... )
            --gameUtil.removeArmatureFile("res/Effect/uiEffect/explizi/explizi.ExportJson")
            --expNode:removeFromParent()

            gameUtil.playUIEffect( "Exppoor_Get" )
        end
        local x, y = expNode:getPosition()
        local p0 = expNode:getParent():convertToWorldSpace(cc.p(x, y))
        local x, y = uiExp:getPosition()
        local p1 = uiExp:getParent():convertToWorldSpace(cc.p(x, y))
        local mx = p1.x - p0.x
        local my = p1.y - p0.y
        local bezier = {
            cc.p(0, 0),
            cc.p(mx + math.random(400,450), math.random(-200,0)),
            cc.p(mx, my),
        }
        local bezierForward = cc.BezierBy:create(0.8, bezier)

        

        expNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(10,20) * 0.01),bezierForward, cc.CallFunc:create(flyBack)))
    end

    

    -- ccfightLog("111111111111111111111111111")
    -- local mx = math.random(-80,80)
    -- local my = math.random(-80,-60)
    -- local bezier = {
    --     cc.p(0, 0),
    --     cc.p(mx * 0.5, math.random(160,180)),
    --     cc.p(mx, my),
    -- }
    -- local bezierForward = cc.BezierBy:create(math.random(40,70) * 0.01, bezier)
    -- ccfightLog("2222222222222222222222222")

    fly()
    -- expNode:runAction(cc.Sequence:create(
    --             bezierForward, 
    --             cc.MoveBy:create(0.1,cc.p(0,20)),
    --             cc.MoveBy:create(0.1,cc.p(0,-20)),
    --             cc.MoveBy:create(0.05,cc.p(0,10)),
    --             cc.MoveBy:create(0.05,cc.p(0,-10)), 
    --             cc.CallFunc:create(fly)))


end

function Unit:setBuffBegin( tab )
    ccfightLog("当前时间当前时间当前时间 "..tab.time)
    ccfightLog("冰冻时间冰冻时间冰冻时间 "..self:getSilenceTime())
    if tab.time > self:getBinDongTime() or math.ceil(self:getCurBlood()) < 0 then
        local binDongNode = self:getChildByName("BinDong")
        if binDongNode then
            binDongNode:removeFromParent()
        end
    end

    if tab.time > self:getSilenceTime() or math.ceil(self:getCurBlood()) < 0 then
        local silenceNode = self:getChildByName("Silence")
        if silenceNode then
            silenceNode:removeFromParent()
        end
    end

    if tab.time > self:getXuanYunTime() or math.ceil(self:getCurBlood()) < 0 then
        local xuanYunNode = self:getChildByName("XuanYun")
        if xuanYunNode then
            xuanYunNode:removeFromParent()
        end
    end

    if tab.time > self:getYangTime() or math.ceil(self:getCurBlood()) < 0 then
        local YangNode = self:getChildByName("Yang")
        if YangNode then
            YangNode:removeFromParent()
            self:getSkeletonNode():setVisible(true)
        end
        
    end

    if tab.time > self:getJiHuoTime() or math.ceil(self:getCurBlood()) < 0 then
        local jiHuoNode = self:getChildByName("JiHuo")
        if jiHuoNode then
            jiHuoNode:removeFromParent()
        end
    end

    if tab.time > self:getHuJiaTime() or math.ceil(self:getCurBlood()) < 0 then
        local huJiaNode = self:getChildByName("HuJia")
        if huJiaNode then
            huJiaNode:removeFromParent()
            if self.hujiaBarImageBg then
                self.hujiaBarImageBg:setVisible(false)
            end
            if self.loadingHuJiaBar then
                self.loadingHuJiaBar:setVisible(false)
            end
            self.HuJiaXue = 0

            
        end
    end

    if tab.time > self:getWuLiHuDunTime() or math.ceil(self:getCurBlood()) < 0 then
        local wuLiHuDunNode = self:getChildByName("WuLiHuDun")
        if wuLiHuDunNode then
            wuLiHuDunNode:removeFromParent()
            if self.wuLiHuDunBarImageBg then
                self.wuLiHuDunBarImageBg:setVisible(false)
            end
            if self.loadingWuLiHuDunBar then
                self.loadingWuLiHuDunBar:setVisible(false)
            end

            self.WuLiHuDunXue = 0
        end
    end

    local TongYongTeXiaoNode = self:getChildByName("TongYongTeXiao")
    if TongYongTeXiaoNode then
        TongYongTeXiaoNode:removeFromParent()
    end

end


function Unit:setDead( ... )
    ccfightLog("删除 buf")
    local binDongNode = self:getChildByName("BinDong")
    if binDongNode then
        binDongNode:removeFromParent()
    end

    local silenceNode = self:getChildByName("Silence")
    if silenceNode then
        silenceNode:removeFromParent()
    end

    local xuanYunNode = self:getChildByName("XuanYun")
    if xuanYunNode then
        xuanYunNode:removeFromParent()
    end

    local yinying = self:getChildByName("yinying")
    if yinying then
        yinying:removeFromParent()
    end

    local Yang = self:getChildByName("Yang")
    if Yang then
        Yang:removeFromParent()
    end

    local jiHuoNode = self:getChildByName("JiHuo")
    if jiHuoNode then
        jiHuoNode:removeFromParent()
    end

    local huJiaNode = self:getChildByName("HuJia")
    if huJiaNode then
        huJiaNode:removeFromParent()
        if self.hujiaBarImageBg then
            self.hujiaBarImageBg:setVisible(false)
        end
        if self.loadingHuJiaBar then
            self.loadingHuJiaBar:setVisible(false)
        end
    end

    local wuLiHuDunNode = self:getChildByName("WuLiHuDun")
    if wuLiHuDunNode then
        wuLiHuDunNode:removeFromParent()
        if self.wuLiHuDunBarImageBg then
            self.wuLiHuDunBarImageBg:setVisible(false)
        end
        if self.loadingWuLiHuDunBar then
            self.loadingWuLiHuDunBar:setVisible(false)
        end
    end

    self:getSkeletonNode():setVisible(false)

    

end

function Unit:PlayHurt(param)
    local hurt  = param.hurt
    local shoujiPath = param.shoujiPath
    local skillId = param.skillId
    local isSilence = param.isSilence
    local isBinDong = param.isBinDong
    local speedScale = param.speed_scale
    local time = param.time
    local TgType = param.TgType
    local isXuanYun = param.isXuanYun
    local isYang = param.isYang
    local isJihuo = param.isJihuo
    local HuJia = param.HuJia
    local WuLiHuDun = param.WuLiHuDun
    local DamageStyle = param.DamageStyle
    local wuliCrit = param.wuliCrit
    local reburthNum = param.reburthNum
    local wumian = param.wumian
    local momian = param.momian
    local hujiaZhi = param.hujiaZhi
    local wuLiHuDunZhi = param.wuLiHuDunZhi
    if WuLiHuDun then
    else
    end

    if self:isDead() then
        --self.fight:hurtEndCount()
        return
    end

    if hurt < 0 then
        local function hurtBack()
            self:getSkeletonNode():unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            
            if self:isDead() then
                
                self:setDead()
            else
                self:getSkeletonNode():setAnimation(0, "stand", true)
                local skillTab = gameUtil.getHeroSkillTab( skillId )
                --是否沉默
                if isSilence then
                    print("ttttttttttxxxxxxxxxxxx           是否沉默")
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local silenceTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addSilenceTexiao(res)
                    self:setSilenceTime(time + silenceTime)
                end

                ----是否冰冻
                if isBinDong then
                    print("ttttttttttxxxxxxxxxxxx           是否冰冻")
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local binDongTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addBinDongTexiao(res)
                    self:setBinDongTime(time + binDongTime)
                end
                --是否眩晕
                if isXuanYun then
                    print("ttttttttttxxxxxxxxxxxx           是否眩晕")
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local xuanYunTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addXuanYunTexiao(res)
                    self:setXuanYunTime(time + xuanYunTime)
                end

                --是否变羊
                if isYang then
                    print("ttttttttttxxxxxxxxxxxx           是否变羊")
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local YangTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addYangTexiao(res)
                    self:setYangTime(time + YangTime)
                end

                --是否集火
                if isJihuo then
                    print("ttttttttttxxxxxxxxxxxx           是否集火")
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local jihuoTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addJiHuoTexiao(res)
                    self:setJiHuoTime(time + jihuoTime)
                end

                


            end
            
        end
        ccfightLog("受伤")
        self:getSkeletonNode():setAnimation(0, "hurt", false)
        self:getSkeletonNode():registerSpineEventHandler(hurtBack,sp.EventType.ANIMATION_COMPLETE)
        self:getSkeletonNode():setTimeScale(speedScale)
    else
        --是否护甲
        ccfightLog(" 是否 护甲 "..skillId)
        if HuJia then
            local skillTab = gameUtil.getHeroSkillTab( skillId )
            local res = INITLUA:getBuffByid( skillTab.BUFFID ).texiaoRes
            local HuJiaTime = INITLUA:getBuffByid( skillTab.BUFFID ).chixuhuihe
            ccfightLog(" 是否 护甲 "..res)
            self:addHuJiaTexiao(res)
            self:setHuJiaTime(time + HuJiaTime)
            self.initHuJiaXue = hujiaZhi
            self.HuJiaXue = hujiaZhi 
            -- hurt = 0 --如果是护盾则不加到血条
        end

        if WuLiHuDun then
            local skillTab = gameUtil.getHeroSkillTab( skillId )
            local res = INITLUA:getBuffByid( skillTab.BUFFID ).texiaoRes
            local WuLiHuDunTime = INITLUA:getBuffByid( skillTab.BUFFID ).chixuhuihe
            ccfightLog(" 是否 护盾 "..res)
            self:addWuLiHuDunTexiao(res)
            self:setWuLiHuDunTime(time + WuLiHuDunTime)
            self.initWuLiHuDunXue = wuLiHuDunZhi
            self.WuLiHuDunXue = wuLiHuDunZhi 
            -- hurt = 0 --如果是护盾则不加到血条
        end
    end
    ---飘雪
    if not self:isDead() then
        -- self:setCurBlood(self:getCurBlood() + hurt) 
        self:calculateCurBlood(hurt, DamageStyle)
        if self.loadingHuJiaBar then
            self.loadingHuJiaBar:setPercent(math.ceil(self:getHuJiaXue() / self.initHuJiaXue * 100))
            if self:getHuJiaXue() <= 0 then
                if self.hujiaBarImageBg then
                    self.hujiaBarImageBg:setVisible(false)
                end
                if self.loadingHuJiaBar then
                    self.loadingHuJiaBar:setVisible(false)
                end
            end
        end
        if self.loadingWuLiHuDunBar then
            self.loadingWuLiHuDunBar:setPercent(math.ceil(self:getWuLiHuDunXue() / self.initWuLiHuDunXue * 100))
            if self:getWuLiHuDunXue() <= 0 then
                if self.wuLiHuDunBarImageBg then
                    self.wuLiHuDunBarImageBg:setVisible(false)
                end
                if self.loadingWuLiHuDunBar then
                    self.loadingWuLiHuDunBar:setVisible(false)
                end
            end
        end
    end
    if math.ceil(self:getCurBlood()) <= 0 then
        if reburthNum and reburthNum > 0 then
            self:setCurBlood(reburthNum)

            gameUtil:addTishi( {p = self, s = "重生" , z = 1000,width = 25, height = 50})
        else
            --计算掉落
            self:playDieTeXiao(time)
            
            game:dispatchEvent({name = EventDef.UI_MSG, code = "CountHeroDiedTime", heroId = self.HeroId, camp = self.campType})
        end

        

    else
        self.loadingBar:setPercent(math.ceil(self:getCurBlood() / self.initialBlood * 100))
        self.barImageBg:setVisible(true)
        self.loadingBar:setVisible(true)
        local function showbarBack( ... )
            self.barImageBg:setVisible(false)
            self.loadingBar:setVisible(false)
        end
        self:runAction( cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(showbarBack)))
    end
    ccfightLog("==================================3")
    local fut = "res/font/fnt_02.fnt"
    if DamageStyle == MM.EDamageStyle.Wuli then
        fut = "res/font/fnt_03.fnt"
    elseif DamageStyle == MM.EDamageStyle.Mofa then
        fut = "res/font/fnt_02.fnt"
    elseif DamageStyle == MM.EDamageStyle.Shen then
        fut = "res/font/fnt_02.fnt"
    else
        fut = "res/font/fnt_02.fnt"
    end
    local hurtText = ccui.TextBMFont:create()
    if hurt > 0 then
        hurtText:setFntFile("res/font/fnt_01.fnt")
    elseif hurt < 0 then
        hurtText:setFntFile(fut)
    else
        hurtText:setVisible(false)
    end
    hurtText:setString(math.abs(math.ceil(hurt)))
    --hurtText:setScale(0.5)
    hurtText:setPositionY(self.nodeHeight)
    if TgType or wuliCrit then
        hurtText:setScale(0.6)
    else
        hurtText:setScale(0.5)
    end
    self:addChild(hurtText)
    local function hurtBack( ... )
        hurtText:removeFromParent()
    end
    hurtText:runAction( cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveBy:create(0.3, cc.p(0,50)),cc.CallFunc:create(hurtBack)))

    if wumian and wumian > 0 then
        gameUtil:addTishi( {p = self, s = "物免" , z = 1000,width = 25, height = 50})
    elseif momian and momian > 0 then
        gameUtil:addTishi( {p = self, s = "魔免" , z = 1000,width = 25, height = 50})
    end

    self.fight:setAllBlood()

    ---飘雪

    --播放受击
    ccfightLog("  播放受击  播放受击 1 ")
    if #shoujiPath > 0 then 
        --if 1144271409 == skillId then
            ccfightLog("  播放受击 : "..shoujiPath)
            ccfightLog("  播放技能 : "..skillId)
        --end
        
        local shoujiNode = gameUtil.createSkeletonAnimation(shoujiPath..".json", shoujiPath..".atlas",1)
        self:getSkeletonNode():addChild(shoujiNode)
        shoujiNode:setAnimation(0, "mb", false)
        shoujiNode:setPosition(0,50)
        shoujiNode:setScaleX(-1)
        shoujiNode:setScale(1)


        local function toPlayHurtAction( ... )
            shoujiNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            shoujiNode:setVisible(false)

        end 
        shoujiNode:registerSpineEventHandler(toPlayHurtAction,sp.EventType.ANIMATION_COMPLETE)
    end
    ccfightLog("  播放受击  播放受击 222 ")
    if debug_xue == 1 then
        self.curBloodText:setString(math.ceil(self.curBlood))
    end
end

--先手 反杀 抢人头
function Unit:showSkillIcon( TgType )

    local skillIcon = ccui.ImageView:create()
    if MM.ETriggerType.TrXianshou == TgType then
        skillIcon:loadTexture("res/icon/jiemian/icon_tanxianshou.png")
        print("showSkillIconshowSkillIconshowSkillIconshowSkillIcon      先手")
    elseif MM.ETriggerType.TrFansha == TgType then
        skillIcon:loadTexture("res/icon/jiemian/icon_tanfansha.png")
        print("showSkillIconshowSkillIconshowSkillIconshowSkillIcon      反杀")
    elseif MM.ETriggerType.TrQiangrentou == TgType then
        skillIcon:loadTexture("res/icon/jiemian/icon_tanrentou.png")
        print("showSkillIconshowSkillIconshowSkillIconshowSkillIcon      抢人头")
    end

    self:addChild(skillIcon)
    skillIcon:setPositionY(150)
    local function showbarBack( ... )
        skillIcon:removeFromParent()
    end
    self:runAction( cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(showbarBack)))
    

end

function Unit:setPiaoxue( hurt, shoujiPath, DamageStyle, isZhuJue )
     ---飘雪
     print("setPiaoxue    飘雪     ============================== " .. hurt)

    if isZhuJue then
        local function hurtBack()
            self:getSkeletonNode():unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            self:getSkeletonNode():setAnimation(0, "stand", true)
        end
        print("setPiaoxue    飘雪     ======================hurt======== " .. hurt)
        self:getSkeletonNode():setAnimation(0, "hurt", false)
        self:getSkeletonNode():registerSpineEventHandler(hurtBack,sp.EventType.ANIMATION_COMPLETE)
    end

    if not self:isDead() then
        local b = self:getCurBlood() + hurt
        -- if b <= 0 then
        --     self:setCurBlood(1) 
        -- else
            -- self:setCurBlood(b)
            self:calculateCurBlood(hurt, DamageStyle) 
            if self.loadingHuJiaBar then
                self.loadingHuJiaBar:setPercent(math.ceil(self:getHuJiaXue() / self.initHuJiaXue * 100))
                if self:getHuJiaXue() <= 0 then
                    if self.hujiaBarImageBg then
                        self.hujiaBarImageBg:setVisible(false)
                    end
                    if self.loadingHuJiaBar then
                        self.loadingHuJiaBar:setVisible(false)
                    end
                end
            end
            if self.loadingWuLiHuDunBar then
                self.loadingWuLiHuDunBar:setPercent(math.ceil(self:getWuLiHuDunXue() / self.initWuLiHuDunXue * 100))
                if self:getWuLiHuDunXue() <= 0 then
                    if self.wuLiHuDunBarImageBg then
                        self.wuLiHuDunBarImageBg:setVisible(false)
                    end
                    if self.loadingWuLiHuDunBar then
                        self.loadingWuLiHuDunBar:setVisible(false)
                    end
                end
            end
            if self:getCurBlood() <= 0 then
                self:setCurBlood(1) 
            end
        -- end
    end
    if math.ceil(self:getCurBlood()) <= 0 then
        self.loadingBar:setPercent(0)
    else
        self.loadingBar:setPercent(math.ceil(self:getCurBlood() / self.initialBlood * 100))
    end
    self.barImageBg:setVisible(true)
    self.loadingBar:setVisible(true)
    local function showbarBack( ... )
        self.barImageBg:setVisible(false)
        self.loadingBar:setVisible(false)
    end
    self:runAction( cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(showbarBack)))

    local fut = "res/font/fnt_02.fnt"
    if DamageStyle == MM.EDamageStyle.Wuli then
        fut = "res/font/fnt_03.fnt"
    elseif DamageStyle == MM.EDamageStyle.Mofa then
        fut = "res/font/fnt_02.fnt"
    elseif DamageStyle == MM.EDamageStyle.Shen then
        fut = "res/font/fnt_02.fnt"
    else
        fut = "res/font/fnt_02.fnt"
    end

    local hurtText = ccui.TextBMFont:create()
    if hurt > 0 then
        hurtText:setFntFile("res/font/fnt_01.fnt")
    elseif hurt < 0 then
        hurtText:setFntFile(fut)
    else
        hurtText:setVisible(false)
    end
    hurtText:setString(math.abs(math.ceil(hurt)))
    --hurtText:setScale(0.5)
    hurtText:setPositionY(self.nodeHeight)
    if TgType then
        hurtText:setScale(0.6)
    else
        hurtText:setScale(0.5)
    end
    self:addChild(hurtText)
    local function hurtBack( ... )
        hurtText:removeFromParent()
    end
    hurtText:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05,1.2),cc.ScaleTo:create(0.05,0.6),cc.MoveBy:create(0.3, cc.p(0,50)),cc.CallFunc:create(hurtBack)))

    self.fight:setAllBlood()
    ---飘雪

    --播放受击
    if #shoujiPath > 0 then 
        if 1144271409 == skillId then
        end
        
        local shoujiNode = gameUtil.createSkeletonAnimation(shoujiPath..".json", shoujiPath..".atlas",1)
        self:getSkeletonNode():addChild(shoujiNode)
        shoujiNode:setAnimation(0, "mb", false)
        shoujiNode:setPosition(0,50)
        shoujiNode:setScaleX(-1)
        shoujiNode:setScale(0.5)


        local function toPlayHurtAction( ... )
            shoujiNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            shoujiNode:setVisible(false)

        end 
        shoujiNode:registerSpineEventHandler(toPlayHurtAction,sp.EventType.ANIMATION_COMPLETE)
    end

    if debug_xue == 1 then
        self.curBloodText:setString(math.ceil(self.curBlood))
    end


end

    -- a)死亡单位金币产量 =  (100 + 等级 * 1.2) / 60 * (单位死亡单位时间 * 0.2)
    -- b)死亡单位经验产量 = 7.6 * (单位死亡时间 * 0.2)
function Unit:sendReward( time )

    local addGold = math.ceil((1000 + mm.data.playerinfo.level * 20) / 60 * (time * 0.2/3))
    local addExp = math.ceil(7.6 * (time * 0.2))
    local addExppool = math.ceil(7.6 * (time * 0.2))
    mm.onePlayAddGold = mm.onePlayAddGold + addGold
    mm.onePlayAddExp = mm.onePlayAddExp + addExp
    mm.onePlayaddExppool = mm.onePlayaddExppool + addExppool
    
    if self.fightType == 1 then 
        mm.req("killMelee",{num = 1})
    else

        if time then
            mm.req("killReward",{time = math.ceil(time), userAction = game.userAction})
        else
        end
    end



end

function Unit:addSilenceTexiao( res )
    local node = self:getChildByName("Silence")
    if node then
        return
    end
    local SilenceNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    self:addChild(SilenceNode)
    SilenceNode:setAnimation(0, "cu", true)
    SilenceNode:setName("Silence")
    -- SilenceNode:setPositionY(120)--(self:getSkeletonNode():getBoundingBox().height + 20)
    SilenceNode:setScale(0.5)
    
end

function Unit:addBinDongTexiao( res )
    local node = self:getChildByName("BinDong")
    if node then
        return
    end
    local BinDongNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    self:addChild(BinDongNode, 99)
    BinDongNode:setAnimation(0, "cu", true)
    BinDongNode:setName("BinDong")
    BinDongNode:setScale(0.5)
end

function Unit:addXuanYunTexiao( res )
    local node = self:getChildByName("XuanYun")
    if node then
        return
    end
    local XuanYunNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    self:addChild(XuanYunNode)
    XuanYunNode:setAnimation(0, "cu", true)
    XuanYunNode:setName("XuanYun")
    XuanYunNode:setPositionY(120)--(self:getSkeletonNode():getBoundingBox().height + 20)
    XuanYunNode:setScale(0.5)
end

function Unit:addYangTexiao( res )
    local node = self:getChildByName("Yang")
    if node then
        return
    end
    self:getSkeletonNode():setVisible(false)
    local YangNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    self:addChild(YangNode)
    YangNode:setAnimation(0, "cu", true)
    YangNode:setName("Yang")
    YangNode:setScale(0.5)
    --YangNode:setAnchorPoint(cc.p(0,0))
    --YangNode:setPositionY(42)
end

function Unit:addJiHuoTexiao( res )
    local node = self:getChildByName("JiHuo")
    if node then
        return
    end
    local XuanYunNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    self:addChild(XuanYunNode)
    XuanYunNode:setAnimation(0, "cu", true)
    XuanYunNode:setName("JiHuo")
    XuanYunNode:setPositionY(42)--(self:getSkeletonNode():getBoundingBox().height + 20)
    XuanYunNode:setScale(0.5)
end

function Unit:addHuJiaTexiao( res )
    local node = self:getChildByName("HuJia")
    if node then
        return
    end
    local HuJiaNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    self:addChild(HuJiaNode)
    HuJiaNode:setAnimation(0, "cu", true)
    HuJiaNode:setName("HuJia")
    HuJiaNode:setScale(0.5)
    -- HuJiaNode:setPositionY(42)--(self:getSkeletonNode():getBoundingBox().height + 20)


    --self.initHuJiaXue = 

    local imageView = ccui.ImageView:create()
    imageView:loadTexture("res/UI/jm_xuetiaodi.png")
    self.skeletonNode:addChild(imageView)
    imageView:setPositionY(150 + 20)
    self.hujiaBarImageBg = imageView

    local barRes = "res/UI/jm_xuetiaobai.png"
    local loadingBar = ccui.LoadingBar:create()
    loadingBar:setName("hujiaBar")
    loadingBar:loadTexture(barRes)
    loadingBar:setPercent(100)
    self.skeletonNode:addChild(loadingBar)
    loadingBar:setPositionY(150 + 20)
    loadingBar:setVisible(true)
    self.loadingHuJiaBar = loadingBar
    self.hujiaBarImageBg:setScale(self.loadingHuJiaBar:getContentSize().width/self.hujiaBarImageBg:getContentSize().width, self.loadingHuJiaBar:getContentSize().height/self.hujiaBarImageBg:getContentSize().height)


    

end

function Unit:addWuLiHuDunTexiao( res )
    local node = self:getChildByName("WuLiHuDun")
    if node then
        return
    end
    local WuLiHuDunNode = gameUtil.createSkeletonAnimation(res..".json", res..".atlas",1)
    self:addChild(WuLiHuDunNode)
    WuLiHuDunNode:setAnimation(0, "cu", true)
    WuLiHuDunNode:setName("WuLiHuDun")
    WuLiHuDunNode:setScale(0.5)
    -- WuLiHuDunNode:setPositionY(42)--(self:getSkeletonNode():getBoundingBox().height + 20)


    --self.initWuLiHuDunXue = 

    local imageView = ccui.ImageView:create()
    imageView:loadTexture("res/UI/jm_xuetiaodi.png")
    self.skeletonNode:addChild(imageView)
    imageView:setPositionY(150 + 27)
    self.wuLiHuDunBarImageBg = imageView

    local barRes = "res/UI/jm_xuetiaobai.png"
    local loadingBar = ccui.LoadingBar:create()
    loadingBar:setName("wuLiHuDunBar")
    loadingBar:loadTexture(barRes)
    loadingBar:setPercent(100)
    self.skeletonNode:addChild(loadingBar)
    loadingBar:setPositionY(150 + 27)
    loadingBar:setVisible(true)
    self.loadingWuLiHuDunBar = loadingBar
    self.wuLiHuDunBarImageBg:setScale(self.loadingWuLiHuDunBar:getContentSize().width/self.wuLiHuDunBarImageBg:getContentSize().width, self.loadingWuLiHuDunBar:getContentSize().height/self.wuLiHuDunBarImageBg:getContentSize().height)


    

end


function Unit:getSkeletonNode()
    return self.skeletonNode
end

function Unit:getCurBlood()
    return self.curBlood
end

function Unit:setCurBlood(curBlood)
    ccfightLog(self:getHeroName().." 2015-11-20     ===========================================1111====血变化 前 血      "..self.curBlood)
    ccfightLog(self:getHeroName().." 2015-11-20     =============================================1111=====血变化       "..curBlood)
    if curBlood > self.initialBlood then
        curBlood = self.initialBlood
    end
    self.curBlood = curBlood
    ccfightLog(self:getHeroName().." 2015-11-20     ==============================================1111======血变化 后 血      "..self.curBlood)
end

function Unit:calculateCurBlood(hurt, damageStyle)
    local hujiaXue = self:getHuJiaXue()
    local wuLiHuDunXue = self:getWuLiHuDunXue()
    ccfightLog(self:getHeroName().." 2015-11-20     =====================打前 当前血       "..self.curBlood)
    ccfightLog(self:getHeroName().." 2015-11-20     =====================当前护盾       "..hujiaXue)
    ccfightLog(self:getHeroName().." 2015-11-20     =====================当前物理护盾       "..wuLiHuDunXue)
    local initHurt = hurt
    ccfightLog(self:getHeroName().." 2015-11-20     =====================受到伤害       "..hurt)
    if hurt < 0 then

        if hurt < 0 and wuLiHuDunXue > 0 and damageStyle == MM.EDamageStyle.Wuli then
            ccfightLog(self:getHeroName().." 2015-11-20     =====================物理护盾抵挡       "..(hurt + wuLiHuDunXue))
            self:setWuLiHuDunXue(hurt)
            hurt = hurt + wuLiHuDunXue
        end

        if hurt < 0 and hujiaXue > 0 then
            ccfightLog(self:getHeroName().." 2015-11-20     =====================护盾抵挡       "..(hurt + hujiaXue))
            self:setHuJiaXue(hurt)
            hurt = hurt + hujiaXue
        end

        if hurt < 0 then
            ccfightLog(self:getHeroName().." 2015-11-20     =====================收到真伤害       "..(hurt ))
            self:setCurBlood(self:getCurBlood() + hurt)
        end
    else
        self:setCurBlood(self:getCurBlood() + hurt)
    end

    ccfightLog(self:getHeroName().." 2015-11-20     =====================当前血       "..self.curBlood)

    -- if hurt < 0 and hujiaXue > 0 then
    --     -- ccfightLog(" calculateCurBlood =========================damageStyle= "..damageStyle)
    --     if (hurt + hujiaXue) > 0 then
    --         self:setHuJiaXue(hurt)
    --     else
    --         self:setHuJiaXue(hurt)
    --         self:setCurBlood(self:getCurBlood() + (hurt + hujiaXue))
    --     end
    -- elseif hurt < 0 and wuLiHuDunXue > 0 and damageStyle == MM.EDamageStyle.Wuli then
    --     if (hurt + wuLiHuDunXue) > 0 then
    --         self:setWuLiHuDunXue(hurt)
    --     else
    --         self:setWuLiHuDunXue(hurt)
    --         self:setCurBlood(self:getCurBlood() + (hurt + wuLiHuDunXue))
    --     end
    -- else
    --     self:setCurBlood(self:getCurBlood() + hurt)
    -- end
end

function Unit:isDead()
    if self.curBlood > 0 then
        return false
    else
        return true
    end
end

function Unit:getPos()
    return self.curPos
end

function Unit:setPos(pos)
    self.curPos = pos
end

function Unit:getSpeed()
    local curSpeed = self.curSpeed
    --添加光环血量
    local gh_BP_Speed = self:GH_Add( MM.EPassiveProperty.BP_Speed).gh_BP_Speed
    curSpeed = curSpeed + gh_BP_Speed

    local gh_BP_SpeedPre = self:GH_Add( MM.EPassiveProperty.BP_SpeedPre).gh_BP_SpeedPre
    curSpeed = curSpeed * (1 + gh_BP_SpeedPre) 

    return curSpeed
end

function Unit:getSkillType()
    return 1
end

function Unit:getSkillObject()
    return self.skillObject
end

function Unit:getCampType()
    return self.campType
end

function Unit:getEffectType()
    return self.effectType
end


function Unit:getHero( ... )
    return self.playHero
end

return Unit
