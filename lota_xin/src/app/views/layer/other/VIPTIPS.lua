

local VIPTIPS = class("VIPTIPS", require("app.views.mmExtend.LayerBase"))
VIPTIPS.RESOURCE_FILENAME = "VIPTIPS.csb"


function VIPTIPS:onCleanup()
    self:clearAllGlobalEventListener()
end

function VIPTIPS:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )
end

function VIPTIPS:onExit()

end

function VIPTIPS:onCreate(param)
    self.fuqin = param.scene
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function VIPTIPS:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end



function VIPTIPS:init(param)

    self.app = param.app
    self.str = param.str

    self.Node = self:getResourceNode()

    local closeBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_Close")
    gameUtil.setBtnEffect(closeBtn)
    closeBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    local Button_Quxiao = self.Node:getChildByName("Image_bg"):getChildByName("Button_Quxiao")
    Button_Quxiao:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(Button_Quxiao)

    local Button_Chongzhi = self.Node:getChildByName("Image_bg"):getChildByName("Button_Chongzhi")
    Button_Chongzhi:addTouchEventListener(handler(self, self.chongzhiBtnCbk))
    gameUtil.setBtnEffect(Button_Chongzhi)

    local strText = self.Node:getChildByName("Image_bg"):getChildByName("Text_Tips01")
    if self.str then
        strText:setString(self.str)
    end

end





function VIPTIPS:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end



function VIPTIPS:chongzhiBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        gameUtil.showChongZhi( self.fuqin)
        self:removeFromParent()
        
    end
end


return VIPTIPS
