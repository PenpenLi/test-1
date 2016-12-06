
local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")

gameUtil = gameUtil or {} 
local gameUtil = gameUtil
local util = util
local util_isFileExist = util.isFileExist

local cclog = cclog
local ccui =ccui
local string = string
local string_format = string.format
local cc_Sprite = cc.Sprite
local ccui_ImageView = ccui.ImageView

-- 资源头文件：
-- require("src.app.models.initLua")
local MM = MM
-- local MM_EQuality = MM.EQuality
-- local GoldQuality = MM_EQuality.GoldQuality
-- local OrangeQuality = MM_EQuality.OrangeQuality

-- 文件相关
function _file_exists(path)
    if not path or #path < 1 then
        return false
    end

    if util_isFileExist(path) then
        return true
    end

    return false
end

-- 金光：
local ccs = ccs
local function createJinGuangFrame(sizeIn)
    local item_play = gameUtil.createSkeAnmion( {name = "wpk", scale = 0.7} )
    --local size = iconBg:getContentSize()
    item_play:setPosition(sizeIn.width*0.5, sizeIn.height*0.5)
    -- item_play:setScale(1.05)
    item_play:setAnimation(0, "stand", true)
    -- local ani = item_play:getAnimation()
    -- if ani then
    --     ani:playWithIndex(0)
    --     return item_play
    -- end
end

-- spine 动画文件格式
local spineJosnFormat = "%s.json"
local spineatlasFormat = "%s.atlas"
local spineskelFormat = "%s.skel"
local function getSpineRes(path)
    return string_format(spineJosnFormat, path), string_format(spineatlasFormat, path), string_format(spineskelFormat, path)
end

-- icon 相关
local iconFormat = "%s.png"
local function createImage(path, isFullpath, isSpri, altFullPath)
    local node = nil
    if isSpri then
        node = cc_Sprite:create()
    else
        node = ccui_ImageView:create()
    end

    local fullpath = path
    if not isFullpath then
        fullpath = string_format(iconFormat, path)
    end

    if not _file_exists(fullpath) then
        fullpath = altFullPath
    end

    if _file_exists(fullpath) then
        if isSpri then
            node:setTexture(fullpath)
        else
            node:loadTexture(fullpath)
        end        
    end

    return node
end

-- icon 上的level
local iconLevelCsbSrc = "lvText.csb"
local function createIconLevelText(num)
    local lvTextNode = cc.CSLoader:createNode(iconLevelCsbSrc)
    lvTextNode:setName("TextLvNode")
    local node = lvTextNode:getChildByName("Text_lv")
    if node then
        node:setString(""..num)
    end
    return lvTextNode
end

function gameUtil.updateHeroById(heroInfo)
    for k,v in pairs(mm.data.playerHero) do
        if v.id == heroInfo.id then
            mm.data.playerHero[k] = heroInfo
            break
        end
    end
end

----------------------------------------------------------------------------------------
--查看文件是否存在
function gameUtil.file_exists(path)
    return _file_exists(path)
end

--查看文件是否存在
function gameUtil.playEffect(filename, isLoop)
    mm.effectOpen = cc.UserDefault:getInstance():getIntegerForKey("effectOpen")
    if mm.effectOpen == 1 then
        return
    end
    local path = filename..".mp3"
    if util.isFileExist(path) then
        AudioEngine.playEffect(path,isLoop)
    else
        return false
    end
end

function gameUtil.playUIEffect( filename )
    gameUtil.playEffect("res/sounds/UI/"..filename, false)
end

function gameUtil.getHeroTab( heroid )
    local heroid = heroid
    return petTable[heroid]
end

function gameUtil.isHasEquip( id )
    if mm.data.playerEquip == nil or #mm.data.playerEquip == 0 then
        return false
    end
    for k,v in pairs(mm.data.playerEquip) do
        if v.id == id and v.num > 0 then
            return true
        end
    end
    return false
end

function gameUtil.isNeedHeCheng( eqId )
    local tab = INITLUA:getEquipByid( eqId )
    for i=1,4 do
        local zujian = "eq_zujian0"..i
        if tab[zujian] ~= 0 then
            return true
        end
    end
    return false
end

function gameUtil.getHeroSkillTab( skillId )
    local tab = INITLUA:getMskillResResById( skillId )
    if tab then
        return tab 
    end

    local tab = INITLUA:getLOLSkillRes()[skillId]
    if tab then
        return tab 
    else
        return INITLUA:getDOTASkillRes()[skillId]
    end
end

--获得主角等级
function gameUtil.getPlayerLv(exp)
    for i=1,#Account do
        if exp < INITLUA:getActResByLv( i ).TotleExp then
            return i
        end
    end
    return #Account
end

function gameUtil.getAccountAddExpPoolMaxExp(exp)
    local lv = gameUtil.getPlayerLv(exp)
    return Account[lv].AddExpPoolMax
end

function gameUtil.getAccountAddExpPoolMaxLv(lv)
    return Account[lv].AddExpPoolMax
end

--获得武将等级
function gameUtil.getHeroLv(exp,Jinlv)
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
    if color == 1 then
        for k,v in pairs(Barrack) do
            if exp < v.BAI_TotleExp then
                return v.Level - 1
            end
        end
    elseif color == 2 then
        for k,v in pairs(Barrack) do
            if exp < v.LV_TotleExp then
                return v.Level - 1
            end
        end
    elseif color == 3 then
        for k,v in pairs(Barrack) do
            if exp < v.LAN_TotleExp then
                return v.Level - 1
            end
        end
    elseif color == 4 then
        for k,v in pairs(Barrack) do
            if exp < v.ZI_TotleExp then
                return v.Level - 1
            end
        end
    elseif color == 5 then
        for k,v in pairs(Barrack) do
            if exp < v.CHENG_TotleExp then
                return v.Level - 1
            end
        end
    elseif color == 6 then
        for k,v in pairs(Barrack) do
            if exp < v.JIN_TotleExp then
                return v.Level - 1
            end
        end
    elseif color == 7 then
        for k,v in pairs(Barrack) do
            if exp < v.HONG_TotleExp then
                return v.Level - 1
            end
        end
    end
    return 25
end

--[[
function gameUtil.getHeroCurExp(exp)
    local lv = gameUtil.getHeroLv(exp)
    if lv == 1 then
        return exp
    else
        return exp - INITLUA:getBckResByLv( lv - 1 ).TotleExp
    end
end
--]]

--获取英雄icon图标
function gameUtil.getHeroIcon(heroid)
    local srcPath = gameUtil.getHeroTab( heroid ).headSrc..".png"
    if gameUtil.file_exists(srcPath) and #srcPath > 0 then
        return srcPath
    else
        return "res/icon/head/touxiang.png"
    end
end

--获取装备icon图标
function gameUtil.getEquipIconRes(equipId)
    local srcPath = INITLUA:getEquipByid( equipId ).eq_res..".png"
    if gameUtil.file_exists(srcPath) and #srcPath > 0 then
        return srcPath
    else
        return "res/icon/head/touxiang.png"
    end
end

--获取装备品质icon图标
function gameUtil.getEquipPinRes(pin)
    local pin = pin
    local srcPath = ""
    if pin == MM.EQuality.NoColor then
        
    else
        srcPath = "res/icon/jiemian/icon_pinjie"..pin..".png"
    end

    if gameUtil.file_exists(srcPath) and #srcPath > 0 then
        return srcPath
    else
        return ""
    end
end          

--获取装备碎片品质icon图标
function gameUtil.getEquipSuipianPinRes(pin)
    local pin = pin
    local srcPath = ""
    if pin == MM.EQuality.NoColor then
        srcPath = "res/UI/jm_lvsuipian.png"
    elseif pin == MM.EQuality.WhiteQuality then
        srcPath = "res/UI/jm_lvsuipian.png"
    elseif pin == MM.EQuality.GreenQuality then
        srcPath = "res/UI/jm_lvsuipian.png"
    elseif pin == MM.EQuality.BlueQuality then
        srcPath = "res/UI/jm_lansuipian.png"
    elseif pin == MM.EQuality.PurpleQuality then
        srcPath = "res/UI/jm_zisuipian.png"
    elseif pin == MM.EQuality.OrangeQuality then
        srcPath = "res/UI/jm_chengsuipian.png"
    elseif pin == MM.EQuality.GoldQuality then
        srcPath = "res/UI/jm_jinsuipian.png"
    elseif pin == MM.EQuality.DarkGoldQuality then
        srcPath = "res/UI/jm_jinsuipian.png"
    elseif pin == MM.EQuality.SevenColorQuality then
        srcPath = "res/UI/jm_jinsuipian.png"
    end

    if gameUtil.file_exists(srcPath) and #srcPath > 0 then
        return srcPath
    else
        return ""
    end
end

--获取道具icon图标
function gameUtil.getItemIconRes(itemId)
    local srcPath = nil
    local curRes = INITLUA:getItemByid( itemId )
    if curRes then
        srcPath = curRes.item_res..".png"
    end
    if gameUtil.file_exists(srcPath) then
        return srcPath
    else
        return "res/icon/head/touxiang.png"
    end
end

--获取默认icon图标
local defaultIconPath = "res/icon/head/touxiang.png"
function gameUtil.getDefaultIconPath()
    return defaultIconPath
end

--获取技能icon图标
function gameUtil.getSkillIconRes(skillId)
    local srcPath = gameUtil.getHeroSkillTab( skillId ).sicon..".png"
    if gameUtil.file_exists(srcPath) and #srcPath > 0 then
        return srcPath
    else
        return "res/icon/head/touxiang.png"
    end
end

--获取至宝icon图标
local defaultPreciousFrameSrc = "res/icon/jiemian/icon_pinjie6.png"
local peciousFrameInColorFormat = "res/icon/jiemian/icon_pinjie%s.png" -- 1~6
local headStarSrcFormat = "res/icon/jiemian/jm_herojinjie%s.png"
local math_ceil = math.ceil
local math_fmod = math.fmod
local cc_Node = cc.Node
local table_insert = table.insert
function gameUtil.createPreciousIcon(pId, lv, order, preOne)
    -- if preOne then
    --     gameUtil.updatePreciousIcon(pId, lv, order, preOne)
    --     return preOne
    -- end

    local curRes = INITLUA:getResWithId("Precious", pId)
    if not curRes then
        return
    end
    if not lv then
        lv = 1
    end
    if not order then
        order = 6
    end
    local orderOriginal = order

    order = math_ceil(order/2)
    order = order + 1
    local icon = preOne
    if not icon then
        icon = createImage(curRes.icon, false) -- (path, isFullpath, isSpri, altFullPath)
    end

    local frameSrc = string_format(peciousFrameInColorFormat, order)
    local frame = icon.frame
    if frame then
        frame:removeFromParent()
        icon.frame = nil
    end
    frame = createImage(frameSrc, true, false, defaultPreciousFrameSrc)
    local curSize = icon:getContentSize()
    frame:setContentSize(curSize)
    frame:setPosition(curSize.width*0.5,curSize.height*0.5)
    icon.frame = frame

    -- 等级
    local textNode = icon.textNode
    if textNode then
        textNode:removeFromParent()
        icon.textNode = nil
    end
    textNode = createIconLevelText(lv)
    textNode:setPosition(15, 30)
    icon.textNode = textNode

    -- 头上星星个数
    local texSrc = string_format(headStarSrcFormat,order)
    local count = math_fmod(orderOriginal, 2)
    if count == 0 and orderOriginal ~= 0 then
        count = 2
    end

    local headStars = icon.headStars
    if headStars then
        for i,v in ipairs(headStars) do
            v:removeFromParent()
        end
    end
    headStars = {}
    icon.headStars = headStars
    for j=1, count do
        local jin_flag = ccui_ImageView:create()
        if _file_exists(texSrc) then
            jin_flag:loadTexture(texSrc)
        end
        icon:addChild(jin_flag,3)
        jin_flag:setPosition(curSize.width*j/(count+1), curSize.height)
        table_insert(headStars, jin_flag)
    end

    icon:addChild(frame)
    icon:addChild(textNode)
    return icon
end

function gameUtil.updatePreciousIcon(pId, lv, order, preOne)

end

local altHeadIconSrc = "res/UI/bt_touxiangsuo.png"
function gameUtil.createSkinIcon1(skinId)
    local skinResAll = INITLUA:getRes("skin")
    local curSkinRes = skinResAll[skinId]
    local src = curSkinRes.Icon

    local icon = createImage(src,false,false,altHeadIconSrc)
    local frame = createImage(defaultPreciousFrameSrc, true)
    local curSize = frame:getContentSize()
    local curIconSize = icon:getContentSize()
    local curIconSize_width = curIconSize.width
    if curIconSize_width > 0 then
        icon:setScale(curSize.width / curIconSize.width)
    end
    icon:setPosition(curSize.width*0.5,curSize.height*0.5)
    frame:addChild(icon) frame.c1 = icon
    return frame
end

-- 选择框
local selectorBgSrc = "res/UI/jm_icon.png"
-- local selectorFrameSrc = "res/Effect/uiEffect/kzbts/kzbts.ExportJson"
local selectorCrossSrc = "res/UI/icon_jiahao_normal.png"
function gameUtil.createSelector()
    local iconBg = createImage(selectorBgSrc,true)

    -- gameUtil.addArmatureFile(selectorFrameSrc)
    -- local up_play = ccs.Armature:create("kzbts")  
    -- local size = iconBg:getContentSize()
    -- local x = size.width*0.5
    -- local y = size.height*0.5
    -- up_play:setPosition(x, y)
    -- up_play:setScale(3.5)
    -- up_play:getAnimation():playWithIndex(0)
    -- iconBg:addChild(up_play, 1)

    local up_play = gameUtil.createSkeAnmion( {name = "kzbts",scale = 1} )
    up_play:setAnimation(0, "stand", true)
    local size = iconBg:getContentSize()
    local x = size.width*0.5
    local y = size.height*0.5
    up_play:setPosition(x, y)
    iconBg:addChild(up_play, 1)

    local cross = createImage(selectorCrossSrc,true)
    cross:setPosition(x, y)
    iconBg:addChild(cross, 2)

    local list = {up_play, cross}
    iconBg.childList = list
    return iconBg
end

function gameUtil.setSelectorVisible(selector,isVisiable)
    local list = selector.childList
    if list then
        for i,v in ipairs(list) do
            v:setVisible(isVisiable)
        end
    end
end

function gameUtil.createImage(srcFull, isSpri)
    return createImage(srcFull,true, isSpri)
end

function gameUtil.getHunshiNumByid( id )
    if nil == mm.data.playerHunshi then
        return 0
    end
    
    for i=1,#mm.data.playerHunshi do
        if mm.data.playerHunshi[i].id == id then
            return mm.data.playerHunshi[i].num
        end
    end
    return 0
end


function gameUtil.getHeroEqByIndex( tab, index )
    if tab == nil then
        return nil
    end

    for k,v in pairs(tab) do
        if v.eqIndex == index then
            return v
        end
    end

    return nil
end

function gameUtil.getEquipId( heroId, jinLv )
    local camp = gameUtil.getHeroTab( heroId ).Nation
    local tab = nil
    if camp == 1 then --dota
        tab = INITLUA:getLOLRankRes()
    elseif camp == 2 then --lol
        tab = INITLUA:getDOTARankRes()
    else
        
    end
    for k,v in pairs(tab) do
        if v.ID == heroId and v.Quality_Lv == jinLv then
            return v
        end
    end
    return nil

end

function gameUtil.getStarTab( heroId, xinLv )
    local camp = gameUtil.getHeroTab( heroId ).Nation
    local tab = nil
    if camp == 1 then --dota
        tab = INITLUA:getLOLSTARRes()
    elseif camp == 2 then --lol
        tab = INITLUA:getDOTASTARRes()
    end
    for k,v in pairs(tab) do
        if v.ID == heroId and v.Star_Lv == xinLv then
            return v
        end
    end

    return nil

end

--根据卡牌id获取对应品质颜色
function gameUtil.getColor(jinLv)
    local quality = #PEIZHI.jinjie
    for i=1,#PEIZHI.jinjie do
        if jinLv < PEIZHI.jinjie[i].num then
            quality = i - 1
            break
        end
    end
    
    local color = {
        cc.c4b(255,255,255,255),
        cc.c4b(22, 206, 22,255),
        cc.c4b(16, 146, 252,255),
        cc.c4b(240,0,255,255),
        cc.c4b(255,162,0,255),
        cc.c4b(246,208,0,255),
        cc.c4b(246,208,0,255),
    }
    return color[quality], jinLv - PEIZHI.jinjie[quality].num, quality
end

--根据卡牌id获取对应品质框
function gameUtil.getKuang(jinLv)
    local quality = 1
    for i=1,#PEIZHI.jinjie do
        if jinLv < PEIZHI.jinjie[i].num then
            quality = i - 1
            break
        end
    end
    
    local kuang = {
        "res/icon/jiemian/jm_hero_bai.png",
        "res/icon/jiemian/jm_hero_lv.png",
        "res/icon/jiemian/jm_hero_lan.png",
        "res/icon/jiemian/jm_hero_zi.png",
        "res/icon/jiemian/jm_hero_cheng.png",
        "res/icon/jiemian/jm_hero_jin.png",
    }
    return kuang[quality]
end


