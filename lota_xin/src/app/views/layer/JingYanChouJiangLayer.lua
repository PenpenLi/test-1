local layer = class("JingYanChouJiangLayer", require("app.views.mmExtend.LayerBase"))
layer.RESOURCE_FILENAME = "res/Jingyanchoujiang.csb"

-- TODO::注意及不合理的地方：获取英雄是客户端根据heroinfo模拟的；抽奖信息不是按表读的；战斗界面的红点提示也只支持3种。
-- 测试模式：
local testMode = false
local function log( ... )
    if not testMode then
        return
    end
    print(...)
end
-- 变量缓存
local ItemRes = Item
local EquipRes = equip
local handler = handler
local mm = mm
local mm_data = mm.data
local g_playerItem = mm_data.playerItem
local g_hero = mm_data.playerHero
local g_hunshi = mm_data.playerHunshi
local gameUtil = gameUtil
local _file_exists = gameUtil.file_exists
local ccui_Layout = ccui.Layout
local ccui_Helper = ccui.Helper
local EventDef = EventDef
local cc = cc
local ccs = ccs
local cc_EaseOut = cc.EaseOut
local cc_EaseIn = cc.EaseIn
local cc_Sequence = cc.Sequence
local ccui_Text = ccui.Text
local defaultFontSrc = "res/fonts/youyuan.TTF"

local str1 = gameUtil.GetMoGameRetStr( 990050 )
local str2 = gameUtil.GetMoGameRetStr( 990051 )
local str3 = gameUtil.GetMoGameRetStr( 990052 )
local str4 = gameUtil.GetMoGameRetStr(990002)
local str5 = gameUtil.GetMoGameRetStr(990001)
local str6 = gameUtil.GetMoGameRetStr(990314)

local MoGlobalZorder = MoGlobalZorder
local curPurchaseLayer = MoGlobalZorder[2000003] + 1
local curRewardShowPanelLayer = curPurchaseLayer - 1

local table_insert = table.insert
local math_random = math.random
local MM = MM
local EEquipType = MM.EEquipType
local ET_HunShi = EEquipType.ET_HunShi
local ET_LinJian = EEquipType.ET_LinJian
local ET_HeChenPin = EEquipType.ET_HeChenPin

local ELOTTERY_CONSUME_TYPE = MM.ELOTTERY_CONSUME_TYPE
local defaultPath = "res/UI/pc_jinbi.png"
local consumeTypeIconPath = {
    [ELOTTERY_CONSUME_TYPE.LOTTERY_CONSUME_GOLD]        =   defaultPath,
    [ELOTTERY_CONSUME_TYPE.LOTTERY_CONSUME_DIAMOND]     =   "res/UI/pc_zuanshi.png",
}

local ELibaoDropType = MM.ELibaoDropType
local ELibaoDropType_LB_Item = ELibaoDropType.LB_Item
local ELibaoDropType_LB_Equip = ELibaoDropType.LB_Equip
local ELibaoDropType_LB_Hero = ELibaoDropType.LB_Hero

local LibaoRes = Libao
local function getItemResIfIsItem(libaoId)
    local curLibaoRes = LibaoRes[libaoId]
    if not curLibaoRes then
        return nil, nil
    end

    if curLibaoRes.LibaoDropType ~= ELibaoDropType_LB_Item then
        return nil, nil
    end

    return ItemRes[curLibaoRes.ItemID], curLibaoRes.ItemID
end

-- 移植到gameUtil
local defaultPath = gameUtil.getDefaultIconPath()
local heroInfoTab = {jinlv=1,id=0}
local LOLRes = LOL
local DOTARes = DOTA
local EEquipCamp = MM.EEquipCamp
local EC_lol = EEquipCamp.EC_lol
local EC_dota = EEquipCamp.EC_dota
local UnitResInCamp = {[EC_lol]=LOLRes, [EC_dota]=DOTARes}

local function getHeroRes(id, equipCamp)
    local curUnitRes = UnitResInCamp[equipCamp]
    if not curUnitRes then
        return nil
    end

    return curUnitRes[id]
end

local function thereIsHero(libaoId)
    local curLibaoRes = LibaoRes[libaoId]
    if not curLibaoRes then
        return nil
    end
    local curLibaoRes_ItemID = curLibaoRes.ItemID
    if curLibaoRes.LibaoDropType == ELibaoDropType_LB_Hero then
        local heroRes = getHeroRes(curLibaoRes_ItemID, curLibaoRes.EquipCamp)
        return heroRes
    end
    return nil
end

local function getIconFrom(libaoId, num, hunshiTag)
    local path = defaultPath
    local curLibaoRes = LibaoRes[libaoId]
    if not curLibaoRes then
        return nil
    end

    local curLibaoRes_ItemID = curLibaoRes.ItemID
    if curLibaoRes.LibaoDropType == ELibaoDropType_LB_Item then
        if ItemRes[curLibaoRes_ItemID] then
            return gameUtil.createItemWidget(curLibaoRes_ItemID, curLibaoRes.Value)
        else
            return nil
        end       
    elseif curLibaoRes.LibaoDropType == ELibaoDropType_LB_Equip then
        -- id都有检查过。
        return gameUtil.createEquipItem(curLibaoRes_ItemID, curLibaoRes.Value) 
    elseif curLibaoRes.LibaoDropType == ELibaoDropType_LB_Hero then
        -- id都有检查过。
        local heroRes = getHeroRes(curLibaoRes_ItemID, curLibaoRes.EquipCamp)       
        if hunshiTag then -- 有英雄, 展示魂石。      
            local count = gameUtil.getZhaoHuanHunshiNum(heroRes)
            if heroRes then 
                local node = gameUtil.createEquipItem(heroRes.herohunshiID, count)
                return node
            end
        else
            heroInfoTab.id = curLibaoRes_ItemID
            local node = gameUtil.createTouXiangSimple(heroInfoTab)
            return node                      
        end
    else
        -- TODO::魂石没处理
        --print("TODO::魂石没处理")
        return nil
    end
end

local function setInHunShi(hunshiId, count, hunshiInId)
    if not hunshiId or not count then
        return
    end

    local curHunshiInfo = hunshiInId[hunshiId]
    local mm_data_playerHunshi = mm.data.playerHunshi
    
    if not curHunshiInfo then
        local hunshiInfo = gameUtil.createHunshiInfoLocal(hunshiId, count)
        table_insert(mm_data_playerHunshi, hunshiInfo)
    else
        curHunshiInfo.num = curHunshiInfo.num + count
    end    
end

local function addHeroToPlayer(libaoId, hunshiTag, hunshiInId)
    local curLibaoRes = LibaoRes[libaoId]
    if not curLibaoRes then
        return
    end

    g_hero = mm.data.playerHero
    local curLibaoRes_ItemID = curLibaoRes.ItemID
    if curLibaoRes.LibaoDropType == ELibaoDropType_LB_Hero then
        local heroRes = getHeroRes(curLibaoRes_ItemID, curLibaoRes.EquipCamp)       
        if heroRes then      
            if not hunshiTag then-- 英雄
                heroInfoTab.id = curLibaoRes_ItemID
                local heroInfo = gameUtil.createHeroInfoLocal(heroRes)
                if heroInfo and g_hero then
                    table_insert(g_hero, heroInfo)
                end
            else -- 魂石
                local count = gameUtil.getZhaoHuanHunshiNum(heroRes)
                local hunshiId = heroRes.herohunshiID
                --local hunshiInfo = gameUtil.createHunshiInfoLocal(, count)
                setInHunShi(hunshiId, count, hunshiInId)
            end          
        end
    elseif curLibaoRes.LibaoDropType == ELibaoDropType_LB_Equip then
        -- 魂石属于装备   
        local curEquipRes = INITLUA:getEquipByid(curLibaoRes_ItemID)
        if curEquipRes and curEquipRes.EquipType == ET_HunShi then
            local count = curLibaoRes.Value
            setInHunShi(curLibaoRes_ItemID, count, hunshiInId)
        end
    end
end

-- 消耗类型icon（金币和钻石）
local function getConsumeTypeIconPath(typeIn)
    local path = consumeTypeIconPath[typeIn]
    if path then
        return path
    end

    return defaultPath
end

local chouJiangPanelPath = "res/JingyanchoujiangLayer.csb"
local JingyanhuodeZSPanelPath = "res/JingyanhuodeZS.csb"

