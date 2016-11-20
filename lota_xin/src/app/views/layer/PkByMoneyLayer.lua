local PkByMoneyLayer = class("PkByMoneyLayer", require("app.views.mmExtend.LayerBase"))
PkByMoneyLayer.RESOURCE_FILENAME = "ExchangeLayer.csb"

function PkByMoneyLayer:onCreate(param)
    self.Node = self:getResourceNode()
    self.num = param.num
    self.id = param.id
    
    local image_bg = self.Node:getChildByName("Image_bg")
    local title = image_bg:getChildByName("Text_name")
    title:setString("强行PK")

    local msg = image_bg:getChildByName("Text_msg")
    msg:setString("无视PK次数，强行PK！")
    image_bg:getChildByName("Image_diamond"):getChildByName("Text_msg"):setString(self.num)

    local button_back = image_bg:getChildByName("Button_back")
    gameUtil.setBtnEffect(button_back)
    button_back:addTouchEventListener(handler(self, self.back))

    local button_ok = image_bg:getChildByName("Button_ok")
    gameUtil.setBtnEffect(button_ok)
    button_ok:addTouchEventListener(handler(self, self.ok))

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function PkByMoneyLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
    	if event.code == "challengeTianTi" then
            if event.t.diamondType == 0 then
        		local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_, type = 10, Info = event.t.direninfo})
                local size  = cc.Director:getInstance():getWinSize()
                self:addChild(BuZhenLayer)
                BuZhenLayer:setContentSize(cc.size(size.width, size.height))
                ccui.Helper:doLayout(BuZhenLayer)
                self:removeFromParent()
            elseif event.t.diamondType == 1 then
                gameUtil:addTishi({p = self, s = MoGameRet[990001]})
            elseif event.t.diamondType == 2 then
                gameUtil.showChongZhi( self, 0 )
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "提升VIP等级增加次数"})
                self:removeFromParent()
            else
                gameUtil:addTishi({p = self, s = MoGameRet[900001]})
            end
    	end
    end
end

function PkByMoneyLayer:ok(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		mm.req("challengeTianTi",{playerid = self.id, diamondType = 1})
	end
end

function PkByMoneyLayer:back(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self:removeFromParent()
	end
end

function PkByMoneyLayer:onEnter()
    
end

function PkByMoneyLayer:onExit()
    
end

function PkByMoneyLayer:onEnterTransitionFinish()
    
end

function PkByMoneyLayer:onExitTransitionStart()
    
end

function PkByMoneyLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return PkByMoneyLayer