
-- 通过ScrollView实现listView效果 横向
-- 

local HorListView = class("HorListView",ccui.ScrollView)

--默认listView的大小
local size = cc.size(600,500)
local cellSize = cc.size(600,100)

-- start --
--------------------------------
-- 创建HorListView
-- end --
function HorListView:ctor(data)
    self:init(data)
end

-- start --
--------------------------------
-- 初始化HorListView
-- end --
function HorListView:init(data)
    self.size = data.size or size
    self.count = data.count or 0
    self.cell = data.cell
    self.target = data.target
    self.fun = data.fun
    self.cellSize = data.cellSize or self.cell:getContentSize()
    self.innerSize = cc.size(self.count * self.cellSize.width,self.size.height) or self.size
    self.cellCount = math.ceil(self.size.width/self.cellSize.width) + 1
    self.notBounceEnabled = data.notBounceEnabled
    if self.cellCount > self.count then
        self.cellCount = self.count   
    end
    self.width = self.innerSize.width
    if self.innerSize.width < self.size.width then
        self.width = self.size.width    
    end
    self:setInnerContainerSize(self.innerSize)
    self.cells = {}
    local diffX = (self.cellSize.width - self.cell:getContentSize().width)/2
    self.diffX = diffX
    local diffY = data.diffY or 0
    self.diffY = diffY
    local index = data.index or 1
    self.startIndex = index
    local container = self:getInnerContainer()
    local posTag = 0
    if index - 1 + self.cellCount > self.count then
        index = self.count - self.cellCount + 1
        posTag = 1
    end
    self.Index = index
    for i=index,index - 1 + self.cellCount do
        local layout = self.cell:clone()
        layout:setPosition(diffX + (i-1)*self.cellSize.width,diffY)
    	self:addChild(layout)
    	self.target[self.fun](self.target,layout,i,true)
        local tag = math.mod(i-1,self.cellCount) + 1
        self.cells[tag] = layout
    end
    gb.performWithDelay(self,function()
        if posTag == 0 then
            container:setPositionX(-(index-1)*self.cellSize.width)
        else
            container:setPositionX(self.size.width - self.innerSize.width)
            self:scrollViewDidScroll(self,ccui.ScrollviewEventType.scrolling) 
        end
    end,0)
	self:setBounceEnabled(true)
    if self.notBounceEnabled then
        self:setBounceEnabled(false)
    end
    self:setContentSize(self.size)
    self:setDirection(ccui.ScrollViewDir.horizontal)
    self:addEventListener(handler(self, self.scrollViewDidScroll))
end

-- start --
--------------------------------
-- reset重置
-- end --
function HorListView:reset(index)
    local index = index or self.startIndex
    local container = self:getInnerContainer()
    local posTag = 0
    if index - 1 + self.cellCount > self.count then
        index = self.count - self.cellCount + 1
        posTag = 1
    end
    self.Index = index
    for i=index,index - 1 + self.cellCount do
        local tag = math.mod(i-1,self.cellCount) + 1
        self.target[self.fun](self.target,self.cells[tag],i)
        self.cells[tag]:setPosition(self.diffX + (i-1)*self.cellSize.width,self.diffY)
    end
    if posTag == 0 then
        container:setPositionX(-(index-1)*self.cellSize.width)
    else
        container:setPositionX(self.size.width - self.innerSize.width)
        self:scrollViewDidScroll(self,ccui.ScrollviewEventType.scrolling) 
    end
end

-- start --
--------------------------------
-- 滚动监听
-- end --
function HorListView:scrollViewDidScroll(sender,eventType)
	if eventType == ccui.ScrollviewEventType.scrolling then
		if self.cellCount == self.count then
            return
        end
        local container = self:getInnerContainer()
        local conX = container:getPositionX()
        local BeginIndex = math.mod(self.Index-1,self.cellCount) + 1
        local EndIndex = math.mod(BeginIndex + self.cellCount - 1 - 1,self.cellCount) + 1
        local posBeginX = self.cells[BeginIndex]:getPositionX()
        local posEndX = self.cells[EndIndex]:getPositionX()
        if posBeginX + conX - self.diffX < - self.cellSize.width  then
            if self.Index + self.cellCount - 1 == self.count then
                return
            end
            self.cells[BeginIndex]:setPositionX(posEndX + self.cellSize.width)
            self.target[self.fun](self.target,self.cells[BeginIndex],self.Index + self.cellCount)
            self.Index = self.Index + 1
        end
        if posBeginX + conX - self.diffX > 0 then
            if self.Index == 1 then
                return
            end
            self.cells[EndIndex]:setPositionX(posBeginX - self.cellSize.width)
            self.target[self.fun](self.target,self.cells[EndIndex],self.Index - 1)
            self.Index = self.Index - 1
        end
	end
end

return HorListView
