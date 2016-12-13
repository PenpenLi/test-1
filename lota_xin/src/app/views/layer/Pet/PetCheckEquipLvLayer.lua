local PetCheckEquipLvLayer = class("PetCheckEquipLvLayer", require("app.views.mmExtend.LayerBase"))
PetCheckEquipLvLayer.RESOURCE_FILENAME = "pet/PetCheckEquipLvLayer.csb"

local size  = cc.Director:getInstance():getWinSize()

local petListitemRes = "res/pet/petListitem.csb"
local PetEqBgItemRes = "res/pet/PetEqBgItem.csb"
local PetEquipItemRes = "res/pet/PetEquipItem.csb"

local petTable = petTable

function PetCheckEquipLvLayer:onEnter()


end

function PetCheckEquipLvLayer:onExit()
	
end

function PetCheckEquipLvLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function PetCheckEquipLvLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function PetCheckEquipLvLayer:init(param)
	self.Node = self:getResourceNode()
    self.ImageBg = self.Node:getChildByName("Image_bg")

    self.pet = param.petTab
    self.index = param.index

    self.beCheckTab = {}

    --初始化主界面UI
    self:UIInit()

end

function PetCheckEquipLvLayer:UIInit() 
    self.backBtn = self.ImageBg:getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.viewNode = self.Node:getChildByName("Node_Scrollview")
    -- self.Node:getChildByName("Button"):addTouchEventListener(handler(self, self.checkBtnCbk))


    

    self:setSorts()
    self:updateList(0)
end


function PetCheckEquipLvLayer:setSorts( ... )
    self.petEquip = mm.data.petEquip

    self.all = {}
    self.sorts = {}
    for k,v in pairs(self.petEquip) do
        local equipResId = v.resId
        local resTab = equipTable[equipResId]
        local Type = resTab.Type
        self.sorts[Type] = self.sorts[Type] or {}

        v.quality = resTab.quality
        local user = v.user
        if user == 0 then
            table.insert(self.sorts[Type], v)
            table.insert(self.all, v)
        end

        
    end

    self:equipSort(self.all)

    for i=1,3 do
        if self.sorts[i] then
            self:equipSort(self.sorts[i])
        end
    end

    
end

function PetCheckEquipLvLayer:equipSort( tab )
    local function sort_rule( a, b )
        if a.quality < b.quality then
            return true
        end
    end
    table.sort(tab, sort_rule)
    return tab
end

function PetCheckEquipLvLayer:updateList(index)
    self.sortIndex = index
    self:setSorts()

    if self.sortIndex == 0 then
        self.checkTab = self.all
    else
        self.checkTab =   self.sorts[self.sortIndex] 
    end

    
    print("self.checkTab  ========  "..#self.checkTab)
    self.hang = #self.checkTab / 5
    print("self.hang  ========1  "..self.hang)
    if #self.checkTab % 5 > 0 then
        self.hang = self.hang + 1
    end
    print("self.hang  ========2  "..self.hang)
    -- print("self.checkTab  ========  "..json.encode(self.checkTab))

    
    self:addList()
end

function PetCheckEquipLvLayer:addList() 
    if self.listView then
        self.listView:removeFromParent()
    end
    local node = cc.CSLoader:createNode(PetEqBgItemRes)
    local layout = node:getChildByName("Image_bg"):clone()

    local t = {
        cell = layout,
        count = self.hang,
        fun = "updateItem",
        target = self,
        size = cc.size(630,750 * display.height / 1136),
    }
    local listView = require(game.VerListView):create(t)
    listView:setPosition(0, 0)
    self.listView = listView
    self.viewNode:addChild(listView,100)


end

function PetCheckEquipLvLayer:updateItem(cell,tag,isInit) 
    print('tag =================================================== '..tag)
    for i=1,5 do
        local Node = cell:getChildByName("Node_"..i)
        local index = (tag - 1) * 5 + i
        local tab = self.checkTab[index]
        if tab then
            local equipNode = Node:getChildByName("equipNode")
            if not equipNode then
                local layoutData = {res = PetEquipItemRes,layoutName = "Image_bg"}
                equipNode = cs.ObjectPoolManager:getObject(layoutData)
                equipNode:setName("equipNode")
                Node:addChild(equipNode)
                equipNode:setAnchorPoint(cc.p(0.5,0.5))
                equipNode:setPosition(0, 0)
            end
            
            local lvText = equipNode:getChildByName("Text_lv")
            lvText:setString(tab.lv)
            local equipResId = tab.resId
            local resTab = equipTable[equipResId]
            equipNode:loadTexture("res/UI/bIcon/bg_icon_"..resTab.quality..".png")

            local iconImage = equipNode:getChildByName("Image_icon")
            iconImage:loadTexture(resTab.iconSrc)

            local checkImage = equipNode:getChildByName("Image_check")
            if self:isCheck(index) then
                checkImage:setVisible(true)
            else
                checkImage:setVisible(false)
            end

            

            equipNode:addTouchEventListener(handler(self, self.checkEquipBtnCbk))
            equipNode:setSwallowTouches(false)
            equipNode:setTag(index)
        end
    end

end

function PetCheckEquipLvLayer:isCheck( index )
    local isCheck = false
    for k,v in pairs(self.beCheckTab) do
        if index == v then
            isCheck = true
            break
        end
    end

    return isCheck
end

function PetCheckEquipLvLayer:checkEquipBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        local checkImage = widget:getChildByName("Image_check")
        if self:isCheck( tag ) then
            table.remove(self.beCheckTab,tag)
            checkImage:setVisible(false)
        else
            table.insert(self.beCheckTab,tag)
            checkImage:setVisible(true)
        end
        
        

    end
end

function PetCheckEquipLvLayer:setExpText( ... )
    self.expText = self.ImageBg:getChildByName("Text_num")
    local num = 0
    for k,v in pairs(self.beCheckTab) do
        local index = v
        local tab = self.checkTab[index]
        local equipResId = tab.resId
        local resTab = equipTable[equipResId]
        -- local resexp = resTab.

    end
end


function PetCheckEquipLvLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function PetCheckEquipLvLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "wearequip" then
            self:removeFromParent()
        end
    end
end


return PetCheckEquipLvLayer