--[[
    面板属性 = （Unit基础属性 + Rank品质增量属性 * Rank品质增量系数 +  Star星级增量属性 * Star星级增量系数）*
        （1 + Rank等级增量系数*（当前等级-1））+ 装备属性
]]
--面板攻击
function gameUtil.heroMBAck( t )
    local heroid = t.heroid or t.id
    local lv = t.lv
    local xinlv = t.xinlv
    local jinlv = t.jinlv
    local eqTab = t.eqTab
    local skinInfo = t.skinInfo

    local heroTab = gameUtil.getHeroTab( heroid )
    local base = heroTab.Attack 
   
    local jinBase = gameUtil.getEquipId( heroid, jinlv ).Quality_Attack
    local jinXishu = gameUtil.getEquipId( heroid, jinlv ).QUp_Attack

    local xinBase = gameUtil.getStarTab( heroid, xinlv ).Star_Attack
    local xinXishu = gameUtil.getStarTab( heroid, xinlv ).SUp_Attack

    local lvXishu = gameUtil.getEquipId( heroid, jinlv ).Lv_Attack

    local mb01 = (base + jinBase * jinXishu + xinBase * xinXishu) * (1 + lvXishu * (lv - 1))

    if skinInfo then
        local skinres = skin[gameUtil.getSkinId(heroid, skinInfo.id)]
        if skinres then
            local value = skinres["eq_gongji"]

            mb01 = mb01 + value
        end
    end

    if eqTab and #eqTab > 0 then
        for i=1,#eqTab do
            local eqId = eqTab[i].eqId
            local ack = INITLUA:getEquipByid(eqId)["eq_gongji"]
            mb01 = mb01 + ack
        end
    end

    local preciousInfo = t.preciousInfo or {}
    local addAck = 0
    -- for k,v in pairs(preciousInfo) do
    --     local index = v.id
    --     local preciousId = heroTab["PreciousAssetIds"][index]
    --     local order = v.order
    --     local lv = v.lv
    --     local eq_gongji = Precious[preciousId].eq_gongji
    --     if eq_gongji > 0 then
    --         local PreciousTab = Precious[preciousId]
    --         local levelUpTemplateId = PreciousTab.levelUpTemplateId
    --         local orderUpExtra = PreciousTab.orderUpExtra
    --         --初始值+等级成长值+阶数*进阶值
    --         local allLv = gameUtil.getPreciousLevelAll(order, lv)
    --         local add = eq_gongji
    --         for i=1,allLv do
    --             add = add + PreciousUp[i]["t"..levelUpTemplateId]
    --         end
    --         addAck = addAck + add
    --     end
    -- end
    mb01 = mb01 + addAck

    return mb01
end

--面板血量
function gameUtil.hpMBAck( t )
    local heroid = t.heroid or t.id
    local lv = t.lv
    local xinlv = t.xinlv
    local jinlv = t.jinlv
    local eqTab = t.eqTab
    local skinInfo = t.skinInfo

    local heroTab = gameUtil.getHeroTab( heroid )
    local base = heroTab.HP 
    local jinBase = gameUtil.getEquipId( heroid, jinlv ).Quality_HP
    local jinXishu = gameUtil.getEquipId( heroid, jinlv ).QUp_HP

    local xinBase = gameUtil.getStarTab( heroid, xinlv ).Star_HP
    local xinXishu = gameUtil.getStarTab( heroid, xinlv ).SUp_HP

    local lvXishu = gameUtil.getEquipId( heroid, jinlv ).Lv_HP

    local mb01 = (base + jinBase * jinXishu + xinBase * xinXishu) * (1 + lvXishu * (lv - 1))


    if skinInfo then
        local skinres = skin[gameUtil.getSkinId(heroid, skinInfo.id)]
        if skinres then
            local value = skinres["eq_shenming"]
            mb01 = mb01 + value
        end
    end

    if eqTab and #eqTab > 0 then
        for i=1,#eqTab do
            local eqId = eqTab[i].eqId
            local ack = INITLUA:getEquipByid(eqId)["eq_shenming"]
            mb01 = mb01 + ack
        end
    end

    local preciousInfo = t.preciousInfo or {}
    local addHp = 0
    -- for k,v in pairs(preciousInfo) do
    --     local index = v.id
    --     local preciousId = heroTab["PreciousAssetIds"][index]
    --     local order = v.order
    --     local lv = v.lv
    --     local eq_shenming = Precious[preciousId].eq_shenming
    --     if eq_shenming > 0 then
    --         local PreciousTab = Precious[preciousId]
    --         local levelUpTemplateId = PreciousTab.levelUpTemplateId
    --         local orderUpExtra = PreciousTab.orderUpExtra
    --         --初始值+等级成长值+阶数*进阶值
    --         local allLv = gameUtil.getPreciousLevelAll(order, lv)
    --         local add = eq_shenming
    --         for i=1,allLv do
    --             add = add + PreciousUp[i]["t"..levelUpTemplateId]
    --         end
    --         addHp = addHp + add
    --     end
    -- end
    mb01 = mb01 + addHp

    return mb01
end

--面板速度
function gameUtil.speedMBAck( t )
    local heroid = t.heroid or t.id
    local lv = t.lv
    local xinlv = t.xinlv
    local jinlv = t.jinlv
    local eqTab = t.eqTab
    local skinInfo = t.skinInfo

    local heroTab = gameUtil.getHeroTab( heroid )
    local base = heroTab.Speed 
    local jinBase = gameUtil.getEquipId( heroid, jinlv ).Quality_Speed
    local jinXishu = gameUtil.getEquipId( heroid, jinlv ).QUp_Speed

    local xinBase = gameUtil.getStarTab( heroid, xinlv ).Star_Speed
    local xinXishu = gameUtil.getStarTab( heroid, xinlv ).SUp_Speed

    local lvXishu = gameUtil.getEquipId( heroid, jinlv ).Lv_Speed

    local mb01 = (base + jinBase * jinXishu + xinBase * xinXishu) * (1 + lvXishu * (lv - 1))


    if skinInfo then
        local skinres = skin[gameUtil.getSkinId(heroid, skinInfo.id)]
        if skinres then
            local value = skinres["eq_sudu"]
            mb01 = mb01 + value
        end
    end

    if eqTab and #eqTab > 0 then
        for i=1,#eqTab do
            local eqId = eqTab[i].eqId
            local ack = INITLUA:getEquipByid(eqId)["eq_sudu"]
            mb01 = mb01 + ack
        end
    end

    local preciousInfo = t.preciousInfo or {}
    local addSudu = 0
    -- for k,v in pairs(preciousInfo) do
    --     local index = v.id
    --     local preciousId = heroTab["PreciousAssetIds"][index]
    --     local order = v.order
    --     local lv = v.lv
    --     local eq_sudu = Precious[preciousId].eq_sudu
    --     if eq_sudu > 0 then
    --         local PreciousTab = Precious[preciousId]
    --         local levelUpTemplateId = PreciousTab.levelUpTemplateId
    --         local orderUpExtra = PreciousTab.orderUpExtra
    --         --初始值+等级成长值+阶数*进阶值
    --         local allLv = gameUtil.getPreciousLevelAll(order, lv)
    --         local add = eq_sudu
    --         for i=1,allLv do
    --             add = add + PreciousUp[i]["t"..levelUpTemplateId]
    --         end
    --         addSudu = addSudu + add
    --     end
    -- end
    mb01 = mb01 + addSudu

    return mb01
end

--面板闪避
function gameUtil.dodgeMBAck( t )
    local heroid = t.heroid or t.id
    local lv = t.lv
    local xinlv = t.xinlv
    local jinlv = t.jinlv
    local eqTab = t.eqTab
    local skinInfo = t.skinInfo

    local heroTab = gameUtil.getHeroTab( heroid )
    local base = heroTab.Dodge 
    local jinBase = gameUtil.getEquipId( heroid, jinlv ).Quality_Dodge
    local jinXishu = gameUtil.getEquipId( heroid, jinlv ).QUp_Dodge

    local xinBase = gameUtil.getStarTab( heroid, xinlv ).Star_Dodge
    local xinXishu = gameUtil.getStarTab( heroid, xinlv ).SUp_Dodge

    local lvXishu = gameUtil.getEquipId( heroid, jinlv ).Lv_Dodge

    local mb01 = (base + jinBase * jinXishu + xinBase * xinXishu) * (1 + lvXishu * (lv - 1))

    if skinInfo then
        local skinres = skin[gameUtil.getSkinId(heroid, skinInfo.id)]
        if skinres then
            local value = skinres["eq_duosan"]
            mb01 = mb01 + value
        end
    end

    if eqTab and #eqTab > 0 then
        for i=1,#eqTab do
            local eqId = eqTab[i].eqId
            local ack = INITLUA:getEquipByid(eqId)["eq_duosan"]
            mb01 = mb01 + ack
        end
    end

    return mb01
end

--面板暴击
function gameUtil.critMBAck( t )
    local heroid = t.heroid or t.id
    local lv = t.lv
    local xinlv = t.xinlv
    local jinlv = t.jinlv
    local eqTab = t.eqTab
    local skinInfo = t.skinInfo

    local heroTab = gameUtil.getHeroTab( heroid )
    local base = heroTab.Crit 
    local jinBase = gameUtil.getEquipId( heroid, jinlv ).Quality_Crit
    local jinXishu = gameUtil.getEquipId( heroid, jinlv ).QUp_Crit

    local xinBase = gameUtil.getStarTab( heroid, xinlv ).Star_Crit
    local xinXishu = gameUtil.getStarTab( heroid, xinlv ).SUp_Crit

    local lvXishu = gameUtil.getEquipId( heroid, jinlv ).Lv_Crit

    local mb01 = (base + jinBase * jinXishu + xinBase * xinXishu) * (1 + lvXishu * (lv - 1))

    if skinInfo then
        local skinres = skin[gameUtil.getSkinId(heroid, skinInfo.id)]
        if skinres then
            local value = skinres["eq_crit"]
            mb01 = mb01 + value
        end
    end

    -- if eqTab and #eqTab > 0 then
    --     for i=1,#eqTab do
    --         local eqId = eqTab[i].eqId
    --         local ack = INITLUA:getEquipByid(eqId)["eq_duosan"]
    --         mb01 = mb01 + ack
    --     end
    -- end

    local preciousInfo = t.preciousInfo or {}
    local addCrit = 0
    -- for k,v in pairs(preciousInfo) do
    --     local index = v.id
    --     local preciousId = heroTab["PreciousAssetIds"][index]
    --     local order = v.order
    --     local lv = v.lv
    --     local eq_crit = Precious[preciousId].eq_crit
    --     if eq_crit > 0 then
    --         local PreciousTab = Precious[preciousId]
    --         local levelUpTemplateId = PreciousTab.levelUpTemplateId
    --         local orderUpExtra = PreciousTab.orderUpExtra
    --         --初始值+等级成长值+阶数*进阶值
    --         local allLv = gameUtil.getPreciousLevelAll(order, lv)
    --         local add = eq_crit
    --         for i=1,allLv do
    --             add = add + PreciousUp[i]["t"..levelUpTemplateId]
    --         end
    --         addCrit = addCrit + add
    --     end
    -- end
    mb01 = mb01 + addCrit

    return mb01
end

--面板护甲
function gameUtil.wufangMBAck( t )
    local heroid = t.heroid or t.id
    local lv = t.lv
    local xinlv = t.xinlv
    local jinlv = t.jinlv
    local eqTab = t.eqTab
    local skinInfo = t.skinInfo

    local heroTab = gameUtil.getHeroTab( heroid )
    local base = heroTab.WuFang 
    local jinBase = gameUtil.getEquipId( heroid, jinlv ).Quality_WuFang
    local jinXishu = gameUtil.getEquipId( heroid, jinlv ).QUp_WuFang

    local xinBase = gameUtil.getStarTab( heroid, xinlv ).Star_WuFang
    local xinXishu = gameUtil.getStarTab( heroid, xinlv ).SUp_WuFang

    local lvXishu = gameUtil.getEquipId( heroid, jinlv ).Lv_WuFang

    local mb01 = (base + jinBase * jinXishu + xinBase * xinXishu) * (1 + lvXishu * (lv - 1))

    if skinInfo then
        local skinres = skin[gameUtil.getSkinId(heroid, skinInfo.id)]
        if skinres then
            local value = skinres["eq_hujia"]
            mb01 = mb01 + value
        end
    end

    if eqTab and #eqTab > 0 then
        for i=1,#eqTab do
            local eqId = eqTab[i].eqId
            local ack = INITLUA:getEquipByid(eqId)["eq_hujia"]
            mb01 = mb01 + ack
        end
    end

    local preciousInfo = t.preciousInfo or {}
    local addWufang = 0
    -- for k,v in pairs(preciousInfo) do
    --     local index = v.id
    --     local preciousId = heroTab["PreciousAssetIds"][index]
    --     local order = v.order
    --     local lv = v.lv
    --     local eq_hujia = Precious[preciousId].eq_hujia
    --     if eq_hujia > 0 then
    --         local PreciousTab = Precious[preciousId]
    --         local levelUpTemplateId = PreciousTab.levelUpTemplateId
    --         local orderUpExtra = PreciousTab.orderUpExtra
    --         --初始值+等级成长值+阶数*进阶值
    --         local allLv = gameUtil.getPreciousLevelAll(order, lv)
    --         local add = eq_hujia
    --         for i=1,allLv do
    --             add = add + PreciousUp[i]["t"..levelUpTemplateId]
    --         end
    --         addWufang = addWufang + add
    --     end
    -- end
    mb01 = mb01 + addWufang


    return mb01
end

--面板魔抗
function gameUtil.mofangMBAck( t )
    local heroid = t.heroid or t.id
    local lv = t.lv
    local xinlv = t.xinlv
    local jinlv = t.jinlv
    local eqTab = t.eqTab
    local skinInfo = t.skinInfo

    local heroTab = gameUtil.getHeroTab( heroid )
    local base = heroTab.MoFang 
    local jinBase = gameUtil.getEquipId( heroid, jinlv ).Quality_MoFang
    local jinXishu = gameUtil.getEquipId( heroid, jinlv ).QUp_MoFang

    local xinBase = gameUtil.getStarTab( heroid, xinlv ).Star_MoFang
    local xinXishu = gameUtil.getStarTab( heroid, xinlv ).SUp_MoFang

    local lvXishu = gameUtil.getEquipId( heroid, jinlv ).Lv_MoFang

    local mb01 = (base + jinBase * jinXishu + xinBase * xinXishu) * (1 + lvXishu * (lv - 1))

    if skinInfo then
        local skinres = skin[gameUtil.getSkinId(heroid, skinInfo.id)]
        if skinres then
            local value = skinres["eq_mokang"]
            mb01 = mb01 + value
        end
    end

    if eqTab and #eqTab > 0 then
        for i=1,#eqTab do
            local eqId = eqTab[i].eqId
            local ack = INITLUA:getEquipByid(eqId)["eq_mokang"]
            mb01 = mb01 + ack
        end
    end

    local preciousInfo = t.preciousInfo or {}
    local addMofang = 0
    -- for k,v in pairs(preciousInfo) do
    --     local index = v.id
    --     local preciousId = heroTab["PreciousAssetIds"][index]

    --     local order = v.order
    --     local lv = v.lv
    --     local eq_mokang = Precious[preciousId].eq_mokang
    --     if eq_mokang > 0 then
    --         local PreciousTab = Precious[preciousId]
    --         local levelUpTemplateId = PreciousTab.levelUpTemplateId
    --         local orderUpExtra = PreciousTab.orderUpExtra
    --         --初始值+等级成长值+阶数*进阶值
    --         local allLv = gameUtil.getPreciousLevelAll(order, lv)
    --         local add = eq_mokang
    --         for i=1,allLv do
    --             add = add + PreciousUp[i]["t"..levelUpTemplateId]
    --         end
    --         addMofang = addMofang + add
    --     end
    -- end
    mb01 = mb01 + addMofang

    return mb01
end

local tabStrPreciousUp = {"eq_gongji", "eq_shenming", "eq_sudu", "eq_duosan", "eq_crit", "eq_hujia", "eq_mokang"}
function gameUtil.getPreciousAdd( preciousInfo, heroId )
    local tab = {}
    local INITLUA = INITLUA
    local PreciousAll = INITLUA:getRes("Precious")
    local PreciousUpAll = INITLUA:getRes("PreciousUp")
    local index = preciousInfo.id
    local preciousId = gameUtil.getPreciousId(heroId, index)
    local curPreciousRes = PreciousAll[preciousId]
    if not curPreciousRes then
        return tab
    end

    local levelUpTemplateId = curPreciousRes.levelUpTemplateId
    local tName = "t"..levelUpTemplateId
    if not PreciousUpAll[1][tName] then -- 模版错误
        return tab
    end

    local order = preciousInfo.order
    local lv = preciousInfo.lv

    for k,v in pairs(tabStrPreciousUp) do
        local value = curPreciousRes[v]
        local nextAddValue = 0
        if value > 0 then
            --初始值+等级成长值+阶数*进阶值
            local allLv = gameUtil.getPreciousLevelAll(order, lv)
            local add = value
            for i=1,allLv do
                add = add + PreciousUpAll[i][tName]
            end

            -- 下一级需要的值
            allLv = allLv + 1
            local toNextRes = PreciousUpAll[allLv]
            if toNextRes then
                nextAddValue = toNextRes[tName]
            end
            value = add
        end
        tab[v] = value
        tab[v.."next"] = nextAddValue
        if value > 0 then
            break
        end        
    end

    return tab
end
local function log( ... )
    print(...)
end
function gameUtil.getLvUpWords(preciousInfoInOld, preciousInfo,heroId)
    local tab = {} -- 输出需要提示的升级文字。
    local paramName = ""

    local INITLUA = INITLUA
    local PreciousAll = INITLUA:getRes("Precious")
    local PreciousUpAll = INITLUA:getRes("PreciousUp")
    local index = preciousInfo.id
    local preciousId = gameUtil.getPreciousId(heroId, index)
    local curPreciousRes = PreciousAll[preciousId]
    if not curPreciousRes then
        return tab
    end

    local levelUpTemplateId = curPreciousRes.levelUpTemplateId
    local tName = "t"..levelUpTemplateId
    if not PreciousUpAll[1][tName] then -- 模版错误
        return tab
    end

    local order = preciousInfo.order
    local lv = preciousInfo.lv

    --初始值+等级成长值+阶数*进阶值
    local allLv = gameUtil.getPreciousLevelAll(order, lv)
    local allLvOld = preciousInfoInOld.order * 25 + preciousInfoInOld.lv
    if allLv <= allLvOld then
        return tab
    end
    -- 是否进阶了
    local isOrederUp = false
    if order > preciousInfoInOld.order then
        isOrederUp = true
    end

    for k,v in pairs(tabStrPreciousUp) do
        local value = curPreciousRes[v]
        local nextAddValue = 0
        if value > 0 then
            for i=allLvOld+1,allLv do
                local addValue = PreciousUpAll[i][tName]
                if addValue then
                    table_insert(tab, addValue)
                end
            end
        end

        if value > 0 then
            paramName = v
            break
        end
    end

    if isOrederUp then
        table_insert(tab, curPreciousRes.orderUpExtra)
    end

    return tab, paramName
