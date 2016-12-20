local EquipInfoLayer = class("EquipInfoLayer", require("app.views.mmExtend.LayerBase"))
EquipInfoLayer.RESOURCE_FILENAME = "pet/EquipInfoLayer.csb"

local size  = cc.Director:getInstance():getWinSize()
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

function EquipInfoLayer:getLvExp( eqTab )
    local exp = eqTab.exp
    for i=1,#equipLvTable do
        local UpLvAll = equipLvTable[i].UpLvAll
        if exp < UpLvAll then
            if i == 1 then
                return i, exp, equipLvTable[i].UpLvNeed
            else
                local curExp = equipLvTable[i-1].UpLvAll
                return i, exp-curExp, equipLvTable[i].UpLvNeed
            end
            break
        end
    end
    -- body
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
    print(lv.."lv   xx "..xx)
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

    


    local LoadingBar = self.ImageBg:getChildByName("LoadingBar")
    local lv, exp, needexp = self:getLvExp(self.equipTab)
    LoadingBar:setPercent(math.ceil(exp / needexp * 100))

    local expText = self.ImageBg:getChildByName("Text_exp")
    expText:setString(exp.." / "..needexp)


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
        if self.usetype and self.usetype == 1 then
            local t = {}
            t.petId = self.petTab.id
            t.eqIndex = self.index
            t.soltId = self.equipTab.id
            print("send  "..json.encode(t))
            mm.req("downequip",t)
        else
            local t = {}
            t.id = self.petTab.id
            t.soltId = self.equipTab.id
            t.eqIndex = self.index
            print("send  "..json.encode(t))
            mm.req("wearequip",t)
        end
    end
end

function EquipInfoLayer:upBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local PetCheckEquipLvLayer = require("src.app.views.layer.Pet.PetCheckEquipLvLayer").new({petTab = self.petTab, index = self.index,equipTab = self.equipTab})
        self:addChild(PetCheckEquipLvLayer, MoGlobalZorder[2000002])
        PetCheckEquipLvLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(PetCheckEquipLvLayer)
    end
end


function EquipInfoLayer:setCheckNode() 

end


function EquipInfoLayer:updateLv( event )

end

function EquipInfoLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        print("EquipInfoLayer:backBtnCbk ============================================================  ")
        self:removeFromParent()
    end
end

function EquipInfoLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "wearequip" then
            --self:removeFromParent()
        elseif event.code == "downequip" then
            self:removeFromParent()
        elseif event.code == "equiplevelup" then
            print("equiplevelup Listener   "..json.encode(event))
            if event.t.result == 0 then
                self:removeFromParent()
            end
        
        end
    end
end


return EquipInfoLayer