--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local stageListLayer = class("stageListLayer", require("app.views.mmExtend.LayerBase"))
stageListLayer.RESOURCE_FILENAME = "Guanqialiebiao.csb"


function stageListLayer:onCleanup()
    --self:clearAllGlobalEventListener()
end

function stageListLayer:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )
end

function stageListLayer:onExit()

end

function stageListLayer:onCreate(param)
    self:init(param)

    --self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function stageListLayer:init(param)
    self.param = param
    self.pLayer = param.pLayer

    self.listTab = param.listTab

    self:initLayerUI()
end

function stageListLayer:initLayerUI( )
    self.Node = self:getResourceNode()
    local ListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("ListView")

    local StageResMap = self.listTab.StageResMap
    local stageRes = self.listTab.stageRes
    local max_proc = self.listTab.max_proc

    local tab = {}
    local max = 1
    for k,v in pairs(StageResMap) do
        local zhang = v.Chapter
        local jie = v.Stage
        tab[zhang] = tab[zhang] or {}
        if mm.data.playerinfo.camp == v.Nation then
            table.insert(tab[zhang], v)
        end
        if v.Chapter > max then
            max = v.Chapter
        end
    end
    
    local useTab = {}
    for i=1,max do
        if tab[i] then
            table.insert(useTab, tab[i])
        end
    end
    

    local hasNum = 0
    for i=1,#useTab do
        local tempItem = cc.CSLoader:createNode("GuanqialbLayer.csb")
        local stageItem = tempItem:getChildByName("Image"):clone()  
        stageItem:setSwallowTouches(false)
        local custom_item = ccui.Layout:create()
        custom_item:addChild(stageItem)
        local size = stageItem:getContentSize()
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)

        local allt = #useTab[i]
        local jindu = 0
        if useTab[i][1].Chapter == stageRes.Chapter then
            jindu = max_proc - hasNum
            stageItem:loadTexture("res/UI/bt_tiao_hong.png")
        elseif useTab[i][1].Chapter < stageRes.Chapter then
            jindu = allt
        end

        hasNum = hasNum + allt

        stageItem:getChildByName("Text_1"):setString("NO."..i)
        stageItem:getChildByName("Text_2"):setString(useTab[i][1]["ChapterName"])
        stageItem:getChildByName("Text_3"):setString("("..jindu.."/"..allt..")")

        stageItem:addTouchEventListener(handler(self, self.ButBack))
        stageItem:setTag(useTab[i][1].Chapter)
    end



    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    

end

function stageListLayer:ButBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        local stageRes = self.listTab.stageRes
        if tag <= stageRes.Chapter then
            self.pLayer:updateStageInfo(tag)
            self:removeFromParent()
        else
            gameUtil:addTishi({s = "尚未通关上一章节"})
        end

    end
end



function stageListLayer:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function stageListLayer:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end



function stageListLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        
    end
end

return stageListLayer


