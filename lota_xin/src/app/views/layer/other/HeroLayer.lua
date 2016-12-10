local HeroLayer = class("HeroLayer", require("app.views.mmExtend.LayerBase"))
HeroLayer.RESOURCE_FILENAME = "HeroLayer.csb"
local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")

-- 测试模式
local testMode = false

local table = table

local gameUtil = gameUtil
local _file_exists = gameUtil.file_exists
local gameUtil_setBtnEffect = gameUtil.setBtnEffect
local gameUtil_createHeroSkinEx = gameUtil.createHeroSkinEx
local gameUtil_getHeroTab = gameUtil.getHeroTab
local gameUtil_createPreciousIcon = gameUtil.createPreciousIcon
local gameUtil_createImage = gameUtil.createImage
local gameUtil_createSelector = gameUtil.createSelector
local gameUtil_setSelectorVisible = gameUtil.setSelectorVisible
local gameUtil_createItemWidget = gameUtil.createItemWidget

local handler = handler
local ccui = ccui
local ccui_Helper = ccui.Helper
local ccui_TouchEventType_ended = ccui.TouchEventType.ended
local ccui_TouchEventType_began = ccui.TouchEventType.began
local ccui_ScrollviewEventType_scrolling = ccui.ScrollviewEventType.scrolling
local ccui_Layout = ccui.Layout
local cc = cc
local cc_CSLoader = cc.CSLoader
local winSize = cc.Director:getInstance():getWinSize()

local distanceToBottom = 100
local mm = mm
local mm_data = mm.data
local mm_req = mm.req

local INITLUA = INITLUA
local MM = MM

local itemResAll = INITLUA:getRes("Item")
local PreciousResAll = INITLUA:getRes("Precious")
local PreciousUpMaterialsAll = INITLUA:getRes("PreciousUpMaterials")
local skinResAll = INITLUA:getRes("skin")

local string = string
local string_format = string.format
local table_insert = table.insert

local tPanelUpdate = {name=1, zizhi=1, stars=1, shuxing=1, zhanli=1, lv=1}
local tPanelUpdate1 = {zhanli=1, lv=1}
local function log( ... )
    if not testMode then
        return
    end
    print(...)
end

-- 特效
-- local performWithDelay = performWithDelay
-- local armInfo1 = {src="res/Effect/uiEffect/sjyx/sjyx.ExportJson", aniName="sjyx", scale = 1}

-- 底下属性面板的管理：
local bottomPanels = {
    shengJi = {src="res/HeroshengjiLayer.csb"},
    jinJie = {src="res/HerojinjieLayer.csb"},
    jiNeng = {src="res/HerojinengLayer.csb"},
    shengXIng = {src="res/HeroshengxingLayer.csb"},
    ZBSJ = {src="res/HeroshengjiZBSJ.csb"},
    ZBJX = {src="res/HeroshengjiZBJX.csb"},
    ZBPF = {src="res/HeroshengjiZBPF.csb"},
}
-- 共四个分页
local pages = {
    levelUp = 1,
    skill = 2,
    starUp = 3,
    precious = 4
}

local selectRecord = {} -- 选中的至宝的记录：英雄id -- index

-- index 获取 至宝id
local gameUtil_getPreciousId = gameUtil.getPreciousId
local function getPreciousId(heroId, index)
    return gameUtil_getPreciousId(heroId,index)
end

local gameUtil_getSkinId = gameUtil.getSkinId
local function getSkinId(heroId, index)
    return gameUtil_getSkinId(heroId,index)
end

--小黄书预选
local preLevelSetMax = 3
local preLevelSets = {{id=0},{id=0},{id=0}}
local preLevelSetsEx = {{id=0},{id=0},{id=0}}
local preOrderSetMax = 2
local preOrderSets = {{id=0},{id=0}}

local function createCSNode(src)
    local src = src
    if not _file_exists(src) then
        return
    end
    return cc_CSLoader:createNode(src)
end

local function createBottomPanel(name)
    local curInfo = bottomPanels[name]
    if not curInfo then
        return
    end

    local curNode = createCSNode(curInfo.src)
    if curNode then
        curNode.BPName = name
    end

    return curNode
end

local function isBPTheName(bp, name)
    if not bp then
        return false
    end

    if bp.BPName == name then
        return true
    end

    return false
end

-- 选中的遮罩
local selectedEffectSrcs = {"res/UI/jm_icon_select.png", "res/UI/jm_hero_xuan.png"}
local function createASelectCover(node, pos, index)
    if not index then
        index = 1
    end

    local cover = gameUtil_createImage(selectedEffectSrcs[index])
    cover:setPosition(pos)
    node:addChild(cover,99)
    node.cover = cover
end

--
local itemBaseSrc = "res/HeroZBCL.csb"
local function createItemIcon(ItemID, num)
    local curItemRes = itemResAll[ItemID]
    if not curItemRes then
        return
    end

    local base = createCSNode(itemBaseSrc)
    if not base then
        return 
    end

    local n1 = base:getChildByName("Image_2")
    if n1 then
        local icon = gameUtil_createItemWidget(ItemID, num)
        if icon then
            n1:addChild(icon)
            base.icon = icon
        end
    end

    local n2 = base:getChildByName("Image_1")
    if n2 then
        n2:setSwallowTouches(false)
        base.bg = n2
    end

    -- 说明
    local nameText = base:getChildByName("Text_1")
    if nameText then
        nameText:setString(curItemRes.Name)
    end

    local expText = base:getChildByName("Text_2")
    if expText then
        expText:setString(""..curItemRes.itemNum)
    end

    return base
end

local function createItemIcon2(ItemID, num, max)
    if itemResAll[ItemID] then
        local icon = gameUtil_createItemWidget(ItemID, num, max)
        return icon
        --return gameUtil_createItemWidget(ItemID, num)
    end
end

local gameUtil_createSkinIcon1 = gameUtil.createSkinIcon1
local function createSkinIcon(skinId)
    return gameUtil_createSkinIcon1(skinId)
end

-- 皮肤icon显示
local skinColloctColor = {cc.c4b(255,255,255,255),cc.c4b(125,125,125,255),cc.c4b(255,0,0,255),cc.c4b(51,51,51,255)}
local yyFont = "fonts/huakang.TTF"
local skinUnopenStr2 = gameUtil.GetMoGameRetStr(990315)
local newTagSrc = "res/UI/icon_tixing.png"
local function setSkinOpenShow(v, open, isNew)
    local child = v.c1

    local frameContent = v:getContentSize()
    local midPos = cc.p(frameContent.width*0.5, frameContent.height*0.5)
    if open then
        v:setColor(skinColloctColor[1])
        if v.tishiText then
            v.tishiText:removeFromParent()
            v.tishiText = nil
        end

        if child then
            child:setColor(skinColloctColor[1])
        end        
    else
        v:setColor(skinColloctColor[2])
        if not v.tishiText then    
            local tishiText = ccui.Text:create()--skinUnopenStr2, yyFont, 36
            tishiText:setTouchScaleChangeEnabled(false)
            tishiText:setFontSize(28)
            tishiText:setFontName(yyFont)
            tishiText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            tishiText:setString(skinUnopenStr2)      
            tishiText:setTextColor(skinColloctColor[3])   
            tishiText:setUnifySizeEnabled(false)
            tishiText:ignoreContentAdaptWithSize(true)

            
            tishiText:setPosition(midPos)
            v:addChild(tishiText, 100)
            v.tishiText = tishiText

            local fOut = cc.FadeOut:create(1.2)
            local fIn = cc.FadeIn:create(0.8)
            local seq = cc.Sequence:create(fOut, fIn)
            local r = cc.RepeatForever:create(seq)
            tishiText:runAction(r)
        end

        if child then
            child:setColor(skinColloctColor[4])
        end
    end

    if isNew then
        -- new tag
        if not v.newTag then
            local newTag = gameUtil_createImage(newTagSrc)
            newTag:setPosition(midPos.x*2-4, midPos.y*2-4)
            v:addChild(newTag, 101)
            v.newTag = newTag            
        end
    else
        if v.newTag then
            v.newTag:removeFromParent()
            v.newTag = nil
        end
    end
end

local function fadeOutAndRemove(nodeIn, t)
    if not nodeIn then
        return
    end

    local fOut = cc.FadeOut:create(t)
    local seq = cc.Sequence:create(fOut, cc.CallFunc:create(function () nodeIn:removeFromParent() end))
    nodeIn:runAction(seq)
end

-- 获取经验显示
local PA = require("src.app.views.mmExtend.preciousAssetHelper")
local function getPreciousInfo(perciousInfoIn, heroId)
    return PA:getPreciousInfo(perciousInfoIn, heroId)
end

-- 等级是否可进阶
local function canLiftOrder(perciousInfoIn)
    return PA:canLiftOrder(perciousInfoIn)
end

-- 获取英雄信息
-- TODO:: 建立map 
local function getHeroInfo(id)
    local mm_data_playerHero = mm_data.playerHero
    for k,v in ipairs(mm_data_playerHero) do
        if v.id == id then    
            return v
        end
    end
end

-- clone
local function simpleClone(a, b) --a 复制b
    for k,v in pairs(b) do
        a[k] = v
    end
end

-- toMap
local function toMap(listWithId)
    local map = {}
    for i,v in ipairs(listWithId) do
        map[v.id] = v
    end
    return map
end

-- delya
local function delayExecute(node,time,func)
    local a1 = cc.DelayTime:create(time)
    local seq = cc.Sequence:create(a1, cc.CallFunc:create(func))
    node:stopAllActions()
    node:runAction(seq)
end

-- 是否是默认皮肤
local function isDefaultSkin(heroId, skinId)
    local curRes = gameUtil_getHeroTab(heroId)
    if not curRes then
        return false
    end

    if skinId == 1 then
        return true
    end
    return false
end

local function hasOpenedNoUsedSkin(_collectList)
    for k,v in ipairs(_collectList) do
        if v.flag > 1 and k > 1 then
            return true
        end
    end

    return false
end
----------------------------------------------------------------------
----------------------------------------------------------------------
local iteminfoList = nil
local preciousMatrial1 = nil
local preciousMatrial2 = nil
local preciousMatrialInMap1 = nil
local preciousMatrialInMap2 = nil
function HeroLayer:onCreate(param)

    local t100 = os.clock()
    print("timetest HeroLayer t100 "..t100)

    -- 开放
    self:checkOpenConditon()
    
    --
    selectRecord = {} -- 删除记录

    -- 
    self:updateItemInfo()

    -- 只需设置一次的
    self:infoSetup()

    self.app = param.app
    self.curHeroId = param.heroId
    self.LayerTag = param.LayerTag
    self.addType = param.addType

    if gameUtil.isFunctionOpen(closeFuncOrder.HERO_LEVEL_UP) == true then
        self.LayerTag = 1
    elseif gameUtil.isFunctionOpen(closeFuncOrder.HERO_SKILL_UP) == true then
        self.LayerTag = 3
    elseif gameUtil.isFunctionOpen(closeFuncOrder.HERO_XING_UP) == true then
        self.LayerTag = 3
    else
        gameUtil:addTishi({s = MoGameRet[990047]})
        self:removeFromParent()
        return
    end

    -- 皮肤浏览模式
    if mm.isPiFuCheckMode then
        self.LayerTag = 4
    end
    local baseNode = self:getResourceNode() 
    self.Node = baseNode

    -- 分页控制：
    self:initPageHandler(baseNode)

    -- 面板子控件获取
    self:initPanelChild()

    local t101 = os.clock()
    print("timetest HeroLayer t101-t100 "..t101 -t100)

    -- 英雄icon列表
    self:initHeroListBack()
    self.refreshHeroList = 0

    local t102 = os.clock()
    print("timetest HeroLayer t102-t101 "..t102 -t101)

    -- 英雄的阴影
    self:initShodow()

    mm.GuildScene.GuildViewEquipBtn = baseNode:getChildByName("Image_bgHero")
    
    -- 返回按钮
    self.backBtn =baseNode:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    --属性按钮
    local hBtn = baseNode:getChildByName("Image_bgHero"):getChildByName("Button_shuxing")
    hBtn:addTouchEventListener(handler(self, self.hBtnBack))

    -- schedule(self, self.addIntoTishiTab, 0.2)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))

    self:doChangePage()

    self:addLayerPoint()
    -- 红点
    self:updateRedPointsForPrecious()

    local t103 = os.clock()
    print("timetest HeroLayer t103-t102 "..t103 -t102)

    local function test( ... )--1295003698
        -- local t = {result=0, heroId=1278227254, preciousInfo={id=1295003697,order=1,lv=24,restExp=30}}
        -- self:handlePreciousMsg(t)

        -- local t = {result=0, heroId=1278227254,skinInfo={id=1278424369,collectList={{id=1278424369,flag=1}}}}
        -- self:handleSkinOnMsg(t)
        --self:updatePreciousMainUiAll()
        --self:updateRedPointsForPrecious()
    end
    local newNode = cc.Node:create()
    self:addChild(newNode)
    delayExecute(newNode, 1, test)   

    if not mm.isPiFuCheckMode then
        -- mm.HeroLayer = self
    end
end

-- 开放信息
function HeroLayer:checkOpenConditon()
    local level = 1
    local mm_data_playerinfo = mm_data.playerinfo
    if mm_data_playerinfo then
        local exp = mm_data_playerinfo.exp
        level = gameUtil.getPlayerLv(exp)
    end

    self.playerLevel = level
end

-- item 信息重新重新整理和更新UI
function HeroLayer:updateItemInfoAndUi()
    --
    self:updateItemInfo()
    -- 小黄书（升级）
    self:levelMatrialPreSet()
    -- 进阶
    if self.curSelectedPreciousInfo then
        self:orderMatrialPreSet(self.curSelectedPreciousInfo)
    end
end

-- 数据准备：
local EItemType = MM.EItemType
local item_zhibaoshengji = EItemType.item_zhibaoshengji
local item_zhibaojinjie = EItemType.item_zhibaojinjie
local xxx = 0
function HeroLayer:updateItemInfo()
    iteminfoList = mm.data.playerItem
    -- if xxx == 0 then
    --     -- table_insert(iteminfoList, {id=1227895609,num=1,level=1})
    --     -- table_insert(iteminfoList, {id=1227895609,num=1,level=1})
    --     -- table_insert(iteminfoList, {id=1227895609,num=1,level=1})

    --     table_insert(iteminfoList, {id=1513107504,num=5,level=1})
    --     table_insert(iteminfoList, {id=1513107505,num=5,level=1})        
    --     table_insert(iteminfoList, {id=1513107506,num=5,level=1})  
    --     table_insert(iteminfoList, {id=1513107507,num=5,level=1})
    --     table_insert(iteminfoList, {id=1513107508,num=5,level=1})    
    -- end
    -- xxx  = xxx + 1

    preciousMatrial1 = {}
    preciousMatrial2 = {}-- 进阶材料
    preciousMatrialInMap1 = {}
    preciousMatrialInMap2 = {}
    if iteminfoList then
        for i,v in ipairs(iteminfoList) do
            local id = v.id
            local curItemRes = itemResAll[id]
            if curItemRes and v.num then
                if curItemRes.ItemType == item_zhibaoshengji then
                    table_insert(preciousMatrial1, v)
                    preciousMatrialInMap1[id] = v
                elseif curItemRes.ItemType == item_zhibaojinjie then
                    table_insert(preciousMatrial2, v)
                    preciousMatrialInMap2[id] = v
                end
            end
        end
    end

    -- 排序
    local function sortFunc(a,b)
        local aRes = itemResAll[a.id]
        local bRes = itemResAll[b.id]
        return aRes.itemNum < bRes.itemNum
    end
    table.sort(preciousMatrial1, sortFunc)
    -- 
end

function HeroLayer:initShodow()
    local function createShow()
        local yiyinImageView = ccui.ImageView:create()
        yiyinImageView:loadTexture("res/UI/jm_yinying.png")    
        yiyinImageView:setName("yinying")
        yiyinImageView:setLocalZOrder(1)
        yiyinImageView:setScale(1)
        return yiyinImageView
    end

    local Node = self.Node
    -- local zhiBaoPanel = Node:getChildByName("Image_bgHero_0")
    local panels = {Node:getChildByName("Image_bgHero"), zhiBaoPanel}

    --属性按钮
    -- local hBtn = zhiBaoPanel:getChildByName("Button_shuxing")
    -- hBtn:addTouchEventListener(handler(self, self.hBtnBack))

    for i,v in ipairs(panels) do
        if v then
            local yiyinImageView = createShow()
            yiyinImageView:setPosition(v:getContentSize().width/2, v:getContentSize().height*0.3)
            v:addChild(yiyinImageView, 0)
        end
    end
end

function HeroLayer:initPageHandler(baseNode)
    if not baseNode then
        return
    end

    -- TODO::未检查,放函数里
    local shengJiBtn = baseNode:getChildByName("Button_shengji") self.shengJiBtn = shengJiBtn
    local jiNengBtn = baseNode:getChildByName("Button_jineng") self.jiNengBtn = jiNengBtn
    local shengXingBtn = baseNode:getChildByName("Button_shengxing") self.shengXingBtn = shengXingBtn
    local PreciousBtn = baseNode:getChildByName("Button_shengxing_0") self.PreciousBtn = PreciousBtn
    PreciousBtn:setVisible(false)
    PreciousBtn:setTouchEnabled(false)

    mm.GuildScene.GuildZhiBaoBtn = PreciousBtn
    -- 页的管理：
        -- 回调设置
    local pageBtns = {
        shengJiBtn, jiNengBtn, shengXingBtn, PreciousBtn
    }
    local function doChangePageFunc(tag)
        self:doChangePage(tag)
    end
    for i,v in ipairs(pageBtns) do
        if v then
            v.info = {pageTag=i, doChangePageFunc = doChangePageFunc}
            v:addTouchEventListener(handler(self, self.pageBtnCB))
        end
    end

    -- 底部面板
    local pageUiMap = {
        {func = handler(self, self.initShengJiUI), isShowPreciousUi = false}, 
        {func = handler(self, self.initJiNengUI), isShowPreciousUi = false}, 
        {func = handler(self, self.initShengXingUI), isShowPreciousUi = false}, 
        {func = handler(self, self.initPreciousUI), isShowPreciousUi = true, btn = pageBtns[4]}
    }
    self.pageUiMap = pageUiMap

    -- 至宝页，与其他3个不同，但放到了一起 
    local PreciousPanel = baseNode:getChildByName("Image_bgHero_0") self.PreciousPanel = PreciousPanel

    -- Image_bgHero
    local heroPanel = baseNode:getChildByName("Image_bgHero") self.heroPanel = heroPanel
    self:showPreciousPanel(false)
end

function HeroLayer:onExit()
    --隐藏选中框
    if self.curSecWidget then
        local secKuang = self.curSecWidget:getChildByName("selectHeroKuang")
        if secKuang then
            secKuang:setVisible(false)
        end
    end

    

    -- 皮肤浏览模式
    mm.isPiFuCheckMode = false

    game:dispatchEvent({name = EventDef.UI_MSG, code = "showbackground"})
    game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshTaskInfo"})
    -- game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshHeroList"})

    mm.HeroLayer = nil
end

function HeroLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function HeroLayer:onEnter()
    if mm.GuildId == 10009 then
        performWithDelay(self,function( ... )
            -- Guide:startGuildById(10010, self.guildPoolBtn)
            Guide:startGuildById(10011, mm.GuildScene.GuildHeroUp)
        end, 0.01)
    elseif mm.GuildId == 10020 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10021, self.guildEquip6Btn)
        end, 0.1)
    elseif mm.GuildId == 19011 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10023, mm.GuildScene.GuildJinJieBtn)
        end, 0.1)
    elseif mm.GuildId == 10502 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10503, mm.GuildScene.GuildZhiBaoBtn)
        end, 0.1)
    end
end

function HeroLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        local event_code = event.code
        if event.code == "heroUpequipAll" then
            self:heroUpequipAllBack(event.t)
        elseif event.code == "heroUpPinJie" then
            if self.LayerTag ~= 1 then
                return
            end

            if mm.GuildId == 10023 then
                Guide:setUserDefId(10024)
            end

            self:shenjieBack(event.t)
        elseif event.code == "heroLevelUp" then
            self.heroLevelUpTag = nil
            if self.LayerTag ~= 1 then
                return
            end
            self:heroLevelUpBcak(event.t)
        elseif event.code == "heroUpXin" then
            if self.LayerTag ~= 3 then
                return
            end
            self:shenxinBack(event.t)
        elseif event.code == "skillUp" then
            self.heroSkillUpTag = nil
            if self.LayerTag ~= 2 then
                return
            end
            self:skillUpBack(event.t)
            gameUtil.playUIEffect( "Skill_Levelup" )
        elseif event.code == "fiveRefreshNotify" then
            if self.LayerTag ~= 2 then
                return
            end
            self.curButtomLayer:getChildByName("Text_dianshu"):setString(mm.data.playerExtra.skillNum.."/"..PEIZHI.MAX_SKILL_NUM)
        elseif event.code == "buySomeThing" then
            if self.LayerTag ~= 2 then
                return
            end
            self.curButtomLayer:getChildByName("Text_dianshu"):setString(mm.data.playerExtra.skillNum.."/"..PEIZHI.MAX_SKILL_NUM)
            mm.data.time.skillTime = 0
        elseif event_code == "preciousLvUp" then
            if self.LayerTag ~= 4 then
                return
            end
            self:handlePreciousMsg(event.t)
        elseif event_code == "skinOn" then
            if self.LayerTag ~= 4 then
                return
            end
            self:handleSkinOnMsg(event.t)   
        elseif event_code == "getItem" then
            self:updateItemInfoAndUi() -- 更新item信息和ui
        end
    end
    if event.name == EventDef.UI_MSG then
        if event.code == "heroUpequip" then
            for i=1,#mm.data.playerHero do
                if self.curHeroTab and self.curHeroTab.id == mm.data.playerHero[i].id then
                    self.curHeroTab.jinlv = mm.data.playerHero[i].jinlv
                    self.curHeroTab.eqTab = mm.data.playerHero[i].eqTab
                    self.curHeroTab.exp = mm.data.playerHero[i].exp
                end
            end

            self:loadEquipInfo()
            -- 加载底部页面
            self:doChangePage()

            -- 装备属性飘字
            if event.equipId ~= nil then
                local equipRes = INITLUA:getEquipByid(event.equipId)
                self:displayEquipTishi(equipRes)
            end

            if event.equipIds ~= nil then
                local size = #event.equipIds
                for i=1,size do
                    local tempId = event.equipIds[i]
                    local equipRes = INITLUA:getEquipByid(tempId)
                    self:displayEquipTishi(equipRes)
                end
            end
        elseif event.code == "ExpGouMai" then
            -- 加载底部页面
            if self.LayerTag == 1 then
                local expValue = mm.data.playerinfo.exppool or 0
                self.expPool = self.curButtomLayer:getChildByName("Text_jingyan")
                local lv = gameUtil.getPlayerLv(mm.data.playerinfo.exp) - 1

                local AddExpPoolMax = gameUtil.getAccountAddExpPoolMaxExp(mm.data.playerinfo.exp)
                local viplevel = gameUtil.getPlayerVipLv( mm.data.playerinfo.vipexp )
                local vipInfo = gameUtil.getVipInfoByLevel( viplevel )
                local VIPExpPoolMax = vipInfo.VIPExpPoolMax

                self.curButtomLayer:getChildByName("LoadingBar_jingyan"):setPercent(expValue * 100 / (PEIZHI.EXP_POOL_BASE + AddExpPoolMax + VIPExpPoolMax ))
                self.expPool:setText(expValue.."/"..((PEIZHI.EXP_POOL_BASE + AddExpPoolMax + VIPExpPoolMax)))
            end
        elseif event.code == "buyEquipBack" then
            self:loadEquipInfo()
        elseif event.code == "addXingRedPoint" then
            -- self:addLayerPoint()
        elseif event.code == "BuyGoldBack" then
            if self.LayerTag == 2 then
                self:initJiNengUI()
            end
        end
    end
end

function HeroLayer:initHeroList()
    mm.req("getHero", {getType=1})
end

function HeroLayer:initHeroListBack()
    local t1 = os.clock()
    print("timetest HeroLayer t1 "..t1)

    local baseNode = self.Node

    self.HeroList = baseNode:getChildByName("ListView_Hero")
    
    
    local playerHero = util.copyTab(mm.data.playerHero)
    --排序
    for k,v in pairs(playerHero) do
        v.zhandouli = gameUtil.Zhandouli(v, playerHero, mm.data.playerExtra.pkValue)
    end
    local sortRules = {
        {
            func = function(v)
                return v.zhandouli
            end,
            isAscending = false
        },
    }
    playerHero = util.powerSort(playerHero, sortRules)

    self.curHeroTab = nil
    self.curHeroIndex = nil
    for k,v in pairs(playerHero) do
        if v.id == self.curHeroId then
            self.curHeroTab = v
            self.curHeroIndex = k
            break
        end
    end

    if not self.curHeroTab then
        local fisrtZhanli = playerHero[1]

        self.curHeroTab = fisrtZhanli
        self.curHeroId = fisrtZhanli.id
    end

    local t2 = os.clock()
    print("timetest HeroLayer t2-t1 "..t2 -t1)

    print("#playerHero ".. #playerHero)

    self:showHeroList(playerHero)

    local t3 = os.clock()
    print("timetest HeroLayer t3-t2 "..t3 -t2)

    -- 触摸
    local Imagebg01 = baseNode:getChildByName("Image_bgHero")
    Imagebg01:setTouchEnabled(true)
    Imagebg01:addTouchEventListener(handler(self, self.HeroShow))
    
    --显示英雄
    self:updateHeroShow()

    local t5 = os.clock()
    print("timetest HeroLayer t5-t3 "..t5-t3)

    -- 加载装备等信息
    self:loadEquipInfo()

    local t6 = os.clock()
    print("timetest HeroLayer t6-t5 "..t6-t5)

    -- 加载底部页面
    self:doChangePage()

    local t7 = os.clock()
    print("timetest HeroLayer t7-t6 "..t7-t6)

    -- 
    self:loadPreciousMainUi()

    local t8 = os.clock()
    print("timetest HeroLayer t8-t7 "..t8-t7)
end

function HeroLayer:showHeroList( countTab )
    local function fun( i, table, cell, cellIndex )
        cell:removeAllChildren()

        for k,v in pairs(mm.data.playerHero) do
            -- print(k,v)
            if v.id == table.id then
                table = v
            end
        end

        local node = gameUtil.getCSLoaderObj({name = "heroIcon", table = table, type = "mycreate", removeTab = {}})
        node:setSwallowTouches(false)
        node:setName("heroIcon")
        cell:addChild(node)
        cell:setTag(table.id)
        print("222222222222222222222222")
        self:addHeroIconPoint(node, table.id, table.xinlv)
        

        gameUtil.setTouXiang( node, table )

        print("showHeroList   "..table.id)
        print("showHeroList   "..self.curHeroId)

        if table.id == self.curHeroId then
            self.selectHeroKuang = node:getChildByName("selectHeroKuang") 
            if not self.selectHeroKuang then
                self.selectHeroKuang = ccui.ImageView:create()
                node:addChild(self.selectHeroKuang)
            else
                self.selectHeroKuang:setVisible(true)
            end
            self.selectHeroKuang:loadTexture("res/UI/jm_hero_select.png")
            self.selectHeroKuang:setPosition(node:getContentSize().width/2, node:getContentSize().height/2)
            self.selectHeroKuang:setName("selectHeroKuang")
            self.curSecWidget = node
        else
            local selectHeroKuang = node:getChildByName("selectHeroKuang") 
            if selectHeroKuang then
                selectHeroKuang:setVisible(false)
            end
        end
        node:setTouchEnabled(true)
        node:addTouchEventListener(handler(self, self.updateHero))
        node:setTag(table.id)
    end

    print("self.curHeroIndex    "..self.curHeroIndex)

    local sollowView = self.HeroList
    sollowView:removeAllChildren()

    game.cellTab = game.cellTab or {}
    self.tempTab = gameUtil.setSollowViewHor(sollowView, 8, self.curHeroIndex, countTab, 100, nil, fun, nil, nil)
    self.HeroList = sollowView
end

function HeroLayer:addHeroIconPoint(node, id, xinlv)
    print(self.LayerTag.."==="..id.."======"..xinlv)
    if gameUtil.canShengXing(id, xinlv) == 1 then
        if self.LayerTag == 3 then
            if node:getChildByName("redPoint") then
                node:getChildByName("redPoint"):setVisible(true)
            else
                gameUtil.addRedPoint(node, 0.9, 0.9)
            end
        else
            print("999999999999999999999999999")
            if node:getChildByName("redPoint") then
                node:getChildByName("redPoint"):setVisible(false)
            end
        end
    else
        print("88888888888888888888888888888")
        if node:getChildByName("redPoint") then
            node:getChildByName("redPoint"):setVisible(false)
        end
    end
end

function HeroLayer:updateHeroBack(widget, lvChange)
    if self.selectHeroKuang then
        self.selectHeroKuang:setVisible(false)
    end
    if mm.data.playerHero == nil then
        mm.data.playerHero = {}
    end
    self.curHeroTab = {}
    for k,v in pairs(mm.data.playerHero) do
        if v.id == self.curHeroId then
            self.curHeroTab = v
            break
        end
    end
    -- 
    local curIcon = self.curSecWidget
    --todo

    local secKuang = curIcon:getChildByName("selectHeroKuang")
    if not secKuang then
        self.selectHeroKuang = ccui.ImageView:create()
        self.selectHeroKuang:loadTexture("res/UI/jm_hero_select.png")
        self.selectHeroKuang:setPosition(curIcon:getContentSize().width/2, curIcon:getContentSize().height/2)
        curIcon:addChild(self.selectHeroKuang)
        self.selectHeroKuang:setName("selectHeroKuang")
    else
        secKuang:setVisible(true)
        self.selectHeroKuang = secKuang
    end


    --显示英雄
    self:updateHeroShow()

    -- 加载装备等信息
    self:loadEquipInfo()

    -- 加载底部页面
    self:doChangePage()

    -- 
    self:loadPreciousMainUi()
end

function HeroLayer:updateHeroShow(forceId)
    local curHeroTab = self.curHeroTab
    local curHeroId = self.curHeroId

    local curSkinInfo = curHeroTab.skinInfo or {}
    local curHeroRes = gameUtil_getHeroTab(curHeroId)
    local skinId = curSkinInfo.id
    if forceId then
        skinId = forceId
    end

    local skinAltId = 1
    local baseNode = self.Node
    local Imagebg01 = baseNode:getChildByName("Image_bgHero")

    if Imagebg01 then
        self:checkIsMaxLevel()
        local skeletonNode = self.skeletonNode


        if skeletonNode then
            local info = skeletonNode.info
            if info.heroId == curHeroId and info.skinId == skinId then
                return
            end

            skeletonNode:removeFromParent()
            self.skeletonNode = nil
        end


        local imageBgSize = Imagebg01:getContentSize()
        skeletonNode = gameUtil.createSkeletonAnimationForUnit(curHeroRes.Src..".json",curHeroRes.Src..".atlas",1)--gameUtil_createHeroSkinEx(curHeroRes, getSkinId(curHeroId, skinId), getSkinId(curHeroId, 1), 1) 
        skeletonNode:setScale(1.2)
        self.skeletonNode = skeletonNode
        skeletonNode.info = {heroId=curHeroId, skinId = skinId}
        skeletonNode:setAnimation(0, "stand", true)

        if skeletonNode then
            skeletonNode:setPosition(imageBgSize.width*0.5, imageBgSize.height*0.3)
            Imagebg01:addChild(skeletonNode, 3)
        end

    end

    -- 至宝层
    -- local Image_bgHero_0 = baseNode:getChildByName("Image_bgHero_0")
    -- if Image_bgHero_0 then
    --     self:checkIsMaxLevel(Image_bgHero_0)
    --     local skeletonNode = self.skeletonNode_0
    --     if skeletonNode then
    --         local _skeToRemove = skeletonNode
    --         fadeOutAndRemove(_skeToRemove, 0.5)
    --         self.skeletonNode_0 = nil
    --     end
    --     local imageBgSize = Image_bgHero_0:getContentSize()
    --     skeletonNode = gameUtil_createHeroSkinEx(curHeroRes, getSkinId(curHeroId, skinId), getSkinId(curHeroId, 1), 1.5) 
    --     self.skeletonNode_0 = skeletonNode
    --     if skeletonNode then
    --         local pos = cc.p(imageBgSize.width*0.5, imageBgSize.height*0.3)
    --         skeletonNode:setPosition(pos)
    --         pos.y = imageBgSize.height*0.5
    --         skeletonNode.pos = pos
    --         skeletonNode.parent = Image_bgHero_0
    --         Image_bgHero_0:addChild(skeletonNode, 1)
    --     end
    -- end
end

function HeroLayer:HeroShow( widget, touchkey )
    if touchkey == ccui.TouchEventType.ended then

        local random_num = math.random(1, 2)
        if random_num == 1 then
            self.skeletonNode:setAnimation(0, "skill", false)
        else
            self.skeletonNode:setAnimation(0, "attack", false)
        end
        local function toPlayHurtAction( ... )
            self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            self.skeletonNode:setAnimation(0, "stand", true)
        end 
        self.skeletonNode:registerSpineEventHandler(toPlayHurtAction,sp.EventType.ANIMATION_COMPLETE)
    end
end

function HeroLayer:loadEquipInfo( ... )
    self.equipItem = {}
    for i=1,6 do
        self.equipItem[i] = self.Node:getChildByName("Image_bgHero"):getChildByName("Image_0"..i)
        self.equipItem[i]:loadTexture("res/UI/jm_icon.png")
        self.equipItem[i]:removeAllChildren()
        local t = self:getHeroEqByIndex( self.curHeroTab.eqTab, i )

        if mm.GuildId == 10020 then
            if i == 6 then 
                self.guildEquip6Btn = self.equipItem[i]
            end
        end

        self.jinTab = gameUtil.getEquipId( self.curHeroTab.id, self.curHeroTab.jinlv )
        local eqId = self.jinTab.EquipEx[i]
        self.equipItem[i]:setTag(i)
        self.equipItem[i]:setTouchEnabled(true)
        self.equipItem[i]:addTouchEventListener(handler(self, self.secEqBack))

        local equipRes = INITLUA:getEquipByid( eqId )
        if t and t.eqIndex and t.eqId then
            self.equipItem[i]:loadTexture(gameUtil.getEquipIconRes(t.eqId))
            local pinPathRes = gameUtil.getEquipPinRes(equipRes.Quality)
            if #pinPathRes > 0 then
                local pinImgView = ccui.ImageView:create()
                pinImgView:loadTexture(pinPathRes)
                self.equipItem[i]:addChild(pinImgView, 4)
                pinImgView:setAnchorPoint(cc.p(0,0))
                pinImgView:setPosition(0, 0)
                pinImgView:setScale(self.equipItem[i]:getContentSize().width/pinImgView:getContentSize().width, self.equipItem[i]:getContentSize().height/pinImgView:getContentSize().height)
            end
        else
            if gameUtil.isHasEquip( eqId ) and gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= equipRes.eq_needLv then
                local imageView = cc.Sprite:create("res/UI/icon_jiahao_normal.png")
                local sprite = cc.Sprite:create(gameUtil.getEquipIconRes(eqId))
                local sprite_face = cc.Sprite:create("res/UI/icon_zhezhao.png")
                sprite_face:setOpacity(70)
                gameUtil.setGRAY(sprite)
                sprite:setScale(self.equipItem[i]:getContentSize().width/sprite:getContentSize().width, self.equipItem[i]:getContentSize().height/sprite:getContentSize().height)
                self.equipItem[i]:addChild(sprite, 1)
                self.equipItem[i]:addChild(imageView, 3)
                self.equipItem[i]:addChild(sprite_face, 2)
                sprite:setPosition(self.equipItem[i]:getContentSize().width * 0.5, self.equipItem[i]:getContentSize().height * 0.5)
                sprite_face:setPosition(self.equipItem[i]:getContentSize().width * 0.5, self.equipItem[i]:getContentSize().height * 0.5)
                imageView:setPosition(self.equipItem[i]:getContentSize().width * 0.5, self.equipItem[i]:getContentSize().height * 0.5)
                -- 可装备提示特效

                local up_play = gameUtil.createSkeAnmion( {name = "kzbts",scale = 1} )
                up_play:setAnimation(0, "stand", true)
                imageView:addChild(up_play, 10)
                local size = imageView:getContentSize()
                up_play:setPosition(size.width/2, size.height*0.5)
            else
                local imageView = cc.Sprite:create("res/UI/icon_jiahao_disable.png")
                local sprite = cc.Sprite:create(gameUtil.getEquipIconRes(eqId))
                local sprite_face = cc.Sprite:create("res/UI/icon_zhezhao.png")
                sprite_face:setOpacity(70)
                gameUtil.setGRAY(sprite)
                sprite:setScale(self.equipItem[i]:getContentSize().width/sprite:getContentSize().width, self.equipItem[i]:getContentSize().height/sprite:getContentSize().height)
                self.equipItem[i]:addChild(sprite)
                self.equipItem[i]:addChild(imageView)
                self.equipItem[i]:addChild(sprite_face)
                sprite:setPosition(self.equipItem[i]:getContentSize().width * 0.5, self.equipItem[i]:getContentSize().height * 0.5)
                sprite_face:setPosition(self.equipItem[i]:getContentSize().width * 0.5, self.equipItem[i]:getContentSize().height * 0.5)
                imageView:setPosition(self.equipItem[i]:getContentSize().width * 0.5, self.equipItem[i]:getContentSize().height * 0.5)
                --不可装备提示特效
                 -- local anime = gameUtil.createSkeAnmion( {name = "bkzbts"} )
                 local anime = gameUtil.createSkeAnmion( {name = "bkzbts",scale = 0.8} )
                anime:setAnimation(0, "stand", true)
                -- imageView:removeAllChildren()
                imageView:addChild(anime,10)
                -- anime:setName('duanwei')
                -- anime:setTag(curDuanWei)
                local size = imageView:getContentSize()
                anime:setPosition(size.width/2, size.height*0.5)

                -- local up_play = ccs.Armature:create("bkzbts")
                -- imageView:addChild(up_play, 10)
                -- local size = imageView:getContentSize()
                -- up_play:setPosition(size.width/2, size.height*0.5)
                -- up_play:setScale(3.5)
                -- up_play:getAnimation():playWithIndex(0)
            end
        end

    end

    -- 面板属性。
    local curHeroTab = self.curHeroTab
    local mm_data = mm.data
    local t = tPanelUpdate
    t.lv = gameUtil.getHeroLv(curHeroTab.exp, curHeroTab.jinlv)
    t.zhanli = gameUtil.Zhandouli( curHeroTab ,mm_data.playerHero, mm_data.playerExtra.pkValue)
    self:updatePanelParam(t)
end

-- 更新面板基础数值属性 -- 名字、等级、战力、星级等信息
local maxXin = 5
function HeroLayer:initPanelChild()
    local baseNode = self.Node
    local mainPanel1 = baseNode:getChildByName("Image_bgHero") self.mainPanel1 = mainPanel1
    local mainPanel2 = baseNode:getChildByName("Image_bgHero_0") self.mainPanel2 = mainPanel2
    -- 两个面板：
    local twoPanels = {mainPanel1, mainPanel2}
    local twoPanelChilds = {} self.twoPanelChilds = twoPanelChilds
    for i,v in ipairs(twoPanels) do
        repeat
            if not v then
                break
            end
            local info = {}
            -- 名字
            info.nameText = v:getChildByName("Text_name")
            -- 资质
            info.ziZhiText = v:getChildByName("Text_zizhi")
            -- 等级
            info.lvText = v:getChildByName("Text_lv")
            -- 星星
            local starts = {} info.starts = starts
            for j=1,maxXin do
                local t = v:getChildByName("Image_xin".."_0"..j)
                table_insert(starts, t)
            end
            -- 战力
            info.zhanliText = v:getChildByName("Text_zhanli")
            -- 属性
            info.shuXingImage = v:getChildByName("Image_shuxing")

            twoPanelChilds[i] = info
        until true
    end

    -- 至宝的几个位置
    self:initPreciousIconsBase()

    -- 皮肤按钮
    if mainPanel2 then
        local skinBtn = mainPanel2:getChildByName("Button_5") 
        if skinBtn then
            self.skinBtn = skinBtn
            skinBtn:addTouchEventListener(handler(self, self.skinBtnCB))
            skinBtn:setTouchEnabled(true)
        end
    end
end

local suxinImgTab = {{"res/UI/icon_fs_normal.png", "res/UI/icon_fs_disable.png"},
                    {"res/UI/icon_mt_normal.png", "res/UI/icon_mt_disable.png"},
                    {"res/UI/icon_dps_normal.png", "res/UI/icon_dps_disable.png"},}
local panelParams = {name=1, zizhi=1, stars=1, shuxing=1, zhanli=1, lv=1} -- 最后两个是真实值
function HeroLayer:updatePanelParam(t)
    if not t then
        return
    end 

    t.lv = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv)
    -- 名字、等级、战力、星级等信息
    local twoPanelChilds = self.twoPanelChilds

    local curHeroTab = self.curHeroTab
    local heroRes = gameUtil.getHeroTab( curHeroTab.id )
    local lv = t.lv
    local zhanli = t.zhanli
    for i,v in ipairs(twoPanelChilds) do
        local nameText = v.nameText
        if panelParams["name"] and nameText then
            local c, vv = gameUtil.getColor(curHeroTab.jinlv)
            nameText:setColor(c)        
            if vv > 0 then
                nameText:setText(gameUtil.getHeroTab( curHeroTab.id ).Name .. "+" .. vv)
            else
                nameText:setText(gameUtil.getHeroTab( curHeroTab.id ).Name)
            end
        end

        local ziZhiText = v.ziZhiText
        if panelParams["zizhi"] and ziZhiText then         
            ziZhiText:setString(MoGameRet[990015])

            local aptitudeImg = ziZhiText:getChildByName("aptitude")
            if aptitudeImg == nil then
                aptitudeImg = ccui.ImageView:create()
                ziZhiText:addChild(aptitudeImg)
            end
            
            aptitudeImg:setAnchorPoint(cc.p(0,0.5))
            aptitudeImg:loadTexture("res/UI/".."aptitude_"..heroRes.aptitude..".png")
            aptitudeImg:setName("aptitude")

            local textSize = ziZhiText:getContentSize()
            aptitudeImg:setPositionX(textSize.width + 10)
            aptitudeImg:setPositionY(textSize.height * 0.5)
        end

        local starts = v.starts
        if panelParams["stars"] then
            for j=1,#starts do
                if j <= curHeroTab.xinlv then
                    if curHeroTab.xinlv <= 5 then
                        starts[j]:loadTexture("res/UI/".."icon_xingxing_normal.png")
                    else
                        if curHeroTab.xinlv - j >= 5 then
                            starts[j]:loadTexture("res/UI/".."icon_yueliang_normal.png")
                        else
                            starts[j]:loadTexture("res/UI/".."icon_xingxing_normal.png")
                        end
                    end
                else
                    starts[j]:loadTexture("res/UI/".."icon_xingxing_disable.png")
                end
            end
        end

        local shuXingImage = v.shuXingImage
        if panelParams["shuxing"] and shuXingImage then
            shuXingImage:loadTexture(suxinImgTab[heroRes.herosuxin][1])  
        end

        local zhanliText = v.zhanliText
        if zhanli and zhanliText then
            zhanliText:setString("战力："..gameUtil.dealNumber(zhanli))
        end
        local lvText = v.lvText
        if lv and lvText then
            lvText:setString("Lv:"..lv)
        end
    end
    --return {lv=lv, zhanli=zhanli}