end

--所有英雄阶数
function gameUtil.allJinlv( heroTab )
    if heroTab == nil then
        return 0
    end
    local lv = 0
    local xinlv = 0

    for k,v in pairs(heroTab) do
        if v.lv and v.xinlv then
            lv = lv + gameUtil.getHeroLv(v.exp, v.jinlv)
            xinlv = xinlv + v.xinlv - 1
        end
    end

    return lv,xinlv
end


--[[
            
        单个英雄的替补倍率系数 = (1+英雄等级/25)*英雄等级/25/2*0.08 + (1+英雄星级)*英雄星级/2*0.43 + 
            主动技能1技能强度*(1+主动技能1技能等级/5)*主动技能1技能等级/5/2*0.16 + 
            被动技能2技能强度*(1+被动技能2技能等级/5)*被动技能2技能等级/5/2*0.16 + 
            被动技能3技能强度*(1+被动技能3技能等级/5)*被动技能3技能等级/5/2*0.16 + 
            被动技能4技能强度*(1+被动技能4技能等级/5)*被动技能4技能等级/5/2*0.16 + 
            被动技能5技能强度*(1+被动技能5技能等级/5)*被动技能5技能等级/5/2*0.16

        --当前使用的是下面的
        
        单个英雄的替补倍率系数 = (1+（（英雄阶数-1）*25+英雄等级）/25)*（（英雄阶数-1）*25+英雄等级）/25/2*0.08 +
         (1+英雄星级)*英雄星级/2*0.43 + 
         主动技能1技能强度*(1+主动技能1技能等级/5)*主动技能1技能等级/5/2*0.16 + 
         被动技能2技能强度*(1+被动技能2技能等级/5)*被动技能2技能等级/5/2*0.16 + 
         被动技能3技能强度*(1+被动技能3技能等级/5)*被动技能3技能等级/5/2*0.16 + 
         被动技能4技能强度*(1+被动技能4技能等级/5)*被动技能4技能等级/5/2*0.16 + 
         被动技能5技能强度*(1+被动技能5技能等级/5)*被动技能5技能等级/5/2*0.16
        
        注：这里的英雄等级不超过25.

            总替补倍率系数 = 所有英雄(包括上阵和不上阵的所有英雄）的替补倍率系数之和

            替补修正值 = 0.0015（注：每一个满级英雄提升主阵容主属性15%）

    ]]

function gameUtil.allHeroTiBuBeiLvXiShu( heroTab )
    local num = 0
    for k,v in pairs(heroTab) do
         num = num + gameUtil.heroTiBuBeiLvXiShu( v )
    end 
    return num
end

--
function gameUtil.heroTiBuBeiLvXiShu( tab )

    local jinlv = tab.jinlv
    local lv = gameUtil.getHeroLv(tab.exp, tab.jinlv)
    local xinlv = tab.xinlv
    local skillTab = tab.skill
    local skillNum = 0
    if skillTab then
        for k,v in pairs(skillTab) do
            local slv = v.lv
            local spor = 0
            local passTab = INITLUA:getPassiveResById( v.id )
            if passTab then
                spor = passTab.PassivePower
            else
                spor = 1
            end
            skillNum = skillNum + spor*(1+slv/5)*slv/5/2*0.16
        end
    end

    local num = (1+((jinlv-1)*25+lv)/25)*((jinlv-1)*25+lv)/25/2*0.08 + (1+xinlv)*xinlv/2*0.43 + skillNum

    return num
    
end


--攻击替补修正 = 面板攻击属性 * （1+ 总替补倍率系数*替补修正值）
function gameUtil.AckTBXZ( ackNum , allHeroTiBuBeiLvXiShu, pkValue )

    local ackxz = ackNum * (1 + allHeroTiBuBeiLvXiShu * 0.0015)

    local pkEffect = 1
    local C = PEIZHI.PK_PARAM_C
    if pkValue ~= nil then
        if pkValue < 10 then
            pkEffect = (pkValue / 10)^2 * C + (1 - C)
        else
            pkEffect = 2 - (((20 - pkValue)/10)^2*C + (1 - C))
        end
    end

    return ackxz*pkEffect
end

--生命替补修正 = 面板生命属性 * （1+ 总替补倍率系数*替补修正值）
function gameUtil.HpTBXZ( hpNum , allHeroTiBuBeiLvXiShu, pkValue )

    local ackxz = hpNum * (1 + allHeroTiBuBeiLvXiShu * 0.0015)

    local pkEffect = 1
    local C = PEIZHI.PK_PARAM_C
    if pkValue ~= nil then
        if pkValue < 10 then
            pkEffect = (pkValue / 10)^2 * C + (1 - C)
        else
            pkEffect = 2 - (((20 - pkValue)/10)^2*C + (1 - C))
        end
    end

    return ackxz*pkEffect
end

-- --速度替补修正
-- function gameUtil.SpeedTBXZ(  alllv, allxinlv )
   
--     local speedxz = (alllv + allxinlv * 75) * 0.0000004
--     return speedxz
-- end

-- --闪避替补修正
-- function gameUtil.DodgeTBXZ(  alllv, allxinlv )
    
--     local dodgexz = (alllv + allxinlv * 75) * 0.003
--     return dodgexz
-- end

-- --暴击替补修正
-- function gameUtil.CritTBXZ( alllv, allxinlv )
    
--     local critxz = (alllv + allxinlv * 75) * 0.003
--     return critxz
-- end

-- --物防替补修正
-- function gameUtil.WufangTBXZ(  alllv, allxinlv )
    
--     local wufangxz = (alllv + allxinlv * 75) * 0.003
--     return wufangxz
-- end

-- --魔防替补修正
-- function gameUtil.MofangTBXZ(  alllv, allxinlv )
    
--     local mofangxz = (alllv + allxinlv * 75) * 0.003
--     return mofangxz
-- end




--战斗力计算
function gameUtil.Zhandouli( tab , allHeroTab, pkValue, needTB)
    local alllv, allxinlv = gameUtil.allJinlv( allHeroTab )
    local t = {}
    t.heroid = tab.id or tab.ID
    t.lv = gameUtil.getHeroLv(tab.exp, tab.jinlv)
    t.xinlv = tab.xinlv 
    t.jinlv = tab.jinlv
    t.eqTab = tab.eqTab
    t.preciousInfo = tab.preciousInfo or {}
    t.skinInfo = tab.skinInfo or {}

    local allHeroTiBuBeiLvXiShu = gameUtil.allHeroTiBuBeiLvXiShu( allHeroTab )



    local ackNum = gameUtil.heroMBAck( t )

    local acktbNum = ackNum
    if needTB == true or needTB == nil then
        acktbNum = gameUtil.AckTBXZ( ackNum, allHeroTiBuBeiLvXiShu, pkValue )
    end


    local hpNum = gameUtil.hpMBAck( t )

    local hptbNum = hpNum
    if needTB == true or needTB == nil then
        hptbNum = gameUtil.HpTBXZ( hpNum, allHeroTiBuBeiLvXiShu, pkValue )
    end

    local speedNum = gameUtil.speedMBAck( t )
    local speedtbNum = speedNum

    local dodgeNum = gameUtil.dodgeMBAck( t )
    local dodgetbNum = dodgeNum
    local dodgetbXishu = dodgetbNum / 10000

    local critNum = gameUtil.critMBAck( t )
    local crittbNum = critNum
    local crittbXishu = crittbNum / 10000
    local critHurtXishu = 2

    local wufangNum = gameUtil.wufangMBAck( t )
    local wufangtbNum = wufangNum
    local wulijianHurt = gameUtil.wulijianHurt( wufangtbNum )

    local mofangNum = gameUtil.mofangMBAck( t )
    local mofangtbNum = mofangNum
    local mofajianHurt = gameUtil.mofajianHurt( mofangtbNum )

    local jineng1 = 0
    local jineng2 = 0
    local jineng3 = 0
    local jineng4 = 0

    local aptitude = gameUtil.getHeroTab(t.heroid).aptitude


    local allskill = 0

    for k,v in pairs(tab.skill) do
        allskill = allskill + v.lv
    end



    local zhandouli = math.pow((math.sqrt((hptbNum / (1 - dodgetbXishu)) * ((speedtbNum * crittbXishu * critHurtXishu *  
            acktbNum + (1 - crittbXishu) * speedtbNum * acktbNum   ) / (1 - (wulijianHurt + mofajianHurt) / 2)) )
        + aptitude * aptitude / 10 * allskill),1.4)/50

                

    return math.ceil(zhandouli)
end

function gameUtil.wulijianHurt( wufang )
    local num = 0
    if wufang >= 0 then
        num = wufang / (math.abs(wufang) + 10000)
    else
        num = wufang / (math.abs(wufang) + 10000) * 2
    end
    return num
end

function gameUtil.mofajianHurt( mofang )
    local num = 0
    if mofang >= 0 then
        num = mofang / (math.abs(mofang) + 10000)
    else
        num = mofang / (math.abs(mofang) + 10000) * 2
    end
    return num
end

function gameUtil:addTishi( tab )
    local w = tab.width
    local h = tab.height
    if tab.color == nil then
        tab.color = cc.c3b(255, 0, 0)
    end

    if mm.piaoZiTab.contentTab == nil then
        mm.piaoZiTab.contentTab = {}
    end
    tab.p = tab.p or mm.self or cc.Director:getInstance():getRunningScene()
    local size = mm.scene():getContentSize()
    if tab.type == nil then
        size = cc.Director:getInstance():getWinSize()
        for k,v in pairs(mm.piaoZiTab.contentTab) do
             v:removeFromParent()
        end
        mm.piaoZiTab.contentTab = {}
    else
        size = tab.p:getContentSize()
    end
    tab.f = tab.f or 56 -- 默认系统提示字体大小
    local tishiText = gameUtil.getCSLoaderObj({name = "heroTishiText", node = {}, type = "mycreate", removeTab = {}})--ccui.Text:create(tab.s, "fonts/youyuan.TTF", tab.f)
    tishiText:setString(tab.s)
    tishiText:setVisible(true)
    tishiText:setOpacity(255)
    tishiText:setScale(1)
    tishiText:stopAllActions()
    if tab.z then
        tab.p:addChild(tishiText, tab.z)
    else
        tab.p:addChild(tishiText, MoGlobalZorder[2999999])
    end
    if tab.type == nil then
        tishiText:setPosition(size.width * 0.5, size.height * 0.65)
    else
        tishiText:setPosition(size.width * 0.5, size.height * 0.5)
    end

    if w and h then
        tishiText:setPosition(w, h)
    end

    mm.piaoZiTab.lastpos = tishiText:getPositionY()
    tishiText:setColor(tab.color)
    tishiText:setScale(2.5)

    local function Back( ... )
        table.remove(mm.piaoZiTab.contentTab, 1)
        if table.getn(mm.piaoZiTab.contentTab) == 0 then
            mm.piaoZiTab.lastpos = nil
        end
        tishiText:removeFromParent()
    end
    local action01 = cc.ScaleTo:create(0.1,1)
    local action02 = cc.MoveBy:create(0.1,cc.p(0, 40))
    local spawn = cc.Spawn:create(action01, action02)
    tishiText:runAction(cc.Sequence:create(spawn ,cc.DelayTime:create(2),cc.FadeOut:create(0.5),cc.CallFunc:create(Back)))
    -- local move = cc.MoveBy:create(0.3, cc.p(0, 60))
    for k,v in pairs(mm.piaoZiTab.contentTab) do
        cc.Director:getInstance():getActionManager():addAction(cc.MoveBy:create(0.05, cc.p(0, tishiText:getContentSize().height + 5)), v, true)
    end
    table.insert(mm.piaoZiTab.contentTab, tishiText)
    -- tishiText:retain()


end

function gameUtil.createItem( tab )
    local item = ccui.Layout:create()
    item:setContentSize(cc.size(84, 84))
    
    -- custom_item:addChild(item)
    
    item:setTouchEnabled(true)
    item:setTag(tab.id)
    

    local imageView = ccui.ImageView:create()
    imageView:loadTexture(gameUtil.getHeroIcon(tab.id))
    item:addChild(imageView)
    imageView:setPosition(item:getContentSize().width * 0.5, item:getContentSize().height * 0.5)
    imageView:setName("icon")

    local kImageView = ccui.ImageView:create()
    kImageView:loadTexture(gameUtil.getKuang(tab.jinlv))
    item:addChild(kImageView)
    kImageView:setPosition(item:getContentSize().width * 0.5, item:getContentSize().height * 0.5)

    local gImageView = ccui.ImageView:create()
    gImageView:loadTexture("res/UI/jm_hero_xuan.png")
    item:addChild(gImageView)
    gImageView:setPosition(item:getContentSize().width * 0.5, item:getContentSize().height * 0.5)
    gImageView:setName("gou")
    gImageView:setVisible(false)

    local ttfConfig = {}
    ttfConfig.fontFilePath = "font/youyuan.TTF"
    ttfConfig.fontSize = 20
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 1
    
    local label = cc.Label:createWithTTF(ttfConfig,tab.lv,cc.TEXT_ALIGNMENT_CENTER,300)
    label:setAnchorPoint(cc.p(1,0))
    label:setPosition(cc.p(30, 20))
    label:setTextColor( cc.c4b(0, 255, 0, 255) )
    label:enableGlow(cc.c4b(255, 255, 0, 255))
    item:addChild(label)

    local xinlv = tab.xinlv
    for i=1,xinlv do
        local xImageView = ccui.ImageView:create()
        xImageView:loadTexture("res/UI/icon_xiaoxing_normal.png")
        item:addChild(xImageView)
        xImageView:setPosition(item:getContentSize().width * 0.5 + (i - 1) * xImageView:getContentSize().width - (xinlv - 1) * xImageView:getContentSize().width * 0.5, xImageView:getContentSize().height * 0.5)
    end

    return item
end

function gameUtil.createFont(res, size, src,color, time)
    local Text = ccui.Text:create(src, res, size)
    --Text:setFontName("Text")
    Text:setColor(color)
    --Text:setPosition(cc.p(0,-20))
    --self:addChild(Text)
    -- local function hurtBack( ... )
    --     Text:removeFromParent()
    --     Text = nil
    -- end
    -- Text:runAction( cc.Sequence:create(cc.ScaleTo:create(0.1,0.6),cc.DelayTime:create(time),cc.MoveBy:create(0.3, cc.p(0,50)),cc.CallFunc:create(hurtBack)))
    return Text
end

function gameUtil.setBtnEffect(Btn)
    Btn:setZoomScale(-Btn:getZoomScale())
    Btn:setPressedActionEnabled(true)
end

function gameUtil.setGRAYByParent( node )
    local children = node:getChildren()
    if #children <= 0 then
        gameUtil.setGRAY(node)
        return
    end
    for k,v in pairs(children) do
        gameUtil.setGRAYByParent(v)
    end
end

--设置灰度图
function gameUtil.setGRAY( node )
    local vertDefaultSource = [[

                           attribute vec4 a_position;
                           attribute vec2 a_texCoord;
                           attribute vec4 a_color;  

                           #ifdef GL_ES
                               varying lowp vec4 v_fragmentColor;
                               varying mediump vec2 v_texCoord;
                           #else
                               varying vec4 v_fragmentColor;
                               varying vec2 v_texCoord;
                           #endif 

                           void main()
                           {
                               gl_Position = CC_PMatrix * a_position; 
                               v_fragmentColor = a_color;
                               v_texCoord = a_texCoord;
                           }

                           ]]
        
    local pszFragSource = [[

                 #ifdef GL_ES 
                                  precision mediump float;
                            #endif 
                            varying vec4 v_fragmentColor; 
                            varying vec2 v_texCoord; 

                            void main(void) 
                            { 
                                vec4 c = texture2D(CC_Texture0, v_texCoord);
                                gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b);
                                gl_FragColor.w = c.w; 
                            }

                            ]]

    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, pszFragSource)
    
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end

--清除灰度
function gameUtil.clearGRAY( node )
    node:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")))
end

