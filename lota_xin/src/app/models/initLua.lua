local INITLUA = {}
MM = MM or {}
local MM = MM
require("app.res.MoResConstants")

function INITLUA:fightSceneLoad( ... )

    require("app.res.peizhi")


    require("app.res.LOLRes")
    require("app.res.DOTARes")
    require("app.res.LOLSkillRes")
    require("app.res.DOTASkillRes")

    require("app.res.AccountRes")

    require("app.res.BarrackRes")

    require("app.res.BUFFRes")

    require("app.res.equipRes")

    require("app.res.ItemRes")

    require("app.res.LOLRankRes")

    require("app.res.DOTARankRes")

    require("app.res.LOLSTARRes")

    require("app.res.DOTASTARRes")

    require("app.res.TaskRes")

    require("app.res.StageRes")

    require("app.res.MonsterRes")

    require("app.res.mskillRes")

    require("app.res.dropoutRes")

    require("app.res.droplistRes")

    require("app.res.rankgiftRes")

    require("app.res.shopRes")

    require("app.res.shopitemRes")

    require("app.res.PassiveRes")

    require("app.res.VipExpRes")

    require("app.res.ExchangeXRes")

    require("app.res.SkillcostRes")

    require("app.res.RechargeRes")

    require("app.res.VipExpRes")

    require("app.res.ActivtyRewardRes")

    require("app.res.ActivtyListRes")

    require("app.res.ActivtyTypeRes")

    require("app.res.ActivityTypeChildRes")

    require("app.res.sundryRes")
    require("app.res.LibaolistRes")

    require("app.res.LibaoRes")

    require("app.res.TipsRes")

    require("app.res.ExpDrawRes")

    require("app.res.PreciousUpRes")

    require("app.res.ShopMeleeItemRes")
    
    require("app.res.RewardmeleeRes")

    require("app.res.skinRes")
    

    INITLUA:initTaskRes()

    INITLUA:initStageResMap()

    INITLUA:initDOTARankResMap()

    INITLUA:initLOLRankResMap()

    INITLUA:initDOTAStarResMap()

    INITLUA:initLOLStarResMap()

    INITLUA:initLiBaoResMap()

    INITLUA:initExpDrawRes()

    INITLUA:initRewardMeleeResMap()
end

local TaskResMap = {}
local StageResMap = {}

local LOLRankResMap = {}
local DOTARankResMap = {}

local LOLStarResMap = {}
local DOTAStarResMap = {}

local LiBaoResMap = {}
local RewardmeleeResMap = {}

local __G = _G
local resNameFormat = "src.app.res.%sRes"
local string = string
local string_format = string.format
local require = require
local function getRes(name)
    local curRes = __G[name]
    if not curRes then
        require(string_format(resNameFormat, name))
        curRes = __G[name]
    end

    return curRes
end

-- 之后获取全表，使用该接口。
function INITLUA:getRes(name)
    return getRes(name)
end

function INITLUA:getResWithId(name, id)
    local allRes = getRes(name)
    if allRes then
        return allRes[id]
    end
end

function INITLUA:getLOLRes( ... )
    return LOL
end

function INITLUA:getSkillcostRes()
    return Skillcost
end

function INITLUA:getLOLResByHeroID( heroid )
    return LOL[heroid]
end

function INITLUA:getDOTARes( ... )
    return DOTA
end

function INITLUA:getLOLSkillRes( ... )
    return LOLSkill
end

function INITLUA:getDOTASkillRes( ... )
    return DOTASkill
end

function INITLUA:getBckResTotalExpByLv( Jinlv,lv )
    local color = 0
    for i=1,#PEIZHI.jinjie do
        if Jinlv <= PEIZHI.jinjie[i].num then
            color = i
            break
        end
    end
    if color == 0 then
        color = 6
    end
    local temp = nil
    for k,v in pairs(Barrack) do
            if v.Level == lv then
                temp = v
            end
        end
    if color == 1 then
        return temp.BAI_TotleExp
    elseif color == 2 then
        return temp.LV_TotleExp
    elseif color == 3 then
        return temp.LAN_TotleExp
    elseif color == 4 then
        return temp.ZI_TotleExp
    elseif color == 5 then
        return temp.CHENG_TotleExp
    elseif color == 6 then
        return temp.JIN_TotleExp
    elseif color == 7 then
        return temp.HONG_TotleExp
    end
    return 9999999
end

