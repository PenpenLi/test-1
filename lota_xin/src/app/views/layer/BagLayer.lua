local BagLayer = class("BagLayer", require("app.views.mmExtend.LayerBase"))
BagLayer.RESOURCE_FILENAME = "BagLayer.csb"
local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")

PEIZHI = require("app.res.peizhi")

function BagLayer:onCreate(param) 
    self.hangNum = 5

    self.param = param
    self.scene = self.param.scene
    self.Node = self:getResourceNode()
    -- 按钮装备
    self.equipBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_zhuangbei")
    self.equipBtn:addTouchEventListener(handler(self, self.zhuangbeiBtnCbk))
    -- 按钮消耗
    self.xiaohaoBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_xiaohao")
    self.xiaohaoBtn:addTouchEventListener(handler(self, self.xiaohaoBtnCbk))
    -- 按钮魂石
    self.hunshiBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_hunshi")
    self.hunshiBtn:addTouchEventListener(handler(self, self.hunshiBtnCbk))
    -- 按钮碎片
    self.suipianBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_shuipian")
    self.suipianBtn:addTouchEventListener(handler(self, self.suipianBtnCbk))

    -- ok按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    --self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

    mm.req("getActivityInfo",{type=0})
end

function BagLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getEquip" and self.curLayerName == "Equip"then
            
            self:initEquipUI(event.t)
        elseif event.code == "getItem" and self.curLayerName == "Item"then
            
            self:initItemUI(event.t)
        elseif event.code == "getHunshi" and self.curLayerName == "Hunshi"then
            
            self:initHunshiUI(event.t)
        elseif event.code == "useItem" and self.curLayerName == "Item" then
            self.userItemTag = nil
            self:useItemBack(event.t)
        elseif event.code == "composeEquip" and self.curLayerName == "Suipian" then
            if event.t.type == 0 then
                mm.data.playerEquip = event.t.playerEquip
                self:initSuipianUI()
            else
                gameUtil:addTishi({s = MoGameRet[990062]})
            end
        end
    end
    if event.name == EventDef.UI_MSG then
        if self.curLayerName and  self.curLayerName == "Item" and event.code == "heroUpExp" then
            self.EquipListView:removeAllItems()
            self.itemIndex = nil
            self:initItemUI( {type = 0 ,playerItem = mm.data.playerItem} )
        end
    end
end

function BagLayer:onEnter()
    if gameUtil.isFunctionOpen(closeFuncOrder.BAG_EQUIP) == true then
        self.curLayerName = "Equip"
        self:initEquipUI()
    elseif gameUtil.isFunctionOpen(closeFuncOrder.BAG_HUNSHI) == true then
        self.curLayerName = "Hunshi"
        self:initHunshiUI()
    -- elseif gameUtil.isFunctionOpen(closeFuncOrder.BAG_HUNSHI) == true then
    --     self.curLayerName = "Hunshi"
    --     self:initHunshiUI()
    elseif gameUtil.isFunctionOpen(closeFuncOrder.BAG_ITEM) == true then
        self.curLayerName = "Item"
        self:initItemUI()
    else
        gameUtil:addTishi({s = MoGameRet[990047]})
        mm:popLayer()
    end
    
    mm.data.lastZhanLi = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue )
end

function BagLayer:onExit()
    if self.SelectView then
        self.SelectView:removeFromParent()
        self.SelectView = nil
    end
    -- game:dispatchEvent({name = EventDef.UI_MSG, code = "backFightSceneBackup"}) 
end

