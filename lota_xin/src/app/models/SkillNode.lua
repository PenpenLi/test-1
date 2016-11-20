local SkillNode = class("SkillNode")
SkillNode.__index = SkillNode

function SkillNode.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, SkillNode)
    return target
end


function SkillNode:onEnter() 
    
end

function SkillNode:onExit()

end

function SkillNode.create(param)
    local node = param.node
    local layerCsb = SkillNode.extend(node) 
    if layerCsb then 
        layerCsb:init(param)
    end
    return layerCsb
end

function SkillNode:init(param)
    
end

function SkillNode:playSkill(skillPath)

    local skeletonNode = gameUtil.createSkeletonAnimation(skillPath..".json", skillPath..".atlas",0.25)
    --local skeletonNode = gameUtil.createSkeletonAnimation("res/Effect/yingxiong/gongyong/t_07/t_07"..".json", "res/Effect/yingxiong/gongyong/t_07/t_07"..".atlas",0.25)
    
    self:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "mb", false)

    local function toPlayHurtAction( ... )
        skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
        skeletonNode:setVisible(false)
        
    end 
    skeletonNode:registerSpineEventHandler(toPlayHurtAction,sp.EventType.ANIMATION_COMPLETE)
    
    
end



return SkillNode
