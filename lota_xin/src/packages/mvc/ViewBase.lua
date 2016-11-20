
local ViewBase = class("ViewBase", cc.Node)
require("app.views.mmExtend.MProt").extend(ViewBase)

local director = cc.Director:getInstance()

function ViewBase:ctor(app, name, t)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    if self.onCreate then self:onCreate(t) end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    
    self.resourceNode_:setContentSize(CC_DESIGN_RESOLUTION)
    ccui.Helper:doLayout(self.resourceNode_)
    
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function ViewBase:pushScene(scene, transition, time, more)
    if director:getRunningScene() then
        if transition then
            scene = display.wrapScene(scene, transition, time, more)
        end
        director:pushScene(scene)
    else
        director:runWithScene(scene)
    end
end

function ViewBase:popScene()
    if director:getRunningScene() then
        director:getRunningScene():popScene()
    end
end

function ViewBase:pushWithScene(transition, time, more)
    self:setVisible(true)
    print("pushWithScene pushWithScene pushWithScene : "..self.name_)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    self:pushScene(scene, transition, time, more)
    return self
end

return ViewBase
