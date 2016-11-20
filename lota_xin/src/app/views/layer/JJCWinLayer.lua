--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local JJCWinLayer = class("JJCWinLayer", require("app.views.mmExtend.LayerBase"))
JJCWinLayer.RESOURCE_FILENAME = "JJCWin.csb"


function JJCWinLayer:onCleanup()
    --self:clearAllGlobalEventListener()
end

function JJCWinLayer:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )

end

function JJCWinLayer:onExit()

end

function JJCWinLayer:onCreate(param)
    self:init(param)

    --self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function JJCWinLayer:init(param)
    self.param = param
    self.scene = param.scene

    self.before = param.before
    self.after = param.after
    self.honor = param.honor
    


    self:initLayerUI()
end

function JJCWinLayer:initLayerUI( )
    
    self.Node = self:getResourceNode()


    local Text_Before = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_Before")
    Text_Before:setString(self.before)
    local Text_After = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_After")
    Text_After:setString(self.after)


    local ListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_2"):getChildByName("ListView")



    if self.honor and self.honor > 0 then
        local item = gameUtil.createItemByIcon("res/icon/jiemian/icon_rongyu.png", self.honor)
        local custom_item = ccui.Layout:create()
        item:setAnchorPoint(cc.p(0, 0))
        local size = item:getContentSize()
        size.width = size.width * 1.3
        size.height = size.height * 1.3
        custom_item:addChild(item)
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end


    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    

end





function JJCWinLayer:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function JJCWinLayer:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end



function JJCWinLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        
    end
end

return JJCWinLayer


