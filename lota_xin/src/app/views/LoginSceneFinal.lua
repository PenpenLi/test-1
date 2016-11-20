if not json then
    require "cocos.cocos2d.json"
end
if not util then
    require "util"
end

require "helper"
require "app.views.mmExtend.mm"

require("app.views.mmExtend.gameUtil")

require("app.views.mmExtend.mm_config")

require("app.views.mmExtend.MoGameRet")

require("platform")

local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
LoginScene.RESOURCE_FILENAME = "LoginSceneF.csb"

local size  = cc.Director:getInstance():getWinSize()

mm.data.time = mm.data.time or {}

function LoginScene:onCreate()

    mm.app = self.app_

    self.scene = self:getChildByName("Scene")

    self.panelLayer = self.scene:getChildByName("Panel_layer")

    local bgImageView = ccui.ImageView:create()
    bgImageView:loadTexture("res/UI/dljm_bg00000.png")
    self.panelLayer:addChild(bgImageView)
    bgImageView:setPosition(size.width * 0.5, size.height * 0.5)
    bgImageView:setScale(CC_DESIGN_RESOLUTION.height / 960)

    self:addNewEffect()

    -- 初始化按钮
    self:initBtn()

    if PLATFORM == "tbt" then
        self.scene:getChildByName("Text_version"):setString("3.0")
    else
        self.scene:getChildByName("Text_version"):setString(LOTA_CUR_VERSION)
    end

    game.LoginSDkData = nil

    
    SDKUtil:openLogin()

    mm.musicOpen = cc.UserDefault:getInstance():getIntegerForKey("musicOpen")
    if mm.musicOpen == 0 then
        AudioEngine.playMusic("res/sounds/music/Main.mp3", true)
    else
        AudioEngine.stopMusic(true)
    end

	self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
	self:addListener()

    self:showLoading(false)
end

function LoginScene:onEnter()
    
end

function LoginScene:addNewEffect()
    self.effSkeletonNode = gameUtil.createSkeletonAnimation("res/Effect/uiEffect/dljmdh/goon.json", "res/Effect/uiEffect/dljmdh/goon.atlas",1)
    self.panelLayer:addChild(self.effSkeletonNode)
    self.effSkeletonNode:setAnimation(0, "stand", true)
    
    self.effSkeletonNode:setPosition(size.width * 0.5, size.height * 0.5)
    self.effSkeletonNode:setScale(CC_DESIGN_RESOLUTION.height / 960)
end


function LoginScene:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "readMail" then
        end
        if event.code == "EVENT_CONNECTED" then
            local userData =  game.LoginSDkData
            local sessionId = userData.token
            if userData == nil or sessionId == nil then 
                 self:delayLogout() --拉起切换帐号或者从新登录
                return
            end

            self:dealLoginWithSDK()
        end
	elseif event.name == EventDef.UI_MSG then
        if event.code == "refreshServerInfo_UI" then
            self:setCurSever()
        elseif event.code == "START_GAME" then
            self:ConnectAndLogin()
        end 
    end
end

function LoginScene:addListener()
    self.listeners = {}
    local function eventCustomListener1( ... )
        
    end
    self.listeners[1] = cc.EventListenerCustom:create("event_come_to_background",eventCustomListener1)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[1], 1)

    local function eventCustomListener2( ... )
        
    end
    self.listeners[2] = cc.EventListenerCustom:create("event_come_to_foreground",eventCustomListener2)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[2], 1)
    
    local function loadForSDKEventListener( ... )
        local userData =  SDKUtil:getLoginInfo()
        local t = json.decode(userData)
        game.LoginSDkData = t
        if t.login then
        	if t.login == "success" then
                -- 得到服务器列表
                self:GetHttp()
        	else
                game.LoginSDkData = nil
                SDKUtil:openLogin()
        	end
        else
        
        end
        self:showLoading(false)
    end
    self.listeners[3] = cc.EventListenerCustom:create("login_data_refesh",loadForSDKEventListener)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[3], 1)

end

