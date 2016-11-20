--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local playerLvUpLayer = class("playerLvUpLayer", require("app.views.mmExtend.LayerBase"))
playerLvUpLayer.RESOURCE_FILENAME = "Dengjitisheng.csb"


function playerLvUpLayer:onCleanup()
    --self:clearAllGlobalEventListener()
end

function playerLvUpLayer:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )

end

function playerLvUpLayer:onExit()

end

function playerLvUpLayer:onCreate(param)
    self:init(param)

    --self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function playerLvUpLayer:init(param)
    self.param = param
    self.scene = param.scene

    self.oldLv = param.oldLv
    self.newLv = param.newLv
    


    self:initLayerUI()
end

function playerLvUpLayer:initLayerUI( )
    self.Node = self:getResourceNode()
    local oldText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_6")
    oldText:setString(self.oldLv)

    local newText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_2")
    newText:setString(self.newLv)

    local expText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_7_0")
    local oldexp = gameUtil.getAccountAddExpPoolMaxLv(self.oldLv)
    local newexp = gameUtil.getAccountAddExpPoolMaxLv(self.newLv)
    expText:setString("经验池上限+"..newexp - oldexp)

    local ListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_2"):getChildByName("ListView")

    local show = {}
    local camp = mm.data.playerinfo.camp
    for k,v in pairs(equip) do
        if v.EquipCamp == camp and self.newLv >= v.eq_needLv and v.eq_needLv > self.oldLv and (v.EquipType == 0 or v.EquipType == 1) then
            table.insert(show, {id = v.ID})

        end

    end

    if show and #show > 0 then
        for k,v in pairs(show) do
            local item = gameUtil.createEquipItem(v.id, 0)

            if item then
                item:setAnchorPoint(cc.p(0.0,0.0))
                local custom_item = ccui.Layout:create()

                custom_item:addChild(item)
                local size = item:getContentSize()
                size.width = size.width * 1.3
                size.height = size.height * 1.3
                custom_item:setContentSize(size)
                ListView:pushBackCustomItem(custom_item)
            end
        end

    else
        local img = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01")
        local p = cc.p(img:getPosition())
        img:setPosition(p.x, p.y - 100)

        img:getChildByName("Text_7"):setVisible(false)
        img:getChildByName("Image_2"):setVisible(false)
    end




    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    

end





function playerLvUpLayer:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function playerLvUpLayer:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end



function playerLvUpLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        
    end
end

return playerLvUpLayer


