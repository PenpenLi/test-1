local PetLayer = class("PetLayer", require("app.views.mmExtend.LayerBase"))
PetLayer.RESOURCE_FILENAME = "pet/PetLayer.csb"

function PetLayer:onEnter()


end

function PetLayer:onExit()
	
end

function PetLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function PetLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function PetLayer:init(param)
	self.Node = self:getResourceNode()
    self.ImageBg = self.Node:getChildByName("Image_bg")

    self.pet = param.pet
    print(" PetLayer :   self.pet      "..json.encode(param))
    print(" PetLayer :   self.pet      "..json.encode(self.pet))

    --初始化主界面UI
    self:UIInit()

end

function PetLayer:UIInit() 
    self.backBtn = self.ImageBg:getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.zhanliText = self.Node:getChildByName("Text_zhanli")
    self.nameText = self.Node:getChildByName("Text_name")
    self.nameText:setString(self.pet.name)
    

    self.checkLvBtn = self.ImageBg:getChildByName("Button_lv")
    self.checkLvBtn:addTouchEventListener(handler(self, self.checkBtnCbk))

    self.checkSkillBtn = self.ImageBg:getChildByName("Button_skill")
    self.checkSkillBtn:addTouchEventListener(handler(self, self.checkBtnCbk))

    self.checkFashionBtn = self.ImageBg:getChildByName("Button_fashion")
    self.checkFashionBtn:addTouchEventListener(handler(self, self.checkBtnCbk))

    self.evolutionBtn = self.ImageBg:getChildByName("Button_evolution")
    self.evolutionBtn:addTouchEventListener(handler(self, self.checkBtnCbk))

    self.lvUpNode = self.Node:getChildByName("Node_lvUp")
    self.skillNode = self.Node:getChildByName("Node_skill")
    self.fashionNode = self.Node:getChildByName("Node_fashion")
    self.evolutionNode = self.Node:getChildByName("Node_evolution")

    self:setCheckBtn(self.checkLvBtn)

    self:updatePublic()
end



function PetLayer:checkBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:setCheckBtn(widget)
    end
end

function PetLayer:setCheckNode() 

end

function PetLayer:setCheckBtn(btn) 
    self.checkLvBtn:setBright(true)
    self.checkSkillBtn:setBright(true)
    self.checkFashionBtn:setBright(true)
    self.evolutionBtn:setBright(true)

    self.checkLvBtn:setEnabled(true)
    self.checkSkillBtn:setEnabled(true)
    self.checkFashionBtn:setEnabled(true)
    self.evolutionBtn:setEnabled(true)

    btn:setBright(false)
    btn:setEnabled(false)

    self.lvUpNode:setVisible(false)
    self.skillNode:setVisible(false)
    self.fashionNode:setVisible(false)
    self.evolutionNode:setVisible(false)
    if btn:getName() == "Button_lv" then
        self.lvUpNode:setVisible(true)
    elseif btn:getName() == "Button_skill" then
        self.skillNode:setVisible(true)
    elseif btn:getName() == "Button_fashion" then
        self.fashionNode:setVisible(true)
    elseif btn:getName() == "Button_evolution" then
        self.evolutionNode:setVisible(true)
    end
end

function PetLayer:updatePublic()
    local zhanliNum = 10
    self.zhanliText:setString(zhanliNum)
end

function PetLayer:updateLv( event )

end

function PetLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function PetLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saveFormation" then
        end
    end
end


return PetLayer