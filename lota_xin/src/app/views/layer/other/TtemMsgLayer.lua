

local TtemMsgLayer = class("TtemMsgLayer", require("app.views.mmExtend.LayerBase"))
TtemMsgLayer.RESOURCE_FILENAME = "TtemMsgLayer.csb"


function TtemMsgLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function TtemMsgLayer:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )

    if mm.GuildId == 10021 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10022, self.EquipmentBtn)
        end, 0.01)
    end
end

function TtemMsgLayer:onExit()

end

function TtemMsgLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function TtemMsgLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "heroUpequip" then
            self:heroUpequipBack(event.t)
        elseif event.code == "buySomeThing" then
            self:buyEquipBack(event.t)
        elseif event.code == "composeEquip" then
        	self:composeEquipBack(event.t)
        end
    end
end



function TtemMsgLayer:init(param)

    self.app = param.app
    self.eqId = param.eqId
    self.isUp = param.isUp
    self.index = param.index
    self.heroId = param.heroId

    self.Node = self:getResourceNode()
    
    -- self.Node:getChildByName("Panel_touch"):addTouchEventListener(handler(self, self.backBtnCbk))

    local iconNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_icon")
    iconNode:loadTexture(gameUtil.getEquipIconRes(self.eqId))

    local equipRes = INITLUA:getEquipByid( self.eqId )
    local pinPathRes = gameUtil.getEquipPinRes(equipRes.Quality)

    if #pinPathRes > 0 then
        local pinImgView = ccui.ImageView:create()
        pinImgView:loadTexture(pinPathRes)
        iconNode:addChild(pinImgView, 4)
        pinImgView:setAnchorPoint(cc.p(0,0))
        pinImgView:setPosition(0, 0)
        pinImgView:setScale(iconNode:getContentSize().width/pinImgView:getContentSize().width, iconNode:getContentSize().height/pinImgView:getContentSize().height)
    end

    self.Node:getChildByName("Image_bg"):getChildByName("Text_name"):setText(INITLUA:getEquipByid( self.eqId ).Name)
    local backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(backBtn)

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
    -- 装备按钮
    self.EquipmentBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_EquipmentBtn")
    gameUtil.setBtnEffect(self.EquipmentBtn)

    self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(false)
    

    if self.isUp then
        self.EquipmentBtn:setVisible(false)
    else
        if gameUtil.isHasEquip( self.eqId ) then
            self.EquipmentBtn:setTitleText("装备")
            self.EquipmentBtn:addTouchEventListener(handler(self, self.zbBtnCbk))
            self.EquipmentBtn:setTag(self.eqId)
        else
            local needNum = equipRes.eq_spnum
            local suipianId = equipRes.eq_needsp
            local suipianNum = 0
            for k,v in pairs(mm.data.playerEquip) do
                if v.id == suipianId then
                    suipianNum = v.num
                    break
                end  
            end

            if suipianId > 0 and suipianNum >= needNum then 
                self.EquipmentBtn:setTitleText("合成")
                self.EquipmentBtn:addTouchEventListener(handler(self, self.composeEquipBtnCbk))
                self.EquipmentBtn:setTag(self.eqId)
            else
                local itemNum = 1
                local needDiamond = equipRes.eq_zhuanshi * itemNum
                self.Node:getChildByName("Image_bg"):getChildByName("Text_10"):setVisible(false)
                self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(true)
                self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):getChildByName("Text_msg"):setString(needDiamond)

                self.EquipmentBtn:setTitleText("购买")
                self.EquipmentBtn:addTouchEventListener(handler(self, self.getWayBtnCbk))
                self.EquipmentBtn:setTag(self.eqId)
            end
        end

    end

    self.Node:getChildByName("Image_bg"):getChildByName("Text_need_lv"):setString("要求穿戴等级:"..equipRes.eq_needLv)
end

function TtemMsgLayer:composeEquipBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local eqId = widget:getTag()
        mm.req("composeEquip",{type = 2, targetEquipId = eqId, getType=1, heroId = self.heroId, eqId = eqId, eqIndex = self.index})
    end
end

function TtemMsgLayer:hcBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local eqId = widget:getTag()
        local HeChenLayer = require("src.app.views.layer.HeChenLayer").create({aap = self.app, eqId = eqId})
        local size  = cc.Director:getInstance():getWinSize()
        self:getParent():addChild(HeChenLayer)
        HeChenLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(HeChenLayer)

        self:removeFromParent()
    end