-- 时间格式化：
local math_floor = math.floor
local string_format = string.format
local function getFormatTime( time )
    if time <= 0 then
        return "00:00:00"
    end

    local hour = math_floor(time / 3600)
    local min = math_floor((time - (3600 * hour)) / 60)
    local sec = time - (3600 * hour) - (min * 60)

    if hour < 10 then
        hour = "0"..hour
    end

    if min < 10 then
        min = "0"..min
    end

    if sec < 10 then
        sec = "0"..sec
    end

    return string_format("%s:%s:%s", hour, min, sec)
end

-- 加载资源
local cc_CSLoader = cc.CSLoader
local function getNodeFromCSB(pathIn)
    if not pathIn or not _file_exists (pathIn) then
        return nil
    end
    return cc_CSLoader:createNode(pathIn)
end

local c_chouJiangMainTypesCount = 3

-- 弹出充值界面
local size = cc.Director:getInstance():getWinSize() local winSize = clone(size)
local purchaseLayerName = "onlyPurchaseLayer"

local function popPurchasePanel(typeName, parentNode)
    if not curPurchaseLayer or not parentNode then
        return
    end

    local PurchaseLayer = parentNode:getChildByName(purchaseLayerName)
    if PurchaseLayer then
        return
    end

    if typeName == "diamond" then
        PurchaseLayer = require("src.app.views.layer.PurchaseLayer").new({})     
    elseif typeName == "gold" then
        PurchaseLayer = require("src.app.views.layer.DianjinshouLayer").new({})   
    end

    if PurchaseLayer then
        parentNode:addChild(PurchaseLayer, curPurchaseLayer, purchaseLayerName)
        PurchaseLayer:setContentSize(cc.size(size.width, size.height))
        ccui_Helper:doLayout(PurchaseLayer)
    end

    return PurchaseLayer
end

-- 抽奖资源初始化：
local INITLUA = INITLUA
local ExpDrawInfo = INITLUA:getExpDrawInfo()
local ExpDreaResInList = {}
if ExpDrawInfo then
    ExpDreaResInList = ExpDrawInfo.list
end

-- 按钮动画
--gameUtil.addArmatureFile("res/Effect/uiEffect/gmyc/gmyc.ExportJson")
local cjShowRewardArmInfo = {src="cj", aniName="stand", scale = 1, nonRepeat = true}
local cjLiuGuangArmInfo = {src="zkcs", aniName="stand", scale = 0.7}
local huodeHeroInfo1 = {src="czyx", aniName="stand" ,scale = 1}
local huodeHeroInfo2 = {src="czyx_bai", aniName="stand", scale = 1, nonRepeat = true}
local huodeHeroInfo3 = {src="czyx_lizi", aniName="stand", scale = 1}
local armatrues = {
    {src="cjcj", aniName="stand", scale = 1},
    {src="gjcj", aniName="stand", scale = 1},
    {src="zjcj", aniName="stand", scale = 0.8},
    {src="res/Effect/uiEffect/gmyc/gmyc.ExportJson", aniName="gmyc", scale = 1, isArmature = true},
--{src="gmyc", aniName="stand", scale = 1, isArmature = true}, -- 新资源免费按钮
    cjLiuGuangArmInfo,
}
local function createArmtrue(arm, repeatTag)
    if not repeatTag then
        repeatTag = 1
    end
    local aniName = arm.aniName
    local scale = arm.scale
    local src = arm.src
    local nonRepeat = arm.nonRepeat
    if arm.isArmature then
        gameUtil.addArmatureFile(src)
        local effectNode = ccs.Armature:create(aniName)
        effectNode:setScale(scale)
        local animation = effectNode:getAnimation()
        if arm.aniAltName then
            aniName = arm.aniAltName
        end
        animation:play(aniName,-1,repeatTag)
        return effectNode
    else
        local effectNode = gameUtil.createSkeAnmion( {name = src,scale = scale} )
        effectNode:setAnimation(0, aniName, not nonRepeat)
        return effectNode
    end
end
-- TODO:: 写死的
ExpDreaResInList = {}
local ExpDraw = ExpDraw
local goldDrawRes = ExpDraw[1093677105]
local diamondDrawRes = ExpDraw[1093677106]
local enemyDrawRes = ExpDraw[1093677107]

local maintTypes = { -- TODO::var应该是数字 类型应该填表
    gold = "gold",
    diamond = "diamond",
    enemy = "enemy"
}

local playerCamp = mm_data.playerinfo.camp
local EEquipCamp = MM.EEquipCamp
local function getOppsiteCamp(campIn)
    if EEquipCamp.EC_lol == campIn then
        return EEquipCamp.EC_dota
    elseif EEquipCamp.EC_dota == campIn then
        return EEquipCamp.EC_lol
    end
end

local function parseLibaoId(idIn, isOppsiteCamp)
    local hero = {}
    local hunshi = {}
    local equip = {}
    local item = {}
    local t = {hero, hunshi, equip, item}
    local list = INITLUA:getLiBaoMapResById(idIn)

    local toCamp = playerCamp
    if isOppsiteCamp then
        --toCamp = getOppsiteCamp(toCamp)
    end
    for i,v in ipairs(list) do
        local v_EquipCamp = v.EquipCamp
        if v_EquipCamp == toCamp then
            local v_LibaoDropType = v.LibaoDropType
            if v_LibaoDropType == ELibaoDropType_LB_Items then
                table_insert(item, v) -- TODO::还没启用这个类型
            elseif v_LibaoDropType == ELibaoDropType_LB_Equip then
                -- 分魂石和武器
                local curRes = EquipRes[v.ItemID]
                if curRes then
                    if curRes.EquipType == ET_HunShi then
                        table_insert(hunshi, v)
                    elseif curRes.EquipType == ET_LinJian then
                        table_insert(equip, v)
                    elseif curRes.EquipType == ET_HeChenPin then
                        table_insert(equip, v)             
                    end
                end
            elseif v_LibaoDropType == ELibaoDropType_LB_Hero then
                local UnitResInCamp = UnitResInCamp[v_EquipCamp]
                if UnitResInCamp then
                    local curUnitRes = UnitResInCamp[v.ItemID]
                    if curUnitRes then
                        table_insert(hero, v)
                    end
                end
            end
        end
    end
    return t
end

local EDRAW_OPEN_CONDITION = MM.EDRAW_OPEN_CONDITION
local DRAW_OPEN_CONDITION_LV = EDRAW_OPEN_CONDITION.DRAW_OPEN_CONDITION_LV
local DRAW_OPEN_CONDITION_VIPLV = EDRAW_OPEN_CONDITION.DRAW_OPEN_CONDITION_VIPLV
local DRAW_OPEN_CONDITION_COMPLETE = EDRAW_OPEN_CONDITION.DRAW_OPEN_CONDITION_COMPLETE

-- 等级限制：
local level = gameUtil.getPlayerLv(mm_data.playerinfo.exp)
local vipLevel = gameUtil.getPlayerVipLv(mm_data.playerinfo.vipexp)
local mm_data_playerTask = mm_data.playerTask

local function hasCompleteTask(id)
    if not mm_data_playerTask then
        return false
    end

    for i,v in ipairs(mm_data_playerTask) do
        if v.taskId == id then
            return true
        end
    end

    return false
end

local function isAbleToShow(curRes)
    if DRAW_OPEN_CONDITION_LV == curRes.DRAW_OPEN_CONDITION then
        if curRes.lv <= level then
            return true
        end
    elseif DRAW_OPEN_CONDITION_VIPLV == curRes.DRAW_OPEN_CONDITION then
        if curRes.lv <= vipLevel then
            return true
        end
    elseif DRAW_OPEN_CONDITION_COMPLETE == curRes.DRAW_OPEN_CONDITION then
        if hasCompleteTask(curRes.missionId) then
            return true
        end
    end

    return false
end

-- 在icon下方加入说明文字
local function addInfoTextToIcon(node, libaoId)
    local curLibaoRes = LibaoRes[libaoId]
    if not curLibaoRes then
        return
    end

    local str = curLibaoRes.Name
    
    if not str then
        return
    end
    local contentSize = node:getContentSize()

    local textNode = ccui_Text:create(str, defaultFontSrc, 25)
    textNode:setPosition(contentSize.width*0.5, - 45)

    node:addChild(textNode, 10)
end

