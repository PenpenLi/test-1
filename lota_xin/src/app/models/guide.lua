
local Guild = {}

GuideData = require("app/models/guideData")
local talkRes = require("app/res/TalkRes")


function Guild:init()
    
	self.taskId = 10001
    
end

function Guild:initGuild()


end

function Guild:getCurTeskId()
    return self.taskId
end

function Guild:startGuildById( id , btn)
    -- if self.kuangImg then
    --     self.kuangImg:removeFromParent()
    --     self.kuangImg = nil
    -- end

    -- if self.clip then
    --     self.clip:removeFromParent()
    --     self.clip = nil
    -- end

    if btn then
        self:btnGuild(id, btn)
    end

    local guild = GuideData[id]
    if guild.btnId then

    else

    end

    mm.GuildId = id

    cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId",id)
end

function Guild:GuildEnd()
    if self.kuangImg then
        self.kuangImg:removeFromParent()
        self.kuangImg = nil
    end

    if self.clip then
        self.clip:removeFromParent()
        self.clip = nil
    end

    -- if self.shouimageView then
    --     self.shouimageView:removeFromParent()
    --     self.shouimageView = nil
    -- end

    self.talkText = nil
    self.imageView = nil
    self.touchlayer = nil

end

function Guild:setHandVisible(type)
    if self.anime then
        self.anime:setVisible(type)
    end
end

function Guild:setColorVisible(type)
    self.layerColor:setVisible(type)
end

function Guild:setkuangImgVisible(type)
    self.kuangImg:setVisible(type)
end

function Guild:setImageViewVisible(type)
    self.imageView:setVisible(type)
end

function Guild:setUserDefId(id)
    cc.UserDefault:getInstance():setIntegerForKey(mm.data.playerinfo.id .. "GuideId",id)
end



