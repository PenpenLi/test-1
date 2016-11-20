local GoodsShowLayer = class("GoodsShowLayer", require("app.views.mmExtend.LayerBase"))
GoodsShowLayer.RESOURCE_FILENAME = "GoodsShowLayer.csb"

function GoodsShowLayer:onCreate(param)
    self.Node = self:getResourceNode()
    self.id = param.id

    local backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(backBtn)

    self.EquipmentBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_EquipmentBtn")
    self.EquipmentBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.EquipmentBtn)

    if param.type == 1 then -- 装备
    	self:initEquip()
    elseif param.type == 2 then -- 魂石
    	self:initHunshi()
    elseif param.type == 3 then -- 道具
    	self:initItem()
    elseif param.type == 4 then -- 皮肤
    	self:initSkin()
    end


    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function GoodsShowLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
    end
end

function GoodsShowLayer:initEquip()
	local equipRes = INITLUA:getEquipByid( self.id )

	self.Node:getChildByName("Image_bg"):getChildByName("Text_name"):setText(equipRes.Name)
	local equipItem = gameUtil.createEquipItem(self.id, 0)
	self.Node:getChildByName("Image_bg"):getChildByName("Image_icon"):addChild(equipItem)

    local shuxingTab = {}
    if math.ceil(equipRes.eq_gongji) ~= 0 then
        table.insert(shuxingTab, "攻击力："..math.ceil(equipRes.eq_gongji))
    end
    if math.ceil(equipRes.eq_shenming) ~= 0 then
        table.insert(shuxingTab, "生命值："..math.ceil(equipRes.eq_shenming))
    end
    if math.ceil(equipRes.eq_sudu) ~= 0 then
        table.insert(shuxingTab, "速度："..math.ceil(equipRes.eq_sudu))
    end
    if math.ceil(equipRes.eq_duosan) ~= 0 then
        table.insert(shuxingTab, "闪避："..math.ceil(equipRes.eq_duosan))
    end
    if math.ceil(equipRes.eq_crit) ~= 0 then
        table.insert(shuxingTab, "暴击概率："..string.format("%0.2f",(equipRes.eq_crit)).."%")
    end
    if math.ceil(equipRes.eq_hujia) ~= 0 then
        table.insert(shuxingTab, "护甲："..math.ceil(equipRes.eq_hujia))
    end
    if math.ceil(equipRes.eq_mokang) ~= 0 then
        table.insert(shuxingTab, "魔抗："..math.ceil(equipRes.eq_mokang))
    end
    local image_bg = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01")
    for i=1, 4 do
        image_bg:getChildByName("Text_0"..i):setVisible(false)
    end
    for i=1, #shuxingTab do
        if i <= 4 then
            image_bg:getChildByName("Text_0"..i):setString(shuxingTab[i])
            image_bg:getChildByName("Text_0"..i):setVisible(true)
        end
    end
end

function GoodsShowLayer:initHunshi()
	local equipRes = INITLUA:getEquipByid( self.id )
	self.Node:getChildByName("Image_bg"):getChildByName("Text_name"):setText(equipRes.Name)
	local equipItem = gameUtil.createEquipItem(self.id, 0)
	self.Node:getChildByName("Image_bg"):getChildByName("Image_icon"):addChild(equipItem)
	local image_bg1 = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01")
	local image_bg2 = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg02")
	image_bg1:setVisible(false)
	image_bg2:setVisible(true)

	image_bg2:getChildByName("Text_1"):setString(equipRes.eqsrc)
end

function GoodsShowLayer:initItem()
	local equipRes = INITLUA:getItemByid( self.id )
	self.Node:getChildByName("Image_bg"):getChildByName("Text_name"):setText(equipRes.Name)
	local equipItem = gameUtil.createItemWidget(self.id, 0)
	self.Node:getChildByName("Image_bg"):getChildByName("Image_icon"):addChild(equipItem)
	local image_bg1 = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01")
	local image_bg2 = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg02")
	image_bg1:setVisible(false)
	image_bg2:setVisible(true)

	image_bg2:getChildByName("Text_1"):setString(equipRes.itemsrc)
end

function GoodsShowLayer:initSkin()
	local equipRes = INITLUA:getResWithId( "skin", self.id )
	self.Node:getChildByName("Image_bg"):getChildByName("Text_name"):setText(equipRes.Name)
	self.Node:getChildByName("Image_bg"):getChildByName("Image_icon"):loadTexture(equipRes.Icon..".png")
	local shuxingTab = {}
    if math.ceil(equipRes.eq_gongji) ~= 0 then
        table.insert(shuxingTab, "攻击力："..math.ceil(equipRes.eq_gongji))
    end
    if math.ceil(equipRes.eq_shenming) ~= 0 then
        table.insert(shuxingTab, "生命值："..math.ceil(equipRes.eq_shenming))
    end
    if math.ceil(equipRes.eq_sudu) ~= 0 then
        table.insert(shuxingTab, "速度："..math.ceil(equipRes.eq_sudu))
    end
    if math.ceil(equipRes.eq_duosan) ~= 0 then
        table.insert(shuxingTab, "闪避："..math.ceil(equipRes.eq_duosan))
    end
    if math.ceil(equipRes.eq_crit) ~= 0 then
        table.insert(shuxingTab, "暴击概率："..string.format("%0.2f",(equipRes.eq_crit)).."%")
    end
    if math.ceil(equipRes.eq_hujia) ~= 0 then
        table.insert(shuxingTab, "护甲："..math.ceil(equipRes.eq_hujia))
    end
    if math.ceil(equipRes.eq_mokang) ~= 0 then
        table.insert(shuxingTab, "魔抗："..math.ceil(equipRes.eq_mokang))
    end
    local image_bg = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01")
    for i=1, 4 do
        image_bg:getChildByName("Text_0"..i):setVisible(false)
    end
    for i=1, #shuxingTab do
        if i <= 4 then
            image_bg:getChildByName("Text_0"..i):setString(shuxingTab[i])
            image_bg:getChildByName("Text_0"..i):setVisible(true)
        end
    end
end

function GoodsShowLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function GoodsShowLayer:onEnter()
    
end

function GoodsShowLayer:onExit()
    
end

function GoodsShowLayer:onEnterTransitionFinish()
    
end

function GoodsShowLayer:onExitTransitionStart()
    
end

function GoodsShowLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return GoodsShowLayer