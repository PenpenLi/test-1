local PetListLayer = class("PetListLayer", require("app.views.mmExtend.LayerBase"))
PetListLayer.RESOURCE_FILENAME = "pet/PetListLayer.csb"

local petListitemRes = "res/pet/petListitem.csb"

function PetListLayer:onEnter()


end

function PetListLayer:onExit()
	
end

function PetListLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function PetListLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function PetListLayer:init(param)
	self.Node = self:getResourceNode()
    self.ImageBg = self.Node:getChildByName("Image_bg")

    --初始化主界面UI
    self:UIInit()

end

function PetListLayer:UIInit() 
    self.backBtn = self.ImageBg:getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.viewNode = self.Node:getChildByName("Node_Scrollview")
    -- self.Node:getChildByName("Button"):addTouchEventListener(handler(self, self.checkBtnCbk))

    self:updateData()
    self:updateList()
end

function PetListLayer:updateData() 
    self.petList = mm.data.playerPet

    self.petTable = {}

    for k,v in pairs(G_PetTable) do
        local id = v.ID
        local isHas = false
        for k1,v1 in pairs(self.petList) do
            if v1.id == id then
                local t = util.copyTab(v1)
                t.id = id
                t.quality = v.quality
                t.name = v.Name
                t.desc = v.Hero_Desc
                for k3,v3 in pairs(v1) do
                    t.k3 = v3
                end
                table.insert( self.petTable, t )
                isHas = true
                break
            end
        end
        if not isHas then
            for k2,v2 in pairs(mm.data.playerBag) do
                if id == v2.id then
                    local t = {}
                    t.id = id
                    t.num = v2.num
                    t.callNum = v.callNum
                    t.promotionNum = v.promotionNum
                    t.lv = 0
                    t.name = v.Name
                    t.quality = v.quality
                    t.desc = v.Hero_Desc
                    table.insert( self.petTable, t )
                    break
                end
            end
        end


    end

    local function sort_rule( a, b )
        if a.lv > b.lv then
            return true
        end
    end
    table.sort(self.petTable, sort_rule)


    print(" self.petTable      "..#self.petTable)
    print(" self.petTable      "..json.encode(self.petTable))
end

function PetListLayer:updateList() 
    local layoutData = {res = petListitemRes,layoutName = "Image_bg"}
    local t = {
        layoutData = layoutData,
        count = #self.petTable,
        fun = "updateItem",
        target = self,
        size = cc.size(630,900 * display.height / 1136),
    }
    local listView = require(game.VerListView):create(t)
    listView:setPosition(0, 0)
    self.listView = listView
    self.viewNode:addChild(listView,100)


end

function PetListLayer:updateItem(cell,tag,isInit) 
    local pet = self.petTable[tag]
    local petId = pet.id
    print(" petId  =================      "..petId)
    local nameText = cell:getChildByName("Text_name")
    nameText:setString(pet.name)
    cell:setTag(tag)

    local lvText = cell:getChildByName("Text_lv")
    local desText = cell:getChildByName("Text_des")
    local barNode = cell:getChildByName("Node_bar")
    local LoadingBar = barNode:getChildByName("LoadingBar")
    if pet.lv > 0 then
        lvText:setVisible(true)
        desText:setVisible(true)
        barNode:setVisible(false)
        lvText:setString(pet.lv)
        desText:setString(pet.desc)
    else
        lvText:setVisible(false)
        desText:setVisible(false)
        barNode:setVisible(true)
        LoadingBar:setPercent(math.ceil(pet.num / pet.callNum * 100))
    end
    if isInit then
        cell:addTouchEventListener(handler(self, self.checkBtnCbk))
    end
end

function PetListLayer:checkBtnCbk(widget,touchkey)

    if touchkey == ccui.TouchEventType.ended then 
        local petId = widget:getTag()
        print("petId "..petId)
        local pet = self.petTable[petId]
        local PetLayer = require("src.app.views.layer.Pet.PetLayer").new({pet=pet})
        self:addChild(PetLayer, 100)
    end
end

function PetListLayer:setCheckNode() 

end

function PetListLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function PetListLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saveFormation" then
        end
    end
end


return PetListLayer