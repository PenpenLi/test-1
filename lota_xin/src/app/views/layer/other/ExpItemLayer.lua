local ExpItemLayer = class("ExpItemLayer")
ExpItemLayer.__index = ExpItemLayer

function ExpItemLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, ExpItemLayer)
    return target
end


function ExpItemLayer:onEnter() 
    self.param.app.clientTCP:send("getHero",{getType=1},handler(self, self.heroBack))
end

function ExpItemLayer:onExit()

end

function ExpItemLayer.create(param)
    local layerCsb = ExpItemLayer.extend(cc.CSLoader:createNode("ExpItemLayer.csb")) 
    if layerCsb then 
        layerCsb:init(param)
    end
    return layerCsb
end

function ExpItemLayer:addNodeEvent( ... )
    local function onNodeEvent(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function ExpItemLayer:init(param)
    --添加node事件
    self:addNodeEvent()

    self.param = param
    self.app = param.app
    local tab = self.param.tab
    local  id = tab.id
    local num = tab.num

    self.ListView = self:getChildByName("ListView")

    self.Item = self:getChildByName("Image_bg"):getChildByName("Image_msg"):getChildByName("Image_icon")

    self.text = self:getChildByName("Image_bg"):getChildByName("Image_msg"):getChildByName("Text")

    self.backBtn = self:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)
    
    local kImgView = ccui.ImageView:create()
    kImgView:loadTexture(gameUtil.getItemIconRes(id))
    self.Item:addChild(kImgView)
    kImgView:setPosition(self.Item:getContentSize().width * 0.5, self.Item:getContentSize().height * 0.5)

    local t = INITLUA:getItemByid( id ).Name .. ":"..num
    self.text:setText(t)
end

function ExpItemLayer:heroBack(event)
    local type = event.type
    local playerHero = event.playerHero
    self.playerHero = playerHero
    if type ~= 0 then
        return
    end
    local camp = mm.data.playerinfo.camp
    local unitRes = INITLUA:getUnitResByCamp(camp)

    local heroTab = playerHero

    

    -- --排序
    -- local sortRules = {
        
    --     {
    --         func = function(v)
    --             return v.exp
    --         end,
    --         isAscending = false       
    --     },
    --     {
    --         func = function(v)
    --             return v.Name
    --         end,
    --         isAscending = false
    --     },
    -- }
    -- heroTab = util.powerSort(heroTab, sortRules)


    local ListView = self.ListView

    for i=1,#heroTab do
        local suxinImgTab = {{"icon_fs_normal.png", "icon_fs_disable.png"},
                            {"icon_mt_normal.png", "icon_mt_disable.png"},
                            {"icon_dps_normal.png", "icon_dps_disable.png"},
                            }
        local itemRes = "ExpItem.csb"
        local suxinImg = suxinImgTab[ gameUtil.getHeroTab( heroTab[i].id ).herosuxin ][1]
        

        local custom_item = ccui.Layout:create()
        local HeroItem = cc.CSLoader:createNode(itemRes)
        custom_item:addChild(HeroItem)
        custom_item:setContentSize(HeroItem:getContentSize())
        ListView:pushBackCustomItem(custom_item)

        --HeroItem:getChildByName("Image_bg"):getChildByName("Text_name"):setText(gameUtil.getHeroTab( heroTab[i].id ).Name)
        HeroItem:getChildByName("Image_bg"):getChildByName("Image_icon"):loadTexture(gameUtil.getHeroIcon(gameUtil.getHeroTab( heroTab[i].id ).ID))

        --HeroItem:getChildByName("Image_bg"):getChildByName("Text_lv"):setText(gameUtil.getHeroLv(heroTab[i].exp))
            
        local nameText = HeroItem:getChildByName("Image_bg"):getChildByName("Text_name")
        local c, v = gameUtil.getColor(heroTab[i].jinlv)
        nameText:setColor(c)
        if v > 0 then
            nameText:setText(gameUtil.getHeroTab( heroTab[i].id ).Name .. "  +" .. v)
        else
            nameText:setText(gameUtil.getHeroTab( heroTab[i].id ).Name)
        end
        local lvText = HeroItem:getChildByName("Image_bg"):getChildByName("Text_lv")
        lvText:setText("Lv:".. gameUtil.getHeroLv(heroTab[i].exp,heroTab[i].jinlv))



        
        HeroItem:getChildByName("Image_bg"):getChildByName("Image_suxin"):loadTexture("res/UI/"..suxinImg)
        
        local maxXin = 5
        for j=1,maxXin do
            if j > heroTab[i].xinlv then
                HeroItem:getChildByName("Image_bg"):getChildByName("Image_xin".."_0"..j):loadTexture("res/UI/".."icon_xingxing_disable.png")
            else
                HeroItem:getChildByName("Image_bg"):getChildByName("Image_xin".."_0"..j):loadTexture("res/UI/".."icon_xingxing_normal.png")
            end
        end

        local bar = HeroItem:getChildByName("Image_bg"):getChildByName("LoadingBar")
        bar:setPercent(80)
        bar:setPercent(heroTab[i].exp / INITLUA:getBckResTotalExpByLv( heroTab[i].jinlv,gameUtil.getHeroLv(heroTab[i].exp,heroTab[i].jinlv)) * 100)

        local barText = HeroItem:getChildByName("Image_bg"):getChildByName("Text_bars")
        barText:setText(heroTab[i].exp .. "/"..INITLUA:getBckResTotalExpByLv( heroTab[i].jinlv,gameUtil.getHeroLv(heroTab[i].exp, heroTab[i].jinlv) ))

        HeroItem:getChildByName("Image_bg"):addTouchEventListener(handler(self, self.addBtnCbk))
        HeroItem:getChildByName("Image_bg"):setTag(i)

    end

