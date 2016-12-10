local GetHeroLayer = class("GetHeroLayer", require("app.views.mmExtend.LayerBase"))
GetHeroLayer.RESOURCE_FILENAME = "HuodeHero.csb"

-- local huodeHeroInfo1 = {src="res/Effect/uiEffect/czyx/czyx.ExportJson", aniName="czyx", aniAltName="czyx_xunhuan",scale = 1/0.34}
-- local huodeHeroInfo2 = {src="res/Effect/uiEffect/czyx_bai/czyx_bai.ExportJson", aniName="czyx_bai", scale = 1/0.9}
-- local huodeHeroInfo3 = {src="res/Effect/uiEffect/czyx_lizi/czyx_lizi.ExportJson", aniName="czyx_lizi", scale = 1/0.58}

function GetHeroLayer:onCreate(param)
	self.heroId = param.heroId
	self.Node = self:getResourceNode()
	
	local heroRes = gameUtil.getHeroTab(self.heroId)
	local text_name = self.Node:getChildByName("Image_2"):getChildByName("Text_1")
	text_name:setString(heroRes.Name)

	local image_hero = self.Node:getChildByName("Image_3")
	self.skeletonNode = gameUtil.createSkeletonAnimation(heroRes.Src..".json", heroRes.Src..".atlas",1)
    image_hero:addChild(self.skeletonNode, 1000)
    self.skeletonNode:setPosition(image_hero:getContentSize().width * 0.5, 0)
    self.skeletonNode:update(0.012)
    self.skeletonNode:setAnimation(0, "stand", true)
    self.skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.skeletonNode:setScale(1.2)

    local button_ok = self.Node:getChildByName("Button_ok")
    gameUtil.setBtnEffect(button_ok)
    button_ok:addTouchEventListener(handler(self, self.okCbk))
    self.btnOk = button_ok

    -- gameUtil.addArmatureFile(huodeHeroInfo1.src)
    -- gameUtil.addArmatureFile(huodeHeroInfo2.src)
    -- gameUtil.addArmatureFile(huodeHeroInfo3.src)

    local imageSize = image_hero:getContentSize()

    local node1 = gameUtil.createSkeAnmion( {name = "czyx",scale = 1.0} )
    node1:setAnimation(0, "stand", true)
    node1:setPosition(imageSize.width * 0.5, imageSize.height * 0.25)
    image_hero:addChild(node1, 1)

    local node2 = gameUtil.createSkeAnmion( {name = "czyx_bai",scale = 1.0} )
    node2:setAnimation(0, "stand", true)
    node2:setPosition(imageSize.width * 0.5, imageSize.height * 0.25)
    image_hero:addChild(node2, 101)

    local node3 = gameUtil.createSkeAnmion( {name = "czyx_lizi",scale = 1.0} )
    node3:setAnimation(0, "stand", true)
    node3:setPosition(imageSize.width * 0.5, imageSize.height * 0.25)
    image_hero:addChild(node3, 2)


    -- local node2 = gameUtil.createArmtrue(huodeHeroInfo2,-1)
    -- node2:setPosition(imageSize.width * 0.5, imageSize.height * 0.25)
    -- image_hero:addChild(node2, 101)
    -- local node3 = gameUtil.createArmtrue(huodeHeroInfo3,-1)
    -- node3:setPosition(imageSize.width * 0.5, imageSize.height * 0.25)
    -- image_hero:addChild(node3, 2)

    -- if mm.GuildId == 10031 then

    --     gameUtil.addArmatureFile("res/Effect/uiEffect/yd/yd.ExportJson")
    --     local anime = ccs.Armature:create("yd")
    --     local animation = anime:getAnimation()
    --     button_ok:addChild(anime,10)
    --     animation:play('yd')
    --     anime:setName("anime")
    --     anime:setPosition(button_ok:getContentSize().width * 0.5, button_ok:getContentSize().height * 0.5)

    -- end
end

function GetHeroLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function GetHeroLayer:okCbk(widget, touchkey)
	if touchkey == ccui.TouchEventType.ended then
        -- self.skeletonNode:setAnimation(0, "stand", false)
		self:removeFromParent()

        
	end
end

function GetHeroLayer:onEnter()
    
end

function GetHeroLayer:onExit()
    
end

function GetHeroLayer:onEnterTransitionFinish()
    
end

function GetHeroLayer:onExitTransitionStart()
    
end

function GetHeroLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return GetHeroLayer