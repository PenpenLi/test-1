local Fight = {}
local Unit = require("app.models.Unit")
local SkillNode = require("app.models.SkillNode")
CAMP_A_NUM = 5
CAMP_B_NUM = 5

CAMP_A_SKILL_NUM = 4
CAMP_B_SKILL_NUM = 4

CAMP_A_TYPE = 1
CAMP_B_TYPE = 2




local sc = 0.6
local a_scale = {sc,sc,sc,sc,sc}
local b_scale = {sc,sc,1,sc,sc}

local zorder = {20,40,10,50,30}

function Fight:init()

    self:timeUpdate()
    
end

function Fight:timeUpdate()
    local function time( dt )
       self:checkattack()
        
    end
    local scheduler = cc.Director:getInstance():getScheduler()
    self.goldTick =  scheduler:scheduleScriptFunc(time, 0.016,false)


end

--[[
    初始化战场
]]
function Fight:initBattlefield(param)
    self.param = param
    local param = param
    local fScene = param.scene
    local unitTA = param.unitTA
    local myplayerHero = param.myplayerHero
    local unitTB = util.copyTab(param.unitTB)
    local diplayerHero = param.diplayerHero
    local typeA = param.typeA
    local typeB = param.typeB

    local myPkValue = param.myPkValue
    local diPkValue = param.diPkValue

    local fightType = param.fightType

    local myMeleeTab = param.myMeleeTab
    local diMeleeTab = param.diMeleeTab

    local nnffInfo = param.nnffInfo

    self.fScene = fScene

    self.Unit = self.Unit or {}
    self.UnitA = self.UnitA or {}
    self.UnitB = self.UnitB or {}
    --A阵营
    for i=1,CAMP_A_NUM do
        if unitTA[i] then
            local node = fScene:getChildByName("Scene"):getChildByName("a_"..i)
            self.Unit[i] = Unit.create({index = i,fight = self,unitid = i,node = node, campType = CAMP_A_TYPE, scale = a_scale[i],
                                 HeroId = unitTA[i], playHero = myplayerHero, playType = typeA, zorder = zorder[i],
                                  fightParam = param, fightType = fightType, meleeTab = myMeleeTab})
            self.UnitA[i] = self.Unit[i]
        end
    end
    --B阵营
    for i=CAMP_A_NUM + 1,CAMP_A_NUM + CAMP_B_NUM do
        local campIndex = i - CAMP_A_NUM
        if unitTB[campIndex] then
            local node = fScene:getChildByName("Scene"):getChildByName("b_"..campIndex)
            self.Unit[i] = Unit.create({index = campIndex,fight = self,unitid = i,node = node, campType = CAMP_B_TYPE,
                             scale = nnffInfo.size, scaleX = -1, HeroId = unitTB[campIndex], playHero = diplayerHero, playType = typeB,
                              zorder = zorder[campIndex], fightParam = param, fightType = fightType, meleeTab = diMeleeTab, nnffInfo = nnffInfo})
            self.UnitB[campIndex] = self.Unit[i]
        end
    end

    self.SkillNodeA = self.SkillNodeA or {}
    self.SkillNodeB = self.SkillNodeB or {}
    --A技能位置
    for i=1,CAMP_A_SKILL_NUM do
        local node = fScene:getChildByName("Scene"):getChildByName("s_a_"..i)
        self.SkillNodeA[i] = SkillNode.create({node = node})
    end
    --B技能位置
    for i=1,CAMP_B_SKILL_NUM do
        local node = fScene:getChildByName("Scene"):getChildByName("s_b_"..i)
        self.SkillNodeB[i] = SkillNode.create({node = node})
    end

    local time = {1,1.5,1.8,2,2.1}
    local shaketime = {0.7,1,1.3,1.5,1.6}
    local function startPK( ... )
        -- self:seceneEndShake()
        self.timetime = 1
        self.allPos = 4000
        math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
        -- self:cteateSkillSequence(self.timetime)
    end 

    performWithDelay(self.fScene, startPK, 1)

   -- self:seceneBeginShake(0.4, st)
   self:setAllBlood()
end

function Fight:UnitB1( ... )
    return self.UnitB[1]
end


function Fight:seceneBeginShake( btime, etime )
    -- self.fScene:beginShake(btime, etime)
end

function Fight:seceneEndShake( ... )
    self.fScene:endShake()
end

function Fight:setAllBlood( ... )
    local curABlood = 0
    local initABlood = 0
    for k,v in pairs(self.UnitA) do
        local curb =  v:getCurBlood()
        if curb > 0 then
            curABlood = curABlood + curb
        end
        initABlood = initABlood + v:getInitBlood()
    end

    local curBBlood = 0
    local initBBlood = 0
    for k,v in pairs(self.UnitB) do
        local curb =  v:getCurBlood()
        if curb > 0 then
            curBBlood = curBBlood + curb
        end
        initBBlood = initBBlood + v:getInitBlood()
    end

    local param = self.param
    local fScene = param.scene

    local t = {}
    t.curABlood = curABlood
    t.initABlood = initABlood
    t.curBBlood = curBBlood
    t.initBBlood = initBBlood

    -- fScene:refreshBlood(t)
end

function Fight:initNode( ... )
    if self.Unit then
        for k,v in pairs(self.Unit) do
            if v then
                v:clear()
            end
        end
    end

    self.Unit = {}
    self.UnitA = {}
    self.UnitB = {}

    self.SkillNodeA = {}
    self.SkillNodeB = {}

    self.lastKillUnitTime = 0
    self.overTime = 0
end

function Fight:replaceNode( ... )

    self.Unit = {}
    self.UnitA = {}
    self.UnitB = {}

    self.SkillNodeA = {}
    self.SkillNodeB = {}

    self.lastKillUnitTime = 0
    self.overTime = 0
end



function Fight:cteateSkillSequence(unit)

    
    local MAX_CYCLE = 200*100
    self.skillSeq = self.skillSeq or {}
    -- print("cteateSkillSequence 1")
    --循环
    local seqIndex = 0

    if self:isOver() or self.zeroOver then
        -- print("isOver")
        self.timetime = nil

        self.zeroOver = false
        self.fScene:nnff()
        return
    end

    -- local t, unit,TgType  = self:moveOneTime(self.timetime)
    -- local t, unit,TgType  = self:checkattack(self.timetime)
    local t = self.timetime
    if unit then
        seqIndex = seqIndex + 1
        self:getRoundSKill(self.skillSeq, self.timetime, unit, TgType,t)
        self:setCurPos(t,unit,self.skillSeq[self.timetime],TgType)

        self:StartAck(self.timetime)
        self.timetime = self.timetime + 1
    else
        self.timetime = self.timetime + 1
        -- self:cteateSkillSequence()
    end

    
end

function Fight:setTimeZero()
    self.zeroOver = true
end

function Fight:checkattack( )
    if not self.timetime then
        return
    end
    local curTime = os.clock()
    for k,v in pairs(self.UnitA) do
        local time = curTime - v:getStartAckTime()
        local AckTime = v:getAckTime()
        if time > AckTime then
            v:startAck()
            self:cteateSkillSequence(v)
        end
    end
    return nil
