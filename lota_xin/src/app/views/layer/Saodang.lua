--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local Saodang = class("Saodang", require("app.views.mmExtend.LayerBase"))
Saodang.RESOURCE_FILENAME = "Saodang.csb"


function Saodang:onCleanup()
    self:clearAllGlobalEventListener()
end

function Saodang:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )


end

function Saodang:onExit()

end

function Saodang:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function Saodang:init(param)
    self.stageId = param.stageId

    local hasSaoJuan = 0
    for i=1,#mm.data.playerItem do
        if mm.data.playerItem[i].id == 1412444209 then
            hasSaoJuan = mm.data.playerItem[i].num
        end
    end
    self.hasSaoJuan = hasSaoJuan

    if self.hasSaoJuan == 0 then
        self.cur_num = 0
    else
        self.cur_num = 1 
    end

    self:initLayerUI()
end

function Saodang:initLayerUI( )
    self.Node = self:getResourceNode()

    local Button_Close = self.Node:getChildByName("Image_bg"):getChildByName("Button_Close")
    Button_Close:addTouchEventListener(handler(self, self.ButtonCloseBack))
    gameUtil.setBtnEffect(Button_Close)

    local Button_Reduce = self.Node:getChildByName("Image_bg"):getChildByName("Button_Reduce")
    Button_Reduce:addTouchEventListener(handler(self, self.Button_ReduceBack))
    gameUtil.setBtnEffect(Button_Reduce)

    local Button_Add = self.Node:getChildByName("Image_bg"):getChildByName("Button_Add")
    Button_Add:addTouchEventListener(handler(self, self.Button_AddBack))
    gameUtil.setBtnEffect(Button_Add)

    local Button_MAX = self.Node:getChildByName("Image_bg"):getChildByName("Button_MAX")
    Button_MAX:addTouchEventListener(handler(self, self.Button_MAXBack))
    gameUtil.setBtnEffect(Button_MAX)

    local Button_saodang = self.Node:getChildByName("Image_bg"):getChildByName("Button_saodang")
    Button_saodang:addTouchEventListener(handler(self, self.Button_saodangBack))
    gameUtil.setBtnEffect(Button_saodang)

    self.numText = self.Node:getChildByName("Image_bg"):getChildByName("num")
    self.numText:setString(self.hasSaoJuan)

    self.Text_cur = self.Node:getChildByName("Image_bg"):getChildByName("Text_cur")
    self.Text_cur:setString(self.cur_num)

    
end


function Saodang:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function Saodang:Button_ReduceBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.cur_num > 1 then
            self.cur_num = self.cur_num - 1
            self.Text_cur:setString(self.cur_num)
        end
    end
end

function Saodang:Button_AddBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.cur_num < self.hasSaoJuan then
            self.cur_num = self.cur_num + 1
            self.Text_cur:setString(self.cur_num)
        end
    end
end

function Saodang:Button_MAXBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.cur_num = self.hasSaoJuan
        self.Text_cur:setString(self.cur_num)
    end
end

function Saodang:Button_saodangBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        print("Button_saodangBack  "..self.cur_num)
        mm.req("saodang",{type=0, stageId = self.stageId, times = self.cur_num})
    end
end








function Saodang:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saodang" then
            self:removeFromParent()
        end
    end
end

return Saodang


