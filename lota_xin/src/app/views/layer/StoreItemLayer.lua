--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local StoreItemLayer = class("StoreItemLayer", require("app.views.mmExtend.LayerBase"))
StoreItemLayer.RESOURCE_FILENAME = "Shangpin.csb"

local MM = MM

function StoreItemLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function StoreItemLayer:onEnter()

end

function StoreItemLayer:onExit()

end

function StoreItemLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function StoreItemLayer:init(param)
    self.param = param
    self.scene = param.scene
    self.itemInfo = param.info
    self:initLayerUI()
end

function StoreItemLayer:initLayerUI( )
    self.Node = self:getResourceNode()
    self.Node:getChildByName("Text_6"):setVisible(false)
    self.Node:getChildByName("Text_4"):setVisible(false)

    local itemID = self.itemInfo.itemID
    local storeItemRes = INITLUA:getShopItemListRes()
    
    local storeItem = storeItemRes[itemID]
    local shopItemID = storeItem.ShopItemID
    local shopItemType = storeItem.ShopType
    -- 如果是绝版，播放特效
    if storeItemRes.ShopItemLv == MM.EShopItemLv.SIL_Jueban then
        -- 添加物品边缘特效
        -- gameUtil.addArmatureFile("res/Effect/uiEffect/sg/sg.ExportJson")
        -- local item_play = ccs.Armature:create("sg")
        -- self.Node:getChildByName("Image_1"):addChild(item_play, 10)
        -- item_play:setAnchorPoint(cc.p(0.5, 0.5))
        -- local size = self.Node:getChildByName("Image_1"):getContentSize()
        -- item_play:setPosition(size.width/2, size.height/2)
        -- --item_play:setScale(size.width/item_play:getContentSize().width, size.height/item_play:getContentSize().height)
        -- item_play:setScale(2)
        -- item_play:getAnimation():playWithIndex(0)

        local item_play = gameUtil.createSkeAnmion( {name = "sg",scale = 0.75} )
        item_play:setAnimation(0, "stand", false)
        self.Node:getChildByName("Image_1"):addChild(item_play, 10)
        item_play:setAnchorPoint(cc.p(0.5, 0.5))
        local size = self.Node:getChildByName("Image_1"):getContentSize()
        item_play:setPosition(size.width/2, size.height/2)
    end
    -- 物品数量
    local itemNum = storeItem.ReNum
    -- 折扣值
    local discountValue = self.itemInfo.discountValue
    local luckyValue = mm.data.playerinfo.luckyValue

    self.discountText = self.Node:getChildByName("Text_3")
    self.discountImage = self.Node:getChildByName("Image_3")
    if discountValue >= 100 then
        self.discountText:setVisible(false)
        self.discountImage:setVisible(false)
    else
        self.discountText:setVisible(true)
        self.discountImage:setVisible(true)
        -- 0.35 0.75
        local offsetX = self.discountImage:getContentSize().width * 0.49
        local offsetY = self.discountImage:getContentSize().height * 0.55
        -- offsetX = self.discountImage:getContentSize().width * 0.4
        -- offsetY = self.discountImage:getContentSize().height * 0.75
        if discountValue >= 85 and discountValue <= 99 then
            self.discountImage:loadTexture("res/icon/jiemian/icon_putong.png")
        elseif discountValue >= 70 and discountValue <= 84 then
            self.discountImage:loadTexture("res/icon/jiemian/icon_gaoji.png")
            offsetX = self.discountImage:getContentSize().width * 0.49
            offsetY = self.discountImage:getContentSize().height * 0.53
            -- local resName = "zkls"
            -- gameUtil.addArmatureFile("res/Effect/uiEffect/"..resName.."/"..resName..".ExportJson")
            -- local anime = ccs.Armature:create(resName)

            -- local animation = anime:getAnimation()
            -- anime:setScale(0.62)
            -- anime:setPosition(cc.p(offsetX, offsetY))
            -- -- anime:setRotation(45)
            -- self.discountImage:addChild(anime)
            -- animation:play(resName)
            -- -- anime:setScale(3.3)
            -- anime:setAnchorPoint(cc.p(0.5,0.5))

            local anime = gameUtil.createSkeAnmion( {name = "zkls",scale = 0.5} )
            anime:setAnimation(0, "stand", true)
            self.discountImage:addChild(anime)
            anime:setPosition(cc.p(offsetX, offsetY))

        elseif discountValue >= 50 and discountValue < 70 then
            self.discountImage:loadTexture("res/icon/jiemian/icon_xiyou.png")
            offsetX = self.discountImage:getContentSize().width * 0.47
            offsetY = self.discountImage:getContentSize().height * 0.53

            -- local resName = "zkzs"
            -- gameUtil.addArmatureFile("res/Effect/uiEffect/"..resName.."/"..resName..".ExportJson")
            -- local anime = ccs.Armature:create(resName)

            -- local animation = anime:getAnimation()
            -- anime:setScale(0.62)
            -- anime:setPosition(cc.p(offsetX, offsetY))
            -- -- anime:setRotation(45)
            -- self.discountImage:addChild(anime)
            -- animation:play(resName)
            -- -- anime:setScale(3.3)
            -- anime:setAnchorPoint(cc.p(0.5,0.5))


            local anime = gameUtil.createSkeAnmion( {name = "zkzs",scale = 0.5} )
            anime:setAnimation(0, "stand", true)
            self.discountImage:addChild(anime)
            anime:setPosition(cc.p(offsetX, offsetY))
        elseif discountValue < 50 then
            self.discountImage:loadTexture("res/icon/jiemian/icon_jueban.png")

            offsetX = self.discountImage:getContentSize().width * 0.4
            offsetY = self.discountImage:getContentSize().height * 0.75

            -- local resName = "zkcs"
            -- gameUtil.addArmatureFile("res/Effect/uiEffect/"..resName.."/"..resName..".ExportJson")
            -- local anime = ccs.Armature:create(resName)

            -- local animation = anime:getAnimation()
            -- anime:setScale(0.65)
            -- anime:setPosition(cc.p(offsetX, offsetY))
            -- -- anime:setRotation(45)
            -- self.discountImage:addChild(anime)
            -- animation:play(resName)
            -- -- anime:setScale(3.3)
            -- anime:setAnchorPoint(cc.p(0.5,0.5))

            local anime = gameUtil.createSkeAnmion( {name = "zkcs",scale = 0.5} )
            anime:setAnimation(0, "stand", true)
            self.discountImage:addChild(anime)
            anime:setPosition(cc.p(offsetX, offsetY))


        end
        self.discountImage:setScale(1.6)
        local tempDiscountValue = discountValue / 10
        tempDiscountValue = string.format("%.01f", tempDiscountValue)
        self.discountText:setString(tempDiscountValue.."折")
    end

    if shopItemType == MM.EShopType.ST_Equip or shopItemType == MM.EShopType.ST_SoulStone then
        local equip = INITLUA:getEquipByid(shopItemID)
        if equip then
            local itemNode = gameUtil.createEquipItem( shopItemID , itemNum)
            local eqIcon = self.Node:getChildByName("Image_2"):addChild(itemNode)
            
            self.item_name = self.Node:getChildByName("Text_1")
            self.item_name:setString(equip.Name)
        end
    elseif shopItemType == MM.EShopType.ST_Xiaohaopin then
        local item = INITLUA:getItemByid(shopItemID)
        if item then
            local itemNode = gameUtil.createItemWidget(shopItemID , itemNum)
            local eqIcon = self.Node:getChildByName("Image_2"):addChild(itemNode)
            
            self.item_name = self.Node:getChildByName("Text_1")
            self.item_name:setString(item.Name)
        end
    elseif shopItemType == MM.EShopType.ST_Pifu then
        local item = INITLUA:getSkinByID(shopItemID)
        if item then
            local itemNode = gameUtil.createSkinIcon(shopItemID)
            local scale = (84 / itemNode:getContentSize().width)
            itemNode:setScale(scale)
            local eqIcon = self.Node:getChildByName("Image_2"):addChild(itemNode)
            
            self.item_name = self.Node:getChildByName("Text_1")
            self.item_name:setString(item.Name)
        end
    else
        
    end

    
    self.item_bg = self.Node:getChildByName("Image_1")
    local bgType = storeItem.ShopItemLv + 1
    local resStr = "res/icon/jiemian/icon_SC_"..bgType..".png"
    self.item_bg:loadTexture(resStr)
    
    self.item_bg:addTouchEventListener(handler(self, self.itemBtnCbk))
    --gameUtil.setBtnEffect(self.item) 


    -- 奖励按钮
    self.item_icon = self.Node:getChildByName("Image_2")
    self.item_icon:addTouchEventListener(handler(self, self.showItemBtnCbk))

    self.soldOut = cc.Sprite:create("res/UI/icon_shouqi.png")
    self.soldOut:setAnchorPoint(cc.p(0.5, 0.5))
    local width = self.item_icon:getContentSize().width
    local height = self.item_icon:getContentSize().height

    self.soldOut:setPosition(cc.p(width*0.5, height*0.5))
    self.item_icon:addChild(self.soldOut)

    if self.itemInfo.status ~= 0 then
        --gameUtil:addTishi({p = self.Node:getParent(), s = "商品已售罄", z = 1000000})
        self.soldOut:setVisible(true)
    else
        self.soldOut:setVisible(false)
    end

    --self.test:setString(param.."sdfsdgsdgsdgsdgsdgsdg"..param)
    --self.test:setFontSize(36)
    self:setContentSize(self.item_bg:getContentSize())
    self.item_bg:setSwallowTouches(false)

    self.itemPriceIcon = self.Node:getChildByName("Image_4")
    
    local shopRes = INITLUA:getShopListRes()
    local shopItem = shopRes[storeItem.ShopID]

    local moneyType = shopItem.Money1
    local priceValue = storeItem.Money1Num
    if priceValue  == 0 then
        moneyType = shopItem.Money2
        priceValue = storeItem.Money2Num
    end
    
    if moneyType == 1 then ---- 金币
        local res = "res/UI/pc_jinbi.png"
        self.itemPriceIcon:loadTexture(res)
    elseif moneyType == 2 then ----砖石
        local res = "res/UI/pc_zuanshi.png"
        self.itemPriceIcon:loadTexture(res)
    elseif moneyType == 3 then ----荣誉
        local res = "res/UI/pc_rongyu.png"
        self.itemPriceIcon:loadTexture(res)
    elseif moneyType == 4 then ----pk币
        local res = "res/UI/pc_PKbi.png"
        self.itemPriceIcon:loadTexture(res)
    end
    
    self.itemPriceIcon:setAnchorPoint(cc.p(0, 0.5))
    self.itemPrice = self.Node:getChildByName("Text_2")

    priceValue = math.floor((priceValue * discountValue) / 100)
    self.itemPrice:setString(priceValue)
    self.itemPrice:setAnchorPoint(cc.p(0, 0.5))
    local textWidth = self.itemPrice:boundingBox().width + self.itemPriceIcon:getContentSize().width
    local itemBGWidth = self.item_bg:getContentSize().width
    local offsetX = (itemBGWidth - textWidth)*0.5
    self.itemPriceIcon:setPositionX(offsetX)
    self.itemPrice:setPositionX(offsetX + self.itemPriceIcon:getContentSize().width)

    if shopItemType == 0 then
        local needHintIds = self:checkHintIds(shopItemID)
        if #needHintIds > 0 then
            gameUtil.addGreenPoint(self.Node:getChildByName("Image_2"), 0.9, 0.9)
        end
    end
