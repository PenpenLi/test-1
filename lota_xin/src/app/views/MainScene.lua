
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
MainScene.RESOURCE_FILENAME = "MainScene.csb"

function MainScene:onCreate()
    self.scene = self:getChildByName("Scene")
    self.panel = self.scene:getChildByName("loginpanel")
    
    self.accountText = self.panel:getChildByName("accountText")
    self.secretText  = self.panel:getChildByName("secretText")
    
    self.registerBtn = self.panel:getChildByName("registerBtn")
    self.loginBtn    = self.panel:getChildByName("loginBtn")
    
    
    
    self.loginBtn:addTouchEventListener(function ()
        
            self.app_:run("FightScene")    
    end)
    
end

return MainScene