end

function TtemMsgLayer:getWayBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        --[[
        local eqId = widget:getTag()
        local HeChenLayer = require("src.app.views.layer.HeChenLayer").create({aap = self.app, eqId = eqId})
        local size  = cc.Director:getInstance():getWinSize()
        self:getParent():addChild(HeChenLayer)
        HeChenLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(HeChenLayer)

        self:removeFromParent()
        --]]
        local buyItemInfo = {}
        buyItemInfo.itemID = self.eqId
        buyItemInfo.itemNum = 1  -----只买一个

        mm.req("buySomeThing",{getType = 1, buyType = 3, buyItemInfo = buyItemInfo})
        --mm.req("buySomeThing",{getType = 1, buyType = 3, buyItemInfo = buyItemInfo})
    end
end

function TtemMsgLayer:buyEquipBack( event )
    if event.type == 0 then
        mm.data.playerEquip = event.playerEquip
        mm.data.playerinfo = event.playerinfo
        local equipRes = INITLUA:getEquipByid( self.eqId )
        if gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= equipRes.eq_needLv then
            mm.req("heroUpequip",{getType=1,heroId = self.heroId, eqId = self.eqId, eqIndex = self.index})
        else
            self.EquipmentBtn:setTitleText("装备")
            self.EquipmentBtn:addTouchEventListener(handler(self, self.zbBtnCbk))
            self.EquipmentBtn:setTag(self.eqId)
            self.Node:getChildByName("Image_bg"):getChildByName("Text_10"):setVisible(true)
            self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):setVisible(false)
        end
        --game:dispatchEvent({name = EventDef.UI_MSG, code = "buyEquipBack"})
        --self:removeFromParent()
    else
        local text = gameUtil.GetMoGameRetStr( event.code )
        if event.code == 990001 then
            gameUtil.showChongZhi( self, event.code )
        elseif event.code == 990060 then
            print(" VIPTIPSVIPTIPSVIPTIPSVIPTIPS        ================ ")
            local VIPTIPS = require("src.app.views.layer.VIPTIPS").new({scene = self})
            self:addChild(VIPTIPS, MoGlobalZorder[2000002])

        end
    end
end

function TtemMsgLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function TtemMsgLayer:heroUpequipBack( event )
    if event.type == 0 then
        mm.data.playerEquip = event.playerEquip
        -- mm.data.playerHero = event.playerHero

        game:dispatchEvent({name = EventDef.UI_MSG, code = "heroUpequip", equipId = self.eqId})
        self:removeFromParent()

        gameUtil.playUIEffect( "Equip_Wear" )
    elseif event.type == 1 then
        gameUtil:addTishi({s = event.message})
    end
end

function TtemMsgLayer:composeEquipBack( event )
    if event.type == 3 then
        mm.data.playerEquip = event.playerEquip

        local upEquipResult = event.upEquipResult
        if upEquipResult.type == 0 then
        	mm.data.playerEquip = upEquipResult.playerEquip

	        game:dispatchEvent({name = EventDef.UI_MSG, code = "heroUpequip", equipId = self.eqId})
	        self:removeFromParent()

	        gameUtil.playUIEffect( "Equip_Wear" )
        else
        	mm.data.playerEquip = event.playerEquip
			gameUtil:addTishi({s = upEquipResult.message})
			self:removeFromParent()
        end
    elseif event.type == 1 then
        gameUtil:addTishi({s = MoGameRet[990062]})
        self:removeFromParent()
    elseif event.type == 2 then
        mm.data.playerEquip = event.playerEquip
        gameUtil:addTishi({s = MoGameRet[990063]})
        self:removeFromParent()
    end
end

function TtemMsgLayer:zbBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local eqId = widget:getTag()

        mm.req("heroUpequip",{getType=1,heroId = self.heroId, eqId = self.eqId, eqIndex = self.index})
        if mm.GuildId == 10022 then
            -- Guide:startGuildById(19001, mm.GuildScene.GuildViewEquipBtn)
            Guide:startGuildById(10023, mm.GuildScene.GuildJinJieBtn)
        end
    end
end


return TtemMsgLayer
