local EquipInfoLayer = class("EquipInfoLayer", require("app.views.mmExtend.LayerBase"))
EquipInfoLayer.RESOURCE_FILENAME = "pet/EquipInfoLayer.csb"

local PetEquipItemRes = "res/pet/PetEquipItem.csb"


function EquipInfoLayer:onEnter()


end

function EquipInfoLayer:onExit()
	
end

function EquipInfoLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function EquipInfoLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function EquipInfoLayer:init(param)
	self.Node = self:getResourceNode()
    self.ImageBg = self.Node:getChildByName("Image_bg")

    self.equipTab = param.equipTab
    self.petTab = param.petTab
    self.usetype = param.usetype
    self.index = param.index

    local equipResId = self.equipTab.resId
    self.resTab = equipTable[equipResId]
    print(" EquipInfoLayer :   self.equipTab      "..json.encode(self.equipTab))
    print(" EquipInfoLayer :   self.resTab      "..json.encode(self.resTab))

    --初始化主界面UI
    self:UIInit()

end

function EquipInfoLayer:UIInit() 
    self.PanelBg = self.Node:getChildByName("Panel_bg")
    self.PanelBg:addTouchEventListener(handler(self, self.backBtnCbk))

    local quality = self.resTab.quality
    local lv = self.equipTab.lv

    self.iconNode = self.ImageBg:getChildByName("Node_icon")
    local layoutData = {res = PetEquipItemRes,layoutName = "Image_bg"}
    local equipNode = cs.ObjectPoolManager:getObject(layoutData)
    self.iconNode:addChild(equipNode)
    equipNode:setAnchorPoint(cc.p(0.5,0.5))
    equipNode:setPosition(0, 0)

    local lvText = equipNode:getChildByName("Text_lv")
    lvText:setString(lv)
    equipNode:loadTexture("res/UI/bIcon/bg_icon_"..quality..".png")

    local iconImage = equipNode:getChildByName("Image_icon")
    iconImage:loadTexture(self.resTab.iconSrc)

    local nameText = self.ImageBg:getChildByName("Text_name")
    nameText:setString(self.resTab.Name)

    local table1 = {"Attack","Crit","Speed"}
    local table2 = {"攻击：+","暴击：+","攻速：+"}
    local table3 = {"攻击：+","减CD：+"}
    local Type = self.resTab.Type
    local xx = table1[Type]..string.format("%02d",quality)
    local zhushuxin = equipLvTable[lv][xx]

    local zhushuxinText = self.ImageBg:getChildByName("Text_zhushuxin")
    zhushuxinText:setString(table2[Type]..zhushuxin)

    local table4 = {"Text_fushuxin_1", "Text_fushuxin_2"}
    local table5 = {"param1", "param2"}
    for i=1,#table4 do
        self.ImageBg:getChildByName(table4[i]):setVisible(false)
    end
    local index = 1
    for i=1,#table4 do
        local num = self.equipTab[table5[i]]
        if num > 0 then
            self.ImageBg:getChildByName(table4[index]):setVisible(true)
            self.ImageBg:getChildByName(table4[index]):setString(table3[i]..num)
            index = index + 1
        end
    end


    self.btn01 = self.ImageBg:getChildByName("Button_1")
    self.btn01:addTouchEventListener(handler(self, self.zbeiBtnCbk))

    

    self.btn02 = self.ImageBg:getChildByName("Button_2")
    self.btn02:addTouchEventListener(handler(self, self.upBtnCbk))

    if self.usetype and self.usetype == 1 then
        self.btn01:setTitleText("卸载")
        self.btn02:setVisible(true)
    else
        self.btn01:setTitleText("穿戴")
        self.btn02:setVisible(false)
    end

end

function EquipInfoLayer:zbeiBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local t = {}
        t.id = self.petTab.id
        t.eqId = self.equipTab.id
        mm.req("wearequip",t)
    end
end

function EquipInfoLayer:upBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 

    end
end


function EquipInfoLayer:setCheckNode() 

end


function EquipInfoLayer:updateLv( event )

end

function EquipInfoLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function EquipInfoLayer:globalEventsListener( event )
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


return EquipInfoLayer