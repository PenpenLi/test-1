--
-- Created by IntelliJ IDEA.
-- User: sunlu
-- Date: 15/6/16
-- Time: 上午9:59
-- To change this template use File | Settings | File Templates.
--
local SocketTCP = require("app.net.SocketTCP")
game = require("app.models.game")
require("platform")
game:ctor()

if not json then
    require "cocos.cocos2d.json"
end

local UpdateScene = class("UpdateScene", cc.load("mvc").ViewBase)
UpdateScene.RESOURCE_FILENAME = "LoadingScene.csb"

local strNotice = "正在玩命更新%.1fMB数据，更新后可获得更新奖励(%s)"
local strTips = "%s"
local tipsTab = {
    "TIPS:金手指能够加快成长速度",
    "TIPS:敌人护甲多的时候，可以用法师打",
    "TIPS:天梯排名越高奖励越好",
    "TIPS:抢战力可以快速提升天梯排名",
    "TIPS:不上阵的英雄也会有属性加成",
    "TIPS:英雄技能可以互相搭配",
    "TIPS:日常每天得完成哟",
    "TIPS:积极参加活动能快速成长"
}

function UpdateScene:onCreate()
    self.i = 1
    self.scene = self:getChildByName("Scene")

    local ImageBg = self.scene:getChildByName("Image_bg")
    
    ImageBg:setScale(CC_DESIGN_RESOLUTION.height / 960)

    self.scene:getChildByName("Node_Buttom"):setVisible(false)

    self.Text_notice = self.scene:getChildByName("Node_Buttom"):getChildByName("Text_msg")
    self.Tips = self.scene:getChildByName("Node_Buttom"):getChildByName("Text_tips")
    self.Text_version = self.scene:getChildByName("Node_Buttom"):getChildByName("Text_version")
    self.Text_version:setString(LOTA_VERSION)

    self.bar = self.scene:getChildByName("Node_Buttom"):getChildByName("Image"):getChildByName("LoadingBar")
    self.bar:setPercent(0)

    self.TextBar = self.scene:getChildByName("Node_Buttom"):getChildByName("Image"):getChildByName("Text_bar")
    local randomNum = math.random(1, #tipsTab)
    self.Tips:setString(tipsTab[randomNum])
    schedule(self, function()
        local randomNum = math.random(1, #tipsTab)
        self.Tips:setString(tipsTab[randomNum])
    end, 3)

    self:getUpdateAddress()

    self.delayNode = cc.Node:create()
    self:addChild(self.delayNode)
end

function UpdateScene:onError(errorcode)
    if errorcode == cc.ASSETSMANAGER_CREATE_FILE then

    elseif errorcode == cc.ASSETSMANAGER_NETWORK then

    elseif errorcode == cc.ASSETSMANAGER_NO_NEW_VERSION then
        self.currdownload.isdownload = true
        cc.UserDefault:getInstance():setStringForKey(self.currdownload.version,"download")
        cc.UserDefault:getInstance():flush()
    elseif errorcode == cc.ASSETSMANAGER_UNCOMPRESS then

    end

    self:nextPackage()
end

function UpdateScene:onProgress(progress)
    local downloadsize = self.downloadsize + self.currdownload.size * progress / 100
    local percent = math.ceil(downloadsize/self.needdownloadsize*100)
    self.bar:setPercent(percent)
    self.TextBar:setString(downloadsize.."/"..self.needdownloadsize.." K  "..percent.."%")
end

function UpdateScene:onSuccess()
    self.currdownload.isdownload = true
    self.downloadsize = self.downloadsize + self.currdownload.size
    cc.UserDefault:getInstance():setStringForKey(self.currdownload.version,"download")
    cc.UserDefault:getInstance():flush()
    self:nextPackage()
end

function UpdateScene:UpdateSuccess()
    self:ToLoginScene()
end

function UpdateScene:nextPackage()
--    if self.schedulerEntry ~= nil then
--        return
--    end
--    self.schedulerEntry = self.scheduler:scheduleScriptFunc(function()
--        self:downloadpackage()
--        self.scheduler:unscheduleScriptEntry(self.schedulerEntry)
--        self.schedulerEntry = nil
--    end,10,false)

    local action = cc.DelayTime:create(0.1)
    local actionseq = cc.Sequence:create(action,cc.CallFunc:create(function()
        self:downloadpackage()
    end
    ))

    self.delayNode:runAction(actionseq)


end


function UpdateScene:downloadpackage()
    for k,v in pairs(self.needdownload ) do
        if v.isdownload == false then

            if v.downloadcount == 3 then
                --- 三次下载不成功   出问题了
                return
            end


            if self.am ~= nil then
                self.am = nil
            end

            self.currdownload = v
            --local am = cc.AssetsManager:create(LOTA_VERSION_DOWNLOAD..v.package,v.version,v.version,handler(self,self.onError),handler(self,self.onProgress),handler(self,self.onSuccess))

            local path = cc.FileUtils:getInstance():getWritablePath().."update/"..v.version
            cc.FileUtils:getInstance():createDirectory(path)
            self.am = cc.AssetsManager:new("","","")
            self.am:retain()
            self.am:setDelegate(handler(self,self.onError),cc.ASSETSMANAGER_PROTOCOL_ERROR)
            self.am:setDelegate(handler(self,self.onProgress),cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            self.am:setDelegate(handler(self,self.onSuccess),cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
            self.am:setConnectionTimeout(1)

            self.am:setPackageUrl(LOTA_VERSION_DOWNLOAD..v.package)
            self.am:setStoragePath(cc.FileUtils:getInstance():getWritablePath().."update/"..v.version)
            self.am:setVersionFileUrl(LOTA_VERSION_TXT)
--            if self.am:checkUpdate() == false then
--                v.isdownload = true
--                self:nextPackage()
--                return
--            end
            self.am:update()
            return
        end
    end

    self:UpdateSuccess()

end

function UpdateScene:getUpdateAddress()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local DEVICE = "ios"--device.platform

    if DEVICE == "android" then
        xhr:open("POST", "http://"..LOTA_UPDATE..":"..LOTA_UPDATE_PORT.. "/updateAddress")
    elseif DEVICE == "ios" then
        xhr:open("POST", "http://"..LOTA_UPDATE..":"..LOTA_UPDATE_PORT.. "/updateAddress")
    else
        DEVICE = "other"
        xhr:open("POST", "http://"..LOTA_UPDATE..":"..LOTA_UPDATE_PORT.. "/updateAddress")
    end

    
    xhr:setRequestHeader("Content-Type","application/json")

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local result = json.decode(xhr.response)
            LOTA_VERSION_JSON       = result.LOTA_VERSION_JSON
            LOTA_VERSION_TXT        = result.LOTA_VERSION_TXT
            LOTA_VERSION_DOWNLOAD   = result.LOTA_VERSION_DOWNLOAD
            self:StartUpdate()
        else
            self:popLayout("获取更新地址失败")
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(json.encode({PLATFORM = PLATFORM, DEVICE = DEVICE}))
end

function UpdateScene:StartUpdate()

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", LOTA_VERSION_JSON)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local statusString = "Http Status Code:"..xhr.statusText
            self.versioninfo = json.decode(xhr.response)

            ---记录需要下载的包
            ---记录需要下载的包大小
            if self.reconnectLayer ~= nil then
                self.reconnectLayer:removeFromParent()
                self.reconnectLayer = nil
            end

            self.needdownload = {}
            self.needdownloadsize = 0
            self.newVersion = ""

            ---收到版本信息 开始处理
            for k,v in pairs(self.versioninfo) do
                local curTab = self:getVTab(LOTA_VERSION)
                local Tab = self:getVTab(v.version)

                if curTab[3] < Tab[3] then
                    self:popLayout("请下载并安装最新的游戏安装包",self.endGame)
                    return
                end 

                if curTab[4] < Tab[4] and curTab[3] == Tab[3]  then
                    self.newVersion = v.version
                    local isdownload = cc.UserDefault:getInstance():getStringForKey(v.version)
                    --cc.UserDefault:getInstance():getStringForKey("mima",secretText)
                    if isdownload ~= "download" then
                        table.insert(self.needdownload,v)
                        self.needdownloadsize = self.needdownloadsize + v.size
                        ---下载次数0  3次不成功提示检查网络
                        v.downloadcount = 0
                        v.isdownload = false
                    end
                end
            end
            self.Text_notice:setString(string.format(strNotice, self.needdownloadsize/1024, self.newVersion))
            ---需要更新
            if #self.needdownload > 0 then

                self.downloadsize = 0

                self.scene:getChildByName("Node_Buttom"):setVisible(true)
                self:downloadpackage()

                --self:popLayout("正在下载新包，请稍后，临时用策划改",nil)

            else
                self:ToLoginScene()

            end


        else
            --self:ToLoginScene()
            self:popLayout("网络无法连接，请确定网络状况后确定重试")
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

function UpdateScene:popLayout( str, GameOver)
    if self.reconnectLayer == nil then
        if GameOver == nil then
            self.reconnectLayer = cc.CSLoader:createNode("wangluolianjie.csb")
            self.scene:addChild(self.reconnectLayer)
            local size  = cc.Director:getInstance():getWinSize()
            self.reconnectLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(self.reconnectLayer)

            local okBtn = self.reconnectLayer:getChildByName("Button_ok")
            okBtn:setZoomScale(-okBtn:getZoomScale())
            okBtn:setPressedActionEnabled(true)
            okBtn:addTouchEventListener(handler(self, self.okBtnCbk))
            self.reconnectLayer:getChildByName("Text_tishi"):setString(str)
        else
            self.reconnectLayer = cc.CSLoader:createNode("wangluolianjie.csb")
            self.scene:addChild(self.reconnectLayer)
            local size  = cc.Director:getInstance():getWinSize()
            self.reconnectLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(self.reconnectLayer)

            local okBtn = self.reconnectLayer:getChildByName("Button_ok")
            okBtn:setZoomScale(-okBtn:getZoomScale())
            okBtn:setPressedActionEnabled(true)
            okBtn:addTouchEventListener(handler(self, self.endGame))
            self.reconnectLayer:getChildByName("Text_tishi"):setString(str)
        end
    end
end

function UpdateScene:okBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:getUpdateAddress()
    end
end

function UpdateScene:endGame( ... )
    cc.Director:getInstance():endToLua()
end

function UpdateScene:uping( ... )
    
end

function UpdateScene:getVTab(str)
    local tab = {}

    for w in string.gmatch(str,"%d+") do 
        table.insert(tab,tonumber(w))
    end

    return tab 
end

function UpdateScene:ToLoginScene( ... )
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    if device.platform == "windows" then
        
    else
        if self.versioninfo then
            for i=1,#self.versioninfo do
                local srcdir = writablePath.."update/"..self.versioninfo[i].version.."/src/"
                local resdir = writablePath.."update/"..self.versioninfo[i].version.."/res/"
                local path = writablePath.."update/"..self.versioninfo[i].version.."/"
                cc.FileUtils:getInstance():addSearchPath(srcdir,true)
                cc.FileUtils:getInstance():addSearchPath(resdir,true)
                cc.FileUtils:getInstance():addSearchPath(path,true)
            end
        end
    end

    -- if device.platform == "android" then
    --     self.app_:run("LoginSceneFinal") 
    -- elseif device.platform == "ios" then
    --     self.app_:run("LoginSceneFinal") 
    -- else
        self.app_:run("LoginScene") 
    -- end

   
    
end

function UpdateScene:globalEventsListener(event)
    if event.name == EventDef.SERVER_MSG then
        if event.code == "EVENT_CONNECTED" then
            -- require("platform")
            -- if device.platform == "android" and PLATFORM == "dhsdk" then
            --     self.app_:run("LoginSceneFinal") 
            -- elseif device.platform == "ios" and PLATFORM == "dhsdk" then
            --     self.app_:run("LoginSceneFinal") 
            -- else
            --     self.app_:run("LoginScene") 
            -- end
        end
    end
end

function UpdateScene:onCleanup()
    self:clearAllGlobalEventListener()
end


return UpdateScene

