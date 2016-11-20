--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local GongGaoLayer = class("GongGaoLayer", require("app.views.mmExtend.LayerBase"))
GongGaoLayer.RESOURCE_FILENAME = "GonggaoLayer.csb"




function GongGaoLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function GongGaoLayer:onEnter()

end

function GongGaoLayer:onExit()

end

function GongGaoLayer:onCreate(param)
    self:init(param)

end

function GongGaoLayer:init(param)
    self.param = param
    self.scene = param.scene

    self:url()

    self.Node = self:getResourceNode()

    self.btnTuchNum = 0

    self:initLayerUI()
    self:initListen()
end

function GongGaoLayer:url( ... )
    self.url1 = "http://mm.17m3.com/3g/index_3.html"
    self.url2 = "http://www.lolvsdota.cn/3g/index.html"
    if PLATFORM == "appstore" then

    elseif PLATFORM == "dhtest" then
        self.url1 = "http://www.lolvsdota.cn/3g/Ad_default.html"
        self.url2 = "http://www.lolvsdota.cn/3g/default.html"
    else
        self.url1 = "http://www.lolvsdota.cn/3g/Ad_Index.html"
        self.url2 = "http://www.lolvsdota.cn/3g/index.html"
    end
end

function GongGaoLayer:initListen( ... )
    local function comeToForeground( ... )
        self:showWebView()
    end

    self.listener1 = cc.EventListenerCustom:create("mm_come_to_foreground",comeToForeground)
    local eventDispatcher1 = self:getEventDispatcher()
    eventDispatcher1:addEventListenerWithFixedPriority(self.listener1 , 1)


    local function onWindowFocus( ... )
        self:showWebView()
    end

    self.listener2 = cc.EventListenerCustom:create("on_window_focus",onWindowFocus)
    local eventDispatcher2 = self:getEventDispatcher()
    eventDispatcher2:addEventListenerWithFixedPriority(self.listener2, 1)
end

function GongGaoLayer:initLayerUI( )
    self.posModel = self.Node:getChildByName("Panel_1")
    
    self.bacBtn = self.Node:getChildByName("Button_1")
    self.bacBtn:addTouchEventListener(handler(self, self.Callback))
    gameUtil.setBtnEffect(self.bacBtn)

    self.text = self.Node:getChildByName("Image_listView"):getChildByName("Text_01")
    
    
    self:showWebView()
    gameUtil.bulletin = self
end

function GongGaoLayer:showWebView( url )
    local winWidth  = cc.Director:getInstance():getVisibleSize().width
    local winHeight = cc.Director:getInstance():getVisibleSize().height
    
    local modelPosX,modelPosY = self.posModel:getPosition()
    local modelWorldPos = self.posModel:getParent():convertToWorldSpace(cc.p(modelPosX, modelPosY))
    
    local box = self.posModel:getContentSize()

    local screenW = SystemUtil:getVisibleViewW()
    local screenH = SystemUtil:getVisibleViewH()
    local viewH = (box.height/winHeight) * screenH
    local viewW = (box.width/winWidth) * screenW
  
    local startX = (((winWidth-box.width) * 0.50)/winWidth) * screenW
    local startY = (((winHeight-box.height) * 0.50)/winHeight)*screenH

    if self.btnTuchNum == 0 then
        SystemUtil:lodeWebView(self.url1, startX,startY,viewW,viewH)
    else
        SystemUtil:lodeWebView(self.url2, startX,startY,viewW,viewH)
    end
end




function GongGaoLayer:Callback(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.btnTuchNum == 0 then
            local targetPlatform = cc.Application:getInstance():getTargetPlatform()
            if (cc.PLATFORM_OS_WINDOWS ~= targetPlatform) then
                SystemUtil:removeWebView()
            end
            self.btnTuchNum = 1
            self:showWebView()

            self.text:setString("精彩活动列表")
            
            -- self:removeBulletin()
        else
            self:removeBulletin()
        end

        
    end
end

function GongGaoLayer:removeBulletin( ... )
    -- body
    gameUtil.bulletin = nil
    self:removeListener()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_WINDOWS ~= targetPlatform) then
        SystemUtil:removeWebView()
    end
    self.scene.GongGaoLayer = nil
    self:removeFromParent()

    

end

function GongGaoLayer:removeListener( ... )
    -- body
    if self.listener1 ~= nil then 
         self:getEventDispatcher():removeEventListener(self.listener1)
    end

    if self.listener2 ~= nil then 
         self:getEventDispatcher():removeEventListener(self.listener2)
    end
end


return GongGaoLayer


