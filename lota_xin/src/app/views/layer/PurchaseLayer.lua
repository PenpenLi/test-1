local PurchaseLayer = class("PurchaseLayer", require("app.views.mmExtend.LayerBase"))
PurchaseLayer.RESOURCE_FILENAME = "Chongzhi.csb"

function PurchaseLayer:onEnter()
	--self:init()
end

function PurchaseLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function PurchaseLayer:onExit()
	
end

function PurchaseLayer:onCreate(param)
    self:init()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))

    if param.bTishi ~= nil then
        if param.bTishi == 1 then
    	       gameUtil:addTishi({p = self, s = MoGameRet[990001]})
        else
            gameUtil:addTishi({p = self, s = MoGameRet[param.bTishi]})
        end
    end
	-- mm.req("getBuyRecordInfo",{type = 1})
end

function PurchaseLayer:init()
    -- 添加node事件
    self.Node = self:getResourceNode()

    -- 按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_2")
    gameUtil.setBtnEffect(self.backBtn)
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.vipBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    gameUtil.setBtnEffect(self.vipBtn)
    self.vipBtn:addTouchEventListener(handler(self, self.vipBtnCbk))

    local an = gameUtil.createSkeAnmion( {name = "csk",scale = 1.0} )
    an:setAnimation(0, "stand", true)
    self.vipBtn:addChild(an)
    an:setPosition(self.vipBtn:getContentSize().width*0.5, self.vipBtn:getContentSize().height*0.5)
    self.an = an

    self.moneyText = self.Node:getChildByName("Image_bg"):getChildByName("Text_need")
    self.vipText = self.Node:getChildByName("Image_bg"):getChildByName("Text_vip")

    local needExp, haveExp = INITLUA:getVipExpNeed(mm.data.playerinfo.vipexp)
    local needDiamond = needExp - haveExp
    self.myVipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    local targetLv = self.myVipLv == 15 and self.myVipLv or (self.myVipLv + 1)

    if self.myVipLv >= 15 then
    	self.Node:getChildByName("Image_bg"):getChildByName("Text_Num"):setVisible(false)
    	self.Node:getChildByName("Image_bg"):getChildByName("Text_Num1"):setVisible(false)
    	self.moneyText:setVisible(false)
    	self.vipText:setVisible(false)
    end

    self.moneyText:setString(needDiamond/10)
    self.vipText:setString("VIP"..targetLv)

    self.listView = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("ListView_1")
    
    self:initRechargeList()
    
    -- vip礼包添加红点
    if gameUtil.canBuyGift() == 1 then
        gameUtil.addRedPoint(self.vipBtn, 0.95, 0.9)
    end
end

