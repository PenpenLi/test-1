

local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)

function LoginScene:ctor()

    game = game or {} 


    self:testNet()


    self.Bg = display.newSprite("res/loginUI/bm_beijing1.jpg")
    self.Bg:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.Bg)
    self.Bg:setPosition(display.cx, display.cy)

    self.setButton = cc.ui.UIPushButton.new({normal = "res/loginUI/bt_shezhi.png", 
    										pressed = "res/loginUI/bt_shezhi.png", 
    										disabled = "res/loginUI/bt_shezhi.png"})
    :align(display.TOP_RIGHT, display.right - 10, display.top - 10)
    :addTo(self)
    self.setButton:onButtonClicked(function(tag)
        self:setBtnCbk()
    end)

    self.iButton = cc.ui.UIPushButton.new({normal = "res/loginUI/bt_renyuan.png", 
    												pressed = "res/loginUI/bt_renyuan.png", 
    												disabled = "res/loginUI/bt_renyuan.png"})
    :align(display.BOTTOM_LEFT, display.left + 10, display.bottom + 10)
    :addTo(self)
    self.iButton:onButtonClicked(function(tag)
        self:iBtnCbk()
    end)

    self.wButton = cc.ui.UIPushButton.new({normal = "res/loginUI/bt_weixin.png", 
    												pressed = "res/loginUI/bt_weixin.png", 
    												disabled = "res/loginUI/bt_weixin.png"})
    :align(display.BOTTOM_RIGHT, display.right - 10, display.bottom + 10)
    :addTo(self)
    self.wButton:onButtonClicked(function(tag)
        self:wBtnCbk()
    end)

    self.fButton = cc.ui.UIPushButton.new({normal = "res/loginUI/bt_facebook.png", 
    												pressed = "res/loginUI/bt_facebook.png", 
    												disabled = "res/loginUI/bt_facebook.png"})
    :align(display.BOTTOM_RIGHT, display.right - 90, display.bottom + 10)
    :addTo(self)
    self.fButton:onButtonClicked(function(tag)
        self:fBtnCbk()
    end)

    self.enterButton = cc.ui.UIPushButton.new({normal = "res/loginUI/bm_kaishi.png", 
    												pressed = "res/loginUI/bm_kaishi.png", 
    												disabled = "res/loginUI/bm_kaishi.png"})
    :align(display.CENTER, display.cx, display.height * 0.25)
    :addTo(self)
    self.enterButton:onButtonClicked(function(tag)
        self:enterBtnCbk()
    end)


    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "开始游戏",
        font  = "font/huakang.TTF",
        size = 42,
    })
    :align(display.CENTER, display.cx, display.height * 0.3)
    :addTo(self)


end

function LoginScene:testNet()
    local clientTCP = require("app.net.ClientTCP")
    game.clientTCP = clientTCP:new()
    game.clientTCP:Connect()


    if device.platform == "ios" then
        game.did = SystemUtil:getUUID(false)
    else
        game.did = "123sfsdfesdd"
    end
    print("did "..game.did)
end

function LoginScene:enterBtnCbk()  
	print(" enterBtnCbk ")
	appInstance:enterMainScene()
end

function LoginScene:setBtnCbk()  

end

function LoginScene:iBtnCbk()  

end

function LoginScene:wBtnCbk()  

end

function LoginScene:fBtnCbk()  

end

return LoginScene
