local layer = class("JingYanYuLanLayer", require("app.views.mmExtend.LayerBase"))
layer.RESOURCE_FILENAME = "res/Jingyanyulan.csb"

-- 变量缓存
local ItemRes = Item
local EquipRes = equip
local handler = handler
local mm = mm
local mm_data = mm.data
local playerCamp = mm_data.playerinfo.camp
local g_playerItem = mm_data.playerItem
local gameUtil = gameUtil
local _file_exists = gameUtil.file_exists
local ccui_Layout = ccui.Layout
local ccui_Helper = ccui.Helper
local EventDef = EventDef
local cc = cc
local INITLUA = INITLUA

local winSize = cc.Director:getInstance():getWinSize()
local table_insert = table.insert
local MM = MM

local panelPath = "res/JingyanyulanLayer.csb"

local LibaoRes = Libao

-- 加载资源
local cc_CSLoader = cc.CSLoader
local function getNodeFromCSB(pathIn)
    if not pathIn or not _file_exists (pathIn) then
        return nil
    end
    return cc_CSLoader:createNode(pathIn)
end

local ELibaoDropType = MM.ELibaoDropType
local ELibaoDropType_LB_Item = ELibaoDropType.LB_Item
local ELibaoDropType_LB_Equip = ELibaoDropType.LB_Equip
local ELibaoDropType_LB_Hero = ELibaoDropType.LB_Hero
local heroInfoTab = {jinlv=1,id=0}
local function getIconFrom(libaoId, num)
    local path = defaultPath
    local curLibaoRes = LibaoRes[libaoId]
    if not curLibaoRes then
        return nil
    end
    if curLibaoRes.LibaoDropType == ELibaoDropType_LB_Item then
        if ItemRes[curLibaoRes.ItemID] then
            return gameUtil.createItemWidget(curLibaoRes.ItemID, curLibaoRes.Value)
        else
            return nil
        end       
    elseif curLibaoRes.LibaoDropType == ELibaoDropType_LB_Equip then
        -- id都有检查过。
        --local iconPath = gameUtil.getEquipIconRes(curLibaoRes.ItemID)
        --if EquipRes[curLibaoRes.ItemID] then
            local node = gameUtil.createEquipItem(curLibaoRes.ItemID, curLibaoRes.Value, true)
            return node
        --else
            --return nil
        --end   
    elseif curLibaoRes.LibaoDropType == ELibaoDropType_LB_Hero then
        -- id都有检查过。
        heroInfoTab.id = curLibaoRes.ItemID
        return gameUtil.createTouXiangSimple(heroInfoTab)
    else
        -- TODO::魂石没处理
        --print("TODO::魂石没处理")
        return nil
    end
end

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
function layer:onCreate(param)
    self.param = param

    local resList = param.resList
    if not resList then
        resList = {}
    end

    -- 资源节点：
    local Node = self:getResourceNode() self.Node = Node
    local bgNode = Node:getChildByName("Image_bg") self.bgNode = bgNode
    
    -- 返回按钮
    local backBtn = bgNode:getChildByName("Button_back") self.backBtn = backBtn
    if backBtn then
        backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
        gameUtil.setBtnEffect(backBtn)
    end

    local btnInfoList = {} self.btnInfoList = btnInfoList
    local nodeNameList = {"Button_yinxiong", "Button_zhuangbei", "Button_zhuangbei_0"}
    --主要功能节点：123 3个节点
    for i,v in ipairs(nodeNameList) do
        local btn = Node:getChildByName(v)
        local curResList = resList[i]
        if btn and curResList and not curResList.hide then
            btn:addTouchEventListener(handler(self, self.clickTag))

            local mainInfo = {btn = btn, btnTag = i, idInTypes = curResList.idsInTypes, btnName = v}
            table_insert(btnInfoList, mainInfo)
            btn.mainInfo = mainInfo
        end
        if curResList.hide then
            btn:setVisible(false)
        end
    end
 
    -- 
    self.panelList = {}
    self:selectTagOn(1)
    ccui_Helper:doLayout(Node)
end

