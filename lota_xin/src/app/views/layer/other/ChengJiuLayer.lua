local ChengJiuLayer = class("ChengJiuLayer", require("app.views.mmExtend.LayerBase"))
ChengJiuLayer.RESOURCE_FILENAME = "Bagchengjiu.csb"
local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")

function ChengJiuLayer:onCreate(param)
	self.param = param
	self.scene = self.param.scene
	self.Node = self:getResourceNode()
	-- 按钮任务
	self.taskBtn = self.Node:getChildByName("Button_yinxiong")
	self.taskBtn:addTouchEventListener(handler(self, self.taskBtnCbk))
	-- 按钮成就
	self.chengjiuBtn = self.Node:getChildByName("Button_zhuangbei")
	self.chengjiuBtn:addTouchEventListener(handler(self, self.chengjiuBtnCbk))

	local taskLayer = cc.CSLoader:createNode("BagchengjiuLayer.csb")
	if self.ContentLayer then
		self.ContentLayer:removeFromParent()
	end
	self.ContentLayer = taskLayer
	self.ContentLayer:getChildByName("Image_1"):getChildByName("Text"):setVisible(false)
	
	self.ListView = self.ContentLayer:getChildByName("ListView")
	self:addChild(taskLayer)
	local size = cc.Director:getInstance():getWinSize()
	taskLayer:setContentSize(cc.size(size.width, size.height))
	ccui.Helper:doLayout(taskLayer)

	-- 关闭按钮
	self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
	self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
	gameUtil.setBtnEffect(self.backBtn)

	self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ChengJiuLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getTaskInfo" then
            self:GetTaskBack(event.t)
        elseif event.code == "getTaskReward" then
            self:GetTaskRewardBack(event.t)
            gameUtil.playUIEffect( "Reward_Get" )
        end
    end
    if event.name == EventDef.UI_MSG then
        if event.code == "LingQu" then
			self:updateLayer()
			--[[
			if self.curLayerName == "Task" then
				self:initTaskUI()
			else
				self:initChengJiuUI()
			end
			--]]
		elseif event.code == "refreshTaskInfo" then
			if self.curLayerName == "Task" then
				self:initTaskUI()
			elseif self.curLayerName == "ChengJiu" then
				self:initChengJiuUI()
			else
				self:initTaskUI()
			end
		end
    end
end

function ChengJiuLayer:onEnter()
	if self.param.typeLayer == 1 and gameUtil.isFunctionOpen(closeFuncOrder.TASK_NORMAL) == false then
		self.param.typeLayer = 2
	elseif self.param.typeLayer == 2 and gameUtil.isFunctionOpen(closeFuncOrder.TASK_DAILY) == false then
		self.param.typeLayer = 1
	end
	if self.param.typeLayer == 2 then
		self:initTaskUI()
	elseif self.param.typeLayer == 1 then
		self:initChengJiuUI()
	end
end

function ChengJiuLayer:onExit()
	
end

function ChengJiuLayer:taskBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
    	if gameUtil.isFunctionOpen(closeFuncOrder.TASK_DAILY) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        self:initTaskUI()
    end
end

function ChengJiuLayer:chengjiuBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
    	if gameUtil.isFunctionOpen(closeFuncOrder.TASK_NORMAL) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        self:initChengJiuUI()

        self.ContentLayer:getChildByName("Image_1"):getChildByName("Text"):setVisible(false)
    end
end

function ChengJiuLayer:initTaskUI( ... )
	self.classify = 2
	mm.req("getTaskInfo",{getType=1, getClassify = 1})
    
	--设置按钮状态
	self:setBtn(self.taskBtn)
	self.curLayerName = "Task"
end

function ChengJiuLayer:GetTaskBack( event )
	local taskInfo = event.taskInfo or {}
	mm.data.playerTask = {}
	for k,v in pairs(taskInfo) do
		mm.data.playerTask[k] = v
	end
	-- 任务进度
	mm.data.playerTaskProc = event.taskProc

	self:showTask()
	performWithDelay(self, function( ... )
        self.ContentLayer:getChildByName("ListView"):jumpToTop()
    end, 0.01)
end

