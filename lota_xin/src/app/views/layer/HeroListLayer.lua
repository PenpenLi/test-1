local HeroListLayer = class("HeroListLayer", require("app.views.mmExtend.LayerBase"))
HeroListLayer.RESOURCE_FILENAME = "HeroLayerNEW.csb"

local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")
local PEIZHI = require("app.res.peizhi")

function HeroListLayer:onCreate(param)
    self.param = param
    self.Node = self:getResourceNode()

    self.fromInitHeroUI = nil
    

    self:initHeroUIBack()
    -- ok按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    mm.GuildScene.heroListBackBtn = self.backBtn

    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

    mm.req("getActivityInfo",{type=0})
end

function HeroListLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getHero" then
            self:initHeroUIBack(event.t)
        end
    end
    if event.name == EventDef.UI_MSG then
        if event.code == "refreshHeroList" then
            self:initHeroUIBack()
        elseif event.code == "heroHeChen" then
            self:initHeroUIBack()
        end
        -- if event.code == "heroUpXin" then
        --     self:initHeroUIBack()
        -- elseif event.code == "heroUpequip" then
        --     self:initHeroUIBack()
        -- elseif event.code == "heroHeChen" then
        --     self:initHeroUIBack()
        -- elseif event.code == "heroUpLevel" then
        --     local custom_item = self.ContentLayer:getChildByName("ListView"):getChildByTag(event.heroId)
        --     --HeroItem:getChildByName("Text_5"):setString("战力："..heroTab[i].zhandouli)
        --     local Image_icon = custom_item:getChildByName("HeroItem"):getChildByName("Image_bg"):getChildByName("Image_icon")
        --     Image_icon:getChildByName("lvTextNode"):getChildByName("Text_lv"):setString(event.lv)
        -- elseif event.code == "refreshZhanli" then
        --     local custom_item = self.ContentLayer:getChildByName("ListView"):getChildByTag(event.heroTab.id)
        --     custom_item:getChildByName("HeroItem"):getChildByName("Text_5"):setString("战力："..gameUtil.Zhandouli( event.heroTab ,mm.data.playerHero))
        -- end
    end
end

function HeroListLayer:onEnter()
    --self:initHeroUI()
    print("mm.GuildId    .. "..mm.GuildId)
    if mm.GuildId == 10008 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10009, self.heroItemBtn)
        end, 0.03)
    elseif mm.GuildId == 10019 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10020, self.heroItemBtn)
        end, 0.03)
    elseif mm.GuildId == 19010 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(19011, self.heroItemBtn)
        end, 0.03)
    elseif mm.GuildId == 10028 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10029, self.heroItemBtn)
        end, 0.03)
    elseif mm.GuildId == 10501 then
        performWithDelay(self,function( ... )
            Guide:startGuildById(10502, self.heroItemBtn)
        end, 0.03)
    end
    mm.data.lastZhanLi = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue )
end

function HeroListLayer:onExit()
    game:dispatchEvent({name = EventDef.UI_MSG, code = "refreshTaskInfo"})
end

function HeroListLayer:isHavebyId11( tab, ID )
    for k,v in pairs(tab) do
        if v.id == ID then
            return 1, v
        end
        
    end
    return 0, nil
end

