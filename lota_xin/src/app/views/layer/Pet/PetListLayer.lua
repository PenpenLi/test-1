local PetListLayer = class("PetListLayer", require("app.views.mmExtend.LayerBase"))
PetListLayer.RESOURCE_FILENAME = "pet/PetListLayer.csb"

function PetListLayer:onEnter()


end

function PetListLayer:onExit()
	
end

function PetListLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function PetListLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function PetListLayer:init(param)
	self.Node = self:getResourceNode()
    self.ImageBg = self.Node:getChildByName("Image_bg")

    --初始化主界面UI
    self:UIInit()

end

function PetListLayer:UIInit() 
    self.backBtn = self.ImageBg:getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))


    self.Node:getChildByName("Button"):addTouchEventListener(handler(self, self.checkBtnCbk))

end



function PetListLayer:checkBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local PetLayer = require("src.app.views.layer.Pet.PetLayer").new({})
        self:addChild(PetLayer, 100)
    end
end

function PetListLayer:setCheckNode() 

end

function PetListLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function PetListLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saveFormation" then
        end
    end
end


return PetListLayer