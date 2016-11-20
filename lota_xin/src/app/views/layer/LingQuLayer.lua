local LingQuLayer = class("LingQuLayer", require("app.views.mmExtend.LayerBase"))
LingQuLayer.RESOURCE_FILENAME = "lingqujiangli.csb"



function LingQuLayer:onCreate(param)
    self:init(param)

    self.isExsit = 1
end


function LingQuLayer:init(param)

    self.Node = self:getResourceNode()

    self.app = param.app
    self.taskId = param.tab.taskId
    
    self.Node:getChildByName("Panel_touch"):addTouchEventListener(handler(self, self.backBtnCbk))

    --self:getChildByName("Image_bg"):getChildByName("hero_icon"):loadTexture(gameUtil.getHeroIcon(self.heroId))

    local v = INITLUA:getTaskResById(self.taskId)

    local image_bg = self.Node:getChildByName("Image_bg")
    image_bg:getChildByName("Text_name"):setText(v.TaskName)
    image_bg:getChildByName("Text_msg"):setText(v.TaskDes)

    image_bg:getChildByName("Text_exp1"):setVisible(false)
    image_bg:getChildByName("Text_exp2"):setVisible(false)
    image_bg:getChildByName("Image_2"):setVisible(false)
    image_bg:getChildByName("Image_3"):setVisible(false)
    if v.T_Exp ~= 0 then
        image_bg:getChildByName("Text_exp1"):setString(v.T_Exp)
        image_bg:getChildByName("Text_exp1"):setVisible(true)
        image_bg:getChildByName("Image_2"):loadTexture("res/UI/icon_EXPzhandui.png")
        image_bg:getChildByName("Image_2"):setVisible(true)
    end
    if v.T_ExpPool ~= 0 then
        if v.T_Exp ~= 0 then
            image_bg:getChildByName("Text_exp2"):setString(v.T_ExpPool)
            image_bg:getChildByName("Text_exp2"):setVisible(true)
            image_bg:getChildByName("Image_3"):loadTexture("res/UI/icon_EXPjingyanchi.png")
            image_bg:getChildByName("Image_3"):setVisible(true)
        else
            image_bg:getChildByName("Text_exp1"):setString(v.T_ExpPool)
            image_bg:getChildByName("Text_exp1"):setVisible(true)
            image_bg:getChildByName("Image_2"):loadTexture("res/UI/icon_EXPjingyanchi.png")
            image_bg:getChildByName("Image_2"):setVisible(true)
        end
    end

    local jinbi = false
    local zuanshi = false
    if mm.data.playerinfo.camp == 1 then
        local skinId = v.LolSkinID
        local index = 1
        if skinId ~= 0 then
            index = 2
            local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_1")
            local skinIcon = gameUtil.createSkinIcon(skinId)
            skinIcon:setScale(equipItem:getContentSize().width/skinIcon:getContentSize().width, equipItem:getContentSize().height/skinIcon:getContentSize().height)
            equipItem:addChild(skinIcon)
        end
        for i=index,5 do
            local lol_item = "LG"..i
            local lol_num = "LGNum"..i
            local lol_type = "LGType"..i
            local iconSrc
            local pinPathRes
            if v[lol_item] ~= 0 then
                if v[lol_type] == MM.EDropType.DT_jingyandan or v[lol_type] == MM.EDropType.DT_consumables then
                    iconSrc = gameUtil.getItemIconRes(v[lol_item])
                    pinPathRes = gameUtil.getEquipPinRes(INITLUA:getItemByid( v[lol_item] ).Quality)
                else
                    iconSrc = gameUtil.getEquipIconRes(v[lol_item])
                    pinPathRes = gameUtil.getEquipPinRes(INITLUA:getEquipByid( v[lol_item] ).Quality)
                end
                local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i)
                local imageView = cc.Sprite:create(iconSrc)
                imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
                if #pinPathRes > 0 then
                    local pinImgView = ccui.ImageView:create()
                    pinImgView:loadTexture(pinPathRes)
                    imageView:addChild(pinImgView)
                    pinImgView:setAnchorPoint(cc.p(0,1))
                    pinImgView:setScale(imageView:getContentSize().width/pinImgView:getContentSize().width)
                    pinImgView:setPosition(0, imageView:getContentSize().height)
                end
                
                if v[lol_type] == MM.EDropType.DT_HunShi then
                    local hunShiTag = cc.Sprite:create("res/UI/icon_hunshi.png")
                    hunShiTag:setAnchorPoint(cc.p(0, 1))
                    hunShiTag:setPosition(cc.p(1, imageView:getContentSize().height-1))
                    imageView:addChild(hunShiTag)
                    hunShiTag:setScale(imageView:getContentSize().width/hunShiTag:getContentSize().width*0.96)
                end
                
                local num = v[lol_num]
                if num > 0 then
                    local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

                    local ttfConfig = {}
                    ttfConfig.fontFilePath = "font/youyuan.TTF"
                    ttfConfig.fontSize = 30
                    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                    ttfConfig.customGlyphs = nil
                    ttfConfig.distanceFieldEnabled = true
                    ttfConfig.outlineSize = 1
                    
                    local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER,300)
                    label:setAnchorPoint(cc.p(1,0))
                    label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
                    label:setTextColor( cc.c4b(255, 255, 255, 255) )
                    label:enableGlow(cc.c4b(255, 255, 0, 255))
                    imageView:addChild(label)
                    --label:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
                    local scaleX = label:getBoundingBox().width / sprite_ditu:getContentSize().width
                    local scaleY = label:getBoundingBox().height / sprite_ditu:getContentSize().height
                    sprite_ditu:setScale(scaleX, scaleY)
                end
                imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
                equipItem:addChild(imageView)
            else
                if jinbi == false and v.T_Gold ~= 0 then
                    local imageView = cc.Sprite:create("res/icon/jiemian/icon_jinbi.png")
                    local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i)
                    imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
                    local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

                    local ttfConfig = {}
                    ttfConfig.fontFilePath = "font/youyuan.TTF"
                    ttfConfig.fontSize = 30
                    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                    ttfConfig.customGlyphs = nil
                    ttfConfig.distanceFieldEnabled = true
                    ttfConfig.outlineSize = 1
                    
                    local label = cc.Label:createWithTTF(ttfConfig,v.T_Gold,cc.TEXT_ALIGNMENT_CENTER,300)
                    label:setAnchorPoint(cc.p(1,0))
                    label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
                    label:setTextColor( cc.c4b(255, 255, 255, 255) )
                    label:enableGlow(cc.c4b(255, 255, 0, 255))
                    imageView:addChild(label)
                    local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
                    local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
                    sprite_ditu:setScale(scaleX, scaleY)
                    imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
                    equipItem:addChild(imageView)
                    jinbi = true
                elseif zuanshi == false and v.Ingot ~= 0 then
                    local imageView = cc.Sprite:create("res/icon/jiemian/icon_zuanshi.png")
                    local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i)
                    imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
                    local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

                    local ttfConfig = {}
                    ttfConfig.fontFilePath = "font/youyuan.TTF"
                    ttfConfig.fontSize = 30
                    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                    ttfConfig.customGlyphs = nil
                    ttfConfig.distanceFieldEnabled = true
                    ttfConfig.outlineSize = 1
                    
                    local label = cc.Label:createWithTTF(ttfConfig,v.Ingot,cc.TEXT_ALIGNMENT_CENTER,300)
                    label:setAnchorPoint(cc.p(1,0))
                    label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
                    label:setTextColor( cc.c4b(255, 255, 255, 255) )
                    label:enableGlow(cc.c4b(255, 255, 0, 255))
                    imageView:addChild(label)
                    local scaleX = label:getBoundingBox().width / sprite_ditu:getContentSize().width
                    local scaleY = label:getBoundingBox().height / sprite_ditu:getContentSize().height
                    sprite_ditu:setScale(scaleX, scaleY)
                    imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
                    equipItem:addChild(imageView)
                    zuanshi = true
                else
                    self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i):setVisible(false)
                end
            end
        end
    else
        local skinId = v.DotaSkinID
        local index = 1
        if skinId ~= 0 then
            index = 2
            local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_1")
            local skinIcon = gameUtil.createSkinIcon(skinId)
            skinIcon:setScale(equipItem:getContentSize().width/skinIcon:getContentSize().width, equipItem:getContentSize().height/skinIcon:getContentSize().height)
            equipItem:addChild(skinIcon)
        end
        for i=index,5 do
            local lol_item = "DG"..i
            local lol_num = "DGNum"..i
            local lol_type = "DGType"..i
            local iconSrc
            local pinPathRes
            if v[lol_item] ~= 0 then
                if v[lol_type] == MM.EDropType.DT_jingyandan or v[lol_type] == MM.EDropType.DT_consumables then
                    iconSrc = gameUtil.getItemIconRes(v[lol_item])
                    pinPathRes = gameUtil.getEquipPinRes(INITLUA:getItemByid( v[lol_item] ).Quality)
                else
                    iconSrc = gameUtil.getEquipIconRes(v[lol_item])
                    pinPathRes = gameUtil.getEquipPinRes(INITLUA:getEquipByid( v[lol_item] ).Quality)
                end
                local imageView = cc.Sprite:create(iconSrc)
                local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i)
                imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
                if #pinPathRes > 0 then
                    local pinImgView = ccui.ImageView:create()
                    pinImgView:loadTexture(pinPathRes)
                    imageView:addChild(pinImgView)
                    pinImgView:setAnchorPoint(cc.p(0,1))
                    pinImgView:setScale(imageView:getContentSize().width/pinImgView:getContentSize().width)
                    pinImgView:setPosition(0, imageView:getContentSize().height)
                end
                
                if v[lol_type] == MM.EDropType.DT_HunShi then
                    local hunShiTag = cc.Sprite:create("res/UI/icon_hunshi.png")
                    hunShiTag:setAnchorPoint(cc.p(0, 1))
                    hunShiTag:setPosition(cc.p(2, imageView:getContentSize().height-2))
                    imageView:addChild(hunShiTag)
                    hunShiTag:setScale(imageView:getContentSize().width/hunShiTag:getContentSize().width*0.96)
                end

                local num = v[lol_num]
                if num > 0 then
                    local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

                    local ttfConfig = {}
                    ttfConfig.fontFilePath = "font/youyuan.TTF"
                    ttfConfig.fontSize = 30
                    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                    ttfConfig.customGlyphs = nil
                    ttfConfig.distanceFieldEnabled = true
                    ttfConfig.outlineSize = 1
                    
                    local label = cc.Label:createWithTTF(ttfConfig,num,cc.TEXT_ALIGNMENT_CENTER,300)
                    label:setAnchorPoint(cc.p(1,0))
                    label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
                    label:setTextColor( cc.c4b(255, 255, 255, 255) )
                    label:enableGlow(cc.c4b(255, 255, 0, 255))
                    -- label:setScale(equipItem:getContentSize().width/imageView:getContentSize().width)
                    imageView:addChild(label)
                    local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
                    local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
                    sprite_ditu:setScale(scaleX, scaleY)
                end
                imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
                equipItem:addChild(imageView)
            else
                if jinbi == false and v.T_Gold ~= 0 then
                    local imageView = cc.Sprite:create("res/icon/jiemian/icon_jinbi.png")
                    local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i)
                    imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
                    local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

                    local ttfConfig = {}
                    ttfConfig.fontFilePath = "font/youyuan.TTF"
                    ttfConfig.fontSize = 30
                    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                    ttfConfig.customGlyphs = nil
                    ttfConfig.distanceFieldEnabled = true
                    ttfConfig.outlineSize = 1
                    
                    local label = cc.Label:createWithTTF(ttfConfig,v.T_Gold,cc.TEXT_ALIGNMENT_CENTER,300)
                    label:setAnchorPoint(cc.p(1,0))
                    label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
                    label:setTextColor( cc.c4b(255, 255, 255, 255) )
                    label:enableGlow(cc.c4b(255, 255, 0, 255))
                    imageView:addChild(label)
                    local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
                    local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
                    sprite_ditu:setScale(scaleX, scaleY)
                    imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
                    equipItem:addChild(imageView)
                    jinbi = true
                elseif zuanshi == false and v.Ingot ~= 0 then
                    local imageView = cc.Sprite:create("res/icon/jiemian/icon_zuanshi.png")
                    local equipItem = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i)
                    imageView:setScale(equipItem:getContentSize().width/imageView:getContentSize().width, equipItem:getContentSize().height/imageView:getContentSize().height)
                    local sprite_ditu = cc.Sprite:create("res/UI/pc_jiaobiao.png")
                    sprite_ditu:setAnchorPoint(cc.p(1, 0))
                    sprite_ditu:setPosition(cc.p(imageView:getContentSize().width, 0))
                    imageView:addChild(sprite_ditu)

                    local ttfConfig = {}
                    ttfConfig.fontFilePath = "font/youyuan.TTF"
                    ttfConfig.fontSize = 30
                    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                    ttfConfig.customGlyphs = nil
                    ttfConfig.distanceFieldEnabled = true
                    ttfConfig.outlineSize = 1
                    
                    local label = cc.Label:createWithTTF(ttfConfig,v.Ingot,cc.TEXT_ALIGNMENT_CENTER,300)
                    label:setAnchorPoint(cc.p(1,0))
                    label:setPosition(cc.p(imageView:getContentSize().width - 5, 0))
                    label:setTextColor( cc.c4b(255, 255, 255, 255) )
                    label:enableGlow(cc.c4b(255, 255, 0, 255))
                    imageView:addChild(label)
                    local scaleX = label:boundingBox().width / sprite_ditu:getContentSize().width
                    local scaleY = label:boundingBox().height / sprite_ditu:getContentSize().height
                    sprite_ditu:setScale(scaleX, scaleY)
                    imageView:setPosition(equipItem:getContentSize().width * 0.5, equipItem:getContentSize().height * 0.5)
                    equipItem:addChild(imageView)
                    zuanshi = true
                else
                    self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i):setVisible(false)
                end
            end
        end
    end

    -- 领取按钮
    self.lingquBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_EquipmentBtn")
    self.lingquBtn:setTitleText("确定")
    gameUtil.setBtnEffect(self.lingquBtn)
    
    self.lingquBtn:addTouchEventListener(handler(self, self.lingquBtnCbk))
    local backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(backBtn)

    if mm.GuildId == 10006 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10007, self.lingquBtn)
        end, 0.05)
    elseif mm.GuildId == 10013 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10014, self.lingquBtn)
        end, 0.05)
    -- elseif mm.GuildId == 10026 then
    --     performWithDelay(self,function( ... )
    --         Guide:startGuildById(10027, self.lingquBtn)
    --     end, 0.05)
    end
