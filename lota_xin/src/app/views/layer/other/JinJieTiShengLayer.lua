local JinJieTiShengLayer = class("JinJieTiShengLayer", require("app.views.mmExtend.LayerBase"))
JinJieTiShengLayer.RESOURCE_FILENAME = "Herojinjietisheng.csb"

function JinJieTiShengLayer:onCreate(param)
    self.oldHero = param.oldHero
    self.newHero = util.copyTab(param.oldHero)
    self.newHero.jinlv = self.newHero.jinlv + 1
    self.newHero.exp = 0
    self.Node = self:getResourceNode()
    local image_bg = self.Node:getChildByName("Image_bg")

    image_bg:setVisible(false)
    self.Node:getChildByName("Panel_touch"):setOpacity(0)
    performWithDelay(self, function()
        image_bg:setVisible(true)
        self.Node:getChildByName("Panel_touch"):setOpacity(255)

        if mm.GuildId == 10023 then
            Guide:setHandVisible(false)
            Guide:setImageViewVisible(false)
            
            performWithDelay(self, function()
                Guide:setHandVisible(true)
                Guide:setImageViewVisible(true)
                Guide:startGuildById(10024, self.backBtn)
            end, 1.5)
        end
    end, 1.3)


    local button_back = image_bg:getChildByName("Button_back")
    gameUtil.setBtnEffect(button_back)
    button_back:addTouchEventListener(handler(self, self.back))
    self.backBtn = button_back

    local touxiang1 = image_bg:getChildByName("Image_bg01"):getChildByName("Image_touxiang1")
   	local touxiang2 = image_bg:getChildByName("Image_bg01"):getChildByName("Image_touxiang2")
    local Image_icon1 = gameUtil.createTouXiang(self.oldHero)
    touxiang1:addChild(Image_icon1)
    Image_icon1:setPositionY(Image_icon1:getContentSize().height * 0.5)
    local Image_icon2 = gameUtil.createTouXiang(self.newHero)
    touxiang2:addChild(Image_icon2)
    Image_icon2:setPositionY(Image_icon2:getContentSize().height * 0.5)
    local attributeTab = gameUtil.getHeroDiff(self.oldHero, self.newHero)
    for i=1, 6 do
    	local textOld = image_bg:getChildByName("Text_"..i.."_1")
    	local textChange = image_bg:getChildByName("Text_"..i.."_2")
    	if i == 4 then
            textOld:setString(string.format("%.1f", attributeTab[i].old).."%")
            if attributeTab[i].change >= 0 then
                textChange:setString(" +"..string.format("%.1f", attributeTab[i].change).."%")
            else
                textChange:setString(string.format("%.1f", attributeTab[i].change).."%")
            end
        else
            textOld:setString(string.format("%.1f", attributeTab[i].old))
            if attributeTab[i].change >= 0 then
                textChange:setString(" +"..string.format("%.1f", attributeTab[i].change))
            else
                textChange:setString(string.format("%.1f", attributeTab[i].change))
            end
        end
    end
end

function JinJieTiShengLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function JinJieTiShengLayer:back(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if mm.GuildId ~= 10023 then
            self:removeFromParent()
            if mm.GuildId == 10024 then
                mm:clearLayer()
                -- Guide:startGuildById(10025, mm.GuildScene.jingyanBtn)
                Guide:startGuildById(15001, mm.GuildScene.duanweiBtn)
            end
        end
    end
end

function JinJieTiShengLayer:onEnter()
    
end

function JinJieTiShengLayer:onExit()
    
end

function JinJieTiShengLayer:onEnterTransitionFinish()
    
end

function JinJieTiShengLayer:onExitTransitionStart()
    
end

function JinJieTiShengLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return JinJieTiShengLayer