function INITLUA:getBckResNeedExpByLv( Jinlv,lv )
    local color = 0
    for i=1,#PEIZHI.jinjie do
        if Jinlv < PEIZHI.jinjie[i].num then
            color = i - 1
            break
        end
    end
    if color == 0 then
        color = 6
    end
    local temp = nil
    for k,v in pairs(Barrack) do
        if v.Level == lv+1 then
            temp = v
        end
    end
    if temp == nil then
        return 0
    end

    if color == 1 then
        return temp.BAI_NeedExp
    elseif color == 2 then
        return temp.LV_NeedExp
    elseif color == 3 then
        return temp.LAN_NeedExp
    elseif color == 4 then
        return temp.ZI_NeedExp
    elseif color == 5 then
        return temp.CHENG_NeedExp
    elseif color == 6 then
        return temp.JIN_NeedExp
    elseif color == 7 then
        return temp.HONG_NeedExp
    end
    return 9999999
end

function INITLUA:getYijianLv( Jinlv,lv , exppool)

    local need = 0
    for i=lv,PEIZHI.UPLVNUM do
        local nextNeed = need + INITLUA:getBckResNeedExpByLv( Jinlv,i )
        if exppool < nextNeed then
            return need
        end
        need = nextNeed
    end
    return need
end

function INITLUA:getActResByLv( lv )
    return Account[lv]
end

function INITLUA:getBuffByid( id )
    return BUFF[id]
end

function INITLUA:getUnitResByCamp( id )
    if 1 == id then
        return LOL
    else
        return DOTA
    end
end

function INITLUA:getEquipByid( id )
    return equip[id]
end

function INITLUA:getItemByid( id )
    return Item[id]
end

function INITLUA:getDOTARankRes( ... )
    return DOTARank
end

function INITLUA:initDOTARankResMap( ... )
    DOTARankResMap = {}
    for k,v in pairs(DOTARank) do
        if DOTARankResMap[v.ID] == nil then
            DOTARankResMap[v.ID] = {}
        end
        DOTARankResMap[v.ID][v.Quality_Lv] = v
    end
end

function INITLUA:getDOTAResFromMap( id, jinlv)
    return DOTARankResMap[id][jinlv]
end

function INITLUA:getLOLRankRes( ... )
    return LOLRank
end

function INITLUA:initLOLRankResMap( ... )
    LOLRankResMap = {}
    for k,v in pairs(LOLRank) do
        if LOLRankResMap[v.ID] == nil then
            LOLRankResMap[v.ID] = {}
        end
        LOLRankResMap[v.ID][v.Quality_Lv] = v
    end
end

function INITLUA:getLOLResFromMap( id, jinlv)
    return LOLRankResMap[id][jinlv]
end

function INITLUA:getDOTASTARRes( ... )
    return DOTASTAR
end

function INITLUA:initDOTAStarResMap( ... )
    DOTAStarResMap = {}
    for k,v in pairs(DOTASTAR) do
        if DOTAStarResMap[v.ID] == nil then
            DOTAStarResMap[v.ID] = {}
        end
        DOTAStarResMap[v.ID][v.Star_Lv] = v
    end
end

function INITLUA:getDOTAStarResFromMap( id, Star_Lv)
    return DOTAStarResMap[id][Star_Lv]
end

function INITLUA:getLOLSTARRes( ... )
    return LOLSTAR
end

function INITLUA:initLOLStarResMap( ... )
    LOLStarResMap = {}
    for k,v in pairs(LOLSTAR) do
        if LOLStarResMap[v.ID] == nil then
            LOLStarResMap[v.ID] = {}
        end
        LOLStarResMap[v.ID][v.Star_Lv] = v
    end
end

function INITLUA:getLOLStarResFromMap( id, Star_Lv)
    return LOLStarResMap[id][Star_Lv]
end

function INITLUA:getTaskRes( ... )
    return Task
end

function INITLUA:getTaskResById( Id )
    return Task[Id]
end

function INITLUA:initTaskRes( ... )
    TaskResMap = {}
    for k,v in pairs(Task) do
        if TaskResMap[v.TaskType] == nil then
            TaskResMap[v.TaskType] = {}
        end
        table.insert(TaskResMap[v.TaskType], v)
    end
end

function INITLUA:getStageRes( ... )
    return Stage
end

function INITLUA:getStageResById( Id )
    return Stage[Id]
end

function INITLUA:initStageResMap( ... )
    StageResMap = {}
    for k,v in pairs(Stage) do
        if StageResMap[v.StageType] == nil then
            StageResMap[v.StageType] = {}
        end
        table.insert(StageResMap[v.StageType], v)
    end
end