end
--[[
function LingQuLayer:zhaohuanBack( event )
    local type  = event.type
    if 0 == type then
        mm.data.playerHero = event.playerHero
        mm.data.playerHunshi = event.playerHunshi

        game:dispatchEvent({name = EventDef.UI_MSG, code = "heroHeChen"})
        self:removeFromParent()
    end
end
--]]

function LingQuLayer:lingquBtnCbk(widget,touchkey)
    
    if touchkey == ccui.TouchEventType.ended then
        
        if self.isExsit == nil then
            return
        end
        game:dispatchEvent({name = EventDef.UI_MSG, code = "LingQu"})
        self.isExsit = nil
        
        self:removeFromParent()
        
        if mm.GuildId == 10007 then
            -- performWithDelay(mm.GuildScene,function( ... )
                Guide:startGuildById(10008, mm.GuildScene.heroBtn)
            -- end, 0.05)
        elseif mm.GuildId == 10014 then
            -- performWithDelay(mm.GuildScene,function( ... )
                Guide:startGuildById(10015, mm.GuildScene.chengjiuCloseBtn)
            -- end, 0.05)
        elseif mm.GuildId == 10027 then
            -- performWithDelay(mm.GuildScene,function( ... )
                Guide:startGuildById(10028, mm.GuildScene.heroBtn)
            -- end, 0.05)
        end

        mm.GuildScene:checkGuild()
    end
end

function LingQuLayer:backBtnCbk(widget,touchkey)
    
    if touchkey == ccui.TouchEventType.ended then 
        if self.isExsit == nil then
            return
        end

        if mm.GuildId == 10006 or mm.GuildId == 10007 or mm.GuildId == 10008 or mm.GuildId == 10013 or mm.GuildId == 10014 or mm.GuildId == 10015 or mm.GuildId == 10026 or mm.GuildId == 10027 or mm.GuildId == 10028 then
        else 
            game:dispatchEvent({name = EventDef.UI_MSG, code = "LingQu"})

            

            self.isExsit = nil
            self:removeFromParent()

            mm.GuildScene:checkGuild()
            
            
        end
    end
end


return LingQuLayer
