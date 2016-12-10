local TTRules = class("TTRules", require("app.views.mmExtend.LayerBase"))
TTRules.RESOURCE_FILENAME = "TTRules.csb"

function TTRules:onCreate(param)
    self.Node = self:getResourceNode()


    local closeBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_Close")
    closeBtn:addTouchEventListener(handler(self, self.back))


    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function TTRules:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
    	if event.code == "challengeTianTi" then

    	end
    end
end

function TTRules:ok(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then

	end
end

function TTRules:back(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self:removeFromParent()
	end
end

function TTRules:onEnter()
    
end

function TTRules:onExit()
    
end

function TTRules:onEnterTransitionFinish()
    
end

function TTRules:onExitTransitionStart()
    
end

function TTRules:onCleanup()
    self:clearAllGlobalEventListener()
end

return TTRules