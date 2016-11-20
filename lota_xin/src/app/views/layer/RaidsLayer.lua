local RaidsLayer = class("RaidsLayer")
RaidsLayer.__index = RaidsLayer

function RaidsLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, RaidsLayer)
    return target
end


function RaidsLayer:onEnter() 
    
end

function RaidsLayer:onExit()

end

function RaidsLayer.create(param)
    local layerCsb = RaidsLayer.extend(cc.CSLoader:createNode("RaidsLayer.csb")) 
    if layerCsb then 
        layerCsb:init(param)
    end
    return layerCsb
end

function RaidsLayer:init(param)
    
    --扫荡时间(7)
    self.costHourLabel = self:getChildByName("Image_bg01"):getChildByName("Text_02")
    self.costHourLabel:setText(7)

    --消耗钻石(消耗：50)
    self.consumeLabel = self:getChildByName("Image_bg01"):getChildByName("Panel_xiaohao"):getChildByName("Text_num")
    self.consumeLabel:setText(600)

    --描述01
    self.msg01Label = self:getChildByName("Image_bg01"):getChildByName("Image_msgbg"):getChildByName("Text_msg01")
    self.msg01Label:setText(string.format("立刻完成%d小时的战斗场次，将消耗%d钻石", 7, 50))

    --描述02
    self.msg02Label = self:getChildByName("Image_bg01"):getChildByName("Image_msgbg"):getChildByName("Text_msg02")
    self.msg02Label:setText(string.format("(VIP%d,今天还剩余%d次数,每天早上6点重置次数)", 7, 50))

    -- ok按钮
    self.backBtn = self:getChildByName("Image_bg01"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

end

function RaidsLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end


return RaidsLayer