function BagLayer:useItemBack(t)
    if t.type == 1 then --道具不足
        gameUtil:addTishi({s = MoGameRet[990043]})
        return
    end
    if t.type == 2 then --pk次数已满
        gameUtil:addTishi({s = MoGameRet[990061]})
        return
    end
    local itemRes = INITLUA:getItemByid(t.itemId)
    self.useItemSucId = t.itemId
    if itemRes.ItemType == 4 then -- 使用礼包
        local GetRewardLayer = require("src.app.views.layer.GetRewardLayer").new({id = t.itemId, dropTab = t.dropTab})
        local size  = cc.Director:getInstance():getWinSize()
        mm.scene():addChild(GetRewardLayer, MoGlobalZorder[2999999])
        GetRewardLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(GetRewardLayer)

        -- self.itemIndex = nil
        self:initItemUI( {type = 0 ,playerItem = mm.data.playerItem} )
    elseif itemRes.ItemType == 0 then -- 使用经验丹
        local tempText = "获得经验+"..itemRes.itemNum
        -- mm.data.playerinfo.exppool = mm.data.playerinfo.exppool + itemRes.itemNum
        gameUtil:addTishi({s = tempText})


        -- self.itemIndex = nil
        self:initItemUI( {type = 0 ,playerItem = mm.data.playerItem} )
    elseif itemRes.ItemType == 8 then --换金币
        local tempText = "获得金币+"..itemRes.itemNum
        -- mm.data.playerinfo.gold = mm.data.playerinfo.gold + itemRes.itemNum
        gameUtil:addTishi({s = tempText})

        self:initItemUI()
    elseif itemRes.ItemType == 2 then --换PK
        local tempText = "获得PK次数+"..itemRes.itemNum
        -- mm.data.playerinfo.gold = mm.data.playerinfo.gold + itemRes.itemNum
        gameUtil:addTishi({s = tempText})

        -- self.itemIndex = nil
        self:initItemUI( {type = 0 ,playerItem = mm.data.playerItem} )
    end
end

function BagLayer:initEquipUI( ... )
    
    self:initContentLayer()

    
    self.chushouBtn:setTitleText("出售")

    self.shiyongBtn:setTitleText("详情")

    self.chushouBtn:setVisible(false)
    self.shiyongBtn:setVisible(false)

    self:setBtn( self.equipBtn )
    self.curLayerName = "Equip"

    performWithDelay(self, function( ... )
        local t = {}
        t.type = 0
        t.playerEquip = mm.data.playerEquip
        self:initEquipUIBack(t)
    end, 0.01)
    
end

