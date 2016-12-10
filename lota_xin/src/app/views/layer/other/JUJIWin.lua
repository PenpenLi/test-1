local JUJIWin = class("JUJIWin", require("app.views.mmExtend.LayerBase"))
JUJIWin.RESOURCE_FILENAME = "JUJIWin.csb"

require("app.res.rankawardRes")
require("app.res.ChangeRes")

function JUJIWin:onCreate(param)
    self.param = param
    self.Node = self:getResourceNode()

    -- ok按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    

    self.Text = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text")
    self.Text:setString("战力上升："..game.jujiZhanli.add)
    self.Text_Before = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_Before")
    self.Text_Before:setString(game.jujiZhanli.old)
    self.Text_After = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_After")
    self.Text_After:setString(game.jujiZhanli.new)

    game.jujiZhanli = nil 


    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

end

function JUJIWin:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        -- if event.code == "getTianTiInfo" then
          
        -- end
    end

end

function JUJIWin:onEnter()
end

function JUJIWin:onExit()
end



function JUJIWin:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function JUJIWin:onCleanup()

    self:clearAllGlobalEventListener()
end

return JUJIWin
