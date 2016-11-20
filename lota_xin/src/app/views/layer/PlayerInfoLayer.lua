local PlayerInfoLayer = class("PlayerInfoLayer", require("app.views.mmExtend.LayerBase"))
PlayerInfoLayer.RESOURCE_FILENAME = "Zhujuexinxi.csb"

local INITLUA = require "app.models.initLua"

function PlayerInfoLayer:onCreate()
    self.Node = self:getResourceNode()

    local imageBg = self.Node:getChildByName("Image_bg")
    local okBtn = imageBg:getChildByName("Button_back")
    gameUtil.setBtnEffect(okBtn)
    okBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.effectBtn = imageBg:getChildByName("Button_effect")
    gameUtil.setBtnEffect(self.effectBtn)
    self.effectBtn:addTouchEventListener(handler(self, self.effectBtnCbk))
    mm.effectOpen = cc.UserDefault:getInstance():getIntegerForKey("effectOpen")
	self:setEffectBtn(mm.effectOpen)

    self.musicBtn = imageBg:getChildByName("Button_music")
    gameUtil.setBtnEffect(self.musicBtn)
    self.musicBtn:addTouchEventListener(handler(self, self.musicBtnCbk))
    mm.musicOpen = cc.UserDefault:getInstance():getIntegerForKey("musicOpen")

	self.rechargeBtn = imageBg:getChildByName("Button_Recharge")
    -- gameUtil.setBtnEffect(self.rechargeBtn)
    self.rechargeBtn:addTouchEventListener(handler(self, self.rechargeBtnCbk))

    mm.musicOpen = cc.UserDefault:getInstance():getIntegerForKey("musicOpen")

    self.danmuBtn = imageBg:getChildByName("Button_1")
    self.danmuBtn:addTouchEventListener(handler(self, self.danmuBtnCbk))
    local open = cc.UserDefault:getInstance():getIntegerForKey("danmuOpen")
    if open == 0 then
		self:setDanmuBtn(1)
	else
		self:setDanmuBtn(0)
	end

	self:setMusicBtn(mm.musicOpen)

    local fenxiangBtn = imageBg:getChildByName("Button_fenxiang")
    if not IOS_S then
    	fenxiangBtn:setVisible(true)
	    fenxiangBtn:setTouchEnabled(true)
	    gameUtil.setBtnEffect(fenxiangBtn)
	    fenxiangBtn:addTouchEventListener(handler(self, self.fenxinagBtnCbk))
	else
		fenxiangBtn:setVisible(false)
	end

    local touxiang = imageBg:getChildByName("Image_touxiang")
    local imagebg01 = imageBg:getChildByName("Image_bg01")
    local name = imagebg01:getChildByName("Text_name")
    name:setString("战队名字："..mm.data.playerinfo.nickname)

   	local lv = imagebg01:getChildByName("Text_lv")
   	lv:setString("战队等级："..gameUtil.getPlayerLv(mm.data.playerinfo.exp))

    local vipLv = imagebg01:getChildByName("Text_vipLv")
    vipLv:setString("VIP等级："..gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp))

    local exp = imagebg01:getChildByName("Text_exp")
    exp:setString("战队经验："..mm.data.playerinfo.exp.."/"..(INITLUA:getActResByLv( gameUtil.getPlayerLv(mm.data.playerinfo.exp) ).TotleExp))

    local ID = imagebg01:getChildByName("Text_ID")
    ID:setString("战队ID："..mm.data.playerinfo.id)

    local image_qizhi = imagebg01:getChildByName("Image_qizhi")

    if mm.data.playerinfo.camp == 1 then
        touxiang:loadTexture("res/icon/head/L036.png")
        image_qizhi:loadTexture("res/UI/bt_qizhilol_select.png")
    else
        touxiang:loadTexture("res/icon/head/D038.png")
        image_qizhi:loadTexture("res/UI/bt_qizhidota_select.png")
    end
end