end

function HeroLayer:secEqBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        local eqId = self.jinTab.EquipEx[tag]
        local isUp = false
        local t = self:getHeroEqByIndex( self.curHeroTab.eqTab, tag )
        if t and t.eqIndex and t.eqId then
            isUp = true
        end

        local TtemMsgLayer = require("src.app.views.layer.TtemMsgLayer").new({app = self.app, eqId = eqId, isUp = isUp, index = tag, heroId = self.curHeroTab.id})
        self:addChild(TtemMsgLayer)
    end
end

function HeroLayer:getHeroEqByIndex( tab, index )
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

function HeroLayer:updateHero( widget, touchkey )
    if touchkey == ccui.TouchEventType.ended then
        self.curHeroId = widget:getTag()
        self.curSecWidget = widget
        self:updateHeroBack(widget)
        
    end
end

function HeroLayer:initJinJieUI( ... )
    if self.curButtomLayer ~= nil then
        self.curButtomLayer:removeFromParent()
    end
    self.curButtomLayer = createBottomPanel("jinJie")
    self.curButtomLayer:setPosition(0, 100)

    local jinjieBtn = self.curButtomLayer:getChildByName("Button_jinjie")
    gameUtil.setBtnEffect(jinjieBtn)
    jinjieBtn:setVisible(false)
    
    local oneKeyEquipBtn = self.curButtomLayer:getChildByName("Button_1KeyEquip")
    gameUtil.setBtnEffect(oneKeyEquipBtn)
    oneKeyEquipBtn:setVisible(true)
    
    local oneKeyEquip = true
    if self.curHeroTab.eqTab == nil or #self.curHeroTab.eqTab < 6 then
        -- local equipNum = 0
        -- for i=1,6 do
        --     local t = self:getHeroEqByIndex( self.curHeroTab.eqTab, i )
        --     self.jinTab = gameUtil.getEquipId( self.curHeroTab.id, self.curHeroTab.jinlv )
        --     local eqId = self.jinTab.EquipEx[i]

        --     local equipRes = INITLUA:getEquipByid( eqId )
        --     if t and t.eqIndex and t.eqId then
        --         -- 已装备
        --         equipNum = equipNum + 1
        --     else
        --         if gameUtil.isHasEquip( eqId ) and gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= equipRes.eq_needLv then
        --             equipNum = equipNum + 1
        --         end
        --     end
        -- end
        -- if equipNum == 6 then
        --     oneKeyEquip = false
        -- end
        oneKeyEquip = true
    else
        oneKeyEquip = false
    end

    if oneKeyEquip == true then
        oneKeyEquipBtn:setVisible(true)
        jinjieBtn:setVisible(false)
    else
        oneKeyEquipBtn:setVisible(false)
        jinjieBtn:setVisible(true)
    end

    local button_play = gameUtil.createSkeAnmion( {name = "sx", scale = 0.7} )
    button_play:setAnimation(0, "stand", true)
    jinjieBtn:addChild(button_play, 10)
    local size = jinjieBtn:getContentSize()
    button_play:setPosition(size.width/2, size.height/2)

    mm.GuildScene.GuildJinJieBtn = jinjieBtn

    jinjieBtn:addTouchEventListener(handler(self, self.jinjieBtnCbk))

    local button_play_2 = gameUtil.createSkeAnmion( {name = "sx", scale = 0.7} )
    button_play_2:setAnimation(0, "stand", true)
    oneKeyEquipBtn:addChild(button_play_2, 10)
    local size = oneKeyEquipBtn:getContentSize()
    button_play_2:setPosition(size.width/2, size.height/2)
    oneKeyEquipBtn:addTouchEventListener(handler(self, self.oneKeyEquipBtnCbk))
  

    local changedHero = util.copyTab(self.curHeroTab)
    changedHero.jinlv = changedHero.jinlv + 1
    changedHero.exp = 0

    local Image_icon = gameUtil.createTouXiang(self.curHeroTab)
    local Image_icon2 = gameUtil.createTouXiang(changedHero)
    local touxiang1 = self.curButtomLayer:getChildByName("Image_touxiang1")
    Image_icon:setContentSize(touxiang1:getContentSize())
    touxiang1:addChild(Image_icon)
    Image_icon:setPositionY(touxiang1:getContentSize().height*0.5)

    local touxiang2 = self.curButtomLayer:getChildByName("Image_touxiang2")
    Image_icon2:setContentSize(touxiang2:getContentSize())
    touxiang2:addChild(Image_icon2)
    Image_icon2:setPositionY(touxiang2:getContentSize().height*0.5)

    local curZhanli = gameUtil.Zhandouli( self.curHeroTab ,mm.data.playerHero, mm.data.playerExtra.pkValue)
    self.curButtomLayer:getChildByName("Text_zhanli1"):setString("战力："..curZhanli)
    self.curButtomLayer:getChildByName("Text_zhanli2"):setString("战力："..gameUtil.Zhandouli( changedHero ,mm.data.playerHero, mm.data.playerExtra.pkValue))
    --self.curButtomLayer:getChildByName("Text_zhanlijia"):setString(" +".. - curZhanli)
    local NeedGold = self.curButtomLayer:getChildByName("Text_jinbi")
    NeedGold:setString(gameUtil.getJinjieNeedGold(self.curHeroTab.jinlv))
    self:addChild(self.curButtomLayer)
    self:setBtn(self.shengJiBtn)

    -- 面板:
    local t = tPanelUpdate1
    t.zhanli = curZhanli
    self:updatePanelParam(t)
    self:checkIsMaxLevel()

    self.LayerTag = 1
    print("44444444444444444444444444444")
    self:addLayerPoint()
end

function HeroLayer:oneKeyEquipBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.curHeroTab.eqTab == nil or #self.curHeroTab.eqTab < 6 then
            local tempInfos = {}
            for i=1,6 do
                local t = self:getHeroEqByIndex( self.curHeroTab.eqTab, i )
                self.jinTab = gameUtil.getEquipId( self.curHeroTab.id, self.curHeroTab.jinlv )
                local eqId = self.jinTab.EquipEx[i]

                local equipRes = INITLUA:getEquipByid( eqId )
                if t and t.eqIndex and t.eqId then
                    -- 已装备
                else
                    if gameUtil.isHasEquip( eqId ) and gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= equipRes.eq_needLv then
                        local temp = {}
                        temp.id = eqId
                        temp.index = i
                        table.insert(tempInfos, temp)
                    end
                end
            end

            if tempInfos == nil or #tempInfos < 1 then
                gameUtil:addTishi({p = self, s = "尚未获得该装备"} )
                return
            end

            local heroId = self.curHeroTab.id
            mm.req("heroUpequipAll",{getType=1, heroId = heroId, eqInfos = tempInfos})
        else
            gameUtil:addTishi({p = self, s = "英雄装备已满"} )
        end
    end
end

function HeroLayer:jinjieBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then

        local heroId = self.curHeroTab.id
        local lv = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv)

        if self.curHeroTab.eqTab == nil or #self.curHeroTab.eqTab < 6 then
            gameUtil:addTishi({p = self, s = "英雄装备未满"} )
            return
        end
        if lv < 25 then
            gameUtil:addTishi({p = self, s = "英雄等级不足25级"} )
            return
        end

        if mm.data.playerinfo.gold < gameUtil.getJinjieNeedGold(self.curHeroTab.jinlv) then
            gameUtil.showDianJinShou( self, 1 )
            return
        end

        mm.req("heroUpPinJie",{getType=1,heroId = heroId})
    end
end

function HeroLayer:heroUpequipAllBack( event )
    if event.type == 0 then
        -- mm.data.playerHero = event.playerHero
        mm.data.playerEquip = event.playerEquip

        -- if self.LayerTag ~= 1 then
        --     return
        -- end
        game:dispatchEvent({name = EventDef.UI_MSG, code = "heroUpequip", equipIds = event.equipIds})
        gameUtil.playUIEffect( "Equip_Wear" )
    end
end

function HeroLayer:shenjieBack( event )
    if event.type == 0 then
        -- mm.data.playerHero = event.playerHero
        local JinJieTiShengLayer = require("src.app.views.layer.JinJieTiShengLayer").new({oldHero = self.curHeroTab})
        local size  = cc.Director:getInstance():getWinSize()
        mm.self:addChild(JinJieTiShengLayer, MoGlobalZorder[2000003])
        JinJieTiShengLayer:setContentSize(cc.size(size.width, size.height))
        JinJieTiShengLayer:setPosition(cc.p(0, 0))
        ccui.Helper:doLayout(JinJieTiShengLayer)

        for i=1,#mm.data.playerHero do
            if self.curHeroTab.ID == mm.data.playerHero[i].id then
                self.curHeroTab.exp = mm.data.playerHero[i].exp
                self.curHeroTab.jinlv = mm.data.playerHero[i].jinlv
                self.curHeroTab.eqTab = mm.data.playerHero[i].eqTab
                self.curHeroTab.xinlv = mm.data.playerHero[i].xinlv
            end
        end

        self:checkIsMaxLevel()
        self:updateShengJieOrShengXing()

        local up_play = gameUtil.createSkeAnmion( {name = "jjyx",scale = 1} )
        up_play:setAnimation(0, "stand", false)
        self.Node:getChildByName("Image_bgHero"):addChild(up_play, 10)

        local size = self.Node:getChildByName("Image_bgHero"):getContentSize()
        up_play:setPosition(size.width/2, size.height*0.4)

        performWithDelay(self,function( ... )
            up_play:removeFromParent()
        end, 0.5)


        local function back()
            self.skeletonNode:setScale(1)
        end
        local spawnAction = cc.Spawn:create(cc.ScaleTo:create(1, 2), cc.FadeOut:create(1))
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.25, 1.5), spawnAction, cc.CallFunc:create(back), cc.FadeIn:create(0.1))
        self.skeletonNode:runAction(seq)
    elseif event.type == 1 then
        gameUtil:addTishi({p = self, s = event.message})
    end
end

function HeroLayer:updateShengJieOrShengXing(lvChange)
    self.selectHeroKuang:removeFromParent()
    if mm.data.playerHero == nil then
        mm.data.playerHero = {}
    end
    self.curHeroTab = {}
    for k,v in pairs(mm.data.playerHero) do
        if v.id == self.curHeroId then
            self.curHeroTab = v
            break
        end
    end

    local parent = self.curSecWidget:getParent()
    parent:removeAllChildren()

    local node = gameUtil.getCSLoaderObj({name = "heroIcon", table = self.curHeroTab, type = "mycreate", removeTab = {}})
    node:setSwallowTouches(false)
    parent:addChild(node)
    parent:setTag(self.curHeroId)

    self.curSecWidget = node
    gameUtil.setTouXiang( node, self.curHeroTab )
    node:setTag(self.curHeroId)
    print("33333333333333333333333333333333333333")
    self:addHeroIconPoint(node, self.curHeroTab.id, self.curHeroTab.xinlv)

    self.selectHeroKuang = ccui.ImageView:create()
    self.selectHeroKuang:loadTexture("res/UI/jm_hero_select.png")
    self.selectHeroKuang:setPosition(node:getContentSize().width/2, node:getContentSize().height/2)
    node:addChild(self.selectHeroKuang)
    self.selectHeroKuang:setName("selectHeroKuang")
    -- 加载装备等信息
    self:loadEquipInfo()
    -- 加载底部页面
    self:doChangePage()
end

function HeroLayer:displayJinJieTishi( v )
    local strTab = {}
    if v.QUp_Attack ~= 0 then 
        table.insert(strTab, "攻击力 +"..v.QUp_Attack)
    end
    if v.QUp_HP ~= 0 then
        table.insert(strTab, "生命值 +"..v.QUp_HP)
    end
    if v.QUp_Speed ~= 0 then
        table.insert(strTab, "速度 +"..v.QUp_Speed)
    end
    if v.QUp_Dodge ~= 0 then
        table.insert(strTab, "闪躲 +"..v.QUp_Dodge)
    end
    if v.QUp_Crit ~= 0 then
        table.insert(strTab, "暴击 +"..v.QUp_Crit)
    end
    if v.QUp_WuFang ~= 0 then
        table.insert(strTab, "护甲 +"..v.QUp_WuFang)
    end
    if v.QUp_MoFang ~= 0 then
        table.insert(strTab, "魔抗 +"..v.QUp_MoFang)
    end
    local i = 1
    function show()
        if i > #strTab then
            return
        end
        local str = strTab[i]
        gameUtil:addTishi({p = self.Node:getChildByName("Image_bgHero"), s = str, z = 100, f = 30})
        i = i + 1
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(show)))
    end
    show()
end

function HeroLayer:initShengJiUI( ... )

    if gameUtil.isFunctionOpen(closeFuncOrder.HERO_LEVEL_UP) == false then
        gameUtil:addTishi({s = MoGameRet[990047]})
        return
    end

    if gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv) >= 25 then
        self:initJinJieUI()
        return
    end
    if self.curButtomLayer ~= nil then
        self.curButtomLayer:removeFromParent()
    end
    self.curButtomLayer = createBottomPanel("shengJi")
    self.curButtomLayer:setPosition(0, 100)
    self.exp_play = nil

    mm.GuildScene.guildViewJinJieBtn = self.curButtomLayer:getChildByName("Panel_Guild_ViewJinJie")

    local expValue = mm.data.playerinfo.exppool or 0
    self.expPool = self.curButtomLayer:getChildByName("Text_jingyan")
    local lv = gameUtil.getPlayerLv(mm.data.playerinfo.exp) - 1

    local AddExpPoolMax = gameUtil.getAccountAddExpPoolMaxExp(mm.data.playerinfo.exp)
    local viplevel = gameUtil.getPlayerVipLv( mm.data.playerinfo.vipexp )
    local vipInfo = gameUtil.getVipInfoByLevel( viplevel )
    local VIPExpPoolMax = vipInfo.VIPExpPoolMax

    local percent = expValue * 100 / (PEIZHI.EXP_POOL_BASE + AddExpPoolMax + VIPExpPoolMax )
    self.curButtomLayer:getChildByName("LoadingBar_jingyan"):setPercent(percent)
    if percent == 100 then -- 添加经验池满的特效
        if self.exp_play == nil then

            self.exp_play = gameUtil.createSkeAnmion( {name = "jyt",scale = 0.75} )
            self.exp_play:setAnimation(0, "stand", true)
            local loadingBar = self.curButtomLayer:getChildByName("LoadingBar_jingyan")
            loadingBar:addChild(self.exp_play, 10)
            local size = loadingBar:getContentSize()
            self.exp_play:setPosition(size.width/2, size.height/2)
        end
    end
    self.expPool:setText(expValue.."/"..((PEIZHI.EXP_POOL_BASE + AddExpPoolMax + VIPExpPoolMax)))
    local shengjiBtn = self.curButtomLayer:getChildByName("Button_shengji")
    shengjiBtn:addTouchEventListener(handler(self, self.shengjiBtnCbk))
    gameUtil.setBtnEffect(shengjiBtn)

    if #mm.data.playerHero > 5 then
        shengjiBtn:setTitleText("一键升级")
    end


    local button_play = gameUtil.createSkeAnmion( {name = "sx", scale = 0.7} )
    button_play:setAnimation(0, "stand", true)
    shengjiBtn:addChild(button_play, 10)
    local size = shengjiBtn:getContentSize()
    button_play:setPosition(size.width/2, size.height/2)

    self.curButtomLayer:getChildByName("Image_jinbi"):loadTexture("res/UI/icon_jingyan.png")
    self.curButtomLayer:getChildByName("Image_jinbi"):setScaleX(1.2)

    local changedHero = util.copyTab(self.curHeroTab)

    local NeedExp = INITLUA:getBckResNeedExpByLv(self.curHeroTab.jinlv, gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv))
    if #mm.data.playerHero > 5 then
        local tempNeedExp = INITLUA:getYijianLv(self.curHeroTab.jinlv, gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv), mm.data.playerinfo.exppool)
        if tempNeedExp > NeedExp then
            NeedExp = tempNeedExp
        end
    else
        NeedExp = INITLUA:getBckResNeedExpByLv(self.curHeroTab.jinlv, gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv))
    end
    changedHero.exp = changedHero.exp + NeedExp
    
    self.curButtomLayer:getChildByName("Text_jinbi"):setString(NeedExp)
    -- 构造改变后的英雄
    
    
    local changedAllHero = util.copyTab(mm.data.playerHero)
    for k,v in pairs(changedAllHero) do
        if v.id == changedHero.id then
            v = changedHero
            break
        end
    end

    local Image_icon = gameUtil.createTouXiang(self.curHeroTab)
    local Image_icon2 = gameUtil.createTouXiang(changedHero)
    local touxiang1 = self.curButtomLayer:getChildByName("Image_touxiang1")
    Image_icon:setContentSize(touxiang1:getContentSize())
    touxiang1:addChild(Image_icon)
    Image_icon:setPositionY(touxiang1:getContentSize().height*0.5)
    local touxiang2 = self.curButtomLayer:getChildByName("Image_touxiang2")
    Image_icon2:setContentSize(touxiang2:getContentSize())
    touxiang2:addChild(Image_icon2)
    Image_icon2:setPositionY(touxiang2:getContentSize().height*0.5)
    local curZhanli = gameUtil.Zhandouli( self.curHeroTab ,mm.data.playerHero, mm.data.playerExtra.pkValue)
    self.curButtomLayer:getChildByName("Text_zhanli1"):setString("战力："..curZhanli)
    self.curButtomLayer:getChildByName("Text_zhanli2"):setString("战力："..gameUtil.Zhandouli( changedHero ,changedAllHero, mm.data.playerExtra.pkValue))
    --self.curButtomLayer:getChildByName("Text_zhanlijia"):setString(" +"..gameUtil.Zhandouli( changedHero ,changedAllHero) - curZhanli)

    self:addChild(self.curButtomLayer)
    self:setBtn(self.shengJiBtn)
    self:checkIsMaxLevel()
    self.LayerTag = 1

print("555555555555555555555555555555555")
    self:addLayerPoint()

    -- 面板:
    local curHeroTab = self.curHeroTab
    local t = tPanelUpdate1
    t.zhanli = curZhanli
    t.lv = gameUtil.getHeroLv(curHeroTab.exp, curHeroTab.jinlv)
    self:updatePanelParam(t)

    if mm.GuildId == 10009 then
        self.guildPoolBtn = self.curButtomLayer:getChildByName("Panel_Guild_expPool")
        mm.GuildScene.GuildHeroUp = shengjiBtn
    end
end

function HeroLayer:shengjiBtnCbk( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
        if self.curHeroId == nil then
            gameUtil:addTishi({p = self, s = "请先选中英雄！"})
            return
        end
        if self.heroLevelUpTag then

        else
            local yijianshengji = 1
            if #mm.data.playerHero > 5 then
                yijianshengji = 2
            end
            for k,v in pairs(mm.data.playerHero) do
                if v.id == self.curHeroId then
                    self.curHeroTab = v
                    break
                end
            end

            print("  displayShengjiTishi  b     "..self.curHeroTab.lv)
            mm.req("heroLevelUp",{getType=yijianshengji, heroId = self.curHeroId})
            self.heroLevelUpTag = 1

            
        end

        gameUtil.playUIEffect( "Hero_Levelup" )
    end
end

function HeroLayer:checkIsMaxLevel(parent)
    if parent == nil then
        parent = self.Node:getChildByName("Image_bgHero")
    end
    local level = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv)
    print("checkIsMaxLevel      "..level)
    if level >= 25 then

        if parent:getChildByName("manji1") ~= nil then
            return
        end

        -- local yxmj = gameUtil.createSkeAnmion( {name = "yxmj", scale = 1} )
        -- yxmj:setAnimation(0, "stand", false)
        -- parent:addChild(yxmj, 10)
        -- local size = parent:getContentSize()
        -- yxmj:setPosition(cc.p(size.width/2, size.height*0.35))
        -- print("checkIsMaxLevel      "..level)
    else
        for i=1,4 do
            local effect = parent:getChildByName("manji"..i)
            if effect then
                effect:removeFromParent()
            end
        end
    end
