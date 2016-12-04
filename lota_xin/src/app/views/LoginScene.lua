if not json then
    require "cocos.cocos2d.json"
end
if not util then
    require "util"
end

game = require("app.models.game")
game:ctor()

require "helper"
require "app.views.mmExtend.mm"

require("app.views.mmExtend.gameUtil")

require("app.views.mmExtend.mm_config")

require("app.views.mmExtend.MoGameRet")


game.HorListView = "app.views.rollView.HorListView"
game.HorPageView = "app.views.rollView.HorPageView"
game.VerListView = "app.views.rollView.VerListView"
game.VerPageView = "app.views.rollView.VerPageView"

cs = cs or {}
cs.ObjectPoolManager = require("app.pool.ObjectPoolManager").new()


local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
LoginScene.RESOURCE_FILENAME = "LoginScene.csb"

mm.data.time = mm.data.time or {}

local size  = cc.Director:getInstance():getWinSize()

function LoginScene:onCreate()

    mm.app = self.app_
    
    self.scene = self:getChildByName("Scene")
    self.panel = self.scene:getChildByName("loginpanel")

    

    -- self:addEffect()

    self.panelLayer = self.scene:getChildByName("Panel_layer")

    local bgImageView = ccui.ImageView:create()
    bgImageView:loadTexture("res/UI/bigImage/yijidi.png")
    self.panelLayer:addChild(bgImageView)
    bgImageView:setPosition(size.width * 0.5, size.height * 0.5)
    bgImageView:setScale(CC_DESIGN_RESOLUTION.height / 960)

    -- 初始化按钮
    self:initBtn()

    local accEditBox = cc.EditBox:create(cc.size(326,36), cc.Scale9Sprite:create("res/UI/jm_shurukuang.png"))
    accEditBox:setAnchorPoint(0.5,0.5)
    accEditBox:setFont("res/font/youyuan.TTF", 32)
    accEditBox:setPlaceHolder("点击输入")
    self.accEditBox = accEditBox

    local Node_account = self.scene:getChildByName("Node_account")
    Node_account:addChild(accEditBox)

    local mimaEditBox = cc.EditBox:create(cc.size(326,36), cc.Scale9Sprite:create("res/UI/jm_shurukuang.png"))
    mimaEditBox:setAnchorPoint(0.5,0.5)
    mimaEditBox:setFont("res/font/youyuan.TTF", 32)
    mimaEditBox:setPlaceHolder("点击输入")
    self.mimaEditBox = mimaEditBox

    local account = cc.UserDefault:getInstance():getStringForKey("account","")
    
    self.accEditBox:setText(account)

    self.scene:getChildByName("Text_version"):setString(LOTA_CUR_VERSION)
    -- 得到服务器列表
    self:GetHttp()

    -- mm.musicOpen = cc.UserDefault:getInstance():getIntegerForKey("musicOpen")
    -- if mm.musicOpen == 0 then
    --     AudioEngine.playMusic("res/sounds/music/Main.mp3", true)
    -- else
        AudioEngine.stopMusic(true)
    -- end

    cc.UserDefault:getInstance():setIntegerForKey("effectOpen", 1)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
end



function LoginScene:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "readMail" then
        end
        if event.code == "EVENT_CONNECTED" then
            self:login()
        end
    elseif event.name == EventDef.UI_MSG then
        if event.code == "refreshServerInfo_UI" then
            self:setCurSever()
        elseif event.code == "START_GAME" then
            self:ConnectAndLogin()
        end 
    end
end

function LoginScene:loginBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:ConnectAndLogin()
        -- self:loginTest()

        -- mm.data.playerinfo = {id = 10000001,exp = 400, lv = 5 }
        -- self.app_:run("FightScene")
    end
end

function LoginScene:loginTest( ... )
    local PetListLayer = require("src.app.views.layer.Pet.PetListLayer").new({})
    self:addChild(PetListLayer, 100)
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

    self:showLoading(true)

    local clientTCP = require("app.net.ClientTCP")
    self.app_.clientTCP = clientTCP:new()
    self.app_.clientTCP:Connect()
end

function LoginScene:severBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local SeverLayer = require("src.app.views.layer.SeverLayer").new({scene = self,severList = self.httpTable})

        --self.node = self.scene:getChildByName("Node")
        self.scene:addChild(SeverLayer, 1000)
        local size  = cc.Director:getInstance():getWinSize()
        SeverLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(SeverLayer)
    end
