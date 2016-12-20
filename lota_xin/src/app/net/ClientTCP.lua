local ClientTCP = class("ClientTCP",require("cocos.framework.components.event"))
local SocketTCP = require("app.net.SocketTCP")

local scheduler = cc.Director:getInstance():getScheduler()


local proto = require ("app.net.proto")
local sproto = require ("app.net.sproto")
require "app.views.mmExtend.mm"

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))


local tcpIsOK = true
local lastConnectTime = 0

function ClientTCP:ctor()
    self:init_()
end

local session = 0
local sessionmap = {}

function ClientTCP:send_package( pack)
    local size = #pack

    local a = math.mod(size,256)
    size = math.floor(size / 256)

    local b = math.mod(size,256)
    size = math.floor(size / 256)

    local package = string.char(b)..string.char(a)..pack
    self.socket:send(package)
end


function ClientTCP:send_request(name, args,callback)
    session = session + 1
    
    if callback ~= nil then
        sessionmap[session] = callback
    end
    
    local str = request(name, args, session)
    self:send_package( str)

    if callback ~= nil then
        return session
    else
        return nil
    end
end


function ClientTCP:Connect(ip,port)
    print("----------------Connect----------------start-"..LOTA_TCP..":"..LOTA_TCP_PORT)
    self.socket = SocketTCP.new(LOTA_TCP, LOTA_TCP_PORT, false)

    self.socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_DATA, handler(self,self.onData))
    self.socket:connect()
    print("----------------Connect----------------end-")
    self.recvdata = ""
end

function ClientTCP:send(name,msg,callback)
    if tcpIsOK then
        return self:send_request(name,msg,callback)
    else
        self:reconnect()
    end
end

function ClientTCP:onData(msg)

    local function unpack_package(text)
        local size = #text
        if size < 2 then
            return nil, text
        end
        local s = text:byte(1) * 256 + text:byte(2)
        if size < s+2 then
            return nil, text
        end

        return text:sub(3,2+s), text:sub(3+s)
    end


    local function process_request(name, args)
--        print("REQUEST", name)
--        if args then
--            for k,v in pairs(args) do
--                print(k,v)
--            end
--        end
        --assert("REQUEST"==name)

        printInfo("REQUEST(%s)", name)
        
        self:dispatchEvent({name = name,data=args})
    end

    local function process_response(session, args)
--        print("RESPONSE", session)
--        if args then
--            for k,v in pairs(args) do
--                print(k,v)
--            end
--        end
        if sessionmap[session] ~= nil then
            local callback = sessionmap[session]
            callback(args)
            -- if xpcall(callback,args) then
            -- else
            --     print("callback error")
            -- end
            
            sessionmap[session] = nil

            -- if g_fightLoadingLayer then
            --     g_fightLoadingLayer:getChildByName("Image"):setVisible(false)
            --     g_fightLoadingLayer:getChildByName("Text"):setVisible(false)
            --     g_fightLoadingLayer:setVisible(false)
            --     g_fightLoadingLayer:stopAllActions()
            -- end
        end

    end


    local function print_package(t, ...)
        if t == "REQUEST" then
            process_request(...)
        else
            assert(t == "RESPONSE")
            process_response(...)
        end
    end

    self.recvdata = self.recvdata..msg.data

    for i = 1,100 do
        local v
        v, self.recvdata = unpack_package(self.recvdata)
        if v then
            print_package(host:dispatch(v))
        else
            break
        end
    end
end