function LoginScene:dealLoginWithSDK( )
    local userData =  game.LoginSDkData
    local uid = userData.uid
    local sessionId = userData.token
    if userData.param then
        local param = {}
        if type(userData.param) == "table" then
            param = userData.param
        else
            param = json.decode(userData.param)
        end
    end

    local currentServer = gameUtil.getDefaultServerInfo(self.httpTable)
    local curSeverId = currentServer.Areaid

    local t = {}
    t.uid       = uid
    t.qufu          = curSeverId
    t.session       = sessionId
    if PLATFORM == "dhtest" then
        t.qudao         = "dhsdk"
    else
        t.qudao         = PLATFORM
    end
    t.zi_qudao         = PLATFORMVER


    local param = ""
    if type(userData.param) == "table" then
        param = json.encode(userData.param)
    else
        param = userData.param
    end
    
    t.param         = param

    mm.accountText = uid
    
    local function loginret(msg)
        if msg.type == 0 then
            if not msg.playerHero then
                cclog(" 没英雄 ！！！！！！ ")
            end
            mm.data.playerinfo = msg.playerinfo or {}
            mm.data.playerEquip = msg.playerEquip or {}
            mm.data.playerItem = msg.playerItem or {}
            mm.data.playerHunshi = msg.playerHunshi or {}
            mm.data.playerHero = msg.playerHero or {}
            mm.data.playerStage = msg.playerStage or {}
            mm.data.playerTask = msg.playerTask or {}
            mm.data.playerTaskProc = msg.TaskProc or {}
            mm.data.playerFormation = msg.playerFormation or {}
            mm.data.guajiTime = msg.guajiTime or 0
            mm.data.guajiWuPin = msg.guajiWuPin or {}
            mm.data.curDuanWei = msg.curDuanWei
            mm.data.playerExtra = msg.playerExtra
            mm.data.time.skillTime = msg.playerExtra.refreshSkillTime

            mm.data.addPoolExp = msg.addPoolExp
            mm.data.addGold = msg.addGold
            mm.data.addExp = msg.addExp
            mm.data.dropTab = msg.dropTab
            mm.data.noReadNum = msg.noReadNum
            mm.data.closeFuncTab = msg.closeFuncTab or {}
            mm.data.meleeStatus = msg.meleeStatus or 3
            mm.data.ranktime = msg.ranktime

            
            mm.data.activityInfo = msg.activityInfo
            
            mm.data.activityRecord = msg.activityRecord
            
            mm.data.publicActivityExtraInfo = msg.publicActivityExtraInfo

            mm.initTalk( msg.worldTalk )

            local function getDiRenListBack( event )
                if event.type == 0 then
                    mm.direninfo = util.copyTab(event.direninfo)
                    if mm.direninfo == nil then
                        cclog("没有敌方英雄 ！！！！！！！！！！！ ")
                    end
                    mm.direnIndex = 1
                     
                else
                end


                SystemUtil:removeWebView()
                self:LoadingScence()


                --[[
                public static final String xiao_mi_push_regid_key = "push_regid";
                public static final String xiao_mi_push_alias_key = "push_alias";
                public static final String xiao_mi_push_account_key = "push_account";
                public static final String xiao_mi_push_subscribe_key = "push_subscribe";
                --]]
                local pushInfo = {}
                local pushId = tostring(mm.data.playerinfo.id)

                pushInfo.push_alias = pushId --别名可以有多个
                pushInfo.push_account = pushId
                pushInfo.push_subscribe = ""

                pushInfo = json.encode(pushInfo)
                SDKUtil:setPushInfo(pushInfo)
            end
            self.app_.clientTCP:send("getDiRenList",{type=0},getDiRenListBack)


            cc.UserDefault:getInstance():setStringForKey("uid", uid)
            cc.UserDefault:getInstance():setStringForKey("mima",sessionId)

            if device.platform == "android" then
                ---------TODO---------------
            elseif device.platform == "ios" then
                local info = {}
                info.submitType = "Account"
                info.uid_ios = uid
                info = json.encode(info)
                SDKUtil:submitExtendData(info)
            end
        elseif msg.type == 1 then
            self:showLoading(false)

            self:delayLogout()
        elseif msg.type == 2 then
            --self.accountText:setString("账号或者密码不正确")
            cc.UserDefault:getInstance():setStringForKey("uid", uid)
            cc.UserDefault:getInstance():setStringForKey("mima",sessionId)
            self:showLoading(false)

            self.app_:run("CreateScene") 
        elseif msg.type == 3 then
            local WarningLayer = require("src.app.views.layer.WarningLayer").new({app_ = self.app_, lockEndTime = msg.playerinfo.lockEndTime})
            local size  = cc.Director:getInstance():getWinSize()
            self.scene:addChild(WarningLayer, 100000)
            WarningLayer:setContentSize(size.width, size.height)
            WarningLayer:setPosition(cc.p(0, 0))
            ccui.Helper:doLayout(WarningLayer)
        else
            self:showLoading(false)
        end
    end
    
    self.app_.clientTCP:send("login", t, loginret)
    self:showLoading(true)
