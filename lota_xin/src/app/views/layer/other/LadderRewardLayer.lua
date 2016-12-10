--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local LadderRewardLayer = class("LadderRewardLayer", require("app.views.mmExtend.LayerBase"))
LadderRewardLayer.RESOURCE_FILENAME = "duanweiJL.csb"

function LadderRewardLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function LadderRewardLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function LadderRewardLayer:onEnter()
    
end

function LadderRewardLayer:onExit()
    
end

function LadderRewardLayer:onEnterTransitionFinish()
    
end

function LadderRewardLayer:onExitTransitionStart()
    
end

function LadderRewardLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function LadderRewardLayer:init(param)
    self:initLayerUI(param)
end

function LadderRewardLayer:initLayerUI( param )
    -- 关闭按钮
    self.Node = self:getResourceNode()
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)
    
    --local size  = cc.Director:getInstance():getWinSize()
    --ladderItem:setContentSize(cc.size(size.width, size.height))
    local dropOutRes = INITLUA:getDropOutRes()
    local name = dropOutRes[param].Name
    local res = dropOutRes[param].Res

    local curDuanWei = tonumber(dropOutRes[param].ID)
    if curDuanWei == 1093677105 
        or curDuanWei == 1093677106 
        or curDuanWei == 1093677107 
        or curDuanWei == 1093677108 
        or curDuanWei == 1093677109 then
        res = "icon1"
    elseif curDuanWei == 1093677110 
        or curDuanWei == 1093677111 
        or curDuanWei == 1093677112 
        or curDuanWei == 1093677113 
        or curDuanWei == 1093677360 then
        res = "icon2"
    elseif curDuanWei == 1093677361 
        or curDuanWei == 1093677362 
        or curDuanWei == 1093677363 
        or curDuanWei == 1093677364 
        or curDuanWei == 1093677365 then
        res = "icon3"
    elseif curDuanWei == 1093677366 
        or curDuanWei == 1093677367 
        or curDuanWei == 1093677368 
        or curDuanWei == 1093677369 
        or curDuanWei == 1093677616 then
        res = "icon4"
    elseif curDuanWei == 1093677617 
        or curDuanWei == 1093677618 
        or curDuanWei == 1093677619 
        or curDuanWei == 1093677620 
        or curDuanWei == 1093677621 then
        res = "icon5"
    elseif curDuanWei == 1093677622  then
        res = "ds"
    elseif curDuanWei == 1093677623 then
        res = "zqwz"
    else
        
    end

    self.ladderIcon = self.Node:getChildByName("Node_1")
    self.textItem = self.Node:getChildByName("Text_2_0")
    self.textItem:setString(dropOutRes[tonumber(mm.data.curDuanWei)].Name)
    self.textItem:setFontSize(24)

    local ListView = self.Node:getChildByName("ListView")
    
    -- gameUtil.addArmatureFile("res/Effect/uiEffect/"..res.."/"..res..".ExportJson")
    -- local anime = ccs.Armature:create(res)
    -- anime:setScale(1.2)
    -- --anime:setAnchorPoint(cc.p(0.5,0.5))
    -- local animation = anime:getAnimation()
    -- self.ladderIcon:addChild(anime,10)
    -- --anime:setPosition(61,61)
    -- animation:play(res)

    local anime = gameUtil.createSkeAnmion( {name = res, scale = 1.4} )
    anime:setAnimation(0, "stand", true)
    self.ladderIcon:removeAllChildren()
    self.ladderIcon:addChild(anime,10)
    anime:setName('duanwei')
    anime:setTag(curDuanWei)

    if res ~= "ds" and res ~= "zqwz" then
        local index = INITLUA:getDropOutRes()[curDuanWei]['RankIconNum']
        anime:setAttachment(res .."=",res .."=" ..index )
    end

    local dropKey = dropOutRes[param].ID
        
    local rankGift = INITLUA:getRankGift()

    local showList = {}
    for k,v in pairs(rankGift) do
        if v.DropFrom == dropKey then
            table.insert(showList, v)
        end
    end

    table.sort( showList, function( a, b )
        return a.RankGiftLevel < b.RankGiftLevel
    end)

    for i=1,#showList do
        local custom_item = ccui.Layout:create()
        local item = cc.CSLoader:createNode("dwjiangliLayer.csb")
        local itemIcon = item:getChildByName("Image_bg"):getChildByName("Node_1")
        --
        --item:setAnchorPoint(cc.p(0.1,0.0))
        --local itemHeight = item:getContentSize().height
        --local itemWidth = item:getContentSize().width
        custom_item:addChild(item)

        custom_item:setContentSize(item:getContentSize()) 
        ListView:pushBackCustomItem(custom_item)

        if i < 4 then
            local sprite = cc.Sprite:create("res/icon/jiemian/icon_paihang_"..i..".png")
            itemIcon:addChild(sprite)
        else
            local ttfConfig = {}
            ttfConfig.fontFilePath = "font/huakang.TTF"
            ttfConfig.fontSize = 30
            ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
            ttfConfig.customGlyphs = nil
            ttfConfig.distanceFieldEnabled = true
            ttfConfig.outlineSize = 1

            local range = showList[i].RankGiftRange
            local text = range[1].."-"..range[2]

            local label = cc.Label:createWithTTF(ttfConfig,text,cc.TEXT_ALIGNMENT_LEFT,300)
            label:setAnchorPoint(cc.p(0,0))
            label:setPosition(cc.p(-20, -20))
            label:setTextColor( cc.c4b(255, 255, 255, 255) )
            label:enableGlow(cc.c4b(255, 255, 0, 255))

            itemIcon:addChild(label)
        end


        local goldIcon = item:getChildByName("Image_bg"):getChildByName("Image_2")
        local honorIcon = item:getChildByName("Image_bg"):getChildByName("Image_3")

        goldIcon:loadTexture("res/UI/pc_jinbi.png")
        honorIcon:loadTexture("res/UI/pc_zuanshi.png")

        local goldText = item:getChildByName("Image_bg"):getChildByName("Text_jinbi")
        local honorText = item:getChildByName("Image_bg"):getChildByName("Text_zuanshi")

        goldText:setString(showList[i].RankGiftGold)
        honorText:setString(showList[i].RankGiftGlory)
    end
end

function LadderRewardLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function LadderRewardLayer:eventListener( event )

end

return LadderRewardLayer