local strOpenTip1 = gameUtil.GetMoGameRetStr( 990103 )
local strOpenTip2 = gameUtil.GetMoGameRetStr( 990104 )
local strOpenTip3 = gameUtil.GetMoGameRetStr( 990105 )
local TaskRes = Task
local function showUnOpen(curRes)
    if DRAW_OPEN_CONDITION_LV == curRes.DRAW_OPEN_CONDITION then
        gameUtil:addTishi({p = self, s = string_format(strOpenTip1, curRes.lv)}) 
    elseif DRAW_OPEN_CONDITION_VIPLV == curRes.DRAW_OPEN_CONDITION then
        gameUtil:addTishi({p = self, s = string_format(strOpenTip2, curRes.lv)}) 
    elseif DRAW_OPEN_CONDITION_COMPLETE == curRes.DRAW_OPEN_CONDITION then
        local taskId = curRes.missionId
        local curTaskRes = TaskRes[taskId]
        if curTaskRes then
            gameUtil:addTishi({p = self, s = string_format(strOpenTip3, curTaskRes.TaskName)}) 
        end
    end
end

-- TODO::整理下
if goldDrawRes then
    local ids = parseLibaoId(goldDrawRes.showDropId)
    table_insert(ExpDreaResInList, {mainType = maintTypes["gold"], res = goldDrawRes, idsInTypes = ids, open = false, arm=armatrues[1]})
end
if diamondDrawRes then
    local ids = parseLibaoId(diamondDrawRes.showDropId)
    table_insert(ExpDreaResInList, {mainType = maintTypes["diamond"], res = diamondDrawRes, idsInTypes = ids, open = false, arm=armatrues[2]})
end
if enemyDrawRes then
    local ids = parseLibaoId(enemyDrawRes.showDropId, true)
    table_insert(ExpDreaResInList, {mainType = maintTypes["enemy"], res = enemyDrawRes, idsInTypes = ids, open = false, arm=armatrues[3]})
end
local mainItemIds = {}
for i,v in ipairs(ExpDreaResInList) do
    local res = v.res
    mainItemIds[res.itemIdOnce] = 1
    mainItemIds[res.itemIdTen] = 1
end

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local heroCount = 0
function layer:onCreate(param)
    heroCount = 0

    self.mainScene = param.scene
    self.param = param
    g_playerItem = mm_data.playerItem -- 每次进入获取item 列表
    g_hero = mm_data.playerHero 
    g_hunshi = mm_data.playerHunshi

    self:setupItemMaps(g_playerItem, mainItemIds)

    -- 检查是否开放
    level = gameUtil.getPlayerLv(mm_data.playerinfo.exp)
    vipLevel = gameUtil.getPlayerVipLv(mm_data.playerinfo.vipexp)
    mm_data_playerTask = mm_data.playerTask   
    for i,v in ipairs(ExpDreaResInList) do
        if isAbleToShow(v.res) then
            v.open = true
        else
            v.open = false
        end
        if testMode then
            v.open = true
        end
    end

    -- 资源节点：
    local Node = self:getResourceNode() self.Node = Node
    -- if gameUtil.isNil( Node, "ERROR: Jingyanchoujiang  名字或节点错误（bgNode）！" ) then
    --     return
    -- end  

    -- TODO::Image_bg必须有
    local bgNode = Node:getChildByName("Image_bg") self.bgNode = bgNode
    
    -- 返回按钮
    local backBtn = bgNode:getChildByName("Button_back") self.backBtn = backBtn
    if backBtn then
        backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
        gameUtil.setBtnEffect(backBtn)
    end

    -- 必要信息。
    if gameUtil.isTrue(#ExpDreaResInList < 1, "ERROR: Jingyanchoujiang  资源没到位！")  then
        --return
    end

    --主要功能节点：
    local image9Node = bgNode:getChildByName("Image_9")
    if gameUtil.isNil( image9Node, "ERROR: Jingyanchoujiang  名字或节点错误（Image_9）！" ) then
        return
    end

    local listViewNode = image9Node:getChildByName("ListView_4") self.listViewNode = listViewNode
    if gameUtil.isNil( bgNode, "ERROR: Jingyanchoujiang  名字或节点错误（bgNode）！" ) then
        return
    end    
    if gameUtil.isNil( listViewNode, "ERROR: Jingyanchoujiang  名字或节点错误（listViewNode）！" ) then
        return
    end

    local goldTextNode = Node:getChildByName("Text_2") self.goldTextNode = goldTextNode
    local diamondTextNode = Node:getChildByName("Text_3") self.diamondTextNode = diamondTextNode
    self:updateGoldDiamond(true)

    -- 充值接口
    local goldPlusBtn = Node:getChildByName("Button_1") self.goldPlusBtn = goldPlusBtn
    if goldPlusBtn then
        goldPlusBtn:addTouchEventListener(handler(self, self.purchaseGoldBtnCbk))
        goldPlusBtn:setTouchEnabled(true)
        gameUtil.setBtnEffect(goldPlusBtn)
    end
    local diamondPlusBtn = Node:getChildByName("Button_2") self.diamondPlusBtn = diamondPlusBtn
    if diamondPlusBtn then
        diamondPlusBtn:addTouchEventListener(handler(self, self.purchaseDiamonBtnCbk))
        diamondPlusBtn:setTouchEnabled(true)
        gameUtil.setBtnEffect(diamondPlusBtn)
    end

    -- 预览接口
    local showRewardBtn = bgNode:getChildByName("Button_2")
    if showRewardBtn then
        showRewardBtn:addTouchEventListener(handler(self, self.showRewardBtnCb))
        showRewardBtn:setTouchEnabled(true)
        gameUtil.setBtnEffect(showRewardBtn)
    end

    ccui_Helper:doLayout(Node)

    -- 3个主类型的抽奖：UI固定
    for i,v in ipairs(armatrues) do
        --gameUtil.addArmatureFile(v.src)
    end
    self:addChouJiangUI()
    --ccui_Helper:doLayout(Node)

    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

    -- 剩余时间请求。
    self:doTimeRequest()

    -- 时间UI和逻辑
    self:initTimeUpdate()

    --PA:test()
    -- 测试模式：
    --self:createRewardShowPanel({})

    -- if not testMode then
    --     return
    -- end

    -- local testEvent = {}
    -- testEvent.t = {luckdrawInfo = {goldTime = 0, diamondTime = 3, enemyTime = 5, restGoldTimes = 3}}
    -- self:dealLuckDraw(testEvent)

    -- local function x( ... )
    --     local testEvent1 = {}
    --     testEvent1.t = {luckdrawInfo = {goldTime = 15, diamondTime = 3, enemyTime = 5, restGoldTimes = 3}}
    --     self:dealLuckDraw(testEvent1)      
    -- end
    -- local action = cc_Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(x))
    -- local node = cc.Node:create()
    -- self:addChild(node)
    -- node:runAction(action)
end

function layer:addChouJiangUI()
    local listViewNode = self.listViewNode
    local contentSize = listViewNode:getContentSize()

    local infoMap = {} self.infoMap = infoMap
    local btnForGuide = {}
    for i=1,#ExpDreaResInList do
        local info = ExpDreaResInList[i]
        local res = info.res
        local openInType = res.Offo -- 在未开启时是否显示的标志
        if not openInType then
            openInType = 1
        end

        repeat 
            if not info then
                break
            end

            if not testMode then
                if openInType == 0 and not info.isOpen then
                    info.hide = true
                    break
                end
            end

            local newPacakedInfo = self:addChouJiangPanelToListView(listViewNode, contentSize, info)
            if newPacakedInfo then
                local mainType = info.mainType
                infoMap[mainType] = newPacakedInfo
                newPacakedInfo.mainType = mainType
                table_insert(btnForGuide, newPacakedInfo.btn1)
                --self:updatePriceWords(newPacakedInfo)
            end

        until true
    end

    -- 
    local btn1 = btnForGuide[1]
    self.guideBtn1 = btn1
    --ccui_Helper:doLayout(self.Node)

    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
        end
    end

    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
        elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
        end
    end
    listViewNode:addEventListener(listViewEvent)
    listViewNode:addScrollViewEventListener(scrollViewEvent)

    listViewNode:forceDoLayout()
    if mm.GuildId >= 10025 and  mm.GuildId <= 10035 then
    else
        listViewNode:jumpToPercentHorizontal(50)
    end

end

