local VIPLayer = class("VIPLayer", require("app.views.mmExtend.LayerBase"))
VIPLayer.RESOURCE_FILENAME = "VIPtequan.csb"

function VIPLayer:onCreate()
    self.Node = self:getResourceNode()
    self.pageView = self.Node:getChildByName("Image_bg"):getChildByName("PageView")
    self.buttomLayer = self.Node:getChildByName("Image_bg"):getChildByName("Image_buttom")

    local button_back = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    gameUtil.setBtnEffect(button_back)
    button_back:addTouchEventListener(handler(self, self.backBtnCbk))

    local button_chongzhi = self.Node:getChildByName("Image_bg"):getChildByName("Button_Recharge")
    -- gameUtil.setBtnEffect(button_chongzhi)
    button_chongzhi:addTouchEventListener(handler(self, self.rechargeBtnCbk))


    self.buyGiftBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    gameUtil.setBtnEffect(self.buyGiftBtn)
    self.buyGiftBtn:addTouchEventListener(handler(self, self.buyGiftBtnCbk))

    self.button_left = self.Node:getChildByName("Image_bg"):getChildByName("Button_left")
    gameUtil.setBtnEffect(self.button_left)
    self.button_left:addTouchEventListener(handler(self, self.button_leftCbk))

    self.button_right = self.Node:getChildByName("Image_bg"):getChildByName("Button_right")
    gameUtil.setBtnEffect(self.button_right)
    self.button_right:addTouchEventListener(handler(self, self.button_rightCbk))

    self.myVipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    self.vipLv = self.myVipLv > 0 and self.myVipLv or 1
    self:initMidLayer()
    -- 初始化三个子页面
    self:initVipItem()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function VIPLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "buySomeThing" then
            self:bugGiftBack(event.t)
        end
    end
end

function VIPLayer:bugGiftBack(t)
    if t.type == 0 then
        gameUtil:addTishi({s = MoGameRet[990033]})
        self:updateButtom()
    elseif t.type == 1 then
        gameUtil:addTishi({s = MoGameRet[990034]})
    elseif t.type == 2 then
        gameUtil:addTishi({s = MoGameRet[990001]})
    elseif t.type == 3 then
        gameUtil:addTishi({s = MoGameRet[990035]})
    end
end

function VIPLayer:initMidLayer()
    local vipNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_VIP"):getChildByName("Node_1")
    gameUtil.setVipLevel(vipNode, self.myVipLv)

    local tishi = self.Node:getChildByName("Image_bg"):getChildByName("Text_tishi")
    local needExp, haveExp = INITLUA:getVipExpNeed(mm.data.playerinfo.vipexp)
    local needDiamond = needExp - haveExp
    local targetLv = self.myVipLv + 1
    local loadingbar = self.Node:getChildByName("Image_bg"):getChildByName("Image_Loadingbar"):getChildByName("LoadingBar")
    local loadingbar_text = self.Node:getChildByName("Image_bg"):getChildByName("Image_Loadingbar"):getChildByName("Text_Loadingbar")
    if targetLv <= 15 then
        tishi:setString(string.format(MoGameRet[990031], needDiamond, targetLv))
        loadingbar:setPercent(math.ceil(haveExp*100/needExp))
        local loadingbar_text = self.Node:getChildByName("Image_bg"):getChildByName("Image_Loadingbar"):getChildByName("Text_Loadingbar")
        loadingbar_text:setString(haveExp.."/"..needExp)
    else
        tishi:setString(MoGameRet[990036])
        loadingbar:setPercent(100)
        loadingbar_text:setString((mm.data.playerinfo.vipexp - haveExp).."/MAX")
    end
end

local function getVipLv(lv)
    if lv > 15 then
        lv = 1
    elseif lv <= 0 then
        lv = 15
    end
    return lv
end

