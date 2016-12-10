local ZhuZhenLayer = class("ZhuZhenLayer", require("app.views.mmExtend.LayerBase"))
ZhuZhenLayer.RESOURCE_FILENAME = "ZhuZhenLayer.csb"



function ZhuZhenLayer:onCreate(param)
    self.zhanzhen = param.zhanzhen
    self.zhuzhen = param.zhuzhen or {}
    self.BuZhenNewLayer = param.BuZhenNewLayer
    self.pkType = param.pkType
    self:init()



    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function ZhuZhenLayer:init()
    self.Node = self:getResourceNode()
    
    self.HeroList = self.Node:getChildByName("Image_bg"):getChildByName("ListView")

    self.SkillList = self.Node:getChildByName("Image_bg"):getChildByName("Image_zhuzhen"):getChildByName("ListView_skill")

    self.txt_rules = self.Node:getChildByName("Image_bg"):getChildByName("Image_zhuzhen"):getChildByName("txt_rules")

    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backCbk))
    gameUtil.setBtnEffect(self.backBtn)

    self.buzhenBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_buzhen")
    self.buzhenBtn:addTouchEventListener(handler(self, self.buzhenBtnCbk))
    gameUtil.setBtnEffect(self.buzhenBtn)

    self.kaizhanBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_zhan")
    self.kaizhanBtn:addTouchEventListener(handler(self, self.kaizhanBtnCbk))
    gameUtil.setBtnEffect(self.kaizhanBtn)


    self:initHeroList()

    self:initSkillList()
end

function ZhuZhenLayer:initHeroList()
    local formationTab = self.zhanzhen.formationTab

    self.showHeroList = {} 

    for k,v in pairs(mm.data.playerHero) do
        local isZhanZhen = false
        for k1,v1 in pairs(formationTab) do
            if v.id == v1.id then
                isZhanZhen = true
                break
            end
        end

        if not isZhanZhen then
            table.insert(self.showHeroList, v)
        end

    end


    --排序
    for k,v in pairs(self.showHeroList) do
        v.zhandouli = gameUtil.Zhandouli(v, mm.data.playerHero, mm.data.playerExtra.pkValue)
    end
    local sortRules = {
        {
            func = function(v)
                return v.zhandouli
            end,
            isAscending = false
        },
    }
    self.showHeroList = util.powerSort(self.showHeroList, sortRules)
    self.HeroList:removeAllItems()
    for k,v in pairs(self.showHeroList) do
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

        end
    end


end

