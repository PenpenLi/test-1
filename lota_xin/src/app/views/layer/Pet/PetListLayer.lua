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
    self.petList = {
        {id = 1278226736, lv = 1, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278226744, lv = 1, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278226993, lv = 1, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278227249, lv = 1, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278227254, lv = 1, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278227255, lv = 0, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278227256, lv = 0, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278227257, lv = 0, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
        {id = 1278227258, lv = 0, skillLv = 1, xinLv = 0, eq01 = 1, eq02 = 1, eq03 = 1, },
    }



end

function PetListLayer:updateList() 
    local layoutData = {res = petListitemRes,layoutName = "Image_bg"}
    local t = {
        layoutData = layoutData,
        count = #self.petList,
        fun = "updateItem",
        target = self,
        size = cc.size(630,850 * display.height / 1136),
    }
    local listView = require(game.VerListView):create(t)
    listView:setPosition(0, 0)
    self.listView = listView
    self.viewNode:addChild(listView,100)


end

function PetListLayer:updateItem(cell,tag,isInit) 

    if isInit then
        -- cell:addTouchEventListener(handler(self, self.checkBtnCbk))
    end
end

function PetListLayer:checkBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local PetLayer = require("src.app.views.layer.Pet.PetLayer").new({})
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