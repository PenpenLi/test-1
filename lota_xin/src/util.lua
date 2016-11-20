--[[
    @全局使用函数
    create:叶俊威
    time:
    *******
]]

util = {}



-- 对table按照关键字k进行升序/降序排序
-- 如 tableSort( { { ID = 1, value = 2}, { ID = 2, value = 2} }, 'ID', false)按降序排序
function util.tableSort(t, k, ascending)
    function comp(a, b)
        if (ascending == false) then
            return a[k] > b[k]
        else
            return a[k] < b[k]
        end
    end
    table.sort(t, comp)
end

--复制一个表
function util.copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = util.copyTab(v)
        end
    end
    return tab
end

--待实现 --todo
function util.getTabByNum(tab,num)
    local tab = {}
    local aa = math.random(1,5)
    tab = {aa}
    return tab
end

-- @brief   对items中项按rules排序
-- @param   items   欲排序项 { item1, item2, item3, ... }
-- @param   rules   排序规则 { rule1, rule2, rule3, ... } 规则优先级rule1 > rule2 > rule3 其中rule为{ func = nil, isAscending = nil }
-- @return  返回已排序新的table
function util.powerSort(items, rules)
    items = util.copyTab(items)
    if (#rules == 0) then
        return items
    end

    local sortedItems = {}

    -- 按规则排序
    local func = rules[1]['func']
    table.sort(items,
        function(lhs, rhs)
            if rules[1]['isAscending'] == true then
                return func(lhs) < func(rhs)
            else
                return func(lhs) > func(rhs)
            end
        end)

    -- 分成子排序项
    local newItems = {}
    local subItems = nil
    local equalKey = nil
    for k, v in pairs(items) do
        local function newSubItems()
            subItems = {}
            table.insert(newItems, subItems)
            equalKey = func(v)
        end

        if subItems == nil or func(v) ~= equalKey then
            newSubItems()
        end
        table.insert(subItems, v)
    end

    -- 对子排序项进行排序
    local subRules = util.copyTab(rules)
    table.remove(subRules, 1)
    for k, v in pairs(newItems) do
        local sortedSubItems = util.powerSort(v, subRules, func)
        for kk, vv in pairs(sortedSubItems) do
            table.insert(sortedItems, vv)
        end
    end

    return sortedItems
end

-- 文件是否存在
function util.isFileExist(src)  
    if src == nil then
        return false
    end

    if src == "" then
        return false
    end

    if cc.FileUtils:getInstance():isFileExist(src) == false then
        return false
    end

    return true
end

-- 获取字符拼码
function util.getNumFormChar(str, fromBac)
    local wordLen = string.len(str)
    --cclog("----getNumFormChar 0")
    if wordLen < fromBac then
        print("erro : wordLen < fromBac")
        return nil
    end

    local srtInNum = 0;
    for i = 1,fromBac do 
        srtInNum =  srtInNum + string.byte(str, -i) * math.pow(256, i-1)
    end 
    --cclog("----"..srtInNum)
    return srtInNum
end

-- 根据拼码获取字符
function util.getStrFormNum(num, fromBac)
    local numRest = num
    local numTable = {}
    local strOutput = ""
    for i = 1, fromBac do
        local mod = math.pow(256,i)
        local modNum = math.fmod(num,mod)
        numRest = numRest - modNum       
        strOutput = string.char(math.floor(modNum / math.pow(256,i-1)))..strOutput
    end
    return strOutput
end

function util.getCurrentTime ( ServerTimeStamp , ServerTimeZone ) 
    --ServerTimeStamp 服务端发给客户端维护的时间戳
    --ServerTimeZone 服务端时间的时区差值
    local function get_timezone()
      local now = os.time()
      return os.difftime(now, os.time(os.date("!*t", now)))
    end
    
    local localTimeZone = get_timezone()
    local timeZoneD = ServerTimeZone - localTimeZone  --计算出服务端时区与客户端时区差值
    local CurrentDateTime = os.date("*t",ServerTimeStamp + timeZoneD)
end


__DEBUG__TABLE__ = function(t, tableName)
    if (tableName ~= nil) then
        cclog("______________[ TAB ] - ".. tableName .. " - [ BEGIN ]____________")
    end

    for i, v in pairs(t) do
        if (type(v) ~= "table") then
            if (type(v) == 'boolean') then
                if (v == true) then
                    cclog(i .. ":     " .. 'true')
                else
                    cclog(i .. ":     " .. 'false')
                end
            elseif (type(v) == 'number') then
                cclog(i .. ":     " .. tostring(v))
            elseif (type(v) == 'function') then
                cclog(i .. ":     " .. tostring(v))
            elseif (type(v) == 'userdata') then
                cclog(i .. ":     " .. tostring(v))
            else
                cclog(i .. ":     " .. v)
            end
        else
            cclog('[' .. i .. ']:')
            __DEBUG__TABLE__(v, i)
        end
    end

    if (tableName ~= nil) then
        cclog("______________[ TAB ] - ".. tableName .. " - [ END ]____________")
    end
end

-- 将int值转换为**:**:**这样的时间表示格式
function util.timeFmt(time)
    local hour = math.floor(time / 3600)
    time = time - hour * 3600
    local min = math.floor(time / 60)
    time = time - min * 60
    local sec = time
    return string.format('%02.0f:%02.0f:%02.0f', hour, min, sec)
end


return util