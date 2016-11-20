local BarrageLayer = class("BarrageLayer", require("app.views.mmExtend.LayerBase"))
BarrageLayer.RESOURCE_FILENAME = "BarrageLayer.csb"

function BarrageLayer:onCreate(param)
    self.tag = param.tag
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener), param.tag)
end

function BarrageLayer:globalEventsListener( event )
    if mm.guaJiReward == nil or (mm.guaJiReward == false and self.tag == "MeleeScene") then
        if event.name == EventDef.SERVER_MSG then
            if event.code == "talk" then
                if not game.iscometoforeground then
                    self:ReceiveTalk(event.t)
                end
            end
        end
    end
end

function BarrageLayer:onEnter()
    
end

function BarrageLayer:onExit()
    
end

function BarrageLayer:onEnterTransitionFinish()
    
end

function BarrageLayer:onExitTransitionStart()
    
end

function BarrageLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function BarrageLayer:init(param)
    self:scheduleUpdateWithPriorityLua(handler(self,self.onDrawUpgradeTimer),0)
    self.labelTab = {}
    self.Node = self:getResourceNode()
    game.BarrageTab = game.BarrageTab or {}
    self.sysTurn = 0
    self.worldTurn = 0
    self.campTurn = 0
    self.sysFlag = 1
    self.sysIndex = 1

    self.Node:getChildByName("Node_1"):getChildByName("Panel_1"):getChildByName("Image_di"):setVisible(false)
    self.Node:getChildByName("Node_1"):getChildByName("Panel_1"):getChildByName("Image_di2"):setVisible(false)

    local data = game.BarrageTab
    for i=1,#data do
        self:updateItem(data[i])
    end

    schedule(self, self.updateSysMessage, 1)

    self.app_ = param
end

function BarrageLayer:ReceiveTalk(event)
    if event.type then
        return
    end
    if event.data.type ~= 1 then
        self:addChatBarrage(event.data)
    else
        self:addSysMessage(event.data)
    end
end

function BarrageLayer:addSysMessage(data)
    self.sysFlag = 0
    game.SysMessage = game.SysMessage or {}

    local realWidth = cc.Director:getInstance():getOpenGLView():getVisibleSize().width
    local t = util.copyTab(data)
    t.PosX = realWidth
    t.PosY = 24
    t.showTime = 30
    if t.fromid ~= 0 then
        t.showTime = 60
        for k,v in pairs(game.SysMessage) do
            if v.fromid ~= 0 then
                table.remove(game.SysMessage, k)
                break
            end
        end
    end

    table.insert(game.SysMessage, t)
    self:addSystemMessage(t)
end

-- 添加系统或玩家消息
function BarrageLayer:addSystemMessage(data)
    local parent = self.Node:getChildByName("Node_1"):getChildByName("Panel_1")
    local Node = cc.CSLoader:createNode("Node_SysMsg.csb")
    local image_di = parent:getChildByName("Image_di")
    local msg = parent:getChildByName("msg")
    if data.fromid == 0 then
        Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_LOGO.png")
        Node:getChildByName("Image_icon"):setScale(0.5, 0.5)
        Node:getChildByName("Text_msg"):setString(data.message)
        image_di = parent:getChildByName("Image_di")
        msg = image_di:getChildByName("msg")
        Node:setName("msg")
    else
        Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_laba.png")
        Node:getChildByName("Image_icon"):setScale(0.3, 0.5)
        Node:getChildByName("Text_msg"):setString(data.fromname..":"..data.message)
        image_di = parent:getChildByName("Image_di2")
        msg = image_di:getChildByName("msg2")
        Node:setName("msg2")
    end

    image_di:setVisible(true)
    if msg ~= nil then
        msg:removeFromParent()
    end
    Node:getChildByName("Text_msg"):setColor(cc.c4b(255,215,0,255))
    Node:setPosition(cc.p(data.PosX,data.PosY))
    image_di:addChild(Node)

    local realWidth = cc.Director:getInstance():getOpenGLView():getVisibleSize().width
    local moveWidth = Node:getChildByName("Text_msg"):getBoundingBox().width
    local function actionEnd()
       Node:setPositionX(realWidth)
    end
    local time = (moveWidth + realWidth) / 200
    local moveBy = cc.MoveBy:create(time, cc.p( - moveWidth - realWidth - 50, 0))
    local sequence = cc.Sequence:create(moveBy, cc.CallFunc:create(actionEnd))
    local action = cc.RepeatForever:create(sequence)
    Node:runAction(action)
    local function del()
        Node:stopAllActions()
        Node:removeFromParent()
        image_di:setVisible(false)
    end
    local sequence2 = cc.Sequence:create(cc.DelayTime:create(data.showTime), cc.CallFunc:create(del))
    Node:runAction(sequence2)
end

