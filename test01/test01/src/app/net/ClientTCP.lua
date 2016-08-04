local ClientTCP = class("ClientTCP",require("framework.cc.components.behavior.EventProtocol"))
local SocketTCP = require("framework.cc.net.SocketTCP")

local scheduler = cc.Director:getInstance():getScheduler()


local proto = require ("app.net.proto")
local sproto = require ("app.net.sproto")

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))


local tcpIsOK = true
local lastConnectTime = 0

function ClientTCP:ctor()
 
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
    local LOTA_TCP = "192.168.17.251"
    local LOTA_TCP_PORT = 8888
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

        printInfo("REQUEST(%s)", name)
        
        self:dispatchEvent({name = name,data=args})
    end

    local function process_response(session, args)
        if sessionmap[session] ~= nil then
            local callback = sessionmap[session]
            callback(args)
            -- if xpcall(callback,args) then
            -- else
            --     print("callback error")
            -- end
            
            sessionmap[session] = nil

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
    print("onStatus----msg--"..msg.name.."------")
    if msg.name == SocketTCP.EVENT_CONNECTED then
        local function back( t )
            dump(t)
            print("login-----------back")
            for k,v in pairs(t.playerInfo.base) do
                print(k,v)
            end

            game.playerInfo = t.playerInfo
            game.uid = game.playerInfo.base.uid
        end
        game.clientTCP:send("login",{did = game.did}, back)
    else
        print("onStatus-----------4")
    end
end


return ClientTCP