function HeroListLayer:initHeroUIBack()
    local playerHero = mm.data.playerHero
    if nil == playerHero then playerHero = {} end
    self.HeroTab = playerHero
    local camp = mm.data.playerinfo.camp
    local unitRes = INITLUA:getUnitResByCamp(camp)

    local heroTab = {}

    for k,v in pairs(unitRes) do
        local tab = {}
        tab.ID = v.ID
        tab.Name = v.Name
        tab.herosuxin = v.herosuxin
        tab.ActorType = v.ActorType
        tab.xinlv = v.chushixin
        tab.lv = 1
        tab.exp = 0
        tab.isHave = 0
        tab.jinlv = 1
        tab.Nation = v.Nation
        tab.aptitude = v.aptitude
        tab.zhandouli = 0
        local hunshiId =  gameUtil.getHeroTab( tab.ID ).herohunshiID
        local num = gameUtil.getHunshiNumByid( hunshiId )

        tab.num = num

        if #playerHero > 0 then
            local isHave, haveV = self:isHavebyId11(playerHero,v.ID)
            tab.isHave = isHave
            if tab.isHave == 1 then
                tab.lv = gameUtil.getHeroLv(haveV.exp, haveV.jinlv) 
                tab.xinlv = haveV.xinlv
                tab.jinlv = haveV.jinlv
                tab.exp = haveV.exp
                tab.eqTab = haveV.eqTab
                tab.baseRule = 2
                tab.zhandouli = gameUtil.Zhandouli(haveV, mm.data.playerHero, mm.data.playerExtra.pkValue)
            else
                local needNum = 0
                for i=1, v.chushixin do
                    needNum = needNum + PEIZHI.xinji[i].num
                end
                if tab.num >= needNum then
                    tab.baseRule = 3
                else
                    tab.baseRule = 1
                end
            end
        end
        
        if tab.Nation == camp then
            table.insert(heroTab,tab)
        end
    end


    local function sort_rule( a, b )
        if a.baseRule > b.baseRule then
            return true
        elseif a.baseRule == b.baseRule then
            if a.baseRule == 2 then
                return a.zhandouli > b.zhandouli
            elseif a.baseRule == 1 then
                if a.num > b.num then
                    return true
                elseif a.num == b.num then
                    return a.aptitude > b.aptitude
                else
                    return false
                end
            else
                return a.aptitude > b.aptitude
            end
        else
            return false
        end
    end
    table.sort(heroTab, sort_rule)

    self.HeroTab = heroTab


    local function fun( i, table, cell, cellIndex )
        cell:removeAllChildren()
         local suxinImgTab = {{"icon_fs_normal.png", "icon_fs_disable.png"},
                            {"icon_mt_normal.png", "icon_mt_disable.png"},
                            {"icon_dps_normal.png", "icon_dps_disable.png"},
                            }
        local suxinImg = ""
        local node
        if table.isHave == 1 then
            suxinImg = suxinImgTab[table.herosuxin][1]
            node = gameUtil.getCSLoaderObj({name = "HeroYesItem.csb", type = "CSLoader"})

        else
            suxinImg = suxinImgTab[table.herosuxin][2]
            node = gameUtil.getCSLoaderObj({name = "HeroNoItem.csb", type = "CSLoader"})
        end

        print("table.herosuxin  "..table.herosuxin)
        print("suxinImg  "..suxinImg)

        node:setSwallowTouches(false)
        cell:addChild(node)


        local Image_icon = node:getChildByName("Image_icon")


        Image_icon:loadTexture(gameUtil.getHeroIcon(table.ID))

        local nameText = node:getChildByName("Text_name")
        local c, v, jin = gameUtil.getColor(table.jinlv)
        nameText:setColor(c)
        -- 添加头像相关
        local touxiang = Image_icon:getChildByName("touxiang")
        if not touxiang then
            touxiang = ccui.ImageView:create()
            Image_icon:addChild(touxiang)
            touxiang:setName("touxiang")
        end
        touxiang:loadTexture(gameUtil.getHeroIcon(table.ID))
        touxiang:setScale(Image_icon:getContentSize().width/touxiang:getContentSize().width*0.98)
        touxiang:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)
        touxiang:removeAllChildren()

        Image_icon:loadTexture("res/icon/jiemian/jm_hero"..jin..".png")

        local Image_kuang = Image_icon:getChildByName("Image_kuang")
        if not Image_kuang then
            Image_kuang = ccui.ImageView:create()
            Image_icon:addChild(Image_kuang)
            Image_kuang:setName("Image_kuang")
        end
        Image_kuang:loadTexture("res/icon/jiemian/jm_herokuang"..jin..".png")
        
        
        
        Image_kuang:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)
        Image_kuang:setScale(Image_icon:getContentSize().width/Image_kuang:getContentSize().width)
        for j=1, 20 do
            local jin_flag = Image_icon:getChildByName("jin_flag"..j)
            if v >= j then
                if not jin_flag then
                    jin_flag = ccui.ImageView:create()
                    Image_icon:addChild(jin_flag)
                    jin_flag:setName("jin_flag"..j)
                end
                jin_flag:loadTexture("res/icon/jiemian/jm_herojinjie"..jin..".png")
                jin_flag:setPosition(Image_icon:getContentSize().width*j/(v+1), Image_icon:getContentSize().height-2)
            else
                if jin_flag then
                    jin_flag:setVisible(false)
                end
            end
        end

        if v > 0 then
            nameText:setText(gameUtil.getHeroTab( table.ID ).Name .. "+" .. v)
        else
            nameText:setText(gameUtil.getHeroTab( table.ID ).Name)
        end

        print("table.isHave  "..table.isHave)
        if table.isHave == 1 then
            local lvTextNode = Image_icon:getChildByName("lvTextNode")
            if not lvTextNode then
                lvTextNode = ccui.Text:create(gameUtil.getHeroLv(table.exp, table.jinlv), "fonts/huakang.TTF", 24)
                lvTextNode:setPosition(cc.p(lvTextNode:getContentSize().width/2 + 5, 30))
                Image_icon:addChild(lvTextNode)     
                lvTextNode:setName("lvTextNode")
            else
                lvTextNode:setString(gameUtil.getHeroLv(table.exp, table.jinlv))
            end

            for xinIndex=201,210 do
                local xinImage = touxiang:getChildByTag(xinIndex)
                if xinImage then
                    xinImage:removeFromParent()
                end
            end
            -- 添加星级
            local limit = table.xinlv > 5 and 5 or table.xinlv
            for j=1, limit do
                local image_xing = ccui.ImageView:create()
                if table.xinlv <= 5 then
                    image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
                    image_xing:setScale(0.6)
                else
                    if table.xinlv - j >= 5 then
                        image_xing:loadTexture("res/UI/icon_yueliang_normal.png")
                        image_xing:setScale(1)
                    else
                        image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
                        image_xing:setScale(0.6)
                    end
                end
                image_xing:setPosition(touxiang:getContentSize().width * 0.5 + (j-limit/2)*12 - 5, 10)
                touxiang:addChild(image_xing)
                image_xing:setTag(200+j)
            end

            node:getChildByName("Text_5"):setString("战力："..gameUtil.dealNumber(table.zhandouli))

            
        else
            -- 添加星级
            for xinIndex=201,210 do
                local xinImage = touxiang:getChildByTag(xinIndex)
                if xinImage then
                    xinImage:removeFromParent()
                end
            end
            local limit = table.xinlv > 5 and 5 or table.xinlv
            for j=1, limit do
                local image_xing = ccui.ImageView:create()
                if table.xinlv <= 5 then
                    image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
                    image_xing:setScale(0.6)
                else
                    if table.xinlv - j >= 5 then
                        image_xing:loadTexture("res/UI/icon_yueliang_normal.png")
                        image_xing:setScale(1)
                    else
                        image_xing:loadTexture("res/UI/icon_xingxing_normal.png")
                        image_xing:setScale(0.6)
                    end
                end
                image_xing:setPosition(touxiang:getContentSize().width * 0.5 + (j-limit/2)*12 - 5, 10)
                touxiang:addChild(image_xing)
                image_xing:setTag(200+j)
            end
            local hunshiId =  gameUtil.getHeroTab( table.ID ).herohunshiID
            local num = gameUtil.getHunshiNumByid( hunshiId )
            local needNum = 0
            for i=1, table.xinlv do
                needNum = needNum + PEIZHI.xinji[i].num
            end
            
            if num >= needNum then
                node:getChildByName("LoadingBar"):setPercent(100)
                node:getChildByName("Text_barNum"):setText("可召唤")
            else
                node:getChildByName("LoadingBar"):setPercent(num / needNum * 100)
                node:getChildByName("Text_barNum"):setText(num .. "/" .. needNum)
            end

            if num >= needNum then
                node:setTouchEnabled(true)
                node:getChildByName("Image_xiaolian"):loadTexture("res/UI/icon_lian_xiao.png")
            else
                node:getChildByName("Image_xiaolian"):loadTexture("res/UI/icon_lian_ku.png")
            end

            node:getChildByName("Text_6"):setString("资质：")
            -- ..gameUtil.getHeroTab( table.ID ).aptitude
            local aptitudeImg = node:getChildByName("Text_6"):getChildByName("zizhi") 
            if not aptitudeImg then
                aptitudeImg = ccui.ImageView:create()
                node:getChildByName("Text_6"):addChild(aptitudeImg)
                aptitudeImg:setName("zizhi")
            end
            aptitudeImg:setAnchorPoint(cc.p(0,0.5))
            aptitudeImg:loadTexture("res/UI/".."aptitude_"..gameUtil.getHeroTab( table.ID ).aptitude..".png")
            
            
            

            local textSize = node:getChildByName("Text_6"):getContentSize()
            aptitudeImg:setPositionX(textSize.width + 10)
            aptitudeImg:setPositionY(textSize.height * 0.5)
        end

        print("table.suxinImg  "..suxinImg)
        node:getChildByName("Image_suxin"):loadTexture("res/UI/"..suxinImg)

        node:setTouchEnabled(true)
        node:addTouchEventListener(handler(self, self.heroDetailBtnCbk))
        node:setTag(heroTab[i].ID)

        print("mm.GuildId    .. mm.GuildId  "..mm.GuildId)
        if mm.GuildId == 10008 then
            if heroTab[i].ID == 1144009526 or heroTab[i].ID == 1278227254 then
                self.heroItemBtn = node
            end
        elseif mm.GuildId == 10019 then
            if heroTab[i].ID == 1144009526 or heroTab[i].ID == 1278227254 then
                self.heroItemBtn = node
            end
        elseif mm.GuildId == 19010 then
            if heroTab[i].ID == 1144009526 or heroTab[i].ID == 1278227254 then
                self.heroItemBtn = node
            end
        elseif mm.GuildId == 10028 then
            if heroTab[i].ID == 1278226995 or heroTab[i].ID == 1144009267 then
                self.heroItemBtn = node
            end
        elseif mm.GuildId == 10501 then
            if heroTab[i].ID == 1278227254 or heroTab[i].ID == 1144009526 then
                self.heroItemBtn = node
            end
        end
        
        if heroTab[i].isHave == 1 then
            local jinTab = gameUtil.getEquipId( heroTab[i].ID, heroTab[i].jinlv )
            if jinTab == nil then
                cclog("数据错误！！！")
                return
            end

            local equipItem = {}
            for j=1,6 do
                equipItem[j] = node:getChildByName("Image_eq0"..j)
                if equipItem[j] then
                    equipItem[j]:removeAllChildren()
                end
                local t = gameUtil.getHeroEqByIndex( heroTab[i].eqTab, j )
                local eqId = jinTab.EquipEx[j]
                local equipRes = INITLUA:getEquipByid(eqId)
                if t and t.eqIndex and t.eqId then
                    equipItem[j]:loadTexture(gameUtil.getEquipIconRes(t.eqId))
                    local pinPathRes = gameUtil.getEquipPinRes(equipRes.Quality)
                    if #pinPathRes > 0 then
                        local pinImgView = ccui.ImageView:create()
                        pinImgView:loadTexture(pinPathRes)
                        equipItem[j]:addChild(pinImgView)
                        pinImgView:setAnchorPoint(cc.p(0,1))
                        pinImgView:setPosition(0, equipItem[j]:getContentSize().height)
                        pinImgView:setScale(equipItem[j]:getContentSize().width/pinImgView:getContentSize().width, equipItem[j]:getContentSize().height/pinImgView:getContentSize().height)
                    end
                else
                    equipItem[j]:loadTexture("res/UI/jm_icon_xiao.png")
                    -- 没有装备，设置底图和加号
                    if gameUtil.isHasEquip( eqId ) and gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= equipRes.eq_needLv then
                        local imageView = ccui.ImageView:create()
                        imageView:loadTexture("res/UI/icon_jiahao_normal.png")
                        imageView:setScale(0.7)
                        equipItem[j]:addChild(imageView)
                        imageView:setName("jiahao")
                        imageView:setPosition(equipItem[j]:getContentSize().width * 0.5, equipItem[j]:getContentSize().height * 0.5)
                    end
                end

            end
        end



    end

    print(" initHeroUIBackinitHeroUIBackinitHeroUIBackinitHeroUIBack")
    if self.ContentLayer then
        self.ContentLayer:removeFromParent()
        self.ContentLayer = nil
    end
    local BagBagLayer = cc.CSLoader:createNode("BagHeroLayer.csb")
    self.ContentLayer = BagBagLayer
    self:addChild(BagBagLayer)
    local size  = cc.Director:getInstance():getWinSize()
    BagBagLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(BagBagLayer)

    local ScrollView = BagBagLayer:getChildByName("ScrollView") 
    self.HeroListView = ScrollView


    gameUtil.setSollowViewNew(self.HeroListView, 8, 1, heroTab, 110, nil, fun, nil, {})


