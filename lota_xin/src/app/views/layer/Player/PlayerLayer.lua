local PlayerLayer = class("PlayerLayer", require("app.views.mmExtend.LayerBase"))
PlayerLayer.RESOURCE_FILENAME = "player/PlayerLayer.csb"

function PlayerLayer:onEnter()


end

function PlayerLayer:onExit()
	
end

function PlayerLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function PlayerLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function PlayerLayer:init(param)
	self.Node = self:getResourceNode()
    self.ImageBg = self.Node:getChildByName("Image_bg")

    --初始化主界面UI
    self:UIInit()

end

function PlayerLayer:UIInit() 
    self.backBtn = self.ImageBg:getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.zhanliText = self.Node:getChildByName("Text_zhanli")
    self.nameText = self.Node:getChildByName("Text_name")
    self.nameText:setString(mm.data.base.nickName or "无名字？")
    self:updatePublic()



    self.checkLvBtn = self.ImageBg:getChildByName("Button_lv")
    self.checkLvBtn:addTouchEventListener(handler(self, self.checkBtnCbk))

    self.checkSkillBtn = self.ImageBg:getChildByName("Button_skill")
    self.checkSkillBtn:addTouchEventListener(handler(self, self.checkBtnCbk))

    self.checkFashionBtn = self.ImageBg:getChildByName("Button_fashion")
    self.checkFashionBtn:addTouchEventListener(handler(self, self.checkBtnCbk))

    self.lvUpNode = self.Node:getChildByName("Node_lvUp")
    self.skillNode = self.Node:getChildByName("Node_skill")
    self.fashionNode = self.Node:getChildByName("Node_fashion")

    self:setCheckBtn(self.checkLvBtn)

    self.lvUpBtn = self.lvUpNode:getChildByName("Button_LvUp")
    self.lvUpBtn:addTouchEventListener(handler(self, self.lvUpBtnCbk))
    self:updateLvUI()

    self.skillUpBtn = self.skillNode:getChildByName("Button_skillUp")
    self.skillUpBtn:addTouchEventListener(handler(self, self.skillUpBtnCbk))
    self:updateSkillUpUI()

end

function PlayerLayer:updatePublic()
    local zhanliNum = mm.data.player.lv + mm.data.player.skillLv
    self.zhanliText:setString("战斗力:"..zhanliNum)
end

function PlayerLayer:updateLvUI()
    local lvText = self.lvUpNode:getChildByName("Image_lvup_bg"):getChildByName("Text_lv")
    lvText:setString(mm.data.player.lv)
    local goldText = self.lvUpNode:getChildByName("Text_gold")
    local needGold = 100
    goldText:setString(needGold)
end

function PlayerLayer:updateSkillUpUI()
    local skillLvText = self.skillNode:getChildByName("Image_skillup_bg"):getChildByName("Text_lv")
    skillLvText:setString(mm.data.player.skillLv)
    local goldText = self.skillNode:getChildByName("Text_gold")
    local needGold = 100
    goldText:setString(needGold)
end

function PlayerLayer:lvUpBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local t = {}
        mm.req("masterlevelup",t)
    end
end

function PlayerLayer:skillUpBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local t = {}
        t.id = 0
        mm.req("skillup",t)
    end
end


function PlayerLayer:checkBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:setCheckBtn(widget)
    end
end

function PlayerLayer:setCheckNode() 

end

function PlayerLayer:setCheckBtn(btn) 
    self.checkLvBtn:setBright(true)
    self.checkSkillBtn:setBright(true)
    self.checkFashionBtn:setBright(true)

    self.checkLvBtn:setEnabled(true)
    self.checkSkillBtn:setEnabled(true)
    self.checkFashionBtn:setEnabled(true)

    btn:setBright(false)
    btn:setEnabled(false)

    self.lvUpNode:setVisible(false)
    self.skillNode:setVisible(false)
    self.fashionNode:setVisible(false)
    if btn:getName() == "Button_lv" then
        self.lvUpNode:setVisible(true)
    elseif btn:getName() == "Button_skill" then
        self.skillNode:setVisible(true)
    elseif btn:getName() == "Button_fashion" then
        self.fashionNode:setVisible(true)
    end
end

function PlayerLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function PlayerLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "masterlevelup" then
            self:updatePublic()
            self:updateLvUI()
        elseif event.code == "skillup" then
            self:updatePublic()
            self:updateSkillUpUI()
        end
    end
end


return PlayerLayer