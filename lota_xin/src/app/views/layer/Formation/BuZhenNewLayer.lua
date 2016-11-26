local BuZhenNewLayer = class("BuZhenNewLayer", require("app.views.mmExtend.LayerBase"))
BuZhenNewLayer.RESOURCE_FILENAME = "BuZhenLayer.csb"

local GuildNum = 2

function BuZhenNewLayer:onCreate(param)
    self.type = param.type
    self.Info = param.Info
    self.index = param.index
    self.Node = self:getResourceNode()
    self.Node:getChildByName("Text_miaoshu"):setVisible(false)
    self.pkType = self.type
    if self.type == nil then
        self.zhenType = 1
    elseif self.type == 1 then
        self.stageRes = INITLUA:getStageResById(self.Info)
        if self.stageRes.StageType == MM.EStageType.STUpLevel then
            self.zhenType = 1
        else
            local chapter = self.stageRes.StageType + 100
            self.zhenType = chapter
        end
        self.Node:getChildByName("Text_miaoshu"):setString(self.stageRes.Desc)
        self.Node:getChildByName("Text_miaoshu"):setVisible(true)
    elseif self.type == 10 then
        self.zhenType = 10
    elseif self.type == 20 then
        self.zhenType = 10

        local pkTimes = tonumber(mm.data.playerExtra.pkTimes)

        local curZhanli = gameUtil.getPlayerForce()
        local pkValue = mm.data.playerExtra.pkValue + 1
        if pkValue >= 20 then
            pkValue = 20
        end
        local newZhanli = gameUtil.getPlayerForce(pkValue)
        local addZhanli = newZhanli - curZhanli

        game.jujiZhanli = {}
        game.jujiZhanli.old = curZhanli
        game.jujiZhanli.new = newZhanli
        game.jujiZhanli.add = addZhanli

        -- local str = "狙击剩余次数:".. pkTimes .. " / 5" .."\n" .. "预计提升战力: ".. addZhanli
        local str = "预计提升战力: ".. addZhanli

        self.Node:getChildByName("Text_miaoshu"):setString(str)
        self.Node:getChildByName("Text_miaoshu"):setVisible(true)
    else
        self.zhenType = 2
    end
    -- 初始化布阵信息
    self:initMyZhenData()

    -- 初始化英雄列表
    self.HeroList = self.Node:getChildByName("Image_bg"):getChildByName("ListView")
    self:initHeroList()

    -- 显示英雄形象
    self:showHero()

    self:updateTop()

    if self.type == nil then
        self:initDiZhen()
    elseif self.type == 1 then
        self:initStageZhen()
    elseif self.type == 10 then
        self:initJJCZhen()
    elseif self.type == 20 then
        self:initJJCZhen()
    else
        self:initPeopleZhen()
    end

    self.zhandouBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_zhan")
    gameUtil.setBtnEffect(self.zhandouBtn)
    self.zhandouBtn:addTouchEventListener(handler(self, self.zhanBtnCbk))

    self.zhuzhenBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_buzhen")
    gameUtil.setBtnEffect(self.zhuzhenBtn)
    self.zhuzhenBtn:addTouchEventListener(handler(self, self.zhuzhenBtnCbk))

    local HeroNum = #mm.data.playerHero
    if HeroNum < 6 then
        self.zhuzhenBtn:setBright(false)
    end


    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self.imageDibtn = self.Node:getChildByName("Image_bg"):getChildByName("Image_di")

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function BuZhenNewLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saveFormation" then
            print("saveFormation &&&&&&&&&&&&&&&&&&        ")
            self:saveFormationBack(event.t)
        end
    end
end

function BuZhenNewLayer:onEnter()
    mm.data.lastZhanLi = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue )
end

function BuZhenNewLayer:onExit()
    game:dispatchEvent({name = EventDef.UI_MSG, code = "backFightSceneBackup"}) 
end