end

function HeroLayer:heroLevelUpBcak( event )
    if event.type == 0 then
        --gameUtil:addTishi({p = self, s = "升级成功！"})
        -- mm.data.playerHero = event.playerHero
        mm.data.playerinfo.exppool = event.exppool
        -- 升级属性飘字
        self:displayShengjiTishi()
        self:updateHeroLevel()
        self:checkIsMaxLevel()
        -- self:updateHeroBack()
        
    elseif event.type == 1 then
        local exsit = self:getChildByTag(123456789)
        if exsit ~= nil then
            exsit:removeFromParent()
        end
        if gameUtil.isFunctionOpen(closeFuncOrder.EXP_EXCHANGE) == true then
            local BuyExpLayer = require("src.app.views.layer.BuyExpLayer").create()
            local size  = cc.Director:getInstance():getWinSize()
            BuyExpLayer:setTag(123456789)

            self:addChild(BuyExpLayer)
            BuyExpLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(BuyExpLayer)
        end
    elseif event.type == 2 then
        gameUtil:addTishi({p = self, s = MoGameRet[990023]})
    elseif event.type == 3 then
        gameUtil:addTishi({p = self, s = MoGameRet[990024]})
    elseif event.type == 4 then
        gameUtil:addTishi({p = self, s = MoGameRet[990047]})
    end

    if mm.GuildId == 10011 then
        Guide:setImageViewVisible(false)
    end
end

function HeroLayer:updateHeroLevel()
    for k,v in pairs(mm.data.playerHero) do
        if v.id == self.curHeroTab.id then
            self.curHeroTab = v
            break
        end
    end
    -- 构造改变后的英雄
    local changedHero = util.copyTab(self.curHeroTab)
    changedHero.exp = changedHero.exp + INITLUA:getBckResNeedExpByLv(changedHero.jinlv, gameUtil.getHeroLv(changedHero.exp, changedHero.jinlv))
    local changedAllHero = util.copyTab(mm.data.playerHero)
    for k,v in pairs(changedAllHero) do
        if v.id == changedHero.id then
            v = changedHero
            break
        end
    end
    local curIcon = self.curSecWidget
    local lv = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv)
    local lv2 = gameUtil.getHeroLv(changedHero.exp, changedHero.jinlv)
    curIcon:getChildByName("TextLvNode"):getChildByName("Text_lv"):setString(lv)
    local text1 = self.curButtomLayer:getChildByName("Image_touxiang1"):getChildByName("TouXiang"):getChildByName("TextLvNode")
    text1:getChildByName("Text_lv"):setString(lv)
    local text2 = self.curButtomLayer:getChildByName("Image_touxiang2"):getChildByName("TouXiang"):getChildByName("TextLvNode")
    text2:getChildByName("Text_lv"):setString(lv2)
    
    local curZhanli = gameUtil.Zhandouli( self.curHeroTab ,mm.data.playerHero, mm.data.playerExtra.pkValue)

    self.curButtomLayer:getChildByName("Text_zhanli1"):setString("战力："..curZhanli)
    self.curButtomLayer:getChildByName("Text_zhanli2"):setString("战力："..gameUtil.Zhandouli( changedHero ,changedAllHero, mm.data.playerExtra.pkValue))
    
    local expValue = mm.data.playerinfo.exppool or 0
    self.expPool = self.curButtomLayer:getChildByName("Text_jingyan")
    local lv_player = gameUtil.getPlayerLv(mm.data.playerinfo.exp) - 1

    local AddExpPoolMax = gameUtil.getAccountAddExpPoolMaxExp(mm.data.playerinfo.exp)
    local viplevel = gameUtil.getPlayerVipLv( mm.data.playerinfo.vipexp )
    local vipInfo = gameUtil.getVipInfoByLevel( viplevel )
    local VIPExpPoolMax = vipInfo.VIPExpPoolMax

    local percentR = expValue * 100 / (PEIZHI.EXP_POOL_BASE + AddExpPoolMax + VIPExpPoolMax )
    self.curButtomLayer:getChildByName("LoadingBar_jingyan"):setPercent(percentR)
    local percent = expValue.."/"..((PEIZHI.EXP_POOL_BASE + AddExpPoolMax + VIPExpPoolMax ))
    self.expPool:setText(percent)
    
    -- if percentR >= 100 then -- 添加经验池满的特效
    --     if self.exp_play == nil then

    --         self.exp_play = gameUtil.createSkeAnmion( {name = "jyt",scale = 0.75} )
    --         self.exp_play:setAnimation(0, "stand", true)
    --         local loadingBar = self.curButtomLayer:getChildByName("LoadingBar_jingyan")
    --         loadingBar:addChild(self.exp_play, 10)
    --         local size = loadingBar:getContentSize()
    --         self.exp_play:setPosition(size.width/2, size.height/2)
    --     end
    -- else
    --     if self.exp_play ~= nil then
    --         self.exp_play:removeFromParent()
    --         self.exp_play = nil
    --     end
    -- end

    local NeedExp = INITLUA:getBckResNeedExpByLv(self.curHeroTab.jinlv, gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv))
    self.curButtomLayer:getChildByName("Text_jinbi"):setString(NeedExp)

    local up_play = gameUtil.createSkeAnmion( {name = "sjyx", scale = 1} )
    up_play:setAnimation(0, "stand", false)
    self.Node:getChildByName("Image_bgHero"):addChild(up_play, 99999)
    local size = self.Node:getChildByName("Image_bgHero"):getContentSize()
    up_play:setPosition(size.width/2, size.height*0.2)
    print("sjyx sjyx sjyx sjyx sjyx sjyx sjyx sjyx ")

    if gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv) >= 25 then
        self:initJinJieUI()
        if mm.GuildId == 10011 then
            Guide:startGuildById(10012, mm.GuildScene.chengjiuBtn)
        end
    end

    -- 面板:
    local t = tPanelUpdate1
    t.zhanli = curZhanli
    t.lv = lv
    self:updatePanelParam(t)
end

function HeroLayer:displayShengjiTishi( ... )
    local t99100 = os.clock()
    print("timetest HeroLayer t99100 "..t99100)

    local strTab = {}
    local playerHeroTab = util.copyTab(mm.data.playerHero)
    local after = nil
    for k,v in pairs(playerHeroTab) do
        if v.id == self.curHeroTab.id then
            -- v.lv = v.lv + 1
            after = v
        end
    end
    print("  displayShengjiTishi  bbb     "..self.curHeroTab.lv)
    print("  displayShengjiTishi  after     "..after.lv)

    local t = util.copyTab(self.curHeroTab)
    local t2 = after --util.copyTab(self.curHeroTab)
    -- t.lv = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv)
    -- t2.lv = t.lv + 1
    local allHeroTiBuBeiLvXiShu = gameUtil.allHeroTiBuBeiLvXiShu( mm.data.playerHero )
    local allHeroTiBuBeiLvXiShu2 = gameUtil.allHeroTiBuBeiLvXiShu( playerHeroTab )

    local t99110 = os.clock()
    print("timetest HeroLayer t99110-t99100 "..t99110 -t99100)

    local ackNum = gameUtil.heroMBAck( t )
    ackNum = gameUtil.AckTBXZ( ackNum, allHeroTiBuBeiLvXiShu )
    local ackNum2 = gameUtil.heroMBAck( t2 )
    ackNum2 = gameUtil.AckTBXZ( ackNum2, allHeroTiBuBeiLvXiShu2 )
    if ackNum2 - ackNum ~= 0 then
        table.insert(strTab, "攻击力 +"..string.format("%0.2f",ackNum2 - ackNum))
    end

    local hpNum = gameUtil.hpMBAck( t )
    hpNum = gameUtil.HpTBXZ( hpNum, allHeroTiBuBeiLvXiShu )
    local hpNum2 = gameUtil.hpMBAck( t2 )
    hpNum2 = gameUtil.HpTBXZ( hpNum2, allHeroTiBuBeiLvXiShu2 )
    
    if hpNum2 - hpNum ~= 0 then
        table.insert(strTab, "生命值 +"..string.format("%0.2f",hpNum2 - hpNum))
    end

    local speedNum = gameUtil.speedMBAck( t )
    local speedNum2 = gameUtil.speedMBAck( t2 )
    if speedNum2 - speedNum ~= 0 then
        table.insert(strTab, "速度 +"..string.format("%0.2f",speedNum2 - speedNum))
    end

    local dodgeNum = gameUtil.dodgeMBAck( t )
    local dodgeNum2 = gameUtil.dodgeMBAck( t2 )
    if dodgeNum2 - dodgeNum ~= 0 then
        table.insert(strTab, "闪躲 +"..string.format("%0.2f",dodgeNum2 - dodgeNum))
    end

    local critNum = gameUtil.critMBAck( t )
    local critNum2 = gameUtil.critMBAck( t2 )
    if critNum2 - critNum ~= 0 then
        table.insert(strTab, "暴击 +"..string.format("%0.2f",critNum2 - critNum))
    end

    local wufangNum = gameUtil.wufangMBAck( t )
    local wufangNum2 = gameUtil.wufangMBAck( t2 )
    if wufangNum2 - wufangNum ~= 0 then
        table.insert(strTab, "护甲 +"..string.format("%0.2f",wufangNum2 - wufangNum))
    end

    local mofangNum = gameUtil.mofangMBAck( t )
    local mofangNum2 = gameUtil.mofangMBAck( t2 )
    if mofangNum2 - mofangNum ~= 0 then
        table.insert(strTab, "魔抗 +"..string.format("%0.2f",mofangNum2 - mofangNum))
    end

    local t99120 = os.clock()
    print("timetest HeroLayer t99120-t99110 "..t99120 -t99110)

    local i = 1
    function show()
        if i > #strTab then
            return
        end
        local str = strTab[i]
        gameUtil:addTishi({p = self.Node:getChildByName("Image_bgHero"), s = str, f = 30, type = 2, color = cc.c3b(0, 255, 0)})
        i = i + 1
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 + i * 0.1), cc.CallFunc:create(show)))
    end
    show()

    local t99130 = os.clock()
    print("timetest HeroLayer t99130-t99120 "..t99130 -t99120)

    -- for i=1, #strTab do
    --     gameUtil:addTishi({p = self.Node:getChildByName("Image_bgHero"), s = strTab[i], z = 100, f = 30, type = 2})
    -- end
end

function HeroLayer:displayEquipTishi( v )
    local strTab = {}
    if v.eq_gongji ~= 0 then
        table.insert(strTab, "攻击力 +"..string.format("%d", v.eq_gongji))
    end
    if v.eq_shenming ~= 0 then
        table.insert(strTab, "生命值 +"..string.format("%d", v.eq_shenming))
    end
    if v.eq_sudu ~= 0 then
        table.insert(strTab, "速度 +"..string.format("%d", v.eq_sudu))
    end
    if v.eq_duosan ~= 0 then
        table.insert(strTab, "闪躲 +"..string.format("%d", v.eq_duosan))
    end
    if v.eq_crit ~= 0 then
        table.insert(strTab, "暴击 +"..string.format("%d", v.eq_crit))
    end
    if v.eq_hujia ~= 0 then
        table.insert(strTab, "护甲 +"..string.format("%d", v.eq_hujia))
    end
    if v.eq_mokang ~= 0 then
        table.insert(strTab, "魔抗 +"..string.format("%d", v.eq_mokang))
    end
    local i = 1
    function show()
        if i > #strTab then
            return
        end
        local str = strTab[i]
        gameUtil:addTishi({p = self.Node:getChildByName("Image_bgHero"), s = str, f = 30, type = 2, color = cc.c3b(0, 255, 0)})
        i = i + 1
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(show)))
    end
    show()
    -- for i=1, #strTab do
    --     gameUtil:addTishi({p = self.Node:getChildByName("Image_bgHero"), s = strTab[i], z = 100, f = 30, type = 2})
    -- end
end

function HeroLayer:initJiNengUI( ... )

    if gameUtil.isFunctionOpen(closeFuncOrder.HERO_SKILL_UP) == false then
        gameUtil:addTishi({s = MoGameRet[990047]})
        return
    end

    -- gameUtil.removeRedPoint(self.jiNengBtn)
    if self.curButtomLayer ~= nil then
        self.curButtomLayer:removeFromParent()
    end
    self.curButtomLayer = createBottomPanel("jiNeng")
    self.curButtomLayer:setPosition(0, 100)
    self:updateSkill()
    self:addChild(self.curButtomLayer)
    self:setBtn(self.jiNengBtn)
    self.LayerTag = 2
print("666666666666666666666666666666666666666")
    self:addLayerPoint()
end

function HeroLayer:updateSkill( ... )
    self.curButtomLayer:getChildByName("Text_dianshu"):setString(mm.data.playerExtra.skillNum.."/"..PEIZHI.MAX_SKILL_NUM)
    schedule(self, function()
        if self.LayerTag == 2 then
            if mm.data.time.skillTime > 0 then
                self.curButtomLayer:getChildByName("Text_time"):setString("(".. util.timeFmt(mm.data.time.skillTime) ..")")
                self.curButtomLayer:getChildByName("Text_time"):setVisible(true)
            else
                self.curButtomLayer:getChildByName("Text_time"):setVisible(false)
            end
        end
    end, 1)
    local ListView = self.curButtomLayer:getChildByName("Image_di"):getChildByName("ListView_skill")
    ListView:removeAllItems()
    local HeroRes = gameUtil.getHeroTab( self.curHeroTab.id )
    for i=1, #HeroRes.Skills do
        local skillId = HeroRes.Skills[i]
        local skillRes = gameUtil.getHeroSkillTab( skillId )
        local skillIconRes = skillRes.sicon
        local custom_item = ccui.Layout:create()
        local skillLv = 0
        for k,v in pairs(self.curHeroTab.skill) do
            if v.index == 1 then
                skillLv = v.lv
                break
            end
        end
        local skill_item

        if skillLv == 0 then
            skill_item = cc.CSLoader:createNode("HerojinengItem_NO.csb")
            skill_item:getChildByName("Text_level"):setString("未学习")
        else
            skill_item = cc.CSLoader:createNode("HerojinengItem.csb")
            skill_item:getChildByName("Text_level"):setString("Lv: "..skillLv)
            local skillBtn = skill_item:getChildByName("Button_shengji")
            
            skillBtn:setTag(skillId)
            gameUtil.setBtnEffect(skillBtn)

            local costLv = skillLv+1
            if skillLv >= #Skillcost then
                costLv = #Skillcost
            end

            local skillCostRes = INITLUA:getSkillcostRes()
            skill_item:getChildByName("Text_jinbi"):setString(skillCostRes[costLv].SkillCost1)

            local lv = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv) + (self.curHeroTab.jinlv-1)*25
            local skillLvLimit = math.floor( lv / 5)
            if skillLv > skillLvLimit then
                skillBtn:addTouchEventListener(handler(self, self.tishiJinjie1))
                skillBtn:setBright(false)
            else
                skillBtn:addTouchEventListener(handler(self, self.skillUp))
                -- 添加技能可选特效

                -- local up_play = gameUtil.createSkeAnmion( {name = "jnkx",scale = 1} )
                -- up_play:setScale(0.745, 0.72)
                -- up_play:setAnimation(0, "stand", true)
                -- up_play:setName("texiao")
                -- local size = skill_item:getContentSize()
                -- up_play:setPosition(size.width/2, size.height/2)
                -- skill_item:addChild(up_play)

            end
            if skillCostRes[costLv].SkillCost1 > mm.data.playerinfo.gold then
                skill_item:getChildByName("Text_jinbi"):setColor(cc.c3b(255, 0, 0))
            end
        end
        skill_item:setName("skill_item")

        local iconNode = skill_item:getChildByName("Image_icon")
        local nameNode = skill_item:getChildByName("Text_name")
        local levelNode = skill_item:getChildByName("Text_level")

        iconNode:loadTexture(skillIconRes..".png")
        nameNode:setString(skillRes.Name)
        levelNode:setString("Lv: "..skillLv)

        local iconTypeRes = nil
        if MM.ETriggerType.TrXianshou == skillRes.TriggerType then
            iconTypeRes = "res/icon/jiemian/icon_tanxianshou.png"
            print("updateSkill      先手")
        elseif MM.ETriggerType.TrFansha == skillRes.TriggerType then
            iconTypeRes = "res/icon/jiemian/icon_tanfansha.png"
            print("updateSkill      反杀")
        elseif MM.ETriggerType.TrQiangrentou == skillRes.TriggerType then
            iconTypeRes = "res/icon/jiemian/icon_tanrentou.png"
            print("updateSkill      抢人头")
        end

        if iconTypeRes then
            local iconImageView = ccui.ImageView:create()
            iconImageView:loadTexture(iconTypeRes)    
            iconNode:addChild(iconImageView)
            iconImageView:setAnchorPoint(cc.p(0.5,0.5))
            iconImageView:setPosition(10,iconNode:getContentSize().height - 15)
            iconImageView:setScale(0.8)
        end



        local levelPosX = levelNode:getPositionX()
        local nameEndPosX = nameNode:getPositionX() + nameNode:getBoundingBox().width
        if nameEndPosX >= (levelPosX - 10) then
            local disX = nameEndPosX - levelPosX
            levelNode:setPositionX(levelPosX + disX + 10)
        end

        local descText = skillRes.Desc

        -- local valueText = skillRes.BPNum + skillRes.BPIncrement * skillLv
        -- descText = string.gsub(descText, "$", valueText)

        skill_item:getChildByName("Text_miaoshu"):setString(descText)
        skill_item:getChildByName("Image_bg"):setSwallowTouches(false)
        custom_item:setTouchEnabled(true)
        custom_item:addChild(skill_item)
        custom_item:setTag(skillId)
        custom_item:setContentSize(skill_item:getContentSize())
        ListView:pushBackCustomItem(custom_item)
    end
    for i=1, #HeroRes.SkillsEx do
        local skillId = HeroRes.SkillsEx[i]
        local skillRes = INITLUA:getPassiveResById( skillId )
        local skillIconRes = skillRes.sicon
        local custom_item = ccui.Layout:create()
        local skillLv = 0
        for k,v in pairs(self.curHeroTab.skill) do
            if v.index == i + 1 then
                skillLv = v.lv
                break
            end
        end

        local skill_item
        if skillLv == 0 then
            skill_item = cc.CSLoader:createNode("HerojinengItem_NO.csb")
            skill_item:getChildByName("Text_level"):setString("未学习")
            skill_item:getChildByName("Image_1"):setTouchEnabled(true)
            skill_item:getChildByName("Image_1"):addTouchEventListener(handler(self, self.tishiJinjie2))
        else
            skill_item = cc.CSLoader:createNode("HerojinengItem.csb")
            skill_item:getChildByName("Text_level"):setString("Lv: "..skillLv)
            local skillBtn = skill_item:getChildByName("Button_shengji")
            skillBtn:addTouchEventListener(handler(self, self.skillUp))
            skillBtn:setTag(skillId)
            gameUtil.setBtnEffect(skillBtn)

            local costLv = skillLv+1
            if skillLv >= #Skillcost then
                costLv = #Skillcost
            end
 
            local skillCostRes = INITLUA:getSkillcostRes()
            local src = "SkillCost"..(i+1)
            skill_item:getChildByName("Text_jinbi"):setString(skillCostRes[costLv][src])

            local lv = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv) + (self.curHeroTab.jinlv-1)*25
            local skillLvLimit = math.floor( lv / 5)
            local flag1 = 0
            local flag2 = 0
            if skillLv > skillLvLimit then
                skillBtn:addTouchEventListener(handler(self, self.tishiJinjie1))
                skillBtn:setBright(false)
            else
                skillBtn:addTouchEventListener(handler(self, self.skillUp))
                flag1 = 1
                
            end
            if skillCostRes[costLv][src] > mm.data.playerinfo.gold then
                skill_item:getChildByName("Text_jinbi"):setColor(cc.c3b(255, 0, 0))
            else
                flag2 = 1
            end
            if flag1 == 1 and flag2 == 1 and mm.data.playerExtra.skillNum > 0 then
                -- 添加技能可选特效

                -- local up_play = gameUtil.createSkeAnmion( {name = "jnkx",scale = 1} )
                -- up_play:setScale(0.745, 0.72)
                -- up_play:setAnimation(0, "stand", true)
                -- up_play:setName("texiao")
                -- local size = skill_item:getContentSize()
                -- up_play:setPosition(size.width/2, size.height/2)
                -- skill_item:addChild(up_play)
            end
        end
        skill_item:setName("skill_item")

        local iconNode = skill_item:getChildByName("Image_icon")
        local nameNode = skill_item:getChildByName("Text_name")
        local levelNode = skill_item:getChildByName("Text_level")

        iconNode:loadTexture(skillIconRes..".png")
        nameNode:setString(skillRes.Name)

        local levelPosX = levelNode:getPositionX()
        local nameEndPosX = nameNode:getPositionX() + nameNode:getBoundingBox().width
        if nameEndPosX >= (levelPosX - 10) then
            local disX = nameEndPosX - levelPosX
            levelNode:setPositionX(levelPosX + disX + 10)
        end

        local descText = skillRes.Desc
        local valueText = skillRes.BPNum + skillRes.BPIncrement * skillLv
        valueText = string.format("%.2f", valueText) 
        descText = string.gsub(descText, "$s", valueText)

        skill_item:getChildByName("Text_miaoshu"):setString(descText)
        skill_item:getChildByName("Image_bg"):setSwallowTouches(false)
        custom_item:setTouchEnabled(true)
        custom_item:addChild(skill_item)
        custom_item:setTag(skillId)
        custom_item:setContentSize(skill_item:getContentSize())
        ListView:pushBackCustomItem(custom_item)
    end