end

function LoginScene:msgBoxBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        
    end
end

function LoginScene:registerBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        --测试通用弹筐
        local severLayer = require("src.app.views.layer.MsgBoxLayer").create({titleText = "提示", msgText = "休休这个臭sb", yesCallBack = "close", node = self})
        local size  = cc.Director:getInstance():getWinSize()
        local x = (size.width - severLayer:getContentSize().width) * 0.5
        local y = (size.height - severLayer:getContentSize().height) * 0.5
        severLayer:setPosition(x, y)
        self:addChild(severLayer)
    end
end

function LoginScene:KuaiSuLoginBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        
    end
end

function LoginScene:jumpToServerLayer( ... )

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

function LoginScene:login()
    local accountText = self.accEditBox:getText()
    local currentServer = gameUtil.getDefaultServerInfo(self.httpTable)
    local curSeverId = currentServer.areaId

    local t = {}
    t.uid       = accountText
    -- t.areaId      = curSeverId
    t.session   = "123456"
    t.qudao     = "aa"
    t.zi_qudao  = PLATFORMVER

    game.loginInfoTab = t
        
    local function loginret(msg)
        print("loginret              !!!!!!!!!!!!!!!!!!!!!!  "..json.encode(msg))
        if msg.result == 0 then

            print("CreateScene loginret       msg.base.pet       !!!!!!!!!!!!!!!!!!!!!!  "..json.encode(msg.pet))

            mm.data.base = msg.base
            mm.data.player = msg.master
            mm.data.player.id = msg.base.id
            mm.data.playerPet = msg.pet
            mm.data.playerEquip = msg.equip
            self.app_:run("FightScene")
            

            cc.UserDefault:getInstance():setStringForKey("account",accountText)
            cc.UserDefault:getInstance():setStringForKey("mima",secretText)
        elseif msg.result == 1 then
            cc.UserDefault:getInstance():setStringForKey("account",accountText)
            cc.UserDefault:getInstance():setStringForKey("mima",secretText)
            self.app_:run("CreateScene") 
        elseif msg.result == 2 then
            --self.accountText:setString("账号或者密码不正确")
            cc.UserDefault:getInstance():setStringForKey("account",accountText)
            cc.UserDefault:getInstance():setStringForKey("mima",secretText)
            self.app_:run("CreateScene") 
        elseif msg.result == 3 then
            local WarningLayer = require("src.app.views.layer.WarningLayer").new({app_ = self.app_, lockEndTime = msg.playerinfo.lockEndTime})
            local size  = cc.Director:getInstance():getWinSize()
            self.scene:addChild(WarningLayer, 100000)
            WarningLayer:setContentSize(size.width, size.height)
            WarningLayer:setPosition(cc.p(0, 0))
            ccui.Helper:doLayout(WarningLayer)
        end
    
    end
    

    print("t              !!!!!!!!!!!!!!!!!!!!!!  "..json.encode(t))
    self.app_.clientTCP:send("login",t, loginret)
    game.LoginSDkData = game.LoginSDkData or {}
    mm.accountText = accountText
    game.LoginSDkData.uid = accountText
    --mm.data.playerinfo.qufu = 1
    game.LoginSDkData.token = '123456'
end
local loadRes = {
    -- "res/FightBg/fight_bg.png",
    -- "res/UI/icon_ditu_lvdi.png",
    -- "res/icon/jiemian/icon_liansheng4.png",
    -- "res/UI/pc_disucai.png",
    -- "res/hero/guanzhong/d_4_qizhi/d_4_qizhi.png",
    -- "res/hero/guanzhong/l_4_qizhi/l_4_qizhi.png",
    -- "res/UI/pc_vs.png",
    -- "res/UI/jm_buzhendi.png",
    -- "res/UI/bt_yingxiong_normal.png",
    -- "res/UI/bt_yingxiong_select.png",
    -- "res/UI/bt_shouzhi_normal.png",
    -- "res/UI/bt_shouzhi_select.png",
    -- "res/UI/bt_shangcheng_normal.png",
    -- "res/UI/bt_shangcheng_select.png",
    -- "res/UI/bt_guanqia_normal.png",
    -- "res/UI/bt_guanqia_select.png",
    -- "res/UI/bt_qizhidota_normal.png",
    -- "res/UI/bt_qizhilol_normal.png",
}