end


local loadRes = {
    "res/FightBg/land_guaji.png",
    "res/FightBg/ground_lvdi.png",
    "res/UI/icon_ditu_lvdi.png",
    "res/icon/jiemian/icon_liansheng4.png",
    "res/UI/pc_disucai.png",
    "res/hero/guanzhong/d_4_qizhi/d_4_qizhi.png",
    "res/hero/guanzhong/l_4_qizhi/l_4_qizhi.png",
    "res/UI/pc_vs.png",
    "res/UI/jm_buzhendi.png",
    "res/UI/bt_yingxiong_normal.png",
    "res/UI/bt_yingxiong_select.png",
    "res/UI/bt_shouzhi_normal.png",
    "res/UI/bt_shouzhi_select.png",
    "res/UI/bt_shangcheng_normal.png",
    "res/UI/bt_shangcheng_select.png",
    "res/UI/bt_guanqia_normal.png",
    "res/UI/bt_guanqia_select.png",
    "res/UI/bt_qizhidota_normal.png",
    "res/UI/bt_qizhilol_normal.png",
    "res/UI/jm_dadi.png",
    "res/UI/jm_tanchu.png",
    "res/UI/jm_xiaodi.png",
    "res/Effect/uiEffect/sl/sl.png",
    "res/Effect/uiEffect/drcx/drcx.png",
}
function LoginScene:LoadingScence( ... )
    local count = 1
    local all = #loadRes
    local function callback( ... )
        if count <= all then
            count = count + 1
            display.loadImage(loadRes[count - 1], callback)
        else
            self.app_:run("FightScene")
        end
    end

    display.loadImage(loadRes[1], callback)
    count = count + 1



    
end


function LoginScene:showLoading( show ) 
    if self.loadingUI == nil then

        self.loadingUI = cc.CSLoader:createNode("heiloading.csb")
        self:addChild(self.loadingUI)

        local size  = cc.Director:getInstance():getWinSize()
        self.loadingUI:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(self.loadingUI)

        local animNode = self.loadingUI:getChildByName("Node_1")
        local player = cc.Sprite:create("res/hero/loading/loading0001.png")
        player:setScale(1.0)
        animNode:addChild(player)

        local animation = cc.Animation:create()
        animation:addSpriteFrameWithFile("res/hero/loading/loading0001.png")
        animation:addSpriteFrameWithFile("res/hero/loading/loading0002.png")
        animation:addSpriteFrameWithFile("res/hero/loading/loading0003.png")
        animation:setDelayPerUnit(0.1)
        -- animation:setLoops(-1)
        local action = cc.Animate:create(animation)
        local delay = cc.DelayTime:create(0.0)
        local sequence =  cc.Sequence:create(action, delay)
        player:runAction(cc.RepeatForever:create(sequence))


        require("app.res.TipsRes")
        
        local textSrc = ""
        local size = 0
        for k,v in pairs(Tips) do
            size = size + 1
        end
        if size == 0 then
            textSrc = ""
        else
            local index = math.random(1, size)
            local tempIndex = 0
            for k,v in pairs(Tips) do
                tempIndex = tempIndex + 1
                if tempIndex == index then
                    textSrc = v.LoadingTips
                    break
                end
            end
            -- textSrc = Tips[index].LoadingTips
        end
        local textNode = self.loadingUI:getChildByName("Text_1")
        textNode:setString(textSrc)


        local loadingText = self.loadingUI:getChildByName("Text")
        local num = 1
        local function flyBack( ... )
            local append = ""
            if num == 1 then
                append = ""
            elseif num == 2 then
                append = "."
            elseif num == 3 then
                append = ".."
            else
                append = "..."
            end
            loadingText:setString("用力加载中"..append)
            num = num + 1
            if num > 4 then
                num = 1
            end
        end
        local sequence = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(flyBack) )
        loadingText:runAction(cc.RepeatForever:create(sequence))
    end

    self.loadingUI:setVisible(show)