function ChengJiuLayer:showTask( ... )
	local taskRes = INITLUA:getTaskRes()
	self.allshowTask = {}
	for k,v in pairs(taskRes) do
		if v.TaskClassify == self.classify and gameUtil.CanShow(v) then
			table.insert(self.allshowTask, v)
		end
	end

	if self.curLayerName == "Task" then
		if #self.allshowTask > 0 then
			self.ContentLayer:getChildByName("Image_1"):getChildByName("Text"):setVisible(false)
		else
			self.ContentLayer:getChildByName("Image_1"):getChildByName("Text"):setVisible(true)
		end 
	end

	local function sortShowFun( a, b )
        if a.ID < b.ID then
            return true
        else
            return false
        end
    end
    table.sort(self.allshowTask, sortShowFun)

    local tampAllShow = {}
    for k,v in pairs(self.allshowTask) do
        local aProgress = gameUtil.GetTaskProgress(v)
        local taskConditionValue = v.TaskConditionValue

        local finish = false
		if v.TaskType == MM.ETaskType.TT_RankLevel then
			if aProgress <= taskConditionValue and aProgress ~= 0 then
				finish = true
			end
		else
			if aProgress >= taskConditionValue then
				finish = true
			end
		end

        if finish == true then 
            table.insert(tampAllShow,1,v)
        else
            table.insert(tampAllShow,v)
        end
    end
    self.allshowTask = tampAllShow
    self.ListView:removeAllItems()
	for k,v in pairs(self.allshowTask) do
    	local taskItem = self:SetItem(v)
    	taskItem:getChildByName("Image_bg"):setTouchEnabled(false)
	    local custom_item = ccui.Layout:create()
	    custom_item:setTag(v.ID)
	    
	    custom_item:addChild(taskItem)
	    custom_item:setContentSize(taskItem:getContentSize())
	    custom_item:setTouchEnabled(true)
	    local aProgress = gameUtil.GetTaskProgress(v)

	    local finish = false
		if v.TaskType == MM.ETaskType.TT_RankLevel then
			if aProgress <= v.TaskConditionValue and aProgress ~= 0 then
				finish = true
			end
		else
			if aProgress >= v.TaskConditionValue then
				finish = true
			end
		end

		if finish == true then
			custom_item:addTouchEventListener(handler(self, self.getRewardCbk))
		end
	    self.ListView:pushBackCustomItem(custom_item)

	end


end

