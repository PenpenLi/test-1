local ExchangeLayer = class("ExchangeLayer", require("app.views.mmExtend.LayerBase"))
ExchangeLayer.RESOURCE_FILENAME = "ExchangeLayer.csb"

function ExchangeLayer:onCreate(param)
    self.Node = self:getResourceNode()
    self.bTishi = param.bTishi
    if param.bTishi == "pk" then
        gameUtil:addTishi({p = self, s = MoGameRet[990014]})
        self.changeToType = MM.EChangeToType.CHANGERTO_PK
        self.time = mm.data.playerExtra.buyPkTime or 1
    elseif param.bTishi == "skill" then
        gameUtil:addTishi({p = self, s = "技能点不足"})
        self.changeToType = MM.EChangeToType.CHANGERTO_Skill
        self.time =  mm.data.playerExtra.buySkillTime or 1
    else
    	local stageRes = INITLUA:getStageResById(self.bTishi)
    	if stageRes.StageType == MM.EStageType.STAD then
            self.changeToType = MM.EChangeToType.CHANGERTO_Momian
        elseif stageRes.StageType == MM.EStageType.STAP then
            self.changeToType = MM.EChangeToType.CHANGERTO_Wumian
        elseif stageRes.StageType == MM.EStageType.STGirl then
            self.changeToType = MM.EChangeToType.CHANGERTO_Meinv
        elseif stageRes.StageType == MM.EStageType.STBeast then
            self.changeToType = MM.EChangeToType.CHANGERTO_Monster
        elseif stageRes.StageType == MM.EStageType.STBattle then
            self.changeToType = MM.EChangeToType.CHANGERTO_Sidou
        end
        self.time = 1
        for k,v in pairs(mm.data.playerStage) do
        	if v.chapter == stageRes.StageType then
        		self.time = v.buyExtraTime or 1
        	end
        end
    end
    local exchangeRes = INITLUA:getExchangeByLevel(self.time, self.changeToType)
    local image_bg = self.Node:getChildByName("Image_bg")
    local title = image_bg:getChildByName("Text_name")
    title:setString(exchangeRes.Name)

    local msg = image_bg:getChildByName("Text_msg")
    msg:setString(exchangeRes.Buy_Desc)
    image_bg:getChildByName("Image_diamond"):getChildByName("Text_msg"):setString(exchangeRes.ConsumeDiamond)

    local button_back = image_bg:getChildByName("Button_back")
    gameUtil.setBtnEffect(button_back)
    button_back:addTouchEventListener(handler(self, self.back))

    local button_ok = image_bg:getChildByName("Button_ok")
    gameUtil.setBtnEffect(button_ok)
    button_ok:addTouchEventListener(handler(self, self.ok))

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ExchangeLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
    	if event.code == "buySomeThing" then
    		if event.t.type == 2 then
    			gameUtil.showChongZhi( self, 1 )
    		elseif event.t.type == 0 then
    			self:removeFromParent()
            elseif event.t.type == 10 then
                gameUtil.showChongZhi( self, 0 )
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "提升VIP等级增加次数"})
    		end
    	end
    end
end

function ExchangeLayer:ok(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		if self.bTishi == "pk" then
			mm.req("buySomeThing", {getType = 2, buyType = 6})
		elseif self.bTishi == "skill" then
			mm.req("buySomeThing", {getType = 1, buyType = 6})
		else
			mm.req("buySomeThing", {getType = self.bTishi, buyType = 6})
		end
	end
end

function ExchangeLayer:back(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self:removeFromParent()
	end
end

function ExchangeLayer:onEnter()
    
end

function ExchangeLayer:onExit()
    
end

function ExchangeLayer:onEnterTransitionFinish()
    
end

function ExchangeLayer:onExitTransitionStart()
    
end

function ExchangeLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return ExchangeLayer