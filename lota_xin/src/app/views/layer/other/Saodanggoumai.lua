--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--


local saoDangMoneyTab = {
    {1,2,20},
    {3,9,40},
    {10,19,60},
    {20,29,80},
    {30,49,100},
    {50,79,150},
    {80,99,200},
    {100,149,300},
    {150,200,400},
}

local Saodanggoumai = class("Saodanggoumai", require("app.views.mmExtend.LayerBase"))
Saodanggoumai.RESOURCE_FILENAME = "Saodanggoumai.csb"


function Saodanggoumai:onCleanup()
    self:clearAllGlobalEventListener()
end

function Saodanggoumai:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )


end

function Saodanggoumai:onExit()

end

function Saodanggoumai:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function Saodanggoumai:init(param)
    self.param = param
    self.scene = param.scene

    self.stageId = param.stageId
    self.OnlyBuy = param.OnlyBuy

    if not mm.data.playerinfo.dailyBuySDCount then
        mm.data.playerinfo.dailyBuySDCount = 0
    end

    self.dailyBuySDCount = mm.data.playerinfo.dailyBuySDCount or 0

    local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    local vipInfo = gameUtil.getVipInfoByLevel( vipLv )
    self.vipCanBuyCount = vipInfo.saodangcishu
    print("Saodanggoumai self.vipCanBuyCount   "..self.vipCanBuyCount)
    print("Saodanggoumai self.dailyBuySDCount   "..self.dailyBuySDCount)

    self.hasSaoJuan = self.vipCanBuyCount - self.dailyBuySDCount
    if self.hasSaoJuan == 0 then
        self.cur_num = 0
    else
        self.cur_num = 1 
    end

    self.needMoney = 20

    self:initLayerUI()
end

function Saodanggoumai:initLayerUI( )
    self.Node = self:getResourceNode()

    local Button_Close = self.Node:getChildByName("Image_bg"):getChildByName("Button_Close")
    Button_Close:addTouchEventListener(handler(self, self.ButtonCloseBack))
    gameUtil.setBtnEffect(Button_Close)

    local Button_Reduce = self.Node:getChildByName("Image_bg"):getChildByName("Button_Reduce")
    Button_Reduce:addTouchEventListener(handler(self, self.Button_ReduceBack))
    gameUtil.setBtnEffect(Button_Reduce)

    local Button_Add = self.Node:getChildByName("Image_bg"):getChildByName("Button_Add")
    Button_Add:addTouchEventListener(handler(self, self.Button_AddBack))
    gameUtil.setBtnEffect(Button_Add)

    local Button_MAX = self.Node:getChildByName("Image_bg"):getChildByName("Button_MAX")
    Button_MAX:addTouchEventListener(handler(self, self.Button_MAXBack))
    gameUtil.setBtnEffect(Button_MAX)

    local Button_Saodanggoumai = self.Node:getChildByName("Image_bg"):getChildByName("Button_Saodanggoumai")
    Button_Saodanggoumai:addTouchEventListener(handler(self, self.Button_SaodanggoumaiBack))
    gameUtil.setBtnEffect(Button_Saodanggoumai)

    if self.OnlyBuy then
        Button_Saodanggoumai:setTitleText("购买")
    else
        Button_Saodanggoumai:setTitleText("扫荡")
    end

    self.Text_Tips02 = self.Node:getChildByName("Image_bg"):getChildByName("Text_Tips02")
    self.Text_Tips02:setString(string.format("今日可购买%d次，每日凌晨5点重置", self.hasSaoJuan))


    self.Text_cur = self.Node:getChildByName("Image_bg"):getChildByName("Text_Num")
    self.Text_cur:setString(self.cur_num)

    self.needMoney = self:getNeedMoney( mm.data.playerinfo.dailyBuySDCount, self.cur_num )
    self.needMoneyText = self.Node:getChildByName("Image_bg"):getChildByName("Text_Price")
    self.needMoneyText:setString(self.needMoney)

    
end

function Saodanggoumai:getOneMoney( times )
    for k,v in pairs(saoDangMoneyTab) do
        if tonumber(v[1]) <= tonumber(times) and tonumber(times) <= tonumber(v[2]) then
            return v[3]
        end
    end
    return 400
end

function Saodanggoumai:getNeedMoney( curtimes, times )
    local money = 0
    for i=curtimes + 1,curtimes + times do
        money = money + self:getOneMoney( i )
    end
    return money
end

function Saodanggoumai:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function Saodanggoumai:Button_ReduceBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.cur_num > 1 then
            self.cur_num = self.cur_num - 1
            self.Text_cur:setString(self.cur_num)
            self.needMoney = self:getNeedMoney( mm.data.playerinfo.dailyBuySDCount, self.cur_num )
            self.needMoneyText:setString(self.needMoney)
        end
    end
end

function Saodanggoumai:Button_AddBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.cur_num < self.hasSaoJuan then
            self.cur_num = self.cur_num + 1
            self.Text_cur:setString(self.cur_num)
            self.needMoney = self:getNeedMoney( mm.data.playerinfo.dailyBuySDCount, self.cur_num )
            self.needMoneyText:setString(self.needMoney)
        end
    end
end

function Saodanggoumai:Button_MAXBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.cur_num = self.hasSaoJuan
        self.Text_cur:setString(self.cur_num)
        self.needMoney = self:getNeedMoney( mm.data.playerinfo.dailyBuySDCount, self.cur_num )
        self.needMoneyText:setString(self.needMoney)
    end
end

function Saodanggoumai:Button_SaodanggoumaiBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.cur_num < 1 then
            gameUtil:addTishi({s = "今日可购买扫荡券次数已不足"})
            return
        end
        if not self.OnlyBuy then
            mm.req("saodang",{type=0, stageId = self.stageId, times = self.cur_num})
        else
            mm.req("buySomeThing",{getType = 1, buyType = 7, buyItemInfo = {itemID = 1412444209, itemNum = self.cur_num}})
        end
    end
end

function Saodanggoumai:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saodang" then
            self:removeFromParent()
        elseif event.code == "buySomeThing" then
            if event.t.type == 0 then
                self:removeFromParent()
            else
                gameUtil:addTishi({p = self, s = MoGameRet[event.t.code]})
            end
        end  
    end
end

return Saodanggoumai