function BuZhenNewLayer:canShow( heroTab )
    local heroRes = gameUtil.getHeroTab(heroTab.id)
    -- 判断是否显示英雄
    if self.stageRes == nil then
        return true
    end
    if self.stageRes.StageType == MM.EStageType.STAD then
        
    elseif self.stageRes.StageType == MM.EStageType.STAP then
        
    elseif self.stageRes.StageType == MM.EStageType.STBoy then
        
    elseif self.stageRes.StageType == MM.EStageType.STGirl then
        if heroRes.CardSex == MM.ECardSex.Girl then
            return true
        else
            return false
        end
    elseif self.stageRes.StageType == MM.EStageType.STBeast then
        if heroRes.CardSex == MM.ECardSex.Beast then
            return true
        else
            return false
        end
    end
    return true
end

function BuZhenNewLayer:initHeroList()
    local playerHero = {} --util.copyTab()
    for k,v in pairs(mm.data.playerHero) do
  
        local isZhuZhen = false
        for k1,v1 in pairs(self.zhuzhen) do
            if v.id == v1.id then
                isZhuZhen = true
            end
        end
        if not isZhuZhen then
            table.insert(playerHero, v)
        end

    end
    --排序
    for k,v in pairs(playerHero) do
        v.zhandouli = gameUtil.Zhandouli(v, playerHero, mm.data.playerExtra.pkValue)
    end
    local sortRules = {
        {
            func = function(v)
                return v.zhandouli
            end,
            isAscending = false
        },
    }
    playerHero = util.powerSort(playerHero, sortRules)
    self.HeroList:removeAllItems()
    for k,v in pairs(playerHero) do
        if self:canShow(v) == true then
            local custom_item = ccui.Layout:create()
            local Image_icon = gameUtil.createTouXiang(v)

            local suxinImgTab = {"icon_fs_normal.png","icon_mt_normal.png","icon_dps_normal.png"}
            local suxin = gameUtil.getHeroTab(v.id).herosuxin
            local suxinImg = suxinImgTab[suxin]
            local pinImgView = ccui.ImageView:create()
            pinImgView:loadTexture("res/UI/"..suxinImg)
            Image_icon:addChild(pinImgView)
            Image_icon:setPositionY(Image_icon:getContentSize().height * 0.5)
            pinImgView:setPosition(Image_icon:getContentSize().width - 5, Image_icon:getContentSize().height - 5)

            if self:IsSelect(v.id) then
                local selectImage = ccui.ImageView:create()
                selectImage:loadTexture("res/UI/jm_hero_xuan.png")
                Image_icon:addChild(selectImage)
                selectImage:setPosition(Image_icon:getContentSize().width/2, Image_icon:getContentSize().height/2)
            end
            custom_item:setTouchEnabled(true)
            custom_item:addTouchEventListener(handler(self, self.updateMyZhen))
            custom_item:setTag(v.id)
            custom_item:addChild(Image_icon)
            custom_item:setContentSize(Image_icon:getContentSize())
            self.HeroList:pushBackCustomItem(custom_item)

            if mm.GuildId == 10033 then
                if v.id == 1278226995 or v.id == 1144009267 then
                    self.heroItemBtn = custom_item
                end
            end
        end
    end
end

function BuZhenNewLayer:IsSelect( id )
    for k,v in pairs(self.myZhen) do
        if v.id == id then
            return true
        end
    end
    return false
end

