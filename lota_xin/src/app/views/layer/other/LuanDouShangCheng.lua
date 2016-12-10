local LuanDouShangCheng = class("LuanDouShangCheng", require("app.views.mmExtend.LayerBase"))
LuanDouShangCheng.RESOURCE_FILENAME = "LuandouShangchengLayer.csb"

function LuanDouShangCheng:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function LuanDouShangCheng:onEnter()
    
end

function LuanDouShangCheng:onExit()

end

function LuanDouShangCheng:onEnterTransitionFinish()

end

function LuanDouShangCheng:onExitTransitionStart()

end

function LuanDouShangCheng:onCleanup()

end

function LuanDouShangCheng:init(param)
    self.param = param
    self.scene = self.param.scene

    self.Node = self:getResourceNode()
    local baseNode = self.Node:getChildByName("Image_bg")
    -- 按钮
    self.storeBtn = baseNode:getChildByName("Button_yinxiong")
    self.storeBtn.storeName = "商店"
    self.storeBtn:setTag(1)

    -- 关闭按钮
    self.backBtn = baseNode:getChildByName("Button_back")
    gameUtil.setBtnEffect(self.backBtn)
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self:initStore()
end

function LuanDouShangCheng:initStore( )
    local storeLayer = require("src.app.views.layer.MeleeStoreLayer").new({scene = self})
    if self.ContentLayer then
        self.ContentLayer:removeFromParent()
    end
    self.ContentLayer = storeLayer
    self:addChild(storeLayer)
    local size = cc.Director:getInstance():getWinSize()
    storeLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(storeLayer)
end

function LuanDouShangCheng:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function LuanDouShangCheng:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "buyMeleeStoreItem" then
            if event.t.type ~= 0 then
                local text = gameUtil.GetMoGameRetStr( event.t.code )
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = text, z = 1000000})
                return
            else
                local text = gameUtil.GetMoGameRetStr( event.t.code )
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = text, z = 1000000})
            end
        end
    end
end

return LuanDouShangCheng