require "app.views.mmExtend.getMsgMgr"
EventDef = EventDef or require("app.models.EventDef")

mm = mm or {} 
game = game or {}

function mm.newLayer(res)
    local layer = CCNodeExtend.extend(cc.CSLoader:createNode(res))
    return layer
end

--[[
	主界面地下一直存在按钮点击的管理，避免重复创建
]]
function mm.pushLayoer( parame )
	local scene = parame.scene
	--local layer = parame.layer
    local resName = parame.resName
    local params = parame.params
    local res = parame.res


	local zord = parame.zord
	local clear = parame.clear
	if nil == scene then
		return nil
	end

	mm.Layout = mm.Layout or {}

    local layer
    if #mm.Layout > 0 then
    	local upLayoutName = mm.Layout[#mm.Layout].__cname
        local MLayoutName = resName
        if upLayoutName == MLayoutName and 1 ~= clear then
        	return nil
        else
            layer = require(res).new(params)
        	if 1 == clear then
        		for i=1,#mm.Layout do
        			mm.Layout[i]:removeFromParent()
                    mm.Layout[i] = nil
        		end
        		mm.Layout = {}
        		mm.Layout[1] = layer
            else
                table.insert(mm.Layout, layer)
        	end

        end
        
        
    else 
    	layer = require(res).new(params)
        mm.Layout[1] = layer
    end

    if not layer then
        return nil
    end

    local size  = cc.Director:getInstance():getWinSize()
    --ccui.Helper:doLayout(layer)

    if zord then
    	scene:addChild(layer, zord)
    else
    	scene:addChild(layer)
    end



    return true
end

function mm:popLayer()
    mm.Layout = mm.Layout or {}
    if #mm.Layout > 0 then
        mm.Layout[#mm.Layout]:removeFromParent()
        table.remove(mm.Layout)

        if #mm.Layout == 0 then
            -- mm.GuildScene:backFightScene()
            -- mm.GuildScene:backFightSceneBackup()
        end
    else
        
    end
end


function mm:clearLayer()
    mm.Layout = mm.Layout or {}
    for i=1,#mm.Layout do
        mm.Layout[i]:removeFromParent()
        mm.Layout[i] = nil
    end
    mm.Layout = {}
end


--数据
mm.data = {}
mm.piaoZiTab = {}

mm.hertTime = 0

function mm.HeartBeatBack( event )
    mm.hertTime = 0
    print("HeartBeatBack===================!!")
    if mm.data.playerinfo and mm.data.playerinfo.gameSession then
        mm.req("clientHeartBeat", {type = 1})
    end
end

local scheduler = cc.Director:getInstance():getScheduler()

function mm.startCheckHeartBeat(  )
    mm.unscheduleScript()

    mm.rescheduler = scheduler:scheduleScriptFunc(function()
            local time = os.time()
            mm.hertTime = mm.hertTime + 1     
        
            if mm.hertTime > 9 then
                --gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "网络异常",z = 3000})
                -- mm.app.clientTCP:reconnect()
                local msg = {}
                msg.name = "SOCKET_TCP_CONNECT_FAILURE"
                mm.hertTime = 0
                mm.app.clientTCP:onStatus(msg)
                -- mm.app.clientTCP.socket:close()
            end      
        end
    , 1,false)
    
end

function mm.unscheduleScript( ... )
    if mm.rescheduler then 
        scheduler:unscheduleScriptEntry(mm.rescheduler) 
    end
end


function mm.reconnect( ... )
    mm.app.clientTCP:reconnect()
    -- mm.hertTime = 0

    -- if g_fightLoadingLayer then
    --     g_fightLoadingLayer:getChildByName("Image"):setVisible(true)
    --     g_fightLoadingLayer:setVisible(true)
    -- end

end

function mm.reconnectSuc( ... )
    mm.HeartBeatBack()
    mm.req("guaJiReward", {type = 1})
end

function mm.connectSuc( ... )
    mm.HeartBeatBack()
    game.dispatchGlobalEvent({ name = EventDef.SERVER_MSG, code = "EVENT_CONNECTED",t = nil})
end

function mm.req(msgName,t)
    -- t.gameSession = mm.data.playerinfo.gameSession
    mm[msgName] = t
    mm.app.clientTCP:send(msgName,t,g_msgCode[msgName])

end