end

function ExpItemLayer:upExpBack( event )
    local type  = event.type
    if 0 == type then
        mm.data.playerItem = event.playerItem
        mm.data.playerHero = event.playerHero
        self.param.tab.num = self.param.tab.num - 1  

        local expNum = INITLUA:getItemByid( self.param.tab.id ).itemNum

        local t = INITLUA:getItemByid( self.param.tab.id ).Name .. ":"..self.param.tab.num
        self.text:setText(t)

        local heroTab = self.playerHero[self.curTag]
        --heroTab.exp = heroTab.exp + expNum

        for i=1,#mm.data.playerHero do
            if mm.data.playerHero[i].id == heroTab.id then
                heroTab.exp = mm.data.playerHero[i].exp
                heroTab.lv = mm.data.playerHero[i].lv
            end
        end
        --self.curBtn:getChildByName("Text_lv"):setText(gameUtil.getHeroLv(heroTab.exp))

        local nameText = self.curBtn:getChildByName("Text_name") 
        local c, v = gameUtil.getColor(heroTab.jinlv)
        nameText:setColor(c)
        if v > 0 then
            nameText:setText(gameUtil.getHeroTab( heroTab.id ).Name .. "  +" .. v)
        else
            nameText:setText(gameUtil.getHeroTab( heroTab.id ).Name)
        end
        local lvText = self.curBtn:getChildByName("Text_lv")
        lvText:setText("lv:".. gameUtil.getHeroLv(heroTab.exp, heroTab.jinlv))



        local bar = self.curBtn:getChildByName("LoadingBar")
        bar:setPercent(80)
        bar:setPercent(heroTab.exp / INITLUA:getBckResTotalExpByLv( heroTab.jinlv,gameUtil.getHeroLv(heroTab.exp,heroTab.jinlv) ) * 100)

        local barText = self.curBtn:getChildByName("Text_bars")
        barText:setText(heroTab.exp .. "/"..INITLUA:getBckResTotalExpByLv( heroTab.jinlv,gameUtil.getHeroLv(heroTab.exp,heroTab.jinlv) ) )

        game:dispatchEvent({name = EventDef.UI_MSG, code = "heroUpExp"})

    elseif type == 1 then
        gameUtil:addTishi({p = self, s = event.message}) -- 英雄等级达到最高，需进阶或到Max
    else
        gameUtil:addTishi({p = self, s = "缺少该物品"} )
    end
end

function ExpItemLayer:addBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curTag = widget:getTag()
        local heroId = self.playerHero[self.curTag].id
        self.curBtn = widget
        self.app.clientTCP:send("heroUpExp",{getType=1,heroId = heroId, itemId = self.param.tab.id},handler(self, self.upExpBack))
    end
end

function ExpItemLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return ExpItemLayer