function BarrageLayer:addSysAction(data)
    self.sysFlag = 0
    local parent = self.Node:getChildByName("Node_1"):getChildByName("Panel_1")
    parent:getChildByName("Image_di"):setVisible(true)
    if parent:getChildByName("msg") ~= nil then
        parent:getChildByName("msg"):removeFromParent()
    end
    local Node = cc.CSLoader:createNode("Node_SysMsg.csb")
    Node:setName("msg")
    if data.fromid == 0 then
        Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_LOGO.png")
        Node:getChildByName("Image_icon"):setScale(0.5, 0.5)
        Node:getChildByName("Text_msg"):setString(data.message)
    else
        Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_laba.png")
        Node:getChildByName("Image_icon"):setScale(0.3, 0.5)
        Node:getChildByName("Text_msg"):setString(data.fromname..":"..data.message)
    end
    Node:getChildByName("Text_msg"):setColor(cc.c4b(255,215,0,255))
    Node:setPosition(cc.p(data.PosX,data.PosY))
    parent:addChild(Node)

    local rootWidth = parent:getChildByName("Image_di"):getContentSize().width
    local moveWidth = Node:getChildByName("Text_msg"):getBoundingBox().width
    local function actionEnd()
        -- moveWidth = 100
        if moveWidth > 0 then
            self.sysFlag = 1
            -- -----需要左右移动-----
            -- --左移
            -- local moveFirst = cc.MoveBy:create(1, cc.p(-moveWidth, 0))
            -- --右移
            -- local moveSecond = cc.MoveBy:create(1, cc.p(moveWidth, 0))
            -- --重复
            -- local sequence = cc.Sequence:create(moveFirst,cc.DelayTime:create(1),moveSecond,cc.DelayTime:create(1))
            -- local repeatAction = cc.RepeatForever:create(sequence)
            -- Node:runAction(repeatAction)
        end
    end
    local realWidth = cc.Director:getInstance():getOpenGLView():getVisibleSize().width
    if moveWidth < realWidth then
        moveWidth = realWidth * 0.92
    end
    local time = moveWidth / 300
    local action = cc.MoveBy:create(time, cc.p( - moveWidth, 0))
    Node:runAction(cc.Sequence:create(action, cc.CallFunc:create(actionEnd)))
end

function BarrageLayer:addChatBarrage(data)
    --增加单条弹幕
    game.BarrageTab = game.BarrageTab or {}

    local realWidth = cc.Director:getInstance():getOpenGLView():getVisibleSize().width
    local t = util.copyTab(data)
    t.PosX = realWidth
    t.PosY = 0--math.random(0,5) * 10
    t.barrageTag = t.type * 100 + 1

    --系统消息合并到世界消息的弹幕
    if t.type == 5 then
        t.type = 2
    end
    
    if t.type == 2 then
        self.worldTurn = self.worldTurn + 1
        if self.worldTurn > 14 then
            self.worldTurn = 1
        end
        t.barrageTag = self.worldTurn + 200
    elseif t.type == 3 then
        self.campTurn = self.campTurn + 1
        if self.campTurn > 6 then
            self.campTurn = 1
        end
        t.barrageTag = self.campTurn + 300
    end
    
    t.showTime = 0
    t.speed = math.random(3, 5)
    
    for i=#game.BarrageTab,1,-1 do
        if game.BarrageTab[i].barrageTag == t.barrageTag then
            t.showTime = game.BarrageTab[i].showTime + 10
            break
        end
    end
    table.insert(game.BarrageTab, t)
 
end

function BarrageLayer:updateItem(data)
    if data.showTime > 0 then
        return
    end

    local string = data.message --gameUtil.base64Decode(data.acChat)
    local node_index = math.floor(data.barrageTag/100)
    local name_index = math.floor(data.barrageTag%100)
    local parent = self.Node:getChildByName("Node_"..node_index):getChildByName("Panel_"..name_index)

    local Node = cc.CSLoader:createNode("Node_msg.csb")
    if data.type == 3 then
        Node:getChildByName("Image_icon"):setVisible(false)
    end
    if data.camp == 1 then
        Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_qizhilol_select.png")
    else
        Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_qizhidota_select.png")
    end
    Node:getChildByName("Text_msg"):setString(data.fromname..":"..data.message)
    Node:setPosition(cc.p(data.PosX,data.PosY))
    parent:addChild(Node)

    Node:setTag(data.speed)
    data.lenght = Node:getChildByName("Image_icon"):getContentSize().width + Node:getChildByName("Text_msg"):getContentSize().width
    

    local vipLv = data.vipLv
    if vipLv <= 0 then
    elseif vipLv > 0 and vipLv <=4 then
        Node:getChildByName("Text_msg"):setColor(cc.c4b(0,255,0,255))
    elseif vipLv > 4 and vipLv <=7 then
        Node:getChildByName("Text_msg"):setColor(cc.c4b(0,0,255,255))
    elseif vipLv > 7 and vipLv <=10 then
        Node:getChildByName("Text_msg"):setColor(cc.c4b(160,32,240,255))
    elseif vipLv > 10 and vipLv <=13 then
        Node:getChildByName("Text_msg"):setColor(cc.c4b(255,97,0,255))
    elseif vipLv > 13 and vipLv <=15 then
        Node:getChildByName("Text_msg"):setColor(cc.c4b(255,215,0,255))
    end

    table.insert(self.labelTab, Node)