local math_fmod = math.fmod
function layer:addChouJiangPanelToListView(parentNode, sizeIn, info)
    local curNode = getNodeFromCSB(chouJiangPanelPath)
    if not curNode then
        return
    end

    -- res
    local res = info.res--ExpDreaResInList[tag].res
    local arm = info.arm
    local DrawExpPool = res.DrawExpPool
    local isOpen = info.open
    local iconPath = res.icon
    local bgPath = res.bg
    local timesMax = #res.freshTime
    local info = {} info.open = isOpen

    local itemSize = curNode:getContentSize()
    local itemHeight = itemSize.height

    local frameHeight = sizeIn.height
    local scale = frameHeight / itemHeight - 0.025
    
    curNode:setScale(scale)
    itemSize.width = itemSize.width * scale
    itemSize.height = itemSize.height * scale

    local baseNode = ccui_Layout:create()
    curNode:setName("panel")
    baseNode:addChild(curNode)
    baseNode:setContentSize(itemSize)
    baseNode:setAnchorPoint(0.5,0.5)

    --baseNode:setLayoutType(ccui.LayoutType.VERTICAL)
    --baseNode:forceDoLayout()
    parentNode:pushBackCustomItem(baseNode)
    --baseNode:setTag(tag)
    local timeText = nil
    local priceText = nil
    local priceTypeTag = nil
    local buyBtnOnce = nil
    local buyBtnTen = nil
    local priceTextTen = nil
    local priceTypeTagTen = nil
    local btn1 = curNode:getChildByName("Button_2")
    if btn1 then
        btn1:addTouchEventListener(handler(self, self.doDrawCallBack))
        btn1.mainInfo = {buyTimes = 1, info = info}
        gameUtil.setBtnEffect(btn1)
        info.btn1 = btn1
    end

    local btn10 = curNode:getChildByName("Button_2_0") buyBtnTen = btn10
    if btn10 then
        btn10:addTouchEventListener(handler(self, self.doDrawCallBack))
        btn10.mainInfo = {buyTimes = 2, info = info}
        gameUtil.setBtnEffect(btn10)

        local bar = btn10:getChildByName("Image_8")
        if bar then
            local pos = cc.p(bar:getPosition())
            local node = createArmtrue(cjLiuGuangArmInfo)
            bar:addChild(node)
            local curSize = bar:getContentSize()
            node:setPositionX(curSize.width*0.5-8)
            node:setPositionY(curSize.height*0.5+21)
            local curScale = 1.0
            --node:setScaleX(curScale)
            --node:setScaleY(curScale)
        end
    end

    -- 时间：Text_quname
    timeText = curNode:getChildByName("Text_quname")

    priceText = curNode:getChildByName("Text_qu_0")
    priceTypeTag = curNode:getChildByName("Image_18_0")
    buyBtnOnce = curNode:getChildByName("Button_2")
    if buyBtnOnce then
        buyBtnOnce.size = buyBtnOnce:getContentSize()
    end

    priceTextTen = curNode:getChildByName("Text_qu")
    priceTypeTagTen = curNode:getChildByName("Image_18")

    -- 其他：表现节点
    local headBarText = curNode:getChildByName("Text_quname_0_0")
    if headBarText then
        headBarText:setString(res.name)
    end
    local bottomBarText = curNode:getChildByName("Text_lv")--expdrawsrc
    if bottomBarText then
        bottomBarText:setString(res.expdrawsrc)
    end

    -- 头顶的bar
    local str2 = res.expdrawfubiaoti if not str2 then str2 = "" end
    local headBarText2 = curNode:getChildByName("Image_19")--Image_19
    local headBarText1 = curNode:getChildByName("Text_quname_0")
    local headBarText3 = curNode:getChildByName("Text_quname_0_0")
    local headBarList1 = {{index=1,node=headBarText1},{index=2,node=headBarText2},{index=3,node=headBarText3}}
    local newText = nil
    if headBarText2 then
        local pos = cc.p(headBarText2:getPosition())
        newText = ccui_Text:create(str2, defaultFontSrc, 25)
        newText:setPosition(pos)
        curNode:addChild(newText)
        newText:setVisible(false)
    end
    local headBarList2 = {{index=1,node=newText}}
    local headBarLists = {headBarList1, headBarList2}
    -- 动画：
    local index = 1
    local function changeWord()
        index = index + 1
        index = math_fmod(index, 2)
        if index == 0 then
            index = 2
        end
        
        for j, list in ipairs(headBarLists) do
            for i,v in ipairs(list) do
                local node = v.node
                if node then
                    if index == j then
                        node:setVisible(true)
                    else
                        node:setVisible(false)
                    end
                end
            end
        end
    end

    local seq = cc_Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(changeWord))
    curNode:runAction(cc.RepeatForever:create(seq))

    --
    local animateNodeBase = curNode:getChildByName("Node_1")
    if animateNodeBase then
        local imageView = ccui.ImageView:create()
        animateNodeBase:addChild(imageView)
        local iconSrc = res.icon
        if _file_exists(iconSrc) then
            imageView:loadTexture(iconSrc)
        end

        if arm then
            local aniName = arm.aniName
            local scale = arm.scale
            local effectNode = createArmtrue(arm, 1)

            animateNodeBase:addChild(effectNode,2)
        end

        -- 动画 animateNodeBase
        local function funcStart()
            local curDrawExpPoolTime = 3
            if DrawExpPool and DrawExpPool > 1500 then
                curDrawExpPoolTime = curDrawExpPoolTime - 1
            end         
            local moveDown = cc.MoveBy:create(curDrawExpPoolTime, cc.p(0,-35))
            local moveDown1 = cc_EaseOut:create(moveDown, 2)

            local moveUp = cc.MoveBy:create(curDrawExpPoolTime, cc.p(0,35))
            local moveUp1 = cc_EaseIn:create(moveUp, 2)

            local seq = cc_Sequence:create(moveDown1, moveUp1)
            animateNodeBase:runAction(cc.RepeatForever:create(seq))
        end

        local delay = cc.DelayTime:create(math_random(1,100)/200)
        local seq1 = cc_Sequence:create(delay, cc.CallFunc:create(funcStart))
        animateNodeBase:runAction(seq1)
    end

    info.time = 0
    info.times = 1
    info.timesMax = timesMax
    info.res = res
    info.timeTextNode = timeText
    info.priceText = priceText
    info.priceTypeTag = priceTypeTag
    info.buyBtnOnce = buyBtnOnce

    info.priceTextTen = priceTextTen
    info.priceTypeTagTen = priceTypeTagTen
    info.buyBtnTen = buyBtnTen

    info.panelNode = curNode

    -- 初始状态
    info.freeFlagOnce = false
    info.itemFirstFlagOnce = false
    info.itemFirstFlagTen = false
    self:resetPanelConsumeType(info, true, true)

    return info
end

-- 设置免费界面
function layer:setFreeShow(info, isFree)
    -- 按钮
    local buyBtnOnce = info.buyBtnOnce
    local priceText = info.priceText
    local priceTypeTag = info.priceTypeTag 

    if isFree and not info.freeFlagOfNodes then
        if buyBtnOnce then
            if info.times < 1 then
                info.times = 1
            end
            buyBtnOnce:setTitleText(string_format(str2, info.times, info.timesMax))--getTitleText
            local effectNode = createArmtrue(armatrues[4], repeatTag)--ccs.Armature:create("gmyc")

            effectNode:setAnchorPoint(cc.p(0,0))
            effectNode:setScale(2.45)
            local buyBtnOnce_size = buyBtnOnce.size
            effectNode:setContentSize(buyBtnOnce.size)
            effectNode:setPosition(buyBtnOnce_size.width*0.5, buyBtnOnce_size.height*0.5)
            --local animation = effectNode:getAnimation()
            --animation:play("gmyc")
            buyBtnOnce:addChild(effectNode)
            buyBtnOnce.effectNode = effectNode
        end
        if priceText then
            priceText:setVisible(false)
        end
        if priceTypeTag then
            priceTypeTag:setVisible(false)
        end

        info.freeFlagOfNodes = true
    elseif not isFree and info.freeFlagOfNodes then
        if buyBtnOnce then
            buyBtnOnce:setTitleText(str3)
            local effectNode = buyBtnOnce.effectNode
            if effectNode then
                effectNode:removeFromParent()
                buyBtnOnce.effectNode = nil
            end
        end
        if priceText then
            priceText:setVisible(true)
        end
        if priceTypeTag then
            priceTypeTag:setVisible(true)
        end
        info.freeFlagOfNodes = false
    end