function ChengJiuLayer:SetItem( v )
	local aProgress = gameUtil.GetTaskProgress(v)
	local taskItem = nil

	local finish = false
	if v.TaskType == MM.ETaskType.TT_RankLevel then
		if aProgress <= v.TaskConditionValue and aProgress ~= 0 then
			finish = true
		end
	else
		if aProgress >= v.TaskConditionValue then
			finish = true
		end
	end
	
	if finish == true then
		taskItem = cc.CSLoader:createNode("chengjiuYesItem.csb")
	else
		taskItem = cc.CSLoader:createNode("chengjiuNOitem1.csb")
		gameUtil.setBtnEffect(taskItem:getChildByName("Button_1"))
		if v.TaskType == MM.ETaskType.TT_IDLV or v.TaskType == MM.ETaskType.TT_KillSFCount or 
			v.TaskType == MM.ETaskType.TT_KillTimoCount or v.TaskType == MM.ETaskType.TT_Zhanli then
			taskItem:getChildByName("Button_1"):setVisible(false)
		else
			taskItem:getChildByName("Button_1"):addTouchEventListener(handler(self, self.gotoBtnCbk))
		end
		taskItem:getChildByName("Button_1"):setTag(v.ID)
		
		if v.TaskType == MM.ETaskType.TT_RankLevel then
			if aProgress == 0 then
				taskItem:getChildByName("Text_lingqu"):setString("无")
			else
				taskItem:getChildByName("Text_lingqu"):setString(aProgress)
			end
		elseif v.TaskType == 9 then
			taskItem:getChildByName("Text_lingqu"):setString("未完成")
		else
			taskItem:getChildByName("Text_lingqu"):setString(aProgress.."/"..v.TaskConditionValue)
		end
	end
	taskItem:setTag(v.ID)
	local taskbiao = taskItem:getChildByName("Text_biao")
	taskbiao:setString(v.TaskName)
	local taskName = taskItem:getChildByName("Text_name")
	taskName:setString(v.TaskDes)
	taskName:setPositionX(taskbiao:getPositionX() + taskbiao:getContentSize().width + 5)
	taskItem:getChildByName("Text_exp1"):setVisible(false)
	taskItem:getChildByName("Text_exp2"):setVisible(false)
	taskItem:getChildByName("Image_2"):setVisible(false)
	taskItem:getChildByName("Image_3"):setVisible(false)
	if v.T_Exp ~= 0 then
		taskItem:getChildByName("Text_exp1"):setString(v.T_Exp)
		taskItem:getChildByName("Text_exp1"):setVisible(true)
		taskItem:getChildByName("Image_2"):loadTexture("res/UI/icon_EXPzhandui.png")
		taskItem:getChildByName("Image_2"):setVisible(true)
	end
	if v.T_ExpPool ~= 0 then
		if v.T_Exp ~= 0 then
			taskItem:getChildByName("Text_exp2"):setString(v.T_ExpPool)
			taskItem:getChildByName("Text_exp2"):setVisible(true)
			taskItem:getChildByName("Image_3"):loadTexture("res/UI/icon_EXPjingyanchi.png")
			taskItem:getChildByName("Image_3"):setVisible(true)
		else
			taskItem:getChildByName("Text_exp1"):setString(v.T_ExpPool)
			taskItem:getChildByName("Text_exp1"):setVisible(true)
			taskItem:getChildByName("Image_2"):loadTexture("res/UI/icon_EXPjingyanchi.png")
			taskItem:getChildByName("Image_2"):setVisible(true)
		end
	end

	local jinbi = false
	local zuanshi = false
	if mm.data.playerinfo.camp == 1 then
		local skinId = v.LolSkinID
		local index = 1
		if skinId ~= 0 then
			index = 2
			local equipItem = taskItem:getChildByName("Image_eq01")
			local skinIcon = gameUtil.createSkinIcon(skinId)
			skinIcon:setScale(equipItem:getContentSize().width/skinIcon:getContentSize().width, equipItem:getContentSize().height/skinIcon:getContentSize().height)
			equipItem:addChild(skinIcon)
		end
		for i=index,5 do
			local lol_item = "LG"..i
			local lol_num = "LGNum"..i
			local lol_type = "LGType"..i
			local iconSrc
			local pinPathRes
			if v[lol_item] ~= 0 then
				if v[lol_type] == MM.EDropType.DT_jingyandan or v[lol_type] == MM.EDropType.DT_consumables then
					iconSrc = gameUtil.getItemIconRes(v[lol_item])
					pinPathRes = gameUtil.getEquipPinRes(INITLUA:getItemByid( v[lol_item] ).Quality)
				else
					iconSrc = gameUtil.getEquipIconRes(v[lol_item])
					pinPathRes = gameUtil.getEquipPinRes(INITLUA:getEquipByid( v[lol_item] ).Quality)
				end
				local equipItem = taskItem:getChildByName("Image_eq0"..i)
				local imageView = cc.Sprite:create(iconSrc)
				imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
				if #pinPathRes > 0 then
	                local pinImgView = ccui.ImageView:create()
	                pinImgView:loadTexture(pinPathRes)
	                imageView:addChild(pinImgView)
	                pinImgView:setAnchorPoint(cc.p(0,1))
	                pinImgView:setScale(imageView:getContentSize().width/pinImgView:getContentSize().width)
	                pinImgView:setPosition(0, imageView:getContentSize().height)
	            end
				
				if v[lol_type] == MM.EDropType.DT_HunShi then
					local hunShiTag = cc.Sprite:create("res/UI/icon_hunshi.png")
	                hunShiTag:setAnchorPoint(cc.p(0, 1))
	                hunShiTag:setPosition(cc.p(1, imageView:getContentSize().height-1))
	                imageView:addChild(hunShiTag)
	                hunShiTag:setScale(imageView:getContentSize().width/hunShiTag:getContentSize().width*0.96)
	            end
	            
	            local num = v[lol_num]
	            if num > 0 then
	            	local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

	                local ttfConfig = {}
	                ttfConfig.fontFilePath = "font/youyuan.TTF"
	                ttfConfig.fontSize = 30
	                ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
	                ttfConfig.customGlyphs = nil
	                ttfConfig.distanceFieldEnabled = true
	                ttfConfig.outlineSize = 1
	                
	                local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER,300)
	                label:setAnchorPoint(cc.p(1,0))
	                label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
	                label:setTextColor( cc.c4b(255, 255, 255, 255) )
	                label:enableGlow(cc.c4b(255, 255, 0, 255))
	                imageView:addChild(label)
	                label:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
	                local scaleX = label:getBoundingBox().width / sprite_ditu:getContentSize().width
	                local scaleY = label:getBoundingBox().height / sprite_ditu:getContentSize().height
        			sprite_ditu:setScale(scaleX, scaleY)
	            end
	            imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
	            equipItem:addChild(imageView)
	        else
	        	if jinbi == false and v.T_Gold ~= 0 then
	        		local imageView = cc.Sprite:create("res/icon/jiemian/icon_jinbi.png")
		        	local equipItem = taskItem:getChildByName("Image_eq0"..i)
					imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
	        		local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

	                local ttfConfig = {}
	                ttfConfig.fontFilePath = "font/youyuan.TTF"
	                ttfConfig.fontSize = 30
	                ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
	                ttfConfig.customGlyphs = nil
	                ttfConfig.distanceFieldEnabled = true
	                ttfConfig.outlineSize = 1
	                
	                local label = cc.Label:createWithTTF(ttfConfig,v.T_Gold,cc.TEXT_ALIGNMENT_CENTER,300)
	                label:setAnchorPoint(cc.p(1,0))
	                label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
	                label:setTextColor( cc.c4b(255, 255, 255, 255) )
	                label:enableGlow(cc.c4b(255, 255, 0, 255))
	                imageView:addChild(label)
	                local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
	                local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
        			sprite_ditu:setScale(scaleX, scaleY)
        			imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
	            	equipItem:addChild(imageView)
	            	jinbi = true
        		elseif zuanshi == false and v.Ingot ~= 0 then
	        		local imageView = cc.Sprite:create("res/icon/jiemian/icon_zuanshi.png")
		        	local equipItem = taskItem:getChildByName("Image_eq0"..i)
					imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
	        		local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

	                local ttfConfig = {}
	                ttfConfig.fontFilePath = "font/youyuan.TTF"
	                ttfConfig.fontSize = 30
	                ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
	                ttfConfig.customGlyphs = nil
	                ttfConfig.distanceFieldEnabled = true
	                ttfConfig.outlineSize = 1
	                
	                local label = cc.Label:createWithTTF(ttfConfig,v.Ingot,cc.TEXT_ALIGNMENT_CENTER,300)
	                label:setAnchorPoint(cc.p(1,0))
	                label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
	                label:setTextColor( cc.c4b(255, 255, 255, 255) )
	                label:enableGlow(cc.c4b(255, 255, 0, 255))
	                imageView:addChild(label)
	                local scaleX = label:getBoundingBox().width / sprite_ditu:getContentSize().width
	                local scaleY = label:getBoundingBox().height / sprite_ditu:getContentSize().height
        			sprite_ditu:setScale(scaleX, scaleY)
        			imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
	            	equipItem:addChild(imageView)
	            	zuanshi = true
        		else
	        		taskItem:getChildByName("Image_eq0"..i):setVisible(false)
	        	end
	        end
		end
	else
		local skinId = v.DotaSkinID
		local index = 1
		if skinId ~= 0 then
			index = 2
			local equipItem = taskItem:getChildByName("Image_eq01")
			local skinIcon = gameUtil.createSkinIcon(skinId)
			skinIcon:setScale(equipItem:getContentSize().width/skinIcon:getContentSize().width, equipItem:getContentSize().height/skinIcon:getContentSize().height)
			equipItem:addChild(skinIcon)
		end
		for i=index,5 do
			local lol_item = "DG"..i
			local lol_num = "DGNum"..i
			local lol_type = "DGType"..i
			local iconSrc
			local pinPathRes
			if v[lol_item] ~= 0 then
				if v[lol_type] == MM.EDropType.DT_jingyandan or v[lol_type] == MM.EDropType.DT_consumables then
					iconSrc = gameUtil.getItemIconRes(v[lol_item])
					pinPathRes = gameUtil.getEquipPinRes(INITLUA:getItemByid( v[lol_item] ).Quality)
				else
					iconSrc = gameUtil.getEquipIconRes(v[lol_item])
					pinPathRes = gameUtil.getEquipPinRes(INITLUA:getEquipByid( v[lol_item] ).Quality)
				end
				local imageView = cc.Sprite:create(iconSrc)
				local equipItem = taskItem:getChildByName("Image_eq0"..i)
				imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
				if #pinPathRes > 0 then
	                local pinImgView = ccui.ImageView:create()
	                pinImgView:loadTexture(pinPathRes)
	                imageView:addChild(pinImgView)
	                pinImgView:setAnchorPoint(cc.p(0,1))
	                pinImgView:setScale(imageView:getContentSize().width/pinImgView:getContentSize().width)
	                pinImgView:setPosition(0, imageView:getContentSize().height)
	            end
				
				if v[lol_type] == MM.EDropType.DT_HunShi then
					local hunShiTag = cc.Sprite:create("res/UI/icon_hunshi.png")
	                hunShiTag:setAnchorPoint(cc.p(0, 1))
	                hunShiTag:setPosition(cc.p(2, imageView:getContentSize().height-2))
	                imageView:addChild(hunShiTag)
	                hunShiTag:setScale(imageView:getContentSize().width/hunShiTag:getContentSize().width*0.96)
	            end

	            local num = v[lol_num]
	            if num > 0 then
	            	local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

	                local ttfConfig = {}
	                ttfConfig.fontFilePath = "font/youyuan.TTF"
	                ttfConfig.fontSize = 30
	                ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
	                ttfConfig.customGlyphs = nil
	                ttfConfig.distanceFieldEnabled = true
	                ttfConfig.outlineSize = 1
	                
	                local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER,300)
	                label:setAnchorPoint(cc.p(1,0))
	                label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
	                label:setTextColor( cc.c4b(255, 255, 255, 255) )
	                label:enableGlow(cc.c4b(255, 255, 0, 255))
	               	label:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
	                imageView:addChild(label)
	                local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
	                local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
        			sprite_ditu:setScale(scaleX, scaleY)
	            end
	            imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
	            equipItem:addChild(imageView)
	        else
	        	if jinbi == false and v.T_Gold ~= 0 then
	        		local imageView = cc.Sprite:create("res/icon/jiemian/icon_jinbi.png")
		        	local equipItem = taskItem:getChildByName("Image_eq0"..i)
					imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
	        		local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

	                local ttfConfig = {}
	                ttfConfig.fontFilePath = "font/youyuan.TTF"
	                ttfConfig.fontSize = 30
	                ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
	                ttfConfig.customGlyphs = nil
	                ttfConfig.distanceFieldEnabled = true
	                ttfConfig.outlineSize = 1
	                
	                local label = cc.Label:createWithTTF(ttfConfig,v.T_Gold,cc.TEXT_ALIGNMENT_CENTER,300)
	                label:setAnchorPoint(cc.p(1,0))
	                label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
	                label:setTextColor( cc.c4b(255, 255, 255, 255) )
	                label:enableGlow(cc.c4b(255, 255, 0, 255))
	                imageView:addChild(label)
	                local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
	                local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
        			sprite_ditu:setScale(scaleX, scaleY)
        			imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
	            	equipItem:addChild(imageView)
	            	jinbi = true
        		elseif zuanshi == false and v.Ingot ~= 0 then
	        		local imageView = cc.Sprite:create("res/icon/jiemian/icon_zuanshi.png")
		        	local equipItem = taskItem:getChildByName("Image_eq0"..i)
					imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
	        		local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

	                local ttfConfig = {}
	                ttfConfig.fontFilePath = "font/youyuan.TTF"
	                ttfConfig.fontSize = 30
	                ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
	                ttfConfig.customGlyphs = nil
	                ttfConfig.distanceFieldEnabled = true
	                ttfConfig.outlineSize = 1
	                
	                local label = cc.Label:createWithTTF(ttfConfig,v.Ingot,cc.TEXT_ALIGNMENT_CENTER,300)
	                label:setAnchorPoint(cc.p(1,0))
	                label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
	                label:setTextColor( cc.c4b(255, 255, 255, 255) )
	                label:enableGlow(cc.c4b(255, 255, 0, 255))
	                imageView:addChild(label)
	                local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
	                local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
        			sprite_ditu:setScale(scaleX, scaleY)
        			imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
	            	equipItem:addChild(imageView)
	            	zuanshi = true
        		else
	        		taskItem:getChildByName("Image_eq0"..i):setVisible(false)
	        	end
	        end
		end
	end
	return taskItem
