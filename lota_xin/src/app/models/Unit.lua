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
    -- print(" Unit:init  ID ".. self.HeroId)
    -- print(" Unit:init  ID ".. json.encode(param.playHero))
    self.playHero = param.playHero
    self.playPet = param.playHero
    self.pet = self:getPetTab(self.HeroId)
    self.petRes = petTable[self.pet.id]

    self.type = param.playType  -- 3 关卡

    self.GuaiWu = self.fightParam.GuaiWu

    self.zorder = param.zorder

    self.nnffInfo = param.nnffInfo

    self:setLocalZOrder(self.zorder)


    self:initValue(param)


    self.campType = param.campType
    local scale = param.scale
    local scaleX = param.scaleX
    self.index = param.index

    local delay = {0,0.5,0.8,1.0,1.1}

    local function addHero(  )
        local res = "res/spine/bossRes/bird_01/bird_01"
        if self.campType == CAMP_A_TYPE then
            res = self:getSRC( self.HeroId )
        end


        self.skeletonNode = gameUtil.createSkeletonAnimationForUnit(res..".json", res..".atlas",1)
        self:addChild(self.skeletonNode)
        self.skeletonNode:setPosition(cc.p(0,0))
        
  
        if scaleX then 
            self.skeletonNode:setScaleX(scale) 
            self.skeletonNode:setScaleY(scale)
        else
            self.skeletonNode:setScaleX(scale)
            self.skeletonNode:setScaleY(scale)
        end

        self.skeletonNode:update(0.012)
        
        
        self.skeletonNode:setAnimation(0, "idle", true)


        self.nodeHeight = 125--self.skeletonNode:getBoundingBox().height

        if self.campType == CAMP_A_TYPE then
        
        else
            self.barImageBg = game.G_FightScene.xueNode_imageBg
            self.loadingBar = game.G_FightScene.xueNode_xueloadbar
            self.loadingBar:setPercent(100)
        end
        

        local yiyinImageView = ccui.ImageView:create()
        yiyinImageView:loadTexture("res/UI/fight/yinying.png")
        self:addChild(yiyinImageView)
        yiyinImageView:setName("yinying")
        yiyinImageView:setLocalZOrder(-20)

        if self.campType == CAMP_A_TYPE then
            yiyinImageView:setScale(1)  
        else
            yiyinImageView:setScale(2) 
            yiyinImageView:setPositionY(-30)
        end

    end

    

    if self.campType == CAMP_A_TYPE then
        addHero()
    else
        --添加出现特效
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


    end

    
    if debug_xue == 1 then
        self.curBloodText = ccui.Text:create(math.ceil(self.curBlood), "fonts/huakang.TTF", 24)
        self.curBloodText:setFontName("curBloodText")
        self.curBloodText:setColor(cc.c3b(255, 255, 255))
        self.curBloodText:setPosition(cc.p(0,-20))
        self:addChild(self.curBloodText)
    end

end

function Unit:getPetRes()
    return self.petRes
end
function Unit:getPetTab( id )
    for k,v in pairs(self.playPet) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function Unit:setAckTime( time )
    self.AckTime = time
end

function Unit:getAckTime( ... )
    return self.AckTime
end

function Unit:startAck(init)
    if init then
        self.startActTime = os.clock() - 5
    else
        self.startActTime = os.clock()
    end
    -- print("startAck ================ "..self.startActTime)
end

function Unit:getStartAckTime( ... )
    return self.startActTime
end

function Unit:initValue(param)
    -- self.skillID = self:getHeroSkillsId()
    -- self.skillTAB = gameUtil.getHeroSkillTab( self.skillID )
    -- self.HeroSkillsEx = self:getHeroSkillsEx( self.HeroId )



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


    -- self.actTimes = self:getInitActTimes()

    -- self.TriggerType, self.TrNum = self:initSkillTriggerType()

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


    local time = math.random(100, 200) / 100
    -- print("timetimetimetime  66666666               "..time)
    self:setAckTime(time)
    self:startAck(true)