function PlayerInfoLayer:setDanmuBtn(open)
	if open == 0 then -- 弹幕为开
		cc.UserDefault:getInstance():setIntegerForKey("danmuOpen", 1)
		self.danmuBtn:loadTextureNormal("res/UI/pc_danmu.png")
	    self.danmuBtn:loadTexturePressed("res/UI/pc_danmu.png")
	    self.danmuBtn:loadTextureDisabled("res/UI/pc_danmu.png")
	    mm.self:getChildByName("BarrageLayer"):setVisible(false)
	else
		cc.UserDefault:getInstance():setIntegerForKey("danmuOpen", 0)
		self.danmuBtn:loadTextureNormal("res/UI/pc_danmu_kai.png")
	    self.danmuBtn:loadTexturePressed("res/UI/pc_danmu_kai.png")
	    self.danmuBtn:loadTextureDisabled("res/UI/pc_danmu_kai.png")
	    mm.self:getChildByName("BarrageLayer"):setVisible(true)
	end
end

function PlayerInfoLayer:danmuBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		local open = cc.UserDefault:getInstance():getIntegerForKey("danmuOpen")
		self:setDanmuBtn(open)
	end
end

function PlayerInfoLayer:backBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		mm.popLayer()
	end
end

function PlayerInfoLayer:setEffectBtn(flag)
	if flag == 1 then
		cc.UserDefault:getInstance():setIntegerForKey("effectOpen", 1)
		self.effectBtn:loadTextureNormal("res/UI/pc_shengyin.png")
	    self.effectBtn:loadTexturePressed("res/UI/pc_shengyin.png")
	    self.effectBtn:loadTextureDisabled("res/UI/pc_shengyin.png")
	else
		cc.UserDefault:getInstance():setIntegerForKey("effectOpen", 0)
		self.effectBtn:loadTextureNormal("res/UI/pc_shengyin_kai.png")
	    self.effectBtn:loadTexturePressed("res/UI/pc_shengyin_kai.png")
	    self.effectBtn:loadTextureDisabled("res/UI/pc_shengyin_kai.png")
	end
end

function PlayerInfoLayer:setMusicBtn(flag)
	if flag == 1 then
		cc.UserDefault:getInstance():setIntegerForKey("musicOpen", 1)
		self.musicBtn:loadTextureNormal("res/UI/pc_yinyue.png")
	    self.musicBtn:loadTexturePressed("res/UI/pc_yinyue.png")
	    self.musicBtn:loadTextureDisabled("res/UI/pc_yinyue.png")
	else
		cc.UserDefault:getInstance():setIntegerForKey("musicOpen", 0)
		self.musicBtn:loadTextureNormal("res/UI/pc_yinyue_kai.png")
	    self.musicBtn:loadTexturePressed("res/UI/pc_yinyue_kai.png")
	    self.musicBtn:loadTextureDisabled("res/UI/pc_yinyue_kai.png")
	end
end

function PlayerInfoLayer:effectBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		mm.effectOpen = cc.UserDefault:getInstance():getIntegerForKey("effectOpen")
		if mm.effectOpen == 1 then -- 改为开的状态
			self:setEffectBtn(0)
		else
			self:setEffectBtn(1)
		end
	end
end

function PlayerInfoLayer:musicBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		mm.musicOpen = cc.UserDefault:getInstance():getIntegerForKey("musicOpen")
		if mm.musicOpen == 1 then -- 现在为不播放
			self:setMusicBtn(0)
			AudioEngine.playMusic("res/sounds/music/Fight.mp3", true)
		else
			self:setMusicBtn(1)
			AudioEngine.stopMusic(true)
		end
	end
end

function PlayerInfoLayer:fenxinagBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		local FengXiangFiveLayer = require("src.app.views.layer.FengXiangFiveLayer").new({bTishi = bTishi})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(FengXiangFiveLayer, MoGlobalZorder[2000002])
        FengXiangFiveLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(FengXiangFiveLayer)
	end
end

function PlayerInfoLayer:rechargeBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		gameUtil.showChongZhi(mm.self)
	end
end

function PlayerInfoLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function PlayerInfoLayer:onEnter()
    
end

function PlayerInfoLayer:onExit()
    
end

function PlayerInfoLayer:onEnterTransitionFinish()
    
end

function PlayerInfoLayer:onExitTransitionStart()
    
end

function PlayerInfoLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return PlayerInfoLayer