end

function HeroLayer:tishiJinjie1(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil:addTishi({p = self, s = MoGameRet[990016]})
    end
end

function HeroLayer:tishiJinjie2(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        gameUtil:addTishi({p = self, s = MoGameRet[990017]})
    end
end

local function getSkillIndex(heroId, skillId)
    local heroRes = gameUtil.getHeroTab(heroId)
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
end

function HeroLayer:skillUp( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
        self.skillId = widget:getTag()
        if mm.data.playerExtra.skillNum <= 0 then
            gameUtil.showBuyDialog( self, "skill")
            return
        end
        local skillInfo
        for k,v in pairs(self.curHeroTab.skill) do
            if v.id == widget:getTag() then
                skillInfo = v
                break
            end
        end
        local skillLvLimit = math.floor((gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv)+self.curHeroTab.jinlv*25) / 5)
        local skillCostRes = INITLUA:getSkillcostRes()
        if skillInfo.lv >= skillLvLimit or skillInfo.lv >= #skillCostRes then
            gameUtil:addTishi({p = self, s = "技能升级到达等级上限"})
            return
        end
        local skillRes = gameUtil.getHeroSkillTab(widget:getTag())
        if skillRes == nil then
            skillRes = INITLUA:getPassiveResById(widget:getTag())
        end
        if skillRes == nil then
            return
        end
        local heroRes = gameUtil.getHeroTab(self.curHeroTab.id)
        local index = getSkillIndex(self.curHeroTab.id, self.skillId)

        local src = "SkillCost"..index
        local costGold = skillCostRes[skillInfo.lv+1][src]
        if costGold > mm.data.playerinfo.gold then
            gameUtil.showDianJinShou( self, 1 )
            return
        end
        
        if not self.heroSkillUpTag then
            mm.req("skillUp", {type = 0, heroId = self.curHeroTab.id, skillId = widget:getTag()})
            self.heroSkillUpTag = 1
        end
    end
end

function HeroLayer:skillUpBack(event)
    if event.type == 1 then
        gameUtil:addTishi({p = self, s = event.message})
    elseif event.type == 0 then
        self.curHeroTab = {}
        for k,v in pairs(mm.data.playerHero) do
            if v.id == self.curHeroId then
                self.curHeroTab = v
                break
            end
        end

        local sIndex = getSkillIndex(self.curHeroTab.id, self.skillId)
        local skillLv = 0
        for k,v in pairs(self.curHeroTab.skill) do
            if v.index == sIndex then
                skillLv = v.lv
                break
            end
        end

        local curZhanli = gameUtil.Zhandouli( self.curHeroTab ,mm.data.playerHero, mm.data.playerExtra.pkValue)
        self.curButtomLayer:getChildByName("Text_dianshu"):setString(mm.data.playerExtra.skillNum.."/"..PEIZHI.MAX_SKILL_NUM)
        local ListView = self.curButtomLayer:getChildByName("Image_di"):getChildByName("ListView_skill")
        local skill_item = ListView:getChildByTag(self.skillId):getChildByName("skill_item")
        skill_item:getChildByName("Text_level"):setString("Lv: "..skillLv)

        local skillRes = INITLUA:getPassiveResById(self.skillId)
        if skillRes ~= nil then
            local descText = skillRes.Desc
            local valueText = skillRes.BPNum + skillRes.BPIncrement * skillLv
            valueText = string.format("%.2f", valueText) 
            descText = string.gsub(descText, "$s", valueText)

            skill_item:getChildByName("Text_miaoshu"):setString(descText)
        end

        local index = ListView:getIndex(skill_item:getParent())
        local skillCostRes = INITLUA:getSkillcostRes()
        local src = "SkillCost"..(index + 1)
        local flag1 = 0
        local flag2 = 0
        skill_item:getChildByName("Text_jinbi"):setString(skillCostRes[skillLv+1][src])
        if skillCostRes[skillLv+1][src] > mm.data.playerinfo.gold then
            skill_item:getChildByName("Text_jinbi"):setColor(cc.c3b(255, 0, 0))
        else
            flag2 = 1
        end

        local lv = gameUtil.getHeroLv(self.curHeroTab.exp, self.curHeroTab.jinlv) + (self.curHeroTab.jinlv-1)*25
        local skillLvLimit = math.floor( lv / 5)
        local skillBtn = skill_item:getChildByName("Button_shengji")
        if skillLv > skillLvLimit then
            skillBtn:addTouchEventListener(handler(self, self.tishiJinjie1))
            skillBtn:setBright(false)
        else
            skillBtn:addTouchEventListener(handler(self, self.skillUp))
            flag1 = 1
        end

        if flag1 == 1 and flag2 == 1 and mm.data.playerExtra.skillNum > 0 then
            if skill_item:getChildByName("texiao") == nil then
                -- 添加技能可选特效
                -- local up_play = gameUtil.createSkeAnmion( {name = "jnkx",scale = 1} )
                -- up_play:setScale(0.745, 0.72)
                -- up_play:setAnimation(0, "stand", true)
                -- up_play:setName("texiao")
                -- local size = skill_item:getContentSize()
                -- up_play:setPosition(size.width/2, size.height/2)
                -- skill_item:addChild(up_play)
            end
        else
            if skill_item:getChildByName("texiao") ~= nil then
                skill_item:getChildByName("texiao"):removeFromParent()
            end
        end

        local skill_icon = skill_item:getChildByName("Image_icon")
        local skill_play = gameUtil.createSkeAnmion( {name = "jntbsj",scale = 0.9} )
        skill_play:setAnimation(0, "stand", false)
        skill_icon:addChild(skill_play, 10)
        local size = skill_icon:getContentSize()
        skill_play:setPosition(size.width/2, size.height*0.5)
        performWithDelay(self,function( ... )
            skill_play:removeFromParent()
        end, 0.5)

        -- 面板:
        local t = tPanelUpdate1
        t.zhanli = curZhanli
        self:updatePanelParam(t)

    end
end

-- function HeroLayer:shengXingBtnCbk(widget, touchkey)
--     if touchkey == ccui.TouchEventType.ended then
--         self:initShengXingUI()
--     end
-- end

function HeroLayer:initShengXingUI( ... )

    if gameUtil.isFunctionOpen(closeFuncOrder.HERO_XING_UP) == false then
        gameUtil:addTishi({s = MoGameRet[990047]})
        return
    end

    if self.curButtomLayer ~= nil then
        self.curButtomLayer:removeFromParent()
    end
    -- gameUtil.removeRedPoint(self.shengXingBtn)
    self.curButtomLayer = createBottomPanel("shengXIng")
    self.curButtomLayer:setPosition(0, 100)
    -- 魂石进度条
    local hunshiId =  gameUtil.getHeroTab( self.curHeroTab.id ).herohunshiID
    local num = gameUtil.getHunshiNumByid( hunshiId )
    local xinlv = self.curHeroTab.xinlv
    if xinlv > #PEIZHI.xinji then
        xinlv = #PEIZHI.xinji
    end
    local temp = xinlv + 1
    if temp > #PEIZHI.xinji then
        temp = #PEIZHI.xinji
    end
    local needNum = PEIZHI.xinji[temp].num

    local suipianBar = self.curButtomLayer:getChildByName("LoadingBar_suipian")
    suipianBar:setPercent(num / needNum * 100)

    local suipianText = self.curButtomLayer:getChildByName("Text_suipian")
    suipianText:setText(num .. "/" .. needNum)

    local shengxingBtn = self.curButtomLayer:getChildByName("Button_shengxing")
    gameUtil.setBtnEffect(shengxingBtn)

    local button_play = gameUtil.createSkeAnmion( {name = "sx", scale = 0.7} )
    button_play:setAnimation(0, "stand", true)
    shengxingBtn:addChild(button_play, 10)
    local size = shengxingBtn:getContentSize()
    button_play:setPosition(size.width/2, size.height/2)

    shengxingBtn:addTouchEventListener(handler(self, self.shengxingBtnCbk))

    -- 构造改变后的英雄
    local changedHero = util.copyTab(self.curHeroTab)
    changedHero.xinlv = changedHero.xinlv + 1
    if changedHero.xinlv > #PEIZHI.xinji then
        changedHero.xinlv = #PEIZHI.xinji
    end
    local changedAllHero = util.copyTab(mm.data.playerHero)
    for k,v in pairs(changedAllHero) do
        if v.id == changedHero.id then
            v = changedHero
            break
        end
    end

    local Image_icon = gameUtil.createTouXiang(self.curHeroTab)
    local Image_icon2 = gameUtil.createTouXiang(changedHero)
    local touxiang1 = self.curButtomLayer:getChildByName("Image_touxiang1")
    Image_icon:setContentSize(touxiang1:getContentSize())
    touxiang1:addChild(Image_icon)
    Image_icon:setPositionY(touxiang1:getContentSize().height*0.5)
    local touxiang2 = self.curButtomLayer:getChildByName("Image_touxiang2")
    Image_icon2:setContentSize(touxiang2:getContentSize())
    touxiang2:addChild(Image_icon2)
    Image_icon2:setPositionY(touxiang2:getContentSize().height*0.5)
    local curZhanli = gameUtil.Zhandouli( self.curHeroTab ,mm.data.playerHero, mm.data.playerExtra.pkValue)
    self.curButtomLayer:getChildByName("Text_zhanli1"):setString("战力："..curZhanli)
    self.curButtomLayer:getChildByName("Text_zhanli2"):setString("战力："..gameUtil.Zhandouli( changedHero ,mm.data.playerHero, mm.data.playerExtra.pkValue))
    --self.curButtomLayer:getChildByName("Text_zhanlijia"):setString(" +"..gameUtil.Zhandouli( changedHero ,changedAllHero) - curZhanli)
    local NeedGold = self.curButtomLayer:getChildByName("Text_jinbi")
    NeedGold:setString(gameUtil.getShengXingNeedGold(self.curHeroTab.xinlv))
    self:addChild(self.curButtomLayer)
    self:setBtn(self.shengXingBtn)
    self.LayerTag = 3

    if self.curHeroTab.xinlv >= #PEIZHI.xinji then
        self.curButtomLayer:getChildByName("Text_zhanli1"):setString("星级已达满值")
        self.curButtomLayer:getChildByName("Text_zhanli2"):setVisible(false)
        touxiang2:setVisible(false)
        NeedGold:setVisible(false)
        self.curButtomLayer:getChildByName("Image_jiantou"):setVisible(false)
        self.curButtomLayer:getChildByName("Image_jinbi"):setVisible(false)
    end

    local t = tPanelUpdate1
    t.zhanli = curZhanli
    self:updatePanelParam(t)

print("777777777777777777777777777777777========"..self.curHeroTab.id)
    self:addLayerPoint()
end

function HeroLayer:shengxingBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.curHeroTab.xinlv >= #PEIZHI.xinji then
            gameUtil:addTishi({s = MoGameRet[990049]})
            return
        end

        if mm.data.playerinfo.gold < gameUtil.getShengXingNeedGold(self.curHeroTab.xinlv) then
            gameUtil.showDianJinShou( self, 1 )
            return
        end
        mm.req("heroUpXin",{getType=1,heroId = self.curHeroId})
    end
end

function HeroLayer:shenxinBack( event )
    if event.type == 0 then
        self:addXingJiTiShengLayer(self.curHeroTab)
        
        self.curHeroTab.xinlv = self.curHeroTab.xinlv + 1
        mm.data.playerHunshi = event.playerHunshi
        -- mm.data.playerHero = event.playerHero


        local up_play = gameUtil.createSkeAnmion( {name = "sxyx"} )
        up_play:setAnimation(0, "stand", false)
        self.Node:getChildByName("Image_bgHero"):addChild(up_play, 10)
        local size = self.Node:getChildByName("Image_bgHero"):getContentSize()
        up_play:setPosition(size.width/2, size.height*0.4)

        local function back()
            self.skeletonNode:setScale(1)
        end
        local spawnAction = cc.Spawn:create(cc.ScaleTo:create(1, 2), cc.FadeOut:create(1))
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.25, 1.5), spawnAction, cc.CallFunc:create(back), cc.FadeIn:create(0.1))
        self.skeletonNode:runAction(seq)

        -- local Image_xin = self.Node:getChildByName("Image_bgHero"):getChildByName("Image_xin".."_0"..(self.curHeroTab.xinlv%6 == 0 and 1 or self.curHeroTab.xinlv%6))
        -- gameUtil.addArmatureFile("res/Effect/uiEffect/yxsx/yxsx.ExportJson")
        -- local xin_play = ccs.Armature:create("yxsx")
        -- Image_xin:addChild(xin_play, 10)
        -- local size = Image_xin:getContentSize()
        -- xin_play:setPosition(size.width/2, size.height/2)
        -- xin_play:setScale(3)
        -- xin_play:getAnimation():playWithIndex(0)

        -- local function animationEventEndx(armatureBack, movementType, movementID)
        --     if movementType == ccs.MovementEventType.complete then
        --         performWithDelay(self,function( ... )
        --             --Image_xin:loadTexture("res/UI/".."icon_xingxing_normal.png")
        --             xin_play:removeFromParent()
        --         end, 0.01)
        --     end
        -- end
        -- xin_play:getAnimation():setMovementEventCallFunc(animationEventEndx)
        self:updateShengJieOrShengXing()

        -- 升级属性飘字
        -- local heroInfo = nil
        -- for k,v in pairs(mm.data.playerHero) do
        --     if self.tab.id == self.heroId then
        --         heroInfo = v
        --         break
        --     end
        -- end
        -- if heroInfo == nil then
        --     return
        -- end
        -- local RankRes
        -- if mm.data.playerinfo.camp == 1 then
        --     RankRes = INITLUA:getLOLStarResFromMap(heroInfo.id, heroInfo.xinlv)
        -- else
        --     RankRes = INITLUA:getDOTAStarResFromMap(heroInfo.id, heroInfo.xinlv)
        -- end
        -- self:displayUpXingTishi(RankRes)
    else
        gameUtil:addTishi({p = self, s = event.message} )
    end
end

function HeroLayer:hBtnBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local Attribute = require("src.app.views.layer.Attribute").new({app = self.app, tab = self.curHeroTab})
        self:addChild(Attribute)
    end
end

function HeroLayer:setBtn( btn )
    self.shengJiBtn:setBright(true)
    self.jiNengBtn:setBright(true)
    self.shengXingBtn:setBright(true)
    self.PreciousBtn:setBright(true)

    self.shengJiBtn:setEnabled(true)
    self.jiNengBtn:setEnabled(true)
    self.shengXingBtn:setEnabled(true)
    self.PreciousBtn:setEnabled(true)
    
    btn:setBright(false)
    btn:setEnabled(false)
end

function HeroLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm.piaoZiTab.contentTab = {}
        if self.addType and self.addType == 999 then
            self:removeFromParent()
        else
            mm.clearLayer()
        end
    end
end

function HeroLayer:addIntoTishiTab()
    if #self.tishiTab <= 0 or #self.readyTab >= 10 then
        return
    end
    self:addIntoReady(self.tishiTab[1])
    table.remove(self.tishiTab, 1)
end

function HeroLayer:addIntoReady( str )

    local node = gameUtil.getCSLoaderObj({name = "heroTishiText", node = {}, type = "mycreate", removeTab = {}})
    node:setString(str)
    local tishiText = node
    self.Node:getChildByName("Image_bgHero"):addChild(tishiText, 10000)
    local size = self.Node:getChildByName("Image_bgHero"):getContentSize()
    tishiText:setColor(cc.c3b(0, 255, 0))
    tishiText:setScale(2.5)
    tishiText:setPosition(size.width * 0.5, size.height * 0.3)
    local function Back( ... )
        table.remove(self.readyTab, 1)
        tishiText:removeFromParent()
    end
    tishiText:runAction( cc.Sequence:create(cc.ScaleTo:create(0.2,1),cc.DelayTime:create(3),cc.FadeOut:create(0.5),cc.CallFunc:create(Back)))
    for k,v in pairs(self.readyTab) do
        cc.Director:getInstance():getActionManager():addAction(cc.MoveBy:create(0.3, cc.p(0, tishiText:getContentSize().height)), v, true)
    end
    table.insert(self.readyTab, tishiText)
    tishiText:retain()
end

function HeroLayer:addLayerPoint()
    local canShengXingNum = 0
    for k,v in pairs(mm.data.playerHero) do
        if gameUtil.canShengXing(v.id, v.xinlv) == 1 then
            canShengXingNum = canShengXingNum + 1
        end
        local custom_item = self.HeroList:getChildByTag(v.id)
        if custom_item then
            custom_item = custom_item:getChildByName("heroIcon")
            print("111111111111111111111111111")
            self:addHeroIconPoint(custom_item, v.id, v.xinlv)
        end
    end
    if canShengXingNum > 0 then
        gameUtil.addRedPoint(self.shengXingBtn, 0.7, 0.6)
    else
        gameUtil.removeRedPoint(self.shengXingBtn)
    end

    -- if gameUtil.canShengXing(self.curHeroTab.id, self.curHeroTab.xinlv) == 1 then
    --     gameUtil.addRedPoint(self.shengXingBtn, 0.7, 0.6)
    -- end

    if mm.data.playerExtra.skillNum >= PEIZHI.MAX_SKILL_NUM then
        gameUtil.addRedPoint(self.jiNengBtn, 0.7, 0.6)
    else
        gameUtil.removeRedPoint(self.jiNengBtn)
    end
end

function HeroLayer:addXingJiTiShengLayer(oldHero)
    newHero = util.copyTab(oldHero)
    newHero.xinlv = newHero.xinlv + 1
    if newHero.xinlv > 4 then
        self.XingJiTiShengLayer = cc.CSLoader:createNode("Herojinjietisheng.csb")
    else
        self.XingJiTiShengLayer = cc.CSLoader:createNode("Heroxingjitisheng.csb")

        local bottomLayer = self.XingJiTiShengLayer:getChildByName("Image_bg"):getChildByName("Image_bottom")
        local HeroRes = gameUtil.getHeroTab( oldHero.id )
        local skillId = HeroRes.SkillsEx[newHero.xinlv - 1]
        local skillRes = INITLUA:getPassiveResById( skillId )
        bottomLayer:getChildByName("Text_skill_name"):setString(skillRes.Name)

        local descText = skillRes.Desc
        local valueText = skillRes.BPNum + skillRes.BPIncrement * 1
        valueText = string.format("%.2f", valueText) 
        descText = string.gsub(descText, "$s", valueText)

        bottomLayer:getChildByName("Text_miaoshu"):setString(descText)
        bottomLayer:getChildByName("Image_skill"):loadTexture(skillRes.sicon..".png")
    end

    local image_bg = self.XingJiTiShengLayer:getChildByName("Image_bg")
    image_bg:setVisible(false)
    self.XingJiTiShengLayer:getChildByName("Panel_touch"):setOpacity(0)
    performWithDelay(self, function()
        image_bg:setVisible(true)
        self.XingJiTiShengLayer:getChildByName("Panel_touch"):setOpacity(255)
    end, 1.3)

    self:addChild(self.XingJiTiShengLayer, 999999)
    local size  = cc.Director:getInstance():getWinSize()
    self.XingJiTiShengLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.XingJiTiShengLayer)


    local button_back = image_bg:getChildByName("Button_back")
    gameUtil.setBtnEffect(button_back)
    button_back:addTouchEventListener(handler(self, self.back))

    local touxiang1 = image_bg:getChildByName("Image_bg01"):getChildByName("Image_touxiang1")
    local touxiang2 = image_bg:getChildByName("Image_bg01"):getChildByName("Image_touxiang2")
    local Image_icon1 = gameUtil.createTouXiang(oldHero)
    touxiang1:addChild(Image_icon1)
    local Image_icon2 = gameUtil.createTouXiang(newHero)
    touxiang2:addChild(Image_icon2)

    local attributeTab = gameUtil.getHeroDiff(oldHero, newHero)
    for i=1, 6 do
        local textOld = image_bg:getChildByName("Text_"..i.."_1")
        local textChange = image_bg:getChildByName("Text_"..i.."_2")
        if i == 4 then
            textOld:setString(string.format("%.1f", attributeTab[i].old).."%")
            textChange:setString(" + "..string.format("%.1f", attributeTab[i].change).."%")
        else
            textOld:setString(string.format("%.1f", attributeTab[i].old))
            textChange:setString(" + "..string.format("%.1f", attributeTab[i].change))
        end
    end
end

