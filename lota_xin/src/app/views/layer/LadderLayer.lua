--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local LadderLayer = class("LadderLayer")
LadderLayer.__index = LadderLayer

function LadderLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, LadderLayer)
    return target
end


function LadderLayer:onEnter()

end

function LadderLayer:onExit()

end

function LadderLayer.create()
    local layerCsb = LadderLayer.extend(cc.CSLoader:createNode("duanweiguize.csb"))
    if layerCsb then
        layerCsb:init()
    end
    return layerCsb
end

function LadderLayer:addNodeEvent( ... )
    local function onNodeEvent(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function LadderLayer:init()

    self.hangNum = 6

    --添加node事件
    self:addNodeEvent()

    
    -- 关闭按钮
    self.backBtn = self:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self:initLayerUI()

end

function LadderLayer:initLayerUI( ... )
    local dropOutRes = INITLUA:getDropOutRes()
    local size  = cc.Director:getInstance():getWinSize()
  
    local key_table = {}  
    --取出所有的键  
    for key,_ in pairs(dropOutRes) do  
        table.insert(key_table,key)  
    end  
    --对所有键进行排序  
    table.sort(key_table, function(a,b)
        return a > b
    end)

    local index = 0  
    for _,key in pairs(key_table) do
        index = index+1 
        local item = require("src.app.views.layer.LadderItemLayer").create(key)
        self:addChild(item)
        local H = item:getContentSize().height * 1.1
        local W = item:getContentSize().width
        item:setPosition((size.width-W)*0.5,size.height-H*(1.5+index))
        ccui.Helper:doLayout(item)
    end  
    --self:addChild(ladderItem)
    --local size  = cc.Director:getInstance():getWinSize()
    --ladderItem:setContentSize(cc.size(size.width, size.height))

end

function LadderLayer:eventListener( event )
end

function LadderLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

return LadderLayer