--获取任务进度
function gameUtil.GetTaskProgress( task )
    if mm.data.playerTaskProc == nil then
        mm.data.playerTaskProc = {}
    end
    
    if task.TaskType == MM.ETaskType.TT_IDLV then
        return gameUtil.getPlayerLv(mm.data.playerinfo.exp) or 0
    elseif task.TaskType == MM.ETaskType.TT_HeroCount then -- 英雄数量
        return #mm.data.playerHero or 0
    elseif task.TaskType == MM.ETaskType.TT_PK then -- 侵略次数
        return mm.data.playerTaskProc.DailyPKCount or 0
    elseif task.TaskType == MM.ETaskType.TT_StarLv then -- 星级等级
        local maxXin = 0
        for k,v in pairs(mm.data.playerHero) do
            maxXin = (maxXin > v.xinlv) and maxXin or v.xinlv or 0
        end
        return maxXin
    elseif task.TaskType == MM.ETaskType.TT_RankLv then -- 天梯等级
        local curDuanWei = tonumber(mm.data.curDuanWei)
        if curDuanWei == 1093677105 
            or curDuanWei == 1093677106 
            or curDuanWei == 1093677107 
            or curDuanWei == 1093677108 
            or curDuanWei == 1093677109 then
            return 1
        elseif curDuanWei == 1093677110 
            or curDuanWei == 1093677111 
            or curDuanWei == 1093677112 
            or curDuanWei == 1093677113 
            or curDuanWei == 1093677360 then
            return 2
        elseif curDuanWei == 1093677361 
            or curDuanWei == 1093677362 
            or curDuanWei == 1093677363 
            or curDuanWei == 1093677364 
            or curDuanWei == 1093677365 then
            return 3
        elseif curDuanWei == 1093677366 
            or curDuanWei == 1093677367 
            or curDuanWei == 1093677368 
            or curDuanWei == 1093677369 
            or curDuanWei == 1093677616 then
            return 4
        elseif curDuanWei == 1093677617 
            or curDuanWei == 1093677618 
            or curDuanWei == 1093677619 
            or curDuanWei == 1093677620 
            or curDuanWei == 1093677621 then
            return 5
        elseif curDuanWei == 1093677622  then
            return 6
        elseif curDuanWei == 1093677623 then
            return 7
        else
            return 0
        end
    elseif task.TaskType == MM.ETaskType.TT_Zhanli then -- 战力数值
        local allZhanli = gameUtil.getPlayerForce(mm.data.playerExtra.pkValue)
        return allZhanli
    elseif task.TaskType == MM.ETaskType.TT_KillTimoCount then -- 击杀提莫
        return mm.data.playerTaskProc.killTimorCount or 0
    elseif task.TaskType == MM.ETaskType.TT_KillSFCount then -- 击杀影魔
        return mm.data.playerTaskProc.killYingMoCount or 0
    elseif task.TaskType == MM.ETaskType.TT_Rank then -- 王者排名
        local curDuanWei = tonumber(mm.data.curDuanWei)
        if curDuanWei == 1093677623 then
            return 1
        else
            return 0
        end
    elseif task.TaskType == MM.ETaskType.TT_Win then -- 过关
        if mm.data.playerStage ~= nil then
            local stageRes = INITLUA:getStageResById(task.CType)
            for k,v in pairs(mm.data.playerStage) do
                if v.chapter == stageRes.StageType and v.max_proc >= task.TaskConditionValue then
                    return v.max_proc
                end
            end
        end
        return -1
    elseif task.TaskType == MM.ETaskType.TT_Level then -- 英雄等级
        return mm.data.playerTaskProc.HeroMaxLevel or 0
    elseif task.TaskType == MM.ETaskType.TT_Quality then -- 英雄品阶
        return mm.data.playerTaskProc.HeroQuality or 0
    elseif task.TaskType == MM.ETaskType.TQ_Chanllenge then -- pk挑战关卡
        return mm.data.playerTaskProc.PkWithStage or 0
    elseif task.TaskType == MM.ETaskType.TQ_Plunder then -- pk同阵营
        return mm.data.playerTaskProc.PkWithMyCamp or 0
    elseif task.TaskType == MM.ETaskType.TQ_Attack then -- pk敌对阵营
        return mm.data.playerTaskProc.DailySnipeCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_Battle then -- pk明星关
        return mm.data.playerTaskProc.PkWithFamous or 0
    elseif task.TaskType == MM.ETaskType.TQ_GoldFinger then -- 金手指
        return mm.data.playerExtra.RaidsTimes or 0
    elseif task.TaskType == MM.ETaskType.TQ_BuyGold then -- 购买金币
        return mm.data.playerTaskProc.GoldBuyCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_ExpPoor then -- 购买经验
        return mm.data.playerTaskProc.ExpBuyCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_Quaility then -- 进阶英雄
        return mm.data.playerTaskProc.HeroJinJieCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_HeroLevelUp then -- 升级英雄
        return mm.data.playerTaskProc.HeroLevelCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_EquipWear then -- 穿装备
        return mm.data.playerTaskProc.HeroQuality or 0
    elseif task.TaskType == MM.ETaskType.Daily_BuyEquip then -- 买装备
        return mm.data.playerTaskProc.DailyEquipBuyCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_BuyEquip then -- 买装备
        return mm.data.playerTaskProc.EquipBuyCount or 0
    elseif task.TaskType == MM.ETaskType.Daily_SkillLevelUp then -- 技能升级
        return mm.data.playerTaskProc.DailyHeroSkillUpCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_SkillLevelUp then -- 技能升级
        return mm.data.playerTaskProc.HeroSkillUpCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_StarUp then -- 提升星级
        return mm.data.playerTaskProc.HeroXingUpCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_Month then -- 月卡任务
        return mm.data.playerinfo.lastMonthcardTimes or 0
    elseif task.TaskType == MM.ETaskType.TQ_ExMonth then -- 高级月卡任务
        return mm.data.playerinfo.lastHighmonthcardTimes or 0
    elseif task.TaskType == MM.ETaskType.TQ_Forever then -- 终身卡任务
        return mm.data.playerinfo.alllife
    elseif task.TaskType == MM.ETaskType.TQ_VIP then -- VIP任务
        return gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    elseif task.TaskType == MM.ETaskType.TQ_Lound then -- 弹幕任务
        return mm.data.playerTaskProc.dailyTalkCount or 0
    elseif task.TaskType == MM.ETaskType.TQ_Saodang then -- 扫荡任务
        return mm.data.playerTaskProc.saodangTimes or 0
    elseif task.TaskType == MM.ETaskType.TQ_Wumian then -- 物免任务
        return mm.data.playerTaskProc.wumianTimes or 0
    elseif task.TaskType == MM.ETaskType.TQ_Momian then -- ，魔免任务
        return mm.data.playerTaskProc.momianTimes or 0
    elseif task.TaskType == MM.ETaskType.TT_RankLevel then -- ，竞技场等级
        return mm.data.playerTaskProc.TianTiLadder or 0
    else
        return 0
    end
end

function gameUtil.CanShow(t)
    if t.Activated == 0 then
        return false
    end

    if t.Nation ~= mm.data.playerinfo.camp then
        if t.Nation ~= 9 then
            return false
        end
    end

    if mm.data.playerTask == nil then
        mm.data.playerTask = {}
    end

    if t.TaskType == MM.ETaskType.TQ_Attack then
        if tonumber(mm.data.curDuanWei) < 1093677617 then
            return false
        end
    end

    for k,v in pairs(mm.data.playerTask) do
        if v.taskId == t.ID then
            return false
        end
    end
    if t.TaskType == MM.ETaskType.TQ_VIP then
        if t.TaskConditionValue == gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp) then
            return true
        else
            return false
        end
    end
    for k,v in pairs(mm.data.playerTask) do
        if v.taskId == t.QianZhiID then
            return true
        end
    end
    if t.QianZhiID == 0 then
        return true
    end
    return false
end

function gameUtil.addGreenPoint( btn , rateX, rateY)
    if btn:getChildByName("greenPoint") == nil then
        local redPoint = cc.Sprite:create("res/UI/pc_tongyong_lvse.png")
        redPoint:setName("greenPoint")
        local size = btn:getSize()
        rateX = rateX or 0.8
        rateY = rateY or 0.8
        local x_right = size.width * rateX
        local y_top = size.height * rateY
    
        redPoint:setPosition(x_right, y_top)
        redPoint:setScale(0.8)
        btn:addChild(redPoint, 100)


        local an = gameUtil.createSkeAnmion( {name = "hd"} ) --gameUtil.createSkeletonAnimation("res/Effect/uiEffect/hd/hd.json", "res/Effect/uiEffect/hd/hd.atlas",1)
        redPoint:addChild(an)
        an:setPosition(redPoint:getContentSize().width*0.5, redPoint:getContentSize().height*0.5)
        an:setAnimation(0, "stand", true)
    end
end

function gameUtil.addRedPoint( btn , rateX, rateY)
    if btn:getChildByName("redPoint") == nil then
        local redPoint = cc.Sprite:create("res/UI/pc_tongyong_xinxitishi.png")
        redPoint:setName("redPoint")
        local size = btn:getSize()
        rateX = rateX or 0.8
        rateY = rateY or 0.8
        local x_right = size.width * rateX
        local y_top = size.height * rateY
    
        redPoint:setPosition(x_right, y_top)
        redPoint:setScale(0.8)
        btn:addChild(redPoint, 100)

        local an = gameUtil.createSkeAnmion( {name = "hd"} )--gameUtil.createSkeletonAnimation("res/Effect/uiEffect/hd/hd.json", "res/Effect/uiEffect/hd/hd.atlas",1)
        redPoint:addChild(an)
        an:setPosition(redPoint:getContentSize().width*0.5, redPoint:getContentSize().height*0.5)
        an:setAnimation(0, "stand", true)
    end
end

function gameUtil.hasResPoint(btn)
    if btn:getChildByName("redPoint") then
        return true
    end
    return false
end

function gameUtil.addNewHint( btn, hintRes, offsetX, offsetY, rateX, rateY)
    if btn:getChildByName("newHint") == nil then
        local hintNode = cc.Node:create()

        gameUtil.addArmatureFile("res/Effect/uiEffect/"..hintRes.."/"..hintRes..".ExportJson")
        local anime = ccs.Armature:create(hintRes)

        local animation = anime:getAnimation()
        anime:setPosition(cc.p(offsetX, offsetY))
        hintNode:addChild(anime)
        animation:play(hintRes)
        -- anime:setScale(3.3)
        anime:setAnchorPoint(cc.p(0.5,0.5))


        local newHint = cc.Sprite:create("res/UI/icon_new.png")
        -- newHint:setName("newHint")
        local size = btn:getSize()
        rateX = rateX or 0.8
        rateY = rateY or 0.8
        local x_right = size.width * rateX
        local y_top = size.height * rateY
    
        newHint:setPosition(x_right, y_top)
        -- newHint:setScale(0.8)
        -- btn:addChild(newHint, 100)
        hintNode:addChild(newHint)

        hintNode:setName("newHint")
        btn:addChild(hintNode, 100)
    end
end

function gameUtil.addNewImg( btn, height )
    local newHint = cc.Sprite:create("res/UI/icon_new.png")
    newHint:setName("newHint")
    local size = btn:getSize()
    rateX = rateX or 0.8
    rateY = rateY or 0.8
    local x_right = size.width * rateX

    local y_top = size.height * rateY
    if height then
        y_top = height
    end
    btn:addChild(newHint)

    newHint:setPosition(x_right, y_top)
end

function gameUtil.addNewPoint( btn , rateX, rateY)
    if btn:getChildByName("newPoint") == nil then
        local redPoint = cc.Sprite:create("res/UI/icon_new.png")
        redPoint:setName("newPoint")
        local size = btn:getSize()
        rateX = rateX or 0.8
        rateY = rateY or 0.8
        local x_right = size.width * rateX
        local y_top = size.height * rateY
    
        redPoint:setPosition(x_right, y_top)
        redPoint:setScale(0.8)
        btn:addChild(redPoint, 100)
    end
end

function gameUtil.removeGreenPoint( btn )
    local redPoint = btn:getChildByName("greenPoint")
    if redPoint ~= nil then
        redPoint:removeFromParent()
    end
end

function gameUtil.removeNewPoint( btn )
    local redPoint = btn:getChildByName("newPoint")
    if redPoint ~= nil then
        redPoint:removeFromParent()
    end
end

function gameUtil.removeRedPoint( btn )
    local redPoint = btn:getChildByName("redPoint")
    if redPoint ~= nil then
        redPoint:removeFromParent()
    end
end

function gameUtil.removeNewHint( btn )
    local newHint = btn:getChildByName("newHint")
    if newHint ~= nil then
        newHint:removeFromParent()
    end
end

-- 输出加载的动画
function gameUtil.addArmatureFile(src)
    if util.isFileExist(src) then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(src)
        return true
    else
    end
    return false
end

function gameUtil.removeArmatureFile(src, bAlsoRemveTexture)
    if util.isFileExist(src) then
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(src)
    else
    end
end


--[[
    mouldRes:模板路径
    floorRes:底板路径
    例子:发光的标题
    模板路径:标题
    底板路径:流光   
]]
function gameUtil.clipFun(mouldRes,floorRes)
    --模板精灵  
    local mouldSprite = cc.Sprite:create(mouldRes)
    local mouldSize = mouldSprite:getContentSize()
    --底板精灵
    local floorSprite = cc.Sprite:create(floorRes)
    local floorSize = floorSprite:getContentSize()
    floorSprite:setPosition(-floorSize.width/2-mouldSize.width/2, 0)

    --裁切节点
    local clipNode = cc.ClippingNode:create()
    clipNode:setAlphaThreshold(0.5)       --设置alpha闸值
    clipNode:setContentSize(mouldSize)    --设置尺寸大小
    clipNode:setStencil(mouldSprite)      --设置模板stencil
    clipNode:addChild(mouldSprite, 1)
    clipNode:addChild(floorSprite,2)

    local function moveBack( ... )
        floorSprite:setPositionX(-floorSize.width/2-mouldSize.width/2)
    end
    local moveTo = cc.MoveTo:create(0.2,cc.p(floorSize.width/2+mouldSize.width/2,0))
    local action = cc.RepeatForever:create(cc.Sequence:create(moveTo,cc.CallFunc:create(moveBack),cc.DelayTime:create(5)))
    floorSprite:runAction(action)

    return clipNode
	
end

-- 判断某件装备是否可合成
function gameUtil.isHechen( id )
    local tab = INITLUA:getEquipByid( id )
    local eqTab = util.copyTab(mm.data.playerEquip)
    local hunshiTab = util.copyTab(mm.data.playerHunshi)
    local eqTab = eqTab
    local hunshiTab = hunshiTab
    if eqTab == nil or #eqTab == 0 then
        return 1
    end  
    if hunshiTab == nil or #hunshiTab == 0 then
        return 1
    end
    if tab.eq_zujian01 > 0 then
        for i=1,4 do
            local eqsrc = "eq_zujian0"..i
            local zjId = tab[eqsrc]
            if zjId > 0 then
                if not gameUtil.isHaveById( eqTab, zjId ) then
                    --判断材料是否可以合成
                    if 0 ~= gameUtil.isHechen(zjId,eqTab) then
                        return 1
                    end
                end
            end
        end
        return 0
    elseif tab.eq_needsp > 0 then
        local hunshiId = tab.eq_needsp
        local hunshiNum = tab.eq_spnum
        if not gameUtil.isHaveById( hunshiTab, hunshiId, hunshiNum ) then
            return 1
        else
            return 0
        end
    else
        return 2 
    end
end
-- 现在是否有某件装备
function gameUtil.isHaveById( tab, id, num )
    local num = num or 0
    for k,v in pairs(tab) do
        if v.id == id and v.num >= num then
            v.num = v.num - num
            return true
        end
    end

    return nil

end

function gameUtil.getEquipId( heroId, jinLv )
    local camp = gameUtil.getHeroTab( heroId ).Nation
    local tab = nil
    if camp == 1 then --dota
        tab = INITLUA:getLOLRankRes()
    elseif camp == 2 then --lol
        tab = INITLUA:getDOTARankRes()
    else
        gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "英雄阵型不对heroId："..heroId,z = 3000})
    end
    for k,v in pairs(tab) do
        if v.ID == heroId and v.Quality_Lv == jinLv then
            return v
        end
    end

    return nil
end

function gameUtil.getJinjieNeedGold( jinlv )
    local gold = 9999999
    for i = 1, #PEIZHI.jinjieNeed do
        if jinlv+1 == PEIZHI.jinjieNeed[i].lv then
            gold = PEIZHI.jinjieNeed[i].gold
            break
        end
    end
    if gold == 9999999 then
        
    end
    return gold
end

function gameUtil.getShengXingNeedGold( xinlv )
    local gold = 9999999
    for i = 1, #PEIZHI.xinji do 
        if PEIZHI.xinji[i].lv == xinlv + 1 then
            gold = PEIZHI.xinji[i].gold
            break
        end
    end
    if gold == 9999999 then

    end
    return gold
end



function gameUtil.setBlur(Node,scale)
    -- local sprite = Node:getVirtualRenderer()
    local glProgram = cc.GLProgram:createWithFilenames("res/shader/common.vert","res/shader/common.frag");
    
    local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glProgram)
    Node:setGLProgramState(glProgramState)

    -- local texture = sprite:getTexture()
    -- local textureWidth = texture:getPixelsWide()
    -- local textureHeight = texture:getPixelsHigh()
    -- glProgramState:setUniformFloat("textureWidth",textureWidth)
    -- glProgramState:setUniformFloat("textureHeight",textureHeight)
    glProgramState:setUniformFloat("scale",scale)

end

--[[

function graySprite(sprite) {  
    if (sprite) {  
        var shader = new cc.GLProgram();//创建一个cc.GLProgram对象  
        shader.init(res.Grat_vsh, res.Gray_fsh);//初始化顶点着色器和片元着色器  
        shader.link();//连接  
        shader.updateUniforms();//我的理解是经过一系列的矩阵变换渲染到屏幕上  
        sprite.setShaderProgram(shader);//应用到精灵上  
    }  
}

]]

function gameUtil.graySprite( sprite )
    if sprite then
        local glProgram = cc.GLProgram:createWithFilenames("res/shader/gray.vsh","res/shader/gray.fsh");
        glProgram:link()
        glProgram:updateUniforms()
        sprite:setGLProgram(glProgram)

        local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glProgram)
        sprite:setGLProgramState(glProgramState)
        --glProgramState:setUniformVec3("FragColor",cc.vec3())
    end
end


--获取玩家战力
function gameUtil.getPlayerForce( pkValue , needTB)
    local allZhanli = 0
    for i=1,5 do
        if mm.puTongZhen[i] then
            for j=1,#mm.data.playerHero do
                if mm.puTongZhen[i] == mm.data.playerHero[j].id then
                    local tab = util.copyTab(mm.data.playerHero[j])
                    local zhanli = gameUtil.Zhandouli( tab ,mm.data.playerHero, pkValue or mm.data.playerExtra.pkValue, needTB)
                    if zhanli then
                        allZhanli = allZhanli + zhanli
                    end
                end
            end
        end
    end
    return allZhanli
end

--获取玩家挂机战力
function gameUtil.getPlayerGuaJiForce( pkValue , needTB)
    local putongForm = nil
    for i=1,#mm.data.playerFormation do
        if mm.data.playerFormation[i].type == 1 then
            putongForm = mm.data.playerFormation[i]
        end
    end

    local myZhen = {}
    if putongForm ~= nil then
        for i=1,#putongForm.formationTab do
            myZhen[i] = {}
            myZhen[i].id = putongForm.formationTab[i].id
            local pos = gameUtil.getHeroTab( myZhen[i].id ).pos
            myZhen[i].pos = pos
        end
    end

    local allZhanli = 0
    for i=1,5 do
        if myZhen[i] then
            for j=1,#mm.data.playerHero do
                if myZhen[i].id == mm.data.playerHero[j].id then
                    local tab = util.copyTab(mm.data.playerHero[j])
                    local zhanli = gameUtil.Zhandouli( tab ,mm.data.playerHero, pkValue or mm.data.playerExtra.pkValue, needTB)
                    if zhanli then
                        allZhanli = allZhanli + zhanli
                    end
                end
            end
        end
    end
    return allZhanli
