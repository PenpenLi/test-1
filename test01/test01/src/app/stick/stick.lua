
STICK_POS_FIXED = false


local scheduler = cc.Director:getInstance():getScheduler()

stick_event = {
    notify_to_stick_event_began = "stick.event_began",
    notify_to_stick_event_moved = "stick.event_moved",
    notify_to_stick_event_ended = "stick.event_ended"
}

local stick = class("stick", function()
    return display.newLayer()
end )

function stick:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:on_touch(event.name, event.x, event.y)
    end )

    self:setTouchSwallowEnabled(false)
    self:setTouchEnabled(true)

    self.touch_enable_ = true
    self.stick_pos_ = { x=100, y=100 }
end

function stick:start_scheduler()
    self:stop_scheduler()

    local update_func = function(dt)
        if self.angle_ then
            self:dispatchEvent({name = stick_event.notify_to_stick_event_moved, angle = self.angle_})
        end
    end

    self.scheduler_id_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_func, self.rate_, false)
end

function stick:stop_scheduler()
    if self.scheduler_id_ ~= nil then
        scheduler.unscheduleGlobal(self.scheduler_id_)
        self.scheduler_id_ = nil
    end
end

function stick:init_data(bg, center, rate)
    self.rate_ = rate

	self.bg_ = cc.Sprite:create(bg)
    assert(self.bg_)
    self.bg_size_ = self.bg_:getContentSize()
    self.bg_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
	self:addChild(self.bg_)

	self.center_ = cc.Sprite:create(center)
    assert(self.center_)
    self.center_size_ = self.center_:getContentSize()
	self.center_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
	self:addChild(self.center_)

    if not STICK_POS_FIXED then
        self:switch_stick_status(false)
    end
end

function stick:switch_stick_status(is_show)
    self.bg_:setVisible(is_show)
    self.center_:setVisible(is_show)
end

function stick:on_touch(event, x, y)
    if not self.touch_enable_ then
        print("not self.touch_enable_ ....")
        return true
    end

    if event == 'began' then
        self.touch_start_ = { x = x, y = y }
        if STICK_POS_FIXED then
            local box = self.center_:getBoundingBox()
            if cc.rectContainsPoint(box, cc.p(x, y)) then
                self:start_scheduler()
                self:dispatchEvent({name = stick_event.notify_to_stick_event_began})
		        return true
    	    end

	        return false
        else
            self.stick_pos_.x = x
            self.stick_pos_.y = y
            self.bg_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
            self.center_:setPosition(self.stick_pos_.x, self.stick_pos_.y)
            self:switch_stick_status(true)
            self:start_scheduler()
            self:dispatchEvent({name = stick_event.notify_to_stick_event_began})
        end
    elseif event == 'moved' then
	    self.angle_ = math.atan2(y - self.stick_pos_.y, x - self.stick_pos_.x) * 180 / math.pi

	    local bg_radis = self.bg_size_.width / 2;
	    local distance_of_touchpoint_to_center = math.sqrt(
			    (self.stick_pos_.x - x)*(self.stick_pos_.x - x) + (self.stick_pos_.y - y)*(self.stick_pos_.y - y))
	    
        --cclog("bg_radis = %f\ndistance_of_touchpoint_to_center=%f\n", bg_radis, distance_of_touchpoint_to_center)

        if distance_of_touchpoint_to_center >= bg_radis then
		    local dx = (x - self.stick_pos_.x) * (bg_radis / distance_of_touchpoint_to_center)
		    local dy = (y - self.stick_pos_.y) * (bg_radis / distance_of_touchpoint_to_center)
		    self.center_:setPosition(self.stick_pos_.x + dx, self.stick_pos_.y + dy)
	    else
		    self.center_:setPosition(x, y)
	    end
    elseif event == 'ended' then
        self.center_:setPosition(self.stick_pos_.x, self.stick_pos_.y)

        if not STICK_POS_FIXED then
            self:switch_stick_status(false)
        end

        self.angle_ = nil
        self:stop_scheduler()
        self:dispatchEvent({name = stick_event.notify_to_stick_event_ended})
    end

    return true
end

return stick