end

function Unit:getInitBlood( ... )
    return self.initialBlood
end


function Unit:getRebirth( ... )
    return self.curRebirth
end

function Unit:setRebirth()
    self.curRebirth = 0
end


function Unit:getInitialAPDeep( ... )
    local APDeep = 0

    return APDeep
end

function Unit:getInitialADDeep( ... )
    local ADDeep = 0

    return ADDeep
end

function Unit:getInitialIgnoreAP( ... )
    local IgnoreAP = 0


    return IgnoreAP
end

function Unit:getInitialIgnoreAD( ... )
    local IgnoreAD = 0


    return IgnoreAD
end

function Unit:getInitialRebirth( ... )
    local Rebirth = 0
    return Rebirth
end

function Unit:getInitialADxixue( ... )
    local ADxixue = 0


    return ADxixue
end

function Unit:getInitialAPRebound( ... )
    local APRebound = 0


    return APRebound
end

function Unit:getInitialADRebound( ... )
    local ADRebound = 0

    return ADRebound
end

function Unit:getInitialExemptAP( ... )
    local ExemptAP = 0

    return ExemptAP
end

function Unit:getInitialExemptAD( ... )
    local ExemptAD = 0


    return ExemptAD
end

function Unit:getInitialAPParry( ... )
    local APParry = 0


    return APParry
end

function Unit:getInitialADParry( ... )
    local ADParry = 0

    return ADParry
end

function Unit:getInitialMAP( ... )
    local MAP = 0

    return MAP
end

function Unit:getInitialArmorP( ... )
    local armorP = 0

    return armorP
end

function Unit:getInitialCritTimes( ... )
    local critTimes = 2

    return critTimes
end


-- function Unit:getInitActTimes( ... )
--     return self.skillTAB.actTimes
-- end

-- function Unit:getCurActTimes( ... )
--     return self.actTimes
-- end

function Unit:getSkillTriggerType( ... )
    return self.TriggerType, self.TrNum
end

function Unit:setSkillTriggerType( TriggerType )
    self.TriggerType = TriggerType
end

-- function Unit:initSkillTriggerType( ... )
--     local id = self:getHeroSkillsId()
--     return gameUtil.getHeroSkillTab( id ).TriggerType, gameUtil.getHeroSkillTab( id ).TrNum
-- end

function Unit:getInitZorder( ... )
    return self.zorder
end

function Unit:getInitialMofang( ... )
    local mofangNum = 0
    return mofangNum

end


function Unit:getInitialWufang( ... )
    local wufangNum = 1
    return 1

end


function Unit:getInitialCrit( ... )
    local critNum = 0
    
    critNum = self.petRes.Crit +  self.pet.lv * 1.1 --todo 公式
    return critNum

end

function Unit:getCrit( ... )
    return self.curCrit
end

function Unit:getInitialDodge( ... )

    return 1

end

function Unit:getDodge( ... )
    return self.curDodge
end

