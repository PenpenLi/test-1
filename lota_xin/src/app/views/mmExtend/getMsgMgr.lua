g_msgCode = {}

g_msgCode["heroUpExp"] = function( t )
    cclog("heroUpExp back")
    -- mm.data.playerHero = t.playerHero or mm.data.playerHero
    mm.dispatchEvent("heroUpExp",t)
end

g_msgCode["heroUpXin"] = function( t )
    cclog("heroUpXin back")
    if t.type == 0 then
        mm.data.playerTaskProc.HeroXingUpCount = t.HeroXingUpCount
        mm.data.playerinfo = t.playerInfo or mm.data.playerinfo
        gameUtil.updateHeroById(t.playerHero)
    end
    mm.dispatchEvent("heroUpXin",t)
end


g_msgCode["killReward"] = function( t )
    cclog("killReward back")
    mm.data.playerinfo = t.playerinfo or {}
    if not t.playerinfo then
    	cclog("killReward back error")
    end
    mm.GuildScene:upPlayerLv()
    mm.dispatchEvent("killReward",t)
end

g_msgCode["meleeEnter"] = function( t )
    cclog("meleeEnter back")
    mm.dispatchEvent("meleeEnter",t)
end

g_msgCode["getMeleeRank"] = function( t )
    cclog("getMeleeRank back")
    mm.dispatchEvent("getMeleeRank",t)
end

g_msgCode["getHero"] = function( t )
    cclog("getHero back")
    mm.data.playerHero = t.playerHero or {}

    mm.dispatchEvent("getHero",t)
end

g_msgCode["getEquip"] = function( t )
    cclog("getEquip back")
    mm.data.playerEquip = t.playerEquip or {}

    mm.dispatchEvent("getEquip",t)
end

g_msgCode["getItem"] = function( t )
    cclog("getItem back")
    mm.data.playerItem = t.playerItem or {}

    mm.dispatchEvent("getItem",t)
end

g_msgCode["getHunshi"] = function( t )
    cclog("getHunshi back")
    mm.data.playerHunshi = t.playerHunshi or {}

    mm.dispatchEvent("getHunshi",t)
end

g_msgCode["getRank"] = function( t )
    cclog("getRank back")

    mm.dispatchEvent("getRank",t)
end

g_msgCode["heroUpPinJie"] = function( t )
    cclog("heroUpPinJie back")
    if t.type == 0 then
        gameUtil.updateHeroById(t.playerHero)
    end
    mm.dispatchEvent("heroUpPinJie",t)
end

g_msgCode["heroLevelUp"] = function( t )
    cclog("heroLevelUp back")
    if t.type == 0 then 
        gameUtil.updateHeroById(t.playerHero)
    end
    -- mm.data.playerHero =  or mm.data.playerHero
    mm.dispatchEvent("heroLevelUp",t)
end

g_msgCode["talk"] = function( t )
    cclog("talk back")
    
    mm.dispatchEvent("talk",t)
end

g_msgCode["guaJiReward"] = function( t )
    cclog("guaJiReward back")
    if t.type == 1 then
    	cclog("gua ji time is not enough")
        mm.data.playerExtra = t.playerExtra or {}
    else
        mm.data.playerEquip = t.playerEquip or {}
        mm.data.playerItem = t.playerItem or {}
        mm.data.playerHunshi = t.playerHunshi or {}
        mm.data.guajiTime = t.guajiTime or 0
        mm.data.guajiWuPin = t.guajiWuPin or {}
        mm.data.playerinfo = t.playerinfo or {}
        mm.data.playerExtra = t.playerExtra or {}
        mm.data.addGold = t.addGold or 0
        mm.data.addExp = t.addExp or 0
        mm.data.addPoolExp = t.addPoolExp or 0
        mm.data.dropTab = t.dropTab
        mm.data.noReadNum = t.noReadNum
    end
    
    mm.dispatchEvent("guaJiReward",t)
end

g_msgCode["fiveRefreshNotify"] = function( t )
    cclog("fiveRefreshNotify back")
    
    mm.dispatchEvent("fiveRefreshNotify",t)
end

g_msgCode["getTaskInfo"] = function( t )
    cclog("getTaskInfo back")
    
    mm.data.playerStage = t.playerStage
    mm.dispatchEvent("getTaskInfo",t)
end

g_msgCode["getTaskReward"] = function( t )
    cclog("getTaskReward back")
    
    mm.dispatchEvent("getTaskReward",t)
    
end

g_msgCode["getStoreInfo"] = function( t )
    cclog("getStoreInfo back")
    
    mm.data.playerinfo = t.playerinfo or mm.data.playerinfo
    mm.dispatchEvent("getStoreInfo",t)
end


g_msgCode["refreshStoreInfo"] = function( t )
    cclog("refreshStoreInfo back")
    
    mm.dispatchEvent("refreshStoreInfo",t)
end

