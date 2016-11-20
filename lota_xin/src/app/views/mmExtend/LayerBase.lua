local LayerBase = class("LayerBase", cc.Node)
require("app.views.mmExtend.MProt").extend(LayerBase)

function LayerBase:ctor(t)
    self:enableNodeEvents()

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


function LayerBase:getResourceNode()
    return self.resourceNode_
end

function LayerBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    
    self.resourceNode_:setContentSize(CC_DESIGN_RESOLUTION)
    ccui.Helper:doLayout(self.resourceNode_)
    
    assert(self.resourceNode_, string.format("LayerBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function LayerBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "LayerBase:createResoueceBinding() - not load resource node")
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

function LayerBase:showWithLayer()
    self:setVisible(true)
    return self
end

return LayerBase