function HeroLayer:back(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.XingJiTiShengLayer ~= nil then
            self.XingJiTiShengLayer:removeFromParent()
        end
    end
end

-- @START : 至宝和皮肤 Image_01
-- 
local EPRICIOUS_ASSET_TYPE = MM.EPRICIOUS_ASSET_TYPE
local preciousIndexToUi = {
    [EPRICIOUS_ASSET_TYPE.PRICIOUS_ASSET_WEAPON] = 1,
    [EPRICIOUS_ASSET_TYPE.PRICIOUS_ASSET_ARMOR] = 2,
    [EPRICIOUS_ASSET_TYPE.PRICIOUS_ASSET_SHOES] = 3,
    [EPRICIOUS_ASSET_TYPE.PRICIOUS_ASSET_DECORATION] = 4,
}

function HeroLayer:initPreciousIconsBase()
    local mainPanel2 = self.mainPanel2
    if not mainPanel2 then
        return
    end

    local iconBases = {"Image_01", "Image_04", "Image_02", "Image_05"}
    local preciousBases = {} self.preciousBases = preciousBases
    for i,v in ipairs(iconBases) do
        local curNode = mainPanel2:getChildByName(v)
        table_insert(preciousBases, curNode)
    end
end

-- 当换英雄时载入
local function findPInfo(id,preciousList)
    for i,v in ipairs(preciousList) do
        if v.id == id then
            return v
        end
    end
    local info = {id=id, order=0, lv=1, restExp=0}
    table_insert(preciousList, info)
    return info
end

local changeToSkinTag = 0 -- 0不是皮肤，1是皮肤
function HeroLayer:loadPreciousMainUi()
    self.curSelectedPreciousInfo = nil
    changeToSkinTag = 0

    local preciousBases = self.preciousBases
    if not preciousBases then
        return
    end

    -- 清理
    self:clrCurPrecious()
    for i,v in ipairs(preciousBases) do
        local child = v.child 
        if child then
            child:removeFromParent()
            v.child = nil
        end
    end

    --
    local curHeroTab = self.curHeroTab
    local preciousInfos = curHeroTab.preciousInfo
    if not preciousInfos then
        preciousInfos = {}
        curHeroTab.preciousInfo = preciousInfos
    end

    local id = curHeroTab.id
    local curHeroRes = gameUtil_getHeroTab(id)
    if not curHeroRes then
        return
    end
    local preciousIdList = curHeroRes.PreciousAssetIds
    local curFrameSize = nil
    local curPos = nil
    local curSize = nil
    local curCenter = nil
    local allPreciousUi = {} self.allPreciousUi = allPreciousUi
    local recordsInIndex = {} self.recordsPreciousInfoInIndex = recordsInIndex
    for i,v in ipairs(preciousIdList) do
        local curRes = PreciousResAll[v]
        if curRes then
            local index = preciousIndexToUi[curRes.PRICIOUS_ASSET_TYPE]
            local parent = preciousBases[index]
            local findedPInfo = findPInfo(i,preciousInfos)
            local node = gameUtil_createPreciousIcon(v, findedPInfo.lv, findedPInfo.order)
            if index and node and parent then
                
                --node.preciousInfo = findedPInfo

                if not curFrameSize then
                    curFrameSize = parent:getContentSize()
                    curPos = cc.p(curFrameSize.width*0.5, curFrameSize.height*0.5)
                end
                if not curSize then
                    curSize = node:getContentSize()
                    curCenter = cc.p(curSize.width*0.5, curSize.height*0.5)
                end
                node:setPosition(curPos)
                parent:addChild(node)
                parent.child = node
                local info = {res=curRes, center=curCenter, 
                    node = node, index = index, 
                    preciousInfo = findedPInfo, 
                    recordPreciousInfo = clone(findedPInfo),
                    heroId = id
                }
                node.info = info
                node.center=curCenter
                self:initPreciousTouch(node)
                table_insert(allPreciousUi, node)
                recordsInIndex[index] = info
            end
            
        end
    end

    self:selectOnPreciousEx()

    
    mm.GuildScene.GuildZhiBao01Btn = self.allPreciousUi[1]

    -- 必要的更新
    self:updatePreciousMainUiAll()
end

function HeroLayer:delayReqInfo(heroId)
    local id = heroId
    local curHeroRes = gameUtil_getHeroTab(id)
    if not curHeroRes then
        return
    end
    local preciousIdList = curHeroRes.PreciousAssetIds
    local function delayReq()
        for i,v in ipairs(preciousIdList) do
            mm_req("preciousLvUp",{heroId=self.curHeroId, preciousId = i, orderTag=2,itemId={}})
        end
    end

    delayExecute(self,0.1,delayReq)
end

function HeroLayer:updatePreciousMainUiAll()
    local allPreciousUi = self.allPreciousUi
    if not allPreciousUi then
        return
    end

    local heroId = self.curHeroId
    for i,v in ipairs(allPreciousUi) do
        local info = v.info
        self:updatePreciousMainUi(heroId, info.preciousInfo)
    end

    -- 皮肤红点按钮
    local curHeroTab = self.curHeroTab
    local skinInfo = curHeroTab.skinInfo
    local skinBtn = self.skinBtn
    local needRedPoint = false
    if skinInfo then
        local _collectList = skinInfo.collectList
        if hasOpenedNoUsedSkin(_collectList) then
            needRedPoint = true
        end
    end

    if needRedPoint then
        gameUtil.addRedPoint(skinBtn, 0.95, 0.95)
    else
        gameUtil.removeRedPoint(skinBtn)
    end
end

function HeroLayer:updatePreciousMainUi(heroIdIn, pInfoIn)
    local findedPInfo = pInfoIn

    local allPreciousUi = self.allPreciousUi
    local curHeroTab = self.curHeroTab
    local curHeroId = self.curHeroId
    if heroIdIn ~= curHeroId then
        return -- 不是同个英雄
    end

    -- 相同p id 的才更新：
    local countChanged = 0
    for i,v in ipairs(allPreciousUi) do
        local info = v.info
        local preciousInfo = info.preciousInfo
        local curHeroId = info.heroId
        
        if findedPInfo.id == preciousInfo.id then
            info.preciousInfo = findedPInfo
            local oldPreciousInfo = info.recordPreciousInfo
            local newLv = findedPInfo.lv
            local oldLv = oldPreciousInfo.lv
            if newLv ~= oldLv or findedPInfo.order ~= oldPreciousInfo.order then
                info.recordPreciousInfo = clone(findedPInfo)
                local pId = getPreciousId(curHeroId, findedPInfo.id)
                gameUtil_createPreciousIcon(pId, newLv, findedPInfo.order, v)
                
                -- 流光
                if v.effectNode then
                    v.effectNode:removeFromParent()
                end

                local n = gameUtil.createSkeAnmion( {name = "iconsc",scale = 0.7} )
                n:setAnimation(0, "stand", true)
                n:setPosition(v.center)
                v:addChild(n) v.effectNode = n

                countChanged = countChanged + 1

                -- 提示字
                local list,pName = gameUtil.getLvUpWords(oldPreciousInfo, findedPInfo, curHeroId)--to
                self:addPreciousLevelUpWords(list,pName)
            end

            -- 面板是否加进阶提示
            if canLiftOrder(findedPInfo) and self:isOrderItemEnough(findedPInfo) then
            --if true then
                gameUtil.addRedPoint(v, 0.95, 0.95)
            else
                gameUtil.removeRedPoint(v)
            end
        end
    end

    -- 是否显示升级效果
    local node = self.skeletonNode_0
    if countChanged > 0 and node then
        self:createLevelUpEffectTo(node.parent, node.pos)
    end
end

function HeroLayer:isOrderItemEnough(preciousInfoIn)
    local pId = getPreciousId(self.curHeroId, preciousInfoIn.id)--preciousInfoIn.id
    local order = preciousInfoIn.order
    local curPreciousRes = PreciousResAll[pId]
    if not curPreciousRes then
        return false
    end

    local orderUpTemplateId = curPreciousRes.orderUpTemplateId
    local m,c = PA:getOrderMatrials(order+1, orderUpTemplateId)
    if not m or not c then
        return false
    end

    local preciousMatrialInMap2 = preciousMatrialInMap2
    for i,v in ipairs(m) do
        local id = v
        local max = c[i]
        if max then
            local numOwned = 0
            local info = preciousMatrialInMap2[id]
            if info then
                numOwned = info.num
                if numOwned < max then -- 不够
                    return false
                end
            else
                return false -- 完全没有
            end
        end
    end

    return true
end

function HeroLayer:selectOnPreciousEx()
    local recordsPreciousInfoInIndex = self.recordsPreciousInfoInIndex -- UI
    if not recordsPreciousInfoInIndex then
        return
    end
    local fisrtInfo = nil
    local preIndex = selectRecord[self.curHeroId]
    if preIndex then 
        local info = recordsPreciousInfoInIndex[preIndex]
        if info then
            fisrtInfo = info
        end
    end
    if not fisrtInfo then
        for k,v in pairs(recordsPreciousInfoInIndex) do
            fisrtInfo = v
            break
        end
    end
    if fisrtInfo then
        self:selectOnPrecious(fisrtInfo, true)
    end
end

-- 触摸
function HeroLayer:preciousTouch(widget,touchkey)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end

    local info = widget.info

    local index = info.index

    if index == 1 then
        if mm.GuildId == 10504 then
            performWithDelay(self,function( ... )
                Guide:startGuildById(10505, mm.GuildScene.GuildZhiBaoSJBtn)
            end, 0.1)
        end
    end


    self:selectOnPrecious(info)
end
function HeroLayer:initPreciousTouch(node)
    node:setTouchEnabled(true)
    node:addTouchEventListener(handler(self, self.preciousTouch))
end

function HeroLayer:showPreciousSelectEffect(node, info)
    local allPreciousUi = self.allPreciousUi
    if allPreciousUi then
        for i,v in ipairs(allPreciousUi) do
            local cover = v.cover
            if cover then
                cover:removeFromParent()
                v.cover = nil
            end
        end
    end    

    createASelectCover(node, info.center)
end

-- 选择
function HeroLayer:clrCurPrecious()
    self.curPrecious = nil
end

local preciousShowMode = {
    ["preciousLevel"] = 1,
    ["preciousOrder"] = 2,
    ["skin"] = 3
}
local preciousShowModeInNum = {}
for k,v in pairs(preciousShowMode) do
    preciousShowModeInNum[v] = k
end

function HeroLayer:selectOnPrecious(info, isFromDefault)
    self.curPrecious = info

    local index = info.index
    local curHeroId = self.curHeroId
    if curHeroId then
        selectRecord[curHeroId] = index
    end

    -- 选中的效果
    self:showPreciousSelectEffect(info.node, info)

    -- 选中的preciousInfo
    local selectedPreciousInfo = info.preciousInfo
    self.curSelectedPreciousInfo = selectedPreciousInfo

    local needUpdateUi,mode = self:isNeedChangePreciousUIMode()
    if isFromDefault and mm.isPiFuCheckMode then
        needUpdateUi = true
        mode = preciousShowMode.skin
    end

    if needUpdateUi then
        self:initPreciousUIInMode(mode)
    end
    -- 更新下方面板
    self:updatePreciousBottomPanel(selectedPreciousInfo)
end

-- 初始化底部至宝UI:总的
function HeroLayer:initPreciousUI() -- 参考 initShengXingUI
    self.curPreciousMode = nil
    self:initPreciousUIInMode()
end

function HeroLayer:initPreciousUIInMode(forceMode)
    local curButtomLayer = self.curButtomLayer
    if curButtomLayer then
        curButtomLayer:removeFromParent()
        self.curButtomLayer = nil
    end

    -- 没有选中的至宝则不显示。
    local curPrecious = self.curPrecious
    if not curPrecious then
        return
    end

    self:doChangePreciousUIMode(forceMode)
end

function HeroLayer:isNeedChangePreciousUIMode()
    local curPreciousMode = self.curPreciousMode
    if not curPreciousMode then
        return false
    end

    local curSelectedPreciousInfo = self.curSelectedPreciousInfo
    if not curSelectedPreciousInfo then
        return false
    end

    local curMode = nil

    local info = getPreciousInfo(curSelectedPreciousInfo, self.curHeroId)
    if info.needOrder then
        curMode = preciousShowMode.preciousOrder
    else
        curMode = preciousShowMode.preciousLevel
    end
    if curPreciousMode == curMode then
        return false
    end
    return true, curMode
end

function HeroLayer:doChangePreciousUIMode(forceMode)
    local curSelectedPreciousInfo = self.curSelectedPreciousInfo
    if not curSelectedPreciousInfo then
        return
    end

    local curMode = preciousShowMode.preciousLevel
    if not forceMode and mm.isPiFuCheckMode then
        curMode = preciousShowMode.skin
        forceMode = curMode
    end

    if forceMode then
        curMode = forceMode
    else
        local info = getPreciousInfo(curSelectedPreciousInfo, self.curHeroId)
        if info.needOrder then
            curMode = preciousShowMode.preciousOrder
        end     
    end
    if not preciousShowModeInNum[curMode] then
        return
    end
    self.curPreciousMode = curMode

    local preciousShowUiMap = self.preciousShowUiMap
    local curInfo = preciousShowUiMap[curMode]

    if not curInfo then
        return
    end
    local func = curInfo.func
    if func then
        func()
    end
    -- 底部面板一个记录
    local curButtomLayer = self.curButtomLayer
    if curButtomLayer and curSelectedPreciousInfo then
        curButtomLayer.preciousInfo = curSelectedPreciousInfo
    end

    -- 更新下方面板
    self:updatePreciousBottomPanel(curSelectedPreciousInfo)
end

-- 升级面板
local color_green4 = cc.c4b(0, 255, 0, 255)
function HeroLayer:initPreciousLevelUpUI()
    local curButtomLayer = createBottomPanel("ZBSJ")
    if not curButtomLayer then
        return
    end
    curButtomLayer:setPosition(0, distanceToBottom)
    self:addChild(curButtomLayer)
    self.curButtomLayer = curButtomLayer
    -- 其他：--Button_shengji
    local shengjiBtn = curButtomLayer:getChildByName("Button_shengji")
    mm.GuildScene.GuildZhiBaoSJBtn = shengjiBtn
    if shengjiBtn then
        shengjiBtn:addTouchEventListener(handler(self, self.ZBSJBtnCB))
        gameUtil_setBtnEffect(shengjiBtn)
    end

    -- 材料选择
    local materialInfoList = {} curButtomLayer.materialInfoList = materialInfoList
    local materialSelectNameList = {"Node_ZB3", "Node_ZB4", "Node_ZB5"}
    for i,v in ipairs(materialSelectNameList) do
        local curIcon = gameUtil_createSelector()
        local baseNode = curButtomLayer:getChildByName(v)
        if baseNode and curIcon then
            baseNode:addChild(curIcon,1)
            local info = {node=curIcon}
            table_insert(materialInfoList, info)
            curIcon:addTouchEventListener(handler(self, self.selectItem1))
            curIcon:setTouchEnabled(true)
            --gameUtil_setSelectorVisible(curIcon, false)
        end
    end

    -- 经验值显示。
    local loading = curButtomLayer:getChildByName("Image_di") curButtomLayer.bar = loading
    if loading then
        local text = loading:getChildByName("Text_jingyan")
        curButtomLayer.expText = text

        local bar = loading:getChildByName("LoadingBar_jingyan")
        curButtomLayer.bar = bar

        local expAddText = loading:getChildByName("Text_jingyan_0")
        curButtomLayer.expAddText = expAddText
        expAddText:setTextColor(color_green4)
    end

    -- 属性加成 Text_zhanli1 Text_zhanli2
    local param1 = curButtomLayer:getChildByName("Text_zhanli1") curButtomLayer.param1 = param1
    local param2 = curButtomLayer:getChildByName("Text_zhanli2") curButtomLayer.param2 = param2

    -- 升级用的icon Node_ZB1
    local iconBase1 = curButtomLayer:getChildByName("Node_ZB1") curButtomLayer.iconBase1 = iconBase1
    local iconBase2 = curButtomLayer:getChildByName("Node_ZB2") curButtomLayer.iconBase2 = iconBase2

    -- 隐藏
    local jinbiImage = curButtomLayer:getChildByName("Image_jinbi")
    local jinbiText = curButtomLayer:getChildByName("Text_jinbi")
    if jinbiImage then
        jinbiImage:setVisible(false)
    end
    if jinbiText then
        jinbiText:setVisible(false)
    end
end

function HeroLayer:selectItem1(widget, touchkey)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end

    -- 展示小黄书
    --log("---------------------- 小黄书")
    -- 获取所需的经验：
    local needExp = 0
    local curSelectedPreciousInfo = self.curSelectedPreciousInfo
    if curSelectedPreciousInfo then
        local output = getPreciousInfo(curSelectedPreciousInfo, self.curHeroId)
        needExp = output.needExp
    end
    --
    self:createMatrialPanel(needExp)

end

function HeroLayer:ZBSJBtnCB(widget, touchkey)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end

    self:reqPrecious(0)
end

local tip1 = gameUtil.GetMoGameRetStr( 990300 )
local tip2 = gameUtil.GetMoGameRetStr( 990300 )
local listRecordOrderConsumeItems = {}
function HeroLayer:reqPrecious(tag)
    local curHeroId = self.curHeroId
    if not curHeroId then
        return
    end

    local curPrecious = self.curPrecious
    if not curPrecious then
        return
    end
    local CurPreciousInfo = curPrecious.preciousInfo
    local curPreciousIndex = CurPreciousInfo.id

    local preciousRes = curPrecious.res
    local preciousId = preciousRes.ID

    local itemId = {}
    if tag == 0 then
        if preLevelSets then
            local itemCount = 0 -- preLevelSetMax
            for i,v in ipairs(preLevelSets) do
                itemCount = itemCount + 1
                if itemCount > preLevelSetMax then
                    break
                end
                table_insert(itemId, v.id)
            end
        end

        if #itemId < 1 then
            gameUtil:addTishi({p = self, s = tip2}) 
        end
    elseif tag == 1 then
        if preOrderSets then
            -- 进阶条件：item检查
            local itemCount = 0 -- preLevelSetMax
            local itemInfoList = {}
            for i,v in ipairs(preOrderSets) do
                itemCount = itemCount + 1
                if itemCount > preOrderSetMax then
                    break
                end
                local max = v.max
                local num = v.num
                if num < max then
                    gameUtil:addTishi({p = self, s = tip1}) 
                    --log("-------------------- 装备不够")--string_format
                    return
                end

                table_insert(itemId, v.id)
                table_insert(itemInfoList, v)
            end

            -- 记录
            if itemCount >= preOrderSetMax then
                local inHero = listRecordOrderConsumeItems[curHeroId]
                if not inHero then
                    inHero = {}
                    listRecordOrderConsumeItems[curHeroId] = inHero
                end

                inHero[curPreciousIndex] = itemInfoList
            end
        end
    end

    --local preciousIdIndex = getPreciousId(self.curHeroId, index)
    local t = {heroId=curHeroId, preciousId = CurPreciousInfo.id, orderTag=tag,itemId=itemId}
    mm_req("preciousLvUp",{heroId=curHeroId, preciousId = CurPreciousInfo.id, orderTag=tag,itemId=itemId})
end

function HeroLayer:itemPreciousLevelConsume(listIn)
    local preciousMatrialInMap1 = preciousMatrialInMap1
    for i,v in ipairs(listIn) do
        local curItemInfo = preciousMatrialInMap1[v]
        if curItemInfo and curItemInfo.num then
            curItemInfo.num = curItemInfo.num - 1
        end
    end
end

-- 至宝进阶物品扣除
function HeroLayer:itemPreciousOrderConsume(heroId, pId)
    local inHero = listRecordOrderConsumeItems[heroId]
    if inHero then
        local inP = inHero[pId]
        if inP then
            local preciousMatrialInMap2 = preciousMatrialInMap2
            for i,v in ipairs(inP) do
                local curItemInfo = preciousMatrialInMap2[v.id]
                if curItemInfo and curItemInfo.num then
                    curItemInfo.num = curItemInfo.num - v.max
                end
            end
        end
    end

    -- 更新红点英雄头像红点
    self:updateRedPointsForPrecious()
end

function HeroLayer:refreshBagItems()
    mm.req("getItem",{getType=1})
end

local strFullLevel = gameUtil.GetMoGameRetStr(990311)
local coutRecheckBag = 0
local canLiftOrder = PA:getCanLiftOrder()
function HeroLayer:handlePreciousMsg(t)
    if not t then
        log("ERROR: handlePreciousMsg t==nil!")
    end

    local result = t.result
    if result == nil then
        log("ERROR: result == nil")
        return
    end

    if result == 0 then
        log("-------------------- 0 升级成功")
    elseif result == 1 then
        log("-------------------- 1 进阶成功")
    elseif result == 2 then
        log("-------------------- 2 请求信息") 
    elseif result == 11 then  
        gameUtil:addTishi({p = self, s = strFullLevel})
    elseif result == 20 then  
        log("----------------------- 20 请检查背包")
        coutRecheckBag = coutRecheckBag + 1
        if coutRecheckBag > 1 then
            self:refreshBagItems()
            coutRecheckBag = 0
        end
    end

    local heroId = t.heroId
    if heroId then
        local _preciousInfo = t.preciousInfo
        local tFinal = _preciousInfo
        if _preciousInfo then
            local _id = _preciousInfo.id
            local curHeroInfo = self.curHeroTab
            if not curHeroInfo or curHeroInfo.id ~= heroId then
                curHeroInfo = getHeroInfo(heroId)
            end
            if curHeroInfo then
                -- 没有则插入，有则替换
                local preciousInfos = curHeroInfo.preciousInfo
                if preciousInfos == nil then
                    preciousInfos = {}
                    curHeroInfo.preciousInfo = preciousInfos
                end

                local findedPInfo = nil
                for i,v in ipairs(preciousInfos) do
                    if _id == v.id then
                        findedPInfo = v
                        break
                    end
                end
                if findedPInfo then
                    simpleClone(findedPInfo, _preciousInfo)
                    tFinal = findedPInfo
                else
                    table_insert(preciousInfos, _preciousInfo)
                    tFinal = _preciousInfo
                end
            end

            -- 主面板更新：
            self:updatePreciousMainUi(heroId, tFinal)

            --dump(tFinal, "=========================================")
            -- page / 检查消息是否对应的当前的英雄和至宝
            -- log("------------------ heroId == "..heroId)
            -- log("------------------ _id == ".._id)
            if true and self:checkShouldChangeBottomPanelUi(heroId, _id) then -- 是否是至宝Mode
                local needUpdateUi,mode = self:isNeedChangePreciousUIMode()
                if needUpdateUi then
                    --log("------------------ needUpdateUi ---------")
                    self:initPreciousUIInMode(mode)
                else
                    --log("---------------2")
                    self:updatePreciousBottomPanel(tFinal)
                end
                --log("------------------ heroId == "..heroId)             
            end

            -- 进阶成功道具消耗
            if result == 1 then
                self:itemPreciousOrderConsume(heroId, _id)
            end

            -- 更新红点:英雄头像红点
            
            if _preciousInfo.lv >= canLiftOrder then
                self:updateRedPointsForPrecious()
            end
        end
    end

    local itemsConsumed = t.itemId
    if itemsConsumed then
        self:itemPreciousLevelConsume(itemsConsumed)
        self:levelMatrialPreSet()
    end
end

local preciousShowMode_skin = preciousShowMode.skin 
function HeroLayer:checkShouldChangeBottomPanelUi(heroId, preciousId)
    -- 当前主page是至宝的
    local PreciousPanel = self.PreciousPanel
    if PreciousPanel and not PreciousPanel:isVisible() then
        return false
    end

    -- 过滤皮肤界面
    local curMode = self.curPreciousMode
    if curMode and preciousShowMode_skin == curMode then
        return
    end

    local curHeroId = self.curHeroId
    if heroId ~= curHeroId then
        --log("------------------x self.curHeroId == "..self.curHeroId)
        return false
    end
    local curButtomLayer = self.curButtomLayer
    if curButtomLayer then
        local preciousInfo = curButtomLayer.preciousInfo
        if preciousInfo then
            if preciousInfo.id == preciousId then
                return true
            else
                --log("------------------x preciousInfo.id == "..preciousInfo.id)
            end
        end
    end
    return false
end

-- 进阶面板
function HeroLayer:initPreciousOrderUpUI()
    local curButtomLayer = createBottomPanel("ZBJX")
    if not curButtomLayer then
        return
    end
    curButtomLayer:setPosition(0, distanceToBottom)
    self:addChild(curButtomLayer)
    self.curButtomLayer = curButtomLayer
    -- 其他：--Button_shengji
    local shengjiBtn = curButtomLayer:getChildByName("Button_shengji")
    if shengjiBtn then
        shengjiBtn:addTouchEventListener(handler(self, self.ZBJSBtnCB))
        gameUtil_setBtnEffect(shengjiBtn)
    end
    mm.GuildScene.PreciousShengjiBtn = shengjiBtn

    if mm.GuildId == 10505 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10506, mm.GuildScene.PreciousShengjiBtn)
        end, 0.1)
    end

    -- 材料选择--只能自动选择
    local materialInfoList = {} curButtomLayer.materialInfoList = materialInfoList
    local materialSelectNameList = {"Node_ZB4", "Node_ZB5"}
    for i,v in ipairs(materialSelectNameList) do
        local curIcon = gameUtil_createSelector()
        local baseNode = curButtomLayer:getChildByName(v)
        if baseNode and curIcon then
            baseNode:addChild(curIcon,1)
            local info = {node=curIcon}
            table_insert(materialInfoList, info)
        end
    end

    -- 属性加成 Text_zhanli1 Text_zhanli2
    local param1 = curButtomLayer:getChildByName("Text_zhanli1") curButtomLayer.param1 = param1
    local param2 = curButtomLayer:getChildByName("Text_zhanli2") curButtomLayer.param2 = param2

    -- 升级用的icon Node_ZB1
    local iconBase1 = curButtomLayer:getChildByName("Node_ZB1") curButtomLayer.iconBase1 = iconBase1
    local iconBase2 = curButtomLayer:getChildByName("Node_ZB2") curButtomLayer.iconBase2 = iconBase2

    -- 隐藏
    local jinbiImage = curButtomLayer:getChildByName("Image_jinbi")
    local jinbiText = curButtomLayer:getChildByName("Text_jinbi")
    if jinbiImage then
        jinbiImage:setVisible(false)
    end
    if jinbiText then
        jinbiText:setVisible(false)
    end    