function VIPLayer:initVipItem()
    self.showNum = 6
    if self.vipLv >= 12 then
        self.showNum = 15
    elseif self.vipLv >= 9 then
        self.showNum = 12
    elseif self.vipLv >= 6 then
        self.showNum = 9
    else
        self.showNum = 6
    end

    for i=1,self.showNum do
        local layout = ccui.Layout:create()
        local layer = cc.CSLoader:createNode("VIP_item.csb")
        local vipLv = i
        self:updateLayout(layer, getVipLv(vipLv))
        layout:addChild(layer)
        self.pageView:addPage(layout)
    end
    self.pageView:scrollToPage(self.vipLv - 1)
    self:updateButtom()

    if self.vipLv == 15 then
        self.button_right:setTouchEnabled(false)
        self.button_right:setVisible(false)
    else
        self.button_right:setTouchEnabled(true)
        self.button_right:setVisible(true)
    end
    if self.vipLv == 1 then
        self.button_left:setTouchEnabled(false)
        self.button_left:setVisible(false)
    else
        self.button_left:setTouchEnabled(true)
        self.button_left:setVisible(true)
    end
end

--[[
    {
        a1 = "充值钻石%d可达到VIP%d", 
        libao = "V%d超值大礼包：%s", 
        a2 = "经验池上限+%d", 
        jinshouzhi = "每天可购买%d次金手指", 
        dianjinshou = "每天可购买%d次点金手", 
        exp = "每天可购买%d次经验喷泉", 
        a3 = "每日可购买PK点数%d次", 
        a4 = "每日可购买死斗次数%d次", 
        a5 = "每日可购买挑战次数%d次", 
        a6 = "每日可直接购买装备%d次", 
        a7 = "每日可刷新商城%d次"},
    
    ]]

function VIPLayer:updateLayout(layout, vipLv)
    local vipExpRes = INITLUA:getVIPTabById(vipLv)
    local ListView = layout:getChildByName("Image_bg"):getChildByName("ListView")
    ListView:setScrollBarEnabled(false)

    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a1, vipExpRes.TotalExp, vipLv))
    ListView:pushBackCustomItem(custom_item)


    local custom_item = self:createItem()
    if mm.data.playerinfo.camp == 1 then
        custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(vipExpRes.VIP_LOLDesc)
    else
        custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(vipExpRes.VIP_DOTADesc)
    end
    ListView:pushBackCustomItem(custom_item)



    -- local custom_item = self:createItem()
    -- custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].jinshouzhi, vipExpRes.GoldFingerTimes))
    -- ListView:pushBackCustomItem(custom_item)


    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].dianjinshou, vipExpRes.BuyGoldTimes))
    ListView:pushBackCustomItem(custom_item)

    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a2, vipExpRes.VIPExpPoolMax))
    ListView:pushBackCustomItem(custom_item)

    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].exp, vipExpRes.ExpPoorTimes))
    ListView:pushBackCustomItem(custom_item)

    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a3, vipExpRes.PKNumMax))
    ListView:pushBackCustomItem(custom_item)

    -- local custom_item = self:createItem()
    -- custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a4, vipExpRes.sidougoumai))
    -- ListView:pushBackCustomItem(custom_item)

    -- local custom_item = self:createItem()
    -- custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a5, vipExpRes.tiaozhangoumai))
    -- ListView:pushBackCustomItem(custom_item)

    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a6, vipExpRes.yingxiongmaizhuangbei))
    ListView:pushBackCustomItem(custom_item)

    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a7, vipExpRes.shangchengshuaxin))
    ListView:pushBackCustomItem(custom_item)

    local custom_item = self:createItem()
    custom_item:getChildByName("vip_text"):getChildByName("Text"):setString(string.format(MoGameRet[990030].a8, vipExpRes.saodangcishu))
    ListView:pushBackCustomItem(custom_item)
end

function VIPLayer:createItem()
    local custom_item = ccui.Layout:create()
    local vipText = cc.CSLoader:createNode("VIP_text.csb")
    vipText:setName("vip_text")
    custom_item:addChild(vipText)
    custom_item:setContentSize(vipText:getContentSize())
    return custom_item
end