end

function gameUtil.createOTItem( res , num)
    local node = cc.Node:create()
    local icon = ccui.ImageView:create()
    icon:loadTexture(res)
    icon:setScale(1)
    icon:setAnchorPoint(cc.p(0, 0))

    node:addChild(icon)
    -- node:setAnchorPoint(cc.p(0, 0))
    local width = icon:getContentSize().width
    node:setContentSize(cc.size(width, width))
    if num > 0 then
        local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
        sprite_ditu:setAnchorPoint(cc.p(1, 0))
        sprite_ditu:setPosition(cc.p(width - 2, 0))
        icon:addChild(sprite_ditu)

        local ttfConfig = {}
        ttfConfig.fontFilePath = "font/youyuan.TTF"
        ttfConfig.fontSize = 20
        ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
        ttfConfig.customGlyphs = nil
        ttfConfig.distanceFieldEnabled = true
        ttfConfig.outlineSize = 1
        
        local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER)
        label:setAnchorPoint(cc.p(1,0))
        label:setPosition(cc.p(width - 2, 0))
        label:setTextColor( cc.c4b(0, 255, 0, 255) )
        label:enableGlow(cc.c4b(255, 255, 0, 255))
        icon:addChild(label)

        local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
        sprite_ditu:setScaleX(scaleX)
    end
    return node
end

function gameUtil.createEquipItem( equipID , num, isWithJinGuang)
    --local imageView = cc.Node:create()
    local imageView = ccui.Layout:create()
    --imageView:loadTexture(gameUtil.getEquipIconRes(equipID))
    --imageView:setScale(1.1)

    local icon = ccui.ImageView:create()
    icon:setName("icon")
    icon:loadTexture(gameUtil.getEquipIconRes(equipID))
    icon:setScale(1.3)
    icon:setAnchorPoint(cc.p(0, 0))

    imageView:addChild(icon)
    imageView:setContentSize(icon:getContentSize())

    local width = icon:getContentSize().width * 1.3

    local frameSize = cc.size(width, width)
    imageView:setContentSize(frameSize)
    
    imageView:setAnchorPoint(cc.p(0, 0))
    
    local equip = INITLUA:getEquipByid(equipID)
    if equip and equip.EquipType == 3 then 
        local hunShiTag = ccui.ImageView:create("res/UI/icon_hunshi.png")
        hunShiTag:setScale(1.05)
        hunShiTag:setAnchorPoint(cc.p(0, 0))
        hunShiTag:setPosition(cc.p(0, 0))
        imageView:addChild(hunShiTag)
        hunShiTag:setName("hunshiImage")

    elseif isWithJinGuang and equip then
        local curQuality = equip.Quality
        if curQuality == GoldQuality then --or curQuality == OrangeQuality
            local jinFrameNode = createJinGuangFrame(frameSize)
            if jinFrameNode then
                imageView:addChild(jinFrameNode,100)
            end
        end
    end

    if num > 0 then
        local sprite_ditu = ccui.ImageView:create("res/UI/pc_jiaobiao.png")
        sprite_ditu:setAnchorPoint(cc.p(1, 0))
        sprite_ditu:setPosition(cc.p(width - 2, 0))
        imageView:addChild(sprite_ditu)
        sprite_ditu:setName("ditu")

        local ttfConfig = {}
        ttfConfig.fontFilePath = "font/youyuan.TTF"
        ttfConfig.fontSize = 20
        ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
        ttfConfig.customGlyphs = nil
        ttfConfig.distanceFieldEnabled = true
        ttfConfig.outlineSize = 1
        
        local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER)
        label:setAnchorPoint(cc.p(1,0))
        label:setPosition(cc.p(width - 2, 0))
        label:setTextColor( cc.c4b(0, 255, 0, 255) )
        label:enableGlow(cc.c4b(255, 255, 0, 255))
        imageView:addChild(label)

        local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
        sprite_ditu:setScaleX(scaleX)
    end

    local pinPathRes = gameUtil.getEquipPinRes(INITLUA:getEquipByid( equipID ).Quality)
    if #pinPathRes > 0 then
        local pinImgView = ccui.ImageView:create()
        pinImgView:loadTexture(pinPathRes)
        pinImgView:setScale(1)
        imageView:addChild(pinImgView)
        pinImgView:setAnchorPoint(cc.p(0,0))
        pinImgView:setName("pin")
    end
    
    return imageView
end

local color_red4 = cc.c4b(255, 0, 0, 255)
local color_green4 = cc.c4b(0, 255, 0, 255)
function gameUtil.createItemWidget( itemID, num, max )
    local res = gameUtil.getItemIconRes(itemID)
    local imageView = ccui.ImageView:create()
    imageView:loadTexture(res)
    imageView:setAnchorPoint(cc.p(0, 0))

    local width = imageView:getContentSize().width
    if num > 0 or max then
        local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
        sprite_ditu:setAnchorPoint(cc.p(1, 0))
        sprite_ditu:setPosition(cc.p(width - 2, 0))
        imageView:addChild(sprite_ditu)

        local ttfConfig = {}
        ttfConfig.fontFilePath = "font/youyuan.TTF"
        ttfConfig.fontSize = 20
        ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
        ttfConfig.customGlyphs = nil
        ttfConfig.distanceFieldEnabled = true
        ttfConfig.outlineSize = 1
        
        local str = ""..num
        local needBeRed = false
        if max then
            str = str.."/"..max
            if num < max then
                needBeRed = true
            end
        end
        local label = cc.Label:createWithTTF(ttfConfig,str,cc.TEXT_ALIGNMENT_CENTER)
        label:setAnchorPoint(cc.p(1,0))
        label:setPosition(cc.p(width - 2, 0))
        label:enableGlow(cc.c4b(255, 255, 0, 255))
        if needBeRed then
            label:setTextColor(color_red4)
        else
            label:setTextColor(color_green4)
        end

        imageView:addChild(label)

        local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
        sprite_ditu:setScaleX(scaleX)
    end
    return imageView
end

function gameUtil.createIconWithNum( res , num)
    local path = "res/icon/head/touxiang.png"
    if gameUtil.file_exists(res) then
        path = res
    end
    
    local imageView = ccui.ImageView:create()
    imageView:loadTexture(path)
    imageView:setAnchorPoint(cc.p(0, 0))

    if num > 0 then
        local width = imageView:getContentSize().width
        local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
        sprite_ditu:setAnchorPoint(cc.p(1, 0))
        sprite_ditu:setPosition(cc.p(width - 2, 0))
        imageView:addChild(sprite_ditu)

        local ttfConfig = {}
        ttfConfig.fontFilePath = "font/youyuan.TTF"
        ttfConfig.fontSize = 20
        ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
        ttfConfig.customGlyphs = nil
        ttfConfig.distanceFieldEnabled = true
        ttfConfig.outlineSize = 1
        
        local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER)
        label:setAnchorPoint(cc.p(1,0))
        label:setPosition(cc.p(width - 2, 0))
        label:setTextColor( cc.c4b(0, 255, 0, 255) )
        label:enableGlow(cc.c4b(255, 255, 0, 255))
        imageView:addChild(label)

        local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
        sprite_ditu:setScaleX(scaleX)
    end
    return imageView
end

function gameUtil.createSkinIcon(id)
    local skinRes = INITLUA:getResWithId("skin", id)
    return gameUtil.createIconWithNum( skinRes.Icon..".png" , 0)
end

function gameUtil.createTouXiang( v )
    local Image_icon = ccui.ImageView:create()
    Image_icon:setName("TouXiang")

    -- 创建头像
    local c, num, jin = gameUtil.getColor(v.jinlv)
    local touxiang = ccui.ImageView:create()
    touxiang:loadTexture(gameUtil.getHeroIcon(v.id))
    touxiang:setName("touxiang")
    -- print("createTouXiang   "..v.id)
    --local Image_di = ccui.ImageView:create()
    Image_icon:loadTexture("res/icon/jiemian/jm_hero"..jin..".png")
    local Image_kuang = ccui.ImageView:create()
    Image_kuang:loadTexture("res/icon/jiemian/jm_herokuang"..jin..".png")
    touxiang:setScale(Image_icon:getContentSize().width/touxiang:getContentSize().width)
    Image_kuang:setName("Image_kuang")
    Image_icon:addChild(touxiang)
    Image_icon:addChild(Image_kuang)
    touxiang:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)
    Image_kuang:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)

    print("Image_icon:getContentSize().height   "..Image_icon:getContentSize().height)

    for j=1, num do
        local jin_flag = ccui.ImageView:create()
        jin_flag:loadTexture("res/icon/jiemian/jm_herojinjie"..jin..".png")
        Image_icon:addChild(jin_flag)
        jin_flag:setName("jin_flag"..j)
        jin_flag:setPosition(Image_icon:getContentSize().width*j/(num+1), Image_icon:getContentSize().height-2)
    end

    local lvTextNode = cc.CSLoader:createNode("lvText.csb")
    lvTextNode:setName("TextLvNode")
    lvTextNode:getChildByName("Text_lv"):setString(gameUtil.getHeroLv(v.exp, v.jinlv))
    lvTextNode:setPosition(cc.p(lvTextNode:getChildByName("Text_lv"):getContentSize().width/2 + 5, 30))
    Image_icon:addChild(lvTextNode)

    -- 添加星级
    local limit = v.xinlv > 5 and 5 or v.xinlv
    for i=1, limit do
        local image_xing = ccui.ImageView:create()
        if v.xinlv <= 5 then
            image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
            image_xing:setScale(0.6)
        else
            if v.xinlv - i >= 5 then
                image_xing:loadTexture("res/UI/icon_yueliang_normal.png")
                image_xing:setScale(1)
            else
                image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
                image_xing:setScale(0.6)
            end
        end
        image_xing:setPosition(Image_icon:getContentSize().width * 0.5 + (i-limit/2)*15 - 5, 10)
        Image_icon:addChild(image_xing)
        image_xing:setName("xinxin"..i)
    end
    Image_icon:setAnchorPoint(cc.p(0, 0.5))
    return Image_icon
end

function gameUtil.setTouXiang( node, v )
    -- 创建头像
    local c, num, jin = gameUtil.getColor(v.jinlv)
    local touxiang = node:getChildByName("touxiang")
    touxiang:loadTexture(gameUtil.getHeroIcon(v.id))
    -- print("createTouXiang   "..v.id)

    node:loadTexture("res/icon/jiemian/jm_hero"..jin..".png")
    local Image_kuang = node:getChildByName("Image_kuang")
    Image_kuang:loadTexture("res/icon/jiemian/jm_herokuang"..jin..".png")

    for j=1, 20 do
        local jin_flag = node:getChildByName("jin_flag"..j)
        if j <= num then
            if not jin_flag then
                jin_flag = ccui.ImageView:create()
                node:addChild(jin_flag)
                jin_flag:setName("jin_flag"..j)
            end
            jin_flag:loadTexture("res/icon/jiemian/jm_herojinjie"..jin..".png")
            
            jin_flag:setPosition(node:getContentSize().width*j/(num+1), node:getContentSize().height-2)
            jin_flag:setVisible(true)
        else
            if jin_flag then
                jin_flag:setVisible(false)
            end
        end
    end

    local lvTextNode = node:getChildByName("TextLvNode")
    if not lvTextNode then
        lvTextNode = cc.CSLoader:createNode("lvText.csb")
        node:addChild(lvTextNode)
    end
    lvTextNode:setName("TextLvNode")
    lvTextNode:getChildByName("Text_lv"):setString(gameUtil.getHeroLv(v.exp, v.jinlv))
    lvTextNode:setPosition(cc.p(lvTextNode:getChildByName("Text_lv"):getContentSize().width/2 + 5, 30))
    

    -- 添加星级
    local limit = v.xinlv > 5 and 5 or v.xinlv
    for i=1, 5 do
        local image_xing = node:getChildByName("xinxin"..i)
        if i <= limit then
            
            if not image_xing then
                image_xing = ccui.ImageView:create()
                node:addChild(image_xing)
                image_xing:setName("xinxin"..i)
            end
            if v.xinlv <= 5 then
                image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
                image_xing:setScale(0.6)
            else
                if v.xinlv - i >= 5 then
                    image_xing:loadTexture("res/UI/icon_yueliang_normal.png")
                    image_xing:setScale(1)
                else
                    image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
                    image_xing:setScale(0.6)
                end
            end
            image_xing:setPosition(node:getContentSize().width * 0.5 + (i-limit/2)*15 - 5, 10)
            
            image_xing:setVisible(true)
        else
            if image_xing then
                image_xing:setVisible(false)
            end
        end
    end
    node:setAnchorPoint(cc.p(0, 0.5))
    return node
end

function gameUtil.createTouXiangSimple( v )
    local Image_icon = ccui.ImageView:create()
    Image_icon:setName("TouXiang")
    -- 创建头像
    local c, num, jin = gameUtil.getColor(v.jinlv)
    local touxiang = ccui.ImageView:create()
    touxiang:loadTexture(gameUtil.getHeroIcon(v.id))
    --local Image_di = ccui.ImageView:create()
    Image_icon:loadTexture("res/icon/jiemian/jm_hero"..jin..".png")
    local Image_kuang = ccui.ImageView:create()
    Image_kuang:loadTexture("res/icon/jiemian/jm_herokuang"..jin..".png")
    touxiang:setScale(Image_icon:getContentSize().width/touxiang:getContentSize().width)
    Image_icon:addChild(touxiang)
    Image_icon:addChild(Image_kuang)
    touxiang:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)
    Image_kuang:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)
    -- for j=1, num do
    --     local jin_flag = ccui.ImageView:create()
    --     jin_flag:loadTexture("res/icon/jiemian/jm_herojinjie"..jin..".png")
    --     Image_icon:addChild(jin_flag)
    --     jin_flag:setPosition(Image_icon:getContentSize().width*j/(num+1), Image_icon:getContentSize().height-2)
    -- end

    Image_icon:setAnchorPoint(cc.p(0, 0))
    return Image_icon
end

function gameUtil:goToSomeWhere( p, LayerName, param)
    if LayerName == "HeroLayer" then
        param.addType = 999
        local HeroLayer = require("src.app.views.layer.HeroLayer").new(param)
        local size  = cc.Director:getInstance():getWinSize()
        mm.self:addChild(HeroLayer, MoGlobalZorder[2000002])
        HeroLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(HeroLayer)
    elseif LayerName == "HeroListLayer" then
        mm.pushLayoer( {scene = mm.self, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.HeroListLayer",
                             resName = "HeroListLayer",params = param} )
    elseif LayerName == "PKLayer" then
        mm.pushLayoer( {scene = mm.self, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.PKLayer",
                                 resName = "PKLayer",params = param} )
        game:dispatchEvent({name = EventDef.UI_MSG, code = "openPkLayer"})
    elseif LayerName == "Main" then
        mm.clearLayer()
    elseif LayerName == "Rank" then
        mm.pushLayoer( {scene = mm.self, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.PVPLayer",
                             resName = "PVPLayer",params = param} )
    elseif LayerName == "BuyExp" then
        if gameUtil.isFunctionOpen(closeFuncOrder.EXP_EXCHANGE) == true then
            local ExpBuy = require("src.app.views.layer.BuyExpLayer").create({})
            local size  = cc.Director:getInstance():getWinSize()
            mm.self:addChild(ExpBuy, MoGlobalZorder[2000002])
            ExpBuy:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(ExpBuy)
        end
    elseif LayerName == "BuyGold" then
        if gameUtil.isFunctionOpen(closeFuncOrder.GOLD_EXCHANGE) == true then
            local DianjinshouLayer = require("src.app.views.layer.DianjinshouLayer").new({})
            local size  = cc.Director:getInstance():getWinSize()
            mm.self:addChild(DianjinshouLayer, MoGlobalZorder[2000002])
            DianjinshouLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(DianjinshouLayer)
        end
    elseif LayerName == "recharge" then
        gameUtil.showChongZhi(mm.self)
    elseif LayerName == "talk" then
        local TalkLayer = require("src.app.views.layer.TalkLayer").new(param.app)
        TalkLayer:setName("TalkLayer")
        local size  = cc.Director:getInstance():getWinSize()
        mm.self:addChild(TalkLayer, MoGlobalZorder[2000002])
        TalkLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(TalkLayer)
    elseif LayerName == "StageDetailLayer" then
        local jumpType = param.type
        local param = {}

        if jumpType == 1 then
            param.stageType = 3
        elseif jumpType == 2 then
            param.stageID = 1093677361
        elseif jumpType == 3 then
            param.stageID = 1093677105
        end
        
        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = "StageDetailLayer", param = param})
    elseif LayerName == "ShangChengLayer" then
        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = "ShangChengLayer"})
    elseif LayerName == "JJCLayer" then
        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = "JJCLayer"})
    elseif LayerName == "PVPLayer" then
        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = "PVPLayer"})
    end
end

function gameUtil.canShengXing( id, xinlv )
    if xinlv >= #PEIZHI.xinji then
        return 0
    end
    local hunshiId =  gameUtil.getHeroTab( id ).herohunshiID
    local num = gameUtil.getHunshiNumByid( hunshiId )
    local needNum = PEIZHI.xinji[xinlv + 1].num

    if num >= needNum then
        return 1
    else
        return 0
    end
end

function gameUtil.canZhaoHuan()
    local camp = mm.data.playerinfo.camp
    local unitRes = INITLUA:getUnitResByCamp(camp)
    for k,v in pairs(unitRes) do
        if v.Nation == camp then
            local tab = {}
            tab.ID = v.ID
            local flag = 0
            for p,q in pairs(mm.data.playerHero) do
                if q.id == tab.ID then
                    flag = 1
                    break
                end
            end
            if flag == 0 then
                local hunshiId =  gameUtil.getHeroTab( tab.ID ).herohunshiID
                local num = gameUtil.getHunshiNumByid( hunshiId )
                local needNum = 0
                for i=1, v.chushixin do
                    needNum = needNum + PEIZHI.xinji[i].num
                end
                if num >= needNum then
                    return 1
                end
            end
        end
    end
    return 0
end