end

-- 面板消耗类型
function layer:resetPanelConsumeType(info, onceIn, tenIn)
    local res = info.res
    if onceIn then
        local priceText = info.priceText
        local priceTypeTag = info.priceTypeTag

        if priceText then
            priceText:setString(res.countOnce)
        end
        if priceTypeTag then
            local path = getConsumeTypeIconPath(res.LOTTERY_CONSUME_TYPE_ONCE)
            if _file_exists(path) then
                priceTypeTag:loadTexture(path)
            end
        end
    end

    if tenIn then
        local priceTextTen = info.priceTextTen
        local priceTypeTagTen = info.priceTypeTagTen

        if priceTextTen then
            priceTextTen:setString(res.countTen)
        end
        if priceTypeTagTen then
            local path = getConsumeTypeIconPath(res.LOTTERY_CONSUME_TYPE_TEN)
            if _file_exists(path) then
                priceTypeTagTen:loadTexture(path)
            end
        end
    end   
end

-- 更新价格信息。
--local goldIconPath = "res/"
function layer:updatePriceWords(info)
    -- 免费：道具：金币（钻石）
    local self_itemMap = self.itemMap
    local res = info.res

    -- 时间
    local timeTextNode = info.timeTextNode
    if timeTextNode then
        if info.closed or info.time <= 0 then
            if not timeTextNode.closed then
                timeTextNode.closed = true
                timeTextNode:setVisible(false)
            end
        else
            if timeTextNode.closed then
                timeTextNode.closed = false
                timeTextNode:setVisible(true)
            end
        end

    end

    -- 价格面板
    if info.freeFlagOnce then
        self:setFreeShow(info, true)
    else
        self:setFreeShow(info, false)

        -- 1次.
        local cosumeItemId = res.itemIdOnce
        local itemCount = res.itemCountOnce
        local countFromPlayer = self:getItemCount(cosumeItemId)
        if itemCount <= countFromPlayer then
            -- 使用道具：
            if not info.itemFirstFlagOnce then
                info.itemFirstFlagOnce = true

                local priceText = info.priceText
                local priceTypeTag = info.priceTypeTag
                if priceTypeTag then
                    local iconPath = gameUtil.getItemIconRes(cosumeItemId)
                    if not _file_exists(iconPath) then
                        iconPath = nil
                    end
                    priceTypeTag:loadTexture(iconPath)
                end
                if priceText then
                    local str = " "..itemCount
                    priceText:setString(str)
                end
            end
        else
            -- 使用金币(钻石)：
            if info.itemFirstFlagOnce then
                self:resetPanelConsumeType(info, true, false)
                info.itemFirstFlagOnce = false
            end 
        end
    end

    -- 10次 没有免费：
    local cosumeItemId = res.itemIdTen
    local itemCount = res.itemCountTen
    local countFromPlayer = self:getItemCount(cosumeItemId)
    if itemCount <= countFromPlayer then
        -- 使用道具：
        if not info.itemFirstFlagTen then
            info.itemFirstFlagTen = true

            local priceText = info.priceTextTen
            local priceTypeTag = info.priceTypeTagTen
            if priceTypeTag then
                local iconPath = gameUtil.getItemIconRes(cosumeItemId)
                if not _file_exists(iconPath) then
                    iconPath = nil
                end
                priceTypeTag:loadTexture(iconPath)
            end
            if priceText then
                local str = " "..itemCount
                priceText:setString(str)
            end
        end
    else
        -- 使用金币(钻石)：
        if info.itemFirstFlagTen then
            self:resetPanelConsumeType(info, false, true)
            info.itemFirstFlagTen = false
        end 
    end
end

local ccui_TouchEventType_ended = ccui.TouchEventType.ended
-- 抽奖按钮回调
function layer:doDrawCallBack(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then
        self:doDrawRequest(widget.mainInfo)
        self.preBtnMainInfo = widget.mainInfo
        --{buyTimes = 2, info = info}
    end    
end
function layer:doDrawRequest(mainInfo)
    if not mainInfo then
        return
    end
    if mm.GuildId == 10026 and self._isGuideMode then
        return
    end
    local info = mainInfo.info
    if info then
        local isOpen = info.open
        if not isOpen then
            showUnOpen(info.res)
            return
        end


        local mainType = info.mainType
        if mainType and maintTypes[mainType] then
            mm.req("luckdraw", {["type"] = mainType, subtype = mainInfo.buyTimes})

            if mm.GuildId == 10026 then
                Guide:setUserDefId(10027)
                self._isGuideMode = true
            end
        end
    end
end

-- 时间请求
function layer:doTimeRequest()
    mm.req("luckdraw", {["type"] = "info", subtype = 1})
end

function layer:onEnter()
    mm.data.lastZhanLi = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue )
end

function layer:onEnterTransitionFinish()
    if mm.GuildId == 10025 then
        performWithDelay(self, function()
            Guide:startGuildById(10026, self.guideBtn1)
            cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "guideJingYan",1)
        end, 0.02)
    end
end

function layer:onExit()
    for i,v in ipairs(armatrues) do
        --gameUtil.removeArmatureFile(v.src)
    end
    -- gameUtil.removeArmatureFile(cjShowRewardArmInfo.src)
    -- gameUtil.removeArmatureFile(huodeHeroInfo1.src)
    -- gameUtil.removeArmatureFile(huodeHeroInfo2.src)
    -- gameUtil.removeArmatureFile(huodeHeroInfo3.src)

    -- game:dispatchEvent({name = EventDef.UI_MSG, code = "backFightSceneBackup"}) 
end

function layer:onCleanup()
    self:clearAllGlobalEventListener()
end

function layer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then        
        if event.code == "luckdraw" then
            self:dealLuckDraw(event)
        end
    --elseif event.name == EventDef.UI_MSG then
    end
end

local table_sort = table.sort
function layer:dealLuckDraw(event)
    -- 是否是时间信息
    local data = event.t
    if not data then
        return
    end
    -- 结果提示
    local result = data.type
    if result == 4 then
        --print("==================ERROR 4：钱不够")
        -- 弹字和充值界面
        popPurchasePanel("gold", self.mainScene)
        gameUtil:addTishi({p = self, s = str4}) 
    elseif result == 5 then
        --print("==================ERROR 5：钻石不够")
        popPurchasePanel("diamond", self.mainScene)
        gameUtil:addTishi({p = self, s = str5}) 
    elseif result == 2 then
        --print("==================ERROR 2：时间未到")
    elseif result == 1 then
        --print("==================ERROR 1：免费次数不够")
    elseif result == 0 then      
        -- 获得道具。
        local items = data.items
        if items and #items > 0 then
            self:createRewardShowPanel()
            local hunshiIndexes = data.hunshiIndex -- 指定是英雄还是魂石
            local hunshiMap = {}
            if hunshiIndexes then
                for i,v in ipairs(hunshiIndexes) do
                    hunshiMap[v] = 0
                end
            end

            local itemInfos = {}
            for i,v in ipairs(items) do
                local curItemRes, itemId = getItemResIfIsItem(v)
                if itemId then
                    local count, curItemInfo = self:getItemCount(itemId)
                    if curItemInfo then
                        curItemInfo.num = curItemInfo.num + 1
                    end
                end
                table_insert(itemInfos, {id=v, r=math_random(1,100), tag = hunshiMap[i]})
            end
            table_sort(itemInfos, function (aa,bb) return aa.r > bb.r end)

            -- 检查是否有英雄加入Player
            local mm_data_playerHunshi = mm.data.playerHunshi
            local hunshiInId = {}
            for i,v in ipairs(mm_data_playerHunshi) do
                hunshiInId[v.id] = v
            end
            for i,v in ipairs(itemInfos) do
                addHeroToPlayer(v.id, v.tag, hunshiInId)
            end
            
            -- 展示
            self:showItemsOnRewardPanel(itemInfos) 
        end
    else
        --print("==================ERROR 3(6)：未知错误")
    end

    if data.hunshiIndex then
        heroCount = heroCount + 1
    end
    -- 物品消耗
    local consumeItemInfo = data.consumeItemInfo
    if consumeItemInfo then
        -- 消耗道具：
        local itemId = consumeItemInfo.id
        local itemCount = consumeItemInfo.count
        if type(itemCount) ~= "number" then
            itemCount = 1
        end 

        local count, curItemInfo = self:getItemCount(itemId)
        if curItemInfo then
            local num = curItemInfo.num
            num = num - itemCount
            if num < 0 then
                num = 0
            end
            curItemInfo.num = num
        end
    end

    -- 信息更新
    local luckdrawInfo = data.luckdrawInfo
    if not luckdrawInfo then
        return
    end

    -- gold 类型，有结束计时的特点：
    local all = {{k1="gold", k2="restGoldTimes", k3="goldTime"},
    {k1="enemy", k2="restEnemyTimes", k3="enemyTime"},
    {k1="diamond", k2="restDiamondTimes", k3="diamondTime"}}
    --dump(luckdrawInfo, "------------------------------")
    for i,v in ipairs(all) do
        local curInfo =  self.infoMap[maintTypes[v.k1]]
        self:setInTimes(maintTypes[v.k1], luckdrawInfo[v.k2])

        if curInfo then
            if luckdrawInfo[v.k2] <= 0 and luckdrawInfo[v.k3] <= 0 then
                curInfo.closed = true
            else
                curInfo.closed = false
            end
        end
    end

    if luckdrawInfo.goldTime then
        self:setInTime(maintTypes["gold"], luckdrawInfo.goldTime)
    end

    if luckdrawInfo.diamondTime then
        self:setInTime(maintTypes["diamond"], luckdrawInfo.diamondTime)
    end

    if luckdrawInfo.enemyTime then
        self:setInTime(maintTypes["enemy"], luckdrawInfo.enemyTime)
    end

    local mm_data_playerinfo = mm_data.playerinfo
    if mm_data_playerinfo then
        if luckdrawInfo.gold then
            mm_data_playerinfo.gold = luckdrawInfo.gold
        end
        if luckdrawInfo.diamond then
            mm_data_playerinfo.diamond = luckdrawInfo.diamond
        end
        if luckdrawInfo.expPool then
            mm_data_playerinfo.exppool = luckdrawInfo.expPool + mm_data_playerinfo.exppool
        end       
    end