function ZhuZhenLayer:updateMyZhen( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        
        local flag = true
        for k,v in pairs(self.zhuzhen) do
            if v.id == widget:getTag() then
                flag = false
                table.remove(self.zhuzhen, k)
                break
            end
        end
        if flag then
            if #self.zhuzhen >= 5 then
                gameUtil:addTishi({s = MoGameRet[990603]})
                return
            end

            local heroTab = {}
            heroTab.id = widget:getTag()

            local ishas = self:isHasSkill(heroTab.id)
            if ishas then
                table.insert(self.zhuzhen, heroTab)
            else
                gameUtil:addTishi({s = MoGameRet[990601]})
                return
            end
        end
        

        self:initHeroList()

        self:initSkillList()

    end
end

function ZhuZhenLayer:IsSelect( id )
    for k,v in pairs(self.zhuzhen) do
        if v.id == id then
            return true
        end
    end
    return false
end


function ZhuZhenLayer:canShow( heroTab )
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

function ZhuZhenLayer:isHasSkill(id)

    local ishas = false
    local tab = nil
    for k1,v1 in pairs(mm.data.playerHero) do
        if v1.id == id then
            tab = v1
        end
    end

    local HeroRes = gameUtil.getHeroTab( tab.id )

    for i=1, #HeroRes.SkillsEx do
        local skillId = HeroRes.SkillsEx[i]
        local skillRes = INITLUA:getPassiveResById( skillId )

        local skillLv = 0
        local curSkillTab = nil
        for k,v in pairs(tab.skill) do
            if v.index == i + 1 then
                skillLv = v.lv
                curSkillTab = v
                break
            end
        end

        if MM.EPassvieType.HaloType == skillRes.PassvieType then
            ishas = true
        end

    end

    return ishas
end

function ZhuZhenLayer:initSkillList()
    self.SkillList:removeAllItems()
    if not self.zhuzhen or #self.zhuzhen < 1 then
        self.txt_rules:setVisible(true)
        return
    end
    self.txt_rules:setVisible(false)



    for k,v in pairs(self.zhuzhen) do
        local id = v.id

        local tab = nil
        for k1,v1 in pairs(mm.data.playerHero) do
            if v1.id == id then
                tab = v1
            end
        end

        local HeroRes = gameUtil.getHeroTab( id )


        for i=1, #HeroRes.SkillsEx do
            local skillId = HeroRes.SkillsEx[i]
            local skillRes = INITLUA:getPassiveResById( skillId )
            local skillIconRes = skillRes.sicon

            local skillLv = 0
            local curSkillTab = nil
            for k,v in pairs(tab.skill) do
                if v.index == i + 1 then
                    skillLv = v.lv
                    curSkillTab = v
                    break
                end
            end

            if MM.EPassvieType.HaloType == skillRes.PassvieType then
                local custom_item = ccui.Layout:create()
                local Image_icon
                local t = {}
                t.id = id
                t.HeroRes = HeroRes
                t.skillId = skillId
                t.skillRes = skillRes
                t.skillLv = skillLv
                t.curSkillTab = curSkillTab
                t.index = i
                t.curHero = tab
                if skillLv > 0 then
                    Image_icon = gameUtil.getCSLoaderObj({name = "ZhuZhenjinengItem.csb", type = "CSLoader"})
                    t.Image_icon = Image_icon
                    self:setItemYes(t)
                else
                    Image_icon = gameUtil.getCSLoaderObj({name = "ZhuZhenjinengItem_NO.csb", type = "CSLoader"})
                    t.Image_icon = Image_icon
                    self:setItemNo(t)
                end

                custom_item:setTouchEnabled(true)
                custom_item:addTouchEventListener(handler(self, self.updateMyZhen))
                custom_item:setTag(id)
                custom_item:addChild(Image_icon)
                custom_item:setContentSize(Image_icon:getContentSize())
                self.SkillList:pushBackCustomItem(custom_item)

                
            end

        end

    


    end


end

function ZhuZhenLayer:setItemYes(t)
    local Image_icon = t.Image_icon
    local id = t.id
    local HeroRes = t.HeroRes 
    local skillId = t.skillId 
    local skillRes = t.skillRes 
    local skillLv = t.skillLv
    local curSkillTab = t.curSkillTab
    local index = t.index
    local curHero = t.curHero

    local skillIconRes = skillRes.sicon


    -- local costLv = skillLv+1
    -- if skillLv >= #Skillcost then
    --     costLv = #Skillcost
    -- end
    -- local skillCostRes = INITLUA:getSkillcostRes()
    -- local src = "SkillCost"..(index+1)
    -- Image_icon:getChildByName("Text_jinbi"):setString(skillCostRes[costLv][src])

    Image_icon:getChildByName("Text_jinbi"):setVisible(false)
    Image_icon:getChildByName("Button_shengji"):setVisible(false)
    Image_icon:getChildByName("Image_2"):setVisible(false)


    local descText = skillRes.Desc
    local valueText = skillRes.BPNum + skillRes.BPIncrement * skillLv
    valueText = string.format("%.2f", valueText) 

    local xinlv = curHero.xinlv
    valueText = valueText * (1 + 0.1*xinlv)

    descText = string.gsub(descText, "$s", valueText)

    local str = "(英雄"..xinlv.."星加成"..(1 + 0.1*xinlv).."倍效果)"

    local c, vv = gameUtil.getColor(curHero.jinlv)

    Image_icon:getChildByName("Image_icon"):loadTexture(skillIconRes..".png")
    Image_icon:getChildByName("Text_name"):setString(skillRes.Name)
    Image_icon:getChildByName("Text_level"):setString("Lv:"..curSkillTab.lv)
    Image_icon:getChildByName("Text_miaoshu"):setString(descText)
    Image_icon:getChildByName("Text_Tips"):setString(str)
    Image_icon:getChildByName("Hero_name"):setColor(c)  
    if vv > 0 then
        Image_icon:getChildByName("Hero_name"):setString(HeroRes.Name .. "+" .. vv)
    else
        Image_icon:getChildByName("Hero_name"):setString(HeroRes.Name)
    end

    local touxiang = gameUtil.createTouXiang(curHero)
    local suxinImgTab = {"icon_fs_normal.png","icon_mt_normal.png","icon_dps_normal.png"}
    local suxin = gameUtil.getHeroTab(id).herosuxin
    local suxinImg = suxinImgTab[suxin]
    local pinImgView = ccui.ImageView:create()
    pinImgView:loadTexture("res/UI/"..suxinImg)
    touxiang:addChild(pinImgView)
    -- touxiang:setPositionY(touxiang:getContentSize().height * 0.5)
    pinImgView:setPosition(touxiang:getContentSize().width - 5, touxiang:getContentSize().height - 5)

    touxiang:setAnchorPoint(cc.p(0.5,0.5))
    Image_icon:getChildByName("Hero_icon1"):addChild(touxiang)



end

function ZhuZhenLayer:setItemNo(t)
    local Image_icon = t.Image_icon
    local id = t.id
    local HeroRes = t.HeroRes 
    local skillId = t.skillId 
    local skillRes = t.skillRes 
    local skillLv = t.skillLv
    local curSkillTab = t.curSkillTab
    local index = t.index
    local curHero = t.curHero

    local skillIconRes = skillRes.sicon


    local descText = skillRes.Desc
    local valueText = skillRes.BPNum + skillRes.BPIncrement * skillLv
    valueText = string.format("%.2f", valueText) 
    descText = string.gsub(descText, "$s", valueText)


    local c, vv = gameUtil.getColor(curHero.jinlv)

    Image_icon:getChildByName("Image_1"):setVisible(false)


    Image_icon:getChildByName("Image_icon"):loadTexture(skillIconRes..".png")
    Image_icon:getChildByName("Text_name"):setString(skillRes.Name)
    Image_icon:getChildByName("Text_miaoshu"):setString(descText)
    
    if vv > 0 then
        Image_icon:getChildByName("Hero_name"):setString(HeroRes.Name .. "+" .. vv)
    else
        Image_icon:getChildByName("Hero_name"):setString(HeroRes.Name)
    end

    local touxiang = gameUtil.createTouXiang(curHero)
    local suxinImgTab = {"icon_fs_normal.png","icon_mt_normal.png","icon_dps_normal.png"}
    local suxin = gameUtil.getHeroTab(id).herosuxin
    local suxinImg = suxinImgTab[suxin]
    local pinImgView = ccui.ImageView:create()
    pinImgView:loadTexture("res/UI/"..suxinImg)
    touxiang:addChild(pinImgView)
    -- touxiang:setPositionY(touxiang:getContentSize().height * 0.5)
    pinImgView:setPosition(touxiang:getContentSize().width - 5, touxiang:getContentSize().height - 5)

    touxiang:setAnchorPoint(cc.p(0.5,0.5))
    Image_icon:getChildByName("Hero_icon1"):addChild(touxiang)

end


function ZhuZhenLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "saveFormation" then
            self:saveFormationBack(event.t)
        end
    end
end

function ZhuZhenLayer:onEnter()


end

function ZhuZhenLayer:onExit()
    -- game:dispatchEvent({name = EventDef.UI_MSG, code = "backFightSceneBackup"}) 
end



function ZhuZhenLayer:backCbk( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:removeFromParent()
    end
end

function ZhuZhenLayer:buzhenBtnCbk( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then

        self.BuZhenNewLayer:updateZhuZhen(self.zhuzhen)

        self:removeFromParent()
    end
end

function ZhuZhenLayer:kaizhanBtnCbk( widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then

        print(" &&&&&&&&&&&&&&&&&&&&         ")

        local t = {}
        t.type = self.zhanzhen.type
        t.formationTab = self.zhanzhen.formationTab

        t.helpFormationTab = self.zhuzhen

        print(" &&&&&&&&&&&&&&&&&&&&         "..  json.encode(t))


        mm.req("saveFormation",{getType=1,playerFormation = t, pkType = self.pkType})


        self:removeFromParent()
    end
end




function ZhuZhenLayer:onEnterTransitionFinish()
    
end

function ZhuZhenLayer:onExitTransitionStart()
    
end

function ZhuZhenLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return ZhuZhenLayer