end

function ChengJiuLayer:initChengJiuUI( ... )
	self.classify = 1
	mm.req("getTaskInfo",{getType=1, getClassify = 2})
	
	--设置按钮状态
	self:setBtn(self.chengjiuBtn)
	self.curLayerName = "ChengJiu"
end

function ChengJiuLayer:setBtn( btn )
    
    self.chengjiuBtn:setBright(true)
    self.taskBtn:setBright(true)

    self.chengjiuBtn:setEnabled(true)
    self.taskBtn:setEnabled(true)

    btn:setBright(false)
    btn:setEnabled(false)

end

function ChengJiuLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function ChengJiuLayer:getRewardCbk(widget,touchkey)
	if touchkey == ccui.TouchEventType.ended then
        mm.req("getTaskReward", {getType = 1, taskId = widget:getTag()})
    end
end

function ChengJiuLayer:GetTaskRewardBack( event )
	if event.type == 0 then
		table.insert(mm.data.playerTask, event.taskInfo)
		self.curTaskInfo = event.taskInfo or {}
		mm.data.playerinfo = event.playerInfo or {}
		mm.data.playerEquip = event.playerEquip or {}
		mm.data.playerHunshi = event.playerHunshi or {}
		mm.data.playerItem = event.playerItem or {}
		game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshMainUI"})
		--self:updateLayer()
		local LingQuLayer = require("src.app.views.layer.LingQuLayer").new({app = self.param.app, tab = event.taskInfo})
        self:addChild(LingQuLayer)

        mm.GuildScene:upPlayerLv()
		
	elseif event.type == 2 then
		gameUtil:addTishi({p = self, s = "已领取"})
	elseif event.type == 3 then 
		gameUtil:addTishi({p = self, s = "标资源错误"})
	elseif event.type == 4 then 
		gameUtil:addTishi({p = self, s = MoGameRet[990047]})
	else
		gameUtil:addTishi({p = self, s = "数据库错误"})
	end