function BagLayer:checkPlayer(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.curLayerName == "tibuZhanli" or self.curLayerName == "heroZhanli" then
            return
        end

        local tag = widget:getTag()
        self.checkId = tag
        mm.req("getPlayerInfo",{playerid = tag})
    end
end

function BagLayer:initHunshiUIBack()

    local playerHunshi = {}--util.copyTab(mm.data.playerHunshi)
    for i=1,#mm.data.playerHunshi do
        local t = mm.data.playerHunshi[i]
        t.bagType = 2
        if t.num > 0 then
            table.insert(playerHunshi,t)
        end
    end


    --排序
    function sortRules( a, b )

        return a.num > b.num
    end
    table.sort(playerHunshi, sortRules)
    self.curInfoTab = playerHunshi
    self.playerHunshi = playerHunshi

    print("#playerHunshi "..#playerHunshi)

    local hang = math.ceil(#playerHunshi/self.hangNum)
    local iconBgSelected = nil

    local countTab = {}
    for i=1,hang do
        countTab[i] = {}
    end
    for i=1,#playerHunshi do
        local h = math.ceil(i/self.hangNum)
        table.insert(countTab[h], playerHunshi[i])
    end

    self:showList(countTab)

    self.ContentLayer:getChildByName("Image_miaoshukuang"):setVisible(true)
end

function BagLayer:initEquipUIBack( event )
    local type = event.type
    local allPlayerEquip = {}
    for i=1,#event.playerEquip do
        print("event.playerEquip[i].id        "..event.playerEquip[i].id)
        local equip = INITLUA:getEquipByid( event.playerEquip[i].id )
        if event.playerEquip[i].num > 0 and equip.EquipType ~= MM.EEquipType.ET_SuiPian then
            local t = event.playerEquip[i]
            t.bagType = 1
            table.insert(allPlayerEquip, t)
        end
    end
    local playerEquip = allPlayerEquip


    print("#allPlayerEquip  "..#allPlayerEquip)


    --排序
    function sortRules( a, b )

        local aRes = INITLUA:getEquipByid( a.id )
        local bRes = INITLUA:getEquipByid( b.id )
        if aRes.Quality ~= bRes.Quality then
            return aRes.Quality > bRes.Quality
        else
            if aRes.Name ~= bRes.Name then
                if aRes.Name < bRes.Name then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
    end
    table.sort(playerEquip, sortRules)
    self.playerEquip = playerEquip
    self.curInfoTab = playerEquip


    local hang = math.ceil(#playerEquip/self.hangNum)
    local iconBgSelected = nil

    local countTab = {}
    for i=1,hang do
        countTab[i] = {}
    end
    for i=1,#playerEquip do
        local h = math.ceil(i/self.hangNum)
        table.insert(countTab[h], playerEquip[i])
    end

    
    self:showList(countTab)
    self.ContentLayer:getChildByName("Image_miaoshukuang"):setVisible(true)
end

function BagLayer:showList( countTab )
    local beginIndex = countTab.beginIndex or 1
    local function fun( i, table, cell, cellIndex )
        -- local cell =game.cellTab[cellIndex]
        cell:setSwallowTouches(false)
        local index = i
        
        for i=1,5 do
            local vTab = table[i]
            local num = 0
            if vTab then
                num = vTab.num
            end
                
            local res
            local suipianJiaobiaoRes 
            if vTab and num > 0 then
                local t = vTab.id
                num = vTab.num
                local res 
                local quality
                if vTab.bagType == 1 then
                    res = gameUtil.getEquipIconRes(vTab.id)
                    quality = INITLUA:getEquipByid( vTab.id ).Quality
                elseif vTab.bagType == 2 then
                    res = gameUtil.getEquipIconRes(vTab.id)
                    quality = INITLUA:getEquipByid( vTab.id ).Quality
                elseif vTab.bagType == 3 then
                    res = gameUtil.getItemIconRes(vTab.id)
                    quality = INITLUA:getItemByid( vTab.id ).Quality
                elseif vTab.bagType == 4 then
                    res = gameUtil.getEquipIconRes(vTab.id)
                    quality = INITLUA:getEquipByid( vTab.id ).Quality
                end
                
                local iconBg = cell:getChildByName("iconbg"..tostring(i))
                if not iconBg then
                    iconBg = ccui.ImageView:create()
                    iconBg:loadTexture("res/UI/jm_icon.png")
                    iconBg:setPosition(55 + 120 * (i - 1), 45)
                    cell:addChild(iconBg)
                    iconBg:retain()
                    iconBg:setName("iconbg"..tostring(i))
                end
                iconBg:setTag((index - 1) * 5 + i) 
                iconBg:addTouchEventListener(handler(self, self.selectCbk))
                iconBg:setTouchEnabled(true)
                
                local imageView = iconBg:getChildByName("icon")
                if not imageView then
                    imageView = ccui.ImageView:create()
                    imageView:loadTexture(res)
                    iconBg:addChild(imageView, 10)
                    imageView:setName("icon")
                else
                    imageView:loadTexture(res)
                end
                imageView:setScale(iconBg:getContentSize().width/imageView:getContentSize().width, iconBg:getContentSize().height/imageView:getContentSize().height)
                imageView:setPosition(iconBg:getContentSize().width * 0.5, iconBg:getContentSize().height * 0.5)    

                --魂石遮罩
                if vTab.bagType == 2 then
                    local zhezhao = iconBg:getChildByName("zhezhao")
                    if not zhezhao then
                        zhezhao = ccui.ImageView:create()
                        zhezhao:loadTexture("res/UI/icon_hunshi.png")
                        iconBg:addChild(zhezhao, 20)
                        zhezhao:setName("zhezhao")
                        zhezhao:setScale(iconBg:getContentSize().width/zhezhao:getContentSize().width, iconBg:getContentSize().height/zhezhao:getContentSize().height)
                        zhezhao:setPosition(iconBg:getContentSize().width * 0.5, iconBg:getContentSize().height * 0.5)
                    end
                    zhezhao:setVisible(true)
                else
                    local zhezhao = iconBg:getChildByName("zhezhao")
                    if zhezhao then
                        zhezhao:setVisible(false)
                    end
                end

                
                local pinImgView = iconBg:getChildByName("pingjie")
                if not pinImgView then
                    
                    pinImgView = ccui.ImageView:create()
                    iconBg:addChild(pinImgView, 30)
                    pinImgView:setAnchorPoint(cc.p(0,1))
                    pinImgView:setPosition(0, iconBg:getContentSize().height)
                    pinImgView:setName("pingjie")

                else
                    
                end
                
                local pinPathRes = gameUtil.getEquipPinRes(quality)
                if #pinPathRes > 0 then
                    pinImgView:loadTexture(pinPathRes)
                end
                
                if (quality == MM.EQuality.GoldQuality or quality == MM.EQuality.OrangeQuality) and vTab.bagType == 1 then
                    local item_play = iconBg:getChildByName("item_play")
                    if item_play then
                        item_play:setVisible(true)
                        item_play:setAnimation(0, "stand", true)
                    else
                        
                        local item_play = gameUtil.createSkeAnmion( {name = "wpk",scale = 0.7} )
                        item_play:setAnimation(0, "stand", true)
                        iconBg:addChild(item_play, 35)
                        local size = iconBg:getContentSize()
                        item_play:setPosition(size.width/2, size.height/2)
                        item_play:setName("item_play")
                        item_play:setVisible(true)

                    end
                else
                    local item_play = iconBg:getChildByName("item_play")
                    if item_play then
                        item_play:setVisible(false)
                    end
                end




                --碎片角标
                if vTab.bagType == 4 then
                    local spjb = iconBg:getChildByName("spjb")
                    if not spjb then
                        spjb = ccui.ImageView:create()
                        spjb:loadTexture(gameUtil.getEquipSuipianPinRes(quality))
                        iconBg:addChild(spjb, 20)
                        spjb:setName("spjb")
                        spjb:setAnchorPoint(cc.p(0, 1))
                        spjb:setPosition(0, iconBg:getContentSize().height)
                    end
                    spjb:setVisible(true)

                else
                    local spjb = iconBg:getChildByName("spjb")
                    if spjb then
                        spjb:setVisible(false)
                    end
                end

                --碎片绿点
                if vTab.bagType == 4 and vTab.hecheng == 1 then
                    local splvdian = iconBg:getChildByName("splvdian")
                    if not splvdian then
                        splvdian = ccui.ImageView:create()
                        splvdian:loadTexture("res/UI/pc_tongyong_lvse.png")
                        iconBg:addChild(splvdian, 20)
                        splvdian:setName("splvdian")
                        splvdian:setAnchorPoint(cc.p(1, 1))
                        splvdian:setPosition(iconBg:getContentSize().width, iconBg:getContentSize().height)
                    end
                    splvdian:setVisible(true)

                else
                    local splvdian = iconBg:getChildByName("splvdian")
                    if splvdian then
                        splvdian:setVisible(false)
                    end
                end
                    
                local sprite_ditu = iconBg:getChildByName("sprite_ditu")
                if not sprite_ditu then
                    sprite_ditu = ccui.ImageView:create()
                    sprite_ditu:loadTexture("res/UI/pc_jiaobiao.png")
                    iconBg:addChild(sprite_ditu, 40)
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(iconBg:getContentSize().width, 0))
                    sprite_ditu:setName("sprite_ditu")
                    sprite_ditu:setScaleX(math.log10(num*10) / 3)
                end

                local ttfConfig = {}
                ttfConfig.fontFilePath = "font/youyuan.TTF"
                ttfConfig.fontSize = 20
                ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                ttfConfig.customGlyphs = nil
                ttfConfig.distanceFieldEnabled = true
                ttfConfig.outlineSize = 1

                local label = iconBg:getChildByName("numlabel")
                if not label then
                    label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER)
                    iconBg:addChild(label, 50)
                    label:setAnchorPoint(cc.p(1,0))
                    label:setPosition(cc.p(iconBg:getContentSize().width - 5, 0))
                    label:setTextColor( cc.c4b(0, 255, 0, 255) )
                    label:enableGlow(cc.c4b(255, 255, 0, 255))
                    label:setName("numlabel")
                end
                label:setString(num)
                label:setName("numlabel")



                if index == 1 and i == 1 then
                    self:selectCbk(iconBg,ccui.TouchEventType.ended)
                elseif vTab.id == self.useItemSucId then
                    self:selectCbk(iconBg,ccui.TouchEventType.ended)
                    
                end

                iconBg:setVisible(true)
            else
                local iconBg = cell:getChildByName("iconbg"..i)
                if iconBg then
                    iconBg:setVisible(false)
                end
            end


        end



    end

    local sollowView = self.ContentLayer:getChildByName("ScrollView")
    sollowView:removeAllChildren()
    -- local container = sollowView:getInnerContainer()
    -- container:setPositionY(0)

    game.cellTab = game.cellTab or {}
    self.tempTab = gameUtil.setSollowViewNewTest(sollowView, 8, beginIndex, countTab, 110, "BagItem.csb", fun, handler(self, self.checkPlayer), game.cellTab)
    self.useItemSucId = nil
    
end



function BagLayer:equipSellBack( event )
    self.EquipListView:removeAllItems()
    mm.data.playerEquip = event.playerEquip
    self:initEquipUI()
end

function BagLayer:chushouBtnCbk( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
        local tag = widget:getTag()
        if self.SelectTab == nil then
            return
        end
        if self.curLayerName == "Equip" then
            -- local equipId = self.curInfoTab[tag].id
            -- self.param.app.clientTCP:send("equipSell",{getType=1, equipId = equipId},handler(self, self.equipSellBack))
        elseif self.curLayerName == "Item" then
            local itemRes = INITLUA:getItemByid(self.SelectTab.id)
            if itemRes.GiftID ~= 0 then
                --gameUtil:addTishi({s = "礼包:"..itemRes.GiftID})
                local LiBaoLayer = require("src.app.views.layer.LiBaoLayer").new({app = self.param.app, id = self.SelectTab.id})
                local size  = cc.Director:getInstance():getWinSize()
                mm.scene():addChild(LiBaoLayer, MoGlobalZorder[2999999])
                LiBaoLayer:setContentSize(cc.size(size.width, size.height))
                ccui.Helper:doLayout(LiBaoLayer)
            else
                --gameUtil:addTishi({s = "不是礼包！！！"})
            end
        elseif self.curLayerName == "Suipian" then
            mm.req("composeEquip",{type = 1, suipianId = self.SelectTab.id})
        end
    end
end

function BagLayer:shiyongBtnCbk( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
        if self.SelectTab == nil then
            return
        end
        if self.curLayerName == "Equip" then
            -- local equipId = self.curInfoTab[tag].id
            -- self.param.app.clientTCP:send("equipSell",{getType=1, equipId = equipId},handler(self, self.equipSellBack))
        elseif self.curLayerName == "Item" then
            local itemRes = INITLUA:getItemByid(self.SelectTab.id)
            if itemRes.ItemType == 4 then
                if not self.userItemTag then
                    mm.req("useItem",{type = 4, itemId = self.SelectTab.id})
                    self.userItemTag = 1
                end
            elseif itemRes.ItemType == 0 then
                if not self.userItemTag then
                    mm.req("useItem",{type = 0, itemId = self.SelectTab.id})
                    self.userItemTag = 1
                end
                
            elseif itemRes.ItemType == 8 then
                if not self.userItemTag then
                    mm.req("useItem",{type = 8, itemId = self.SelectTab.id})
                    self.userItemTag = 1
                end
            elseif itemRes.ItemType == 2 then
                if not self.userItemTag then
                    mm.req("useItem",{type = 2, itemId = self.SelectTab.id})
                    self.userItemTag = 1
                end
            else
                if itemRes.ItemLayerPath ~= "" then
                    if itemRes.ItemLayerPath == "StageDetailLayer" then
                        local param = {}
                        param.stageType = 3
                        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = itemRes.ItemLayerPath, param = param})
                    else
                        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = itemRes.ItemLayerPath})
                    end
                    
                else
                    gameUtil:addTishi({s = "不能在此使用"})
                end
            end
        end
    end
end

function BagLayer:setSelect( widget, tab, index )
    local miaoshukuang = self.ContentLayer:getChildByName("Image_miaoshukuang")
    local nameLabel = miaoshukuang:getChildByName("Text_name")


    if tab == nil then
        nameLabel:setText("")
        return
    end

    local id = tab.id
    print("setSelect  id "..id)
    print("setSelect  self.curLayerName "..self.curLayerName)
    
    local resTab = nil
    if self.curLayerName == "Item" then
        resTab = INITLUA:getItemByid( id )
        self.itemIndex = index
        
        for i=1, 4 do
            miaoshukuang:getChildByName("Text_"..i):setVisible(false)
        end
        miaoshukuang:getChildByName("Text_wenben"):setVisible(true)
        miaoshukuang:getChildByName("Text_wenben"):setString(resTab.itemsrc)


        local imageIcon = miaoshukuang:getChildByName("Image_icon")
        imageIcon:removeAllChildren()
        imageIcon:setVisible(true)
        local node = widget:clone()
        imageIcon:addChild(node)
        node:setPosition(imageIcon:getContentSize().width * 0.5, imageIcon:getContentSize().height * 0.5)

        node:setTouchEnabled(false)
        local children = node:getChildren()
        for k,v in pairs(children) do
            v:setTouchEnabled(false)
        end
        
        if resTab.ItemType == 4 then
            self.shiyongBtn:setTitleText("使用")
        elseif resTab.ItemType == 0 then
            self.shiyongBtn:setTitleText("使用")
        else
            if resTab.ItemLayerPath ~= "" then
                self.shiyongBtn:setTitleText("跳转")
            else
                self.shiyongBtn:setTitleText("使用")
            end
        end
        self.shiyongBtn:setVisible(true)
        self.chushouBtn:setVisible(true)
    elseif self.curLayerName == "Equip" or self.curLayerName == "Suipian"  then
        resTab = INITLUA:getEquipByid( id )
        self.equipIndex = index
        local equipRes = INITLUA:getEquipByid( tab.id )
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
        for i=1, 4 do
            miaoshukuang:getChildByName("Text_"..i):setVisible(false)
        end
        for i=1, #shuxingTab do
            if i <= 4 then
                miaoshukuang:getChildByName("Text_"..i):setString(shuxingTab[i])
                miaoshukuang:getChildByName("Text_"..i):setVisible(true)
            end
        end
        if self.curLayerName == "Suipian" then
            local textNode = miaoshukuang:getChildByName("Text_wenben_0")
            textNode:setVisible(true)
            textNode:setString(equipRes.eqsrc)
            self.chushouBtn:setVisible(true)
        end
        local imageIcon = miaoshukuang:getChildByName("Image_icon")
        imageIcon:removeAllChildren()
        imageIcon:setVisible(true)
        local node = widget:clone()
        imageIcon:addChild(node)
        node:setPosition(imageIcon:getContentSize().width * 0.5, imageIcon:getContentSize().height * 0.5)

        node:setTouchEnabled(false)
        local children = node:getChildren()
        for k,v in pairs(children) do
            v:setTouchEnabled(false)
        end

        local spjb = node:getChildByName("splvdian")
        if spjb then
            spjb:setVisible(false)
        end

        if widget:getChildByName("numlabel") then
            num = widget:getChildByName("numlabel"):getString()
            local ttfConfig = {}
            ttfConfig.fontFilePath = "font/youyuan.TTF"
            ttfConfig.fontSize = 20
            ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
            ttfConfig.customGlyphs = nil
            ttfConfig.distanceFieldEnabled = true
            ttfConfig.outlineSize = 1
            local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER)
            node:addChild(label, 50)
            label:setAnchorPoint(cc.p(1,0))
            label:setPosition(cc.p(node:getContentSize().width - 5, 0))
            label:setTextColor( cc.c4b(0, 255, 0, 255) )
            label:enableGlow(cc.c4b(255, 255, 0, 255))
            label:setName("numlabel")
        end

        
        

    elseif self.curLayerName == "Hunshi" then
        resTab = INITLUA:getEquipByid( id )
        for i=1, 4 do
            miaoshukuang:getChildByName("Text_"..i):setVisible(false)
        end


        local imageIcon = miaoshukuang:getChildByName("Image_icon")
        imageIcon:removeAllChildren()
        imageIcon:setVisible(true)
        local node = widget:clone()
        imageIcon:addChild(node)
        node:setPosition(imageIcon:getContentSize().width * 0.5, imageIcon:getContentSize().height * 0.5)

        node:setTouchEnabled(false)
        local children = node:getChildren()
        for k,v in pairs(children) do
            v:setTouchEnabled(false)
        end

        miaoshukuang:getChildByName("Text_wenben_0"):setVisible(true)
        miaoshukuang:getChildByName("Text_wenben_0"):setString(resTab.eqsrc)
        
        self.hunShiIndex = index
    else
        resTab = INITLUA:getEquipByid( id )
    end

    local Name = resTab.Name
    local src = resTab.eqsrc
    
    nameLabel:setText(Name)

    -- self.chushouBtn:setTag(index)
    -- self.shiyongBtn:setTag(index)