end

--需要跳转大区选择界面--
function LoginScene:jumpToServerLayer( ... )
    if game.LoginSDkData == nil then
        self:delayLogout() --拉起切换帐号或者从新登录
        return
    end

    self:showLoading(false)

    if self.SeverLayer ~= nil then
        self.SeverLayer:removeFromParent()
        self.SeverLayer = nil
    end
    
    self.SeverLayer = require("src.app.views.layer.SeverLayer").new({scene = self,severList = self.httpTable})

    --self.node = self.scene:getChildByName("Node")
    self.scene:addChild(self.SeverLayer, 1000)
    local size  = cc.Director:getInstance():getWinSize()
    self.SeverLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.SeverLayer)
end

function LoginScene:delayLogin( ... )
    --self:setButtonTouchEnabled(false)
    self:showLoading(false)
    if device.platform == "android" then
        self:performWithDelay(
            function( ... )
                cc.Director:getInstance():stopAnimation()
                SDKUtil:openLogin()
            end
        ,0.3) 
    elseif device.platform == "ios" then
        SDKUtil:openLogin() 
    else
        SDKUtil:openLogin()
    end
end

function LoginScene:delayLogout( ... )
    --self:setButtonTouchEnabled(false)
    self:showLoading(false)
    if device.platform == "android" then
        self:performWithDelay(
            function( ... )
                cc.Director:getInstance():stopAnimation()
                SDKUtil:openLogOut()
            end
        ,0.3) 
    elseif device.platform == "ios" then
        SDKUtil:openLogOut() 
    else
        SDKUtil:openLogOut()
    end

    
end

function LoginScene:performWithDelay(callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return sequence
end

function LoginScene:severBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:jumpToServerLayer()
    end
end

function LoginScene:msgBoxBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        
    end
end

function LoginScene:loginBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local userData =  game.LoginSDkData
        local sessionId = nil
        if userData then
            sessionId = userData.token
        end
        
        if userData == nil or sessionId == nil then 
            self:delayLogout() --拉起切换帐号或者从新登录
            return
        end
        self:ConnectAndLogin()
    end
end

function LoginScene:ConnectAndLogin()
    local currentServer = gameUtil.getDefaultServerInfo(self.httpTable)
    if not currentServer then
        gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "大区不存在", z = 100})
        return
    else
        if currentServer.Status == "4" then
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "大区维护中", z = 100})
            return
        end
    end

    -- local severId = cc.UserDefault:getInstance():getIntegerForKey("severId",0)
    -- if 0 == severId then
    --     gameUtil:addTishi({s = "大区不存在", z = 100})
    --     return
    -- else
    --     for k,v in pairs(self.httpTable) do
    --         if v.id == severId then
    --             if v.Status == "4" then
    --                 gameUtil:addTishi({s = "大区维护中", z = 100})
    --                 return
    --             end
    --         end
    --     end
    -- end

    if self.app_.clientTCP ~= nil then
        self.app_.clientTCP:disconnect()
        self.app_.clientTCP = nil
    end

    self:showLoading(true)

    local clientTCP = require("app.net.ClientTCP")
    self.app_.clientTCP = clientTCP:new()
    self.app_.clientTCP:Connect()