end

function ChengJiuLayer:gotoBtnCbk(widget,touchkey)
	if touchkey == ccui.TouchEventType.ended then
        local curTaskRes = INITLUA:getTaskResById( widget:getTag() )
        if curTaskRes.TaskType == MM.ETaskType.TT_HeroCount or curTaskRes.TaskType == MM.ETaskType.TT_HeroCount or
        	curTaskRes.TaskType == MM.ETaskType.TQ_HeroLevelUp or curTaskRes.TaskType == MM.ETaskType.TQ_Quaility or
        	curTaskRes.TaskType == MM.ETaskType.TQ_SkillLevelUp or curTaskRes.TaskType == MM.ETaskType.Daily_SkillLevelUp then -- 跳转到英雄列表
        	gameUtil:goToSomeWhere( self.scene, "HeroListLayer", {app = self.param.app})
        elseif curTaskRes.TaskType == MM.ETaskType.TT_StarLv or curTaskRes.TaskType == MM.ETaskType.TQ_StarUp then -- 跳转到英雄升星界面
        	local heroId = gameUtil.GetStarMaxHeroId()
        	gameUtil:goToSomeWhere( self, "HeroLayer", {app = self.param.app, heroId = heroId, LayerTag = 3})
        elseif curTaskRes.TaskType == MM.ETaskType.TT_Level then -- 跳转到英雄升级界面
        	local heroId = gameUtil.GetLevelMaxHeroId()
        	gameUtil:goToSomeWhere( self, "HeroLayer", {app = self.param.app, heroId = heroId, LayerTag = 1})
        elseif curTaskRes.TaskType == MM.ETaskType.TT_Quality then -- 跳转到英雄升级界面
        	local heroId = gameUtil.GetQualityMaxHeroId()
        	gameUtil:goToSomeWhere( self, "HeroLayer", {app = self.param.app, heroId = heroId, LayerTag = 1})
        elseif curTaskRes.TaskType == MM.ETaskType.TT_PK or
        		curTaskRes.TaskType == MM.ETaskType.TQ_Plunder or curTaskRes.TaskType == MM.ETaskType.TQ_Battle or
        		curTaskRes.TaskType == MM.ETaskType.TQ_Chanllenge or curTaskRes.TaskType == MM.ETaskType.TT_Win then -- 跳转到PK界面
        	gameUtil:goToSomeWhere(self, "StageDetailLayer", {app = self.param.app, type = 1})
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_ExpPoor then -- 跳转到买经验界面
        	gameUtil:goToSomeWhere( self, "BuyExp")
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_BuyGold then -- 跳转到点金手界面
        	gameUtil:goToSomeWhere( self, "BuyGold")
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_GoldFinger then -- 跳转到主界面
        	gameUtil:goToSomeWhere( self, "Main", {})
        elseif curTaskRes.TaskType == MM.ETaskType.TT_RankLv then -- 跳转到天梯界面
        	gameUtil:goToSomeWhere( self, "Rank", {app = self.param.app})
        elseif curTaskRes.TaskType == MM.ETaskType.TT_RankLv or curTaskRes.TaskType == MM.ETaskType.TQ_Month or
        	curTaskRes.TaskType == MM.ETaskType.TQ_ExMonth then
        	gameUtil:goToSomeWhere( self, "recharge", {app = self.param.app})
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_Lound then
        	gameUtil:goToSomeWhere(self, "talk", {app = self.param.app})
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_Saodang then
        	gameUtil:goToSomeWhere(self, "StageDetailLayer", {app = self.param.app, type = 1})
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_Wumian then
        	gameUtil:goToSomeWhere(self, "StageDetailLayer", {app = self.param.app, type = 2})
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_Momian then
        	gameUtil:goToSomeWhere(self, "StageDetailLayer", {app = self.param.app, type = 3})
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_BuyEquip or curTaskRes.TaskType == MM.ETaskType.Daily_BuyEquip then
        	gameUtil:goToSomeWhere(self, "ShangChengLayer", {app = self.param.app})
        elseif curTaskRes.TaskType == MM.ETaskType.TT_RankLevel then
        	gameUtil:goToSomeWhere(self, "JJCLayer", {app = self.param.app})
        elseif curTaskRes.TaskType == MM.ETaskType.TQ_Attack then
        	gameUtil:goToSomeWhere(self, "PVPLayer", {app = self.param.app})
        else

        end
    end
