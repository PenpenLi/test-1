--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local MeleeStoreItemNoLayer = class("MeleeStoreItemNoLayer", require("app.views.mmExtend.LayerBase"))
MeleeStoreItemNoLayer.RESOURCE_FILENAME = "Luandoushangpin.csb"


function MeleeStoreItemNoLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function MeleeStoreItemNoLayer:onEnter()

end

function MeleeStoreItemNoLayer:onExit()

end

function MeleeStoreItemNoLayer:onCreate(param)
    self:init(param)
end

function MeleeStoreItemNoLayer:init(param)
    self.param = param
    self.scene = param.scene
    self.itemInfo = param.info
    self:initLayerUI()
end

function MeleeStoreItemNoLayer:initLayerUI( )
    self.noNode = self:getResourceNode()

    local itemBg = self.noNode:getChildByName("Image_1")
    local resStr = "res/icon/jiemian/icon_SC_5.png"
    itemBg:loadTexture(resStr)
    itemBg:setSwallowTouches(false)

    local fightTimes = mm.data.playerExtra.meleeWinTimes
    if fightTimes == nil then
        fightTimes = 0
    end

    local itemID = self.itemInfo.id
    local storeItemRes = INITLUA:getShopMeleeItemRes()
    local storeItem = storeItemRes[itemID]

    self.noNode:getChildByName("Text_1"):setString("乱斗胜利:"..fightTimes.."/"..storeItem.shopmelee_num)

    self:setContentSize(itemBg:getContentSize())
end

return MeleeStoreItemNoLayer


