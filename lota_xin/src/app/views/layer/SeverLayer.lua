local SeverLayer = class("SeverLayer", require("app.views.mmExtend.LayerBase"))
SeverLayer.RESOURCE_FILENAME = "SeverLayer.csb"

function SeverLayer:onEnter()
    --self:init()
end

function SeverLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function SeverLayer:onExit()
    
end

function SeverLayer:onCreate(param)
    self:init(param)
end

function SeverLayer:init(param)
    self.scene = param.scene
    self.severList = param.severList
    self.Node = self:getResourceNode()
    util.tableSort(self.severList,"AreaCount",false)

    self.listView = self.Node:getChildByName("Image_bg"):getChildByName("ListView")
    
    local lastItemNode = self.Node:getChildByName("Image_bg"):getChildByName("Image_2")
    lastItemNode:setVisible(false)
    local lastItem = cc.CSLoader:createNode("severItem.csb")
    lastItem:setAnchorPoint(cc.p(0.5,0.5))
    local x,y = lastItemNode:getPosition()
    lastItem:setPosition(cc.p(x + lastItem:getContentSize().width*0.5,y + lastItem:getContentSize().height*0.5))
    self.Node:getChildByName("Image_bg"):addChild(lastItem)

    local info = {}
    local currentServer = gameUtil.getDefaultServerInfo(self.severList)
    info.index = currentServer.Areaid
    info.name = currentServer.Name
    info.serverTag = "火爆"
    info.level = currentServer.lv

    -- local severId = cc.UserDefault:getInstance():getIntegerForKey("severId",0)

    -- local info = {}
    -- if 0 == severId then
    --     info.index = self.severList[1].id
    --     info.name = self.severList[1].Name
    --     info.serverTag = "火爆"
    --     info.level = nil
    -- else
    --     for k,v in pairs(self.severList) do
    --         if v.id == severId then
    --             info.index = v.id
    --             info.name = v.Name
    --             info.serverTag = "火爆"
    --             info.level = v.lv
    --             break
    --         end
    --     end
    -- end

    -- -------如果找不到大区----------
    -- if info.index == nil then
    --     info.index = self.severList[1].id
    --     info.name = self.severList[1].Name
    --     info.serverTag = "火爆"
    --     info.level = nil
    -- end

    self:setItemNodeInfo(lastItem, info)
    local text = self.Node:getChildByName("Image_bg"):getChildByName("Image_4"):getChildByName("Image_5"):getChildByName("Text_5")
    -- text:setString(info.index.."区".." "..info.name)
    text:setString(info.name)
    cc.UserDefault:getInstance():setStringForKey("severId",info.index)
    

    local num = #self.severList
    local groupNum = math.ceil(num / 2)
    local width = self.listView:getContentSize().width
    for i=1,groupNum do
        local node = ccui.Layout:create()
        node:setTouchEnabled(true)
        for j=1,2 do
            local index = (i - 1) * 2 + j
            if index > num then
                break
            end
            local itemCsb = cc.CSLoader:createNode("severItem1.csb")
            local itemSize = itemCsb:getContentSize()
            local info = {}
            
            info.index = self.severList[index].id
            info.name = self.severList[index].Name
            info.serverTag = "火爆"
            info.level = self.severList[index].lv

            self:setItemNodeInfo(itemCsb, info)
            node:addChild(itemCsb)

            itemCsb:setAnchorPoint(cc.p(0.5,0.5))
            if index % 2 == 0 then
                --itemCsb:setAnchorPoint(cc.p(1,0))
                itemCsb:setPosition(cc.p(width,itemSize.height*0.5))
            else
                itemCsb:setPosition(cc.p(itemSize.width,itemSize.height*0.5))
            end
            node:setContentSize(width,itemSize.height)
        end
        
        self.listView:pushBackCustomItem(node)
    end

    self.startBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_1")
    self.startBtn:addTouchEventListener(handler(self, self.startBtnCbk))
    gameUtil.setBtnEffect(self.startBtn)
end

function SeverLayer:setItemNodeInfo( item, info )
    local lastBtnNode = item:getChildByName("Image_btn")

    if lastBtnNode:getChildByName("Image_8") == nil then
        
    end
    lastBtnNode:getChildByName("Image_8"):loadTexture("res/icon/jiemian/icon_xiyou.png")
    lastBtnNode:getChildByName("Image_8"):setVisible(false)
    lastBtnNode:getChildByName("Image_3"):setVisible(false)
    lastBtnNode:getChildByName("Text_lv"):setVisible(false)

    -- lastBtnNode:getChildByName("Text_qu"):setString(info.index.."区")
    -- lastBtnNode:getChildByName("Text_quname"):setString(info.name)
    lastBtnNode:getChildByName("Text_qu"):setString(info.name)
    lastBtnNode:getChildByName("Text_quname"):setString("")

    if info.level ~= nil then
        lastBtnNode:getChildByName("Image_3"):setVisible(true)
        lastBtnNode:getChildByName("Text_lv"):setString("Lv:"..info.level)
        lastBtnNode:getChildByName("Text_lv"):setVisible(true)
    end

    if info.serverTag ~= nil and info.serverTag ~= "" then
        lastBtnNode:getChildByName("Image_8"):getChildByName("Text_5"):setString(info.serverTag)
        lastBtnNode:getChildByName("Image_8"):setVisible(true)
    end

    lastBtnNode:setTag(tonumber(info.index))
    lastBtnNode:setTouchEnabled(true)
    lastBtnNode:setSwallowTouches(false)
    lastBtnNode:setAnchorPoint(cc.p(0.5,0.5))
    lastBtnNode:addTouchEventListener(handler(self, self.lastBtnCbk))
end

function SeverLayer:lastBtnCbk(widget,touchkey)
    --widget:setAnchorPoint(cc.p(0.5,0.5))
    if touchkey == ccui.TouchEventType.began then
        local action = cc.ScaleTo:create(0.1,0.95)
        widget:runAction(action)
    elseif touchkey == ccui.TouchEventType.moved then

    elseif touchkey == ccui.TouchEventType.canceled then
        local action = cc.ScaleTo:create(0.1,1)
        widget:runAction(action)
    elseif touchkey == ccui.TouchEventType.ended then
        local action = cc.ScaleTo:create(0.1,1)
        widget:runAction(action)
        
        self.isMove = false
        
        local index = tostring(widget:getTag())

        local text = self.Node:getChildByName("Image_bg"):getChildByName("Image_4"):getChildByName("Image_5"):getChildByName("Text_5")
        for k,v in pairs(self.severList) do
            if v.Areaid == index then
                local text = self.Node:getChildByName("Image_bg"):getChildByName("Image_4"):getChildByName("Image_5"):getChildByName("Text_5")
                -- text:setString(v.Areaid.."区".." "..v.Name)
                text:setString(v.Name)
                break
            end
        end
        cc.UserDefault:getInstance():setStringForKey("severId",index)
        ---[[
        game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshServerInfo_UI"})
        --self:removeFromParent()
        --]]
    end
end

function SeverLayer:startBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        game:dispatchEvent({name = EventDef.UI_MSG, code = "START_GAME"})
    end
end

return SeverLayer