-- 召唤所需魂石：
--local PEIZHI = PEIZHI
function gameUtil.getZhaoHuanHunshiNum(heroRes)
    local needNum = 0
    for i=1, heroRes.chushixin do
        needNum = needNum + PEIZHI.xinji[i].num
    end

    return needNum
end

function gameUtil.canShengJi( t )
    local lv = gameUtil.getHeroLv(t.exp, t.jinlv)
    local NeedExp = INITLUA:getBckResNeedExpByLv(t.jinlv, lv)
    if NeedExp > mm.data.playerinfo.exppool then
        return 0
    else
        return 1
    end
end

function gameUtil.canJinJie( t )
    if gameUtil.getHeroLv(t.exp, t.jinlv) < 25 then
        return 0
    end
    if t.eqTab == nil then
        return 0
    end
    if #t.eqTab < 6 then
        return 0
    end
    return 1
end

function gameUtil.GetStarMaxHeroId( ... )
    local curHero
    for k,v in pairs(mm.data.playerHero) do
        if curHero == nil then
            curHero = {}
            curHero.zhanli = gameUtil.Zhandouli(v, mm.data.playerHero, mm.data.playerExtra.pkValue)
            curHero.id = v.id
            curHero.xinlv = v.xinlv
            curHero.can = gameUtil.canShengXing(v.id, v.xinlv)
        else
            local zhanli = gameUtil.Zhandouli(v, mm.data.playerHero, mm.data.playerExtra.pkValue)
            local can = gameUtil.canShengXing(v.id, v.xinlv)
            local xinlv = v.xinlv
            if curHero.can < can then
                curHero.id = v.id
                curHero.zhanli = zhanli
                curHero.can = can
                curHero.xinlv = xinlv
            elseif curHero.zhanli < zhanli then
                curHero.id = v.id
                curHero.zhanli = zhanli
                curHero.can = can
                curHero.xinlv = xinlv
            end
        end
    end
    return curHero.id
end

function gameUtil.GetLevelMaxHeroId( ... )
    local curHero
    for k,v in pairs(mm.data.playerHero) do
        if curHero == nil then
            curHero = {}
            curHero.zhanli = gameUtil.Zhandouli(v, mm.data.playerHero, mm.data.playerExtra.pkValue)
            curHero.id = v.id
            curHero.lv = v.lv
            curHero.can = gameUtil.canShengJi(v)
        else
            local zhanli = gameUtil.Zhandouli(v, mm.data.playerHero, mm.data.playerExtra.pkValue)
            local can = gameUtil.canShengJi(v)
            local xinlv = v.xinlv
            if curHero.can < can then
                curHero.id = v.id
                curHero.zhanli = zhanli
                curHero.can = can
                curHero.xinlv = xinlv
            elseif curHero.zhanli < zhanli then
                curHero.id = v.id
                curHero.zhanli = zhanli
                curHero.can = can
                curHero.xinlv = xinlv
            end
        end
    end
    return curHero.id
end

function gameUtil.GetQualityMaxHeroId( ... )
    local curHero
    for k,v in pairs(mm.data.playerHero) do
        if curHero == nil then
            curHero = {}
            curHero.zhanli = gameUtil.Zhandouli(v, mm.data.playerHero, mm.data.playerExtra.pkValue)
            curHero.id = v.id
            curHero.lv = v.lv
            curHero.can = gameUtil.canJinJie(v)
        else
            local zhanli = gameUtil.Zhandouli(v, mm.data.playerHero, mm.data.playerExtra.pkValue)
            local can = gameUtil.canJinJie(v)
            local xinlv = v.xinlv
            if curHero.can < can then
                curHero.id = v.id
                curHero.zhanli = zhanli
                curHero.can = can
                curHero.xinlv = xinlv
            elseif curHero.zhanli < zhanli then
                curHero.id = v.id
                curHero.zhanli = zhanli
                curHero.can = can
                curHero.xinlv = xinlv
            end
        end
    end
    return curHero.id
end

function gameUtil.getSkillIndex(heroId, skillId)
    local heroRes = gameUtil.getHeroTab(heroId)
    if heroRes then
        local index = 1
        for i=1, #heroRes.Skills do
            if skillId == heroRes.Skills[i] then
                index = i
                break
            end
        end
        for i=1, #heroRes.SkillsEx do
            if skillId == heroRes.SkillsEx[i] then
                index = i + #heroRes.Skills
                break
            end
        end
        return index
    else
        return nil
    end
end


function gameUtil.getHeroSkillLv( heroId, skillId,playHero )
    local playHero = playHero or mm.data.playerHero
    local index = gameUtil.getSkillIndex(heroId, skillId)
    if index then
        for k,v in pairs(playHero) do
            if v.id == heroId then
                for k1,v1 in pairs(v.skill) do
                    if v1.index == index then
                        return v1.lv
                    end
                end
            end
        end
    end
    return nil
end

function gameUtil.getReGroupGoodsByListForMail( list, itemType )
    local fullItem = {}
    local allCellFull = false ---总格子数超出
    local typeCellFull = false ---单个类型的格子数超出

    local allCellNum = 0
    local maxAllCellNum = 70
    for k,v in pairs(list) do
        local item = nil
        
        local maxCellItemNum = 2
        local maxSameCellNum = 50
        

        --0 1 2 3 4
        if itemType == 0 or itemType == 1 or itemType == 2 or itemType == 3 or itemType == 4 then
            item = INITLUA:getEquipByid( v.id )
        else
            item = INITLUA:getItemByid( v.id )
        end

        maxCellItemNum = item.eq_count
        maxSameCellNum = item.eq_groupcount
        
        local needCellNum = math.ceil(v.num / maxCellItemNum)
        
        if needCellNum > maxAllCellNum then
            --单个物品的格子数超出总格子数
            table.insert(fullItem, v)
            allCellNum = allCellNum + needCellNum
        else
            if needCellNum > maxSameCellNum then
                --单类物品的格子数超出此类格子数限制
                if allCellNum > maxAllCellNum then
                    --已有的格子数超出总格子数限制
                    table.insert(fullItem, v)
                    allCellNum = allCellNum + needCellNum
                else
                    if allCellNum + needCellNum > maxAllCellNum then
                        table.insert(fullItem, v)
                        allCellNum = allCellNum + needCellNum
                    else
                        if allCellNum + needCellNum > maxSameCellNum then
                            table.insert(fullItem, v)
                            allCellNum = allCellNum + needCellNum
                        else
                            allCellNum = allCellNum + needCellNum
                        end
                    end
                end
            else
                if allCellNum > maxAllCellNum then
                    table.insert(fullItem, v)
                    allCellNum = allCellNum + needCellNum
                else
                    if allCellNum + needCellNum > maxAllCellNum then
                        table.insert(fullItem, v)
                        allCellNum = allCellNum + needCellNum
                    else
                        if allCellNum + needCellNum > maxAllCellNum then
                            table.insert(fullItem, v)
                            allCellNum = allCellNum + needCellNum
                        else
                            allCellNum = allCellNum + needCellNum
                        end
                    end
                end
            end
        end
    end

    local full = allCellNum - maxAllCellNum
    return fullItem, full
end

function gameUtil.getReGroupGoodsByList( list, itemType )
    local reGroupGoods = {}
    local allFull = false
    local allCellNum = 0
    local maxAllCellNum = 10

    for k,v in pairs(list) do
        local item = nil
        
        local maxCellItemNum = 3
        local maxSameCellNum = 8

        --0 1 2 3 4
        if itemType == 0 or itemType == 1 or itemType == 2 or itemType == 3 or itemType == 4 then
            item = INITLUA:getEquipByid( v.id )
        else
            item = INITLUA:getItemByid( v.id )
        end

        maxCellItemNum = item.eq_count
        maxSameCellNum = item.eq_groupcount

        local needCellNum = math.ceil(v.num / maxCellItemNum)

        local left = v.num % maxCellItemNum
        local finalCellNum = needCellNum
        
        local currentCellNum = #reGroupGoods
        local leftCellNum = maxAllCellNum - currentCellNum
        
        if leftCellNum <= 0  then
            allFull = true
            break
        end
        
        local leftSameCell = maxSameCellNum - needCellNum
        if leftSameCell < 0 then
            leftSameCell = maxSameCellNum
        else
            leftSameCell = needCellNum
        end
        
        if leftCellNum < leftSameCell then
            leftSameCell = leftCellNum

        end

        finalCellNum = leftSameCell

        local addCellNum = 0
        
        if finalCellNum < needCellNum then
            for i=1,finalCellNum do
                addCellNum = addCellNum + 1
                local cellItem = {}
                cellItem.id = v.id
                cellItem.num = maxCellItemNum
                table.insert(reGroupGoods, cellItem)
            end
        else
            finalCellNum = finalCellNum - 1
            for i=1,finalCellNum do
                addCellNum = addCellNum + 1
                local cellItem = {}
                cellItem.id = v.id
                cellItem.num = maxCellItemNum
                table.insert(reGroupGoods, cellItem)
            end

            local cellItem = {}
            cellItem.id = v.id
            cellItem.num = left
            table.insert(reGroupGoods, cellItem)
        end
    end
    return reGroupGoods
end

function gameUtil.reGroupGoods( ... )
    local maxEquipCellItemNum = 10
    local maxEquipAllCellNum = 100
    local maxEquipSameCellNum = 5

    local maxHunshiCellItemNum = 10
    local maxHunshiAllCellNum = 100
    local maxHunshiSameCellNum = 5

    local maxItemCellItemNum = 10
    local maxItemAllCellNum = 100
    local maxItemSameCellNum = 5

    -----------------------检查装备情况----------------------------------

    local reGroupEquip = gameUtil.getReGroupGoodsByList(mm.data.playerEquip,maxEquipCellItemNum,maxEquipSameCellNum,maxEquipAllCellNum, true)
    local reGroupHunshi = gameUtil.getReGroupGoodsByList(mm.data.playerHunshi,maxHunshiCellItemNum,maxHunshiSameCellNum,maxHunshiAllCellNum, true)
    local reGroupItem = gameUtil.getReGroupGoodsByList(mm.data.playerItem,maxItemCellItemNum,maxItemSameCellNum,maxItemAllCellNum, true)

    local reGroupGoods = {}
    reGroupGoods.reGroupEquip = reGroupEquip
    reGroupGoods.reGroupHunshi = reGroupHunshi
    reGroupGoods.reGroupItem = reGroupItem

    return reGroupGoods
end


--  输出错误码
function gameUtil.CCLOGMoGameRet( code )
    require "src/app/views/mmExtend/MoGameRet"
    if MoGameRet then
        if MoGameRet[code] then
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = MoGameRet[code],z = 999999})
            return
        end
    end
    gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = MoGameRet[900001],z = 999999})
end

--  返回错误码内容
function gameUtil.GetMoGameRetStr( code )
    require "src/app/views/mmExtend/MoGameRet"
    if MoGameRet then
        if MoGameRet[code] then
           return MoGameRet[code]
        end
    end
    return MoGameRet[900001]
end

local storeRecordTime = {}
function gameUtil.setStoreRecordTime( storeID, time )
    for k,v in pairs(storeRecordTime) do
        if v.storeID == storeID then
            storeRecordTime[k].time = time
            return
        end
    end
    local temp = {}
    temp.storeID = storeID
    temp.time = time
    table.insert(storeRecordTime, temp)
end

function gameUtil.getStoreRecordTime( storeID )
    for k,v in pairs(storeRecordTime) do
        if v.storeID == storeID then
            return v.time
        end
    end
    return 0
end

function gameUtil.createSkeletonAnimationForUnit(json,atlas,scale)

    local t = {}
    t.name = json
    t.json = json
    t.atlas = atlas
    t.scale = scale
    t.type = "sp"
    local node = gameUtil.getCSLoaderObj(t)

    return node
end

function gameUtil.createSkeletonAnimation(json,atlas,scale)
    -- local Skeleton = sp.SkeletonAnimation:create(json,atlas,scale)

    local t = {}
    t.name = json
    t.json = json
    t.atlas = atlas
    t.scale = scale
    t.type = "sp"
    local node = gameUtil.getCSLoaderObj(t)

    return node
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
    --     -- Skeleton:setOpacityModifyRGB(false)
    --     -- Skeleton:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA))
    -- elseif (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    --     Skeleton:setOpacityModifyRGB(false)
    --     Skeleton:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA))
    -- elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
    
    -- end
end

function gameUtil.createSkeAnmion( tab )
    local path = tab.path or "res/Effect/uiEffect/"
    local name = tab.name
    local scale = tab.scale or 1
    local zdyName = tab.zdyName

    local json = path .. name .."/" .. name ..".json"
    local atlas = path .. name .."/" .. name ..".atlas"

    local t = {}
    t.name = zdyName or json 
    t.json = json
    t.atlas = atlas
    t.scale = scale
    t.type = "sp"
    local node = gameUtil.getCSLoaderObj(t)

    
    return node --sp.SkeletonAnimation:create(json,atlas,scale)
end

function gameUtil.createHeroSkin(path,scale)
    local json,atlas,skel = getSpineRes(path)
    if  (_file_exists(json) or _file_exists(skel)) and _file_exists(atlas) then
        return gameUtil.createSkeletonAnimation(json,atlas,scale)
    end

    return nil  
end

-- check : skin id的检查不放这一层 altSkinId(默认皮肤)
function gameUtil.createHeroSkinEx(heroRes, skinId, altSkinId, scale)

    if skinId == 0 then
        return
    end

    local curScale = scale
    if not curScale then
        curScale = 1
    end
    local curSkinRes = INITLUA:getResWithId("skin", skinId)
    if not curSkinRes then
        return
    end

    local src = curSkinRes.Src
    -- TODO::gameUtil_createSkeletonAnimation 函数不安全！
    local curNode = gameUtil.createHeroSkin(src,curScale)
 
    if not curNode then
        curSkinRes = INITLUA:getResWithId("skin", altSkinId)
        if curSkinRes then
            src = curSkinRes.Src
            curNode = gameUtil.createHeroSkin(src,curScale)
        end
    end
    if not curNode then
        return
    end
    curNode:update(0.012)
    curNode:setAnimation(0, "stand", true)
    curNode:setAnchorPoint(0.5, 0.5)
    return curNode
end

function gameUtil.showDianJinShou( layer, bTishi )
    if gameUtil.isFunctionOpen(closeFuncOrder.GOLD_EXCHANGE) == true then
        local DianjinshouLayer = require("src.app.views.layer.DianjinshouLayer").new({bTishi = bTishi})
        local size  = cc.Director:getInstance():getWinSize()
        layer:addChild(DianjinshouLayer, 50)
        DianjinshouLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(DianjinshouLayer)
    end
end

function gameUtil.showBuyDialog( layer, bTishi )
    local ExchangeLayer = require("src.app.views.layer.ExchangeLayer").new({bTishi = bTishi})
    local size  = cc.Director:getInstance():getWinSize()
    layer:addChild(ExchangeLayer, 50)
    ExchangeLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(ExchangeLayer)
end

function gameUtil.setSollowView(sollowView, maxItem, begainItem, tab, itemHeight,res, fun, callBack)
    sollowView:setScrollBarEnabled(false)
    local tempTab = {}
    local maxItem = maxItem

    if begainItem > #tab - maxItem then
        begainItem = #tab - maxItem > 0 and #tab - maxItem or 1
    end

    tempTab.allItem = #tab
    tempTab.existItem = #tab > maxItem and maxItem or #tab
    tempTab.ItemHeight = itemHeight

    
    local size = sollowView:getInnerContainerSize()
    sollowView:setInnerContainerSize(cc.size(630,tempTab.ItemHeight * tempTab.allItem))
    sollowView:setBounceEnabled(true)

    tempTab.sizeY = sollowView:getSize().height

    local container = sollowView:getInnerContainer()
    tempTab.begainPosY = container:getPositionY()
    tempTab.begPosY = tempTab.sizeY - tempTab.ItemHeight * tempTab.allItem

    tempTab.newItemEndIndex = begainItem + tempTab.existItem -1 
    tempTab.newItemHeadIndex = begainItem

    local function scrollViewDidScroll(sender,eventType)
        if true then
            if sollowView:getChildrenCount() == 0 then
                return
            end

            local container = sollowView:getInnerContainer()
            local cony = container:getPositionY()
            local conSizeH = container:getSize().height
            if cony <= tempTab.begPosY then
                return
            end

            if cony >= 0 then
                return
            end

            local isUp = nil
            if tempTab.begainPosY > cony then
                isUp = false
                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionY()
                        end,
                        isAscending = true
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            elseif tempTab.begainPosY < cony then
                isUp = true

                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionY()
                        end,
                        isAscending = false
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            end
            tempTab.begainPosY = cony
            for i=1,tempTab.existItem do 
                local y = tempTab.cell[i]:getPositionY() + cony - tempTab.sizeY
                if y > 0 and isUp == true and (tempTab.newItemEndIndex + 1) <= tempTab.allItem then
                    local toDy = tempTab.cell[i]:getPositionY() - tempTab.existItem * tempTab.ItemHeight--minY - tempTab.ItemHeight
                    if toDy >= 0 and toDy <= conSizeH - tempTab.ItemHeight then
                        tempTab.cell[i]:setPositionY(toDy)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex + 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex + 1
                        fun(tempTab.newItemEndIndex,tab[tempTab.newItemEndIndex], tempTab.cell[i],1)
                    end
                elseif y < (- tempTab.sizeY - tempTab.ItemHeight) and isUp == false and (tempTab.newItemHeadIndex - 1) >= 1 then
                    local toDy = tempTab.cell[i]:getPositionY() + tempTab.existItem * tempTab.ItemHeight--maxY + tempTab.ItemHeight
                    if toDy >= 0 and toDy <= conSizeH - tempTab.ItemHeight then
                        tempTab.cell[i]:setPositionY(toDy)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex - 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex - 1
                        fun(tempTab.newItemHeadIndex,tab[tempTab.newItemHeadIndex], tempTab.cell[i],1)
                    end
                end
            end
        end
    end

    local onePosY = container:getSize().height - tempTab.ItemHeight * tempTab.allItem
    if onePosY < 0 then onePosY = 0 end

    tempTab.cell = {}
    for i=1,tempTab.existItem do
        local cell = cc.CSLoader:createNode(res)
        cell = cell:getChildByName("Image_bg"):clone()
        -- cell:getChildByTag(180464):addTouchEventListener(handler(tempTab,self.fenjieBack))
        -- cell:getChildByTag(320771):addTouchEventListener(handler(tempTab,self.exchangeBack))
        cell:addTouchEventListener(callBack)

        sollowView:addChild(cell)
        cell:setPosition(0, onePosY + tempTab.ItemHeight * (tempTab.allItem - i - (begainItem - 1)))
        tempTab.cell[i] = cell
        fun(begainItem + i - 1, tab[begainItem + i - 1], cell,1)
    end

    
    sollowView:addEventListenerScrollView(scrollViewDidScroll)

    return tempTab.cell