function ClientTCP:onStatus(msg)
    -- print("onStatus------------------"..msg.name.."-------------------")
    -- print("onStatus-1-----------------"..SocketTCP.EVENT_CONNECTED)
    -- print("onStatus-2-----------------"..SocketTCP.EVENT_CLOSED)
    -- print("onStatus-3-----------------"..SocketTCP.EVENT_CONNECT_FAILURE)
    -- print("onStatus-4-----------------"..SocketTCP.EVENT_CLOSE)
    if msg.name == SocketTCP.EVENT_CONNECTED then
        print("onStatus------断线重连BUG测试  连接  连接  连接   EVENT_CONNECTED")
        tcpIsOK = true

        --self:send_request("handshake")
        if initSceneNameGloble == nil then
            initSceneNameGloble = "UpdateScene"
        end
        print("onStatus=========cxx==========="..initSceneNameGloble)
        --if self.chonglian == true and initSceneNameGloble == "FightScene" then
        if self.chonglian == true and (initSceneNameGloble == "LoginSceneFinal" or initSceneNameGloble == "FightScene" or initSceneNameGloble == "CreateScene") then
            print("chonglian------断线重连BUG测试  是重新连接   ")
            local function chonglianBack( event )
                print("chonglianBack")
                print("chonglianBack------断线重连BUG测试  重连返回 :    "..json.encode(event))
                if event.type == 0 then
                    --gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = event.message,z = 3000})
                    if initSceneNameGloble == "FightScene" then
                        mm.reconnectSuc()
                    end

                    self:hidenHint()
                    self.chonglian = false
                    print("onStatus------断线重连BUG测试  连接成功  连接成功  连接成功   ")
                else
                    --self:reconnect()
                    self.socket:close()
                    -- g_fightLoadingLayer:getChildByName("Text"):setString(event.message)
                    print("onStatus------断线重连BUG测试  连接失败  连接失败   连接失败   ")
                end
            end

            print("onStatus------11111111111")
            -- if game.LoginSDkData == nil then
            --     return
            -- end
            
            -- local qufu = "101"
            -- local currentServer = gameUtil.getDefaultServerInfo(game.severList)
            -- qufu = currentServer.Areaid

            -- local playerid = 0
            -- if mm.data.playerinfo ~= nil then
            --     qufu = mm.data.playerinfo.qufu
            --     playerid = mm.data.playerinfo.id
            -- end
            local param = {}
            param.uid = game.LoginSDkData.uid
            -- param.qufu = qufu
            -- param.session = game.LoginSDkData.token

            param.qudao= "aa"
            -- -------------蛋疼的解决方案----------------
            -- if PLATFORM == "dhtest" then
            --     param.qudao= "dhsdk"
            -- end
            
            -- param.playerid = playerid
            -- param.gameSession = mm.data.playerinfo.gameSession

            print("onStatus------222222222222 "..json.encode(param))


            self:send_request("reconnect", param ,chonglianBack)
        else
            mm.connectSuc()
            --self:hidenHint()
            self.chonglian = false
        end
    else
        print("onStatus-----------4")
        self:delayShowHint()
        print("onStatus-----------5")
        self:reconnect()
    	print("onStatus==========="..msg.name)
    end
end

function ClientTCP:hidenHint( ... )
    if g_fightLoadingLayer then
        g_fightLoadingLayer:stopAllActions()
        g_fightLoadingLayer:setVisible(false)
    end
end

function ClientTCP:repeatAction( )
    local action = cc.Sequence:create(
                    cc.CallFunc:create(function( ... )
                        g_fightLoadingLayer:getChildByName("Text"):setString("网络连接中...")
                    end),
                    cc.DelayTime:create( 1 ),
                    cc.CallFunc:create(function( ... )
                        g_fightLoadingLayer:getChildByName("Text"):setString("网络连接中......")
                    end),
                    cc.DelayTime:create( 1 )
                )
    local repeatAct = cc.RepeatForever:create(action)
    if g_fightLoadingLayer then
        g_fightLoadingLayer:stopAllActions()
        g_fightLoadingLayer:runAction(repeatAct)
    end
end

function ClientTCP:delayShowHint( ... )
    local action = cc.Sequence:create(
                    cc.DelayTime:create( 2 ),
                    cc.CallFunc:create(function( ... )
                        if g_fightLoadingLayer then
                            g_fightLoadingLayer:setVisible(true)
                        end
                        -- self:repeatAction()
                    end)
                )
    if g_fightLoadingLayer then
        g_fightLoadingLayer:stopAllActions()
        g_fightLoadingLayer:runAction(action)
    end
end

function ClientTCP:reconnect()
    if os.time() - lastConnectTime < 5 then
        return
    end
    print("onStatus------断线重连BUG测试 开始重连 socket   1")
    tcpIsOK = false
    mm.hertTime = 0
    self.recvdata = ""
    self.chonglian = true

    self.socket:removeAllEventListeners()
    self.socket:close()    
    self.socket = nil
    self.socket = SocketTCP.new(LOTA_TCP, LOTA_TCP_PORT, false)
    self.socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
    self.socket:addEventListener(SocketTCP.EVENT_DATA, handler(self,self.onData))
    self.socket:connect()

    lastConnectTime = os.time()

    print("onStatus------断线重连BUG测试 开始重连 socket   2")
end

function ClientTCP:getSessionmap( ... )
    return sessionmap
end

function ClientTCP:removeSessionmap( session )
     sessionmap[session] = nil
end

function ClientTCP:disconnect()
    self.socket:removeAllEventListeners()
    self.socket:close()
end
return ClientTCP