end
function HeroLayer:ZBJSBtnCB(widget, touchkey)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end

    self:reqPrecious(1)

    if mm.GuildId == 10506 then
        Guide:GuildEnd()
    end
end
-- 消息回复时，更新下方的面板：
function HeroLayer:updatePreciousBottomPanel(info)
    local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    --else
        --return
    end

    local preciousPanelUpdateMag = self.preciousPanelUpdateMag
    local name = curButtomLayer.BPName
    local func = preciousPanelUpdateMag[name]
    if func then
        func(info)
    end
end
-- 升级：icon 战力 等级 
function HeroLayer:updatePreciousBottomPanelLv(...)
    local preciousInfoIn = ...
    local curButtomLayer = self.curButtomLayer
    -- if not curButtomLayer then
    --     return
    -- end
    local materialInfoList = curButtomLayer.materialInfoList
    if not materialInfoList then
        return
    end
    -- 预选：
    self:levelMatrialPreSet()

    -- 等级信息：
    local curPreciousInfo = preciousInfoIn
    local heroId = self.curHeroId
    self:updatePBPanelLevelInfo(heroId, curPreciousInfo)
end

local paramNames = {
    eq_gongji = gameUtil.GetMoGameRetStr(990301),
    eq_shenming = gameUtil.GetMoGameRetStr(990302),
    eq_sudu = gameUtil.GetMoGameRetStr(990303),
    eq_duosan = gameUtil.GetMoGameRetStr(990304),
    eq_crit = gameUtil.GetMoGameRetStr(990305),
    eq_hujia = gameUtil.GetMoGameRetStr(990306),
    eq_mokang = gameUtil.GetMoGameRetStr(990307),
}
local strAdd = gameUtil.GetMoGameRetStr(990308)
local checkParamList = {
    {name="eq_gongji",name1=1,func = gameUtil.heroMBAck}, 
    {name="eq_shenming",name1=2,func = gameUtil.hpMBAck},
    {name="eq_sudu",name1=3,func = gameUtil.speedMBAck},
    {name="eq_duosan",name1=4,func = gameUtil.dodgeMBAck},
    {name="eq_crit",name1=5,func = gameUtil.critMBAck},
    {name="eq_hujia",name1=6,func = gameUtil.wufangMBAck},
    {name="eq_mokang",name1=7,func = gameUtil.mofangMBAck},
}

function getFirstParamWithValue(res)
    local curparam = nil
    for i,v in ipairs(checkParamList) do
        local value = res[v.name]
        if value and value > 0 then
            curparam = v
            curparam.value = value
            break
        end
    end
    return curparam
end
function getFirstParamWithValue2(t)
    for i,v in ipairs(checkParamList) do
        v.value = nil
        v.nextValue = nil
    end
    local curparam = nil
    for i,v in ipairs(checkParamList) do
        local value = t[v.name]
        local nextValue = t[v.name.."next"]
        if value and value > 0 then
            curparam = v
            curparam.value = value
            curparam.nextValue = nextValue
            break
        end
    end
    return curparam
end

local math_floor = math.floor
function HeroLayer:updatePBPanelLevelInfo(heroId, preciousInfoIn)
    if not preciousInfoIn then
        return
    end
    local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    end
    local name = curButtomLayer.BPName
    if "ZBSJ" ~= name then
        return
    end
    -- hero id 检查
    local heroIdUI = self.curHeroId
    local curHeroTab = self.curHeroTab
    if heroIdUI ~= heroId then
        return
    end
    -- 至宝 id检查
    --log("--------------r1 ")
    local _preciousInfo = self.curSelectedPreciousInfo
    if _preciousInfo then
        curButtomLayer.preciousInfo = _preciousInfo
    end

    -- icon
    self:updateBottomLayerIcons(curButtomLayer, _preciousInfo)

    -- 攻击力等属性
    self:updateBottomLayerAttack(curButtomLayer, preciousInfoIn, curHeroTab)

    -- UI更新： 
    local output = getPreciousInfo(preciousInfoIn, self.curHeroId)

    local expText = curButtomLayer.expText
    if expText then
        local str = output.str
        expText:setString(str)
    end

    local bar = curButtomLayer.bar
    if bar then
        local per = output.per
        bar:setPercent(per)
    end

    local expAddText = curButtomLayer.expAddText
    if expAddText then
        local num = self:getPreSetExpAdd()
        if num == 0 then
            expAddText:setVisible(false)
        else
            expAddText:setVisible(true)
        end
        local str = "  +"..num
        expAddText:setString(str)
    end
end

function HeroLayer:updateBottomLayerIcons(curButtomLayer, _preciousInfo)
    -- icon
    local iconBase1 = curButtomLayer.iconBase1
    if iconBase1 then
        local child = iconBase1.child
        local recordPreciousInfo = nil
        if child then
            recordPreciousInfo = child.recordPreciousInfo
            child:removeFromParent()
            iconBase1.child = nil
        end

        child = gameUtil_createPreciousIcon(getPreciousId(self.curHeroId, _preciousInfo.id), _preciousInfo.lv, _preciousInfo.order)
        local curSize = child:getContentSize()
        iconBase1:addChild(child)
        iconBase1.child = child

        -- 
        if recordPreciousInfo then
            if recordPreciousInfo.id == _preciousInfo.id 
                and (recordPreciousInfo.lv ~= _preciousInfo.lv
                or recordPreciousInfo.order ~= _preciousInfo.order) then
                
                if child.effectNode then
                    child.effectNode:removeFromParent()
                end
                local n = gameUtil.createSkeAnmion( {name = "iconsc",scale = 0.7} )
                n:setAnimation(0, "stand", true)
                n:setPosition(curSize.width*0.5, curSize.height*0.5)
                child:addChild(n) child.effectNode = n
            end
        end
        child.recordPreciousInfo = clone(_preciousInfo)
    end

    -- icon
    local iconBase2 = curButtomLayer.iconBase2
    if iconBase2 then
        local child = iconBase2.child
        if child then
            child:removeFromParent()
            iconBase2.child = nil
        end
        local fakeInfo = PA:liftUpPreciousInfo(_preciousInfo)
        if not fakeInfo.isFullLevel then
            child = gameUtil_createPreciousIcon(getPreciousId(self.curHeroId, fakeInfo.id), fakeInfo.lv, fakeInfo.order)
            iconBase2:addChild(child)
            iconBase2.child = child
        end
    end
end

function HeroLayer:updateBottomLayerAttack(curButtomLayer, _preciousInfoIn, curHeroTabIn)
    -- 检查什么属性加成了
    if not _preciousInfoIn then
        return
    end

    local param1 = curButtomLayer.param1
    local param2 = curButtomLayer.param2
    
    local paramWithLevel = gameUtil.getPreciousAdd(_preciousInfoIn, self.curHeroId)
    if not paramWithLevel then
        return
    end

    local t = getFirstParamWithValue2(paramWithLevel)
    if not t then
        if param1 then
            param1:setString("")
        end
        if param2 then
            param2:setString("")
        end
        return
    end

    -- 攻击力等修改1  
    local ackNum = (t.value)
    local nextValue = t.nextValue
    if not nextValue then
        nextValue = 0
    else
        nextValue = (nextValue)
    end

    if param1 and t then
        param1:setString(paramNames[t.name].."："..ackNum)
    end

    -- 攻击力等修改2 
    if param2 and t then
        param2:setString(paramNames[t.name].."："..(ackNum+nextValue))
    end
end

function HeroLayer:updatePreciousBottomPanelOrder(...)
    local preciousInfoIn = ...
    local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    end

    local materialInfoList = curButtomLayer.materialInfoList
    if not materialInfoList then
        return
    end

    -- 预选：
    self:orderMatrialPreSet(preciousInfoIn)

    -- 等级信息：
    local curPreciousInfo = preciousInfoIn
    local heroId = self.curHeroId
    self:updatePBPanelOrderInfo(heroId, curPreciousInfo)
end

function HeroLayer:updatePBPanelOrderInfo(heroId, preciousInfoIn)
    if not preciousInfoIn then
        return
    end
    local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    end
    local name = curButtomLayer.BPName
    if "ZBJX" ~= name then
        return
    end
    -- hero id 检查
    local heroIdUI = self.curHeroId
    local curHeroTab = self.curHeroTab
    if heroIdUI ~= heroId then
        return
    end
    -- 至宝 id检查
    local _preciousInfo = self.curSelectedPreciousInfo
    if _preciousInfo then
        curButtomLayer.preciousInfo = preciousInfoIn
    end

    -- icon
    self:updateBottomLayerIcons(curButtomLayer, _preciousInfo)

    -- 攻击力等属性
    self:updateBottomLayerAttack(curButtomLayer, preciousInfoIn, curHeroTab)


    --
end

-- 材料选择面板 
local expInfo2 = gameUtil.GetMoGameRetStr(990310)
local matrialPanelSrc = "res/HeroZBtankuang.csb"
function HeroLayer:createMatrialPanel(needExp)
    local curMatrialPanel = self.curMatrialPanel
    if curMatrialPanel then
        return
    end

    local node = createCSNode(matrialPanelSrc)
    if not node then
        return
    end

    local base2 = node:getChildByName("Image_bg")

    -- 按钮
    if base2 then
        local backBtn = base2:getChildByName("Button_back")
        if backBtn then
            gameUtil_setBtnEffect(backBtn)
            backBtn:addTouchEventListener(handler(self, self.closeMatrialPanel))
        end

        local okBtn = base2:getChildByName("Button_1")
        if okBtn then
            gameUtil_setBtnEffect(okBtn)
            okBtn:addTouchEventListener(handler(self, self.closeMatrialPanel))
        end

        --Image_listView
        local listView1 = base2:getChildByName("Image_listView")
        if listView1 then
            local listView2 = listView1:getChildByName("ListView_1")
            if listView2 then
                node.listView = listView2
                listView2.width = listView2:getContentSize().width
            end
        end

        -- Text_Num1_0 Text_Num1_0
        local expShowText1 = base2:getChildByName("Text_Num1") 
        node.expShowText1 = expShowText1

        local expShowText2 = base2:getChildByName("Text_Num1_0") 
        if expShowText2 then
            expShowText2:setString(expInfo2..needExp)
        end
    end
    -- 
    node:setContentSize(winSize)
    ccui_Helper:doLayout(node)

    self.curMatrialPanel = node
    self:addChild(node, 100)

    self:updateMatrialPanel()
end

-- 更新小黄书预览面板中的小黄书
local hNum = 3
local math = math
local math_mod = math.mod
local clone = clone
function HeroLayer:updateMatrialPanel()
    local curMatrialPanel = self.curMatrialPanel
    if not curMatrialPanel then
        return
    end
    local listView = curMatrialPanel.listView
    if not listView then
        return
    end
    listView:setItemModel(ccui_Layout:create())

    local preciousMatrial = preciousMatrial1
    if not preciousMatrial then
        return
    end

    local countAll = 0
    local showMax = 10

    -- 记录选中个数。
    self.preSelectedCount = 0
    local _preLevelSetsMap = {}
    local preLevelSetsMap = self.preLevelSetsMap
    if preLevelSetsMap then
        _preLevelSetsMap = clone(preLevelSetsMap)
        -- for k,v in pairs(_preLevelSetsMap) do
        -- end
    end
    self.selectdeInfoRecord = {}

    --
    local width = listView.width local frameSize = cc.size(width, 200)
    local frameHeight = nil local averW = width / hNum
    local xStart = averW/2 local frame = nil local countH = 0 
    local countItem = 0 local countALL = 0 local iconSize = nil
    for i,v in ipairs(preciousMatrial) do
        local numDetail = v.num
        local curId = v.id
        if numDetail > showMax then
            numDetail = showMax
        end
        for j = 1, numDetail do
            local curNode = createItemIcon(curId, 1)
            if countH >= hNum then
                countH = math_mod(countH, hNum)
            end

            if curNode then
                if not frameHeight then
                    local s = curNode:getContentSize()
                    frameHeight = s.height --* 1.00
                    frameSize.height = frameHeight
                end

                if countH == 0 then -- 横条
                    xStart = 0
                    listView:pushBackDefaultItem()
                    frame = listView:getItem(countItem)
                    --listView:pushBackCustomItem(frame)
                    frame:setContentSize(frameSize)
                    countItem = countItem + 1
                end
                countH = countH + 1
                countALL = countALL + 1
                --local itemSize = curNode:getContentSize()            
                frame:addChild(curNode)
                frame:setAnchorPoint(0,0.5)
                curNode:setPositionX(xStart)
                xStart = xStart + averW

                -- bg
                local bg = curNode.bg
                if bg then
                    bg:setTouchEnabled(true)
                    bg:addTouchEventListener(handler(self, self.matrialPanelIconCB))
                    bg.listView = listView
                end

                local icon = curNode.icon
                if icon then
                    icon.info = {id = curId, node = icon, index=countH, tag=countALL}

                    if not iconSize then
                        local s = icon:getContentSize()
                        iconSize = cc.p(s.width*0.5, s.height*0.5)
                    end
                    icon.center = iconSize

                    -- 选中 _preLevelSetsMap
                    local _info = _preLevelSetsMap[curId]
                    if _info then
                        local _num = _info.num
                        if _num > 0 then
                            _info.num = _num - 1
                            self:selectOnPreciousMatrial(icon)
                        end
                    end

                    if bg then
                        bg.icon = icon
                    end
                end
            end
        end
    end

    self:updateMatrialPanelExp()
end

--
local expInfo1 = gameUtil.GetMoGameRetStr(990309)
function HeroLayer:updateMatrialPanelExp()
    local curMatrialPanel = self.curMatrialPanel
    if not curMatrialPanel then
        return
    end

    local expAll = 0
    local selectdeInfoRecord = self.selectdeInfoRecord
    for k,v in pairs(selectdeInfoRecord) do
        local info = v
        local id = info.id
        local curRes = itemResAll[id]
        if curRes and info.selected then
            expAll = expAll + curRes.itemNum
        end
    end

    local expShowText1 = curMatrialPanel.expShowText1 
    if expShowText1 then
        expShowText1:setString(expInfo1..expAll)
    end
end

--小黄书预选
function HeroLayer:levelMatrialPreSet(preSetIn)
    if preSetIn then
        preLevelSets = preSetIn
    else
        -- 从默认的数据中取 -- preciousMatrial1
        -- 规则取前3个（已经排序）
        local count = 0
        preLevelSets = {}
        local preLevelSets = preLevelSets
        for i,v in ipairs(preciousMatrial1) do
            local id = v.id
            local num = v.num
            for j = 1, num do
                count = count + 1
                if count <= preLevelSetMax then
                    local preSetInfo = preLevelSets[count]
                    if not preSetInfo then
                        preSetInfo = {} preLevelSets[count] = preSetInfo
                    end
                    preSetInfo.id = id
                end                
            end

            if count > preLevelSetMax then
                break
            end
        end
    end

    -- 建立map好查找
    local preLevelSetsMap = {} self.preLevelSetsMap = preLevelSetsMap
    for i,v in ipairs(preLevelSets) do
        local id = v.id
        local info = preLevelSetsMap[id]
        if not info then
            info = {id=id,num=1}
            preLevelSetsMap[id] = info
        else
            info.num = info.num + 1
        end     
    end

    -- 更新UI
    self:levelMatrialPreSetUIUpdate()
end

function HeroLayer:getPreSetExpAdd()
    local add = 0
    local preLevelSets = preLevelSets
    if not preLevelSets then
        return add
    end
    local itemResAll = itemResAll
    for i = 1,preLevelSetMax do
        local setInfo = preLevelSets[i]
        if setInfo then
            local id = setInfo.id
            local curRes = itemResAll[id]
            if curRes then
                add = add + curRes.itemNum
            end
        end
    end

    return add
end

function HeroLayer:levelMatrialPreSetUIUpdate()
    local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    end

    local name = curButtomLayer.BPName
    if "ZBSJ" ~= name then
        return
    end

    local materialInfoList = curButtomLayer.materialInfoList
    if not materialInfoList then
        return
    end
    --preLevelSets preLevelSetMax
    for i = 1,preLevelSetMax do
        local nodeInfo = materialInfoList[i]
        local setInfo = preLevelSets[i]

        if nodeInfo then
            local node = nodeInfo.node
            if node then
                local iconNode = node.iconNode
                if iconNode then
                    iconNode:removeFromParent()
                    node.iconNode = nil
                end
                if setInfo then         
                    local id = setInfo.id
                    local curIconNode = createItemIcon2(id, 1)
                    if curIconNode then
                        node:addChild(curIconNode, 1000)
                        node.iconNode = curIconNode
                    end
                end
            end
        end
    end

    local expAddText = curButtomLayer.expAddText
    if expAddText then
        local str = "  +"..self:getPreSetExpAdd()
        expAddText:setString(str)
    end