end




function gameUtil.setSollowViewNew(sollowView, maxItem, begainItem, tab, itemHeight,res, fun, callBack, cellTab)
    local tempTab = {}
    sollowView:setScrollBarEnabled(false)

    tempTab.sizeY = sollowView:getSize().height

    local maxItem = math.ceil(tempTab.sizeY / itemHeight) + 1
    print("maxItemmaxItemmaxItem    "..maxItem)

    if begainItem > #tab - maxItem then
        begainItem = #tab - maxItem > 0 and #tab - maxItem or 1
    end
    print("begainItembegainItembegainItemNew    "..begainItem)

    tempTab.allItem = #tab
    tempTab.existItem = #tab > maxItem and maxItem or #tab
    tempTab.ItemHeight = itemHeight

    
    local size = sollowView:getInnerContainerSize()
    sollowView:setInnerContainerSize(cc.size(630,tempTab.ItemHeight * tempTab.allItem))
    -- sollowView:setBounceEnabled(false)

    

    local container = sollowView:getInnerContainer()
    tempTab.begPosY = tempTab.sizeY - tempTab.ItemHeight * tempTab.allItem
    tempTab.begainPosY = container:getPositionY()
    
    print("tempTab.begainPosY  "..tempTab.begainPosY)


    tempTab.newItemEndIndex = begainItem + tempTab.existItem -1 
    tempTab.newItemHeadIndex = begainItem

    local function scrollViewDidScroll(sender,eventType)
        if true then
            if sollowView:getChildrenCount() == 0 then
                return
            end

            local container = sollowView:getInnerContainer()
            local cony = container:getPositionY()
            local conSizeH = container:getSize().height
            if cony <= tempTab.begPosY then
                return
            end

            if cony >= 0 then
                return
            end

            local isUp = nil
            if tempTab.begainPosY > cony then
                isUp = false
                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionY()
                        end,
                        isAscending = true
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            elseif tempTab.begainPosY < cony then
                isUp = true

                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionY()
                        end,
                        isAscending = false
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            end
            tempTab.begainPosY = cony
            for i=1,tempTab.existItem do 
                local y = tempTab.cell[i]:getPositionY() + cony - tempTab.sizeY
                if y > 0 and isUp == true and (tempTab.newItemEndIndex + 1) <= tempTab.allItem then
                    local toDy = tempTab.cell[i]:getPositionY() - tempTab.existItem * tempTab.ItemHeight--minY - tempTab.ItemHeight
                    if toDy >= 0 and toDy <= conSizeH - tempTab.ItemHeight then
                        tempTab.cell[i]:setPositionY(toDy)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex + 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex + 1
                        fun(tempTab.newItemEndIndex,tab[tempTab.newItemEndIndex], tempTab.cell[i],i)
                    end
                elseif y < (- tempTab.sizeY - tempTab.ItemHeight) and isUp == false and (tempTab.newItemHeadIndex - 1) >= 1 then
                    local toDy = tempTab.cell[i]:getPositionY() + tempTab.existItem * tempTab.ItemHeight--maxY + tempTab.ItemHeight
                    if toDy >= 0 and toDy <= conSizeH - tempTab.ItemHeight then
                        tempTab.cell[i]:setPositionY(toDy)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex - 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex - 1
                        fun(tempTab.newItemHeadIndex,tab[tempTab.newItemHeadIndex], tempTab.cell[i],i)
                    end
                end
            end
        end
    end

    local onePosY = container:getSize().height - tempTab.ItemHeight * tempTab.allItem
    if onePosY < 0 then onePosY = 0 end

    tempTab.cell = cellTab
    for i=1,tempTab.existItem do
        if not tempTab.cell[i] then
            performWithDelay(sollowView, function( ... )
                local cell = ccui.ImageView:create()
                -- cell:addTouchEventListener(callBack)
                cell:setAnchorPoint(cc.p(0,0))

                sollowView:addChild(cell)
                cell:setPosition(0, onePosY + tempTab.ItemHeight * (tempTab.allItem - i - (begainItem - 1)))
                tempTab.cell[i] = cell
                
                fun(begainItem + i - 1, tab[begainItem + i - 1], cell,i)

                tempTab.cell[i]:retain()
                tempTab.cell[i]:retain()

            end, 0.032 * i)
        else
            sollowView:addChild(tempTab.cell[i])
            tempTab.cell[i]:setPosition(0, onePosY + tempTab.ItemHeight * (tempTab.allItem - i - (begainItem - 1)))
            fun(begainItem + i - 1, tab[begainItem + i - 1], tempTab.cell[i],i)
        end
    end

    
    sollowView:addEventListenerScrollView(scrollViewDidScroll)

    return tempTab.cell
end

function gameUtil.setSollowViewHor(sollowView, maxItem, begainItem, tab, itemWidth,res, fun, callBack, cellTab)
    local tempTab = {}
    tempTab.tab = tab
    sollowView:setScrollBarEnabled(false)

    tempTab.sizeX = sollowView:getSize().width

    local maxItem = math.ceil(tempTab.sizeX / itemWidth) + 2
    print("maxItemmaxItemmaxItem    "..maxItem)

    local initBegainItem = begainItem
    if begainItem > #tab - maxItem then
        begainItem = #tab - maxItem + 1 > 0 and #tab - maxItem + 1 or 1
    end

    print("begainItembegainItembegainItemHor    "..begainItem)

    tempTab.allItem = #tab
    tempTab.existItem = #tab > maxItem and maxItem or #tab
    tempTab.ItemWidth = itemWidth

    
    local size = sollowView:getInnerContainerSize()
    sollowView:setInnerContainerSize(cc.size(tempTab.ItemWidth * tempTab.allItem, sollowView:getSize().height))
    -- sollowView:setBounceEnabled(false)

    local InnerContainerW =  tempTab.ItemWidth * tempTab.allItem
    

    local container = sollowView:getInnerContainer()
    -- tempTab.begPosX =  - tempTab.ItemWidth * (begainItem - 1)
    -- container:setPositionX(tempTab.begPosX)
    -- tempTab.begainPosX = container:getPositionX()
    -- print("tempTab.begainPosX     "..tempTab.begainPosX)

    performWithDelay(sollowView, function( ... )
        local showItemNum = math.ceil(tempTab.sizeX / itemWidth)
        if #tab > showItemNum and initBegainItem > (#tab - showItemNum)  then
            tempTab.begPosX =  - tempTab.ItemWidth * tempTab.allItem + tempTab.sizeX
            container:setPositionX(tempTab.begPosX)
            tempTab.begainPosX = container:getPositionX()
        else
            tempTab.begPosX =  - tempTab.ItemWidth * (begainItem - 1)
            container:setPositionX(tempTab.begPosX)
            tempTab.begainPosX = container:getPositionX()
        end

    end, 0.032)



    tempTab.newItemEndIndex = begainItem + tempTab.existItem -1 
    tempTab.newItemHeadIndex = begainItem

    local function scrollViewDidScroll(sender,eventType)
        if true then
            if sollowView:getChildrenCount() == 0 then
                return
            end

            local container = sollowView:getInnerContainer()
            local cony = container:getPositionX()
            local conSizeW = container:getSize().width
            if cony <= -InnerContainerW then
                return
            end

            if cony >= 0 then
                return
            end

            local isUp = nil
            if tempTab.begainPosX > cony then
                isRight = false
                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionX()
                        end,
                        isAscending = false
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            elseif tempTab.begainPosX < cony then
                isRight = true

                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionX()
                        end,
                        isAscending = true
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            end
            tempTab.begainPosX = cony
            for i=1,tempTab.existItem do 
                local x = tempTab.cell[i]:getPositionX() + cony - tempTab.sizeX
                if x > 0 and isRight == true and (tempTab.newItemEndIndex - 1) <= tempTab.allItem then
                    local toDx = tempTab.cell[i]:getPositionX() - tempTab.existItem * tempTab.ItemWidth
                    if toDx >= 0 and toDx <= conSizeW - tempTab.ItemWidth then
                        tempTab.cell[i]:setPositionX(toDx)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex - 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex - 1
                        fun(tempTab.newItemHeadIndex,tab[tempTab.newItemHeadIndex], tempTab.cell[i],i)
                    end
                elseif x < (- tempTab.sizeX - tempTab.ItemWidth) and isRight == false and (tempTab.newItemHeadIndex + 1) >= 1 then
                    local toDx = tempTab.cell[i]:getPositionX() + tempTab.existItem * tempTab.ItemWidth
                    if toDx >= 0 and toDx <= conSizeW - tempTab.ItemWidth then
                        tempTab.cell[i]:setPositionX(toDx)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex + 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex + 1
                        fun(tempTab.newItemEndIndex,tab[tempTab.newItemEndIndex], tempTab.cell[i],i)
                    end
                end
            end
        end
    end

    local onePosX = tempTab.ItemWidth * (begainItem - 1)
    -- if onePosX < 0 then onePosX = 0 end
    tempTab.cell = {}
    for i=1,tempTab.existItem do
        if not tempTab.cell[i] then
            -- performWithDelay(sollowView, function( ... )
                local cell = ccui.ImageView:create()
                -- cell:addTouchEventListener(callBack)
                local tabItem = tab[begainItem + i - 1]

                cell:setAnchorPoint(cc.p(0,0.5))
                cell:setTag(tabItem.id)

                sollowView:addChild(cell)

                local posxx =  tempTab.ItemWidth * (begainItem + i - 2)

                cell:setPosition(posxx, size.height*0.5)
                tempTab.cell[i] = cell
                fun(begainItem + i - 1, tabItem, cell,i)

                tempTab.cell[i]:retain()

            -- end, 0.032 * i)
        else
            sollowView:addChild(tempTab.cell[i])
            tempTab.cell[i]:setPosition(onePosX + tempTab.ItemWidth * (i - 1), 0)
            fun(begainItem + i - 1, tab[begainItem + i - 1], tempTab.cell[i],i)
        end
    end

    
    sollowView:addEventListenerScrollView(scrollViewDidScroll)

    return tempTab
end

function gameUtil.setSollowViewNewTest(sollowView, maxItem, begainItem, tab, itemHeight,res, fun, callBack, cellTab)
    local tempTab = {}
    sollowView:setScrollBarEnabled(false)

    tempTab.sizeY = sollowView:getSize().height

    local maxItem = math.ceil(tempTab.sizeY / itemHeight) + 2
    print("maxItemmaxItemmaxItem    "..maxItem)
    print("begainItembegainItembegainItemNew    "..begainItem)

    local initBegainItem = begainItem
    if begainItem > #tab - maxItem then
        begainItem = #tab - maxItem + 1 > 0 and #tab - maxItem + 1 or 1
    end
    print("begainItembegainItembegainItemNew 1   "..begainItem)

    local bTtem = begainItem

    tempTab.allItem = #tab
    tempTab.existItem = #tab > maxItem and maxItem or #tab
    tempTab.ItemHeight = itemHeight

    
    local size = sollowView:getInnerContainerSize()
    sollowView:setInnerContainerSize(cc.size(630,tempTab.ItemHeight * tempTab.allItem))
    -- sollowView:setBounceEnabled(false)

    

    local container = sollowView:getInnerContainer()
    -- tempTab.begPosY = tempTab.sizeY - tempTab.ItemHeight * tempTab.allItem
    -- tempTab.begainPosY = container:getPositionY()
    
    -- print("tempTab.begainPosY  "..tempTab.begainPosY)

    performWithDelay(sollowView, function( ... )
        local showItemNum = math.ceil(tempTab.sizeY / itemHeight)
        print("11111showItemNum   00000  showItemNum   "..showItemNum)
        if (#tab > showItemNum and initBegainItem > (#tab - showItemNum)) or ( #tab < (math.ceil(tempTab.sizeY / itemHeight) + 1))  then
            tempTab.begPosY =  0
            container:setPositionY(tempTab.begPosY)
            tempTab.begainPosY = container:getPositionY()
            print("11111showItemNum    111111 tempTab.begPosY   "..tempTab.begPosY)
        else
            tempTab.begPosY =  tempTab.sizeY + (initBegainItem - 1 - tempTab.allItem)  * itemHeight  
            container:setPositionY(tempTab.begPosY)
            tempTab.begainPosY = container:getPositionY()
            print("11111showItemNum    222222222 tempTab.begPosY   "..tempTab.begPosY)
        end

    end, 0.032)


    tempTab.newItemEndIndex = bTtem + tempTab.existItem -1 
    tempTab.newItemHeadIndex = bTtem

    local function scrollViewDidScroll(sender,eventType)
        if true then
            if sollowView:getChildrenCount() == 0 then
                return
            end

            local container = sollowView:getInnerContainer()
            local cony = container:getPositionY()
            local conSizeH = container:getSize().height
            -- if cony <= tempTab.begPosY then
            --     return
            -- end

            -- if cony >= 0 then
            --     return
            -- end

            local isUp = nil
            if tempTab.begainPosY > cony then
                isUp = false
                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionY()
                        end,
                        isAscending = true
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            elseif tempTab.begainPosY < cony then
                isUp = true

                local sortRules = {
                    {
                        func = function(v)
                            return v:getPositionY()
                        end,
                        isAscending = false
                    },
                    
                }
                tempTab.cell = util.powerSort(tempTab.cell, sortRules)
            end
            tempTab.begainPosY = cony
            for i=1,tempTab.existItem do 
                local y = tempTab.cell[i]:getPositionY() + cony - tempTab.sizeY
                if y > 0 and isUp == true and (tempTab.newItemEndIndex + 1) <= tempTab.allItem then
                    local toDy = tempTab.cell[i]:getPositionY() - tempTab.existItem * tempTab.ItemHeight--minY - tempTab.ItemHeight
                    if toDy >= 0 and toDy <= conSizeH - tempTab.ItemHeight then
                        tempTab.cell[i]:setPositionY(toDy)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex + 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex + 1
                        fun(tempTab.newItemEndIndex,tab[tempTab.newItemEndIndex], tempTab.cell[i],i)
                    end
                elseif y < (- tempTab.sizeY - tempTab.ItemHeight) and isUp == false and (tempTab.newItemHeadIndex - 1) >= 1 then
                    local toDy = tempTab.cell[i]:getPositionY() + tempTab.existItem * tempTab.ItemHeight--maxY + tempTab.ItemHeight
                    if toDy >= 0 and toDy <= conSizeH - tempTab.ItemHeight then
                        tempTab.cell[i]:setPositionY(toDy)
                        tempTab.newItemEndIndex = tempTab.newItemEndIndex - 1
                        tempTab.newItemHeadIndex = tempTab.newItemHeadIndex - 1
                        fun(tempTab.newItemHeadIndex,tab[tempTab.newItemHeadIndex], tempTab.cell[i],i)
                    end
                end
            end
        end
    end

    local onePosY = container:getSize().height - tempTab.ItemHeight * tempTab.allItem
    if onePosY < 0 then onePosY = 0 end

    tempTab.cell = cellTab
    for i=1,tempTab.existItem do
        if not tempTab.cell[i] then
            performWithDelay(sollowView, function( ... )
                local cell = ccui.ImageView:create()
                -- cell:addTouchEventListener(callBack)
                cell:setAnchorPoint(cc.p(0,0))

                sollowView:addChild(cell)
                cell:setPosition(0, onePosY + tempTab.ItemHeight * (tempTab.allItem - i - (bTtem - 1)))
                tempTab.cell[i] = cell
                
                fun(bTtem + i - 1, tab[bTtem + i - 1], cell,i)

                tempTab.cell[i]:retain()
                tempTab.cell[i]:retain()

            end, 0.032 * i)
        else
            sollowView:addChild(tempTab.cell[i])
            tempTab.cell[i]:setPosition(0, onePosY + tempTab.ItemHeight * (tempTab.allItem - i - (bTtem - 1)))
            fun(bTtem + i - 1, tab[bTtem + i - 1], tempTab.cell[i],i)
        end
    end

    
    sollowView:addEventListenerScrollView(scrollViewDidScroll)

    return tempTab
end

function gameUtil.getCSLoaderObj(tab)
    local type = tab.type                  --类型   
    local removeTab = tab.removeTab or {}  --需要删除的孩子
    local name = tab.name                  --名字
    -- print("getCSLoaderObj                        name "..name)
    game[name] = game[name] or {}
    local node
    for k,v in pairs(game[name]) do
        if 777777 == v:getTag() then
            node = v
            break
        end
    end
    if not node then
        if type == "CSLoader" then
            node = cc.CSLoader:createNode(name)
            node = node:getChildByName("Image_bg"):clone()
        elseif type == "mycreate" then
            local table = tab.table
            if name == "heroIcon" then
                node = gameUtil.createTouXiang( table )
            elseif name == "heroTishiText" then
                node = ccui.Text:create("", "fonts/youyuan.TTF", 30)
                
            end
        elseif type == "sp" then
            local json = tab.json
            local atlas = tab.atlas
            local scale = tab.scale
            node = sp.SkeletonAnimation:create(json,atlas,scale)
            -- if name == "res/hero/lol/L070/L070.json" then
                -- print("getCSLoaderObj                        新建 "..name)
            -- end
        end
        
    else
        if type == "sp" then
            -- if name == "res/hero/lol/L070/L070.json" then
                -- print("getCSLoaderObj                        内存 "..name)
            -- end
        end
        if type == "sp" then
            node:setVisible(true)
        end
    end
    node:retain()
    node:enableNodeEvents()
    node.onCleanup = function ()
        if type == "sp" then
            node:unregisterSpineEventHandler(sp.EventType.ANIMATION_START)
            node:unregisterSpineEventHandler(sp.EventType.ANIMATION_END)
            node:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            node:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
       
            node:setOpacity(255)
            -- node:initialize()
            node:removeAllChildren()
        end

        if type == "mycreate" then
            node:stopAllActions()
        end

        for k,v in pairs(removeTab) do
            local remove = node:getChildByName(v)
            if remove then
                remove:removeFromParent()
            end
        end

        node:setTag(777777)
        node:setParent(nil)
    end
    table.insert(game[name], node)


    if type == "sp" then
        node:setRotation(0)
        node:setPosition(0,0)
    end

    node:setTag(0)


    return node

    
end

function gameUtil.dealNumber( value )
    value = tonumber(value)
    cclog("gameUtil.dealNumber    value  "..value)
    local str = ""..value
    if value >= 100000000  then
        if value%100000000 >= 10000000 then
            str = string.format("%.1f", value/100000000).. "亿"
        else
            str = string.format("%.0f", value/100000000).. "亿"
        end
    elseif value >= 1000000 then
        if value%10000 >= 1000 then
            str = string.format("%.1f", value/10000).. "万"
        else
            str = string.format("%.0f", value/10000).. "万"
        end
    end
    return str
end

function gameUtil.dealNumberShort( value )
    local str = ""..value
    if value >= 100000 then
        if value%10000 >= 1000 then
            str = string.format("%.1f", value/10000).. "万"
        else
            str = string.format("%.0f", value/10000).. "万"
        end
    end
    return str
end

function gameUtil.showChongZhi( layer, bTishi )
    if gameUtil.isFunctionOpen(closeFuncOrder.RECHARGE_ENTER) == true then
        local PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({bTishi = bTishi})
        local size  = cc.Director:getInstance():getWinSize()
        layer:addChild(PurchaseLayer, MoGlobalZorder[2000002])
        PurchaseLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(PurchaseLayer)
    end
end

function gameUtil.getPlayerVipLv( exp )
    local vipExpRes = INITLUA:getVipExpRes()
    for i=1,#vipExpRes do
        if exp < vipExpRes[i].TotalExp then
            return vipExpRes[i].Level - 1
        end
    end
    return #vipExpRes - 1
end

function gameUtil.getVipInfoByLevel( level )
    for k,v in pairs(VipExp) do
        if v.Level == level then
            return v
        end
    end
    return nil
end

function gameUtil.setVipLevel( node, lv )
    if lv < 10 then
        local imageView = ccui.ImageView:create()
        imageView:loadTexture("res/UI/icon_jin_shuzi"..lv..".png")
        imageView:setScale(0.25)
        imageView:setPosition(18, 12)
        node:addChild(imageView)
    else
        local imageView1 = ccui.ImageView:create()
        imageView1:loadTexture("res/UI/icon_jin_shuzi"..(math.floor(lv/10))..".png")
        imageView1:setScale(0.25)
        imageView1:setPosition(10, 12)
        local imageView2 = ccui.ImageView:create()
        imageView2:loadTexture("res/UI/icon_jin_shuzi"..(lv%10)..".png")
        imageView2:setScale(0.25)
        imageView2:setPosition(23, 12)
        node:addChild(imageView1)
        node:addChild(imageView2)
    end
end

function gameUtil.createItemByIcon(iconSrc, num)
    local imageView = cc.Sprite:create(iconSrc)
    local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
    sprite_ditu:setAnchorPoint(cc.p(1, 0))
    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
    imageView:addChild(sprite_ditu)

    local ttfConfig = {}
    ttfConfig.fontFilePath = "font/youyuan.TTF"
    ttfConfig.fontSize = 30
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 1
    
    local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER,300)
    label:setAnchorPoint(cc.p(1,0))
    label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
    label:setTextColor( cc.c4b(255, 255, 255, 255) )
    label:enableGlow(cc.c4b(255, 255, 0, 255))
    imageView:addChild(label)
    local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
    local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
    sprite_ditu:setScale(scaleX, scaleY)

    return imageView