end

function ChengJiuLayer:updateLayer( ... )
	local x = 1
	for k,v in pairs(self.allshowTask) do
		if self.curTaskInfo.taskId == v.ID then
			self.ContentLayer:getChildByName("ListView"):getChildByTag(v.ID):removeFromParent()
			v = nil
			break
		end
		x = x + 1
	end
	table.remove(self.allshowTask, x)
	local taskRes = INITLUA:getTaskRes()
	local flag = false
	local curTask = INITLUA:getTaskResById(self.curTaskInfo.taskId)
	for k,v in pairs(taskRes) do
		if v.TaskType == curTask.TaskType then
			if gameUtil.CanShow(v) then
				curTask = v
				flag = true
				break
			end
		end
	end
	if flag then
		local aProgress = gameUtil.GetTaskProgress(curTask)
		
		local finish = false
		if curTask.TaskType == MM.ETaskType.TT_RankLevel then
			if aProgress <= curTask.TaskConditionValue and aProgress ~= 0 then
				finish = true
			end
		else
			if aProgress >= curTask.TaskConditionValue then
				finish = true
			end
		end

		if finish == true then
			table.insert(self.allshowTask, x, curTask)
		else
			table.insert(self.allshowTask, #self.allshowTask+1, curTask)
		end
    	local taskItem = self:SetItem(curTask)
    	taskItem:getChildByName("Image_bg"):setTouchEnabled(false)
        local custom_item = ccui.Layout:create()
        custom_item:setTag(curTask.ID)
        custom_item:addChild(taskItem)
        custom_item:setContentSize(taskItem:getContentSize())
        custom_item:setTouchEnabled(true)
        if finish == true then
        	self.ContentLayer:getChildByName("ListView"):insertCustomItem(custom_item, x)
        	custom_item:addTouchEventListener(handler(self, self.getRewardCbk))
		else
        	self.ContentLayer:getChildByName("ListView"):insertCustomItem(custom_item, #self.allshowTask-1)
        end
        self.ContentLayer:getChildByName("ListView"):jumpToTop()
    end

    if self.curLayerName == "Task" then
	    if #self.allshowTask > 0 then
			self.ContentLayer:getChildByName("Image_1"):getChildByName("Text"):setVisible(false)
		else
			self.ContentLayer:getChildByName("Image_1"):getChildByName("Text"):setVisible(true)
		end
	else
		self.ContentLayer:getChildByName("Image_1"):getChildByName("Text"):setVisible(false)
	end
end

function ChengJiuLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return ChengJiuLayer