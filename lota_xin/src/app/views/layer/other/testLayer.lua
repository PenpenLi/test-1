local testLayer = class("testLayer", require("app.views.mmExtend.LayerBase"))
testLayer.RESOURCE_FILENAME = "testLayer.csb"

function testLayer:onCreate(param)
    self.Node = self:getResourceNode()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function testLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "heroUpExp" then
            
        elseif event.code == "heroUpXin" then
            
        end

    end
end

function testLayer:onEnter()
    
end

function testLayer:onExit()
    
end

function testLayer:onEnterTransitionFinish()
    
end

function testLayer:onExitTransitionStart()
    
end

function testLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return testLayer