end

function gameUtil.getSmallLaBaNum()
    for k,v in pairs(mm.data.playerItem) do
        if v.id == 1227894841 then
            return v.num
        end
    end
    return 0
end

function gameUtil.getBigLaBaNum()
    for k,v in pairs(mm.data.playerItem) do
        if v.id == 1227895088 then
            return v.num
        end
    end
    return 0
end

function gameUtil.getRealCharNum(str)
    local length = 0
    local size = #str
    for i=1,size do
        local curByte = string.byte(str, i)
        if curByte > 127 then
            length = length + 1
        end
    end
    length = size - length *2 / 3
    return length
end

function gameUtil.getDefaultServerInfo( serverlist )
    util.tableSort(serverlist, "AreaCount", false)
    local info = nil

    local curSeverId = cc.UserDefault:getInstance():getStringForKey("severId", "0")

    for k,v in pairs(serverlist) do
        if v.areaId == curSeverId then
            info = v
            return info
        end
    end

    if info == nil then
        info = serverlist[1]
        for k,v in pairs(serverlist) do
            if v.status ~= 4 and v.status ~= 5 then  ---维护和测试状态
                info = v
                break
            end
        end
    end
    
    cc.UserDefault:getInstance():setStringForKey("severId",info.areaId)

    return info
end

-- 获取关卡到开启或关闭的时间
function gameUtil.getLeftTime(time, stageId, flag)
    local date = os.date("*t", time)
    local stageRes = INITLUA:getStageResById(stageId)
    local openDay = stageRes.StageOpenDay
    local leftDay = 0
    for i=0, 6 do
        local curDay = date.wday + i
        if curDay == 8 then
            curDay = 1
        else
            curDay = curDay%8
        end
        local flag2 = 0
        for k,v in pairs(openDay) do
            if v == curDay then
                flag2 = 1
                break
            end
        end
        
        if flag2 ~= flag then
            leftDay = curDay - date.wday
            if leftDay < 0 then
                leftDay = leftDay + 7
            end
            break
        end
    end

    local copyDate = util.copyTab(date)
    copyDate.hour = 5
    copyDate.min = 0
    copyDate.sec = 0
    local targetTime = os.time(copyDate)
    targetTime = targetTime + 24*60*60*leftDay
    return targetTime - time
end

-- 礼包是否可购买
function gameUtil.canBuyGift()
    local count = 0
    local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    mm.data.playerExtra.vipGiftTab = mm.data.playerExtra.vipGiftTab or {}
    for k,v in pairs(mm.data.playerExtra.vipGiftTab) do
        if v <= vipLv then
            count = count + 1
        end
    end
    if count < vipLv then
        return 1
    else
        return 0
    end
end

-- 判断功能是否开放
function gameUtil.isFunctionOpen(order)
    for k,v in pairs(mm.data.closeFuncTab) do
        if v == order then
            return false
        end
    end
    return true
end

local function addEquip(id, num)
    for k,v in pairs(mm.data.playerEquip) do
        if v.id == id then
            v.num = v.num + num
            return
        end
    end
    local temp = {}
    temp.id = id
    temp.num = num
    table.insert(mm.data.playerEquip, temp)
end

local function addHunshi(id, num)
    for k,v in pairs(mm.data.playerHunshi) do
        if v.id == id then
            v.num = v.num + num
            return
        end
    end
    local temp = {}
    temp.id = id
    temp.num = num
    table.insert(mm.data.playerHunshi, temp)
end

local function addItem(id, num)
    for k,v in pairs(mm.data.playerItem) do
        if v.id == id then
            v.num = v.num + num
            return
        end
    end
    local temp = {}
    temp.id = id
    temp.num = num
    table.insert(mm.data.playerItem, temp)
end


-- 刷新游戏背包数据
function gameUtil.refreshData(dropTab)
    if dropTab == nil then
        dropTab = {}
    end
    for k,v in pairs(dropTab) do
        if v.type == 1 then
            addEquip(v.id, v.num)
        elseif v.type == 3 then
            addItem(v.id, v.num)
        elseif v.type == 2 then
            addHunshi(v.id, v.num)
        elseif v.type == 4 then
            ---TODO------------HERO刷新
        end
    end
end

function gameUtil.updateStageExtra(t)
    if t == nil then
        return
    end
    local stageRes = INITLUA:getStageResById(t.id)
    for k,v in pairs(mm.data.playerStage) do
        if v.chapter == stageRes.StageType then
            v.extraTime = t.extraTime
            v.buyExtraTime = t.buyExtraTime
            break
        end
    end
end

function gameUtil.getNewHintRes( picRes )
    local res = {}
    res.bt_kaifu = "kflb"
    res.bt_meiri = "mryx"
    res.bt_shouchong = "sclb"

    return res[picRes]
end

-- 是否为空
function gameUtil.isNil( objIn, log )
    if objIn == nil then
        return true
    end

    return false
end

function gameUtil.isTrue( objIn, log )
    if objIn == true then
        return true
    end

    return false
end

function gameUtil.getHeroDiff(oldHero, newHero)
    oldHero.lv = gameUtil.getHeroLv(oldHero.exp, oldHero.jinlv)
    newHero.lv = gameUtil.getHeroLv(newHero.exp, newHero.jinlv)
    local playerHeroTab = util.copyTab(mm.data.playerHero)
    for k,v in pairs(playerHeroTab) do
        if v.id == oldHero.id then
            v = newHero
        end
    end
    local allHeroTiBuBeiLvXiShu = gameUtil.allHeroTiBuBeiLvXiShu( mm.data.playerHero )
    local allHeroTiBuBeiLvXiShu2 = gameUtil.allHeroTiBuBeiLvXiShu( playerHeroTab )

    local attributeTab = {}

    local hpNum1 = gameUtil.hpMBAck( oldHero )
    hpNum1 = gameUtil.HpTBXZ( hpNum1, allHeroTiBuBeiLvXiShu )
    local hpNum2 = gameUtil.hpMBAck( newHero )
    hpNum2 = gameUtil.HpTBXZ( hpNum2, allHeroTiBuBeiLvXiShu2 )
    attributeTab[1] = {old = hpNum1, change = hpNum2 - hpNum1}

    local ackNum1 = gameUtil.heroMBAck( oldHero )
    ackNum1 = gameUtil.AckTBXZ( ackNum1, allHeroTiBuBeiLvXiShu )
    local ackNum2 = gameUtil.heroMBAck( newHero )
    ackNum2 = gameUtil.AckTBXZ( ackNum2, allHeroTiBuBeiLvXiShu2 )
    attributeTab[2] = {old = ackNum1, change = ackNum2 - ackNum1}

    local speedNum1 = gameUtil.speedMBAck( oldHero )
    local speedNum2 = gameUtil.speedMBAck( newHero )
    attributeTab[3] = {old = speedNum1, change = speedNum2 - speedNum1}

    local critNum1 = gameUtil.critMBAck( oldHero )
    local critNum2 = gameUtil.critMBAck( newHero )
    attributeTab[4] = {old = critNum1/100, change = (critNum2 - critNum1)/100}

    local wufangNum1 = gameUtil.wufangMBAck( oldHero )
    local wufangNum2 = gameUtil.wufangMBAck( newHero )
    attributeTab[5] = {old = wufangNum1, change = wufangNum2 - wufangNum1}

    local mofangNum1 = gameUtil.mofangMBAck( oldHero )
    local mofangNum2 = gameUtil.mofangMBAck( newHero )
    attributeTab[6] = {old = mofangNum1, change = mofangNum2 - mofangNum1}

    return attributeTab
end

-- TODO::新建一个英雄，根据proto
function gameUtil.createHeroInfoLocal(unitRes)
    local tab = {}
    tab.id = unitRes.ID
    tab.lv = 1
    tab.xinlv = unitRes.chushixin
    tab.jinlv = 1
    tab.exp = 0
    tab.eqTab = {}

    local skill = {} tab.skill = skill
    for i,v in ipairs(unitRes.Skills) do
        table.insert(skill, {id=v, lv=1})
    end

    for i,v in ipairs(unitRes.SkillsEx) do
        table.insert(skill, {id=v, lv=1})
    end

    return tab
end

function gameUtil.createHunshiInfoLocal(id, num)
    if id and num then
        return {id = id, num=num}
    end

    return nil
end

function gameUtil.getBlessValue( currentBlessTimes )
    local tempRes = INITLUA:getExchangeByType( MM.EChangeToType.CHANGERTO_luandouzhufu )
    local blessValue = 0
    local function sortRule(a, b)
        return a.Times < b.Times
    end
    table.sort( tempRes, sortRule )
    for k,v in pairs(tempRes) do
        if v.Times > currentBlessTimes then
            break
        end
        blessValue = blessValue + v.Fold
    end

    if blessValue > 900 then
        blessValue = 900
    end

    return blessValue
end

local gameUtil_getHeroTab = gameUtil.getHeroTab
function gameUtil.getPreciousId(heroId, index)
    local curHeroRes = gameUtil_getHeroTab(heroId)
    if not curHeroRes then
        return 0
    end

    return curHeroRes.PreciousAssetIds[index]
end

function gameUtil.getSkinId(heroId, index)
    local curHeroRes = gameUtil_getHeroTab(heroId)
    if not curHeroRes then
        return 0
    end

    return curHeroRes.SkinId[index]
end

function gameUtil.createArmtrue(arm, repeatTag)
    if not repeatTag then
        repeatTag = 1
    end

    local aniName = arm.aniName
    local scale = arm.scale
    local effectNode = ccs.Armature:create(aniName)
    effectNode:setScale(scale)
    local animation = effectNode:getAnimation()
    if arm.aniAltName then
        aniName = arm.aniAltName
    end
    animation:play(aniName,-1,repeatTag)

    return effectNode
end

function gameUtil.getStringHang(msg)
    local str = ""
    local d = 580
    local oldi = 1
    local len = 0
    local hang = 1
    local hanzi = 0
    for i=1, #msg do
        local curByte = string.byte(msg, i)
        if curByte > 127 then
            hanzi = hanzi + 1
        else
            len = len + 1
        end
        if len * 14 + hanzi*30/3 >= d then
            if str == "" then
                str = str..(string.sub(msg, oldi, i))
            else
                str = str.."\n"..(string.sub(msg, oldi, i))
            end
            oldi = i
            len = 0
            hanzi = 0
            hang = hang + 1
        end
    end
    if #str < #msg then
        if #str ~= 0 then
            str = str.."\n"..(string.sub(msg, #str+1, #msg))
        else
            str = str..(string.sub(msg, #str+1, #msg))
        end
    end
    return hang
end

function gameUtil.getPreciousLevelAll(order, level)
    local PreciousUp = INITLUA:getRes("PreciousUp")
    local PreciousUpLevelAll = #PreciousUp

    local willLevelAll = order * 10 + level
    if willLevelAll > PreciousUpLevelAll then
        return PreciousUpLevelAll
    end
    return willLevelAll
end

function gameUtil.getShowStageInfoWithOutOpenDay( stageSort )
    if mm.data.playerStage == nil then
        mm.data.playerStage = {}
    end
    local stageResMap = INITLUA:getStageResMap()
    local showStage = {}
    for k,v in pairs(stageResMap) do
        if v[1].StagePKVisible == 1 and v[1].StageSort == 3 then
            -- 判断是否开放
            -- showStage.flag = 0
            -- for x,y in pairs(v[1].StageOpenDay) do
            --     if y == self.weekDay then
            --         showStage.flag = 1
            --         break
            --     end
            -- end
            local max_proc = 0
            showStage.leftCount = v[1].ChapterLimit
            showStage.LevelLowerLimit = v[1].LevelLowerLimit
            for p, q in pairs(mm.data.playerStage) do
                if q.chapter == v[1].StageType then
                    max_proc = q.max_proc
                    showStage.ID = q.stageId
                    showStage.leftCount = v[1].ChapterLimit - q.dailyCount
                    if showStage.leftCount < 0 then
                        showStage.leftCount = 0
                    end
                end
            end
            showStage.StageSort = v[1].StageSort
            for p, q in pairs(v) do
                if q.Stage == max_proc + 1 and q.Nation == mm.data.playerinfo.camp then
                    showStage.ID = q.ID
                end
                if showStage.LevelLowerLimit > q.LevelLowerLimit then
                    showStage.LevelLowerLimit = q.LevelLowerLimit
                end
            end
        end
    end

    return showStage
end

function gameUtil.getSaoDangJuanNum(  )
    local hasSaoJuan = 0
    mm.data.playerItem = mm.data.playerItem or {}
    for i=1,#mm.data.playerItem do
        if mm.data.playerItem[i].id == 1412444209 then
            hasSaoJuan = mm.data.playerItem[i].num
        end
    end
    return hasSaoJuan
end

function gameUtil.addUserAction(id)
    game.userAction = game.userAction or {}
    table.insert(game.userAction, id)
    if #game.userAction > 5 then
        table.remove(game.userAction, 1)
    end
    for i=1,#game.userAction do
        print(i .. "============addUserAction==============" .. game.userAction[i])
    end
end

-- 一些资源
-- local jinGuangFrame = "res/Effect/uiEffect/wpk/wpk.ExportJson"
-- gameUtil.addArmatureFile(jinGuangFrame)
--table乱序
-- function gameUtil.tableLuanXu( table )
--     local tab = table
--     local newtab = {}
--     local index = 1
--     for k,v in pairs(tab) do
--         table.insert(newtab,math.random(1,index) , v)
--         index = index + 1
--     end
--     return newtab
-- end

-- function gameUtil.isHaveById( tab, id )
--     for k,v in pairs(table_name) do
--         if v.id == id and v.num > 0 then
--             v.num = v.num - 1
--             return true
--         end
--     end

--     return nil
    
-- end

-- --测试通用弹筐
    -- local severLayer = require("src.app.views.layer.MsgBoxLayer").create({titleText = "提示", msgText = "该功能暂未开放", yesCallBack = "close", node = self})
    -- local size  = cc.Director:getInstance():getWinSize()
    -- local x = (size.width - severLayer:getContentSize().width) * 0.5
    -- local y = (size.height - severLayer:getContentSize().height) * 0.5
    -- severLayer:setPosition(x, y)
    -- self:addChild(severLayer)
    -- 设置按钮状态











