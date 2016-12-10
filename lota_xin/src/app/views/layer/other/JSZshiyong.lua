--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local JSZshiyong = class("JSZshiyong", require("app.views.mmExtend.LayerBase"))
JSZshiyong.RESOURCE_FILENAME = "JSZshiyong.csb"


function JSZshiyong:onCleanup()
    self:clearAllGlobalEventListener()
end

function JSZshiyong:onEnter()
    if mm.GuildId == 10037 and self.RaidsTimes == 0 then
        Guide:startGuildById(10038, self.okBtn)
    else
        mm.GuildId = 999999
        Guide:GuildEnd()
    end
end

function JSZshiyong:onExit()

end

function JSZshiyong:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function JSZshiyong:init(param)
    self.param = param
    self.scene = param.scene

    self.RaidsTimes = param.RaidsTimes
    self.hasRaidsTimes = param.hasRaidsTimes

    self:initLayerUI()
end

function JSZshiyong:initLayerUI( )
    if 0 == self.RaidsTimes then
        self.moneyNum = 0
    elseif self.RaidsTimes > 0 then
        if self.RaidsTimes > 200 then
            self.moneyNum = INITLUA:getRaidsNumByTimes( 200 ).ConsumeDiamond
        else
            self.moneyNum = INITLUA:getRaidsNumByTimes( self.RaidsTimes ).ConsumeDiamond
        end
        
    else
        gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "次数错误",z = 3000})
    end

    local times = self.hasRaidsTimes

    self.Node = self:getResourceNode()

    local moneyText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("moneyText")
    moneyText:setString(self.moneyNum)

    local timesText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("timesText")
    timesText:setString(string.format("剩余次数：%d（可累积）",times))

    local tishiText = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("tishiText")
    tishiText:setString("刷新时间：每日5点刷新")

    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    gameUtil.setBtnEffect(Button_ok)

    self.okBtn = Button_ok

    local Button_close = self.Node:getChildByName("Image_bg"):getChildByName("Button_close")
    Button_close:addTouchEventListener(handler(self, self.ButtonCloseBack))

    local Panel_touch = self.Node:getChildByName("Panel_touch")
    Panel_touch:addTouchEventListener(handler(self, self.ButtonCloseBack))
end



function JSZshiyong:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function JSZshiyong:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if mm.RaidsTwoHour ~= true then
            if self.moneyNum > mm.data.playerinfo.diamond then
                gameUtil.showChongZhi( self, 1 )
                return
            end
            mm.RaidsTwoHour = true
            mm.req("Raids",{type=1, time = 120})

            if mm.GuildId == 10038 then
                Guide:startGuildById(10039, mm.GuildScene.PanelGuildTime)
            end
        else
            
        end

        

    end
end



function JSZshiyong:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "Raids" then
            self:removeFromParent()
        end
    end
end

return JSZshiyong