function PurchaseLayer:initRechargeList()
	local rechargeInfo = INITLUA:getRechargeRes()

    table.sort(rechargeInfo, function(a,b)
        return a.ChongzhiSort < b.ChongzhiSort
    end)

    for k,v in pairs(rechargeInfo) do
        if v.Activated == 1 then
            local custom_item = ccui.Layout:create()
            custom_item:addTouchEventListener(handler(self, self.selectCbk))
            custom_item:setTouchEnabled(true)
            custom_item.proId = v.IDString

            local item = cc.CSLoader:createNode("chongzhiLayer1.csb")
            local itemRoot = item:getChildByName("Image_1")
            itemRoot:setTouchEnabled(false)
            --itemRoot:setSwallowTouches(false)
            
            itemRoot.proId = v.IDString

            itemRoot:getChildByName("Text_1"):setString(v.Name)
            itemRoot:getChildByName("Text_2"):setVisible(false)

            local des = v.ChongzhiDescDouble
            local isFirst = true
    		local record = mm.data.playerinfo.rechargetype
    		if record and #record > 0 then
    			record = json.decode(record)
    			for key,value in pairs(record) do
    				if key == v.IDString and value == true then
    					des = v.ChongzhiDesc
                        isFirst = false
                        break
    				end
    			end
    		end 

            itemRoot:getChildByName("Text_2_0"):setString(des)
            itemRoot:getChildByName("Text_4"):setString(v.RMB.."元")

            item:getChildByName("Text_5"):setVisible(false)
            if v.IDString == "com.dianhun.lota.B007" and mm.data.playerinfo.lastMonthcardTimes and mm.data.playerinfo.lastMonthcardTimes > 0  then
                itemRoot:getChildByName("Text_2_0"):setString("已购买，剩余时间："..mm.data.playerinfo.lastMonthcardTimes.."天")
                itemRoot:getChildByName("Text_2_0"):setColor(cc.c3b(255, 0, 0))
            elseif v.IDString == "com.dianhun.lota.B008" and mm.data.playerinfo.lastHighmonthcardTimes and mm.data.playerinfo.lastHighmonthcardTimes > 0  then
                itemRoot:getChildByName("Text_2_0"):setString("已购买，剩余时间："..mm.data.playerinfo.lastHighmonthcardTimes.."天")
                itemRoot:getChildByName("Text_2_0"):setColor(cc.c3b(255, 0, 0))
            elseif v.IDString == "com.dianhun.lota.B009" and mm.data.playerinfo.alllife and mm.data.playerinfo.alllife > 0  then
                itemRoot:getChildByName("Text_2_0"):setString("已购买，终生有效")
                itemRoot:getChildByName("Text_2_0"):setColor(cc.c3b(255, 0, 0))
            else
                if isFirst and  v.IDString ~= "com.dianhun.lota.B007" and  v.IDString ~= "com.dianhun.lota.B008" and  v.IDString ~= "com.dianhun.lota.B009" then
                    item:getChildByName("Text_5"):setVisible(true)
                    item:getChildByName("Text_5"):setString("双倍")
                    item:getChildByName("Text_5"):setColor(cc.c3b(255, 0, 0))
                else
                    item:getChildByName("Text_5"):setVisible(false)
                end
            end

            item:getChildByName("Image_4"):setVisible(false)

            local zOrder = item:getChildByName("Image_4"):getZOrder()
            local positionx, positiony = item:getChildByName("Image_4"):getPosition()

            local icon = cc.Sprite:create("res/icon/jiemian/"..v.Icon..".png")
            itemRoot:addChild(icon,zOrder)
            icon:setPosition(positionx, positiony)

         --    if v.Hot == 1 then
         --    	item:getChildByName("Text_5"):setVisible(true)
    	    -- else
    	    -- 	item:getChildByName("Text_5"):setVisible(false)
    	    -- end

            

            custom_item:setContentSize(item:getContentSize())
            custom_item:addChild(item)

            self.listView:pushBackCustomItem(custom_item)
        end
    end
end

function PurchaseLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getOrderInfo" then
            local orderTab = event.t.orderInfo
            local proId = orderTab.proId
            local orderid = orderTab.orderid
            local rechargeList = INITLUA:getRechargeRes()
            local rechargeInfo = nil
            for k,v in pairs(rechargeList) do
                if v.IDString == proId then
                    rechargeInfo = v
                    break
                end
            end

            if rechargeInfo == nil then
                cclog("PurchaseLayer --------------------找不到对应充值物品ID")
                return
            end

            local des = rechargeInfo.ChongzhiDescDouble
            local isFirst = true
            local record = mm.data.playerinfo.rechargetype
            if record and #record > 0 then
                record = json.decode(record)
                for key,value in pairs(record) do
                    if key == rechargeInfo.IDString and value == true then
                        des = rechargeInfo.ChongzhiDesc
                        isFirst = false
                        break
                    end
                end
            end

            local userData =  game.LoginSDkData
            local memo = orderid
            local partyName = "LOL"
            local curSeverName = ""
            for k,v in pairs(game.severList) do
                if v.id == mm.data.playerinfo.qufu then
                    curSeverName = v.Name
                    break
                end
            end

            local info = {}
            info.proId = rechargeInfo.IDString
            info.appUserId = mm.data.playerinfo.id
            info.sdkUserId = userData.uid
            info.price = rechargeInfo.RMB
            info.proName = rechargeInfo.Name
            info.goodsCount = 1
            info.roleId = mm.data.playerinfo.id
            info.roleName = mm.data.playerinfo.nickname
            info.roleLevel = mm.data.playerinfo.level
            info.memo = orderid
            info.orderId = orderid
            info.areaId = mm.data.playerinfo.qufu
            info.balance = mm.data.playerinfo.diamond
            info.roleVipLevel = mm.data.playerinfo.viplevel
            info.partyName = partyName
            info.serverName = curSeverName

            local param = {}
            param.proDes = des
            
            info.param = json.encode(param)
            
            local infoRes = json.encode(info)
            SDKUtil:payment(infoRes)

        elseif event.code == "getBuyRecordInfo" then
        	if event.t.type == 0 then
        	-- 	local info = event.t.buyRecordInfo
        	-- 	local infoList = json.decode(info)
        	-- 	self:initRechargeList( infoList )
        	end
        end
    end

    if event.name == EventDef.UI_MSG then
        if event.code == "vipGift" then
            -- vip礼包添加红点
            if gameUtil.canBuyGift() == 1 then
                gameUtil.addRedPoint(self.vipBtn, 0.95, 0.9)
            else
                gameUtil.removeRedPoint(self.vipBtn)
            end
        end
    end
