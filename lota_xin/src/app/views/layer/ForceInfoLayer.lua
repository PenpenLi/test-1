local ForceInfoLayer = class("ForceInfoLayer", require("app.views.mmExtend.LayerBase"))
ForceInfoLayer.RESOURCE_FILENAME = "Zhanli.csb"

local INITLUA = require "app.models.initLua"

function ForceInfoLayer:onCreate()
    self.Node = self:getResourceNode()

    local imageBg = self.Node:getChildByName("Image_bg")
    local okBtn = imageBg:getChildByName("Button_1")
    gameUtil.setBtnEffect(okBtn)
    okBtn:addTouchEventListener(handler(self, self.backBtnCbk))

   local infoNode = imageBg:getChildByName("Image_bg01")
   local zhanli = infoNode:getChildByName("Text_zhanli")
   local campZhanli = infoNode:getChildByName("Text_01")
   local backZhanli = infoNode:getChildByName("Text_02")
   local luedDuoZhanli = infoNode:getChildByName("Text_03")

   local valueAll = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue, true )
   local valueA = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue, false )
   local valueC = gameUtil.getPlayerForce( 10, true )

   local valueB = valueAll - valueA
   valueC = valueAll - valueC

   campZhanli:setString("阵容战力："..valueA)
   backZhanli:setString("替补战力："..valueB)
   zhanli:setString("战力："..valueA + valueB)
   luedDuoZhanli:setString("临时掠夺战力："..valueC)

end

function ForceInfoLayer:backBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm.popLayer()
    end
end

function ForceInfoLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function ForceInfoLayer:onEnter()
    
end

function ForceInfoLayer:onExit()
    
end

function ForceInfoLayer:onEnterTransitionFinish()
    
end

function ForceInfoLayer:onExitTransitionStart()
    
end

function ForceInfoLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return ForceInfoLayer