function BuZhenNewLayer:updateMyZhen( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if #self.myZhen >= 5 then
            return
        end
        local flag = true
        for k,v in pairs(self.myZhen) do
            if v.id == widget:getTag() then
                flag = false
                break
            end
        end
        if flag == false then
            return
        end
        local heroTab = {}
        heroTab.id = widget:getTag()
        heroTab.pos = gameUtil.getHeroTab( heroTab.id ).pos
        table.insert(self.myZhen, heroTab)
        self:showHero()
        self:initHeroList()
        self:updateTop()

        gameUtil.playUIEffect( "Hero_On" )



    end
end

function BuZhenNewLayer:initMyZhenData( ... )
    print(" &&&&&&&&&&&&&&&&&&&&     101    "..  json.encode(mm.data.playerFormation))
    local putongForm = nil
    for k,v in pairs(mm.data.playerFormation) do
        if v.type == self.zhenType then
            putongForm = v
        end
    end
    self.myZhen = {}
    if putongForm ~= nil then
        for i=1,#putongForm.formationTab do
            self.myZhen[i] = {}
            self.myZhen[i].id = putongForm.formationTab[i].id
            local pos = gameUtil.getHeroTab( self.myZhen[i].id ).pos
            self.myZhen[i].pos = pos
        end
    end

    self.zhuzhen = {}
    if putongForm then
        print(" &&&&&&&&&&&&&&&&&&&&     100    "..  json.encode(putongForm))
        self.zhuzhen = util.copyTab(putongForm.helpFormationTab) or {}
    end
end

function BuZhenNewLayer:showHero()
    local sortRules = {
        {
            func = function(v)
                return v.pos
            end,
            isAscending = true
        },
    }
    self.myZhen = util.powerSort(self.myZhen, sortRules)
    for i = 1, 5 do
        local Image = self.Node:getChildByName("Image_bg"):getChildByName("Image_hero"):getChildByName("Image_"..i)
        local oldHero = Image:getChildByName("Hero")
        if oldHero ~= nil then
            oldHero:removeFromParent()
        end
    end
    for i = 1, #self.myZhen do
        local Image = self.Node:getChildByName("Image_bg"):getChildByName("Image_hero"):getChildByName("Image_"..i)
        Image:getChildByName("Panel_"..i):setTag(self.myZhen[i].id)
        Image:getChildByName("Panel_"..i):addTouchEventListener(handler(self, self.xiaZhen))
        local skeletonNode = gameUtil.createSkeletonAnimation(gameUtil.getHeroTab(self.myZhen[i].id).Src..".json", gameUtil.getHeroTab(self.myZhen[i].id).Src..".atlas",1)
        skeletonNode:setPosition(Image:getContentSize().width * 0.5, Image:getContentSize().height * 0.8)
        skeletonNode:update(0.012)
        skeletonNode:setAnimation(0, "stand", true)
        skeletonNode:setScale(0.9)
        skeletonNode:setName("Hero")
        Image:addChild(skeletonNode)
    end

    self.heroZhenImg = self.Node:getChildByName("Image_bg"):getChildByName("Image_hero")
end

function BuZhenNewLayer:xiaZhen( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local index
        for k,v in pairs(self.myZhen) do
            if v.id == widget:getTag() then
                index = k
            end
        end
        table.remove(self.myZhen, index)
        self:showHero()
        self:initHeroList()
        self:updateTop()

        gameUtil.playUIEffect( "Hero_Down" )
    end
end

function BuZhenNewLayer:updateTop()
    --更新战斗力
    local allZhanli = 0
    for i=1,#self.myZhen do
        if self.myZhen[i] then
            for j=1,#mm.data.playerHero do
                if self.myZhen[i].id == mm.data.playerHero[j].id then
                    tab = util.copyTab(mm.data.playerHero[j])
                    local zhanli = gameUtil.Zhandouli( tab ,mm.data.playerHero, mm.data.playerExtra.pkValue)
                    if zhanli then
                        allZhanli = allZhanli + zhanli
                    end
                end
            end
           
        end
    end

    local Top = self.Node:getChildByName("Image_bg"):getChildByName("Image_top")
    Top:getChildByName("Text_myZhanLi"):setString("己方战力："..allZhanli)

    for i = 1, 5 do
        Top:getChildByName("Image_"..i):setVisible(true)
        if self.myZhen[i] ~= nil then
            local Image = Top:getChildByName("Image_"..i)
            Image:loadTexture(gameUtil.getHeroIcon(self.myZhen[i].id))
            local kuang = ccui.ImageView:create()
            kuang:loadTexture("res/icon/jiemian/jm_herokuang1.png")
            kuang:setPosition(Image:getContentSize().width/2, Image:getContentSize().height/2)
            kuang:setScale(Image:getContentSize().width/kuang:getContentSize().width, Image:getContentSize().height/kuang:getContentSize().height)
            Image:addChild(kuang)
        else
            Top:getChildByName("Image_"..i):setVisible(false)
        end
    end
end

function BuZhenNewLayer:initDiZhen()
    local difangInfo = mm.direninfo[mm.direnIndex]
    local difangForm = difangInfo.playerFormation
    local puTongZhen = {}
    for i=1,#difangForm do
        if difangForm[i].type == 1 then
            puTongZhen = difangForm[i].formationTab
        end
    end
    local diplayerHero = difangInfo.playerHero
    local allZhanli = 0
    for i=1,#puTongZhen do
        if diplayerHero == nil then
            
        end
        local pos = gameUtil.getHeroTab( puTongZhen[i].id ).pos
        puTongZhen[i].pos = pos
        for j=1,#diplayerHero do
            if puTongZhen[i].id == diplayerHero[j].id then
                tab = util.copyTab(diplayerHero[j])
                local zhanli = gameUtil.Zhandouli( tab ,diplayerHero)
                if zhanli then
                    allZhanli = allZhanli + zhanli
                end
            end
        end
    end
    local sortRules = {
        {
            func = function(v)
                return v.pos
            end,
            isAscending = true
        },
    }
    puTongZhen = util.powerSort(puTongZhen, sortRules)
    local Top = self.Node:getChildByName("Image_bg"):getChildByName("Image_top")
    Top:getChildByName("Text_hisZhanLi"):setString("敌方战力："..allZhanli)
    for i = 1, 5 do
        Top:getChildByName("Image2_"..i):setVisible(true)
        if puTongZhen[i] ~= nil then
            local Image = Top:getChildByName("Image2_"..i)
            Image:loadTexture(gameUtil.getHeroIcon(puTongZhen[i].id))
            local kuang = ccui.ImageView:create()
            kuang:loadTexture("res/icon/jiemian/jm_herokuang1.png")
            kuang:setPosition(Image:getContentSize().width/2, Image:getContentSize().height/2)
            kuang:setScale(Image:getContentSize().width/kuang:getContentSize().width, Image:getContentSize().height/kuang:getContentSize().height)
            Image:addChild(kuang)
        else
            Top:getChildByName("Image2_"..i):setVisible(false)
        end
    end
end

function BuZhenNewLayer:initStageZhen()
    self.diType = 3
    self.diZhen = {}
    self.dizhanli = 0
    self.stageId = self.Info
    local stageRes = INITLUA:getStageResById(self.stageId)
    self.nickname = stageRes.StageName
    for i=1,#stageRes.StageEnemy do
        local EnemyRes = INITLUA:getMonsterResById(stageRes.StageEnemy[i])
        local tempTab = {}
        tempTab.id = EnemyRes.ID
        tempTab.pos = EnemyRes.pos
        self.dizhanli = self.dizhanli + EnemyRes.monster_power
        table.insert(self.diZhen, tempTab)
    end
    --排序
    local sortRules = {
        {
            func = function(v)
                return v.pos
            end,
            isAscending = true
        }
    }
    self.diZhen = util.powerSort(self.diZhen, sortRules)
    local Top = self.Node:getChildByName("Image_bg"):getChildByName("Image_top")
    Top:getChildByName("Text_hisZhanLi"):setString("敌方战力："..gameUtil.dealNumber(self.dizhanli))
    for i = 1, 5 do
        Top:getChildByName("Image2_"..i):setVisible(true)
        if self.diZhen[i] ~= nil then
            local Image = Top:getChildByName("Image2_"..i)
            Image:loadTexture(INITLUA:getMonsterResById(self.diZhen[i].id).headSrc..".png")
            local kuang = ccui.ImageView:create()
            kuang:loadTexture("res/icon/jiemian/jm_herokuang1.png")
            kuang:setPosition(Image:getContentSize().width/2, Image:getContentSize().height/2)
            kuang:setScale(Image:getContentSize().width/kuang:getContentSize().width, Image:getContentSize().height/kuang:getContentSize().height)
            Image:addChild(kuang)
        else
            Top:getChildByName("Image2_"..i):setVisible(false)
        end
    end
end

function BuZhenNewLayer:initPeopleZhen()
    local diFmTab = util.copyTab(self.Info.playerFormation)
    local diHero = util.copyTab(self.Info.playerHero)
    local diTab = nil
    if self.Info.playerinfo.camp == mm.data.playerinfo.camp then
        self.diType = 4
    else
        self.diType = 5
    end
    -- 获取敌方普通阵型
    for k,v in pairs(diFmTab) do
        if v.type == 1 then
            diTab = v.formationTab
        end
    end

    self.dizhanli = 0
    self.diNickName = self.Info.playerinfo.nickname
    if diTab then
        for i=1,#diTab do
            for hk,hv in pairs(diHero) do
                if hv.id == diTab[i].id then
                    diTab[i].jinlv = hv.jinlv
                    diTab[i].exp = hv.exp
                    diTab[i].xinlv = hv.xinlv
                   
                    local zhanli = gameUtil.Zhandouli( hv , diHero, self.Info.pkValue)
                    if zhanli then
                        self.dizhanli = self.dizhanli + zhanli
                    end
                end
            end
        end
    end
    self.diZhen = self.diZhen or {}
    for k,v in pairs(diTab) do
        local pos = gameUtil.getHeroTab( v.id ).pos
        v.pos = pos
        table.insert(self.diZhen, v)
    end

    --排序
    local sortRules = {
        {
            func = function(v)
                return v.pos
            end,
            isAscending = true
        }
    }
    self.diZhen = util.powerSort(self.diZhen, sortRules)
    local Top = self.Node:getChildByName("Image_bg"):getChildByName("Image_top")
    Top:getChildByName("Text_hisZhanLi"):setString("敌方战力："..self.dizhanli)
    for i = 1, 5 do
        Top:getChildByName("Image2_"..i):setVisible(true)
        if self.diZhen[i] ~= nil then
            local Image = Top:getChildByName("Image2_"..i)
            Image:loadTexture(gameUtil.getHeroIcon(self.diZhen[i].id))
            local kuang = ccui.ImageView:create()
            kuang:loadTexture("res/icon/jiemian/jm_herokuang1.png")
            kuang:setPosition(Image:getContentSize().width/2, Image:getContentSize().height/2)
            kuang:setScale(Image:getContentSize().width/kuang:getContentSize().width, Image:getContentSize().height/kuang:getContentSize().height)
            Image:addChild(kuang)
        else
            Top:getChildByName("Image2_"..i):setVisible(false)
        end
    end
end

function BuZhenNewLayer:initJJCZhen()
    local diFmTab = util.copyTab(self.Info.playerFormation)
    local diHero = util.copyTab(self.Info.playerHero)
    local diTab = nil
    self.diType = self.zhenType 
    -- 获取敌方阵型
    for k,v in pairs(diFmTab) do
        if v.type == self.diType then
            diTab = v.formationTab
        end
    end

    if not diTab then
        for k,v in pairs(diFmTab) do
            if v.type == 1 then
                diTab = v.formationTab
            end
        end
    end

    self.dizhanli = 0
    self.diNickName = self.Info.playerinfo.nickname
    if diTab then
        for i=1,#diTab do
            for hk,hv in pairs(diHero) do
                if hv.id == diTab[i].id then
                    diTab[i].jinlv = hv.jinlv
                    diTab[i].exp = hv.exp
                    diTab[i].xinlv = hv.xinlv
                   
                    local zhanli = gameUtil.Zhandouli( hv , diHero, self.Info.pkValue)
                    if zhanli then
                        self.dizhanli = self.dizhanli + zhanli
                    end
                end
            end
        end
    end
    self.diZhen = self.diZhen or {}
    for k,v in pairs(diTab) do
        local pos = gameUtil.getHeroTab( v.id ).pos
        v.pos = pos
        table.insert(self.diZhen, v)
    end

    --排序
    local sortRules = {
        {
            func = function(v)
                return v.pos
            end,
            isAscending = true
        }
    }
    self.diZhen = util.powerSort(self.diZhen, sortRules)
    local Top = self.Node:getChildByName("Image_bg"):getChildByName("Image_top")
    Top:getChildByName("Text_hisZhanLi"):setString("敌方战力："..self.dizhanli)
    for i = 1, 5 do
        Top:getChildByName("Image2_"..i):setVisible(true)
        if self.diZhen[i] ~= nil then
            local Image = Top:getChildByName("Image2_"..i)
            Image:loadTexture(gameUtil.getHeroIcon(self.diZhen[i].id))
            local kuang = ccui.ImageView:create()
            kuang:loadTexture("res/icon/jiemian/jm_herokuang1.png")
            kuang:setPosition(Image:getContentSize().width/2, Image:getContentSize().height/2)
            kuang:setScale(Image:getContentSize().width/kuang:getContentSize().width, Image:getContentSize().height/kuang:getContentSize().height)
            Image:addChild(kuang)
        else
            Top:getChildByName("Image2_"..i):setVisible(false)
        end
    end
end



function BuZhenNewLayer:zhuzhenBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local HeroNum = #mm.data.playerHero
        if HeroNum < 6 then
            gameUtil:addTishi({s = MoGameRet[990602]})
            return
        end

        if #self.myZhen <= 0 then
            return
        end

        local t = {}
        t.type = self.zhenType
        t.formationTab = {}
        for i=1,#self.myZhen do
             table.insert(t.formationTab, {id = self.myZhen[i].id} )
        end

        local tab = {}
        tab.zhanzhen = t
        tab.BuZhenNewLayer = self
        tab.zhuzhen = self.zhuzhen
        tab.pkType = self.pkType

        print("  zhuzhenBtnCbk###########################       ".. json.encode(tab.zhanzhen))

        local ZhuZhenLayer = require("src.app.views.layer.ZhuZhenLayer").new(tab)
        self:addChild(ZhuZhenLayer, MoGlobalZorder[2999999])

    end
end

function BuZhenNewLayer:updateZhuZhen(zhuzhen)
    print("  updateZhuZhen###########################       ")
    self.zhuzhen = zhuzhen

end

function BuZhenNewLayer:zhanBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if #self.myZhen <= 0 then
            return
        end



        local t = {}
        t.type = self.zhenType
        t.formationTab = {}
        for i=1,#self.myZhen do
             table.insert(t.formationTab, {id = self.myZhen[i].id} )
        end


        t.helpFormationTab = self.zhuzhen

        mm.data.playerFormation = mm.data.playerFormation or {}
        local putongForm = nil
        for i=1,#mm.data.playerFormation do
            if mm.data.playerFormation[i].type == self.zhenType then
                putongForm = mm.data.playerFormation[i]
            end
        end
        if putongForm == nil then
            table.insert(mm.data.playerFormation, t)
        else
            putongForm = t
        end

        mm.req("saveFormation",{getType=1,playerFormation = t, pkType = self.pkType})


    end
end

function BuZhenNewLayer:saveFormationBack( event )
    local type  = event.type
    if 0 == type then
        mm.puTongZhen = {}

        for i=1,#self.myZhen do
            table.insert(mm.puTongZhen, self.myZhen[i].id)
        end

        local t = {}
        t.type = self.zhenType
        t.formationTab = {}
        for i=1,#self.myZhen do
             table.insert(t.formationTab, {id = self.myZhen[i].id} )
        end
        -- for i=1,#mm.data.playerFormation do
        --     if mm.data.playerFormation[i].type == self.zhenType then
        --         mm.data.playerFormation[i] = t
        --     end
        -- end

        mm.diFangZhen = {}
        mm.diFangZhen.pkType = self.type
        mm.diFangZhen.formation = {}
        mm.diFangZhen.stageId = self.stageId or self.index or 0
        if self.diType ~= 3 and self.Info then
            mm.diFangZhen.playerInfo = self.Info.playerinfo or {}
            mm.diplayerHero = self.Info.playerHero
        end
        mm.diFangZhen.diType = self.diType or 1
        mm.diFangZhen.zhandouli = self.dizhanli
        mm.diFangZhen.nickname = self.diNickName or "白菜叶"
        if self.diZhen and #self.diZhen > 0 then
            for i=1,#self.diZhen do
                table.insert(mm.diFangZhen.formation,self.diZhen[i].id)
            end
        end

        mm.diFangZhen.zhuZhen = {}
        for k,v in pairs(self.zhuzhen) do
            table.insert(mm.diFangZhen.zhuZhen,v.id)
        end

        self:removeFromParent()
        game:dispatchEvent({name = EventDef.UI_MSG, code = "closePkLayer", flag = mm.diFangZhen.diType})
        mm:clearLayer()


    else
        cclog(" 保存阵型返回 错误  ")
    end
end

function BuZhenNewLayer:backCbk( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function BuZhenNewLayer:onEnterTransitionFinish()
    
end

function BuZhenNewLayer:onExitTransitionStart()
    
end

function BuZhenNewLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return BuZhenNewLayer