end

function HeroListLayer:heroDetailBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self.heroBtnIn =  widget
        local tag = widget:getTag()
        self.fromInitHeroUI = 0
        local flag = 0
        for k,v in pairs(mm.data.playerHero) do
            if v.id == tag then
                flag = 1
                break
            end
        end
        if flag == 1 then
            if gameUtil.isFunctionOpen(closeFuncOrder.HERO_DETAIL) == false then
                gameUtil:addTishi({s = MoGameRet[990047]})
                return
            end

            if self.ContentLayer then
                self.ContentLayer:removeFromParent()
                self.ContentLayer = nil
            end
            local HeroLayer = require("src.app.views.layer.HeroLayer").new({app = self.param.app, heroId = tag, LayerTag = 1})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(HeroLayer)
            HeroLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(HeroLayer)
        else
            local Herozhaohuan = require("src.app.views.layer.Herozhaohuan").new({app = self.param.app, heroId = tag})
            local size  = cc.Director:getInstance():getWinSize()
            if mm.GuildId == 10029 then
                self:addChild(Herozhaohuan, MoGlobalZorder[2999999])
            else
                mm.scene():addChild(Herozhaohuan, MoGlobalZorder[2999999])
            end
            Herozhaohuan:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(Herozhaohuan)
        end

        gameUtil.playUIEffect( "Herobar_Click" )
    end
end

function HeroListLayer:selectCbk( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
        local kImgView = ccui.ImageView:create()
        kImgView:loadTexture("res/UI/jm_icon_select.png")
        widget:addChild(kImgView)
        kImgView:setPosition(widget:getContentSize().width * 0.5, widget:getContentSize().height * 0.5)
        local index = widget:getTag()
        if self.SelectView then
            self.SelectView:removeFromParent()
        end
        self.SelectView = kImgView
        self.SelectTab = self.curInfoTab[index]

        self:setSelect( self.curInfoTab[index], index )
    end
end

function HeroListLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()

        -- if mm.GuildId == 10031 then
        --     Guide:startGuildById(10033, mm.GuildScene.PanelLeft)
        -- end
    end
end

function HeroListLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return HeroListLayer