end

function StoreItemLayer:checkHintIds( equipID )
    local heroIDs = {}
    for i=1,#mm.data.playerHero do
        local eqTab = mm.data.playerHero[i].eqTab
        local jinTab = gameUtil.getEquipId( mm.data.playerHero[i].id, mm.data.playerHero[i].jinlv )
        if jinTab == nil then
            
        end
        for j=1,6 do
            local t = gameUtil.getHeroEqByIndex( eqTab, j )
            local eqId = jinTab.EquipEx[j]
            if t == nil and eqId == equipID and self.itemInfo.status == 0 then
                table.insert(heroIDs, mm.data.playerHero[i].id)
                break
            end
        end
    end
    return heroIDs
end

function StoreItemLayer:eventListener( event )
    
end

function StoreItemLayer:showItemBtnCbk(widget,touchkey)

end

function StoreItemLayer:itemBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.began then
        self.itemBtnTouch = 0
    elseif touchkey == ccui.TouchEventType.moved then
        self.itemBtnTouch = self.itemBtnTouch + 1
    elseif touchkey == ccui.TouchEventType.ended then 
        if self.itemBtnTouch > 5 then
            self.itemBtnTouch = 0
            return
        else
            self.itemBtnTouch = 0
        end

        local condition = self.itemInfo.condition
        local conditionValue = self.itemInfo.conditionValue
        if condition == 0 then
            
        elseif condition == 1 then
            local playerInfo = mm.data.playerinfo
            if playerInfo.vipexp < conditionValue then
                --gameUtil:addTishi({p = self.Node:getParent(), s = "未达到购买条件", z = 1000000})
                gameUtil:addTishi({p = self.scene, s = "未达到购买条件", z = 1000000})
                return
            end
        end
        if self.itemInfo.status ~= 0 then
            --gameUtil:addTishi({p = self.Node:getParent(), s = "商品已售罄", z = 1000000})
            local text = gameUtil.GetMoGameRetStr( 990008 )
            gameUtil:addTishi({p = self.scene, s = text, z = 1000000})
            return
        end
        --达到购买条件则弹出购买确认窗口
        local windowLayer = require("src.app.views.layer.StoreItemWindow").new({param = self.itemInfo})
        local size  = cc.Director:getInstance():getWinSize()

        self.scene:addChild(windowLayer)
        windowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(windowLayer)
    end
end

function StoreItemLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "buySomeThing" then
            local info = event.t.buyItemInfo
            if info == nil then
                return
            end
            
            if info.itemID == self.itemInfo.itemID then
                self.itemInfo.status = info.status
                if self.itemInfo.status ~= 0 then
                    --gameUtil:addTishi({p = self.Node:getParent(), s = "商品已售罄", z = 1000000})
                    self.soldOut:setVisible(true)
                else
                    self.soldOut:setVisible(false)
                end
            end
            
        end
    end
end

return StoreItemLayer