function INITLUA:getStageResMap( ... )
    return StageResMap
end

function INITLUA:getStageResMapByType( type )
    return StageResMap[type]
end

function INITLUA:getMonsterResById( Id )
    return Monster[Id]
end

function INITLUA:getMskillResResById( Id )
    return mskill[Id]
end

function INITLUA:getDropOutRes( ... )
    return dropout
end

function INITLUA:getDropListRes( ... )
    return droplist
end

function INITLUA:getShopListRes( ... )
    return shop
end

function INITLUA:getShopItemListRes( ... )
    return shopitem
end

function INITLUA:getPassiveResById( id )
    return Passive[id]
end

function INITLUA:getVIPTabById( lv )
    for k,v in pairs(VipExp) do
        if v.Level == lv then
            return v
        end
    end
    return nil
end

function INITLUA:getRaidsNumByTimes( times )
    for k,v in pairs(ExchangeX) do
        if v.ChangeToType == MM.EChangeToType.CHANGERTO_GoldFinger and v.Times == times then
            return v
        end
    end
    return nil
end

function INITLUA:getRankGift( ... )
    return rankgift
end

function INITLUA:getExchangeByLevel(level, changeToType)
    local maxID = 1093677105
    for k,v in pairs(ExchangeX) do
        if v.ChangeToType == changeToType then   
            if v.ID > maxID then
                maxID = v.ID
            end
            if v.Times == level then
                return ExchangeX[k]
            end
        end
    end
    return ExchangeX[maxID]
end

function INITLUA:getExchangeByType( desType )
    local result = {}
    for k,v in pairs(ExchangeX) do
        if v.ChangeToType == desType then   
            table.insert(result, v)   
        end
    end
    return result
end

function INITLUA:getRechargeRes( ... )
    return Recharge
end

function INITLUA:getVipInfoByLevel( lv )
    for k,v in pairs(VipExp) do
        if v.Level == lv then
            return v
        end
    end
end

function INITLUA:getVipExpNeed( exp )
    for i=1,#VipExp do
        if exp < VipExp[i].TotalExp then
            return VipExp[i].NeedExp, VipExp[i].NeedExp - VipExp[i].TotalExp + exp
        end
    end
    return 0, VipExp[#VipExp - 1].TotalExp
end

function INITLUA:getVipExpRes()
    return VipExp
end

function INITLUA:getActivtyRewardRes()
    return ActivtyReward
end

function INITLUA:getActivtyListRes()
    return ActivtyList
end

function INITLUA:getActivtyTypeRes()
    return ActivtyType
end

function INITLUA:getActivityTypeChildRes()
    return ActivityTypeChild
end

function INITLUA:getSundryRes()
    return sundry
end

function INITLUA:getLiBaoResById(id)
    return Libaolist[id]
end

function INITLUA:getLiBaoRes()
    return Libao
end

function INITLUA:initLiBaoResMap()
    LiBaoResMap = {}
    for k,v in pairs(Libao) do
        if LiBaoResMap[v.LibaoID] == nil then
            LiBaoResMap[v.LibaoID] = {}
        end
        table.insert(LiBaoResMap[v.LibaoID], v)
    end
end

function INITLUA:getLiBaoMapResById(id)
    return LiBaoResMap[id]
end

function INITLUA:getTipsRes()
    return Tips
end

function INITLUA:initExpDrawRes()
    local ExpDrawRes = ExpDraw
    local ExpDreaResInList = {}
    if ExpDrawRes then
        local table_insert = table.insert
        for k,v in pairs(ExpDrawRes) do
            table_insert(ExpDreaResInList, v)
        end
    end
    self._expDrawInfo = {count = #ExpDreaResInList, list = ExpDreaResInList }

end

function INITLUA:getExpDrawInfo()
    return self._expDrawInfo
end

function INITLUA:getShopMeleeItemRes( )
    return ShopMeleeItem
end

function INITLUA:getRewardMeleeRes()
    return Rewardmelee
end

function INITLUA:initRewardMeleeResMap()
    RewardMeleeResMap = {}
    for k,v in pairs(Rewardmelee) do
        if RewardMeleeResMap[v.melleerewardtype] == nil then
            RewardMeleeResMap[v.melleerewardtype] = {}
        end
        table.insert(RewardMeleeResMap[v.melleerewardtype], v)
    end
end

function INITLUA:getRewardMeleeResMapByType(type)
    return RewardMeleeResMap[type]
end

function INITLUA:getSkinByID(skinID)
    return skin[skinID]
end

return INITLUA