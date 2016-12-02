
-- 横向滚动
--

local HorPageView = class("HorPageView",ccui.Layout)

--滑动的距离  超过产生翻页事件
HorPageView.DiffX = 200

--滑动的最短距离  未超过当点击事件来处理
HorPageView.DiffMinX = 10

--滑动的最大速度
HorPageView.Speed = 500


-- start --
--------------------------------
-- 创建HorPageView
-- end --
function HorPageView:ctor(data)
	self.data = data
	self.child = data.child
	self.index = data.index or 1
	self.count = data.count or 10
    self.updatePageView = data.updatePageView
	self.BeginPoint = cc.p(0,0)
	self.beginX = self.child:getPositionX()
    self.beginY = self.child:getPositionY()
    self.size = self.child:getContentSize()
    self.MoveWidth = self.size.width + 100
    self.touch = true
    self.target = data.target
    self.loop = data.loop or false   --是否循环滚动
	self:init()
end

-- start --
--------------------------------
-- 初始化HorPageView
-- end --
function HorPageView:init()
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
function HorPageView:onTouchBegan(touch, event)
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
function HorPageView:onTouchMoved(touch, event)
    if self.isMoving then
        return
    end
	local diff = touch:getDelta()
	self.child:setPositionX(self.child:getPositionX() + diff.x)
end

-- start --
--------------------------------
-- end --
function HorPageView:onTouchEnded(touch, event)
	local diff = math.abs(self.BeginPoint.x - touch:getLocation().x)
    if diff > HorPageView.DiffMinX then
        --event:stopPropagation()
        self.target.EventTag = false
    else
        self.target.EventTag = true
        return
    end
    if self.isMoving then
        return
    end
    local location = touch:getLocation()
    local dx = self.BeginPoint.x-location.x
    self.beginTime = self.beginTime or os.clock()-2
    self.endTime = os.clock()
    local speed = math.abs(dx) / (self.endTime - self.beginTime)
    if dx > HorPageView.DiffX or (dx > HorPageView.DiffMinX and speed > HorPageView.Speed)  then
    	if self.index == self.count then
            if self.loop then
      		    self.index = 0
            else
               local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
                self.child:runAction(moveTo)
                return
            end
        end

        local function toBack( ... )
        	self.child:setPosition(self.beginX+ self.MoveWidth, self.beginY )
            self.index = self.index + 1
            if self.updatePageView then
                self.updatePageView(self.target, self.index)
            else
                if self.target["updatePageView"] then
                    self.target["updatePageView"](self.target,self.index)
                end
            end
        end

        local function backBack( ... )
        	self.touch = true
        end

        local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX- self.MoveWidth, self.beginY ))
        local moveBack = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
        self.touch = false
        self.child:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(toBack),moveBack,cc.CallFunc:create(backBack)))
    elseif dx < (-1) * HorPageView.DiffX or (math.abs(dx) > HorPageView.DiffMinX and dx < 0 and speed > HorPageView.Speed) then
    	if self.index == 1 then
            if self.loop then
                self.index = self.count + 1
            else
                local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
                self.child:runAction(moveTo)
                return
            end
        end

        local function toBack( ... )
        	self.child:setPosition(self.beginX- self.MoveWidth, self.beginY )
            self.index = self.index - 1
            if self.updatePageView then
                self.updatePageView(self.target, self.index)
            else
                if self.target["updatePageView"] then
                    self.target["updatePageView"](self.target,self.index)
                end
            end
        end

        local function backBack( ... )
        	self.touch = true
        end

        local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX + self.MoveWidth, self.beginY ))
        local moveBack = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
        self.touch = false
        self.child:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(toBack),moveBack,cc.CallFunc:create(backBack)))
    else
    	local moveTo = cc.MoveTo:create(0.2, cc.p(self.beginX, self.beginY))
        self.child:runAction(moveTo)
    end
end

return HorPageView