g_msgCode["skillUp"] = function( t )
    cclog("skillUp back   ")
    if t.type == 0 then
        gameUtil.updateHeroById(t.playerHero)
    end
    -- mm.data.playerHero = t.playerHero or mm.data.playerHero
    mm.data.playerExtra.skillNum = t.skillNum or mm.data.playerExtra.skillNum
    mm.data.playerinfo.gold = t.gold or mm.data.playerinfo.gold
    mm.data.time.skillTime = t.time

    mm.dispatchEvent("skillUp",t)
end

g_msgCode["saveFormation"] = function( t )
    cclog("saveFormation back")
    mm.data.playerFormation = t.playerFormation or {}
    print(" saveFormation   ")
    print(" saveFormation   "..  json.encode(t))
    print(" saveFormation   ")
    print(" saveFormation    "..  json.encode(mm.data.playerFormation))
    print(" saveFormation "..  json.encode(t.playerFormation))
    mm.data.playerExtra.pkTimes = t.pkTimes or mm.data.playerExtra.pkTimes
    mm.dispatchEvent("saveFormation",t)
end


g_msgCode["Raids"] = function( t )
    cclog("Raids back   "..t.type)

    if t.type ~= 0 then
        gameUtil.CCLOGMoGameRet( t.type )
        return
    end
 
    mm.data.playerinfo = t.playerinfo
    mm.data.playerEquip = t.playerEquip
    mm.data.playerExtra = t.playerExtra
    mm.data.playerHunshi = t.playerHunshi or mm.data.playerHunshi
    mm.data.guajiTime = t.guajiTime
    mm.data.RaidsGuajiWuPin = t.guajiWuPin
    mm.data.RaidsAddPoolExp = t.addPoolExp
    mm.data.RaidsAddGold = t.addGold
    mm.data.RaidsAddExp = t.addExp
    mm.data.RaidsDropTab = t.dropTab
    
    mm.dispatchEvent("Raids",t)
end

g_msgCode["getPKEnterData"] = function( t )
    cclog("getPKEnterData back")
    mm.data.playerExtra.pkTimes = t.pkCount
    mm.data.time.pkTime = t.time
    mm.dispatchEvent("getPKEnterData",t)
end

g_msgCode["mailProcess"] = function( t )
    cclog("mailProcess back")
    
    mm.data.playerinfo = t.playerinfo or mm.data.playerinfo
    mm.data.playerExtra = t.playerExtra or mm.data.playerExtra
    gameUtil.refreshData(t.dropTab)
    
    mm.dispatchEvent("mailProcess",t)
end

g_msgCode["getRandomName"] = function( t )
    cclog("getRandomName back")
    
    mm.dispatchEvent("getRandomName",t)
end

g_msgCode["getMailNumWithoutRead"] = function( t )
    cclog("getMailNumWithoutRead back")
    
    mm.dispatchEvent("getMailNumWithoutRead",t)
end

g_msgCode["readMail"] = function( t )
    cclog("readMail back")
    
    mm.dispatchEvent("readMail",t)
end

g_msgCode["heroUpequip"] = function( t )
    cclog("heroUpequip back")
    if t.type == 0 then
        gameUtil.updateHeroById(t.playerHero)
    end
    mm.dispatchEvent("heroUpequip",t)
end

g_msgCode["buySomeThing"] = function( t )
    cclog("buySomeThing back")
    mm.data.playerinfo = t.playerinfo or mm.data.playerinfo
    mm.data.playerEquip = t.playerEquip or mm.data.playerEquip
    -- mm.data.playerHunshi = t.playerHunshi or mm.data.playerHunshi
    -- mm.data.playerItem = t.playerItem or mm.data.playerItem
    mm.data.playerExtra = t.playerExtra or mm.data.playerExtra
    gameUtil.refreshData(t.dropTab)
    gameUtil.updateStageExtra(t.stageExtra)

    mm.data.playerTaskProc.EquipBuyCount = mm.data.playerExtra.EquipBuyCount
    game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshMainUI"})
    mm.dispatchEvent("buySomeThing",t)
end

g_msgCode["eqHeChen"] = function( t )
    cclog("eqHeChen back")
    
    mm.dispatchEvent("eqHeChen",t)
end

g_msgCode["heroHeChen"] = function( t )
    cclog("heroHeChen back")
    
    mm.data.playerinfo = t.playerInfo or mm.data.playerinfo
    mm.dispatchEvent("heroHeChen",t)
end

g_msgCode["rankUp"] = function( t )
    cclog("rankUp back")
    if t.type == 0 then
        mm.data.playerinfo = t.playerinfo or mm.data.playerinfo
        mm.data.curDuanWei = t.curRank
    end 
    mm.dispatchEvent("rankUp",t)
    
end

g_msgCode["getRankList"] = function( t )
    cclog("getRankList back")
    
    mm.dispatchEvent("getRankList",t)
    
end

g_msgCode["getBuyRecordInfo"] = function( t )
    cclog("getBuyRecordInfo back")
    
    mm.dispatchEvent("getBuyRecordInfo",t)
    
end

g_msgCode["getActivityInfo"] = function( t )
    cclog("getActivityInfo back")
    
    mm.dispatchEvent("getActivityInfo",t)
    
end

