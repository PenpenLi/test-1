local JJCRules = class("JJCRules", require("app.views.mmExtend.LayerBase"))
JJCRules.RESOURCE_FILENAME = "JJCRules.csb"

function JJCRules:onCreate(param)
    self.Node = self:getResourceNode()


    local closeBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_Close")
    closeBtn:addTouchEventListener(handler(self, self.back))


    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function JJCRules:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
    	if event.code == "challengeTianTi" then

    	end
    end
end

function JJCRules:ok(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then

	end
end

function JJCRules:back(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self:removeFromParent()
	end
end

function JJCRules:onEnter()
    
end

function JJCRules:onExit()
    
end

function JJCRules:onEnterTransitionFinish()
    
end

function JJCRules:onExitTransitionStart()
    
end

function JJCRules:onCleanup()
    self:clearAllGlobalEventListener()
end

return JJCRules