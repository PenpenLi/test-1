local ShangChengLayer = class("ShangChengLayer", require("app.views.mmExtend.LayerBase"))
ShangChengLayer.RESOURCE_FILENAME = "ShangchengLayer.csb"
local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")


function ShangChengLayer:onEnter()
	mm.req("getStoreInfo",{type = 0})

	if mm.lastStoreInfo ~= nil then
		self:updateLayer(nil, mm.lastStoreInfo, true)
	end

    

end

function ShangChengLayer:onExit()
	
end

function ShangChengLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function ShangChengLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ShangChengLayer:init(param)
	self.buttons = {}

	self.param = param
	self.scene = self.param.scene

    local openHint = true
    if param.typeLayer then
        if self.param.typeLayer == 1 then
            if gameUtil.isFunctionOpen(closeFuncOrder.SHOP_NORMAL) == true then
                openHint = false
            end
        elseif self.param.typeLayer == 2 then
            if gameUtil.isFunctionOpen(closeFuncOrder.SHOP_HONOR) == true then
                openHint = false
            end
        elseif self.param.typeLayer == 3 then
            if gameUtil.isFunctionOpen(closeFuncOrder.SHOP_HEIDIAN) == true then
                openHint = false
            end
        end
    else
        if gameUtil.isFunctionOpen(closeFuncOrder.SHOP_NORMAL) == true then
            self.param.typeLayer = 1
            openHint = false
        elseif gameUtil.isFunctionOpen(closeFuncOrder.SHOP_HONOR) == true then
            self.param.typeLayer = 2
            openHint = false
        elseif gameUtil.isFunctionOpen(closeFuncOrder.SHOP_HEIDIAN) == true then
            self.param.typeLayer = 3
            openHint = false
        end
    end

    if openHint == true then
        gameUtil:addTishi({s = MoGameRet[990047]})
        mm:popLayer()
        return
    end

	mm.app.clientTCP:addEventListener("autoRefreshStoreInfo",mm.autoRefreshStoreInfo)

	self.Node = self:getResourceNode()

	local baseNode = self.Node:getChildByName("Image_bg")
	-- 按钮
	self.storeBtn = baseNode:getChildByName("Button_yinxiong")
	self.storeBtn.storeName = "商店"
	self.storeBtn:addTouchEventListener(handler(self, self.storeBtnCbk))
	self.storeBtn:setTag(1)
	self.buttons[1] = self.storeBtn
	-- 按钮
	self.zhuangbeiBtn = baseNode:getChildByName("Button_zhuangbei")
	self.zhuangbeiBtn:addTouchEventListener(handler(self, self.storeBtnCbk))
	self.zhuangbeiBtn:setTag(2)
	self.buttons[2] = self.zhuangbeiBtn

	self.hunshiBtn = baseNode:getChildByName("Button_hunshi")
	self.hunshiBtn:addTouchEventListener(handler(self, self.storeBtnCbk))
	self.hunshiBtn:setTag(3)
	self.buttons[3] = self.hunshiBtn

	self.xiaohaoBtn = baseNode:getChildByName("Button_xiaohao")
	self.xiaohaoBtn:addTouchEventListener(handler(self, self.storeBtnCbk))
	self.xiaohaoBtn:setTag(4)
	self.buttons[4] = self.xiaohaoBtn

	for k,v in pairs(self.buttons) do
		v:setVisible(false)
	end

	-- 关闭按钮
	self.backBtn = baseNode:getChildByName("Button_back")
	gameUtil.setBtnEffect(self.backBtn)
	self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
end

function ShangChengLayer:checkOpenCondition( ID )
	local shopRes = INITLUA:getShopListRes()
	for k,v in pairs(shopRes) do
		if v.ID == ID then
			if v.OpenCondition == 1 then --无条件开放
				return true
			elseif v.OpenCondition == 2 then --VIP开放
				return mm.data.playerinfo.vipexp > v.OCNum 
			end
			break
		end
	end
	return false
end

function ShangChengLayer:storeBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
    	local order = closeFuncOrder.SHOP_ENTER
    	if widget:getTag() == 1 then
    		order = closeFuncOrder.SHOP_NORMAL
    	elseif widget:getTag() == 2 then
    		order = closeFuncOrder.SHOP_HONOR
    	elseif widget:getTag() == 3 then
    		order = closeFuncOrder.SHOP_HEIDIAN
    	end
    	
    	if gameUtil.isFunctionOpen(order) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        self:initStore(widget, false)
    end
end

