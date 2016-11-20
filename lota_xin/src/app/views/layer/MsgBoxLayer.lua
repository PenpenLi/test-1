local MsgBoxLayer = class("MsgBoxLayer", require("app.views.mmExtend.LayerBase"))
MsgBoxLayer.RESOURCE_FILENAME = "MsgBoxLayer.csb"

function MsgBoxLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function MsgBoxLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function MsgBoxLayer:onEnter()

end

function MsgBoxLayer:onExit()

end

function MsgBoxLayer:onEnterTransitionFinish()

end

function MsgBoxLayer:onExitTransitionStart()

end

function MsgBoxLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function MsgBoxLayer:init(param)
    local titleText = param.titleText or "标题"
    local msgText = param.msgText or "内容"
    local yesCallBack = param.yesCallBack or nil
    local noCallBack = param.noCallBack or nil
    local node = param.node or nil
    self.Node = self:getResourceNode()

    self.Node:getChildByName("Text_title"):setText(titleText)
    self.Node:getChildByName("Text_msg"):setText(msgText)

    self.yesBtn = self.Node:getChildByName("Btn_yes")
    self.noBtn = self.Node:getChildByName("Btn_no")
    --gameUtil.setBtnEffect(self.yesBtn)
    --gameUtil.setBtnEffect(self.noBtn)

    if yesCallBack and not noCallBack then
        self.noBtn:setVisible(false)
    elseif not yesCallBack and noCallBack then
        self.yesBtn:setVisible(false)
    elseif yesCallBack and noCallBack then
        self.yesBtn:setPosition(self.yesBtn:getPositionX() + 100, self.yesBtn:getPositionY())
        self.noBtn:setPosition(self.noBtn:getPositionX() - 100, self.noBtn:getPositionY())
    else
        self.noBtn:setVisible(false)
        self.yesBtn:setVisible(false)
    end

    if yesCallBack then
        if yesCallBack == "close" then
            self.yesBtn:addTouchEventListener(handler(self, self.BackBtnCbk))
            return
        end
        if node then
            self.yesBtn:addTouchEventListener(handler(node, yesCallBack))
        else
            self.yesBtn:addTouchEventListener(yesCallBack)
        end
    end
    if noCallBack then
        if noCallBack == "close" then
            self.noBtn:addTouchEventListener(handler(self, self.BackBtnCbk))
            return
        end
        if node then
            self.noBtn:addTouchEventListener(handler(node, noCallBack))
        else
            self.noBtn:addTouchEventListener(noCallBack)
        end
    end
    
end

function MsgBoxLayer:BackBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return MsgBoxLayer
