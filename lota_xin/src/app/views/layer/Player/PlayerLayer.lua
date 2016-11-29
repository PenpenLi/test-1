local PlayerLayer = class("PlayerLayer", require("app.views.mmExtend.LayerBase"))
PlayerLayer.RESOURCE_FILENAME = "PlayerLayer.csb"

function PlayerLayer:onEnter()


end

function PlayerLayer:onExit()
	
end

function PlayerLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function PlayerLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function PlayerLayer:init(param)
	self.Node = self:getResourceNode()
    self.ImageBg = self.Node:getChildByName("Image_bg")

    --初始化主界面UI
    self:UIInit()

end

function PlayerLayer:UIInit() 
    self.backBtn = self.ImageBg:getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
end

function PlayerLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function PlayerLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saveFormation" then
        end
    end
end


return PlayerLayer