function VIPLayer:button_leftCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.vipLv == 1 then
            return
        end
        self.vipLv = self.vipLv - 1
        self.pageView:scrollToPage(self.vipLv - 1)
        if self.vipLv == 1 then
            self.button_left:setTouchEnabled(false)
            self.button_left:setVisible(false)
        else
            self.button_left:setTouchEnabled(true)
            self.button_left:setVisible(true)
        end
        self:updateButtom()
        self.button_right:setTouchEnabled(true)
        self.button_right:setVisible(true)
        -- widget:setTouchEnabled(false)
        -- self.pageView:scrollToPage(0)
        -- self.vipLv = getVipLv(self.vipLv-1)
        -- self:updateButtom()
        -- performWithDelay(self, function()
        --         self.pageView:removePageAtIndex(2)
        --         local layout = ccui.Layout:create()
        --         local layer = cc.CSLoader:createNode("VIP_item.csb")
        --         self:updateLayout(layer, getVipLv(self.vipLv-1))
        --         layout:addChild(layer)
        --         self.pageView:insertPage(layout, 0)
        --         self.pageView:scrollToPage(1)
        --         widget:setTouchEnabled(true)
        --     end
        -- , 0.5)
    end
end

function VIPLayer:button_rightCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.vipLv == 15 then
            return
        end
        self.vipLv = self.vipLv + 1
        self.pageView:scrollToPage(self.vipLv - 1)
        if self.vipLv == 15 then
            self.button_right:setTouchEnabled(false)
            self.button_right:setVisible(false)
        else
            if self.vipLv >= self.showNum then
                self.button_right:setTouchEnabled(false)
                self.button_right:setVisible(false)
            else
                self.button_right:setTouchEnabled(true)
                self.button_right:setVisible(true)
            end
            
        end
        self:updateButtom()
        self.button_left:setTouchEnabled(true)
        self.button_left:setVisible(true)
        -- widget:setTouchEnabled(false)
        -- self.pageView:scrollToPage(2)
        -- self.vipLv = getVipLv(self.vipLv+1)
        -- self:updateButtom()
        -- performWithDelay(self, function()
        --         self.pageView:removePageAtIndex(0)
        --         local layout = ccui.Layout:create()
        --         local layer = cc.CSLoader:createNode("VIP_item.csb")
        --         self:updateLayout(layer, getVipLv(self.vipLv+1))
        --         layout:addChild(layer)
        --         self.pageView:addPage(layout)
        --         widget:setTouchEnabled(true)
        --     end
        -- , 0.5)
    end
end

function VIPLayer:updateButtom()
    local vipExpRes = INITLUA:getVIPTabById(self.vipLv)
    local flag = 0
    mm.data.playerExtra.vipGiftTab = mm.data.playerExtra.vipGiftTab or {}
    for k,v in pairs(mm.data.playerExtra.vipGiftTab) do
        if v == self.vipLv then
            flag = 1
        end
    end
    if flag == 0 then
        self.buyGiftBtn:setBright(true)
        self.buyGiftBtn:setTouchEnabled(true)
        -- vip礼包添加红点
        if gameUtil.canBuyGift() == 1 and self.myVipLv >= self.vipLv then
            gameUtil.addRedPoint(self.buyGiftBtn, 0.95, 0.9)
        else
            gameUtil.removeRedPoint(self.buyGiftBtn)
        end

        if self.an then
            self.an:setVisible(true)
        else
            an = gameUtil.createSkeAnmion( {name = "csk",scale = 1.0} )
            self.buyGiftBtn:addChild(an)
            an:setPosition(self.buyGiftBtn:getContentSize().width*0.5, self.buyGiftBtn:getContentSize().height*0.5)
            an:setAnimation(0, "stand", true)
            self.an = an
        end
    else
        self.buyGiftBtn:setBright(false)
        self.buyGiftBtn:setTouchEnabled(false)
        gameUtil.removeRedPoint(self.buyGiftBtn)
        if self.an then
            self.an:setVisible(false)
        end
    end

    if mm.data.playerinfo.camp == 1 then
        self.buttomLayer:getChildByName("Text_title"):setString(vipExpRes.VIP_LOLDesc)
    else
        self.buttomLayer:getChildByName("Text_title"):setString(vipExpRes.VIP_DOTADesc)
    end
    self.buttomLayer:getChildByName("Text_jinbi"):setString(vipExpRes.VipGiftCost1)
    self.buttomLayer:getChildByName("Text_jinbi_real"):setString(vipExpRes.VipGiftCost)
    local equipTab = {}
    if mm.data.playerinfo.camp == 1 then
        for k,v in pairs(vipExpRes.VipLOLEquip) do
            --local equipRes = INITLUA:getEquipByid(v)
            local temp = {}
            temp.type = 1
            temp.id = v
            temp.num = vipExpRes.VipLOLEquipLimit[k]
            table.insert(equipTab, temp)
        end
        for k,v in pairs(vipExpRes.VipLOLItem) do
            local temp = {}
            temp.type = 2
            temp.id = v
            temp.num = vipExpRes.VipLOLItemLimit[k]
            table.insert(equipTab, temp)
        end
    else
        for k,v in pairs(vipExpRes.VipDOTAEquip) do
            --local equipRes = INITLUA:getEquipByid(v)
            local temp = {}
            temp.type = 1
            temp.id = v
            temp.num = vipExpRes.VipDOTAEquipLimit[k]
            table.insert(equipTab, temp)
        end
        for k,v in pairs(vipExpRes.VipDOTAItem) do
            local temp = {}
            temp.type = 2
            temp.id = v
            temp.num = vipExpRes.VipDOTAItemLimit[k]
            table.insert(equipTab, temp)
        end
    end
    self:pushItemIntoList(equipTab)