function LoginScene:LoadingScence( ... )
    print("LoadingScence            111")
    local count = 1
    local all = #loadRes
    local function callback( ... )
        if count <= all then
            count = count + 1

            print("LoadingScence            111 "..count)
            display.loadImage(loadRes[count - 1], callback)
            print("LoadingScence            222 "..loadRes[count - 1])
        else
            print("LoadingScence            333 ")
            self.app_:run("FightScene")
        end
    end
    print("LoadingScence            111111111")
    display.loadImage(loadRes[1], callback)
    count = count + 1
    
end


function LoginScene:initBtn( ... )
    self.loginBtn = self.scene:getChildByName("Btn_login")
    self.loginBtn:addTouchEventListener(handler(self, self.loginBtnCbk))
    gameUtil.setBtnEffect(self.loginBtn)

    self.severBtn = self.scene:getChildByName("Image_5")
    self.severBtn:setTouchEnabled(true)
    self.severBtn:getChildByName("Text_5"):setString("")
    self.severBtn:addTouchEventListener(handler(self, self.severBtnCbk))

    self.loginBtnKuaiSu = self.scene:getChildByName("Btn_login_0")
    self.loginBtnKuaiSu:addTouchEventListener(handler(self, self.KuaiSuLoginBtnCbk))
    --self.loginBtnKuaiSu:addTouchEventListener(handler(self, self.registerBtnCbk))
    gameUtil.setBtnEffect(self.loginBtnKuaiSu)

    --self.registerBtn = self.panel:getChildByName("Btn_register")
    --self.registerBtn:addTouchEventListener(handler(self, self.registerBtnCbk))
end

function LoginScene:severBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:jumpToServerLayer()
    end
end

--需要跳转大区选择界面--
function LoginScene:jumpToServerLayer( ... )
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

function LoginScene:showLoading( show ) 
    if self.loadingUI == nil then
        self.loadingUI = cc.CSLoader:createNode("heiloading.csb")
        self:addChild(self.loadingUI, 1000)

        local size  = cc.Director:getInstance():getWinSize()
        self.loadingUI:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(self.loadingUI)


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

function LoginScene:setCurSever()
    if not self.httpTable then
        cclog("not severlist")
        return
    end

    local currentServer = gameUtil.getDefaultServerInfo(self.httpTable)
    local curSeverName = currentServer.name
    local serverId = currentServer.areaId
    LOTA_TCP = currentServer.ip
    LOTA_TCP_PORT = currentServer.port
    cc.UserDefault:getInstance():setStringForKey("severId", serverId)
    
    self.severBtn:getChildByName("Text_5"):setString(curSeverName)

    game.severList = self.httpTable
end

function LoginScene:GetHttp( ... )
    local version = "version" .. "=" .. "dh001"
    local platfrom = "platfrom" .. "=" .. "windows"
    
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    --xhr:open("POST", "http://127.0.0.1:3000/getserverlist?"..version.."&"..platfrom)
    --xhr:open("POST", "http://112.126.85.84:8001/dh/area/getAreaList")
    --xhr:open("POST", "http://192.168.17.120:8001/dh/area/getAreaList")

    xhr:open("POST", "http://"..LOTA_UPDATE..":" .. LOTA_UPDATE_PORT .."/dh/area/getAreaList")
    xhr:setRequestHeader("Content-Type","application/json")

    local accountText = self.accEditBox:getText()
    
    local params = {}
    params.version = version
    params.platfrom = platfrom
    params.TopChannel = TOPCHANNEL or '2' ---非正版IOS渠道
    params.Channel = "dh"
    params.gameChannel = PLATFORM
    params.uid = accountText

    params = json.encode(params)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local statusString = "Http Status Code:"..xhr.statusText
            cclog("--------------------------拉取服务器列表出错--statusString "..statusString)
            cclog("--------------------------拉取服务器列表出错--xhr.response "..xhr.response)
            local result = json.decode(xhr.response)
            if result.type == 0 then
                self.httpTable = result.areaList
                self:setCurSever()

            else
                cclog("--------------------------拉取服务器列表出错--0------------------")
                self.severBtn:getChildByName("Text_5"):setString("")
            end
        else
            cclog("xhr.readyState is:"..xhr.readyState.."xhr.status is: "..xhr.status)
            cclog("--------------------------拉取服务器列表出错--1------------------")
            self.severBtn:getChildByName("Text_5"):setString("")
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(params)
end

function LoginScene:onCleanup()
    self:clearAllGlobalEventListener()
end

return LoginScene
