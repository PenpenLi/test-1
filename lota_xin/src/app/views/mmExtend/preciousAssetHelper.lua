-- 至宝(PA)觉醒的一些辅助函数
-- PA的升级和英雄升级相像
local gameUtil = gameUtil
local gameUtil_getPreciousId = gameUtil.getPreciousId

-- 等级 提示
local preciousOpenPlayerLevel = 35
local unopenStr1 = gameUtil.GetMoGameRetStr(990312)
local unopenStrFull1 = string.format(unopenStr1, preciousOpenPlayerLevel)

local function log( ... )
	print(...)
end

local function getPreciousId(heroId, index)
    local id =  gameUtil_getPreciousId(heroId, index)
    --log("---------id == "..id)
    return id
end

local math = math
local floor = math.floor

local INITLUA = INITLUA
local itemResAll = INITLUA:getRes("Item")

local PreciousResAll = INITLUA:getRes("Precious")
local PreciousUpMaterialsAll = INITLUA:getRes("PreciousUpMaterials")
local preciousUpRes = INITLUA:getRes("PreciousUp")
local countlevelTotal = #preciousUpRes

local levelMax = 25 --25级一个进阶，从1开始
local orderMax = 10 -- 从0开始
local levelTotal = levelMax*orderMax

local preciousAssetHelper = {} local PA = preciousAssetHelper

PA.isResValid = true
if countlevelTotal ~= levelTotal then
	log("ERROR : 总共不是250级")
	PA.isResValid = false
end

-- 检查前置条件是否都合法。
function PA:isValid()
	return self.isResValid
end

function PA:updateLvInfo(exp, levelTotalIn)-- levelTotal仅供参考
	if not levelTotalIn or levelTotalIn < 1 then
		levelTotalIn = 1
	end

	if not exp or exp < 0 then
		exp = 0
	end

	local levelTotalInReal = levelTotalIn

	local curlevelTotal = 1

	-- 从参考等级开始检查：
	if levelTotalIn > 3 then--增加容错
		levelTotalIn = levelTotalIn - 3
	end
	local preciousUpRes = preciousUpRes
	for i = levelTotalIn,levelTotal do
		local v = preciousUpRes[i]
		curlevelTotal = i
		if exp < v.Pexp then			
			break
		end
	end

	-- 再检查上一级
	local lvPre = curlevelTotal - 1
	if lvPre > 0 then
		local v = preciousUpRes[lvPre]
		if exp < v.Pexp then -- 参考等级有问题。-- 从头开始遍历		
			curlevelTotal = 1
			for i,v in ipairs(preciousUpRes) do
				curlevelTotal = i
				if exp < v.Pexp then		
					break				
				end
			end
		end
	end

	-- 是否与参考值有变化：
	local changedFlag = false
	if curlevelTotal ~= levelTotalInReal then
		changedFlag = true
	end

	local order = floor(curlevelTotal / levelMax)
	local level = curlevelTotal - order * levelMax
	return {changedFlag=changedFlag, levelTotal=curlevelTotal, order=order,level=level}
end

local string = string
local string_format = string.format
local f1 = "%s/%s"
local math_floor = math.floor
function PA:getPreciousInfo(preciousInfoIn,heroId)
	local output = {expPool=0, nextExp = 0, needOrder=false,str = "",per=0,needExp=0}

    local id = getPreciousId(heroId, preciousInfoIn.id)
    local curPreciousRes = PreciousResAll[id]
    if not curPreciousRes then
        return output
    end

    local lv = preciousInfoIn.lv
    local order = preciousInfoIn.order
    if not order then
    	order = 0
    end

    if not lv or not order then
        return output
    end
    if lv < 1 then
    	lv = 1
    end
    local restExp = preciousInfoIn.restExp
    if not restExp then
        restExp = 0
    end

    local lvAll = order * levelMax + lv

    if lvAll > levelTotal then
    	return output
    end

    local curPreicousUpRes = preciousUpRes[lvAll]
    local needExp = curPreicousUpRes.Pexp
    if lv >= levelMax then
    	--if restExp >= needExp then
    		output.needOrder = true
    	--end
    end

    output.nextExp = needExp
    output.expPool = restExp
    output.needExp = needExp - restExp
    if output.needExp < 0 then
    	output.needExp = 0
    end

    local per = 0
    if needExp == 0 then
    	per = 1
    else
    	per = restExp/needExp
    end
	if per > 1 then
		per = 1
	end
	if per < 0 then
		per = 0
	end
	per = math_floor(per * 100)

    output.str = string_format(f1, restExp, curPreicousUpRes.Pexp)
    --output.str = output.str.."lv:"..lv.." or:"..order
    output.per = per
    return output
end