end

function BagLayer:selectCbk( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
        local kImgView = ccui.ImageView:create()
        kImgView:loadTexture("res/UI/jm_icon_select.png")
        widget:addChild(kImgView, 100)
        kImgView:setName("select")
        kImgView:setPosition(widget:getContentSize().width * 0.5, widget:getContentSize().height * 0.5)
        local index = widget:getTag()
        if self.SelectView then
            self.SelectView:removeFromParent()
        end
        self.SelectView = kImgView
        self.SelectTab = self.curInfoTab[index]
        self:setSelect( widget, self.curInfoTab[index], index )
    end
end

function BagLayer:initItemUI( )
    self:initContentLayer()

    
    self.chushouBtn:setTitleText("详情")

    self.shiyongBtn:setTitleText("使用")
    self.chushouBtn:setVisible(false)
    self.shiyongBtn:setVisible(false)
    self.chushouBtn:setTouchEnabled(true)
    self.shiyongBtn:setTouchEnabled(true)
    
    self:setBtn( self.xiaohaoBtn )
    self.curLayerName = "Item"

    self:initItemUIBack()
end


function BagLayer:initItemUIBack()
    local playerItem = mm.data.playerItem

    local playerItem = {}
    for i=1,#mm.data.playerItem do
        local t = mm.data.playerItem[i]
        t.bagType = 3
        if t.num > 0 then
            table.insert(playerItem,t)
        end
    end

    --排序
    local sortRules = { 
        {
            func = function(v)
                local itemTemp = INITLUA:getItemByid( v.id )
                return itemTemp.ItemType
            end,
            isAscending = false       
        },
        {
            func = function(v)
                local itemTemp = INITLUA:getItemByid( v.id )
                return itemTemp.Quality
            end,
            isAscending = false
        },
        {
            func = function(v)
                local itemTemp = INITLUA:getItemByid( v.id )
                return itemTemp.ID
            end,
            isAscending = false
        }
    }
    playerItem = util.powerSort(playerItem, sortRules)
    self.playerItem = playerItem
    self.curInfoTab = playerItem

    print("#playerItem "..#playerItem)

    local hang = math.ceil(#playerItem/self.hangNum)
    local iconBgSelected = nil

    local countTab = {}
    for i=1,hang do
        countTab[i] = {}
    end
    for i=1,#playerItem do
        local h = math.ceil(i/self.hangNum)
        table.insert(countTab[h], playerItem[i])
        if playerItem[i].id == self.useItemSucId then
            countTab.beginIndex = self.tempTab.newItemHeadIndex

        end
    end

    self:showList(countTab)

    self.ContentLayer:getChildByName("Image_miaoshukuang"):setVisible(true)

end

function BagLayer:initContentLayer( ... )
    if self.ContentLayer then
        self.ContentLayer:removeFromParent()
    end
    -- if self.ContentLayer then
        
    --     local miaoshukuang = self.ContentLayer:getChildByName("Image_miaoshukuang")

    --     local children = miaoshukuang:getChildren()
    --     for k,v in pairs(children) do
    --         v:setVisible(false)
    --     end
    -- else

        local BagBagLayer = cc.CSLoader:createNode("BagBagLayer.csb")
        self.ContentLayer = BagBagLayer
        self:addChild(BagBagLayer)
        local size  = cc.Director:getInstance():getWinSize()
        BagBagLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(BagBagLayer)

        if self.SelectView then
            self.SelectView:removeFromParent()
            self.SelectView = nil
        end
    -- end

    self.ContentLayer:getChildByName("Image_miaoshukuang"):setVisible(false)

    -- 设置按钮状态
    -- if not self.chushouBtn then
        self.chushouBtn = self.ContentLayer:getChildByName("Button_chushou")
        self.chushouBtn:addTouchEventListener(handler(self, self.chushouBtnCbk))
        gameUtil.setBtnEffect(self.chushouBtn)
    -- end

    -- if not self.shiyongBtn then
        self.shiyongBtn = self.ContentLayer:getChildByName("Button_shiyong")
        self.shiyongBtn:addTouchEventListener(handler(self, self.shiyongBtnCbk))
        gameUtil.setBtnEffect(self.shiyongBtn)
    -- end


end

function BagLayer:initHunshiUI( ... )
    
    self:initContentLayer()
    -- 
    self.chushouBtn:setTitleText("出售")
    self.shiyongBtn:setTitleText("详情")
    self.chushouBtn:setVisible(false)
    self.shiyongBtn:setVisible(false)

    self:setBtn( self.hunshiBtn )
    self.curLayerName = "Hunshi"

    self:initHunshiUIBack()
end

function BagLayer:initSuipianUI( ... )
    self:initContentLayer()

    self.chushouBtn:setTitleText("合成")
    self.shiyongBtn:setTitleText("详情")
    self.chushouBtn:setVisible(false)
    self.shiyongBtn:setVisible(false)
    self.chushouBtn:setTouchEnabled(true)

    self.chushouBtn:setPosition(self.shiyongBtn:getPosition())

    self:setBtn( self.suipianBtn )
    self.curLayerName = "Suipian"

    self:initSuipianUIBack()
end


function BagLayer:initSuipianUIBack( )

    local playerSuipian = {}
    local eTab = mm.data.playerEquip
    for i=1,#eTab do
        local suipian = INITLUA:getEquipByid( eTab[i].id )
        
        if eTab[i].num > 0 and suipian.EquipType == MM.EEquipType.ET_SuiPian then
            local equipId = suipian.eq_suipian
            local equip = INITLUA:getEquipByid( equipId )
            local eq_spnum = equip.eq_spnum

            local t = eTab[i]
            t.bagType = 4
            if eTab[i].num >= eq_spnum then
                t.hecheng = 1
            else
                t.hecheng = 0
            end
            table.insert(playerSuipian, t)
        end
    end

    print("#playerSuipian  "..#playerSuipian)


    --排序
    function sortRules( a, b )


        if a.hecheng ~= b.hecheng then
            return a.hecheng > b.hecheng
        end

        local aRes = INITLUA:getEquipByid( a.id )
        local bRes = INITLUA:getEquipByid( b.id )
        if aRes.Quality ~= bRes.Quality then
            return aRes.Quality > bRes.Quality
        else
            if aRes.Name ~= bRes.Name then
                if aRes.Name < bRes.Name then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
    end
    table.sort(playerSuipian, sortRules)
    self.playerSuipian = playerSuipian
    self.curInfoTab = playerSuipian

    local hang = math.ceil(#playerSuipian/self.hangNum)
    local iconBgSelected = nil

    local countTab = {}
    for i=1,hang do
        countTab[i] = {}
    end
    for i=1,#playerSuipian do
        local h = math.ceil(i/self.hangNum)
        table.insert(countTab[h], playerSuipian[i])
    end

    
    self:showList(countTab)

    self.ContentLayer:getChildByName("Image_miaoshukuang"):setVisible(true)

    
end




function BagLayer:setBtn( btn )
    
    self.equipBtn:setBright(true)
    self.xiaohaoBtn:setBright(true)
    self.hunshiBtn:setBright(true)
    self.suipianBtn:setBright(true)

    self.equipBtn:setEnabled(true)
    self.xiaohaoBtn:setEnabled(true)
    self.hunshiBtn:setEnabled(true)
    self.suipianBtn:setEnabled(true)

    btn:setBright(false)
    btn:setEnabled(false)

end

function BagLayer:zhuangbeiBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if gameUtil.isFunctionOpen(closeFuncOrder.BAG_EQUIP) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        self:initEquipUI()
    end
end

function BagLayer:xiaohaoBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if gameUtil.isFunctionOpen(closeFuncOrder.BAG_ITEM) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end
        self:initItemUI()
    end
end

function BagLayer:hunshiBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if gameUtil.isFunctionOpen(closeFuncOrder.BAG_HUNSHI) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end
        self:initHunshiUI()
    end
end

function BagLayer:suipianBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        -- if gameUtil.isFunctionOpen(closeFuncOrder.BAG_HUNSHI) == false then
        --     gameUtil:addTishi({s = MoGameRet[990047]})
        --     return
        -- end
        self:initSuipianUI()
    end
end

function BagLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function BagLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return BagLayer
