--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local JSZjiangliLayer = class("JSZjiangliLayer", require("app.views.mmExtend.LayerBase"))
JSZjiangliLayer.RESOURCE_FILENAME = "JSZjiangliLayer.csb"


function JSZjiangliLayer:onCleanup()
    --self:clearAllGlobalEventListener()
end

function JSZjiangliLayer:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )

    -- if mm.GuildId == 10015 then
    --     performWithDelay(self,function( ... )
    --         -- Guide:startGuildById(10016, mm.GuildScene.jsGuildtimesBtn)
    --         Guide:startGuildById(10018, mm.GuildScene.jsGuildokBtn)
    --     end, 0.01)
    -- elseif mm.GuildId == 10041 then
    --     performWithDelay(self,function( ... )
    --         Guide:startGuildById(10043, mm.GuildScene.jsGuildokBtn)
    --     end, 0.01)
    -- end

    if mm.GuildId == 10041 then
        Guide:GuildEnd()
    end

    mm.req("getActivityInfo",{type=0})
end

function JSZjiangliLayer:onExit()

end

function JSZjiangliLayer:onCreate(param)
    self:init(param)

    --self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function JSZjiangliLayer:init(param)
    self.param = param
    self.scene = param.scene

    self.RaidsTimes = param.RaidsTimes
    self.exp = param.exp
    self.gold = param.gold
    self.poolExp = param.poolExp
    self.wupinA =    param.wupinA
    self.wupinB = param.wupinB
    self.top5 = param.top5
    self.type = param.type
    self.allDropTab = param.allDropTab
    

    self:initLayerUI()
end

