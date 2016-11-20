--[[--
    file description: 
    extern the modal class(scene/floatlayout) function.
]]

local MProt = {}

--[[--

]]
function MProt.extend(object)

    --[[--
        add event handle to manager
    ]]
    function object:appendGlobalEventHandle(msgCode, handle)
        if self._globalEventHs == nil then
            self._globalEventHs = {}
        end
        table.insert(self._globalEventHs, {c = msgCode, h = handle})
    end

    --[[--
        del event handle from manager
    ]]
    function object:deleteGlobalEventHandle(msgCode)
        if self._globalEventHs ~= nil then
            for i = 1, #self._globalEventHs do
                if self._globalEventHs[i].c == msgCode then
                    game.removeGlobalEventListener(self._globalEventHs[i].c, self._globalEventHs[i].h)
                    table.remove(self._globalEventHs, i)
                    --break
                end
            end
        end
    end

    --[[--
        regist global event listener
    ]]
    function object:addGlobalEventListener(msgCode, listener, tag)
        local target_, handle = game.addGlobalEventListener(msgCode, listener, tag)
        if handle then
            self:appendGlobalEventHandle(msgCode, handle)
            return handle
        end
        return nil
    end 

    --[[--
        remove the Global event listener
    ]]
    function object:removeGlobalEventListener(msgCode)
        self:deleteGlobalEventHandle(msgCode)
    end

    --[[--
        clear server msg listeners
    ]]
    function object:clearAllGlobalEventListener()
        --cclog("remove event listener enter")
        if self._globalEventHs ~= nil then
            for i = 1, #self._globalEventHs do
                --cclog("remove event listener "..i)
                game.removeGlobalEventListener(self._globalEventHs[i].h)
            end
            self._globalEventHs = nil
        end
    end   

    return object
end

return MProt