end

function BarrageLayer:checkBarrageTab()
    local flag = 0
    for k,v in pairs(game.BarrageTab) do
        if v.barrageTag == 201 then
            flag = 1
            break
        end
    end
    if flag == 0 then
        self.worldTurn = 0
    end

    local flag = 0
    for k,v in pairs(game.BarrageTab) do
        if v.barrageTag == 301 then
            flag = 1
            break
        end
    end
    if flag == 0 then
        self.campTurn = 0
    end
end

--计时器
function BarrageLayer:onDrawUpgradeTimer( ... )
    local newBarrage = {}
    for i=1,#game.BarrageTab do
        if game.BarrageTab[i].showTime == 0 then
            self:updateItem(game.BarrageTab[i])
        end
        if game.BarrageTab[i].showTime >= 0 then
            game.BarrageTab[i].showTime = game.BarrageTab[i].showTime - 1
        end

        if game.BarrageTab[i].showTime < 0 then
            game.BarrageTab[i].PosX = game.BarrageTab[i].PosX - game.BarrageTab[i].speed
            if game.BarrageTab[i].PosX < - game.BarrageTab[i].lenght then
            else
                table.insert(newBarrage, game.BarrageTab[i])
            end
        else
            table.insert(newBarrage, game.BarrageTab[i])
        end
    end
    game.BarrageTab = newBarrage

    self:checkBarrageTab()

    local t = {}
    for i=1,#self.labelTab do
        self.labelTab[i]:setPositionX(self.labelTab[i]:getPositionX()-self.labelTab[i]:getTag())
        local width = self.labelTab[i]:getChildByName("Image_icon"):getContentSize().width + self.labelTab[i]:getChildByName("Text_msg"):getContentSize().width
        if self.labelTab[i]:getPositionX() < - width then
            self.labelTab[i]:removeFromParent()
        else
            table.insert(t,self.labelTab[i])
        end
    end
    self.labelTab = t

    
end

function BarrageLayer:updateSysMessage()
    -- 更新系统消息
    game.SysMessage = game.SysMessage or {}
    if #game.SysMessage <= 0 then
        local parent = self.Node:getChildByName("Node_1"):getChildByName("Panel_1")
        parent:getChildByName("Image_di"):setVisible(false)
        if parent:getChildByName("msg") ~= nil then
            parent:getChildByName("msg"):removeFromParent()
        end
    end
    if self.sysFlag == 1 and #game.SysMessage > 0 then
        local newBarrage = {}
        for k,v in pairs(game.SysMessage) do
            v.showTime = v.showTime - 2
            if v.showTime >= 0 then
                table.insert(newBarrage, v)
            end
        end
        -- game.SysMessage = newBarrage
        -- if self.sysIndex > #game.SysMessage then
        --     self.sysIndex = #game.SysMessage
        -- end
        -- local parent = self.Node:getChildByName("Node_1"):getChildByName("Panel_1")
        -- parent:getChildByName("Image_di"):setVisible(true)
        -- if parent:getChildByName("msg") ~= nil then
        --     parent:getChildByName("msg"):removeFromParent()
        -- end
        -- if #game.SysMessage > 0 then
        --     local Node = cc.CSLoader:createNode("Node_SysMsg.csb")
        --     Node:setName("msg")
        --     local data = game.SysMessage[self.sysIndex]
        --     if data.fromid == 0 then
        --         Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_LOGO.png")
        --         Node:getChildByName("Image_icon"):setScale(0.5, 0.5)
        --         Node:getChildByName("Text_msg"):setString(data.message)
        --     else
        --         Node:getChildByName("Image_icon"):loadTexture("res/UI/bt_laba.png")
        --         Node:getChildByName("Image_icon"):setScale(0.3, 0.5)
        --         Node:getChildByName("Text_msg"):setString(data.fromname..":"..data.message)
        --     end
        --     Node:getChildByName("Text_msg"):setColor(cc.c4b(255,215,0,255))
        --     Node:setPosition(cc.p(data.PosX*0.08,data.PosY))
        --     parent:addChild(Node)
        -- end
        self:addSysAction(game.SysMessage[self.sysIndex])
        self.sysIndex = self.sysIndex + 1
        if self.sysIndex > #game.SysMessage then
            self.sysIndex = 1
        end
    end
end

return BarrageLayer