function JSZjiangliLayer:initLayerUI( )
    self.Node = self:getResourceNode()

    if self.type == 1 then
        self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_1"):setString("挂机战斗场次")
        self.Node:getChildByName("Image_bg"):getChildByName("Text_01"):setString("挂机奖励")
    end

    local Text_zhantimes = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_zhantimes")
    Text_zhantimes:setString(self.RaidsTimes)

    local Text_exp = self.Node:getChildByName("Image_bg"):getChildByName("Text_exp")
    Text_exp:setString(self.exp)

    local Text_exppool = self.Node:getChildByName("Image_bg"):getChildByName("Text_exppool")
    Text_exppool:setString(self.poolExp)

    -- local chenText = self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):getChildByName("Text_2")
    -- chenText:setString("橙色装备：123")

    -- local ziText = self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):getChildByName("Text_3")
    -- ziText:setString("紫色装备：123")

    -- local lanText = self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):getChildByName("Text_4")
    -- lanText:setString("蓝色装备：123")

    -- local lvText = self.Node:getChildByName("Image_bg"):getChildByName("Image_1"):getChildByName("Text_5")
    -- lvText:setString("绿色装备：123")

    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    Button_ok:setTouchEnabled(false)
    performWithDelay(self,function(  )
        Button_ok:setTouchEnabled(true)
    end,0.2)

    -- local Panel_touch = self.Node:getChildByName("Panel_touch")
    -- Panel_touch:addTouchEventListener(handler(self, self.ButtonCloseBack))


    local dropTab = self.top5
    if mm.GuildId == 10015 or mm.GuildId == 10016 then
        if 1 == mm.data.playerinfo.camp then
            dropTab = {{id = 1160785969,num = 1,type = 0}}
        else
            dropTab = {{id = 1513632312,num = 1,type = 0}}
        end
        
    end
    
    -- for i=1,5 do
    --     if i > 5 then
    --         break
    --     end

    --     if i > #dropTab then
    --         self.Node:getChildByName("Image_bg"):getChildByName("Image_"..i):setVisible(false)
    --     else
    --         local iconSrc = nil
    --         if dropTab[i].type == MM.EDropType.DT_jingyandan then
    --             iconSrc = gameUtil.getItemIconRes(dropTab[i].id)
    --         else
    --             iconsrc = gameUtil.getEquipIconRes(dropTab[i].id)
    --         end
    --         local imageView = self.Node:getChildByName("Image_bg"):getChildByName("Image_"..i)
    --         imageView:setVisible(true)
    --         local sprite = cc.Sprite:create(iconsrc)

    --         if dropTab[i].num > 0 then
    --             imageView:getChildByName("num"):setString(dropTab[i].num)
    --             imageView:getChildByName("num"):setLocalZOrder(100)
    --         end

    --         if dropTab[i].type ~= MM.EDropType.DT_jingyandan then
    --             local pinPathRes = gameUtil.getEquipPinRes(INITLUA:getEquipByid( dropTab[i].id ).Quality)
    --             if #pinPathRes > 0 then
    --                 local pinImgView = ccui.ImageView:create()
    --                 pinImgView:loadTexture(pinPathRes)
    --                 sprite:addChild(pinImgView)
    --                 pinImgView:setAnchorPoint(cc.p(0,0))
    --                 pinImgView:setPosition(0, 0)
    --                 pinImgView:setScale(sprite:getContentSize().width/pinImgView:getContentSize().width, sprite:getContentSize().height/pinImgView:getContentSize().height)
    --             end
    --         end
    --         --sprite:setScale(imageView:getContentSize().width/sprite:getContentSize().width, imageView:getContentSize().height/sprite:getContentSize().height)

    --         sprite:setPosition(imageView:getContentSize().width/2, imageView:getContentSize().height/2)
    --         imageView:addChild(sprite)
    --         local s = imageView:getContentSize().width/sprite:getContentSize().width
    --         sprite:setScale(s)
    --     end

        
        
    -- end

    local size  = cc.Director:getInstance():getWinSize()

    local ListView = self.Node:getChildByName("ListView")

    local dTab = self.allDropTab



    if dTab then

        local count = 0

        local itemHeight = 84 * 1.2
        local itemWidth = 84


        local offsetY = itemHeight*0.3
        local offsetX = itemWidth*0.1
        local all = #dTab

        local custom_item = ccui.Layout:create()

        for k,v1 in pairs(dTab) do
            count = count + 1

            local equip = INITLUA:getEquipByid(v1.id)

            if equip then
                local item = gameUtil.createEquipItem(v1.id,v1.num)
                item:setAnchorPoint(cc.p(0.0,0.0))
                
                itemHeight = item:getContentSize().height * 1.3
                itemWidth = item:getContentSize().width * 1.1
                custom_item:addChild(item)

                offsetY = itemHeight*0.3
                offsetX = itemWidth*0.1
                
                local tempY = math.floor((all/5) + 1) * itemHeight + offsetY
                local tempX = (size.width-itemWidth*5-offsetX*4) * 0.5 + itemWidth * 0.2
                item:setPosition(tempX + itemWidth* 1 * ((count-1)%5), tempY - offsetY  - itemHeight * ((math.floor((count-1)/5))+1))
                local aaa = tempX + itemWidth* 1.2 * ((count-1)%5)
                local bbb = tempY - offsetY  - itemHeight * ((math.floor((count-1)/5))+1)
                cclog(" www ###################         "..aaa)
                cclog(" www ###################         "..bbb)
                if equip.EquipType == MM.EEquipType.ET_SuiPian then
                    local suipianPinPathRes = gameUtil.getEquipSuipianPinRes(equip.Quality)
                    local suipianTag = cc.Sprite:create(suipianPinPathRes)
                    suipianTag:setPosition(cc.p(20, item:getContentSize().height - 15))
                    item:addChild(suipianTag)
                end
            end

        end


        local H = math.floor((count/5) + 1) * itemHeight 
        cclog(" www ###################     count    "..count)
        cclog(" www ###################      H   "..H)

        custom_item:setContentSize(size.width,H) 

        ListView:pushBackCustomItem(custom_item)

    end












    local count = 0


    if self.wupinA then
        for i=1,#self.wupinA do
            count = count + self.wupinA[i]
        end
    end

    if self.wupinB then
        for i=1,#self.wupinB do
            count = count + self.wupinB[i]
        end
    end

    local dropTab = self.allDropTab
    local count = 0
    if dropTab then
        for k,v in pairs(dropTab) do
            count = count + v.num
        end
    end


    self.Node:getChildByName("Image_bg"):getChildByName("Text_Num"):setString("获得装备："..count)

    mm.GuildScene.jsGuildtimesBtn = self.Node:getChildByName("Panel_Guild_times")
    mm.GuildScene.jsGuilddropBtn = self.Node:getChildByName("Panel_Guild_drop")
    mm.GuildScene.jsGuildokBtn = Button_ok
end





function JSZjiangliLayer:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
        mm.GuildScene:checkGuild()
        if mm.GuildId == 10043 then
            -- Guide:GuildEnd()
        end
    end
end

function JSZjiangliLayer:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
        if mm.GuildId == 10018 then
            Guide:startGuildById(10019, mm.GuildScene.heroBtn)
        elseif mm.GuildId == 10043 then
            Guide:GuildEnd()
            -- Guide:startGuildById(10044, mm.GuildScene.heroBtn)
        end

        mm.GuildScene:checkGuild()
    end
end



function JSZjiangliLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        
    end
end

return JSZjiangliLayer