function Guild:btnGuild(id, btn)
    local guild = GuideData[id]

    -- local btnNode = btn:clone()
    -- btnNode:retain()
    -- self.btnNode = btnNode
    -- local x, y = btn:getPosition()
    -- local p = btn:getParent():convertToWorldSpace(cc.p(x, y))
    -- local wz = btn:getBoundingBox()
    -- wz.x = p.x
    -- wz.y = p.y
    -- local maodian = btn:getAnchorPoint()
    -- btnNode:setPosition(p.x,p.y)
    -- mm.GuildScene:addChild(btnNode, 10000)
    -- btnNode:setTouchEnabled(false)
    -- btnNode:setOpacity(1)

    local x, y = btn:getPosition()
    local p = btn:getParent():convertToWorldSpace(cc.p(x, y))
    local maodian = btn:getAnchorPoint()

    if not self.clip then
        self.clip = cc.ClippingNode:create()
        self.clip:setInverted(true)
        self.clip:setAlphaThreshold(0)
        mm.GuildScene:addChild(self.clip, MoGlobalZorder[2800000])
        
        local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0))
        self.clip:addChild(layerColor, 1)
        self.layerColor = layerColor
        -- self.layerColor:setVisible(false)

    end

    if not self.kuangImg then
        
        self.kuangImg = cc.Scale9Sprite:create("res/UI/pc_xuanzexian.png", cc.rect(1, 1, 68, 68), cc.rect(34, 34, 1, 1))
        self.clip:setStencil(self.kuangImg)
        mm.GuildScene:addChild(self.kuangImg, MoGlobalZorder[2800000])
        
        -- gameUtil.addArmatureFile("res/Effect/uiEffect/yd/yd.ExportJson")
        -- local anime = ccs.Armature:create("yd")
        -- local animation = anime:getAnimation()
        -- self.clip:addChild(anime,10)
        -- animation:play('yd')
        -- anime:setName("anime")
        -- self.anime = anime

        local anime = gameUtil.createSkeAnmion( {name = "yd"} )
        anime:setAnimation(0, "stand", true)
        self.clip:addChild(anime,10)
        anime:setName("anime")
        self.anime = anime
    end

    local ww = btn:getContentSize().width
    local hh = btn:getContentSize().height
    if guild.scale then
        ww = ww * guild.scale
        hh = hh * guild.scale
    end
    self.kuangImg:setContentSize(cc.size(ww, hh))
    self.kuangImg:setAnchorPoint(maodian)

    -- self.kuangImg:getChildByName("anime"):setPosition(ww/2, hh/2)

    if guild.isHand ~= 0 then
        self.anime:setVisible(true)
    else
        self.anime:setVisible(false)
    end

    self.kuangImg = self.kuangImg

    local action3 = cc.FadeTo:create(0.8, 255)
    local action4 = cc.FadeTo:create(0.8, 124)
    local action5 = cc.RepeatForever:create(cc.Sequence:create(action3, action4))
    self.kuangImg:runAction(action5)

    

    
    -- local aa = self.clip:getStencil()
    self.kuangImg:setPosition(p.x, p.y)

    if maodian.x == 0 and maodian.y == 0 then
        self.anime:setPosition(p.x + btn:getContentSize().width * 0.5, p.y + btn:getContentSize().height * 0.5)
    elseif maodian.x == 0.5 and maodian.y == 0.5 then
        self.anime:setPosition(p.x, p.y)
        if id == 15002  then
            self.anime:setPosition(p.x - 240, p.y)
        elseif  id == 15053 or id == 10203 or id == 10306 then
            self.anime:setPosition(p.x - 140, p.y)
        elseif id == 80007 or id == 15052  then
            self.anime:setPosition(p.x - 250, p.y)
        end
    elseif maodian.x == 0.5 and maodian.y == 0 then
        self.anime:setPosition(p.x , p.y + btn:getContentSize().height * 0.5)
    elseif maodian.x == 0.5 and maodian.y == 1 then
        self.anime:setPosition(p.x , p.y - btn:getContentSize().height * 0.5)
    elseif maodian.x == 1 and maodian.y == 1 then
        self.anime:setPosition(p.x - btn:getContentSize().width * 0.5 , p.y - btn:getContentSize().height * 0.5)
    end



    if id == 10043 or id == 10041 or id == 10044 then
        self.kuangImg:setVisible(false)
        self.clip:setVisible(false)
    else
        self.kuangImg:setVisible(true)
        self.clip:setVisible(true)
    end

    self.kuangImg:setVisible(false)

    if id == 10040 then
        self.anime:setTimeScale(1/5)
    else
        self.anime:setTimeScale(1)
    end


    -- if not self.shouimageView then
    --     self.shouimageView = ccui.ImageView:create()
    --     self.shouimageView:loadTexture("res/UI/bt_shouzhi.png")
    --     self.shouimageView:setAnchorPoint(cc.p(0.5,0))
    --     mm.GuildScene:addChild(self.shouimageView, MoGlobalZorder[2999999])

    --     local action1 = cc.MoveBy:create(0.5, cc.p(0,30))
    --     local action2 = cc.MoveBy:create(0.5, cc.p(0,-30))
    --     local action = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
    --     self.shouimageView:runAction(action)
    -- end


    
    -- if maodian.x == 0 and maodian.y == 0 then
    --     self.shouimageView:setPosition(p.x + btn:getContentSize().width * 0.5, p.y + btn:getContentSize().height)
    -- elseif maodian.x == 0.5 and maodian.y == 0.5 then
    --     self.shouimageView:setPosition(p.x, p.y + btn:getContentSize().height * 0.5)
    -- elseif maodian.x == 0.5 and maodian.y == 0 then
    --     self.shouimageView:setPosition(p.x , p.y + btn:getContentSize().height)
    -- elseif maodian.x == 1 and maodian.y == 1 then
    --     self.shouimageView:setPosition(p.x - btn:getContentSize().width * 0.5 , p.y)
    -- end

    -- if guild.f == -1 then
    --     self.shouimageView:setScaleY(-1)
    --     self.shouimageView:setPosition(p.x - btn:getContentSize().width * 0.5 , p.y - btn:getContentSize().height)
    -- else
    --     self.shouimageView:setScaleY(1)
    -- end

    -- if id == 10041 then
    --     self.shouimageView:setPositionY(p.y + btn:getContentSize().height * 0.5)
    -- end


    
    -- -- layerColor:setOpacity(10)

    -- if self.shouimageView then
    --     self.shouimageView:setVisible(false)
    -- end

    if guild.f == -1 then
        self.anime:setScaleX(-1)
    elseif guild.f == -2 then
        self.anime:setScaleY(-1)
    else
        self.anime:setScaleX(1)
        self.anime:setScaleY(1)
    end



    local function onTouchBegan(touch, event)
        
        local location = touch:getLocation()
        local isTouchCard
        isTouchCard = cc.rectContainsPoint(self.kuangImg:getBoundingBox(), cc.p(location.x, location.y))
        if isTouchCard then
        else
            event:stopPropagation()
        end 

        if mm.GuildId == 10001 then
            event:stopPropagation()

        elseif mm.GuildId == 10002 then
            -- mm.GuildScene:jiesuan(mm.guildJieSuanTab)
            event:stopPropagation()
            -- mm.GuildScene:nextFight()
            Guide:startGuildById(80005, mm.GuildScene.zhandouBtn)

        elseif mm.GuildId == 10003 then
            -- mm.GuildScene:nextFight()
        elseif mm.GuildId == 10004 then
            -- Guide:startGuildById(10005, mm.GuildScene.chengjiuBtn)
            event:stopPropagation()
        elseif mm.GuildId == 10010 then
            -- Guide:startGuildById(10011, mm.GuildScene.GuildHeroUp)
            event:stopPropagation()
        elseif mm.GuildId == 10016 then
            Guide:startGuildById(10017, mm.GuildScene.jsGuilddropBtn)
        elseif mm.GuildId == 10017 then
            Guide:startGuildById(10018, mm.GuildScene.jsGuildokBtn)
        elseif mm.GuildId == 19001 then
            -- Guide:startGuildById(10023, mm.GuildScene.GuildJinJieBtn)
            event:stopPropagation()
        elseif mm.GuildId == 10024 then
            -- Guide:startGuildById(10025, mm.GuildScene.chengjiuBtn)
        elseif mm.GuildId == 10035 then
            -- Guide:startGuildById(10036, mm.GuildScene.zhanBtn)
            event:stopPropagation()
        elseif mm.GuildId == 10039 then
            Guide:startGuildById(10040, mm.GuildScene.PanelRight)
        elseif mm.GuildId == 10040 then
            mm.GuildScene:readyGo()
            -- Guide:GuildEnd()
            Guide:startGuildById(10041, mm.GuildScene.PanelRight)
        elseif mm.GuildId == 10044 then
            Guide:GuildEnd()


        elseif mm.GuildId == 10102 then
            Guide:startGuildById(10103, game.storeXinYunBtn)
            event:stopPropagation()
        elseif mm.GuildId == 10103 then
            Guide:startGuildById(10104, game.storeshuaxinBtn)
            event:stopPropagation()
        elseif mm.GuildId == 10104 then
            Guide:GuildEnd()

        elseif mm.GuildId == 10205 then
            Guide:GuildEnd()


        elseif mm.GuildId == 10303 then
            Guide:startGuildById(10304, game.zhanliPkSDPl)
            event:stopPropagation()
        elseif mm.GuildId == 10304 then
            Guide:startGuildById(10305, game.tiaozhanPkSDPl)
            event:stopPropagation()
        elseif mm.GuildId == 10308 then
            Guide:GuildEnd()

        elseif mm.GuildId == 10403 then
            Guide:startGuildById(10404, game.zhanliPkSDPl)
            event:stopPropagation()
        elseif mm.GuildId == 10404 then
            Guide:startGuildById(10405, game.tiaozhanPkSDPl)
            event:stopPropagation()
        elseif mm.GuildId == 10408 then
            Guide:GuildEnd()

        elseif mm.GuildId == 10603 then
            Guide:startGuildById(10604, game.zhanliPkSDPl)
            event:stopPropagation()
        elseif mm.GuildId == 10604 then
            Guide:startGuildById(10605, game.tiaozhanPkSDPl)
            event:stopPropagation()
        end

        
        
        return true
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        event:stopPropagation()
    end

    if not self.touchlayer then
        local touchlayer = cc.Layer:create()
        self.layerColor:addChild(touchlayer, 7)
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        local eventDispatcher = touchlayer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchlayer)
        self.touchlayer = touchlayer
    end


    local guild = GuideData[id]
    local str = "Guide_Desc"
    local res = "res/UI/guildLoL.png"
    local camp = mm.data.playerinfo.camp
    if 1 == camp then
        res = "res/UI/guildLoL.png"
    else
        res = "res/UI/guildDota.png"
        str = "DotaGuide_Desc"
    end
    if guild.talk then
        if not self.imageView then
            local imageView = ccui.ImageView:create()
            imageView:loadTexture("res/UI/bt_yindao.png")
            imageView:setAnchorPoint(cc.p(0,0))
            self.layerColor:addChild(imageView)
            self.imageView = imageView

            local imView = ccui.ImageView:create()
            imView:loadTexture(res)
            imView:setAnchorPoint(cc.p(0,0))
            imageView:addChild(imView)
            imView:setPosition(-100,20)
            imView:setScale(1.8)

            local talkText = ccui.Text:create(Talk[guild.talk[1]][str], "fonts/huakang.TTF", 24)
            talkText:setColor(cc.c3b(255, 255, 255))
            talkText:setPosition(cc.p(260,60))
            imageView:addChild(talkText)
            talkText:setAnchorPoint(cc.p(0,0))
            talkText:ignoreContentAdaptWithSize(false)
            talkText:setSize(cc.size(280,90))
            self.talkText = talkText

        else
            if self.imageView then
                self.imageView:setVisible(true)
            end

            if self.talkText then
                self.talkText:setVisible(true)
            end
        end

        self.talkText:setString(Talk[guild.talk[1]][str])


        if guild.height then
            self.imageView:setPosition(cc.p(20,guild.height))
        else
            self.imageView:setPosition(cc.p(20,100))
        end
    else
        if self.imageView then
            self.imageView:setVisible(false)
            self.talkText:setVisible(false)
        end
    end
end

return Guild