function mm.dispatchEvent(msgName,t)
    game.dispatchGlobalEvent({ name = EventDef.SERVER_MSG, code = msgName,t = t})
end

function mm.fiveRefreshNotify( event )
    mm.data.playerExtra.RaidsTimes = event.data.RaidsTimes or mm.data.playerExtra.RaidsTimes
    mm.data.playerExtra.hasRaidsTimes = event.data.hasRaidsTimes or mm.data.playerExtra.hasRaidsTimes
    mm.data.time.skillTime = event.data.SkillTime or mm.data.time.skillTime
    mm.data.playerExtra.skillNum = event.data.SkillNum or mm.data.playerExtra.skillNum
    mm.data.time.pkTime = event.data.pkTime or mm.data.time.pkTime
    mm.data.playerExtra.pkTimes = event.data.pkTimes or mm.data.playerExtra.pkTimes
    mm.data.playerTaskProc = event.data.taskProc or mm.data.playerTaskProc
    mm.data.playerinfo.luckyValue = event.data.luckyValue or mm.data.playerinfo.luckyValue
    mm.data.curDuanWei = event.data.curDuanWei or mm.data.curDuanWei
    mm.data.playerStage = event.data.playerStage or mm.data.playerStage
    mm.data.playerExtra.pkValue = event.data.pkValue or mm.data.playerExtra.pkValue

    mm.data.playerEquip = event.data.playerEquip or mm.data.playerEquip
    mm.data.playerItem = event.data.playerItem or mm.data.playerItem
    mm.data.playerHunshi = event.data.playerHunshi or mm.data.playerHunshi
    mm.data.playerinfo.exp = event.data.exp or mm.data.playerinfo.exp
    mm.data.playerinfo.exppool = event.data.exppool or mm.data.playerinfo.exppool
    mm.data.playerinfo.honor = event.data.honor or mm.data.playerinfo.honor
    
    game.dispatchGlobalEvent({ name = EventDef.SERVER_MSG, code = "fiveRefreshNotify",t = event.data})

end

function mm.closeArea( event )
    if event.data.type == 0 then
        game.dispatchGlobalEvent({name = EventDef.SERVER_MSG, code = "closeArea"})
    elseif event.data.type == 1 then
        game.dispatchGlobalEvent({name = EventDef.SERVER_MSG, code = "forceLogout"})
    end
end

function mm.closeFunction( event )
    mm.data.closeFuncTab = event.data.closeFuncTab or {}
end

function mm.mailNotify( event )
    game.dispatchGlobalEvent({ name = EventDef.SERVER_MSG, code = "mailnotify",t = event.data})
end

function mm.autoRefreshStoreInfo( event )
    game.dispatchGlobalEvent({ name = EventDef.SERVER_MSG, code = "autoRefreshStoreInfo",t = event.data})
end

function mm.recharge( event )
    game.dispatchGlobalEvent({ name = EventDef.SERVER_MSG, code = "recharge",t = event.data})
end

function mm.forbidLogin( event )
    game.dispatchGlobalEvent({name = EventDef.SERVER_MSG, code = "forbidLogin", t = event.data})
end

function mm.notifyStatus( event )
    game.dispatchGlobalEvent({name = EventDef.SERVER_MSG, code = "notifyStatus", t = event.data})
end

function mm.notifyMeleeEndResult( event )
    game.dispatchGlobalEvent({name = EventDef.SERVER_MSG, code = "notifyMeleeEndResult", t = event.data})
end

function mm.initTalk( talkInfo )
    mm.talkMsg = mm.talkMsg or {}
    if talkInfo then
        for i,v in ipairs(talkInfo) do
            local t = v.type
            if not mm.talkMsg[t] then
                mm.talkMsg[t] = {}
                table.insert(mm.talkMsg[t],v)
            else
                table.insert(mm.talkMsg[t],v)
            end
        end
    end
end

function mm.talk( event )
    mm.talkMsg = mm.talkMsg or {}
    local t = event.data.type
    if not mm.talkMsg[t] then
        mm.talkMsg[t] = {}
        table.insert(mm.talkMsg[t],event.data)
    else
        table.insert(mm.talkMsg[t],event.data)
    end 
    game.dispatchGlobalEvent({ name = EventDef.SERVER_MSG, code = "talk",t = event})
end

function mm.scene( ... )
    return cc.Director:getInstance():getRunningScene()
end