g_msgCode["rewardActivity"] = function( t )
    cclog("rewardActivity back")
    gameUtil.refreshData(t.dropTab)

    mm.dispatchEvent("rewardActivity",t)
    
end

g_msgCode["buyFund"] = function( t )
    cclog("buyFund back")
    
    mm.dispatchEvent("buyFund",t)
    
end

g_msgCode["getOrderInfo"] = function( t )
    cclog("getOrderInfo back")
    mm.dispatchEvent("getOrderInfo",t)
end

g_msgCode["useItem"] = function( t )
    cclog("useItem back")
    mm.data.playerinfo = t.playerInfo or mm.data.playerinfo
    mm.data.playerExtra = t.playerExtra or mm.data.playerExtra
    
    -- 将dropTab里的物品更新到客户端
    gameUtil.refreshData(t.dropTab)
    
    mm.dispatchEvent("useItem",t)
end

g_msgCode["readActivity"] = function( t )
    cclog("readActivity back")
    mm.dispatchEvent("readActivity",t)
end

g_msgCode["refreshEvent"] = function( t )
    cclog("refreshEvent back")
    mm.dispatchEvent("refreshEvent",t)
end

g_msgCode["luckdraw"] = function( t )
    mm.dispatchEvent("luckdraw",t)
end

g_msgCode["getMeleeList"] = function( t )
    cclog("getMeleeList back")
    mm.dispatchEvent("getMeleeList",t)
end

g_msgCode["killMelee"] = function( t )
    cclog("killMelee back")
    mm.dispatchEvent("killMelee",t)
end

g_msgCode["fightResultMelee"] = function( t )
    cclog("fightResultMelee back")
    mm.dispatchEvent("fightResultMelee",t)
end

g_msgCode["getMeleeStore"] = function( t )
    mm.dispatchEvent("getMeleeStore",t)
end

g_msgCode["buyMeleeStoreItem"] = function( t )
    mm.dispatchEvent("buyMeleeStoreItem",t)
end

g_msgCode["blessMelee"] = function( t ) 
    mm.dispatchEvent("blessMelee",t)
end

g_msgCode["preciousLvUp"] = function( t )
    mm.dispatchEvent("preciousLvUp",t)
end

g_msgCode["skinOn"] = function( t )
    mm.dispatchEvent("skinOn",t)
end

g_msgCode["joinMelee"] = function( t )
    mm.dispatchEvent("joinMelee",t)
end

g_msgCode["getFinalResultData"] = function( t )
    mm.dispatchEvent("getFinalResultData",t)
end

g_msgCode["saveTheWorld"] = function( t )
    mm.dispatchEvent("saveTheWorld",t)
end

g_msgCode["getPlayerInfo"] = function( t )
    mm.dispatchEvent("getPlayerInfo",t)
end

g_msgCode["getZhanliList"] = function( t )
    mm.dispatchEvent("getZhanliList",t)
end

g_msgCode["getTibuZhanliList"] = function( t )
    mm.dispatchEvent("getTibuZhanliList",t)
end

g_msgCode["getTianTiList"] = function( t )
    mm.dispatchEvent("getTianTiList",t)
end

g_msgCode["getHeroZhanliList"] = function( t )
    mm.dispatchEvent("getHeroZhanliList",t)
end

g_msgCode["composeEquip"] = function( t )
    if t.type == 3 and t.playerHero then
        gameUtil.updateHeroById(t.playerHero)
    end
    mm.dispatchEvent("composeEquip",t)
end

g_msgCode["heroUpequipAll"] = function( t )
    if t.type == 0 then
        gameUtil.updateHeroById(t.playerHero)
    end
    mm.dispatchEvent("heroUpequipAll",t)
end

g_msgCode["saodang"] = function( t )
    cclog("saodang back   "..t.type)

    if t.type ~= 0 then
        gameUtil.CCLOGMoGameRet( t.type )
        return
    end
 
    mm.data.playerinfo = t.playerinfo
    mm.data.playerEquip = t.playerEquip
    mm.data.playerHunshi = t.playerHunshi
    mm.data.playerItem = t.playerItem

    mm.data.saodangDrop = t.dropTab
    mm.data.saodangTimes = t.times
    mm.data.saodangTab = t
    
    mm.dispatchEvent("saodang",t)
end



g_msgCode["getTianTiInfo"] = function( t )
    cclog("getTianTiInfo back   ")

    if t.type and t.type ~= 0 then
        gameUtil.CCLOGMoGameRet( t.type )
        return
    end
    
    mm.dispatchEvent("getTianTiInfo",t)
end

g_msgCode["challengeTianTi"] = function( t )
    cclog("challengeTianTi back   ")
    mm.dispatchEvent("challengeTianTi",t)
end

g_msgCode["snipe"] = function( t )
    cclog("snipe back   ")

    if t.type and t.type ~= 0 then
        gameUtil.CCLOGMoGameRet( t.type )
        return
    elseif t.type == 0 then
        cclog("snipe back  pkValue "..t.pkValue)
        mm.data.playerinfo.pkValue = t.pkValue
        mm.data.playerExtra.pkTimes = t.pkTimes
    end
    
    mm.dispatchEvent("snipe",t)
end