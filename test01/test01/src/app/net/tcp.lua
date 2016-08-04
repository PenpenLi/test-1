local ls = require("lsocket")


local tcp = class("tcp",require("cocos.framework.components.event"))
tcp.CONNECTED = "CONNECTED"
tcp.ERROR     = "ERROR"
tcp.DATA      = "DATA"


local scheduler = cc.Director:getInstance():getScheduler()


function tcp:ctor()
    self:init_()

end

function tcp:connect(ip,port)
    local client, err = ls.connect(ip, port)
    if not client then
        print("error connect: "..err)
        
        self:dispatchEvent({name=tcp.ERROR,err=err})
        return
    end
    
    self.client = client
    
    

    
  
end

function tcp:checkConnect()
    ls.select(nil, {self.client},0)
    local ok, err = client:status()
    if not ok then
        print("error select: "..err)
        self:dispatchEvent({name=tcp.ERROR,err=err})
    end


end





return tcp