end

function LoginScene:initBtn( ... )
    self.loginBtn = self.scene:getChildByName("Btn_login")
    self.loginBtn:addTouchEventListener(handler(self, self.loginBtnCbk))
    gameUtil.setBtnEffect(self.loginBtn)

    self.severBtn = self.scene:getChildByName("Image_5")
    self.severBtn:setTouchEnabled(true)
    self.severBtn:getChildByName("Text_5"):setString("")
    self.severBtn:addTouchEventListener(handler(self, self.severBtnCbk))
    --gameUtil.setBtnEffect(self.severBtn)

    --self.registerBtn = self.panel:getChildByName("Btn_register")
    --self.registerBtn:addTouchEventListener(handler(self, self.registerBtnCbk))
end

function LoginScene:setCurSever()
    if not self.httpTable then
        return
    end

    local currentServer = gameUtil.getDefaultServerInfo(self.httpTable)
    local curSeverName = currentServer.Name
    LOTA_TCP = currentServer.IP
    LOTA_TCP_PORT = currentServer.Port
    cc.UserDefault:getInstance():setStringForKey("severId",currentServer.Areaid)

    -- local curSeverName = ""
    -- local severId = cc.UserDefault:getInstance():getIntegerForKey("severId",0)
    -- if 0 == severId then
    --     util.tableSort(self.httpTable,"id",false)
    --     curSeverName = self.httpTable[1].Name
    --     local serverId = self.httpTable[1].Areaid
    --     LOTA_TCP = self.httpTable[1].IP
    --     cc.UserDefault:getInstance():setStringForKey("severId",serverId)
    -- else
    --     for k,v in pairs(self.httpTable) do
    --         if tonumber(v.Areaid) == tonumber(severId) then
    --             curSeverName = v.Name
    --             LOTA_TCP = v.IP
    --             LOTA_TCP_PORT = v.Port
    --         end
    --     end
    -- end
    self.severBtn:getChildByName("Text_5"):setString(curSeverName)

    game.severList = self.httpTable
end

function LoginScene:GetHttp( ... )
    local version = "version" .. "=" .. "dh001"
    local platfrom = "platfrom" .. "=" .. "android"

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    --xhr:open("POST", "http://127.0.0.1:3000/getserverlist?"..version.."&"..platfrom)
    --xhr:open("POST", "http://112.126.85.84:8001/dh/area/getAreaList")
    --xhr:open("POST", "http://192.168.17.120:8001/dh/area/getAreaList")

    xhr:open("POST", "http://"..LOTA_UPDATE..":" .. LOTA_UPDATE_PORT .."/dh/area/getAreaList")
    xhr:setRequestHeader("Content-Type","application/json")
    

    local params = {}
    params.version = version
    params.platfrom = platfrom
    params.TopChannel = TOPCHANNEL or '2' ---非正版IOS渠道
    params.Channel = "dh"
    params.gameChannel = PLATFORM
    params.uid = game.LoginSDkData.uid or 1001

    params = json.encode(params)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local statusString = "Http Status Code:"..xhr.statusText

            local result = json.decode(xhr.response)
            if result.type == 0 then
                self.httpTable = json.decode(result.areaList)
                self:setCurSever()

                if self.GongGaoLayer ~= nil then
                    self.GongGaoLayer:removeFromParent()
                    self.GongGaoLayer = nil
                end
                
                self.GongGaoLayer = require("src.app.views.layer.GongGaoLayer").new({scene = self})
                self.scene:addChild(self.GongGaoLayer, 1200)

            else
                self.severBtn:getChildByName("Text_5"):setString("")
            end
        else
            self.severBtn:getChildByName("Text_5"):setString("")
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(params)
end

function LoginScene:onCleanup() 
    
    if self.listeners ~= nil then 
        for k,v in pairs(self.listeners) do
           self:getEventDispatcher():removeEventListener(v)
        end
    end
    self:clearAllGlobalEventListener()

    gameUtil.removeArmatureFile("res/Effect/uiEffect/dljmdh/dljmdh.ExportJson")
end

return LoginScene