function ShangChengLayer:initStore( widget, recordTime )
	
	local info = nil
	for i,v in pairs(self.buttons) do
		if widget:getTag() == self.buttons[i]:getTag() then
			info = self.storeInfo[i]
		end
	end


	
	local currentParam = info
	local storeLayer = require("src.app.views.layer.StoreLayer").new({scene = self, param = currentParam, needRecordTime = recordTime})
	if self.ContentLayer then
		self.ContentLayer:removeFromParent()
	end
	self.ContentLayer = storeLayer
	self:addChild(storeLayer)
	local size = cc.Director:getInstance():getWinSize()
	storeLayer:setContentSize(cc.size(size.width, size.height))
	ccui.Helper:doLayout(storeLayer)


	
	--设置按钮状态
	self:setBtn(widget)
	self.curLayerName = "Store"
end

function ShangChengLayer:setBtn( btn )
	for k,v in pairs(self.buttons) do
		v:setBright(true)
		v:setEnabled(true)
	end
    btn:setBright(false)
    btn:setEnabled(false)
end

function ShangChengLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function ShangChengLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
    	if event.code == "getStoreInfo" then
            --event.t
            if event.t.type == 0 then
            	mm.lastStoreInfo = event.t.storeInfo
            	self:updateLayer(nil, event.t.storeInfo, true)

                if mm.GuildId == 10101 then
                    if game.storeItemBtn then
                        performWithDelay(self.ContentLayer,function( ... )
                            Guide:startGuildById(10102, game.storeItemBtn)
                        end, 0.01)
                    else
                    end

                end

				game:dispatchEvent({name = EventDef.UI_MSG, code = "storeRefreshed"})
			end
        elseif event.code == "buySomeThing" then
        	if event.t.code == 990002 then
        		gameUtil.showDianJinShou( self, 1 )
        	elseif event.t.code == 990001 then
        		gameUtil.showChongZhi( self, 1 )
        	end
        	local payerInfo = event.t.playerinfo
            if payerInfo ~= nil then
                mm.data.playerinfo = payerInfo 
            end
        	if event.t.type ~= 0 then
        		local text = gameUtil.GetMoGameRetStr( event.t.code )
	            gameUtil:addTishi({p = self.scene, s = text, z = 1000000})
	            return
        	else
        		local text = gameUtil.GetMoGameRetStr( event.t.code )
        		gameUtil:addTishi({p = self.scene, s = text, z = 1000000})
                gameUtil.playUIEffect( "Gold_Get" )
        	end
        	mm.lastStoreInfo = event.t.storeInfo
        	self:updateLayer(event.t.buyItemInfo, event.t.storeInfo, false)

        	game:dispatchEvent({name = EventDef.UI_MSG, code = "storeRefreshed"})
        elseif event.code == "refreshStoreInfo" or event.code == "autoRefreshStoreInfo" then
            local payerInfo = event.t.playerinfo
            if payerInfo ~= nil then
                mm.data.playerinfo = payerInfo 
            end

            local playerExtra = event.t.playerExtra
            if playerExtra ~= nil then
                mm.data.playerExtra = playerExtra
            end

            local payerItem = event.t.playerItem
            if payerItem ~= nil then
                mm.data.playerItem = payerItem 
            end

            if event.t.type == 0 then
                mm.lastStoreInfo = event.t.storeInfo
                local storeInfo = event.t.storeInfo
                self:updateStoreInfo(storeInfo)

                game:dispatchEvent({name = EventDef.UI_MSG, code = "storeRefreshed"})
            end
        end
    end
end

function ShangChengLayer:updateStoreInfo( storeInfo )
--buyItemInfo.itemID
	if storeInfo == nil then
		return
	end

	self.storeInfo = {}
	local showIndexList = {}

    for i,v in ipairs(storeInfo) do
    	if storeInfo[i] == nil then
    		showIndexList[i] = 99 --不存在
    	else
    		showIndexList[i] = v.shopSort
    		gameUtil.setStoreRecordTime(storeInfo[i].storeID, os.time())
    	end
    end
    table.sort( showIndexList )

    for i,v in ipairs(showIndexList) do
    	local showIndex = showIndexList[i]
    	for i,v in pairs(storeInfo) do
    		if showIndex == 99 then
    			break
    		end
    		if v.shopSort == showIndex then
    			table.insert(self.storeInfo, v)
    			break
    		end
    	end
    end
end

function ShangChengLayer:updateLayer( buyItemInfo, storeInfo , init)
	self:updateStoreInfo(storeInfo)
	--buyItemInfo.itemID

	for k,v in pairs(self.buttons) do
		v:setVisible(false)
	end

	if self.storeInfo ~= nil then
		local shopRes = INITLUA:getShopListRes()

	    for i,v in ipairs(self.storeInfo) do
	    	local numID = util.getNumFormChar(v.storeID, 4)
	    	local name = shopRes[numID].Name
	    	self.buttons[i]:getChildByName("Text"):setString(name)
	    	self.buttons[i]:setVisible(true)
	    end
	end
    if init then
    	self:initStore(self.buttons[self.param.typeLayer], true)
    end
end

return ShangChengLayer