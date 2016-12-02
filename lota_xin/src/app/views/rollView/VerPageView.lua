
-- 竖版滚动
--

local VerPageView = class("VerPageView",ccui.Layout)

--滑动的距离  超过产生翻页事件
VerPageView.DiffY = 200

--滑动的最短距离  未超过当点击事件来处理
VerPageView.DiffMinY = 10

--滑动的最大速度
VerPageView.Speed = 500


-- start --
--------------------------------
-- 创建VerPageView
-- end --
function VerPageView:ctor(data)
	self.data = data
	self.child = data.child
	self.index = data.index or 1
	self.count = data.count or 10
	self.BeginPoint = cc.p(0,0)
	self.beginX = self.child:getPositionX()
    self.beginY = self.child:getPositionY()
    self.size = self.child:getContentSize()
    self.MoveHeight = self.size.height + 100
    self.touch = true
    self.target = data.target
	self:init()
end

-- start --
--------------------------------
-- 初始化VerPageView
-- end --
function VerPageView:init()
    self:setContentSize(self.size)
    self:setClippingEnabled(true)
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(handler(self, self.onTouchMoved),cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(handler(self, self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-- start --
--------------------------------
-- end --
function VerPageView:onTouchBegan(touch, event)
    if not cc.rectContainsPoint(self:getBoundingBox(), self:getParent():convertTouchToNodeSpace(touch)) then
    	return
    end
    if not self.touch then
        return
    end
    self.beginTime = os.clock()
    self.BeginPoint = cc.p(touch:getLocation().x,touch:getLocation().y)
	return true
end

-- start --
--------------------------------
-- end --
function VerPageView:onTouchMoved(touch, event)
	local diff = touch:getDelta()
	self.child:setPositionY(self.child:getPositionY() + diff.y)
end

-- start --
--------------------------------
-- end --
function VerPageView:onTouchEnded(touch, event)
	local diff = math.abs(self.BeginPoint.y - touch:getLocation().y)
    if diff > VerPageView.DiffMinY then
        self.target.EventTag = false
        --event:stopPropagation()
    else
        self.target.EventTag = true
        return
    end
    local location = touch:getLocation()
    local dy = location.y - self.BeginPoint.y
    self.endTime = os.clock()
    local speed = math.abs(dy) / (self.endTime - self.beginTime)
    if dy > VerPageView.DiffY or (dy > VerPageView.DiffMinY and speed > VerPageView.Speed)  then
    	if self.index == self.count then
    		local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
            self.child:runAction(moveTo)
            return
        end

        local function toBack( ... )
        	self.child:setPosition(self.beginX, self.beginY - self.MoveHeight)
            self.index = self.index + 1
            self.target["updatePageView"](self.target,self.index)
        end

        local function backBack( ... )
        	self.touch = true
        end

        local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY + self.MoveHeight))
        local moveBack = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
        self.touch = false
        self.child:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(toBack),moveBack,cc.CallFunc:create(backBack)))
    elseif dy < (-1) * VerPageView.DiffY or (math.abs(dy) > VerPageView.DiffMinY and dy < 0 and speed > VerPageView.Speed) then
    	if self.index == 1 then
            local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
            self.child:runAction(moveTo)
            return
        end

        local function toBack( ... )
        	self.child:setPosition(self.beginX, self.beginY + self.MoveHeight)
            self.index = self.index - 1
            self.target["updatePageView"](self.target,self.index)
        end

        local function backBack( ... )
        	self.touch = true
        end

        local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY - self.MoveHeight))
        local moveBack = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
        self.touch = false
        self.child:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(toBack),moveBack,cc.CallFunc:create(backBack)))
    else
    	local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
        self.child:runAction(moveTo)
    end
end

return VerPageView
