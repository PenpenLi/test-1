--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local MailItemWindow = class("MailItemWindow", require("app.views.mmExtend.LayerBase"))
MailItemWindow.RESOURCE_FILENAME = "youjianman.csb"

function MailItemWindow:onCleanup()

end

function MailItemWindow:onEnter()

end

function MailItemWindow:onExit()

end

function MailItemWindow:onCreate(param)
    self:init(param)
end

function MailItemWindow:init(param)
    self:initUI(param)
end

function MailItemWindow:initUI( param )
    self.Node = self:getResourceNode()
    local panel = self.Node:getChildByName("Panel_touch")
    self:setContentSize(self.Node:getContentSize())
    panel:setSwallowTouches(true)

    local rewardBtn = self.Node:getChildByName("Image_di"):getChildByName("Button_2")
    rewardBtn:addTouchEventListener(handler(self, self.rewardBtc))
    gameUtil.setBtnEffect(rewardBtn)

    local cleanBtn = self.Node:getChildByName("Image_di"):getChildByName("Button_1")
    cleanBtn:addTouchEventListener(handler(self, self.cleanBtc))
    gameUtil.setBtnEffect(cleanBtn)

    local listView = self.Node:getChildByName("Image_di"):getChildByName("Image_2"):getChildByName("ListView_2")
    --param = {id = mail.id,equip = realFullEquip,hunshi = realFullHunshi,item = realFullItem}


    local icon_item = ccui.Layout:create()
    self.mailID = param.param.id

    local lineNum = 5
    local showNum = 0
    local itemWidth = 90

    local showEquip = param.param.equip
    local showHunshi = param.param.hunshi
    local showItem = param.param.item
    local equipFull = param.param.equipFull
    local hunshiFull = param.param.hunshiFull
    local itemFull = param.param.itemFull

    local offsetSrcX = (listView:getContentSize().width - lineNum * itemWidth)/(lineNum+1)
    
    if showEquip then
        showNum = showNum + (#showEquip)
    end
    if showHunshi then
        showNum = showNum + (#showHunshi)
    end
    if showItem then
        showNum = showNum + (#showItem)
    end

    local H = math.ceil((showNum/lineNum)) * itemWidth * 0.9
    local index = -1

    for i,value in ipairs(showEquip) do
        index = index + 1
        local icon = gameUtil.createEquipItem( value.id , value.num)
        icon:setAnchorPoint(cc.p(0.0,1.0))
        local offsetX = (index % lineNum) * itemWidth + ((index%lineNum) + 1) * offsetSrcX
        local offsetY = math.floor((index / lineNum)) * itemWidth
        icon:setPosition(cc.p(offsetX,H-offsetY))
        icon_item:addChild(icon)
    end
    for i,value in ipairs(showHunshi) do
        index = index + 1
        local icon = gameUtil.createEquipItem( value.id , value.num)
        icon:setAnchorPoint(cc.p(0.0,1.0))
        local offsetX = (index % lineNum) * itemWidth + ((index%lineNum) + 1) * offsetSrcX
        local offsetY = math.floor((index / lineNum)) * itemWidth
        icon:setPosition(cc.p(offsetX,H-offsetY))
        icon_item:addChild(icon)
    end
    for i,value in ipairs(showItem) do
        index = index + 1
        local icon = gameUtil.createItemWidget( value.id , value.num)
        icon:setAnchorPoint(cc.p(0.0,1.0))
        local offsetX = (index % lineNum) * itemWidth + ((index%lineNum) + 1) * offsetSrcX
        local offsetY = math.floor((index / lineNum)) * itemWidth
        icon:setPosition(cc.p(offsetX,H-offsetY))
        icon_item:addChild(icon)
    end

    icon_item:setContentSize(listView:getContentSize().width, (1 + math.floor((index / lineNum))) * itemWidth)
    listView:pushBackCustomItem(icon_item)

    local ttfConfig = {}
    ttfConfig.fontFilePath = "font/youyuan.TTF"
    ttfConfig.fontSize = 25
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 1
    
    local textStr = ""
    if equipFull > 0 then
        textStr = "装备格子满了"
    end
    if hunshiFull > 0 then
        textStr = "魂石格子满了"
    end
    if itemFull > 0 then
        textStr = "消耗品格子满了"
    end

    local label = cc.Label:createWithTTF(ttfConfig,textStr,cc.TEXT_ALIGNMENT_LEFT)
    label:setAnchorPoint(cc.p(0.0,0.0))
    label:setPosition(cc.p(listView:getContentSize().width * 0.04, 0))
    label:setTextColor( cc.c4b(255, 255, 255, 255) )
    --label:enableGlow(cc.c4b(255, 255, 0, 255))
    --label:setString("")
    label:setMaxLineWidth(listView:getContentSize().width * 0.92)
    
    local label_item = ccui.Layout:create()
    label_item:addChild(label)
    label_item:setContentSize(label:getContentSize().width,label:getContentSize().height *1.3)
    listView:pushBackCustomItem(label_item)
end

function MailItemWindow:rewardBtc(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then

        mm.req("mailProcess",{type = 1, id = self.mailID})


        --mm.req("buySomeThing",{getType = 1, buyType = 2, buyItemInfo = buyItemInfo})

        self:removeFromParent()
    end
end

function MailItemWindow:cleanBtc(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return MailItemWindow