end

function Fight:moveOneTime( time )

    local time = time
    local unit = nil
    local TrNum = nil
    local TgType = nil


    local cp = nil
    for k,v in pairs(self.UnitA) do
        
        --判断血量 之后还要判断眩晕 等等
        if v:getCurBlood() <= 0 or time <= v:getBinDongTime() or time <= v:getXuanYunTime() or time <= v:getYangTime() then
            
        else
            local curPos = v:getPos() + v:getSpeed()
            v:setPos(curPos)
            if curPos >= self.allPos then
                cp = cp or curPos
                if curPos >= cp then
                    unit = v
                end
            else

            end
        end

        if time > v:getHuJiaTime() then
            v:setinitHuJiaXue(0)
        end

        if time > v:getWuLiHuDunTime() then
            v:setinitWuLiHuDunXue(0)
        end
    end

    return time,unit


end

--[[
    战斗是否结束
]]
function Fight:isOver()
    local isAOver = true
    for i=1,#self.UnitA do
        if self.UnitA[i]:getCurBlood() > 0 then
            isAOver = false
        end
    end

    local isBOver = true
    for i=1,#self.UnitB do
        if self.UnitB[i]:getCurBlood() > 0 then
            isBOver = false
        end
    end

    if isAOver then
        return 2 --输了
    elseif isBOver then
        return 1 --赢了
    else
        return false
    end

end

--[[
    每回合的技能施放
]]
function Fight:getRoundSKill(skillSeq, Index, Unit, TgType,t)
    local skillSeq = skillSeq
    local index = Index
    local unit = Unit
    local TgType = TgType
    local time  = t
    skillSeq[index] = {}
    skillSeq[index].id = unit:getUnitid()
    skillSeq[index].curSkillId = unit:getCurSkillId(false, unit:getHeroId())
    skillSeq[index].time = t
    skillSeq[index].TgType = TgType

    skillSeq[index].skillType = unit:getSkillType()
    skillSeq[index].Object = {}
    local campType = unit:getCampType()
    local effectType = unit:getEffectType()
    
    local skillObject, skillNodeId = self:getSkillTarget(unit:getHeroId(),skillSeq[index].curSkillId,effectType,skillSeq[index],Unit,time)--unit:getSkillObject() --攻击到得目标
    

    local objectUnit = skillSeq[index].objectUnit
    
    if skillObject then
        for i=1,#skillObject do
            skillSeq[index].Object[i] = {}
            skillSeq[index].Object[i].id = skillObject[i]

            local SilenceTime = self:getSilenceTime(skillSeq[index].curSkillId)
            if SilenceTime ~= 0 then
                skillSeq[index].Object[i].isSilence = true
            end
            
            local BinDongTime = self:getBinDongTime(skillSeq[index].curSkillId)
            if BinDongTime ~= 0 then
                skillSeq[index].Object[i].isBinDong = true
            end

            local XuanYunTime = self:getXuanYunTime(skillSeq[index].curSkillId)
            if XuanYunTime ~= 0 then
                skillSeq[index].Object[i].isXuanYun = true
            end

            local YangTime = self:getYangTime(skillSeq[index].curSkillId)
            if YangTime ~= 0 then
                skillSeq[index].Object[i].isYang = true
            end

            local HuJia = self:getHuJiaTime(skillSeq[index].curSkillId)
            if HuJia ~= 0 then
                skillSeq[index].Object[i].HuJia = true
            end

            local WuLiHuDun = self:getWuLiHuDunTime(skillSeq[index].curSkillId)
            if WuLiHuDun ~= 0 then
                skillSeq[index].Object[i].WuLiHuDun = true
            end

            local JiHuoTime = self:getJiHuoTime(skillSeq[index].curSkillId)
            if JiHuoTime ~= 0 then
                skillSeq[index].Object[i].isJihuo = true
            end

            local bgjectUnit = objectUnit[skillSeq[index].Object[i].id]
            if bgjectUnit then
                 local t = Unit:getSkillAck(bgjectUnit,skillSeq[index].curSkillId, TgType)
                 skillSeq[index].Object[i].hurt = t.hurt
                 skillSeq[index].Object[i].wuliCrit = t.wuliCrit
                 skillSeq[index].Object[i].myHurt = t.myHurt
                 skillSeq[index].Object[i].wumian = t.wumian
                 skillSeq[index].Object[i].momian = t.momian
                 skillSeq[index].Object[i].damageStyle = t.damageStyle
                if HuJia ~= 0 then
                    skillSeq[index].Object[i].hurt = 0
                    bgjectUnit:setinitHuJiaXue(t.hurt)
                    skillSeq[index].Object[i].hujiaZhi = t.hurt
                    bgjectUnit:setHuJiaTime( time + HuJia )
                end

                if WuLiHuDun ~= 0 then
                    skillSeq[index].Object[i].hurt = 0
                    bgjectUnit:setinitWuLiHuDunXue(t.hurt)
                    skillSeq[index].Object[i].wuLiHuDunZhi = t.hurt
                    bgjectUnit:setWuLiHuDunTime( time + WuLiHuDun )
                end
                 
                local hurt = skillSeq[index].Object[i].hurt
                local damageStyle = skillSeq[index].Object[i].damageStyle
                
                if BinDongTime > 0 then
                    bgjectUnit:setBinDongTime( time + BinDongTime )
                end
                if SilenceTime > 0 then
                    bgjectUnit:setSilenceTime( time + SilenceTime )
                end
                if XuanYunTime > 0 then
                    bgjectUnit:setXuanYunTime( time + XuanYunTime )
                end
                if YangTime > 0 then
                    bgjectUnit:setYangTime( time + YangTime )
                end
                if JiHuoTime > 0 then
                    bgjectUnit:setJiHuoTime( time + JiHuoTime )
                end

                --以前是先算所有回合所以直接扣
                -- bgjectUnit:calculateCurBlood(hurt, damageStyle)

                if bgjectUnit:getCurBlood() < 0 and bgjectUnit:getCampType() == CAMP_B_TYPE then
                    self.lastKillUnitTime = time
                end

                --重生
                local reburthNum = bgjectUnit:getRebirth()
                if bgjectUnit:getCurBlood() <= 0 and reburthNum > 0 then
                    
                    skillSeq[index].Object[i].reburthNum = reburthNum
                    bgjectUnit:setCurBlood(reburthNum)
                    bgjectUnit:setRebirth()
                end

                --以前是先算所有回合所以直接扣
                -- unit:calculateCurBlood(t.myHurt, damageStyle)

            end
        end

    end
end

function Fight:getBinDongTime( skillId )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    if skillTab.DEBUFFID > 0 then
        if INITLUA:getBuffByid( skillTab.DEBUFFID ).effType0 == MM.EeffType0.effType_bindong then
            return INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
        else
            return 0
        end
    else
        return 0
    end
end

function Fight:getXuanYunTime( skillId )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    if skillTab.DEBUFFID > 0 then
        if INITLUA:getBuffByid( skillTab.DEBUFFID ).effType0 == MM.EeffType0.effType_xuanyun then
            return INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
        else
            return 0
        end
    else
        return 0
    end
