local itemInfoAndJump = class("itemInfoAndJump", require("app.views.mmExtend.LayerBase"))
itemInfoAndJump.RESOURCE_FILENAME = "res/Scqueren.csb"
local INITLUA = INITLUA
local function log( ... )
    print(...)
end

function itemInfoAndJump:onCreate(param)
    self:init(param.itemInfo)
end

function itemInfoAndJump:init(itemInfo)
    self.itemInfo = itemInfo
    self:initLayerUI()
end

function itemInfoAndJump:initLayerUI()
    local itemInfo = self.itemInfo

    local itemID = itemInfo.id

    local Node = self:getResourceNode() self.Node = Node
    local rootNode = Node:getChildByName("Image_bg") self.rootNode = rootNode  
    if not rootNode then
        return
    end

    -- 确定
    self.buyBtn = rootNode:getChildByName("Button_7")
    self.buyBtn:setTitleText("确定")
    self.buyBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.buyBtn) 

    -- 关闭按钮
    self.backBtn = rootNode:getChildByName("Button_1")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    -- 其他
    -- local bg2 = rootNode:getChildByName("Image_bg01")
    -- if bg2 then
    --     -- local ts = {"Text_01","Text_02","Text_03"}
    --     -- for i,v in ipairs(ts) do
    --     --     local t = bg2:getChildByName(v)
    --     --     if t then
    --     --         t:setVisible(false)
    --     --     end
    --     -- end
        
    --     --local infoText = bg2:getChildByName("Text_16") self.infoText = infoText
    -- end

    rootNode:getChildByName("Text_2"):setVisible(false)
    rootNode:getChildByName("Image_21"):setVisible(false)
    rootNode:getChildByName("Text_3"):setVisible(false)

    local equipAreaNode = rootNode:getChildByName("Panel_2")
    equipAreaNode:setVisible(false)
    local item = INITLUA:getItemByid(itemID)
    if not item then
        return
    end
    local hasNum = 0
    for k,v in pairs(mm.data.playerItem) do
        if v.id == itemID then
            hasNum = v.num
            break
        end
    end
    local hasItemNum = rootNode:getChildByName("Text_08")
    hasItemNum:setString("拥有"..hasNum.."件")

    local itemNode = gameUtil.createItemWidget(itemID , 0)
    local itemIcon = rootNode:getChildByName("Image_1")
    itemIcon:addChild(itemNode)

    local itemName = rootNode:getChildByName("Text_name")
    itemName:setString(item.Name)

    local infoTextNode = rootNode:getChildByName("Image_bg01")
    local attText = infoTextNode:getChildByName("Text_01")
    local hpText = infoTextNode:getChildByName("Text_02")
    local speedText = infoTextNode:getChildByName("Text_03")
    local des = infoTextNode:getChildByName("Text_16")

    des:setString(item.itemsrc)
    attText:setVisible(false)
    hpText:setVisible(false)
    speedText:setVisible(false)

end

function itemInfoAndJump:buyBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function itemInfoAndJump:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return itemInfoAndJump


