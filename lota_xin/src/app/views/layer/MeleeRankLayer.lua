local MeleeRankLayer = class("MeleeRankLayer", require("app.views.mmExtend.LayerBase"))
MeleeRankLayer.RESOURCE_FILENAME = "Daluandoupaihang.csb"

function MeleeRankLayer:onCreate(param)
    self.Node = self:getResourceNode()

    local image_bg = self.Node:getChildByName("Image_bg")
    self.benfuBtn = image_bg:getChildByName("Button_zhuangbei")
    self.benfuText = self.benfuBtn:getChildByName("Text")
    self.benfuText:setString("本服")
    self.benfuBtn:addTouchEventListener(handler(self, self.benfuBtnCbk))

    self.backBtn = image_bg:getChildByName("Button_back")
    gameUtil.setBtnEffect(self.backBtn)
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.kuafuBtn = image_bg:getChildByName("Button_hunshi")
    self.kuafuText = self.kuafuBtn:getChildByName("Text")
    self.kuafuText:setString("跨服")
    self.kuafuBtn:addTouchEventListener(handler(self, self.kuafuBtnCbk))
    self.kuafuBtn:setVisible(false)

    self.quBtn = image_bg:getChildByName("Button_xiaohao")
    self.quText = self.quBtn:getChildByName("Text")
    self.quText:setString("区")
    self.quBtn:addTouchEventListener(handler(self, self.quBtnCbk))
    self.quBtn:setVisible(false)

    local image_top = self.Node:getChildByName("Image_top")
    self.image_title = image_top:getChildByName("Image_title")

    self.rewardBtn = image_top:getChildByName("Button_reward")
    self.rewardBtn:addTouchEventListener(handler(self, self.rewardBtnCbk))
    gameUtil.setBtnEffect(self.rewardBtn)

    local image_di = self.Node:getChildByName("Image_di")
    image_di:getChildByName("Text_miaoshu"):setString("活动开启后刷新排行榜 \n活动结束时，通过邮件发放排行奖励")
    

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function MeleeRankLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getMeleeRank" then
        	if event.t.type == 0 then
	        	self.rankList = event.t.rankList
	        	self.myInfo = event.t.myInfo
				self:updateList()
			elseif event.t.type == 1 then
				gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), z = 999999, s = "该排行在开服3天后开放"})
			end
        end
    end
end

function MeleeRankLayer:onEnter()
    self.layerTag = 1
    mm.req("getMeleeRank", {type = 1})
end

function MeleeRankLayer:onExit()
    
end

function MeleeRankLayer:benfuBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self.layerTag = 1
    	mm.req("getMeleeRank", {type = 1})
	end
end

function MeleeRankLayer:kuafuBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self.layerTag = 2
        mm.req("getMeleeRank", {type = 2})

        -- gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), z = 999999, s = "暂未开放"})
	end
end

function MeleeRankLayer:quBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self.layerTag = 3
    	mm.req("getMeleeRank", {type = 3})
	end
end

function MeleeRankLayer:updateList()
	local sollowView = self.Node:getChildByName("ScrollView") 
    sollowView:removeAllChildren()
    sollowView:jumpToTop()
    local function fun( i, table, cell )
    	local image_bg = cell
        image_bg:setSwallowTouches(false)

        if i < 4 then
            image_bg:getChildByName("Image_1"):loadTexture("res/icon/jiemian/icon_paihang_"..i..".png")
            image_bg:getChildByName("Text_ranking"):setVisible(false)
        else
            image_bg:getChildByName("Image_1"):loadTexture("res/icon/jiemian/icon_paihang_4.png")
            image_bg:getChildByName("Text_ranking"):setText(i)
            image_bg:getChildByName("Text_ranking"):setVisible(true)
        end
        if self.layerTag == 2 then
        	image_bg:getChildByName("Text_6"):setVisible(true)
        	image_bg:getChildByName("Text_6"):setString(table.level.."区")
	    else
	    	image_bg:getChildByName("Text_6"):setVisible(false)
	    end
	    image_bg:getChildByName("Text_name"):setText(table.nickname)

	    image_bg:getChildByName("Text_zhanli"):setText("战力: "..gameUtil.dealNumber(table.zhanli))

        if table.camp == 1 then
            image_bg:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhilol_select.png")
            image_bg:getChildByName("Image_icon"):loadTexture("res/icon/head/L023.png")
        else
            image_bg:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhidota_select.png")
            image_bg:getChildByName("Image_icon"):loadTexture("res/icon/head/D074.png")
        end
        image_bg:getChildByName("Text_name_0"):setString(table.meleeKillNum)

        image_bg:setAnchorPoint(0.0,0.0)
    end

    if self.rankList and #self.rankList > 0 then
        gameUtil.setSollowView(sollowView, 8, 1, self.rankList, 105, "DaluandouPHtiao.csb", fun, handler(self, self.checkPlayer))
    end

    -- 更新自己的信息
    local image_my = self.Node:getChildByName("Image_my")
    image_my:getChildByName("Text_paiming"):setString(self.myInfo.ranking)
	image_my:getChildByName("Text_ming"):setString(self.myInfo.nickname)
    image_my:getChildByName("Text_shenglv"):setString(self.myInfo.meleeKillNum)


	if self.layerTag == 1 then
		self.image_title:loadTexture("res/UI/pc_benfu.png")
		self:setBtn(self.benfuBtn)
	elseif self.layerTag == 2 then
		self.image_title:loadTexture("res/UI/pc_kuafu.png")
		self:setBtn(self.kuafuBtn)
	else
		self.image_title:loadTexture("res/UI/pc_qu.png")
		self:setBtn(self.quBtn)
	end
end

function MeleeRankLayer:checkPlayer(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        
    end
end

function MeleeRankLayer:setBtn(btn)
	self.benfuBtn:setBright(true)
    self.kuafuBtn:setBright(true)
    self.quBtn:setBright(true)

    self.benfuBtn:setEnabled(true)
    self.kuafuBtn:setEnabled(true)
    self.quBtn:setEnabled(true)

    btn:setBright(false)
    btn:setEnabled(false)
end

function MeleeRankLayer:rewardBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local MeleeRewardLayer = require("src.app.views.layer.MeleeRewardLayer").new(self.app_)
        MeleeRewardLayer:setName("MeleeRewardLayer")
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(MeleeRewardLayer, MoGlobalZorder[2000002])
        MeleeRewardLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(MeleeRewardLayer)
    end
end

function MeleeRankLayer:backBtnCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
		self:removeFromParent()
	end
end

function MeleeRankLayer:onEnterTransitionFinish()
    
end

function MeleeRankLayer:onExitTransitionStart()
    
end

function MeleeRankLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return MeleeRankLayer