function Unit:getInitialAck( ... )
    local ackNum = 0
    
    ackNum = self.petRes.Attack +  self.pet.lv * 1 +  self.pet.skillLv * 1--todo 公式

    local eq01 = self.pet.eq01
    if eq01 > 0 then

        local eqTab
        for k,v in pairs(mm.data.petEquip) do
            if v.id == eq01 then
                eqTab = v
            end
        end

        if eqTab then
            local table1 = {"Attack","Crit","Speed"}
            local equipResId = eqTab.resId
            local resTab = equipTable[equipResId]
            local quality = resTab.quality
            local lv = eqTab.lv
            local Type = resTab.Type

            local xx = table1[Type]..string.format("%02d",quality)
            print(lv.."lv   xx "..xx)
            local zhushuxin = equipLvTable[lv][xx]

            ackNum = ackNum + zhushuxin
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
    local hurt = self.curAck * (-1)

    return {
                hurt = hurt, 
                wuliCrit = 1,
                myHurt = 0,
                wumian = nil,
                momian = nil,
                damageStyle = MM.EDamageStyle.Wuli
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
    return self.petRes.Src
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

    local TgType =  game.skillBtnTab[heroid].can
    if TgType then
        id = self:getHeroSkillsId()
        game.skillBtnTab[heroid].can = false
    else
        id = self:getHeroPuGongId()
    end

    return id

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
    else
        hpNum = 1000
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
            for i=1,#self.fightParam.zhuZhenA do
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

    return t
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
    local speed = 1

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

    self.loadingBar = nil
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
        -- self.barImageBg:setVisible(false)
        -- self.loadingBar:setVisible(false)
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

    -- print("font  hurt                    1")

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
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local silenceTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addSilenceTexiao(res)
                    self:setSilenceTime(time + silenceTime)
                end

                ----是否冰冻
                if isBinDong then
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local binDongTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addBinDongTexiao(res)
                    self:setBinDongTime(time + binDongTime)
                end
                --是否眩晕
                if isXuanYun then
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local xuanYunTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addXuanYunTexiao(res)
                    self:setXuanYunTime(time + xuanYunTime)
                end

                --是否变羊
                if isYang then
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local YangTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addYangTexiao(res)
                    self:setYangTime(time + YangTime)
                end

                --是否集火
                if isJihuo then
                    local res = INITLUA:getBuffByid( skillTab.DEBUFFID ).texiaoRes
                    local jihuoTime = INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
                    self:addJiHuoTexiao(res)
                    self:setJiHuoTime(time + jihuoTime)
                end

                


            end
            
        end
        self:getSkeletonNode():setAnimation(0, "hurt", false)
        self:getSkeletonNode():registerSpineEventHandler(hurtBack,sp.EventType.ANIMATION_COMPLETE)
        self:getSkeletonNode():setTimeScale(speedScale)

    else
        --是否护甲
        if HuJia then
            local skillTab = gameUtil.getHeroSkillTab( skillId )
            local res = INITLUA:getBuffByid( skillTab.BUFFID ).texiaoRes
            local HuJiaTime = INITLUA:getBuffByid( skillTab.BUFFID ).chixuhuihe
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
    else
    end

    if math.ceil(self:getCurBlood()) <= 0 then
        if reburthNum and reburthNum > 0 then
            self:setCurBlood(reburthNum)

            gameUtil:addTishi( {p = self, s = "重生" , z = 1000,width = 25, height = 50})
        else
            --计算掉落
            self:playDieTeXiao(time)
            -- game:dispatchEvent({name = EventDef.UI_MSG, code = "CountHeroDiedTime", heroId = self.HeroId, camp = self.campType})
        end

        

    else
        self.loadingBar:setPercent(math.ceil(self:getCurBlood() / self.initialBlood * 100))
        -- self.barImageBg:setVisible(true)
        -- self.loadingBar:setVisible(true)
        local function showbarBack( ... )
            -- self.barImageBg:setVisible(false)
            -- self.loadingBar:setVisible(false)
        end
        self:runAction( cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(showbarBack)))
    end
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

    -- print("font  hurt      "..hurt)
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
    if debug_xue == 1 then
        self.curBloodText:setString(math.ceil(self.curBlood))
    end

end