end

function PurchaseLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        game:dispatchEvent({name = EventDef.UI_MSG, code = "vipGift"})
        self:removeFromParent()
    end
end

function PurchaseLayer:vipBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.began then
        if self.an then
            self.an:setScale(0.9)
        end
    elseif touchkey == ccui.TouchEventType.canceled then
        if self.an then
            self.an:setScale(1)
        end
    elseif touchkey == ccui.TouchEventType.ended then
        if self.an then
            self.an:setScale(1)
        end
        local VIPLayer = require("src.app.views.layer.VIPLayer").new(self.app_)
        VIPLayer:setName("VIPLayer")
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(VIPLayer)
        VIPLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(VIPLayer)
    end
end

function PurchaseLayer:selectCbk(widget,touchkey)
	if touchkey == ccui.TouchEventType.ended then 
        --根据平台做下一步处理
        if PLATFORM == "dhsdk" or PLATFORM == "dhtest" then
	       	--[[
			// 支付传递json的key
			public static final String pay_arg_param = "param"; // 额外参数
			public static final String pay_arg_pro_id = "proId"; // 产品ID
			public static final String pay_arg_app_user_id = "appUserId"; // 我们游戏的唯一标识（帐号）
			public static final String pay_arg_sdk_user_id = "sdkUserId"; // sdk的唯一标识（帐号）
			public static final String pay_arg_price = "price"; // 产品价格
			public static final String pay_arg_pro_name = "proName"; // 产品名称
			public static final String pay_arg_goods_count = "goodsCount"; // 物品数量
			public static final String pay_arg_role_id = "roleId"; // 角色id
			public static final String pay_arg_role_name = "roleName"; // 角色名
			public static final String pay_arg_role_level = "roleLevel"; // 角色等级
			public static final String pay_arg_memo = "memo"; // 透传信息
			public static final String pay_arg_order_id = "orderId";// 订单ID
			public static final String pay_arg_area_id = "areaId"; // 大区ID
			
			public static final String pay_arg_balance = "balance";// 账户余额
			public static final String pay_arg_role_vip_level = "roleVipLevel";// 等级vip等级
			public static final String pay_arg_party_name = "partyName";// 工会名字
			public static final String pay_arg_server_name = "serverName";// 所在服务器	
			--]]
	        local proId = widget.proId
	        local rechargeList = INITLUA:getRechargeRes()
	        local rechargeInfo = nil
	        for k,v in pairs(rechargeList) do
	        	if v.IDString == proId then
	        		rechargeInfo = v
	        		break
	        	end
	        end
	        if rechargeInfo == nil then
	        	cclog("PurchaseLayer --------------------找不到对应充值物品ID")
	        	return
	        end
	        local userData =  game.LoginSDkData
	        local memo = {}
	        memo.sourcetype = PLATFORM
	        local partyName = "LOL"
	        local curSeverName = ""
	        for k,v in pairs(game.severList) do
	            if v.id == mm.data.playerinfo.qufu then
	                curSeverName = v.Name
	                break
	            end
        	end

	        local info = {}
	        info.proId = rechargeInfo.IDString
	        info.appUserId = mm.data.playerinfo.id
	        info.sdkUserId = userData.uid
	        info.price = rechargeInfo.RMB
	        info.proName = rechargeInfo.Name
			info.goodsCount = 1
	        info.roleId = mm.data.playerinfo.id
	        info.roleName = mm.data.playerinfo.nickname
	        info.roleLevel = mm.data.playerinfo.level
	        info.memo = json.encode(memo)
	        info.orderId = ""
	        info.areaId = mm.data.playerinfo.qufu
	        info.balance = mm.data.playerinfo.diamond
	        info.roleVipLevel = mm.data.playerinfo.viplevel
	        info.partyName = partyName
	        info.serverName = curSeverName
			info.param = ""
	        
	        local infoRes = json.encode(info)
        	SDKUtil:payment(infoRes)
        elseif PLATFORM == "appstore" then
            --[[
            // 支付传递json的key
            public static final String pay_arg_param = "param"; // 额外参数
            public static final String pay_arg_pro_id = "proId"; // 产品ID
            public static final String pay_arg_app_user_id = "appUserId"; // 我们游戏的唯一标识（帐号）
            public static final String pay_arg_sdk_user_id = "sdkUserId"; // sdk的唯一标识（帐号）
            public static final String pay_arg_price = "price"; // 产品价格
            public static final String pay_arg_pro_name = "proName"; // 产品名称
            public static final String pay_arg_goods_count = "goodsCount"; // 物品数量
            public static final String pay_arg_role_id = "roleId"; // 角色id
            public static final String pay_arg_role_name = "roleName"; // 角色名
            public static final String pay_arg_role_level = "roleLevel"; // 角色等级
            public static final String pay_arg_memo = "memo"; // 透传信息
            public static final String pay_arg_order_id = "orderId";// 订单ID
            public static final String pay_arg_area_id = "areaId"; // 大区ID
            
            public static final String pay_arg_balance = "balance";// 账户余额
            public static final String pay_arg_role_vip_level = "roleVipLevel";// 等级vip等级
            public static final String pay_arg_party_name = "partyName";// 工会名字
            public static final String pay_arg_server_name = "serverName";// 所在服务器  
            --]]
            local proId = widget.proId
            local rechargeList = INITLUA:getRechargeRes()
            local rechargeInfo = nil
            for k,v in pairs(rechargeList) do
                if v.IDString == proId then
                    rechargeInfo = v
                    break
                end
            end
            if rechargeInfo == nil then
                cclog("PurchaseLayer --------------------找不到对应充值物品ID")
                return
            end
            local userData =  game.LoginSDkData
            local memo = {}
            memo.sourcetype = PLATFORM
            local partyName = "LOL"
            local curSeverName = ""
            for k,v in pairs(game.severList) do
                if v.id == mm.data.playerinfo.qufu then
                    curSeverName = v.Name
                    break
                end
            end

            local info = {}
            info.proId = rechargeInfo.IDString
            info.appUserId = mm.data.playerinfo.id
            info.sdkUserId = userData.uid
            info.price = rechargeInfo.RMB
            info.proName = rechargeInfo.Name
            info.goodsCount = 1
            info.roleId = mm.data.playerinfo.id
            info.roleName = mm.data.playerinfo.nickname
            info.roleLevel = mm.data.playerinfo.level
            info.memo = json.encode(memo)
            info.orderId = ""
            info.areaId = mm.data.playerinfo.qufu
            info.balance = mm.data.playerinfo.diamond
            info.roleVipLevel = mm.data.playerinfo.viplevel
            info.partyName = partyName
            info.serverName = curSeverName
            info.param = ""
            
            local infoRes = json.encode(info)
            SDKUtil:payment(infoRes)
            --todo
        else--if PLATFORM == "xyzs" or PLATFORM == "itools" then
            local proId = widget.proId
            local rechargeList = INITLUA:getRechargeRes()
            local rechargeInfo = nil
            for k,v in pairs(rechargeList) do
                if v.IDString == proId then
                    rechargeInfo = v
                    break
                end
            end
            if rechargeInfo == nil then
                cclog("PurchaseLayer --------------------找不到对应充值物品ID")
                return
            end
            local userData =  game.LoginSDkData
            local memo = {}
            memo.sourcetype = PLATFORM
            local partyName = "LOL"
            local curSeverName = ""
            for k,v in pairs(game.severList) do
                if v.id == mm.data.playerinfo.qufu then
                    curSeverName = v.Name
                    break
                end
            end

            -- local info = {}
            -- info.proId = rechargeInfo.IDString
            -- info.appUserId = mm.data.playerinfo.id
            -- info.sdkUserId = userData.uid
            -- info.price = rechargeInfo.RMB
            -- info.proName = rechargeInfo.Name
            -- info.goodsCount = 1
            -- info.roleId = mm.data.playerinfo.id
            -- info.roleName = mm.data.playerinfo.nickname
            -- info.roleLevel = mm.data.playerinfo.level
            -- info.memo = json.encode(memo)
            -- info.orderId = ""
            -- info.areaId = mm.data.playerinfo.qufu
            -- info.balance = mm.data.playerinfo.diamond
            -- info.roleVipLevel = mm.data.playerinfo.viplevel
            -- info.partyName = partyName
            -- info.serverName = curSeverName
            -- info.param = ""
            
            -- local infoRes = json.encode(info)
            -- SDKUtil:payment(infoRes)

            mm.req("getOrderInfo",{type = 1, proId = rechargeInfo.IDString})
        --else
        	
        end
    end
end

return PurchaseLayer