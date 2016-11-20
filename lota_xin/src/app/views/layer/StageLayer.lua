local StageLayer = class("StageLayer", require("app.views.mmExtend.LayerBase"))
StageLayer.RESOURCE_FILENAME = "guanqialayer.csb"

function StageLayer:onCreate(param)
    self.app = param.app
    self.Node = self:getResourceNode()
    
    self.Node:getChildByName("Panel_touch"):addTouchEventListener(handler(self, self.backBtnCbk))
    self.Node:getChildByName("Image_bg"):getChildByName("Button_back"):addTouchEventListener(handler(self, self.backBtnCbk))

    self.ListView = self.Node:getChildByName("ListView")
    self:showStage()
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function StageLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "heroUpExp" then
            
        elseif event.code == "heroUpXin" then
            
        end
    end
end

function StageLayer:onEnter() 
    
end

function StageLayer:onExit()

end

function StageLayer:showStage( ... )
    local allShowStage = {}
    local StageResMap = INITLUA:getStageResMap()
    for k,v in pairs(StageResMap) do
        for x,y in pairs(v) do
            if mm.data.playerinfo.camp == y.Nation then
                local tab = {}
                tab.name = k
                tab.value = y.StageSort
                table.insert(allShowStage, tab)
                break
            end
        end
    end

    function sort_rule( a, b )
        return a.value < b.value
    end

    table.sort( allShowStage, sort_rule )
    for k,v in pairs(allShowStage) do
        local custom_item = ccui.Layout:create()
                
        local StageItem = cc.CSLoader:createNode("guanqiaItem.csb")
        StageItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setString(v.name)
        custom_item:addChild(StageItem)
        custom_item:setName(v.name)
        custom_item:setContentSize(StageItem:getContentSize())
        self.ListView:pushBackCustomItem(custom_item)
        StageItem:getChildByName("Image_bg"):setTouchEnabled(false)
        custom_item:setTouchEnabled(true)
        custom_item:addTouchEventListener(handler(self, self.stageDetail))

    end
end

function StageLayer:stageDetail(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local StageDetailLayer = require("src.app.views.layer.StageDetailLayer").create({app = self.app, name = widget:getName()})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(StageDetailLayer)
        StageDetailLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(StageDetailLayer)
    end
end

function StageLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function StageLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return StageLayer