-- 升一级的信息
function PA:liftUpPreciousInfo(preciousInfoIn)
	local fakeInfo = {}

    local lv = preciousInfoIn.lv + 1
    local order = preciousInfoIn.order
    local needOrder = false
    if lv > levelMax then
    	lv = 1
    	needOrder = true
    end

    local isFullLevel = false
    if needOrder then
    	order = order + 1
    end
	if order >= orderMax then
		isFullLevel = true
	end

    fakeInfo.id = preciousInfoIn.id
    fakeInfo.lv = lv
    fakeInfo.order = order
    fakeInfo.isFullLevel = isFullLevel
    return fakeInfo
end

-- 是否可以进阶
function PA:canLiftOrder(preciousInfoIn)
	--local order = preciousInfoIn.order
    if preciousInfoIn.lv >= levelMax then
    	return true
    end
    return false
end

function PA:getCanLiftOrder()
	--local order = preciousInfoIn.order
    return levelMax
end

--
local templateCountMax = 4
local f1 = "m"
local f2 = "c"
function PA:getOrderMatrials(orderId, templateId)
    local curPreciousMatrialRes = PreciousUpMaterialsAll[orderId]
    if not curPreciousMatrialRes then
        return
    end
	--
	if templateId > templateCountMax then
		log("ERROR: getOrderMatrials templateId > templateCountMax")
		--return
	end
	local matrials = curPreciousMatrialRes[f1..templateId]
	local counts = curPreciousMatrialRes[f2..templateId]

	if not matrials or not counts then
		log("ERROR: getOrderMatrials not matrials or not counts")
		return
	end

	return matrials, counts
end

local preciousMatrialInMap2 = nil
local MM = MM
local EItemType = MM.EItemType
local item_zhibaojinjie = EItemType.item_zhibaojinjie
local table_insert = table.insert
function PA:setupNewItems(iteminfoList)
    --iteminfoList = mm.data.playerItem
    preciousMatrialInMap2 = {}
    if not iteminfoList then
    	return
    end

    for i,v in ipairs(iteminfoList) do
        local id = v.id
        local curItemRes = itemResAll[id]
        if curItemRes and v.num then
            if curItemRes.ItemType == item_zhibaojinjie then
                preciousMatrialInMap2[id] = v
            end
        end
    end

    self.newItemsSeted = true
end

function PA:newItemsSeted()
	self.newItemsSeted = false
end

function PA:isNewItemsSeted()
	return self.newItemsSeted
end

function PA:isOrderItemEnough(preciousInfoIn, heroId)
    local preciousMatrialInMap2 = preciousMatrialInMap2
    if not preciousMatrialInMap2 then
    	return false
    end

    local pId = getPreciousId(heroId, preciousInfoIn.id)
    local order = preciousInfoIn.order
    local curPreciousRes = PreciousResAll[pId]
    if not curPreciousRes then
        return false
    end
    local orderUpTemplateId = curPreciousRes.orderUpTemplateId
    local m,c = PA:getOrderMatrials(order+1, orderUpTemplateId)
    if not m or not c then
        return false
    end
    for i,v in ipairs(m) do
        local id = v
        local max = c[i]
        if max then
            local numOwned = 0
            local info = preciousMatrialInMap2[id]
            if info then
                numOwned = info.num
                if numOwned < max then -- 不够
                    return false
                end
            else
                return false -- 完全没有
            end
        end
    end

    return true
end

-- 是否可进阶
function PA:canLiftOrderByTheWay(preciousInfoIn, heroId)
	-- 等级检查
	if preciousInfoIn.lv < levelMax then
		return false
	end
	-- 物品检查
	if not self:isOrderItemEnough(preciousInfoIn, heroId) then
		return false
	end
	return true
end

function PA:test()
	-- for i = 1, 1 do
	-- 	local randExp = 124500+100--math.random(0, 124500+100)
	-- 	local info = self:updateLvInfo(randExp,250)
	-- 	--log("-----exp == "..randExp.."____ levelTotal == "..info.levelTotal)
	-- end
end

function PA:isPreciousOpen(parent, isWithTiShi)
    local level = 1
    local mm_data_playerinfo = mm.data.playerinfo
    if mm_data_playerinfo then
        local exp = mm_data_playerinfo.exp
        level = gameUtil.getPlayerLv(exp)
    end

    if preciousOpenPlayerLevel > level then
        if isWithTiShi then
            gameUtil:addTishi({p = parent, s = unopenStrFull1})
        end

        return false
    end

    return true
end

function PA:getOpenLevel()
    return preciousOpenPlayerLevel
end

function PA:hasOpenedNoUsedSkin(_collectList)
    for k,v in ipairs(_collectList) do
        if v.flag > 1 and k > 1 then
            return true
        end
    end

    return false
end

return PA