end

function Fight:getYangTime( skillId )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    if skillTab.DEBUFFID > 0 then
        if INITLUA:getBuffByid( skillTab.DEBUFFID ).effType0 == MM.EeffType0.effType_bianyang then
            return INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
        else
            return 0
        end
    else
        return 0
    end
end



function Fight:getWuLiHuDunTime( skillId )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    if skillTab.BUFFID > 0 then
        if INITLUA:getBuffByid( skillTab.BUFFID ).effType0 == MM.EeffType0.effType_WLS then
            return INITLUA:getBuffByid( skillTab.BUFFID ).chixuhuihe
        else
            return 0
        end
    else
        return 0
    end
end

function Fight:getHuJiaTime( skillId )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    if skillTab.BUFFID > 0 then
        if INITLUA:getBuffByid( skillTab.BUFFID ).effType0 == MM.EeffType0.effType_Shield then
            return INITLUA:getBuffByid( skillTab.BUFFID ).chixuhuihe
        else
            return 0
        end
    else
        return 0
    end
end

function Fight:getSilenceTime( skillId )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    if skillTab.DEBUFFID > 0 then
        if INITLUA:getBuffByid( skillTab.DEBUFFID ).effType0 == MM.EeffType0.effType_cengmo then
            return INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
        else
            return 0
        end
    else
        return 0
    end
end

function Fight:getJiHuoTime( skillId )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    if skillTab.DEBUFFID > 0 then
        if INITLUA:getBuffByid( skillTab.DEBUFFID ).effType0 == MM.EeffType0.effType_jihuo then
            return INITLUA:getBuffByid( skillTab.DEBUFFID ).chixuhuihe
        else
            return 0
        end
    else
        return 0
    end
end



--[[
    计算技能命中目标
    MM.ETargetType = {
        all     =   1,
        random      =   2,
        qian        =   3,
        hou     =   4,
        qianhou     =   5,
        shang       =   6,
        zhong       =   7,
        xia     =   8,
        shangxia        =   9,
        shangzhongxia       =   10,
    }
]]
function Fight:getSkillTarget(heroId,skillId,effectType,skillSeq,Unit,time)
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    local Rtab = {}
    local skillNodeId = nil

    local aUnit = nil
    local bUnit = nil
    local skillNodeUnit = nil
    local campType = Unit:getCampType()
    if MM.ETarget.Friend == effectType then
        if CAMP_A_TYPE == campType then
            aUnit = {}
            for i,v in ipairs(self.UnitA) do
                if v:getUnitid() ~= Unit:getUnitid() then
                    table.insert(aUnit,v)
                end
            end
            bUnit = self.UnitB
            skillNodeUnit = self.SkillNodeA
            skillSeq.ObjectType = CAMP_A_TYPE
        elseif CAMP_B_TYPE == campType then
            aUnit = self.UnitB
            bUnit = self.UnitA
            skillNodeUnit = self.SkillNodeB
            skillSeq.ObjectType = CAMP_B_TYPE
        end
    elseif MM.ETarget.Enemy == effectType then
        if CAMP_A_TYPE == campType then
            aUnit = self.UnitB
            bUnit = self.UnitA
            skillNodeUnit = self.SkillNodeB
            skillSeq.ObjectType = CAMP_B_TYPE
        elseif CAMP_B_TYPE == campType then
            aUnit = self.UnitA
            bUnit = self.UnitB
            skillNodeUnit = self.SkillNodeA
            skillSeq.ObjectType = CAMP_A_TYPE
        end
    elseif MM.ETarget.quanbu == effectType then
        if CAMP_A_TYPE == campType then
            aUnit = self.UnitB
            bUnit = self.UnitA
            skillNodeUnit = self.SkillNodeB
            skillSeq.ObjectType = CAMP_B_TYPE
        elseif CAMP_B_TYPE == campType then
            aUnit = self.UnitA
            bUnit = self.UnitB
            skillNodeUnit = self.SkillNodeA
            skillSeq.ObjectType = CAMP_A_TYPE
        end
    elseif MM.ETarget.AllFriend == effectType then
        if CAMP_A_TYPE == campType then
            aUnit = self.UnitA
            bUnit = self.UnitB
            skillNodeUnit = self.SkillNodeA
            skillSeq.ObjectType = CAMP_A_TYPE
        elseif CAMP_B_TYPE == campType then
            aUnit = self.UnitB
            bUnit = self.UnitA
            skillNodeUnit = self.SkillNodeB
            skillSeq.ObjectType = CAMP_B_TYPE
        end
    elseif MM.ETarget.me == effectType then
        if CAMP_A_TYPE == campType then
            aUnit = {}
            table.insert(aUnit,Unit)
            skillNodeUnit = self.SkillNodeA
            skillSeq.ObjectType = CAMP_A_TYPE
        elseif CAMP_B_TYPE == campType then
            aUnit = {}
            table.insert(aUnit,Unit)
            skillNodeUnit = self.SkillNodeB
            skillSeq.ObjectType = CAMP_B_TYPE
        end
    else
        gameUtil:addTishi( {p = mm.scene(), f = 30,s = string.format("英雄ID %d, 技能ID %d 攻击类型 %d ", heroId, skillId, skillTab.SkillEffType) .. "effectType 不对:"..effectType , z = 1000})
    end


    skillSeq.objectUnit = aUnit
    local objectUnit = aUnit

    --统计当前活的
    local live = {}
    local jihuoK = nil
    for k,v in pairs(aUnit) do
        if v:getCurBlood()>0 then
            table.insert(live,k)
            if v:getJiHuoTime() > time then
                jihuoK = k
            end
        end
    end
    local Rtab = nil

    if MM.ESkillEffType.NormalACK == skillTab.SkillEffType then
        --随机一个活着的，--todo 集火
        -- Rtab = self:RandomIndex(live,1)
        -- return Rtab
        if jihuoK then
            return {jihuoK}
        end
    end
    
    local mubiao = {}
    local sifaPos = skillTab.TargetType
    local sifaNum = skillTab.TargetCount
    local tab = live
    if sifaPos == MM.ETargetType.all then
        Rtab = self:RandomIndex(tab,sifaNum)
        skillNodeId = 4
    elseif sifaPos == MM.ETargetType.random then
        Rtab = self:RandomIndex(tab,sifaNum)
    elseif sifaPos == MM.ETargetType.qian then
        Rtab = self:getLiveRTab(objectUnit, {1,2})
        if Rtab then
            Rtab = self:RandomIndex(Rtab,sifaNum)
            skillNodeId = 1
        else
            Rtab = self:getLiveRTab(objectUnit, {3,4,5})
            if Rtab then
                Rtab = self:RandomIndex(Rtab,sifaNum)
                skillNodeId = 4
            else
                skillNodeId = 4
            end
        end
        
    elseif sifaPos == MM.ETargetType.hou then
        Rtab = self:getLiveRTab(objectUnit, {3,4,5})
        if Rtab then
            Rtab = self:RandomIndex(Rtab,sifaNum)
            skillNodeId = 4
        else
            Rtab = self:getLiveRTab(objectUnit, {1,2})
            Rtab = self:RandomIndex(Rtab,sifaNum)
            skillNodeId = 1
        end
        
    elseif sifaPos == MM.ETargetType.qianhou then
    elseif sifaPos == MM.ETargetType.shang then
    elseif sifaPos == MM.ETargetType.zhong then
    elseif sifaPos == MM.ETargetType.xia then
    elseif sifaPos == MM.ETargetType.shangxia then
    elseif sifaPos == MM.ETargetType.shangzhongxia then
        Rtab = self:getLiveRTab(objectUnit, {1,3})
        if Rtab then
            Rtab = self:RandomIndex(Rtab,sifaNum)
            skillNodeId = 2
        elseif self:getLiveRTab(objectUnit, {1,2,5}) then
            Rtab = self:getLiveRTab(objectUnit, {1,2,5})
            Rtab = self:RandomIndex(Rtab,sifaNum)
            skillNodeId = 4
        else
            Rtab = self:getLiveRTab(objectUnit, {2,4})
            Rtab = self:RandomIndex(Rtab,sifaNum)
            skillNodeId = 3
        end
    end
    if skillNodeId then
        skillSeq.skillNodeId = skillNodeId
        skillSeq.skillNode = skillNodeUnit[skillNodeId]
    end
    if Rtab == nil then
    end
    return Rtab, skillNodeId
