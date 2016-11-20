require "helper"
require("platform")

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)
PlayScene.RESOURCE_FILENAME = "LoginSceneWhat.csb"

function PlayScene:onCreate()
    self.scene = self:getChildByName("Scene")

    self.rootNodeMM = self.scene:getChildByName("Panel_2")
    self.rootNodeOther = self.scene:getChildByName("Panel_1")

    self.rootNodeMM:setVisible(false)
    self.rootNodeOther:setVisible(false)
end

function PlayScene:onEnter()
    if PLATFORM == "dhsdk" or PLATFORM == "dhtest" then
        self.rootNodeMM:setVisible(true)
        local function callback( ... )
            self.app_:run("UpdateScene")
        end
        self:performWithDelay(callback, 2)
    elseif PLATFORM == "qmzs" then
        self.rootNodeMM:setVisible(true)

        local function callback1( ... )
            -- self.rootNodeMM:setVisible(false)
            -- local qmzs = cc.Sprite:create("res/channel/qmzs.jpg")
            local imView = ccui.ImageView:create()
            imView:loadTexture("res/channel/qmzs.jpg")
            imView:setAnchorPoint(cc.p(0.5,0.5))

            local size  = cc.Director:getInstance():getWinSize()
            -- imView:setContentSize(cc.size(size.width, size.height))
            local imgSize = imView:getContentSize()
            imView:setScaleX(size.width/imgSize.width)
            imView:setScaleY(size.height/imgSize.height)
            imView:setPosition(size.width/2,size.height/2)

            self.rootNodeMM:addChild(imView)
        end

        local function callback2( ... )
            self.app_:run("UpdateScene")
        end
        self:performWithDelay(callback1, 2)
        self:performWithDelay(callback2, 4)
    else
        self.rootNodeMM:setVisible(false)
        self.rootNodeOther:setVisible(false)
        self.app_:run("UpdateScene")
    end
end

function PlayScene:performWithDelay(callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return sequence
end

function PlayScene:onCleanup() 
    
    if self.listeners ~= nil then 
        for k,v in pairs(self.listeners) do
           self:getEventDispatcher():removeEventListener(v)
        end
    end
    self:clearAllGlobalEventListener()
end

return PlayScene