local ccui_TouchEventType_ended = ccui.TouchEventType.ended
function layer:backBtnCbk(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then 
        self:removeFromParent()
    end
end

function layer:clickTag(widget,touchkey)
    if touchkey == ccui_TouchEventType_ended then 
        local mainInfo = widget.mainInfo
        self:selectTagOn(mainInfo.btnTag)
    end
end

local function selectBtn(btn, enableIn)
    if enableIn then
        btn:setBright(false)
        btn:setEnabled(false)
    else
        btn:setBright(true)
        btn:setEnabled(true)
    end
end

function layer:selectTagOn(indexIn)
    local btnInfoList = self.btnInfoList
    local curBtnInfo = btnInfoList[indexIn]
    if not curBtnInfo then
        return
    end

    for i,v in ipairs(btnInfoList) do
        selectBtn(v.btn, false)
        if v.panel then
            v.panel:setVisible(false)
        end
    end

    selectBtn(curBtnInfo.btn, true)

    -- 展示逻辑：
    local idInTypes = curBtnInfo.idInTypes
    self:showOnViewList(idInTypes, indexIn, curBtnInfo)
end

local ccui_Layout = ccui.Layout
local hNum = 5
local math_mod = math.fmod
local barPath = "res/UI/pc_mingzidi.png"
local str1 = gameUtil.GetMoGameRetStr( 990100 )
local str2 = gameUtil.GetMoGameRetStr( 990101 )
local str3 = gameUtil.GetMoGameRetStr( 990102 )
local str4 = gameUtil.GetMoGameRetStr( 990106 )
local barNames = {str4, str1, str2, str3}
function layer:showOnViewList(idInTypes, index, infoIn)
    local panelList = self.panelList
    local panel = panelList[index]
    if panel then
        panel:setVisible(true)
        return
    end

    panel = getNodeFromCSB(panelPath)
    local listView = nil
    if panel then
        infoIn.panel = panel
        panelList[index] = panel

        panel:setContentSize(winSize)
        self:addChild(panel, 1000)
        local bg = panel:getChildByName("Image_1")
        if bg then
            listView = bg:getChildByName("ListView")
            if listView then
                listView.width = listView:getContentSize().width
            end
        end
        ccui_Helper:doLayout(panel)
    end

    if not listView then
        return
    end
    listView:setItemModel(ccui_Layout:create())
    
    local width = listView.width
    local averW = width / hNum
    local xStart = averW/2
    local frameSize = cc.size(width, 95)
    local countH = 0
    local frame = nil
    local countItem = 0

    for key,var in ipairs(idInTypes) do
        countH = 0

        --分栏
        if #var > 0 then 
            listView:pushBackDefaultItem()
            local bar = listView:getItem(countItem)
            bar:setContentSize(frameSize)
            bar:setAnchorPoint(cc.p(0.5, 0.5))
            if barPath then              
                local name = barNames[key]
                if name then
                    local title = getNodeFromCSB("LiBaoItemTitle.csb")
                    local custom_item = ccui_Layout:create()
                    title:getChildByName("Text"):setString(name)
                    bar:addChild(title, 100)

                    title:setAnchorPoint(cc.p(0.5, 0.2))
                    title:setScale(1.5)
                    title:setPositionX(frameSize.width/2 - 10)
                end
            end

            countItem = countItem + 1
        end
        
        for i,v in ipairs(var) do
            local curNode = getIconFrom(v.ID, 1)   
            if countH >= hNum then
                countH = math_mod(countH, hNum)
            end

            if curNode then
                if countH == 0 then
                    xStart = 0--averW/2
                    listView:pushBackDefaultItem()
                    frame = listView:getItem(countItem)
                    --listView:pushBackCustomItem(frame)
                    frame:setContentSize(frameSize)
                    countItem = countItem + 1       
                end
                countH = countH + 1
                
                local itemSize = curNode:getContentSize()            
                frame:addChild(curNode)
                frame:setAnchorPoint(0,0.5)
                curNode:setPositionX(xStart)
                xStart = xStart + averW
            end
        end
    end
    ccui_Helper:doLayout(panel)
end

return layer