end

function Fight:getLiveRTab( unit,tab )
    local RTab = nil
    for i=1,#tab do
        if (unit[tab[i]] and unit[tab[i]].getCurBlood and  unit[tab[i]]:getCurBlood() > 0 ) then
            RTab = RTab or {}
            table.insert(RTab,tab[i])
        end
    end
    return RTab
end

function Fight:RandomIndex(tab,num)
    local rt
    local tab = tab
    local tabNum = #tab
    if tabNum <= num then
        rt = tab
    else
        for i=1,tabNum - num do
            table.remove(tab, math.random(1,#tab))
        end
        rt = tab
    end

    return rt

end


--[[
    得到最快的人到达时间
]]
function Fight:getTimeMin()
    local time = nil
    local unit = nil
    local TrNum = nil
    local TgType = nil

    --先手
    for k,v in pairs(self.Unit) do
        if v:getCurBlood() <= 0 then
            
        else
            local TriggerType, Tn = v:getSkillTriggerType()
            if TriggerType == MM.ETriggerType.TrXianshou then
                TrNum = TrNum or Tn
                if Tn >= TrNum then
                    TrNum = Tn 
                    unit = v
                    time = 0
                    TgType = MM.ETriggerType.TrXianshou
                end
            end

        end
    end

    if unit then
        unit:setSkillTriggerType(- MM.ETriggerType.TrXianshou)
        return time, unit, TgType
    end

    --反杀
    for k,v in pairs(self.Unit) do
        if v:getCurBlood() <= 0 then
            
        else
            local TriggerType, Tn = v:getSkillTriggerType()
            if TriggerType == MM.ETriggerType.TrFansha then
                if Tn > 1 then
                    if v:getCurBlood() < Tn then
                        unit = v
                        time = 0
                        TgType = MM.ETriggerType.TrFansha
                    end
                else
                    if v:getCurBlood() / v:getInitBlood()  < Tn then
                        unit = v
                        time = 0
                        TgType = MM.ETriggerType.TrFansha
                    end
                end
            end

        end
    end

    if unit then
        unit:setSkillTriggerType(- MM.ETriggerType.TrFansha)
        return time, unit, TgType
    end

    --抢人头
    for k,v in pairs(self.Unit) do

        if v:getCurBlood() <= 0 then
            
        else
            local TriggerType, Tn = v:getSkillTriggerType()
            local direnUnit = nil
            if TriggerType == MM.ETriggerType.TrQiangrentou then
                if v:getCampType() == CAMP_A_TYPE then
                    direnUnit = self.UnitB
                else
                    direnUnit = self.UnitA
                end

                for k1,v1 in pairs(direnUnit) do
                    if Tn > 1 then
                        if v1:getCurBlood() < Tn then
                            v:setSkillTriggerType(- MM.ETriggerType.TrQiangrentou)
                            unit = v
                            time = 0
                            TgType = MM.ETriggerType.TrQiangrentou
                            return time, unit, TgType
                        end
                    else
                        if v1:getCurBlood() / v1:getInitBlood()  < Tn then
                            v:setSkillTriggerType(- MM.ETriggerType.TrQiangrentou)
                            unit = v
                            time = 0
                            TgType = MM.ETriggerType.TrQiangrentou
                            return time, unit, TgType
                        end
                    end
                end
                
            end

        end
    end



    --正常
    for k,v in pairs(self.Unit) do
        
        --判断血量 之后还要判断眩晕 等等
        if v:getCurBlood() <= 0 then
            
        else
            local t = ( self.allPos - v:getPos() ) / v:getSpeed()
            time = time or t
            if t <= time then
                time = t
                unit = v
            end
        end
    end
    return time, unit
end

--[[
    设置回合结束后的最新位置
]]
function Fight:setCurPos(t,unit,skillSeq, TgType)
    local time = t
    local unit = unit
    
    local pos = unit:getPos() - self.allPos
    if pos > 0 then
        unit:setPos(pos)
    else
        unit:setPos(0)
    end
        
    
end

function Fight:fightEnd( ... )
    -- if mm.GuildId == 10002 or mm.GuildId == 10003 or mm.GuildId == 10003 then

    -- else
        local param = self.param
        local fScene = param.scene
        fScene:nextFight()

    -- end

    
end

function Fight:jiesuan( ... )
    if mm.GuildId == 10001 then
        local param = self.param
        local fScene = param.scene

        local lastKillUnitTime =  self.lastKillUnitTime
        local overTime = self.overTime

        -- mm.guildJieSuanTab = {result = self.skillSeq.result, lastKillUnitTime = lastKillUnitTime, overTime = overTime}
        fScene:jiesuan({result = self.skillSeq.result, lastKillUnitTime = lastKillUnitTime, overTime = overTime})
        Guide:startGuildById(10002 , mm.PanelGuideBtn)
        mm.GuildId = 10002

        
        
        Guide:setHandVisible(true)

    else
        local param = self.param
        local fScene = param.scene

        local lastKillUnitTime =  self.lastKillUnitTime
        local overTime = self.overTime
        fScene:jiesuan({result = self.skillSeq.result, lastKillUnitTime = lastKillUnitTime, overTime = overTime})
        --todo
    end

    
end

--[[
    开始战斗
]]
function Fight:StartAck(roundIndex)
    -- print("StartAck ")
    local skillSeq = self.skillSeq

    local round = #skillSeq
    if #self.Unit == 0 then
        return
    end 


    -- if roundIndex > round then
    --     game.jiesuanAction = performWithDelay(self.param.scene, handler(self, self.jiesuan), 0.5)
    --     game.jiesuanAction:setTag(500)
    --     game.fightEndAction = performWithDelay(self.param.scene, handler(self, self.fightEnd), 4)
    --     game.fightEndAction:setTag(501)
    --     return
    -- end


    for k,v in pairs(self.Unit) do
        v:setBuffBegin(skillSeq[roundIndex])
    end

    local skillId = skillSeq[roundIndex].curSkillId
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    
    local id = skillSeq[roundIndex].id
    local unit = self.Unit[id]
    
    local texiaoEffect = gameUtil.getHeroSkillTab( skillId ).texiaoEffect 

    self.ackPlayEnd = false

    self:sifangSkill({skillSeq = skillSeq[roundIndex], roundIndex = roundIndex})
    
end

function Fight:AnimationHoldBack( roundIndex )
    local skillSeq = self.skillSeq
    self:PlayHurtAction( {skillSeq = skillSeq[roundIndex]} )
end

--[[
    施法动画结束
]]
function Fight:AckOrSkillActionEnd( roundIndex )
    local skillSeq = self.skillSeq
    --开始播放技能释放
    self:sifangSkill({skillSeq = skillSeq[roundIndex], roundIndex = roundIndex})
end


function Fight:getTwoNodeCP( unitA, unitB)
    local x = unitB:getPositionX() - unitA:getPositionX()
    local y = unitB:getPositionY()  - 
                (unitA:getPositionY() )
    return cc.p(x,y)
end

function Fight:getTwoPosXY( unitA, unitB )
    local bp = cc.p(unitB:getPosition())
    local ap = cc.p(unitA:getPosition())
    local v =  cc.pSub(bp, ap)
    local Angel = - math.deg(cc.pToAngleSelf(v)) 
    return Angel
end

function Fight:playSiFaEffect( ... )
    --gameUtil.playEffect("res/sounds/effect/all/t_sf_zs", false)
end

--[[
    skillSeq 此次技能序列
]]
function Fight:sifangSkill( param )
    -- print("sifangSkill ")
    local skillSeq = param.skillSeq
    local skillId = skillSeq.curSkillId
    local unitA = self.Unit[skillSeq.id]
    local roundIndex = param.roundIndex
    local TgType = skillSeq.TgType

    self.tousewuCo = self.tousewuCo or {}
    self.boCo = self.boCo or {}
    self.tiaoCo = self.tiaoCo or {}
    self.dianCo = self.dianCo or {}
    self.dianweiCo = self.dianweiCo or {}
    self.yuandiCo = self.yuandiCo or {}


    unitA:showSkillIcon( TgType )
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    local texiaoEffect = gameUtil.getHeroSkillTab( skillId ).texiaoEffect 
    -- print("sifangSkill ====================       1 ")
    if texiaoEffect == MM.EtexiaoEffect.null then

    elseif texiaoEffect == MM.EtexiaoEffect.tousewu or  texiaoEffect == MM.EtexiaoEffect.touzhi then
        local skillTab = gameUtil.getHeroSkillTab( skillId )

        local objd = skillSeq.Object[1].id
        local unitB = skillSeq.objectUnit[objd]
        if unitB == nil then
        end

        local angel = self:getTwoPosXY( unitA, unitB )
        local function playTouSewu( ... )
            local Skilltype = skillTab.SkillEffType
            local scale = skillTab.speed_scale * game.speedBuff

            local skeletonNode = unitA:getSkeletonNode()
            -- if unitA:getCampType() == CAMP_A_TYPE then
            --     skeletonNode:setRotation(angel)
            -- else
            --     skeletonNode:setRotation(angel + 180)
            -- end
            if Skilltype == MM.ESkillEffType.NormalACK then
                skeletonNode:setAnimation(0, "attack", false)
                skeletonNode:setTimeScale(scale)
            elseif Skilltype == MM.ESkillEffType.Initiative then
                skeletonNode:setAnimation(0, "skill", false)
                unitA:playSkillTongYongTeXiao()
                skeletonNode:setTimeScale(scale)
            end
            self:playSiFaEffect()
            
            local function ackBack()
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:setAnimation(0, "stand", true)
                -- skeletonNode:setRotation(0)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            skeletonNode:registerSpineEventHandler(function (event)
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                if event.eventData.name == "HurtHold" then
                elseif event.eventData.name == "AnimationHold" then
                    coroutine.resume(self.tousewuCo[skillId], self)
                end
              
            end, sp.EventType.ANIMATION_EVENT)
            coroutine.yield()

            local skeletonNode = gameUtil.createSkeletonAnimation(skillTab.hurtEffect..".json", skillTab.hurtEffect..".atlas",1)
            unitA:addChild(skeletonNode)
            skeletonNode:setAnimation(0, "tsw", false)
            skeletonNode:setScale(0.5)

            local speedScale = skillTab.speed_scale * game.speedBuff
            if speedScale == 0 then
                speedScale = 1
            end

            if unitA:getCampType() == CAMP_A_TYPE then
                skeletonNode:setPosition(100 * 0.5,100 * 0.5)
            else
                skeletonNode:setPosition(-100 * 0.5,100 * 0.5)
            end
            
            skeletonNode:setRotation(angel)

            local paowu = 0
            if texiaoEffect == MM.EtexiaoEffect.touzhi then
                paowu = math.random(60,80 )
            end
            local cpjuli = self:getTwoNodeCP( unitA, unitB )
            local cp = self:getTwoNodeCP( unitA, unitB )
            local bezier = {
                cc.p(0, 0),
                cc.p(cp.x * 0.5, paowu + cp.y),
                cc.p(cp.x, cp.y),
            }
            local juli = math.sqrt((math.abs(cpjuli.x) * math.abs(cpjuli.x)) + (math.abs(cpjuli.y) * math.abs(cpjuli.y))) 
            local time = juli * 0.001 / game.speedBuff
            local bezierForward = cc.BezierBy:create(time, bezier)

            local action = cc.Sequence:create(
                    --cc.MoveBy:create(juli * 0.001 / speedScale, self:getTwoNodeCP( unitA, unitB )),
                    bezierForward,
                    cc.CallFunc:create(function( ... )
                        skeletonNode:setVisible(false)
                        coroutine.resume(self.tousewuCo[skillId], self)
                    end)
                )
            skeletonNode:runAction(action)
            gameUtil.playEffect(skillTab.Start_Sound,false)

            coroutine.yield()

            self:PlayHurtAction( param )

            gameUtil.playEffect(skillTab.End_Sound,false)

            local action = cc.Sequence:create(
                    cc.DelayTime:create(0.5 / game.speedBuff ),
                    cc.CallFunc:create(function( ... )
                        coroutine.resume(self.tousewuCo[skillId], self)
                    end)
                )
            unitA:runAction(action)
            coroutine.yield()
            self:AckIsPlayEnd()
        end
        

        self.tousewuCo[skillId] = coroutine.create(function()
            playTouSewu()
        end)
        coroutine.resume(self.tousewuCo[skillId], self)



    elseif texiaoEffect == MM.EtexiaoEffect.bo then
        local skillTab = gameUtil.getHeroSkillTab( skillId )
        local function playBo( ... )
            local Skilltype = skillTab.SkillEffType
            local isAnimationHold = param.isAnimationHold
            local scale = skillTab.speed_scale * game.speedBuff

            local skeletonNode = unitA:getSkeletonNode()
            if Skilltype == MM.ESkillEffType.NormalACK then
                skeletonNode:setAnimation(0, "attack", false)
                skeletonNode:setTimeScale(scale)
            elseif Skilltype == MM.ESkillEffType.Initiative then
                skeletonNode:setAnimation(0, "skill", false)
                unitA:playSkillTongYongTeXiao()
                skeletonNode:setTimeScale(scale)
            end
            self:playSiFaEffect()

            
            local function ackBack()
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:setAnimation(0, "stand", true)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            skeletonNode:registerSpineEventHandler(function (event)
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                if event.eventData.name == "HurtHold" then
                elseif event.eventData.name == "AnimationHold" then
                    coroutine.resume(self.boCo[skillId], self)
                end
              
            end, sp.EventType.ANIMATION_EVENT)
            coroutine.yield()

            self:playHurtEffect({resume = self.boCo[skillId],skillTab = skillTab, skillSeq = skillSeq, unitA = unitA, animationName = "bo", texiaoEffect = texiaoEffect})

            self:PlayHurtAction( param )
            gameUtil.playEffect(skillTab.End_Sound,false)

            local action = cc.Sequence:create(
                    cc.DelayTime:create(0.5 / game.speedBuff ),
                    cc.CallFunc:create(function( ... )
                        coroutine.resume(self.boCo[skillId], self)
                    end)
                )
            unitA:runAction(action)
            coroutine.yield()
            self:AckIsPlayEnd()

        end
        self.boCo[skillId] = coroutine.create(function()
            playBo()
        end)
        coroutine.resume(self.boCo[skillId], self)


        

    elseif texiaoEffect == MM.EtexiaoEffect.tiao then
        local skillTab = gameUtil.getHeroSkillTab( skillId )

        local function playTiao( ... )
            local unitB = nil
            if skillSeq.skillNode then
                unitB = skillSeq.skillNode
            else
                local objd = skillSeq.Object[1].id
                unitB = skillSeq.objectUnit[objd]
            end

            local angel = self:getPosXY( unitA, unitB )
            local cp = self:getCp( unitA, unitB )
            

            if unitA:getCampType() == CAMP_A_TYPE then
                cp.x = cp.x - 100
            else
                cp.x = cp.x + 100
            end
 
            self.ackPlayEnd = false

            local speedScale = skillTab.speed_scale * game.speedBuff
            if speedScale == 0 then
                speedScale = 1
            end

            local action = cc.Sequence:create(
                    cc.MoveBy:create(0.15  / speedScale / game.speedBuff , cp),
                    cc.CallFunc:create(function()
                        coroutine.resume(self.tiaoCo[skillId], self)
                    end)
                    
                )
            unitA:runAction(action)
            coroutine.yield()

            local Skilltype = skillTab.SkillEffType
            local scale = skillTab.speed_scale * game.speedBuff

            local skeletonNode = unitA:getSkeletonNode()
            if Skilltype == MM.ESkillEffType.NormalACK then
                skeletonNode:setAnimation(0, "attack", false)
                skeletonNode:setTimeScale(scale)
            elseif Skilltype == MM.ESkillEffType.Initiative then
                skeletonNode:setAnimation(0, "skill", false)
                unitA:playSkillTongYongTeXiao()
                skeletonNode:setTimeScale(scale)
            end
            self:playSiFaEffect()
            
            gameUtil.playEffect(skillTab.Start_Sound,false)
            
            
            local function ackBack()
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:setAnimation(0, "stand", true)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            skeletonNode:registerSpineEventHandler(function (event)
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                if event.eventData.name == "HurtHold" then
                    coroutine.resume(self.tiaoCo[skillId], self)
                elseif event.eventData.name == "AnimationHold" then
                    coroutine.resume(self.tiaoCo[skillId], self)
                elseif event.eventData.name == "DefHold" then
                    coroutine.resume(self.tiaoCo[skillId], self)
                end
              -- print(string.format("[spine] %d event: %s, %d, %f, %s", 
              --         event.trackIndex,
              --         event.eventData.name,
              --         event.eventData.intValue,
              --         event.eventData.floatValue,
              --         event.eventData.stringValue))
            end, sp.EventType.ANIMATION_EVENT)

            coroutine.yield()

            self:playHurtEffect({resume = self.tiaoCo[skillId],skillTab = skillTab, skillSeq = skillSeq, unitA = unitA, animationName = "zs", texiaoEffect = texiaoEffect})

            self:PlayHurtAction( param )
            gameUtil.playEffect(skillTab.End_Sound,false)

            local action = cc.Sequence:create(
                    cc.DelayTime:create(0.6 / game.speedBuff),
                    cc.CallFunc:create(function( ... )
                        coroutine.resume(self.tiaoCo[skillId], self)
                    end)
                )
            unitA:runAction(action)
            coroutine.yield()

            local action = cc.Sequence:create(
                        cc.MoveBy:create(0.15 / speedScale / game.speedBuff, cc.p(cp.x*(-1),cp.y*(-1))),
                        cc.CallFunc:create(function( ... )
                            coroutine.resume(self.tiaoCo[skillId], self)
                        end)
                    )
            unitA:runAction(action)    

            coroutine.yield()
            self:AckIsPlayEnd()

        end

        self.tiaoCo[skillId] = coroutine.create(function()
            playTiao()
        end)
        coroutine.resume(self.tiaoCo[skillId], self)
        
        

        

        

    elseif texiaoEffect == MM.EtexiaoEffect.dian then    
        local skillTab = gameUtil.getHeroSkillTab( skillId )
        local function playDian( ... )
            local Skilltype = skillTab.SkillEffType
            local scale = skillTab.speed_scale * game.speedBuff
            local skeletonNode = unitA:getSkeletonNode()
            if Skilltype == MM.ESkillEffType.NormalACK then
                skeletonNode:setAnimation(0, "attack", false)
                skeletonNode:setTimeScale(scale)
            elseif Skilltype == MM.ESkillEffType.Initiative then
                skeletonNode:setAnimation(0, "skill", false)
                unitA:playSkillTongYongTeXiao()
                skeletonNode:setTimeScale(scale)
            end
            self:playSiFaEffect()
            
            local function ackBack()
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:setAnimation(0, "stand", true)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

                skeletonNode:registerSpineEventHandler(function (event)
                    skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                    if event.eventData.name == "HurtHold" then
                    elseif event.eventData.name == "AnimationHold" then
                        coroutine.resume(self.dianCo[skillId], self)
                    end
                  
              end, sp.EventType.ANIMATION_EVENT)
            coroutine.yield()

            local unitB = nil
            if skillSeq.skillNode then
                unitB = skillSeq.skillNode
            else
                local objd = skillSeq.Object[1].id
                unitB = skillSeq.objectUnit[objd]
            end

            local skeletonNode = gameUtil.createSkeletonAnimation(skillTab.hurtEffect..".json", skillTab.hurtEffect..".atlas",1)
            unitB:addChild(skeletonNode)
            skeletonNode:setAnimation(0, "mbd", false)
            skeletonNode:setTimeScale(skillTab.speed_scale * game.speedBuff)
            skeletonNode:setScale(0.5)

            local function toPlayHurtAction( ... )
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:setVisible(false)
            end 
            skeletonNode:registerSpineEventHandler(toPlayHurtAction,sp.EventType.ANIMATION_COMPLETE)

            skeletonNode:registerSpineEventHandler(function (event)
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                if event.eventData.name == "HurtHold" then
                    coroutine.resume(self.dianCo[skillId], self)
                end
            end, sp.EventType.ANIMATION_EVENT)

            coroutine.yield()


            self:PlayHurtAction( param )
            gameUtil.playEffect(skillTab.End_Sound,false)

            local action = cc.Sequence:create(
                    cc.DelayTime:create(0.5 / game.speedBuff ),
                    cc.CallFunc:create(function( ... )
                        coroutine.resume(self.dianCo[skillId], self)
                    end)
                )
            unitA:runAction(action)
            coroutine.yield()
            self:AckIsPlayEnd()


        end

        self.dianCo[skillId] = coroutine.create(function()
            playDian()
        end)
        coroutine.resume(self.dianCo[skillId], self)

        
    elseif texiaoEffect == MM.EtexiaoEffect.danwei then 
        local skillTab = gameUtil.getHeroSkillTab( skillId )

        local function playDanwei( ... )
            local Skilltype = skillTab.SkillEffType
            local scale = skillTab.speed_scale * game.speedBuff

            

            local skeletonNode = unitA:getSkeletonNode()
            if Skilltype == MM.ESkillEffType.NormalACK then
                skeletonNode:setAnimation(0, "attack", false)
                skeletonNode:setTimeScale(scale)
            elseif Skilltype == MM.ESkillEffType.Initiative then
                skeletonNode:setAnimation(0, "skill", false)
                unitA:playSkillTongYongTeXiao()
                skeletonNode:setTimeScale(scale)
            end
            self:playSiFaEffect()
            
            local unitB = nil
            if skillSeq.skillNode then
                unitB = skillSeq.skillNode
            else
                local objd = skillSeq.Object[1].id
                unitB = skillSeq.objectUnit[objd]
            end
            
            local function ackBack()
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:setAnimation(0, "stand", true)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)

            skeletonNode:registerSpineEventHandler(function (event)
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                if event.eventData.name == "HurtHold" then
                    coroutine.resume(self.dianweiCo[skillId], self)
                elseif event.eventData.name == "AnimationHold" then
                    coroutine.resume(self.dianweiCo[skillId], self)
                end
              
            end, sp.EventType.ANIMATION_EVENT)
            coroutine.yield()

            self:playHurtEffect({resume = self.dianweiCo[skillId],skillTab = skillTab, skillSeq = skillSeq, unitA = unitA, animationName = "mb", texiaoEffect = texiaoEffect})
            self:PlayHurtAction(param)
            local action = cc.Sequence:create(
                    cc.DelayTime:create(1 ),
                    cc.CallFunc:create(function( ... )
                        coroutine.resume(self.dianweiCo[skillId], self)
                    end)
                )
            unitA:runAction(action)
            coroutine.yield()
            self:AckIsPlayEnd()

        end
        self.dianweiCo[skillId] = coroutine.create(function()
            playDanwei()
        end)
        coroutine.resume(self.dianweiCo[skillId], self)



    
    elseif texiaoEffect == MM.EtexiaoEffect.yuandi then 
        local skillTab = gameUtil.getHeroSkillTab( skillId )
        local function playYuandi( ... )
            local Skilltype = skillTab.SkillEffType
            local isAnimationHold = param.isAnimationHold
            local scale = skillTab.speed_scale * game.speedBuff
            local skeletonNode = unitA:getSkeletonNode()
            if Skilltype == MM.ESkillEffType.NormalACK then
                skeletonNode:setAnimation(0, "attack", false)
                skeletonNode:setTimeScale(scale)
            elseif Skilltype == MM.ESkillEffType.Initiative then
                skeletonNode:setAnimation(0, "skill", false)
                unitA:playSkillTongYongTeXiao()
                skeletonNode:setTimeScale(scale)
            end
            self:playSiFaEffect()
            
            local function ackBack()
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                skeletonNode:setAnimation(0, "stand", true)
            end
            skeletonNode:registerSpineEventHandler(ackBack,sp.EventType.ANIMATION_COMPLETE)
            skeletonNode:registerSpineEventHandler(function (event)
                skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                if event.eventData.name == "HurtHold" then
                    coroutine.resume(self.yuandiCo[skillId], self)
                elseif event.eventData.name == "AnimationHold" then
                    
                    coroutine.resume(self.yuandiCo[skillId], self)
                elseif event.eventData.name == "DefHold" then
                    
                    coroutine.resume(self.yuandiCo[skillId], self)
                end
                -- print(string.format("[spine] %d event: %s, %d, %f, %s", 
                --       event.trackIndex,
                --       event.eventData.name,
                --       event.eventData.intValue,
                --       event.eventData.floatValue,
                --       event.eventData.stringValue))
              
            end, sp.EventType.ANIMATION_EVENT)

            coroutine.yield()

            self:playHurtEffect({resume = self.yuandiCo[skillId],skillTab = skillTab, skillSeq = skillSeq, unitA = unitA, animationName = "zs", texiaoEffect = texiaoEffect})

            self:PlayHurtAction(param)
            local action = cc.Sequence:create(
                    cc.DelayTime:create(0.5 / game.speedBuff ),
                    cc.CallFunc:create(function( ... )
                        coroutine.resume(self.yuandiCo[skillId], self)
                    end)
                )
            unitA:runAction(action)
            coroutine.yield()
            self:AckIsPlayEnd()

        end

        self.yuandiCo[skillId] = coroutine.create(function()
            playYuandi()
        end)
        coroutine.resume(self.yuandiCo[skillId], self)

        


        
    else

    end
end

function Fight:playHurtEffect( param )
    local skillTab = param.skillTab
    local skillSeq = param.skillSeq
    local unitA = param.unitA
    local animationName = param.animationName
    local texiaoEffect = param.texiaoEffect
    local resume = param.resume

    local hurtTimes = skillTab.hurtTimes

    local unitB = nil
    if skillSeq.skillNode then
        unitB = skillSeq.skillNode
    else
        local objd = skillSeq.Object[1].id
        unitB = skillSeq.objectUnit[objd]
    end
    if #skillTab.hurtEffect > 0 then
        local hurtStonNode = gameUtil.createSkeletonAnimation(skillTab.hurtEffect..".json", skillTab.hurtEffect..".atlas",1)
        if animationName == "zs" and texiaoEffect == MM.EtexiaoEffect.tiao  then
            unitA:getSkeletonNode():addChild(hurtStonNode)
        elseif animationName == "zs" and texiaoEffect == MM.EtexiaoEffect.yuandi  then
            unitA:getSkeletonNode():addChild(hurtStonNode)
        elseif animationName == "bo" then
            unitA:addChild(hurtStonNode)
        else
            if skillSeq.skillNode then
                unitB:addChild(hurtStonNode)
            else
                unitB:getSkeletonNode():addChild(hurtStonNode)
            end
        end
        hurtStonNode:setAnimation(0, animationName, false)
        hurtStonNode:setTimeScale(skillTab.speed_scale * game.speedBuff)
        hurtStonNode:setScale(0.65)
        --hurtStonNode:setPositionY(42)
        gameUtil.playEffect(skillTab.Start_Sound,false)

        if animationName == "bo" then
            local angel = self:getPosXY( unitA, unitB )
            hurtStonNode:setRotation(angel)
        end


        if skillId == 1278488886 then
            unitB:getSkeletonNode():setVisible(false)
        end

        local function toPlayHurtAction( ... )
            hurtStonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            hurtStonNode:setVisible(false)
        end 
        hurtStonNode:registerSpineEventHandler(toPlayHurtAction,sp.EventType.ANIMATION_COMPLETE)

        
        local times = 0 
        if hurtTimes > 1 then
            self:setHurtTab( skillSeq, hurtTimes)
        end
        hurtStonNode:registerSpineEventHandler(function (event)
                --hurtStonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                if event.eventData.name == "HurtHold" then
                    if hurtTimes <= 1 then
                        coroutine.resume(resume, self)
                    else
                        times = times + 1

                        for i=1,#skillSeq.Object do
                            if times < hurtTimes then
                                local objd = skillSeq.Object[i].id
                                local unit = skillSeq.objectUnit[objd]
                                unit:setPiaoxue(skillSeq.Object[i].hurtTab[times], skillTab.shoujiEffect, skillTab.DamageStyle)
                            else
                                if i == 1 then
                                    coroutine.resume(resume, self)
                                end
                            end
                        end
                    end
                elseif event.eventData.name == "AnimationHold" then
                    coroutine.resume(resume, self)
                elseif event.eventData.name == "VibrationHold" then
                    -- self:seceneBeginShake( 0, 0.5 )
                end
            -- print(string.format("[spine11] %d event: %s, %d, %f, %s", 
            --           event.trackIndex,
            --           event.eventData.name,
            --           event.eventData.intValue,
            --           event.eventData.floatValue,
            --           event.eventData.stringValue))
        end, sp.EventType.ANIMATION_EVENT)
        coroutine.yield()
        
    end
end

function Fight:setHurtTab( skillSeq, hurtTimes)
    for i=1,#skillSeq.Object do
        local allhurt = skillSeq.Object[i].hurt
        local hurt1 = allhurt / (hurtTimes)
        local hurt2 = allhurt / (hurtTimes*4)
        skillSeq.Object[i].hurtTab = {}
        for n=1,hurtTimes - 1 do
            local h = math.ceil(math.random(hurt1 - hurt2, hurt1))
            skillSeq.Object[i].hurtTab[n] = h
            allhurt = allhurt - h
        end
        skillSeq.Object[i].hurt = allhurt
    end
end

function Fight:getCp( unitA, unitB )
    local x = unitB:getPositionX() - unitA:getPositionX()
    local y = unitB:getPositionY() - unitA:getPositionY()
    return cc.p(x,y)
end

function Fight:getPosXY( unitA, unitB )
    local v =  cc.pSub(cc.p(unitB:getPosition()), cc.p(unitA:getPosition()))
    local Angel = - math.deg(cc.pToAngleSelf(v)) 
    return Angel
end

function Fight:PlayHurtAction( param )
    local skillSeq = param.skillSeq
    local skillId = skillSeq.curSkillId
    local skillTab = gameUtil.getHeroSkillTab( skillId )
    local shoujiPath = skillTab.shoujiEffect

    local unitA = self.Unit[skillSeq.id]

    self.allHurt = #skillSeq.Object
    self.hurtEnd = 0
    for i=1,#skillSeq.Object do
        local objd = skillSeq.Object[i].id
        local hurtSkeletonNode = skillSeq.objectUnit[objd]
        local hurt = skillSeq.Object[i].hurt
        local wuliCrit = skillSeq.Object[i].wuliCrit
        local myHurt = skillSeq.Object[i].myHurt
        local reburthNum = skillSeq.Object[i].reburthNum
        local wumian = skillSeq.Object[i].wumian
        local momian = skillSeq.Object[i].momian
        local hujiaZhi = skillSeq.Object[i].hujiaZhi
        local wuLiHuDunZhi = skillSeq.Object[i].wuLiHuDunZhi


        local isSilence = skillSeq.Object[i].isSilence  --沉默时间
        local isBinDong = skillSeq.Object[i].isBinDong  --冰冻时间
        local isXuanYun = skillSeq.Object[i].isXuanYun  --眩晕时间
        local isYang = skillSeq.Object[i].isYang  --羊时间
        local isJihuo = skillSeq.Object[i].isJihuo  --集火时间
        local HuJia = skillSeq.Object[i].HuJia  --护盾
        local WuLiHuDun = skillSeq.Object[i].WuLiHuDun  --物理护盾
        if not hurtSkeletonNode then
            self.allHurt = self.allHurt - 1
        else
            local t = {
                hurt = hurt,
                shoujiPath = shoujiPath,
                skillId = skillId,
                isSilence = isSilence,
                isBinDong = isBinDong,
                speed_scale = skillTab.speed_scale * game.speedBuff,
                time = skillSeq.time,
                TgType = skillSeq.TgType,
                isXuanYun = isXuanYun,
                isYang = isYang,
                isJihuo = isJihuo,
                HuJia = HuJia,
                WuLiHuDun = WuLiHuDun,
                DamageStyle = skillTab.DamageStyle,
                wuliCrit = wuliCrit,
                reburthNum = reburthNum,
                wumian = wumian,
                momian = momian,
                hujiaZhi = hujiaZhi,
                wuLiHuDunZhi = wuLiHuDunZhi,
            }

            -- print("font  hurt    PlayHurt                1")
            hurtSkeletonNode:PlayHurt(t)
        end
        if myHurt ~= 0 then
            unitA:PlayHurt({
                                hurt = myHurt,
                                shoujiPath = skillTab.shoujiEffect,
                                DamageStyle = skillTab.DamageStyle,
                                speed_scale = skillTab.speed_scale * game.speedBuff,
                                skillId = skillId,

                            })
        end   
    end
end

function Fight:hurtEndCount( ... )
    -- self.hurtEnd = self.hurtEnd + 1
    
    -- if self.hurtEnd >= self.allHurt and self.ackPlayEnd then
    --     self.hurtEnd = nil
    --     self.allHurt = nil
    --     self.ackPlayEnd = false
    --     self.roundIndex = self.roundIndex + 1
    --     self:StartAck(self.roundIndex)
    -- end
end

function Fight:AckIsPlayEnd( ... )
        self.ackPlayEnd = true
    --if self.allHurt and self.hurtEnd and self.hurtEnd >= self.allHurt then
        self.hurtEnd = nil
        self.allHurt = nil
        self.ackPlayEnd = false
        -- self.roundIndex = self.roundIndex + 1
        -- self:StartAck(self.roundIndex)
        -- self:cteateSkillSequence()
        
        
    --end
end


return Fight
