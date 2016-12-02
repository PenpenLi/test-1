--
-- Author: zcy
-- Date: 2016-07-15
--
-- 对象池管理器
--

local ObjectPoolManager = class("ObjectPoolManager")

-- start --
--------------------------------
-- ObjectPoolManager
-- end --
function ObjectPoolManager:ctor()
    self.ObjectPools = {}
    self.Indexs = {}
end

-- start --
--------------------------------
-- 调用对象
-- end --
function ObjectPoolManager:getObject(data)
    local res = data.res
    local isFree = data.isFree or false

    if not self.ObjectPools[res] then
        self.ObjectPools[res] = {}
        self.Indexs[res] = 0
    end

    --在对象池中查找是否有空闲的对象
    local count = #self.ObjectPools[res]
    for i=1,count do
        local index = self.Indexs[res] + 1
        if index > count then
            index = 1
        end
        local t = self.ObjectPools[res][index]
        if t and t.isFree then
            t.isFree = isFree
            self.Indexs[res] = index
            return t.node
        end
    end
    
    --没有空闲对象就添加新的对象
    return self:addObject(data)
end

-- start --
--------------------------------
-- 设置新的对象
-- end --
function ObjectPoolManager:addObject(data)
    local res = data.res
    local layoutName = data.layoutName
    local node
    if data.isSpine and data.sAtlas then
        node = gb.skeletonAnimationCreate(data.sAtlas)
    else
        node = cc.CSLoader:createNode(res)
    end
    if node then
        if layoutName then
            local layout = node:getChildByName(layoutName)
            if layout then
                layout:removeFromParent()
                return self:insertObject(self.ObjectPools[res],layout,data)
            end   
        end
        return self:insertObject(self.ObjectPools[res],node,data)
    end
end

-- start --
--------------------------------
-- 插入新的对象
-- end --
function ObjectPoolManager:insertObject(pools,node,data)
    local t = {}
    node:retain()
    t.node = node
    t.isFree = data.isFree or false
    table.insert(pools,t)
    node:enableNodeEvents()
    local childLayoutName = data.childLayoutName
    node.onCleanup = function ()
        if childLayoutName and node:getChildByName(childLayoutName) then
            node:getChildByName(childLayoutName):removeAllChildren()
        end
        t.isFree = true
    end
    return node
end

-- start --
--------------------------------
-- 删除对应的对象
-- end --
function ObjectPoolManager:removeObject(res,node)
    if self.ObjectPools[res] then
        --在对象池中查找是否有空闲的对象
        for i,v in ipairs(self.ObjectPools[res]) do
            if v.node == node then
                v.isFree = true
            end 
        end
    end
end

return ObjectPoolManager