end

function VIPLayer:pushItemIntoList(equipTab)
    local ListView = self.buttomLayer:getChildByName("ListView_equip")
    ListView:setScrollBarEnabled(false)

    ListView:removeAllItems()
    for i=1, #equipTab do
        local imageView
        if equipTab[i].type == 1 then
            imageView = gameUtil.createEquipItem(equipTab[i].id, equipTab[i].num)
        else
            imageView = gameUtil.createItemWidget(equipTab[i].id, equipTab[i].num)
        end

        imageView:setTouchEnabled(true)
        imageView:setTag(equipTab[i].id)

        if equipTab[i].type == 1 then
            local dropRes = INITLUA:getEquipByid(equipTab[i].id)
            if dropRes.EquipType == MM.EEquipType.ET_HunShi then
                imageView:addTouchEventListener(handler(self, self.hunshiCbk))
            else
                imageView:addTouchEventListener(handler(self, self.equipiCbk))
            end
        else
            imageView:addTouchEventListener(handler(self, self.itemCbk))
        end

        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(imageView:getContentSize())
        custom_item:addChild(imageView)
        ListView:pushBackCustomItem(custom_item)
    end
end

function VIPLayer:hunshiCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        local GoodsShowLayer = require("src.app.views.layer.GoodsShowLayer").new({id = id, type = 2})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(GoodsShowLayer, MoGlobalZorder[2000002])
        GoodsShowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(GoodsShowLayer)
    end
end

function VIPLayer:itemCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        local GoodsShowLayer = require("src.app.views.layer.GoodsShowLayer").new({id = id, type = 3})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(GoodsShowLayer, MoGlobalZorder[2000002])
        GoodsShowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(GoodsShowLayer)
    end
end

function VIPLayer:equipiCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        local GoodsShowLayer = require("src.app.views.layer.GoodsShowLayer").new({id = id, type = 1})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(GoodsShowLayer, MoGlobalZorder[2000002])
        GoodsShowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(GoodsShowLayer)
    end
end

function VIPLayer:backBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        game:dispatchEvent({name = EventDef.UI_MSG, code = "vipGift"})
        self:removeFromParent()
    end
end

function VIPLayer:buyGiftBtnCbk(widget, touchkey)

    
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
        mm.req("buySomeThing", {getType = self.vipLv, buyType = 5})
    end
end

function VIPLayer:rechargeBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        -- game:dispatchEvent({name = EventDef.UI_MSG, code = "vipGift"})
        self:removeFromParent()
    end
end

function VIPLayer:onEnter()
    
end

function VIPLayer:onExit()
    
end

function VIPLayer:onEnterTransitionFinish()
    
end

function VIPLayer:onExitTransitionStart()
    
end

function VIPLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return VIPLayer