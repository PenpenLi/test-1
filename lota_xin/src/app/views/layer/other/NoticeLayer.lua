local NoticeLayer = class("NoticeLayer", require("app.views.mmExtend.LayerBase"))
--NoticeLayer.RESOURCE_FILENAME = "NoticeLayer.csb"

function NoticeLayer:onCreate(param)

    local winSize = cc.Director:getInstance():getVisibleSize()
    self._webView = ccexp.WebView:create()
    self._webView:setPosition(winSize.width / 2, winSize.height / 2 - 40)
    self._webView:setContentSize(winSize.width / 2,  winSize.height / 2)
    self._webView:loadURL("http://www.baidu.com")
    self._webView:setScalesPageToFit(true)

    self._webView:setOnShouldStartLoading(function(sender, url)
        return true
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
    end)

    self:addChild(self._webView)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function NoticeLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function NoticeLayer:onEnter()
    
end

function NoticeLayer:onExit()
    
end

function NoticeLayer:onEnterTransitionFinish()
    
end

function NoticeLayer:onExitTransitionStart()
    
end

function NoticeLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return NoticeLayer