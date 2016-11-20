local WarningLayer = class("WarningLayer", require("app.views.mmExtend.LayerBase"))
WarningLayer.RESOURCE_FILENAME = "wangluolianjie.csb"

function WarningLayer:onCreate(param)
	self.app_ = param.app_
	self.fight = param.fight
	self.Node = self:getResourceNode()
	self.lockEndTime = param.lockEndTime
	self.forceLogout = param.forceLogout
	if self.app_.clientTCP then
		self.app_.clientTCP:disconnect()
		self.app_.clientTCP = nil
	end

	mm.unscheduleScript()

	local text = self.Node:getChildByName("Text_tishi")
	if self.forceLogout == true then
		text:setString(MoGameRet[990058])
	elseif self.lockEndTime == nil then
		text:setString(MoGameRet[990029])
	else
		local date = os.date("*t", param.lockEndTime)
		local str = string.format("%04d-%02d-%02d %02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
		text:setString(MoGameRet[990048]..str)
	end
	local okBtn = self.Node:getChildByName("Button_ok")
	gameUtil.setBtnEffect(okBtn)
	okBtn:addTouchEventListener(handler(self, self.okBtnCbk))

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function WarningLayer:okBtnCbk( widget, touchkey )
	if touchkey == ccui.TouchEventType.ended then
		if self.lockEndTime == nil then
			self.fight:initNode()
			mm.self = nil
			Guide:GuildEnd()
		end
		mm:clearLayer()
		self.app_:run("UpdateScene")
	end
end

function WarningLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function WarningLayer:onEnter()
    
end

function WarningLayer:onExit()
    
end

function WarningLayer:onEnterTransitionFinish()
    
end

function WarningLayer:onExitTransitionStart()
    
end

function WarningLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return WarningLayer