local scheduler = cc.Director:getInstance():getScheduler()


local Timer = {}

function Timer:new( ... )
	local intervalUnit = 0.1
	local sysTime = 0
	local DT = 0

	local function onTimer( dt )
		local curTime = os.time()
		local dt =  curTime - sysTime
		sysTime = curTime
		DT = DT + dt
		
		if DT >= 1 then
			self:updateTimer(math.floor(DT))
			DT = DT - math.floor(DT)
		end


	end


	handle = scheduler:scheduleScriptFunc(onTimer, intervalUnit, false)
	sysTime = os.time()

end

mm.data.time = mm.data.time or {}
mm.data.time.pkTime = 86400
mm.data.time.serverTime = os.time()
function Timer:updateTimer( dt )
	local function dTime(count)
        return count > 0 and count - dt or 0
    end

    local function aTime(count)
        return count > 0 and count + dt or 0
    end

    --技能时间
	-- mm.data.time.skillTime = dTime(mm.data.time.skillTime)

end



return Timer