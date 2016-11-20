--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local TiaoZhanGhengGongLayer = class("TiaoZhanGhengGongLayer", require("app.views.mmExtend.LayerBase"))
TiaoZhanGhengGongLayer.RESOURCE_FILENAME = "Tiaozhanchenggong.csb"


function TiaoZhanGhengGongLayer:onCleanup()
    --self:clearAllGlobalEventListener()
end

function TiaoZhanGhengGongLayer:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )

end

function TiaoZhanGhengGongLayer:onExit()

end

function TiaoZhanGhengGongLayer:onCreate(param)
    self:init(param)

    --self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function TiaoZhanGhengGongLayer:init(param)
    self.param = param
    self.scene = param.scene

    self.exp = param.exp
    self.gold = param.gold
    self.poolExp = param.poolExp
    self.dropTab =    param.dropTab
    self.result = param.result
    self.allDropTab = param.allDropTab
    self.stageId = param.stageId
    


    self:initLayerUI()
end

function TiaoZhanGhengGongLayer:initLayerUI( )
    
    self.Node = self:getResourceNode()
    local stageNameText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_4")
    local stageRes = INITLUA:getStageResById(self.stageId)
    stageNameText:setString(stageRes.StageName)

    local one = cc.p(self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_1"):getPosition())
    local two = cc.p(self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_exp"):getPosition())

    local expImage = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_1")
    local poolExpImage = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_exp")
    local goldImage = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_gold")

    local expText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_1"):getChildByName("Text_1")
    local poolExpText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_exp"):getChildByName("Text_2")
    local goldText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_gold"):getChildByName("Text_2")

    local count = 0

    if StageType and StageType ~= MM.EStageType.STAD and StageType ~= MM.EStageType.STAP then
        if self.exp and self.exp > 0 then
            expText:setString(self.exp)
            count = count + 1
        else
            expImage:setVisible(false)
        end

        if self.poolExp and self.poolExp > 0 then
            poolExpText:setString(self.poolExp)
            if count == 0 then
                poolExpImage:setPosition(one.x, one.y)
            end
            count = count + 1
        else
            poolExpImage:setVisible(false)
        end
    else
        poolExpImage:setVisible(false)
        expImage:setVisible(false)
    end
    -- if self.gold and self.gold > 0 then
    --     goldText:setString(self.gold)
    --     if count == 0 then
    --         goldImage:setPosition(one.x, one.y)
    --     elseif count == 1 then
    --         goldImage:setPosition(two.x, two.y)
    --     end
    -- else
    --     goldImage:setVisible(false)
    -- end


    local ListView = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_2"):getChildByName("ListView")

    if self.dropTab and #self.dropTab > 0 then
        for k,v in pairs(self.dropTab) do
            if v.num and v.num > 0 then 
                local item = nil
                if v.type == 1 then
                    item = gameUtil.createEquipItem(v.id, v.num)
                    local equipRes = INITLUA:getEquipByid( v.id )
                    if equipRes.EquipType == MM.EEquipType.ET_SuiPian then
                        local suipianPinPathRes = gameUtil.getEquipSuipianPinRes(equipRes.Quality)
                        local suipianTag = cc.Sprite:create(suipianPinPathRes)
                        suipianTag:setPosition(cc.p(20, item:getContentSize().height - 15))
                        item:addChild(suipianTag)
                    end
                elseif v.type == 2 then
                    item = gameUtil.createItemWidget(v.id, v.num)
                elseif v.type == 3 then
                    item = gameUtil.createEquipItem(v.id, v.num)
                end

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
        end
    end

    if self.gold and self.gold > 0 then
        local item = gameUtil.createItemByIcon("res/icon/jiemian/icon_jinbi.png", self.gold)
        local custom_item = ccui.Layout:create()
        item:setAnchorPoint(cc.p(0, 0))
        local size = item:getContentSize()
        size.width = size.width * 1.3
        size.height = size.height * 1.3
        custom_item:addChild(item)
        custom_item:setContentSize(size)
        ListView:pushBackCustomItem(custom_item)
    end


    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    

end





function TiaoZhanGhengGongLayer:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function TiaoZhanGhengGongLayer:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end



function TiaoZhanGhengGongLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        
    end
end

return TiaoZhanGhengGongLayer


