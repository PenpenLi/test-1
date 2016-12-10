local HeChenLayer = class("HeChenLayer", require("app.views.mmExtend.LayerBase"))
HeChenLayer.RESOURCE_FILENAME = "HeChenLayer.csb"

function HeChenLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function HeChenLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "eqHeChen" then
            self:hechenBtnCbk(event.t)
        end
    end
end

function HeChenLayer:onEnter()
    
end

function HeChenLayer:onExit()
    
end

function HeChenLayer:onEnterTransitionFinish()
    
end

function HeChenLayer:onExitTransitionStart()
    
end

function HeChenLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function HeChenLayer:init(param)

    self.app = param.app
    self.eqId = param.eqId
    self.Node = self:getResourceNode()

    local id  = self.eqId

    -- 合成按钮
    self.hechengBtn = self.Node:getChildByName("Image_bg01"):getChildByName("Button_hecheng")
    self.hechengBtn:addTouchEventListener(handler(self, self.hechengBtnCbk))
    gameUtil.setBtnEffect(self.hechengBtn)

    self.backBtn = self.Node:getChildByName("Image_bg01"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self.listView = self.Node:getChildByName("Image_bg01"):getChildByName("Image_bg02"):getChildByName("ListView")

    local custom_item = ccui.Layout:create()
    local HeroItem = cc.CSLoader:createNode("minItem.csb")
    HeroItem:setName("minItem")
    custom_item:addChild(HeroItem)
    custom_item:setContentSize(HeroItem:getContentSize())
    self.listView:pushBackCustomItem(custom_item)

    HeroItem:getChildByName("Image_bg"):loadTexture(gameUtil.getEquipIconRes(id))

    HeroItem:getChildByName("Image_bg"):setTag(id)
    HeroItem:getChildByName("Image_bg"):setTouchEnabled(true)
    HeroItem:getChildByName("Image_bg"):addTouchEventListener(handler(self, self.secUpBtnCbk))



    self.eqList = {}

    for i=1,4 do
        self.eqList[i] = self.Node:getChildByName("Image_bg01"):getChildByName("Node_"..i)
    end
    self.curEq = self.Node:getChildByName("Image_bg01"):getChildByName("Node_0")
    self.curEqName = self.Node:getChildByName("Image_bg01"):getChildByName("Text_zbName")

    self.curGoldNum = self.Node:getChildByName("Image_bg01"):getChildByName("Text_goldNum")

    self:updateItem(id)

    
end


function HeChenLayer:secUpBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        self.eqId = tag

        local tab = self.listView:getItems()
        for i=1,#tab do
            local id = tab[i]:getChildByName("minItem"):getChildByName("Image_bg"):getTag()
        end

        for i=1,#tab do
            local last = self.listView:getItems()[#self.listView:getItems()]
            
            local id = last:getChildByName("minItem"):getChildByName("Image_bg"):getTag()
            
            if id ~= tag then
                self.listView:removeLastItem()
            else
                break
            end
        end

        self:updateItem(tag)
    end
end

function HeChenLayer:secBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        self.eqId = tag

        local custom_item = ccui.Layout:create()
        local HeroItem = cc.CSLoader:createNode("minItem.csb")
        custom_item:addChild(HeroItem)
        HeroItem:setName("minItem")
        custom_item:setContentSize(HeroItem:getContentSize())
        self.listView:pushBackCustomItem(custom_item)

        HeroItem:getChildByName("Image_bg"):loadTexture(gameUtil.getEquipIconRes(tag))

        HeroItem:getChildByName("Image_bg"):setTag(tag)
        HeroItem:getChildByName("Image_bg"):setTouchEnabled(true)
        HeroItem:getChildByName("Image_bg"):addTouchEventListener(handler(self, self.secUpBtnCbk))

        self:updateItem(tag)
    end
end

function HeChenLayer:curIsHaveById( id )
    for k,v in pairs(mm.data.playerEquip) do
        if v.id == id and v.num > 0 then
            return true
        end
    end
    return nil
    
end

function HeChenLayer:updateItem( id )
    local tab = INITLUA:getEquipByid( id )

    self.curEq:removeAllChildren()
    for i=1,4 do
        self.eqList[i]:removeAllChildren()
    end

    for i=1,4 do
        local eqsrc = "eq_zujian0"..i
        local zjId = tab[eqsrc]
        if zjId > 0 then
            local image1 = ccui.ImageView:create()
            image1:loadTexture("res/UI/jm_icon.png")
            self.eqList[i]:addChild(image1)

            local imageView = ccui.ImageView:create()
            imageView:loadTexture(gameUtil.getEquipIconRes(zjId))
            self.eqList[i]:addChild(imageView)
            imageView:setTouchEnabled(true)
            imageView:addTouchEventListener(handler(self, self.secBtnCbk))
            imageView:setTag(zjId)
            if not self.curIsHaveById( zjId ) then
                imageView:setOpacity(100)
                --判断材料是否可以合成
                if 0 ~= gameUtil.isHechen(zjId) then
                    local text = ccui.Text:create()
                    text:setString("缺材料")
                    imageView:addChild(text)
                    text:setPosition(imageView:getContentSize().width * 0.5, imageView:getContentSize().height * 0.5)
                else
                    local text = ccui.Text:create()
                    text:setString("可合成")
                    imageView:addChild(text)
                    text:setPosition(imageView:getContentSize().width * 0.5, imageView:getContentSize().height * 0.5)
                end
            else
                
            end
        else
            local imageView = ccui.ImageView:create()
            imageView:loadTexture("res/UI/jm_icon.png")
            self.eqList[i]:addChild(imageView)

        end

        local hunshiId = tab.eq_needsp
        local hunshiNum = tab.eq_spnum
        if hunshiId > 0 then
            local image1 = ccui.ImageView:create()
            image1:loadTexture(gameUtil.getEquipIconRes(hunshiId))
            self.eqList[1]:addChild(image1)

            local ttfConfig = {}
            ttfConfig.fontFilePath = "font/youyuan.TTF"
            ttfConfig.fontSize = 20
            ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
            ttfConfig.customGlyphs = nil
            ttfConfig.distanceFieldEnabled = true
            ttfConfig.outlineSize = 1
            
            local label = cc.Label:createWithTTF(ttfConfig,"魂"..hunshiNum,cc.TEXT_ALIGNMENT_CENTER,300)
            label:setAnchorPoint(cc.p(1,0))
            label:setPosition(cc.p(image1:getContentSize().width - 10, 0))
            label:setTextColor( cc.c4b(0, 255, 0, 255) )
            label:enableGlow(cc.c4b(255, 255, 0, 255))
            image1:addChild(label)
        end
    end

    local imageView = ccui.ImageView:create()
    imageView:loadTexture(gameUtil.getEquipIconRes(id))
    self.curEq:addChild(imageView)

    self.curEqName:setText(tab.Name)
    self.curGoldNum:setText(tab.eq_jinbi)

    local eqTab = util.copyTab(mm.data.playerEquip)
    local hunshiTab = util.copyTab(mm.data.playerHunshi)
    if self:isHechen(id , eqTab, hunshiTab) == 0 then
        self.hechengBtn:setEnabled(true)
        self.hechengBtn:setBright(true)
    else
        self.hechengBtn:setEnabled(false)
        self.hechengBtn:setBright(false)
    end

end

function HeChenLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function HeChenLayer:hechenBtnCbk( event )
    mm.data.playerEquip = event.playerEquip
    mm.data.playerHunshi = event.playerHunshi
    game:dispatchEvent({name = EventDef.UI_MSG, code = "heroLevelUp"})
    self:removeFromParent()
end

function HeChenLayer:hechengBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm.req("eqHeChen",{getType=1,eqId = self.eqId})
    end
end

return HeChenLayer
