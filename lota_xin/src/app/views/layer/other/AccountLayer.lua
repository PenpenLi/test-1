local AccountLayer = class("AccountLayer", require("app.views.mmExtend.LayerBase"))
AccountLayer.RESOURCE_FILENAME = "JieSuanLayer.csb"

function AccountLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function AccountLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then

    end
end

function AccountLayer:onEnter()

    -- if mm.GuildId == 10002 then
    --     Guide:startGuildById(10003, self.Node:getChildByName("Panel_Guild"))
    -- end
end

function AccountLayer:onExit()

end

function AccountLayer:onEnterTransitionFinish()
    
end

function AccountLayer:onExitTransitionStart()
    
end

function AccountLayer:onCleanup()
    
    self:clearAllGlobalEventListener()
end

function AccountLayer:init(param)

    self.scene = param.scene
    self.PanelHeibg = self.scene:getChildByName("Scene"):getChildByName("Panel_heibg")
    self.PanelHeibg:setVisible(true)
    self.Node = self:getResourceNode()
    local result = param.result
    
    local dropTab = param.dropTab or {}
    --dropTab = {{id = 1160786233,num = 1,type = 1},{id = 1160786233,num = 1,type = 1},{id = 1160786233,num = 1,type = 1},{id = 1160786233,num = 1,type = 1},{id = 1160786233,num = 1,type = 1}}
    
    if mm.GuildId == 10002 then
        if 1 == mm.data.playerinfo.camp then
            dropTab = {{id = 1160785969,num = 1,type = 1}}
        else
            dropTab = {{id = 1513632312,num = 1,type = 1}}
        end
        
    end

    self.scene = self.Node:getChildByName("Panel_touch")
    self.scene:setVisible(false)
    self.Node_win = self.Node:getChildByName("Node_win")

    for j=1,5 do
        self.Node:getChildByName("Image_"..j):setVisible(false)
    end

    if #dropTab > 0 then
        function sort_rule(a, b)
            return a.num > b.num
        end
        table.sort(dropTab, sort_rule)
    end

    local size = cc.Director:getInstance():getWinSize()
    if result == 1 then

        local win_play = gameUtil.createSkeAnmion( {name = "sl", scale = 1} )
        win_play:setAnimation(0, "stand01", false)
        self:addChild(win_play,100)
        win_play:setPosition(size.width/2, size.height*3/4)


        local win_playQuan = gameUtil.createSkeAnmion( {name = "sl", scale = 1} )
        win_playQuan:setAnimation(0, "stand03", false)
        self:addChild(win_playQuan,99)
        win_playQuan:setPosition(size.width/2, size.height*3/4)
        win_playQuan:setScale(2)

        gameUtil.playUIEffect( "Win" )

        function deleteWinPlay( ... )
            win_play:removeFromParent()
            win_playQuan:removeFromParent()
            self.PanelHeibg:setVisible(false)
            self:removeFromParent()
        end
        local dropNum = #dropTab
        local i = 1
        function addequip( ... )
            
            if i > dropNum or i > 5 or dropTab[i].num <= 0 then
                return
            end
            
            local imageView = self.Node:getChildByName("Image_"..i)
            imageView:setVisible(true)
            local sprite

            if dropTab[i].type == 1 then
                sprite = gameUtil.createEquipItem(dropTab[i].id, dropTab[i].num)
            elseif dropTab[i].type == 2 then
                sprite = gameUtil.createItemWidget(dropTab[i].id, dropTab[i].num)
            elseif dropTab[i].type == 3 then
                sprite = gameUtil.createEquipItem(dropTab[i].id, dropTab[i].num)
            end
            sprite:setAnchorPoint(cc.p(0.5, 0.5))

            local equipRes = INITLUA:getEquipByid( dropTab[i].id )
            if equipRes.EquipType == MM.EEquipType.ET_SuiPian then
                local suipianPinPathRes = gameUtil.getEquipSuipianPinRes(equipRes.Quality)
                local suipianTag = cc.Sprite:create(suipianPinPathRes)
                suipianTag:setPosition(cc.p(20, sprite:getContentSize().height - 15))
                sprite:addChild(suipianTag)
            end

            sprite:setPosition(imageView:getContentSize().width/2, imageView:getContentSize().height/2)
            
            sprite:setScale(2)
            imageView:addChild(sprite, 1)
            --win_play2:getAnimation():setSpeedScale(2)
            function playTexiao()

                local win_play2 = gameUtil.createSkeAnmion( {name = "sl", scale = 1} )
                win_play2:setAnimation(0, "stand02", false)
                self:addChild(win_play2, 2)
                win_play2:setPosition(imageView:getPositionX(), imageView:getPositionY())

            end
            sprite:runAction( cc.Sequence:create(cc.ScaleTo:create(0.2, imageView:getContentSize().width/sprite:getContentSize().width), cc.CallFunc:create(playTexiao)))
            i = i + 1
            self:runAction( cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(addequip)))
        end
        self:runAction( cc.Sequence:create(cc.DelayTime:create(1.2), cc.CallFunc:create(addequip), cc.DelayTime:create(0.5), cc.CallFunc:create(deleteWinPlay)))
    else

        local lose_play = gameUtil.createSkeAnmion( {name = "sb", scale = 1} )
        lose_play:setAnimation(0, "stand", false)
        self:addChild(lose_play, 2)
        lose_play:setPosition(size.width/2, size.height*3/4)

        gameUtil.playUIEffect( "Lose" )
        
        function deleteLosePlay( ... )
            self.PanelHeibg:setVisible(false)
            self:removeFromParent()
        end
        local dropNum = #dropTab
        local i = 1
        function addequip( ... )
            
            if i > dropNum or i > 5 or dropTab[i].num <= 0 then
                return
            end

            local imageView = self.Node:getChildByName("Image_"..i)
            imageView:setVisible(true)
            local sprite

            if dropTab[i].type == 1 then
                sprite = gameUtil.createEquipItem(dropTab[i].id, dropTab[i].num)
            elseif dropTab[i].type == 2 then
                sprite = gameUtil.createItemWidget(dropTab[i].id, dropTab[i].num)
            end
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            --sprite:setScale(imageView:getContentSize().width/sprite:getContentSize().width, imageView:getContentSize().height/sprite:getContentSize().height)
            local equipRes = INITLUA:getEquipByid( dropTab[i].id )
            if equipRes.EquipType == MM.EEquipType.ET_SuiPian then
                local suipianPinPathRes = gameUtil.getEquipSuipianPinRes(equipRes.Quality)
                local suipianTag = cc.Sprite:create(suipianPinPathRes)
                suipianTag:setPosition(cc.p(20, sprite:getContentSize().height - 15))
                sprite:addChild(suipianTag)
            end
            
            sprite:setPosition(imageView:getContentSize().width/2, imageView:getContentSize().height/2)
            sprite:setScale(3)
            imageView:addChild(sprite)
            function playTexiao()
                local win_play2 = gameUtil.createSkeAnmion( {name = "sl", scale = 1} )
                win_play2:setAnimation(0, "stand02", false)
                self:addChild(win_play2, 2)
                win_play2:setPosition(imageView:getPositionX(), imageView:getPositionY())
            end
            sprite:runAction( cc.Sequence:create(cc.ScaleTo:create(0.2, imageView:getContentSize().width/sprite:getContentSize().width), cc.CallFunc:create(playTexiao)))
            
            i = i + 1
            self:runAction( cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(addequip)))
        end
        self:runAction( cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(addequip), cc.DelayTime:create(2.5), cc.CallFunc:create(deleteLosePlay)))
    end

end

return AccountLayer