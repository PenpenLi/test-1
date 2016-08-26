
require("cocos.init")
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")


require("app/util/util")

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

    -- self:enterLoginScene()
    -- self:enterGardenScene()
    self:enterCheckpointScene()

    appInstance = self
end

function MyApp:enterMenuScene(t)
    self:enterScene("MenuScene", t, "rotoZoom", 0.6, display.COLOR_WHITE)
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

function MyApp:enterCheckpointScene()
    self:enterScene("CheckpointScene", nil, "splitRows", 0.6, display.COLOR_WHITE)
end

function MyApp:enterGardenScene()
    self:enterScene("GardenScene", nil, "splitRows", 0.6, display.COLOR_WHITE)
end

function MyApp:enterjieSuanScene(jieguo, checkId)
    self:enterScene("jieSuanScene", {jieguo, checkId}, "moveInT", 0.1, display.COLOR_WHITE)
end

function MyApp:enterPaiHangScene()
    self:enterScene("PaiHangScene", nil, "moveInT", 0.1, display.COLOR_WHITE)
end

function MyApp:playLevel(levelIndex)
    self:enterScene("PlayLevelScene", {levelIndex}, "fade", 0.6, display.COLOR_WHITE)
end


return MyApp
