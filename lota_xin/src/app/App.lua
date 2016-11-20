
local MyApp = class("App", cc.load("mvc").AppBase)

function MyApp:onCreate()
	if device.platform == "android" then
        self.configs_.defaultSceneName = "PlayScene"
    elseif device.platform == "ios" then
    	-- if PLATFORM == "dhsdk" then
     --    	self.configs_.defaultSceneName = "UpdateScene"
    	-- else
    	-- 	self.configs_.defaultSceneName = "PlayScene"
    	-- end
    	self.configs_.defaultSceneName = "UpdateScene"
    else
    	self.configs_.defaultSceneName = "UpdateScene"
    end
    
    math.randomseed(os.time())
    
    -- local clientTCP = require("app.net.ClientTCP")
    -- self.clientTCP = clientTCP:new()
    -- self.clientTCP:Connect()


end

function MyApp:Run(scene)
    self:run(scene) 
end


return MyApp