end

-- 至宝进阶预选 -- 只能从表格和背包信里直接取值：
function HeroLayer:orderMatrialPreSet(preciousInfoIn)
    -- 从表格里取信息
    if not preciousInfoIn then
        return
    end
    local pId = getPreciousId(self.curHeroId, preciousInfoIn.id) --preciousInfoIn.id
    local order = preciousInfoIn.order
    local curPreciousRes = PreciousResAll[pId]
    if not curPreciousRes then
        return
    end
    local orderUpTemplateId = curPreciousRes.orderUpTemplateId
    local m,c = PA:getOrderMatrials(order+1, orderUpTemplateId)
    if not m or not c then
        return
    end 

    preOrderSets = {}
    local preOrderSets = preOrderSets
    for i,v in ipairs(m) do
        local id = v
        local max = c[i]
        if max then
            local numOwned = 0
            local info = preciousMatrialInMap2[id]
            if info then
                numOwned = info.num
            end
            table_insert(preOrderSets, {id=id, num=numOwned, max=max})
        end
    end

    -- 更新UI
    --log("-------------#preOrderSets == "..#preOrderSets)
    self:orderMatrialPreSetUIUpdate(preOrderSets) 
end

local cGray = cc.c3b(0, 0, 0)
function HeroLayer:orderMatrialPreSetUIUpdate(preOrderSetsIn)
   local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    end

    local name = curButtomLayer.BPName
    if "ZBJX" ~= name then
        return
    end

    local materialInfoList = curButtomLayer.materialInfoList
    if not materialInfoList then
        return
    end
    
    local preOrderSets = preOrderSetsIn
    for i = 1,preOrderSetMax do
        local nodeInfo = materialInfoList[i]
        local setInfo = preOrderSets[i]

        if nodeInfo then
            local node = nodeInfo.node
            if node then
                local iconNode = node.iconNode
                if iconNode then
                    iconNode:removeFromParent()
                    node.iconNode = nil
                end
                if setInfo then         
                    local id = setInfo.id
                    local max = setInfo.max
                    local num = setInfo.num
                    --log("=------- max == "..max)
                    --log("=------- num == "..num)
                    --if num >= max then
                        local numSafe = num
                        -- if num > max then
                        --     numSafe = max
                        -- end
                        local curIconNode = createItemIcon2(id, numSafe, max)
                        if curIconNode then
                            node:addChild(curIconNode, 1000)
                            node.iconNode = curIconNode
                            node:setTouchEnabled(true)
                            node:addTouchEventListener(handler(self,self.orderMatrialIconCB))
                            local info = {id=id}
                            node.info = info
                        end
                    --end
                end
            end
        end
    end
end

function HeroLayer:orderMatrialIconCB(widget, touchkey)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end

    local info = widget.info
    self:orderMatrialOkLayer(info)
end

local jumpLayer = require("src.app.views.layer.itemInfoAndJump")
function HeroLayer:orderMatrialOkLayer(info)
    local okLayer = jumpLayer.new({app = self.app, itemInfo=info})

    --, itemInfo = {id=0}
    if not okLayer then
        return
    end

    self.curOrderMatrialOkLayer = okLayer
    self:addChild(okLayer, 1000)
    okLayer:setContentSize(winSize)
    ccui_Helper:doLayout(okLayer)
end

-- 选中小黄书
local math_abs = math.abs
function HeroLayer:matrialPanelIconCB(widget, touchkey)
    if touchkey == ccui_TouchEventType_began then
        local listView = widget.listView
        if listView then
            local pos = listView:getInnerContainerPosition()
            widget.pY = pos.y
        end
    elseif touchkey == ccui_TouchEventType_ended then
        local listView = widget.listView
        if listView then
            local pos = listView:getInnerContainerPosition()
            local deltaY = math_abs(widget.pY - pos.y)
            if deltaY > 25 then
                return
            end
        end

        local node = widget.icon
        if node then
            self:selectOnPreciousMatrial(node)
        end

        -- 计算面板值：
        self:updateMatrialPanelExp()
    end

end

-- touch 
function HeroLayer:selectOnPreciousMatrial(widget)
    local info = widget.info
    if not info then
        return
    end

    local preSelectedCount = self.preSelectedCount
    if info.selected then
        local node = info.node
        if node then
            local cover = node.cover 
            if cover then
                info.selected = false
                preSelectedCount = preSelectedCount - 1
                cover:removeFromParent()
            end
        end
    else
        if preSelectedCount >= preLevelSetMax then
            return
        end

        info.selected = true
        createASelectCover(widget, widget.center, 2)
        preSelectedCount = preSelectedCount + 1
        
        -- 选过的都记录下
        local selectdeInfoRecord = self.selectdeInfoRecord
        selectdeInfoRecord[info.tag] = info
    end
    self.preSelectedCount = preSelectedCount
end

--
function HeroLayer:closeMatrialPanel(widget, touchkey)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end

    local curMatrialPanel = self.curMatrialPanel
    if curMatrialPanel then
        -- 选中过的检查一次,返回选中的值
        local _preLevelSetsEx = {} -- preLevelSetMax
        local count = 0
        local selectdeInfoRecord = self.selectdeInfoRecord
        for k,v in pairs(selectdeInfoRecord) do
            local info = v
            if info.selected and count < preLevelSetMax then
                count = count + 1
                _preLevelSetsEx[count] = {id=info.id}
            end
        end

        -- 更新面板
        self:levelMatrialPreSet(_preLevelSetsEx)

        -- 清理
        curMatrialPanel:removeFromParent()
        self.curMatrialPanel = nil
    end

    self.curMatrialSelectInfo = nil
end

-- 皮肤
function HeroLayer:initPreciousSkinUI()
    self.curSelectedSkinInfo = nil

    local curButtomLayer = createBottomPanel("ZBPF")
    if not curButtomLayer then
        return
    end
    curButtomLayer:setPosition(5, distanceToBottom)
    self:addChild(curButtomLayer)
    self.curButtomLayer = curButtomLayer
    -- 
    local bg1 = curButtomLayer:getChildByName("Image_shang")
    if not bg1 then
        return
    end

    local listView = bg1:getChildByName("ListView_Hero")
    curButtomLayer.listView =listView
    if not listView then
        return
    end

    -- 其他子控件 Text_zhanli2
    local nameText = curButtomLayer:getChildByName("Text_zhanli2")
    curButtomLayer.nameText = nameText
    local zhanliText = curButtomLayer:getChildByName("Text_zhanli2_0")
    curButtomLayer.zhanliText = zhanliText
    local infoText = curButtomLayer:getChildByName("Text_jinbi_0")
    curButtomLayer.infoText = infoText

    -- 从herotable 获取皮肤信息：
    local curHeroTab = self.curHeroTab
    local curSkinInfo = curHeroTab.skinInfo
    if not curSkinInfo then
        curSkinInfo = {}
        curHeroTab.skinInfo = curSkinInfo
    end
    mm_req("skinOn",{heroId=self.curHeroId, skinId = 1, tag=0})

    curButtomLayer.heroId = curHeroTab.id
    local collectList = curSkinInfo.collectList
    if not collectList then
        collectList = {} curSkinInfo.collectList=collectList
    end

    --初始化4个固定的skin
    local curHeroId = self.curHeroId
    local curHeroRes = gameUtil_getHeroTab(curHeroId)
    if not curHeroRes then
        return
    end
    local skinUiList = {} curButtomLayer.skinUiList = skinUiList
    local curSkinIdList = curHeroRes.SkinId
    local firstInfo = nil
    local fisrtSize = nil

    -- 数据造假
    local defalutSKinId = 1
    if not curSkinInfo.id then
        curSkinInfo.id = defalutSKinId
    else
        defalutSKinId = curSkinInfo.id
    end

    local function getSkinCollectInfo(index, list)
        for i,v in ipairs(list) do
            if v.id == index then
                return v
            end
        end

        local info = {id=index, flag=0}
        table_insert(list, info)
        return info
    end

    -- UI
    for i,v in ipairs(curSkinIdList) do
        local id = v
        local curSkinRes = skinResAll[id]
        if curSkinRes then
            local node = createSkinIcon(id)
            if node then
                local collectInfo = getSkinCollectInfo(i, collectList)

                listView:pushBackCustomItem(node)
                table_insert(skinUiList, node)
                local info = {id=i,node=node,collectInfo=collectInfo}
                node.info = info

                node:setTouchEnabled(true)
                node:addTouchEventListener(handler(self, self.clickSkinBtnCB))

                if not firstInfo and i == defalutSKinId then
                    firstInfo = info
                end
                if not fisrtSize then
                    local iconSize = node:getContentSize()
                    node.center = cc.p(iconSize.width*0.5, iconSize.height*0.5)
                end


                if collectInfo.flag == 0 and i ~= defalutSKinId then
                    --node:setColor(skinColloctColor[2])
                    setSkinOpenShow(node, false)
                end
            end
        end
    end

    -- 
    if firstInfo then
        self:selectSkin(firstInfo)
    end
end

function HeroLayer:selectSkin(infoIn)
    local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    end

    local skinUiList = curButtomLayer.skinUiList
    if not skinUiList then
        return
    end

    for i,v in ipairs(skinUiList) do
        local node = v
        local cover = node.cover
        if cover then
            cover:removeFromParent()
            node.cover = nil
        end
    end

    local node = infoIn.node
    createASelectCover(node, node.center)

    -- 记录下
    self.curSelectedSkinInfo = infoIn

    -- 皮肤
    self:updateSkinInfo(infoIn)
end

function HeroLayer:updateSkinInfo(infoIn)
    local curButtomLayer = self.curButtomLayer
    local id = getSkinId(self.curHeroId, infoIn.id)--infoIn.id
    local curSkinRes = skinResAll[id]
    if not curSkinRes then
        return
    end

    local nameText = curButtomLayer.nameText
    local zhanliText = curButtomLayer.zhanliText
    local infoText = curButtomLayer.infoText

    if nameText then
        nameText:setString(curSkinRes.Name)
    end
    if zhanliText then
        -- 判定下是什么属性加成了。
        local curparam = getFirstParamWithValue(curSkinRes)
        if curparam then
            zhanliText:setString(strAdd..paramNames[curparam.name]..curparam.value)
        else
            zhanliText:setString("...")
        end      
    end

    if infoText then
        infoText:setString(curSkinRes.SkinNote)
    end
end

function HeroLayer:updatePreciousBottomPanelSkin(heroTabIn)
    local curButtomLayer = self.curButtomLayer
    if not curButtomLayer then
        return
    end
    local curHeroTab = heroTabIn
    local curHeroId = curHeroTab.id
    local curSkinInfo = curHeroTab.skinInfo
    if not curSkinInfo then
        return
    end
    local layerHeroId = curButtomLayer.heroId
    if layerHeroId then
        if layerHeroId ~= curHeroId then
            return
        end
    end
    local skinUiList = curButtomLayer.skinUiList
    if not skinUiList then
        return
    end
    local curSkinId = curSkinInfo.id
    if not curSkinId then
        return
    end
    local theMap = {}
    if curSkinInfo.collectList then
        theMap = toMap(curSkinInfo.collectList)
    end

    local selectInfo = nil--skinUiList[1].info
    for i,v in ipairs(skinUiList) do
        local info = v.info
        local id = info.id
        local newSkinCollectInfo = theMap[id]
        if newSkinCollectInfo then
            info.collectInfo = newSkinCollectInfo
            setSkinOpenShow(v, newSkinCollectInfo.flag > 0 or i == 1, newSkinCollectInfo.flag > 1 and i > 1)
            -- if newSkinCollectInfo.flag > 0 then
            --     v:setColor(skinColloctColor[1])
            -- else
            --     v:setColor(skinColloctColor[2])
            -- end
        end

        if not selectInfo and curSkinId == id then
            selectInfo = info
        end
    end

    -- 无
    if not selectInfo then
        selectInfo = skinUiList[1].info
    end

    -- id 对但未收集
    self:selectSkin(selectInfo)
end

local preciousShowMode_skin = preciousShowMode.skin 
function HeroLayer:skinBtnCB(widget, touchkey)
--     local info = {id=1227894833}
-- self:orderMatrialOkLayer(info)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end
    local curMode = self.curPreciousMode

    if preciousShowMode_skin == curMode then
        self:initPreciousUIInMode(preciousShowMode.preciousLevel)
    else
        self.curSelectedSkinInfo = nil
        self:initPreciousUIInMode(preciousShowMode_skin)-- 优先至宝
    end

    gameUtil.removeRedPoint(widget)
end

function HeroLayer:clickSkinBtnCB(widget, touchkey)
    if touchkey ~= ccui_TouchEventType_ended then
        return
    end

    local info = widget.info
    local id = info.id
    mm_req("skinOn", {heroId=self.curHeroId, skinId = id, tag=1})

    -- TODO::如果是默认皮肤，直接重置到默认皮肤：

    -- 直接显示
    self:updateHeroShow(id)
end

local skinUnopenStr1 = gameUtil.GetMoGameRetStr(990313)
function HeroLayer:handleSkinOnMsg(t)
    if not t then
        return
    end

    local result = t.result
    if not result then
        return
    end

    if result == 0 then
        log("-------- return 换装成功！")
    else
        -- 不是默认皮肤的话，给予提示！
        log("-------- return 换装：其他！")
    end

    --dump(t,"------------skinOn back----------------")
    local heroId = t.heroId
    local skinInfo = t.skinInfo
    if result == 0 and heroId and skinInfo then
        --log("-------- return 换装：其他！111")
        --dump(skinInfo, "------------skinInfo----------------")
        local curHeroInfo = self.curHeroTab
        local curId = curHeroInfo.id
        if curId ~= heroId then
            -- 重新获取一个hero table
            curHeroInfo = getHeroInfo(heroId)
        end

        -- id
        local skinInfoClient = curHeroInfo.skinInfo
        if skinInfo.id and skinInfoClient then
            -- TODO::检查id是否是表里的
            skinInfoClient.id = skinInfo.id
        end

        -- list
        local collectList = skinInfo.collectList
        if collectList then
            --dump(collectList, "------------collectList----------------")
            local collectListClient = skinInfoClient.collectList
            local collectMap = {}
            for i,v in ipairs(collectListClient) do
                collectMap[v.id] = v
            end
            for i,v in ipairs(collectList) do
                if  v.flag >= 1 then -- 等于1是拥有 大于1是拥有但未使用
                    local curCollectInfo = collectMap[v.id]
                    if curCollectInfo then
                        curCollectInfo.flag = v.flag
                    end
                end
            end
        end
        self:updatePreciousBottomPanelSkin(self.curHeroTab)
    end

    if result ~= 0 and heroId and skinInfo and not isDefaultSkin(heroId, skinInfo.id)  then
        gameUtil:addTishi({p = self, s = skinUnopenStr1})
    else
        self:updateHeroShow()
    end
end

-- 至宝展示板和隐藏：
function HeroLayer:showPreciousPanel(isTrue)
    local PreciousPanel = self.PreciousPanel
    if PreciousPanel then
        PreciousPanel:setVisible(isTrue)
    end

    local heroPanel = self.heroPanel
    if heroPanel then
        heroPanel:setVisible(not isTrue)
    end
end

-- @END

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function HeroLayer:infoSetup()
    local preciousShowUiMap = {
        [preciousShowMode.preciousLevel] = {func = handler(self, self.initPreciousLevelUpUI)},
        [preciousShowMode.preciousOrder] = {func = handler(self, self.initPreciousOrderUpUI)},
        [preciousShowMode.skin] = {func = handler(self, self.initPreciousSkinUI)}
    }

    self.preciousShowUiMap = preciousShowUiMap


    local preciousPanelUpdateMag = {
        ZBSJ = handler(self, self.updatePreciousBottomPanelLv),
        ZBJX = handler(self, self.updatePreciousBottomPanelOrder)
    } 
    self.preciousPanelUpdateMag = preciousPanelUpdateMag
end

-- 分页的设置：
local preciousTag = pages.precious
function HeroLayer:doChangePage(tagIn)
    if not tagIn then
        tagIn = self.LayerTag
    end

    -- 开放检查
    if tagIn == preciousTag and not PA:isPreciousOpen(self, true) and not testMode then
        return
    end

    --
    local pageUiMap = self.pageUiMap
    if not pageUiMap then
        return
    end

    local doInitUIInfo = pageUiMap[tagIn]
    if not doInitUIInfo then
        return
    end

    local func = doInitUIInfo.func
    self.LayerTag = tagIn
    func()

    -- 
    self:showPreciousPanel(doInitUIInfo.isShowPreciousUi)

    -- btn
    local btn = doInitUIInfo.btn
    if btn then
        self:setBtn(btn)
    end

    --
    if tagIn == preciousTag then
        -- 延迟请求：
        self:delayReqInfo(self.curHeroId)

        -- 
        self:updateRedPointsForPrecious()
    end

    --
    if tagIn == 4 then
        if mm.GuildId == 10503 then
            performWithDelay(self,function( ... )
                Guide:startGuildById(10504, mm.GuildScene.GuildZhiBao01Btn)
            end, 0.1)
        end
    end

end

-- 所有Page按钮的回调
function HeroLayer:pageBtnCB(widget, touchkey)
    if touchkey == ccui_TouchEventType_ended then
        local info = widget.info -- {pageTag=1}
        if not info then
            return
        end

        
        local doChangePageFunc = info.doChangePageFunc
        if doChangePageFunc then
            doChangePageFunc(info.pageTag)
        end
    end
end

local gameUtil_addRedPoint = gameUtil.addRedPoint
local gameUtil_removeRedPoint = gameUtil.removeRedPoint
function HeroLayer:updateRedPointsForPrecious()
    local countAllHeros = 0
    local canLiftOrder = PA:getCanLiftOrder()

    local heroHeadIconsInId = self.heroHeadIconsInId
    for k,v in ipairs(mm_data.playerHero) do
        local preciousInfo = v.preciousInfo
        local heroId = v.id
        if testMode and not preciousInfo then
            --preciousInfo = {{id=1295003697, order=1, lv=25, restExp=20}}
        end
        local canLiftOrderCount = 0 --和皮肤公用
        if preciousInfo then
            for i,v in ipairs(preciousInfo) do
                if canLiftOrder <= v.lv and self:isOrderItemEnough(v) then
                    canLiftOrderCount = canLiftOrderCount + 1
                    break
                end
            end
        end

        -- 检查皮肤
        local skinInfo = v.skinInfo
        if skinInfo and self.playerLevel >= PA:getOpenLevel() then
            local _collectList = skinInfo.collectList
            if _collectList then
                for k,v in ipairs(_collectList) do
                    if v.flag > 1 and k > 1 then
                        canLiftOrderCount = canLiftOrderCount + 1
                        break
                    end
                end
            end
        end

        -- 红点加入
        -- local curIcon = heroHeadIconsInId[heroId]
        -- if curIcon then
        --     if canLiftOrderCount > 0 then
        --         gameUtil_addRedPoint(curIcon, 0.9, 0.9)
        --         countAllHeros = countAllHeros + 1
        --     else
        --         --gameUtil_removeRedPoint(curIcon)
        --     end
        -- end

    end

    -- 
    local PreciousBtn = self.PreciousBtn
    if PreciousBtn then
        if countAllHeros > 0 then
            gameUtil_addRedPoint(PreciousBtn, 0.7, 0.6)
        else
            gameUtil_removeRedPoint(PreciousBtn)
        end
    end
end

local ccs_MovementEventType_complete = ccs.MovementEventType.complete
function HeroLayer:createLevelUpEffectTo(parentNode, pos)
    print("sjyx sjyx sjyx sjyx sjyx sjyx sjyx sjyx111")
    local up_play = gameUtil.createSkeAnmion( {name = "sjyx", scale = 1} )
    up_play:setAnimation(0, "stand", false)
    parentNode:addChild(up_play, 10)
    up_play:setPosition(pos.x, pos.y * 0.35)

end

-- 至宝升级提示字
local wordColor = cc.c3b(0, 255, 0)
local p1 = {p = nil, s = nil, z = 100, f = 30, type = 2, color = wordColor}
local averTime = 0.5
function HeroLayer:addPreciousLevelUpWords(wordList, pName)
    if not wordList then
        return
    end

    local toNode = self.mainPanel2
    if not toNode then
        return
    end

    local pNameInCn = paramNames[pName]
    if not pNameInCn then
        return
    end

    local curPreciousLvUpWordListCount = #wordList
    if curPreciousLvUpWordListCount < 1 then
        return
    end

    toNode:stopAllActions()
    local index = 1
    function show()
        if index > curPreciousLvUpWordListCount then
            return
        end

        local str = pNameInCn.." +"..wordList[index]
        p1.p = toNode
        p1.s = str
        gameUtil:addTishi(p1)
        local t = averTime - 0.05 * curPreciousLvUpWordListCount
        if t < 0.1 then
            t = 0.1
        end
        toNode:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(show)))

        index = index + 1
    end
    show()
end

return HeroLayer
