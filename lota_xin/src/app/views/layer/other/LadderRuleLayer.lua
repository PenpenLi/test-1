local LadderRuleLayer = class("LadderRuleLayer", require("app.views.mmExtend.LayerBase"))
LadderRuleLayer.RESOURCE_FILENAME = "duanweiguize.csb"

function LadderRuleLayer:onEnter()

end

function LadderRuleLayer:onExit()

end

function LadderRuleLayer:onCleanup()
    self:clearAllGlobalEventListener()
end


function LadderRuleLayer:onCreate()
    self:init()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function LadderRuleLayer:init()
    self.Node = self:getResourceNode()

    -- 关闭按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self:initLayerUI()

end

function LadderRuleLayer:initLayerUI( ... )
    local ruleRootNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_9")
    local ruleRootNodeH = ruleRootNode:getContentSize().height
    local itemH = 210
    local offsetY = (ruleRootNodeH - itemH * 3) / 4

    local dropOutRes = INITLUA:getDropOutRes()
    
    local key_table = {}  
    --取出所有的键  
    -- for key,_ in pairs(dropOutRes) do  
    --     table.insert(key_table,key)  
    -- end  
    -- --对所有键进行排序  
    -- table.sort(key_table, function(a,b)
    --     return a > b
    -- end)
    
    -- 先简单修改
    table.insert(key_table,1093677623)  
    table.insert(key_table,1093677622)
    table.insert(key_table,1093677621)
    table.insert(key_table,1093677616)
    table.insert(key_table,1093677365)
    table.insert(key_table,1093677360)
    table.insert(key_table,1093677109)


    for i,key in pairs(key_table) do  
        local iconNodeName = "Image_"..i
        local icon = ruleRootNode:getChildByName(iconNodeName)
        --icon:setVisible(false)
        icon:setOpacity(0)
        icon:setTouchEnabled(true)
        local node = cc.Node:create()
        node:setContentSize(icon:getContentSize())
        node:setAnchorPoint(cc.p(0.5,1))
        ruleRootNode:addChild(node)

        -- local res = dropOutRes[key].Res

        local res = "icon1"
    
    local curDuanWei = tonumber(dropOutRes[key].ID)
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

    -- local index = INITLUA:getDropOutRes()[curDuanWei]['Res']
    -- gameUtil.addArmatureFile("res/Effect/uiEffect/"..res.."/"..res..".ExportJson")
    -- local anime = ccs.Armature:create(res)
    -- -- 将胜利文字替换为高清的
    -- -- local duanwei = ccs.Skin:create("res/icon/jiemian/"..index..".png")
    -- -- local text_bone = anime:getBone("tp")
    -- -- text_bone:removeDisplay(0)
    -- -- text_bone:addDisplay(duanwei, 0)
    -- -- text_bone:setScale(0.7)

    -- local animation = anime:getAnimation()
    -- anime:setScale(1.2)
    -- node:removeAllChildren()
    -- node:addChild(anime,10)
    -- anime:setName('duanwei')
    -- anime:setTag(curDuanWei)
    -- animation:play(res)

    -- anime:setAnchorPoint(cc.p(0.27,0.20))

    local anime = gameUtil.createSkeAnmion( {name = res, scale = 1.4} )
    anime:setAnimation(0, "stand", true)
    node:removeAllChildren()
    node:addChild(anime,10)
    anime:setName('duanwei')
    anime:setTag(curDuanWei)
    anime:setPosition(61,40)

    if res ~= "ds" and res ~= "zqwz" then
        local index = INITLUA:getDropOutRes()[curDuanWei]['RankIconNum']
        anime:setAttachment(res .."=",res .."=" ..index )
    end

        -- local path = "res/Effect/uiEffect/"..res.."/"..res..".ExportJson"
        -- gameUtil.addArmatureFile(path)
        -- local anime = ccs.Armature:create(res)
        -- local animation = anime:getAnimation()
        -- anime:setScale(1.6)
        -- node:addChild(anime)
        -- --anime:setAnchorPoint(cc.p(0.5,0.5))
        -- anime:setAnchorPoint(cc.p(0.27,0.20))
        -- --anime:setPosition(61,61)
        -- animation:play(res)


        local ttfConfig = {}
        ttfConfig.fontFilePath = "font/youyuan.TTF"
        ttfConfig.fontSize = 25
        ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
        ttfConfig.customGlyphs = nil
        ttfConfig.distanceFieldEnabled = true
        ttfConfig.outlineSize = 0
        

        local diamondNode = cc.Node:create()
        diamondNode:setAnchorPoint(cc.p(0.5,0.5))

        local diamondIcon = cc.Sprite:create("res/UI/pc_zuanshi.png")
        diamondIcon:setAnchorPoint(cc.p(0.0,0.5))
        diamondIcon:setPosition(cc.p(0, 0))

        diamondNode:addChild(diamondIcon)

        local dropKey = dropOutRes[key].ID

        local honorValue = 0
        local goldValue = 0

        local rankGift = INITLUA:getRankGift()
        for k,v in pairs(rankGift) do
            if v.DropFrom == dropKey and v.RankGiftLevel == 1 then
                honorValue = v.RankGiftGlory
                goldValue = v.RankGiftGold
                break
            end
        end

        local diamondText = cc.Label:createWithTTF(ttfConfig,honorValue,cc.TEXT_ALIGNMENT_LEFT,300)
        diamondText:setAnchorPoint(cc.p(0.0,0.5))
        diamondText:setPosition(cc.p(diamondIcon:getContentSize().width, 0))
        diamondText:setTextColor( cc.c4b(255, 255, 255, 255) )
        --label:enableGlow(cc.c4b(255, 255, 0, 255))
        diamondNode:addChild(diamondText)

        node:addChild(diamondNode)


        local DH = diamondIcon:getContentSize().height
        local DW = diamondIcon:getContentSize().width + diamondText:boundingBox().width
        diamondNode:setPosition(0,-DH)


        local goldNode = cc.Node:create()
        goldNode:setAnchorPoint(cc.p(0.5,0.5))

        local goldIcon = cc.Sprite:create("res/UI/pc_jinbi.png")
        goldIcon:setAnchorPoint(cc.p(0.0,0.5))
        goldIcon:setPosition(cc.p(0, 0))

        goldNode:addChild(goldIcon)

        local goldText = cc.Label:createWithTTF(ttfConfig,goldValue,cc.TEXT_ALIGNMENT_LEFT,300)
        goldText:setAnchorPoint(cc.p(0.0,0.5))
        goldText:setPosition(cc.p(goldIcon:getContentSize().width, 0))
        goldText:setTextColor( cc.c4b(255, 255, 255, 255) )
        --label:enableGlow(cc.c4b(255, 255, 0, 255))
        goldNode:addChild(goldText)

        node:addChild(goldNode)


        local GH = goldIcon:getContentSize().height
        local GW = goldIcon:getContentSize().width + goldText:boundingBox().width
        goldNode:setPosition(0,-GH-DH)



        local nodeOffsetY = offsetY
        if i == 1 then
            nodeOffsetY = offsetY * 3 + itemH * 3 
        elseif i == 2 or i == 3 then
            nodeOffsetY = offsetY * 2 + itemH * 2 
        else
            nodeOffsetY = offsetY + itemH
        end

        local nodeOffsetX = icon:getPosition()
        node:setPosition(cc.p(nodeOffsetX,nodeOffsetY - 20))

        icon:setTag(dropKey)
        icon:addTouchEventListener(handler(self, self.onClick))
    end
    
    local text = gameUtil.GetMoGameRetStr( 990005 )
    local decNode = self.Node:getChildByName("Image_bg"):getChildByName("Text_2")
    decNode:setString(text)
end

function LadderRuleLayer:globalEventsListener( event )
    
end

function LadderRuleLayer:onClick(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local key = widget:getTag()
        local rewardLayer = require("src.app.views.layer.LadderRewardLayer").new(key)
        local size  = cc.Director:getInstance():getWinSize()
        self:getParent():addChild(rewardLayer)
        rewardLayer:setContentSize(cc.size(size.width, size.height))
        
        ccui.Helper:doLayout(rewardLayer)
    end
end


function LadderRuleLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

return LadderRuleLayer


