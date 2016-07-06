
require("cocos.init")
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self.objects_ = {}
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    display.addSpriteFrames(GAME_TEXTURE_DATA_FILENAME, GAME_TEXTURE_IMAGE_FILENAME)

    -- preload all sounds
    for k, v in pairs(GAME_SFX) do
        audio.preloadSound(v)
    end

    self:enterLoginScene()

    appInstance = self
end

function MyApp:enterMenuScene()
    self:enterScene("MenuScene", nil, "rotoZoom", 0.6, display.COLOR_WHITE)
end

function MyApp:enterLoginScene()
    self:enterScene("LoginScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:enterMainScene()
    self:enterScene("MainScene", nil, "turnOffTiles", 0.6, display.COLOR_WHITE)
end

function MyApp:enterChooseLevelScene()
    self:enterScene("ChooseLevelScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:playLevel(levelIndex)
    self:enterScene("PlayLevelScene", {levelIndex}, "fade", 0.6, display.COLOR_WHITE)
end


return MyApp
