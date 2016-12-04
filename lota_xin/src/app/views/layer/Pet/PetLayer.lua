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
    self:updatePublic()

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

    

    self.lvUpBtn = self.lvUpNode:getChildByName("Button_LvUp")
    self.lvUpBtn:addTouchEventListener(handler(self, self.lvUpBtnCbk))
    self:updateLvUI()

    self.skillUpBtn = self.skillNode:getChildByName("Button_skillUp")
    self.skillUpBtn:addTouchEventListener(handler(self, self.skillUpBtnCbk))
    self:updateSkillUpUI()
end

function PetLayer:updateLvUI()
    local lvText = self.lvUpNode:getChildByName("Image_lvup_bg"):getChildByName("Text_lv")
    lvText:setString(self.pet.lv)
    local goldText = self.lvUpNode:getChildByName("Text_gold")
    local needGold = 100
    goldText:setString(needGold)
end

function PetLayer:updateSkillUpUI()
    local skillLvText = self.skillNode:getChildByName("Image_skillup_bg"):getChildByName("Text_lv")
    skillLvText:setString(self.pet.skillLv)
    local goldText = self.skillNode:getChildByName("Text_gold")
    local needGold = 100
    goldText:setString(needGold)
end



function PetLayer:checkBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:setCheckBtn(widget)
    end
end

function PetLayer:lvUpBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local t = {}
        t.id = self.pet.id
        mm.req("petlevelup",t)
    end
end

function PetLayer:skillUpBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local t = {}
        t.id = self.pet.id
        mm.req("skillup",t)
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
    local zhanliNum = self.pet.lv + self.pet.skillLv
    self.zhanliText:setString("战斗力:"..zhanliNum)
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
        if event.code == "petlevelup" then
            self.pet.lv = self.pet.lv + 1
            self:updatePublic()
            self:updateLvUI()
        elseif event.code == "skillup" then
            self.pet.skillLv = self.pet.skillLv + 1
            self:updatePublic()
            self:updateSkillUpUI()
        end
    end
end


return PetLayer