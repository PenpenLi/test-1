
-- 通过ScrollView实现listView效果
-- 

local VerListView = class("VerListView",ccui.ScrollView)

--默认listView的大小
local size = cc.size(600,500)
local cellSize = cc.size(600,100)

-- start --
--------------------------------
-- 创建VerListView
-- end --
function VerListView:ctor(data)
    self:enableNodeEvents()
    self:init(data)
end

-- start --
--------------------------------
-- 初始化VerListView
-- end --
function VerListView:init(data)
    self.size = data.size or size
    self.count = data.count or 0
    local layoutData = data.layoutData or {}
    self.res = layoutData.res
    if data.cell then
        self.cell = data.cell
    else
        layoutData.isFree = true
        self.cell = cs.ObjectPoolManager:getObject(layoutData)
    end
    self.target = data.target
    self.fun = data.fun
    self.cellSize = self.cell:getContentSize() or cellSize
    self.innerSize = cc.size(self.size.width,(self.count * self.cellSize.height)) or self.size
    self.cellCount = math.ceil(self.size.height/self.cellSize.height) + 1
    if self.cellCount > self.count then
        self.cellCount = self.count   
    end
    self.height = self.innerSize.height
    if self.innerSize.height < self.size.height then
        self.height = self.size.height    
    end
    self:setInnerContainerSize(self.innerSize)

    self.Index = 1

    self.cells = {}
    layoutData.isFree = false
    for i=1,self.cellCount do
        local layout = nil
        if data.cell then
            layout = self.cell:clone()
        else
            layout = cs.ObjectPoolManager:getObject(layoutData)
        end
        layout:setPositionY(self.height - i*self.cellSize.height)
    	self:addChild(layout)
    	self.target[self.fun](self.target,layout,i,true)
        self.cells[i] = layout
    end

	self:setBounceEnabled(true)
    -- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- self:setBackGroundColor(cc.c3b(150,150,255))
    self:setContentSize(self.size)
    self:setDirection(ccui.ScrollViewDir.vertical)
    self:addEventListener(handler(self, self.scrollViewDidScroll))
end

-- start --
--------------------------------
-- reset重置
-- end --
function VerListView:reset()
    self.Index = 1
    local container = self:getInnerContainer()
    container:setPositionY(self.size.height - self.innerSize.height)
    for i,v in ipairs(self.cells) do
        v:setPositionY(self.height - i*self.cellSize.height)
        self.target[self.fun](self.target,v,i)
    end
end

-- start --
--------------------------------
-- 滚动监听
-- end --
function VerListView:scrollViewDidScroll(sender,eventType)
	if eventType == ccui.ScrollviewEventType.scrolling then
        local container = self:getInnerContainer()

		if self.cellCount == self.count then
            return
        end
        local conY = container:getPositionY()
        local BeginIndex = math.mod(self.Index-1,self.cellCount) + 1
        local EndIndex = math.mod(BeginIndex + self.cellCount - 1 - 1,self.cellCount) + 1
        local posBeginY = self.cells[BeginIndex]:getPositionY()
        local posEndY = self.cells[EndIndex]:getPositionY()
        self.conY = self.conY or conY
        if math.abs(self.conY - conY) < self.cellSize.height then
            if posBeginY + conY >= self.size.height then
                if self.Index + self.cellCount - 1 == self.count then
                    return
                end
                self.cells[BeginIndex]:setPositionY(posEndY-self.cellSize.height)
                self.target[self.fun](self.target,self.cells[BeginIndex],self.Index + self.cellCount)
                self.Index = self.Index + 1
            end
            if posBeginY + conY < self.size.height - self.cellSize.height then
                if self.Index == 1 then
                    return
                end
                self.cells[EndIndex]:setPositionY(posBeginY + self.cellSize.height)
                self.target[self.fun](self.target,self.cells[EndIndex],self.Index - 1)
                self.Index = self.Index - 1
            end
        end
        self.conY = conY
	end
end

return VerListView