end

function layer:backBtnCbk(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then 
        mm:popLayer()
        if mm.GuildId == 10029 then
            Guide:startGuildById(10033, mm.GuildScene.PanelLeft)
        end
    end
end

function layer:updateTimeInInfo(v)
    local time = v.time
    --local updatePriceWordsFlag = false
    if time > 0 then
        time = time - 1

        if time <= 0 then
            time = 0
            if not v.closed then 
                v.freeFlagOnce = true
            end
            --self:updatePriceWords(v)
            --updatePriceWordsFlag = true
        end

        v.time = time

        self:updateTextTimeAngBtn(v.timeTextNode, v.buyBtnOnce, getFormatTime(time), time == 0)

    end

    -- 每秒都需检查金钱和道具的数量。
    self:updatePriceWords(v)
    self:updateGoldDiamond(true)

    self:updateRewardPanel()
end

function layer:updateTime() -- dt == 1s
    for k,v in pairs(self.infoMap) do
        self:updateTimeInInfo(v)
    end
end

function layer:initTimeUpdate()
    local action = cc.RepeatForever:create(cc_Sequence:create(cc.CallFunc:create(handler(self,self.updateTime)), cc.DelayTime:create(1)))
    self:runAction(action)
end

function layer:updateTextTimeAngBtn(timeTextNode, buyBtnOnce, timeInFormat, isEnd)
    if timeTextNode then
        timeTextNode:setString(string_format("%s%s", timeInFormat, str1))
    end

    if isEnd and buyBtnOnce then

    end
end

local delayTime = 5
function layer:setInTime(mainType, time)
    local t = self.infoMap[mainType]
    if t then
        if time > 0 then
            t.freeFlagOnce = false
            self:updatePriceWords(t)
        end
        if time == 0 then
            t.time = 1
            -- 立即更新
            self:updateTimeInInfo(t)
        else
            if time < delayTime then
                t.time = time + delayTime
            else
                t.time = time
            end
        end
    end
end

function layer:setInTimes(mainType, times)
    if times == nil then
        times = 0
    end

    local t = self.infoMap[mainType]
    if t then
        t.times = times
        if times < 1 then
            t.freeFlagOnce = false
        end
    end


end

function layer:goToNextWaitingInClient(mainType)
    
end

-- 设置物品map
function layer:setupItemMaps(itemListIn, toFindIdsIn)
    local map = {} self.itemMap = map
    if type(itemListIn) ~= "table" then
        return
    end

    local id = 0
    for i,v in ipairs(itemListIn) do
        id = v.id     
        if toFindIdsIn[id] then
            map[id] = v
        end
    end  
end

function layer:getItemCount(idIn)
    local curItemInfo = self.itemMap[idIn]

    if not curItemInfo then
        return 0, nil
    end
    return curItemInfo.num, curItemInfo
end

function layer:updateGoldDiamond(idFromPlayer)
    local mm_data_playerinfo = mm_data.playerinfo
    if not mm_data_playerinfo then
        return
    end
    local gold = mm_data_playerinfo.gold
    local diamond = mm_data_playerinfo.diamond

    local goldTextNode = self.goldTextNode
    if goldTextNode then
        goldTextNode:setString(""..gold)
    end

    local diamondTextNode = self.diamondTextNode
    if diamondTextNode then
        diamondTextNode:setString(""..diamond)
    end    
end

function layer:purchaseGoldBtnCbk(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then
        popPurchasePanel("gold", self.mainScene)
    end
end

function layer:purchaseDiamonBtnCbk(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then
        popPurchasePanel("diamond", self.mainScene)
    end
end

function layer:showRewardBtnCb(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then
        local Layer = require("src.app.views.layer.JingYanYuLanLayer").new({app = self.param.app, resList = ExpDreaResInList})
        self:addChild(Layer, 100)
        Layer:setContentSize(cc.size(size.width, height))
        ccui_Helper:doLayout(Layer)
    end
end

-- 获得展示界面 
local borderX = 0
local borderY = 25
local hNum = 5
local vNum = 2 
function layer:createRewardShowPanel()
    local preBtnMainInfo = self.preBtnMainInfo
    if not preBtnMainInfo then
        return
    end
    local curRewardShowPanel = self.curRewardShowPanel
    if curRewardShowPanel then
        return
    end
    -- 新建
    local baseNode = getNodeFromCSB(JingyanhuodeZSPanelPath)
    if not baseNode then
        return
    end
    gameUtil.addArmatureFile(cjShowRewardArmInfo.src)

    self.mainScene:addChild(baseNode, curRewardShowPanelLayer)
    baseNode:setContentSize(size)
    ccui_Helper:doLayout(baseNode)

    self.curRewardShowPanel = baseNode

    --  
    local btnReturn = baseNode:getChildByName("Button_ok_0") self.btnReturn = btnReturn
    if btnReturn then
        btnReturn:addTouchEventListener(handler(self, self.rewardShowPanelReturnCB))
        gameUtil.setBtnEffect(btnReturn)
    end

    mm.GuildScene.jingYanbtnReturn = btnReturn

    local btnAgain = baseNode:getChildByName("Button_ok") baseNode.btnAgain = btnAgain
    if btnAgain then
        btnAgain:addTouchEventListener(handler(self, self.rewardShowPanelAgainCB))
        gameUtil.setBtnEffect(btnAgain)
        btnAgain.mainInfo = preBtnMainInfo
    end

    -- icon text Image_4 Text_3
    local icon = baseNode:getChildByName("Image_4") baseNode.icon = icon
    local text = nil
    if icon then
        text = icon:getChildByName("Text_3") baseNode.text = text
    end

    local showFrameNode = baseNode:getChildByName("Panel_1") baseNode.showFrameNode = showFrameNode
    if showFrameNode then
        local posBase = cc.p(showFrameNode:getPosition())

        local winWidth = winSize.width
        local winHeight = winSize.height
        local frameSize = showFrameNode:getContentSize()
        local width = frameSize.width
        local height = frameSize.height
        local tenPoses = self.tenPoses
        if not tenPoses then
            tenPoses = {} self.tenPoses = tenPoses
        end
        local centerPos = {x=(width*0.5+posBase.x), y=(height*0.5+posBase.y)}
        local iconPos = cc.p(winWidth*0.5, winHeight*0.5) -- 起始位置
        showFrameNode.posInfo = {startPos = iconPos, centerPos = centerPos, tenPoses = tenPoses}

        local xAve = (width - borderX*2) / hNum
        local yAve = 85 + 15

        local yStart = borderY + yAve*vNum - yAve*0.5
        for i=1,vNum do
            local xStart = borderX + xAve*0.5
            for i=1,hNum do
                table_insert(tenPoses, {x=(xStart+posBase.x), y=(yStart+posBase.y)})
                xStart = xStart + xAve
            end
            yStart = yStart - yAve
        end

        -- 调节下位置：
        local bgImage = baseNode:getChildByName("Image_3")
        if bgImage and cjShowRewardArmInfo then
            bgImage:setAnchorPoint(cc.p(0.5,0.5))
            iconPos = cc.p(bgImage:getPosition())
            showFrameNode.posInfo.startPos = iconPos
            iconPos.x = winWidth * 0.5
            -- ICON
            local info = preBtnMainInfo.info
            if info then
                local res = info.res
                local imageView = ccui.ImageView:create()
                imageView:setPosition(iconPos)
                baseNode:addChild(imageView)
                local iconSrc = res.icon
                if _file_exists(iconSrc) then
                    imageView:loadTexture(iconSrc)
                    imageView:setScale(1.44)
                end

                baseNode.childIcon = imageView
            end

            -- 动画
            baseNode.effectPlay = function ()
                local aniName = cjShowRewardArmInfo.aniName
                local effectNode = createArmtrue(cjShowRewardArmInfo)--ccs.Armature:create(aniName)
                --effectNode:setAnchorPoint(cc.p(0.5,0.5))
                --effectNode:setScale(cjShowRewardArmInfo.scale)
                --local animation = effectNode:getAnimation()
                effectNode:setPosition(iconPos)
                

                baseNode:addChild(effectNode)
                --effectNode:setVisible(false)
                effectNode:setVisible(true)
                --animation:play(aniName)

                local r = math_random(1, 4) * 90
                effectNode:setRotation(r)

                return effectNode
            end
        end
    end

    self.preBtnMainInfoForReward = preBtnMainInfo

    self:updateRewardPanel()

    self:initRewardPanelUpdate(baseNode)

    ccui_Helper:doLayout(baseNode)
end

local iconShowUpTimeSpan = 0.4
local iconFlyTime = 0.35
function layer:initRewardPanelUpdate(baseNode)
    local function updateTime()
        self:showAnRewardIcon()
    end

    local action = cc.RepeatForever:create(cc_Sequence:create(cc.CallFunc:create(updateTime), cc.DelayTime:create(iconShowUpTimeSpan)))
    baseNode:runAction(action)
end

function layer:rewardShowPanelReturnCB(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then
        self.curRewardShowPanel:removeFromParent(true)
        self.curRewardShowPanel = nil
            -- mm.req("getHero", {getType=1})
            -- heroCount = 0
        if mm.GuildId == 10028 then
            -- Guide:startGuildById(10033, mm.GuildScene.PanelLeft)
            
            Guide:startGuildById(10029, self.backBtn)
        end
    end
end

function layer:rewardShowPanelAgainCB(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then
        self:doDrawRequest(widget.mainInfo)
    end
end

function layer:updateRewardPanel()
    local curRewardShowPanel = self.curRewardShowPanel
    if not curRewardShowPanel then
        return
    end

    local preBtnMainInfoForReward = self.preBtnMainInfoForReward
    if not preBtnMainInfoForReward then
        return
    end

    local info = preBtnMainInfoForReward.info
    local res = info.res
    local cosumeItemId = 0
    local itemCount = 0

    local res_count = res.countOnce   
    local res_LOTTERY_CONSUME_TYPE = res.LOTTERY_CONSUME_TYPE_ONCE
    if preBtnMainInfoForReward.buyTimes == 1 then -- 1次
        cosumeItemId = res.itemIdOnce
        itemCount = res.itemCountOnce 
    elseif preBtnMainInfoForReward.buyTimes == 2 then -- 10次
        cosumeItemId = res.itemIdTen
        itemCount = res.itemCountTen

        res_count = res.countTen   
        res_LOTTERY_CONSUME_TYPE = res.LOTTERY_CONSUME_TYPE_TEN
    end

    local countFromPlayer = self:getItemCount(cosumeItemId)
    local priceText = curRewardShowPanel.text
    local priceTypeTag = curRewardShowPanel.icon
    if itemCount <= countFromPlayer then
        -- 使用道具：
            if priceTypeTag then
                local iconPath = gameUtil.getItemIconRes(cosumeItemId)
                if not _file_exists(iconPath) then
                    iconPath = nil
                end
                priceTypeTag:loadTexture(iconPath)
            end
            if priceText then
                local str = " "..itemCount
                priceText:setString(str)
            end
    else
        -- 使用金币(钻石)：
        if priceText then
            priceText:setString(res_count)
        end
        if priceTypeTag then
            local path = getConsumeTypeIconPath(res_LOTTERY_CONSUME_TYPE)
            if _file_exists(path) then
                priceTypeTag:loadTexture(path)
            end
        end
    end 


    -- 文字模仿：
    local btnBuy = curRewardShowPanel.btnAgain
    if btnBuy then
        --:setTitleText(string_format(str2, info.times, info.timesMax))-- 
        if preBtnMainInfoForReward.buyTimes == 2 then
            local btn = info.buyBtnTen
            if btn then
                btnBuy:setTitleText(btn:getTitleText())
            end
        else
            local btn = info.buyBtnOnce
            if btn then
                btnBuy:setTitleText(btn:getTitleText())
            end
        end
    end
end

local singleOneScale = 1.5
local defaultAnchor = cc.p(0.5,0.5)
function layer:showItemsOnRewardPanel(items)
    local curRewardShowPanel = self.curRewardShowPanel
    if not curRewardShowPanel then
        return
    end

    -- 展示框
    local showFrameNode = curRewardShowPanel.showFrameNode
    if not showFrameNode then
        return
    end

    -- 旧的删除
    local list = curRewardShowPanel.rewardItemList
    if list then
        for i,v in ipairs(list) do
            v:removeFromParent(true)
        end
    end
    list = {} curRewardShowPanel.rewardItemList = list

    -- info
    local posInfo = showFrameNode.posInfo

    local showRewardInfo = {isStarted = false,parent=curRewardShowPanel} -- 用于动画展示的信息
    local count  = #items
    local iconInfos = {} showRewardInfo.iconInfos = iconInfos
    local startPos = posInfo.startPos
    if count == 1 then -- 单个变大
        local curItemInfo = items[1]
        local centerPos = posInfo.centerPos
        local curItemId = curItemInfo.id
        table_insert(iconInfos, {itemId=curItemId, extraTag=curItemInfo.tag, toPos = centerPos})  
    else
        local tenPoses = posInfo.tenPoses
        local countPoses = #tenPoses
        for i,v in ipairs(items) do
            if i > countPoses then
                break
            end

            local curItemId = v.id
            table_insert(iconInfos, {itemId=curItemId, extraTag=v.tag, toPos = tenPoses[i]})
        end
    end

    local countIcon = #iconInfos
    if countIcon < 1 then
        return
    end
    local toScale = 1
    if countIcon == 1 then
        toScale = singleOneScale
    end

    showRewardInfo.index = 0
    showRewardInfo.max = countIcon
    showRewardInfo.startPos = startPos
    showRewardInfo.toScale = toScale
    showRewardInfo.pausedTags = {}

    self.showRewardInfo = showRewardInfo

    -- local delayNode = cc.Node:create()
    -- local delay = cc.DelayTime:create()

    showRewardInfo.isPaused = false

    local iconNode = curRewardShowPanel.childIcon
    if iconNode then
        iconNode:stopAllActions()

        showRewardInfo.isPaused = true

        local t = 0.04
        local moveCount = 20
        local moveList = {}
        local centerPos = iconNode.centerPos
        if centerPos then
        else
            centerPos = cc.p(iconNode:getPosition())
            iconNode.centerPos = centerPos
        end
        
        local span = 10
        for i = 1,moveCount do
            local rPos = cc.p(centerPos.x+math_random(-span, span), centerPos.y+math_random(-span, span))
            local m = cc.MoveTo:create(t*(1-i/moveCount) + 0.01, rPos)
            table_insert(moveList, m)
        end

        local function explode()
            showRewardInfo.isPaused = false
        end

        local seq = cc_Sequence:create(
            moveList[1],moveList[2],moveList[3],moveList[4],moveList[5],
            moveList[6],moveList[7],moveList[8],moveList[9], cc.CallFunc:create(explode), moveList[10],
            moveList[11],moveList[12],moveList[13],moveList[14],moveList[15]
            )
        iconNode:runAction(seq)
    end
end

local cc_MoveTo = cc.MoveTo
local cc_ScaleTo = cc.ScaleTo
local cc_RotateBy = cc.RotateBy
local cc_Spawn = cc.Spawn
--local getHeroLayerSrc = "src.app.views.layer.GetHeroLayer"
function layer:showAnRewardIcon()
    local showRewardInfo = self.showRewardInfo
    if not showRewardInfo then
        return
    end

    if showRewardInfo.isPaused then
        return
    end

    local index = showRewardInfo.index
    local max = showRewardInfo.max

    index = index + 1
    if index > max then
        self.showRewardInfo = nil
        --showRewardInfo.isEnded = true
        return
    end

    local curInfo = showRewardInfo.iconInfos[index]
    local curRewardShowPanel = self.curRewardShowPanel
    if not curRewardShowPanel then
        return
    end
    local curItemId = curInfo.itemId

    local pausedTags = showRewardInfo.pausedTags
    local heroRes = thereIsHero(curItemId)
    local parent = showRewardInfo.parent
    if pausedTags[index] == nil and heroRes then
        -- 获得英雄的显示：
        local  shwoHeroPanel = self:createGetHeroPanel(heroRes.ID, curInfo.extraTag)
        if shwoHeroPanel then
            parent:addChild(shwoHeroPanel, 100)
            if mm.GuildId == 10026 then
                Guide:setHandVisible(false)
                Guide:setImageViewVisible(false)
                performWithDelay(self,function( ... )
                    Guide:setHandVisible(true)
                    Guide:setImageViewVisible(true)
                    Guide:startGuildById(10027, shwoHeroPanel:getChildByName("Button_ok"))
                end, 1.5)
            end
        end
   
        -- 暂停：
        showRewardInfo.isPaused = true
        pausedTags[index] = 1
        return
    end

    showRewardInfo.index = index
    local list = curRewardShowPanel.rewardItemList

    local node = getIconFrom(curInfo.itemId, 1, curInfo.extraTag)
    if node then
        local startPos = showRewardInfo.startPos
        curRewardShowPanel:addChild(node, 10)
        local _startPos = cc.p(startPos.x+math_random(-50,50), startPos.y+math_random(-25,-50))
        node:setPosition(_startPos)
        node:setAnchorPoint(defaultAnchor)
        node:setScale(0.5)

        table_insert(list, node)

        local toPos = curInfo.toPos
        local _curIconFlyTime = iconFlyTime + index * 0.01 
        local move = cc_MoveTo:create(_curIconFlyTime, toPos)
        local scale = cc_ScaleTo:create(_curIconFlyTime, showRewardInfo.toScale)
        local rotation = cc_RotateBy:create(_curIconFlyTime, 360)
        local c = cc_Spawn:create(move, scale, rotation)
        local ce = cc_EaseOut:create(c, 1.9)

        -- 单个的加说明的字

        if max == 1 then
            local function flyActionBack()
                addInfoTextToIcon(node, curItemId)
            end
            local seq = cc_Sequence:create(ce,cc.CallFunc:create(flyActionBack))
            node:runAction(seq)            
        else
            node:runAction(ce)
        end

        gameUtil.playUIEffect( "Reward_Get" )
    end

    local effectPlay = parent.effectPlay
    if effectPlay then
        local node = effectPlay()
        table_insert(list, node)
    end
end

local getHeroPanelSrc = "res/HuodeHero.csb"
function layer:createGetHeroPanel(heroId, hunshiTag)
    local heroShowPanel = self.heroShowPanel
    if heroShowPanel then
        heroShowPanel:removeFromParent(true)
        self.heroShowPanel = nil
    end

    local node = getNodeFromCSB(getHeroPanelSrc)
    if not node then
        return
    end 

    local heroRes = gameUtil.getHeroTab(heroId)
    if not heroRes then
        return
    end

    local node1 = node:getChildByName("Image_2")
    if not node1 then
        return
    end

    local text_name = node1:getChildByName("Text_1")
    if not text_name then
        return
    end

    text_name:setString(heroRes.Name)

    local image_hero = node:getChildByName("Image_3")
    if not image_hero then
        return
    end

    local imageSize = image_hero:getContentSize() 

    -- 特效
    gameUtil.addArmatureFile(huodeHeroInfo1.src)
    gameUtil.addArmatureFile(huodeHeroInfo2.src)
    gameUtil.addArmatureFile(huodeHeroInfo3.src)

    local shiftY = 75

    -- 英雄
    local skeletonNode = gameUtil.createSkeletonAnimation(heroRes.Src..".json", heroRes.Src..".atlas",1)
    skeletonNode:setPosition(imageSize.width * 0.5, 0)--imageSize.height * 0.05
    skeletonNode:update(0.012) 
    skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
    image_hero:addChild(skeletonNode, 10)
    skeletonNode:setScale(1.5)
    self.huodeHero = skeletonNode

    local dropTime = 0.4
    local drop1 = cc_EaseIn:create(cc.ScaleTo:create(dropTime, 1), 1.9)
    skeletonNode:runAction(drop1)

    local function trig1()
        self.huodeHero:setAnimation(0, "stand", true)

        local node1 = createArmtrue(huodeHeroInfo1,-1)
        node1:setPosition(imageSize.width * 0.5, imageSize.height * 0.1 + shiftY)
        image_hero:addChild(node1, 1)
        local node2 = createArmtrue(huodeHeroInfo2,-1)
        node2:setPosition(imageSize.width * 0.5, imageSize.height * 0.1 + shiftY)
        image_hero:addChild(node2, 101)
        local node3 = createArmtrue(huodeHeroInfo3,-1)
        node3:setPosition(imageSize.width * 0.5, imageSize.height * 0.1 + shiftY)
        image_hero:addChild(node3, 2)
        -- 
        local skeletonNode1 = gameUtil.createSkeletonAnimation(heroRes.Src..".json", heroRes.Src..".atlas",1)
        skeletonNode1:setPosition(imageSize.width * 0.5, imageSize.height * 0.1)
        skeletonNode1:update(0.012)  
        skeletonNode1:setAnchorPoint(cc.p(0.5, 0.5))
        skeletonNode1:setOpacity(100)    
        skeletonNode:setScale(1.5)
        local drop2 = cc.ScaleTo:create(0.8, 5)
        local fade2 = cc.FadeOut:create(0.8)
        local sp = cc.Spawn:create(drop2, fade2)
        local seq1 = cc.Sequence:create(sp, cc.CallFunc:create(function ()
            skeletonNode1:setVisible(false)
        end))
        skeletonNode1:runAction(seq1)
        image_hero:addChild(skeletonNode1, 10)
    end
    local seq = cc.Sequence:create(cc.DelayTime:create(dropTime), cc.CallFunc:create(trig1))
    node:runAction(seq)

    local button_ok = node:getChildByName("Button_ok")
    if button_ok then
        gameUtil.setBtnEffect(button_ok)
        button_ok:addTouchEventListener(handler(self, self.okCbk))
        self.heroShowPanel = node
    end

    -- 说明
    if hunshiTag and button_ok then
        local pos = cc.p(button_ok:getPosition())
        pos.y = pos.y - 15
        local textNode = ccui_Text:create(str6, defaultFontSrc, 30)
        textNode:setPosition(pos)
        node:addChild(textNode)
    end

    node:setContentSize(size)
    ccui_Helper:doLayout(node)
    return node
end

function layer:okCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if mm.GuildId ~= 10026 then

            local heroShowPanel = self.heroShowPanel
            if heroShowPanel then
                heroShowPanel:removeFromParent()
                self.heroShowPanel = nil
            end

            local showRewardInfo = self.showRewardInfo
            if showRewardInfo then
                showRewardInfo.isPaused = false
            end        

            if mm.GuildId == 10027 then
                Guide:startGuildById(10028, mm.GuildScene.jingYanbtnReturn)
            end
        end

        if self.huodeHero then
            -- self.huodeHero:setAnimation(0, "skill", false)
            self.huodeHero = nil
        end
    end
end

return layer