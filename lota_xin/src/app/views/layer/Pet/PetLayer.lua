local PetLayer = class("PetLayer", require("app.views.mmExtend.LayerBase"))
PetLayer.RESOURCE_FILENAME = "pet/PetLayer.csb"

local size  = cc.Director:getInstance():getWinSize()

local PetEqBgItemRes = "res/pet/PetEqBgItem.csb"
local PetEquipItemRes = "res/pet/PetEquipItem.csb"


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

    -- self.petEquip = mm.data.petEquip
    -- print(" PetLayer :   self.pet      "..json.encode(param))
    -- print(" PetLayer :   self.pet      "..json.encode(self.pet))



    --初始化主界面UI
    self:UIInit()

end

function PetLayer:setSorts( ... )
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

    
end

function PetLayer:equipSort( tab )
    local function sort_rule( a, b )
        if a.quality > b.quality then
            return true
        end
    end
    table.sort(tab, sort_rule)
    return tab
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

function PetLayer:initEquipUIBtn()
    local table1 = {"Button_0", "Button_1", "Button_2", "Button_3"}
    for i=1,#table1 do
        local btn = self.fashionNode:getChildByName(table1[i])
        btn:setTag(i-1)
        btn:addTouchEventListener(handler(self, self.EquipViewBtnCbk))
    end
end

function PetLayer:EquipViewBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        print("EquipViewBtnCbk  ========  "..tag)
        self:updateEquipUI(tag)
    end
end

function PetLayer:updateEquipUI(index)
    self.sortIndex = index
    self:setSorts()

    if self.sortIndex == 0 then
        self.checkTab = self.all
    else
        self.checkTab =   self.sorts[self.sortIndex] 
    end


    self.viewNode = self.fashionNode:getChildByName("Image_equip_bg"):getChildByName("viewNode")
    
    print("self.checkTab  ========  "..#self.checkTab)
    self.hang = #self.checkTab / 5
    print("self.hang  ========1  "..self.hang)
    if #self.checkTab % 5 > 0 then
        self.hang = self.hang + 1
    end
    print("self.hang  ========2  "..self.hang)
    -- print("self.checkTab  ========  "..json.encode(self.checkTab))

    
    self:updateList()
end

function PetLayer:updateList() 
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
        size = cc.size(630,354 * display.height / 1136),
    }
    local listView = require(game.VerListView):create(t)
    listView:setPosition(0, 0)
    self.listView = listView
    self.viewNode:addChild(listView,100)


end

function PetLayer:updateItem(cell,tag,isInit) 
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

            equipNode:addTouchEventListener(handler(self, self.checkEquipBtnCbk))
            equipNode:setSwallowTouches(false)
            equipNode:setTag(index)
        end
    end

end

function PetLayer:checkEquipBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        local equipTab = self.checkTab[tag]
        print("tag =============== "..tag)

        local EquipInfoLayer = require("src.app.views.layer.Pet.EquipInfoLayer").new({equipTab = equipTab, petTab = self.pet})
        self:addChild(EquipInfoLayer, 10000)
        EquipInfoLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(EquipInfoLayer)

    end
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
        self:initEquipUIBtn()
        self:updateEquipUI(0)
    elseif btn:getName() == "Button_evolution" then
        self.evolutionNode:setVisible(true)
    end
end

function PetLayer:updatePublic()
    local zhanliNum = self.pet.lv + self.pet.skillLv
    self.zhanliText:setString("战斗力:"..zhanliNum)
    print("eqIndex ============================  "..self.pet.id)
    print("eqIndex ============================  "..json.encode(self.pet))

    local table1 = {"Image_Eq_01", "Image_Eq_02", "Image_Eq_03"}
    local playerNode = self.Node:getChildByName("Node_player")
    for i=1,#table1 do
        local eqIndex = self.pet["eq0"..i]

        if eqIndex > 100000000 then
            local eqTab
            for k,v in pairs(self.checkTab) do
                if v.id == eqIndex then
                    eqTab = v
                end
            end
            if eqTab then
                local equipResId = eqTab.resId
                self.resTab = equipTable[equipResId]
                local quality = self.resTab.quality
                local lv = eqTab.lv

                local img = playerNode:getChildByName(table1[i])
                local layoutData = {res = PetEquipItemRes,layoutName = "Image_bg"}
                local equipNode = cs.ObjectPoolManager:getObject(layoutData)
                img:addChild(equipNode)
                equipNode:setAnchorPoint(cc.p(0.5,0.5))
                equipNode:setPosition(img:getContentSize().width * 0.5 , img:getContentSize().height * 0.5)

                local lvText = equipNode:getChildByName("Text_lv")
                lvText:setString(lv)
                equipNode:loadTexture("res/UI/bIcon/bg_icon_"..quality..".png")

                local iconImage = equipNode:getChildByName("Image_icon")
                iconImage:loadTexture(self.resTab.iconSrc)
                equipNode:setTag(i)
                equipNode:addTouchEventListener(handler(self, self.petEquipBtnCbk))
            end
        end
    end
    
end

function PetLayer:petEquipBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        print("tag =============== "..tag)

        local eqIndex = self.pet["eq0"..tag]

        local eqTab
        for k,v in pairs(self.checkTab) do
            if v.id == eqIndex then
                eqTab = v
            end
        end

        if eqTab then
            local EquipInfoLayer = require("src.app.views.layer.Pet.EquipInfoLayer").new({equipTab = eqTab, petTab = self.pet, usetype = 1, index = tag})
            self:addChild(EquipInfoLayer, MoGlobalZorder[2000002])
            EquipInfoLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(EquipInfoLayer)

        end

        

    end
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