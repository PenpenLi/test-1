--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local LadderItemLayer = class("LadderItemLayer", require("app.views.mmExtend.LayerBase"))
LadderItemLayer.RESOURCE_FILENAME = "duanweiguizeLayer.csb"

function LadderItemLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function LadderItemLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function LadderItemLayer:onEnter()
    
end

function LadderItemLayer:onExit()
    
end

function LadderItemLayer:onEnterTransitionFinish()
    
end

function LadderItemLayer:onExitTransitionStart()
    
end

function LadderItemLayer:onCleanup()
    
    self:clearAllGlobalEventListener()
end

function LadderItemLayer:init(key)
    self.key = key
    self:initLayerUI(key)
end

function LadderItemLayer:initLayerUI( key )
    self.Node = self:getResourceNode()
    self.duanweiIcon = self.Node:getChildByName("Node_1")
    self.duanweiText = self.Node:getChildByName("Text_1")

    self.item = self.Node:getChildByName("Image_di")
    self.item:addTouchEventListener(handler(self, self.itemBtnCbk))
    --gameUtil.setBtnEffect(self.item)

    local dropOutRes = INITLUA:getDropOutRes()
    local dropListRes = INITLUA:getDropListRes()

    
    local res = dropOutRes[key].Res
    self.duanweiText:setText(dropOutRes[key].Name)
    
    gameUtil.addArmatureFile("res/Effect/uiEffect/"..res.."/"..res..".ExportJson")
    local anime = ccs.Armature:create(res)
    anime:setScale(1.2)
    anime:setPosition(0,0)
    local animation = anime:getAnimation()
    self.duanweiIcon:addChild(anime,10)
    --anime:setPosition(61,61)
    animation:play(res)


    
    local setList = {}
    --dropout.Name
    for k,v in pairs(dropListRes) do
        if v.DropFrom == key and v.EquipCamp == 1 then
            if v.ItemID ~= 0 then
                local item = {}
                item.RankPower = v.RankPower
                item.ItemID = v.ItemID
                table.insert(setList, item)
            end
        end
    end

    local sortRules = {
        {
            func = function(v)
                return v.RankPower
            end,
            isAscending = false
        },
        {
            func = function(v)
                return v.ItemID
            end,
            isAscending = false       
        },
    }
    local showTab = util.powerSort(setList, sortRules)
    --只取前5个
    for i=1,5 do
        local value = showTab[i]
        local equip = INITLUA:getEquipByid(value.ItemID)
        if equip then
            local eqRes = equip.eq_res .. ".png"
            local eqIcon = self.Node:getChildByName("Image_"..i):loadTexture(eqRes)
        end
    end

    -- 奖励按钮
    self.rewardBtn = self.Node:getChildByName("Button_1")
    self.rewardBtn:addTouchEventListener(handler(self, self.showRewardBtnCbk))
    gameUtil.setBtnEffect(self.rewardBtn)
end

function LadderItemLayer:showRewardBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local rewardLayer = require("src.app.views.layer.DropItemLayer").new(self.key)
        local size  = cc.Director:getInstance():getWinSize()
        self.Node:getParent():addChild(rewardLayer)
        rewardLayer:setContentSize(cc.size(size.width, size.height))
        
        ccui.Helper:doLayout(rewardLayer)
    end
end

function LadderItemLayer:itemBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local rewardLayer = require("src.app.views.layer.LadderRewardLayer").new(self.key)
        local size  = cc.Director:getInstance():getWinSize()
        self.Node:getParent():addChild(rewardLayer)
        rewardLayer:setContentSize(cc.size(size.width, size.height))
        
        ccui.Helper:doLayout(rewardLayer)
    end
end

return LadderItemLayer


