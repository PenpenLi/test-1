-- 抽奖辅助函数

-- TODO::将抽奖
local function log( ... )
	print(...)
end
local gameUtil = gameUtil

local table_insert = table.insert

local INITLUA = INITLUA
local itemResAll = INITLUA:getRes("Item")
local ExpDraw = INITLUA:getRes("ExpDraw")
local goldDrawRes = ExpDraw[1093677105]
local diamondDrawRes = ExpDraw[1093677106]
local enemyDrawRes = ExpDraw[1093677107]

local MM = MM
local EDRAW_OPEN_CONDITION = MM.EDRAW_OPEN_CONDITION
local DRAW_OPEN_CONDITION_LV = EDRAW_OPEN_CONDITION.DRAW_OPEN_CONDITION_LV
local DRAW_OPEN_CONDITION_VIPLV = EDRAW_OPEN_CONDITION.DRAW_OPEN_CONDITION_VIPLV
local DRAW_OPEN_CONDITION_COMPLETE = EDRAW_OPEN_CONDITION.DRAW_OPEN_CONDITION_COMPLETE

local maintTypes = { -- TODO::var应该是数字 类型应该填表
    gold = "gold",
    diamond = "diamond",
    enemy = "enemy"
}

local ExpDreaResInList = {}
if goldDrawRes then
    table_insert(ExpDreaResInList, {mainType = maintTypes["gold"], res = goldDrawRes, idsInTypes = {}, open = false, arm=""})
end
if diamondDrawRes then
    table_insert(ExpDreaResInList, {mainType = maintTypes["diamond"], res = diamondDrawRes, idsInTypes = {}, open = false, arm=""})
end
if enemyDrawRes then
    table_insert(ExpDreaResInList, {mainType = maintTypes["enemy"], res = enemyDrawRes, idsInTypes = {}, open = false, arm=""})
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
local chouJiangHelper = {} 
local CJH = chouJiangHelper

--
local mm_data = mm.data
local function hasCompleteTask(id)
local mm_data_playerTask = mm_data.playerTask
    if not mm_data_playerTask then
        return false
    end

    for i,v in ipairs(mm_data_playerTask) do
        if v.taskId == id then
            return true
        end
    end

    return false
end

--
local function isAbleToShow(curRes, t)
    if curRes.Offo < 1 then -- 强制开关
        return false
    end

    if DRAW_OPEN_CONDITION_LV == curRes.DRAW_OPEN_CONDITION then
        if curRes.lv <= t.level then
            return true
        end
    elseif DRAW_OPEN_CONDITION_VIPLV == curRes.DRAW_OPEN_CONDITION then
        if curRes.lv <= t.vipLevel then
            return true
        end
    elseif DRAW_OPEN_CONDITION_COMPLETE == curRes.DRAW_OPEN_CONDITION then
        if hasCompleteTask(curRes.missionId) then
            return true
        end
    end

    return false
end

--
function CJH:checkOpen(name)
    local level = gameUtil.getPlayerLv(mm_data.playerinfo.exp)
    local vipLevel = gameUtil.getPlayerVipLv(mm_data.playerinfo.vipexp)
    local t = {level=level, vipLevel=vipLevel}
    for i,v in ipairs(ExpDreaResInList) do
        if name == v.mainType then
            if isAbleToShow(v.res, t) then
                return true
            end
        end
    end

    return false
end

return CJH