--先手 反杀 抢人头
function Unit:showSkillIcon( TgType )

    local skillIcon = ccui.ImageView:create()
    if MM.ETriggerType.TrXianshou == TgType then
        skillIcon:loadTexture("res/icon/jiemian/icon_tanxianshou.png")
        -- print("showSkillIconshowSkillIconshowSkillIconshowSkillIcon      先手")
    elseif MM.ETriggerType.TrFansha == TgType then
        skillIcon:loadTexture("res/icon/jiemian/icon_tanfansha.png")
        -- print("showSkillIconshowSkillIconshowSkillIconshowSkillIcon      反杀")
    elseif MM.ETriggerType.TrQiangrentou == TgType then
        skillIcon:loadTexture("res/icon/jiemian/icon_tanrentou.png")
        -- print("showSkillIconshowSkillIconshowSkillIconshowSkillIcon      抢人头")
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

    -- if isZhuJue then
    --     local function hurtBack()
    --         self:getSkeletonNode():unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
    --         self:getSkeletonNode():setAnimation(0, "stand", true)
    --     end
    --     self:getSkeletonNode():setAnimation(0, "hurt", false)
    --     self:getSkeletonNode():registerSpineEventHandler(hurtBack,sp.EventType.ANIMATION_COMPLETE)
    -- end

    if not self:isDead() then
        local b = self:getCurBlood() + hurt
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


    if not self.loadingBar then
        return
    end

    if math.ceil(self:getCurBlood()) <= 0 then
        self.loadingBar:setPercent(0)
    else
        self.loadingBar:setPercent(math.ceil(self:getCurBlood() / self.initialBlood * 100))
    end

    -- self.barImageBg:setVisible(true)
    -- self.loadingBar:setVisible(true)
    local function showbarBack( ... )
        -- self.barImageBg:setVisible(false)
        -- self.loadingBar:setVisible(false)
    end
    self:runAction( cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(showbarBack)))

    local fut = "res/font/fnt_02.fnt"
    if DamageStyle == 1 then
        fut = "res/font/fnt_03.fnt"
    elseif DamageStyle == 2 then
        fut = "res/font/fnt_02.fnt"
    elseif DamageStyle == 3 then
        fut = "res/font/fnt_02.fnt"
    else
        fut = "res/font/fnt_02.fnt"
    end

    -- print("font  hurt  111111    "..hurt)

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
    -- if shoujiPath and #shoujiPath > 0 then 

    --     local shoujiNode = gameUtil.createSkeletonAnimation(shoujiPath..".json", shoujiPath..".atlas",1)
    --     self:getSkeletonNode():addChild(shoujiNode)
    --     shoujiNode:setAnimation(0, "mb", false)
    --     shoujiNode:setPosition(0,50)
    --     shoujiNode:setScaleX(-1)
    --     shoujiNode:setScale(0.5)


    --     local function toPlayHurtAction( ... )
    --         shoujiNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
    --         shoujiNode:setVisible(false)

    --     end 
    --     shoujiNode:registerSpineEventHandler(toPlayHurtAction,sp.EventType.ANIMATION_COMPLETE)
    -- end


    if debug_xue == 1 then
        self.curBloodText:setString(math.ceil(self.curBlood))
    end


    if self:isDead() then
        --播放死亡动画
    end

end

    -- a)死亡单位金币产量 =  (100 + 等级 * 1.2) / 60 * (单位死亡单位时间 * 0.2)
    -- b)死亡单位经验产量 = 7.6 * (单位死亡时间 * 0.2)
function Unit:sendReward( time )
    
    local addGold = math.ceil((1000 + mm.data.playerinfo.level * 20) / 60 * (time * 0.2/3))
    local addExp = math.ceil(7.6 * (time * 0.2))
    local addExppool = math.ceil(7.6 * (time * 0.2))

    -- mm.onePlayAddGold = mm.onePlayAddGold + addGold
    -- mm.onePlayAddExp = mm.onePlayAddExp + addExp
    -- mm.onePlayaddExppool = mm.onePlayaddExppool + addExppool
    
    -- if self.fightType == 1 then 
    --     mm.req("killMelee",{num = 1})
    -- else

    --     if time then
    --         mm.req("killReward",{time = math.ceil(time), userAction = game.userAction})
    --     else
    --     end
    -- end



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
    -- print(self:getHeroName().." 2015-11-20     ===========================================1111====血变化 前 血      "..self.curBlood)
    -- print(self:getHeroName().." 2015-11-20     =============================================1111=====血变化       "..curBlood)
    if curBlood > self.initialBlood then
        curBlood = self.initialBlood
    end
    self.curBlood = curBlood
    -- print(self:getHeroName().." 2015-11-20     ==============================================1111======血变化 后 血      "..self.curBlood)
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
