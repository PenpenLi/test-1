local StageDetailLayer = class("StageDetailLayer", require("app.views.mmExtend.LayerBase"))
StageDetailLayer.RESOURCE_FILENAME = "GuanqiaLayer.csb"
local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")

function StageDetailLayer:onCreate(param)
    self.app = param.app
    self.stageId = param.stageId

    self.Node = self:getResourceNode()

    local backBtn = self.Node:getChildByName("Button_back")
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(backBtn)
    self.item_reward = self.Node:getChildByName("ScrollView_stage"):getChildByName("Node_bg"):getChildByName("Node_reward")
    self.item_reward:setVisible(false)

    self.itemrewardPl = self.Node:getChildByName("ScrollView_stage"):getChildByName("Node_bg"):getChildByName("Panel_diaoluo")

    

    local stageTab = INITLUA:getStageResById(self.stageId)
    print("stageTab.StageType "..stageTab.StageType)
    if stageTab.StageType == MM.EStageType.STBattle then
        self.Image_buttom = self.Node:getChildByName("Image_buttom")
        self.Image_buttom:setVisible(false)
        self.Copy_Bottom = self.Node:getChildByName("Copy_Bottom")
        self.Copy_Bottom:setVisible(true)
        self.isSTBattle = true

        
        self.tiaozhanBtn = self.Node:getChildByName("Copy_Bottom"):getChildByName("Button_Fight")
        self.textZhanLi = self.Node:getChildByName("Copy_Bottom"):getChildByName("Text_zhanli")
        gameUtil.setBtnEffect(self.tiaozhanBtn)
        self.tiaozhanBtn:addTouchEventListener(handler(self, self.tiaozhanBtnCbk))
        self.tiaozhanBtn:setTag(0)
        game.tiaozhanPkSDPl = self.tiaozhanBtn

        local hasSaoJuan = gameUtil.getSaoDangJuanNum()
        self.saoDangNum = self.Node:getChildByName("Copy_Bottom"):getChildByName("Panel_Saodang"):getChildByName("Bg_Num"):getChildByName("Text_Num")
        self.saoDangNum:setString(hasSaoJuan)
        
        self.saoDangBtn = self.Node:getChildByName("Copy_Bottom"):getChildByName("Panel_Saodang"):getChildByName("Bg_Num"):getChildByName("Button_Add")
        self.saoDangBtn:addTouchEventListener(handler(self, self.buySdBtnCbk))

    else
        self.isSTBattle = false
        self.Image_buttom = self.Node:getChildByName("Image_buttom")
        self.Image_buttom:setVisible(true)
        self.Copy_Bottom = self.Node:getChildByName("Copy_Bottom")
        self.Copy_Bottom:setVisible(false)

        self.tiaozhanBtn = self.Node:getChildByName("Image_buttom"):getChildByName("Button_begin")
        self.textZhanLi = self.Node:getChildByName("Image_buttom"):getChildByName("Text_zhanli")
        
        gameUtil.setBtnEffect(self.tiaozhanBtn)
        self.tiaozhanBtn:addTouchEventListener(handler(self, self.tiaozhanBtnCbk))
        self.tiaozhanBtn:setTag(0)
        game.tiaozhanPkSDPl = self.tiaozhanBtn


    end
    


    -- self:InitStageInfo()

    self:initData(self.stageId)
    self:updateStageInfo(self.data.stageRes.Chapter)


    local stageRes = self.listTab.stageRes

    self.leftNum = stageRes.ChapterLimit
    for k,v in pairs(mm.data.playerStage) do
        if v.chapter == stageRes.StageType then
            if v.dailyCount <= stageRes.ChapterLimit then
                self.leftNum = stageRes.ChapterLimit - v.dailyCount + (v.extraTime or 0)
            else
                self.leftNum = (v.extraTime or 0)
            end
        end
    end
    if self.leftNum < 0 then
        self.leftNum = 0
    end

    if not self.isSTBattle then
        self.Node:getChildByName("Image_buttom"):getChildByName("Text_num"):setString(MoGameRet[990026]..self.leftNum.."/"..stageRes.ChapterLimit)
        game.zhanliPkSDPl = self.Node:getChildByName("Image_buttom"):getChildByName("Panel_zhanli")
    end

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function StageDetailLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "buySomeThing" then
            local stageRes = INITLUA:getStageResById(self.stageId)
            self.leftNum = stageRes.ChapterLimit
            for k,v in pairs(mm.data.playerStage) do
                if v.chapter == stageRes.StageType then
                    if v.dailyCount <= stageRes.ChapterLimit then
                        self.leftNum = stageRes.ChapterLimit - v.dailyCount + (v.extraTime or 0)
                    else
                        self.leftNum = (v.extraTime or 0)
                    end
                    break
                end
            end
            if self.leftNum < 0 then
                self.leftNum = 0
            end
            if not self.isSTBattle then
                self.Node:getChildByName("Image_buttom"):getChildByName("Text_num"):setString(MoGameRet[990026]..self.leftNum.."/"..stageRes.ChapterLimit)
            end

            if self.isSTBattle then
                local hasSaoJuan = gameUtil.getSaoDangJuanNum()
                self.saoDangNum:setString(hasSaoJuan)
            end


        elseif event.code == "saodang" then
            local saoDangJiangli = require("src.app.views.layer.saoDangJiangli").new({})
            self:addChild(saoDangJiangli, 100)
            if self.isSTBattle then
                local hasSaoJuan = gameUtil.getSaoDangJuanNum()
                self.saoDangNum:setString(hasSaoJuan)
            end
        end
    end
end

function StageDetailLayer:onEnter()
    if mm.GuildId == 10302 then
            Guide:startGuildById(10303, self.itemrewardPl)
    elseif mm.GuildId == 10402 then
            Guide:startGuildById(10403, self.itemrewardPl)
    elseif mm.GuildId == 10602 then
        Guide:startGuildById(10603, self.itemrewardPl)

    end

    if mm.GuildId == 80005 then

        Guide:startGuildById(80006, game.tiaozhanPkSDPl)
    end
end

function StageDetailLayer:onExit()
    
end

function StageDetailLayer:onEnterTransitionFinish()
    
end

function StageDetailLayer:onExitTransitionStart()
    
end

function StageDetailLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function StageDetailLayer:InitStageInfo()
    local stageRes = INITLUA:getStageResById(self.stageId)
    self.Node:getChildByName("Text_title"):setString(stageRes.ChapterName)
    local StageResMap = INITLUA:getStageResMapByType(stageRes.StageType)
    local maxStage = 0
    for k,v in pairs(StageResMap) do
        if v.Stage > maxStage then
            maxStage = v.Stage
        end
    end
    self.StageInfoTab = {}
    local max_proc = 0
    for k,v in pairs(mm.data.playerStage) do
        if v.chapter == stageRes.StageType then
            max_proc = v.max_proc
            break
        end
    end
    local limitX = max_proc - max_proc%10
    local limitY = limitX + 10
    for k,v in pairs(StageResMap) do
        if max_proc == maxStage then
            limitY = maxStage
            limitX = limitY - 10
        end
        if (mm.data.playerinfo.camp == v.Nation and v.Stage > limitX and v.Stage <= limitY) then
            -- 只显示本阵营能打的关卡
            local i = v.Stage%10
            if i == 0 then
                i = 10
            end
            self.StageInfoTab[v.ID] = v
            self.Node_bg = self.Node:getChildByName("ScrollView_stage"):getChildByName("Node_bg")
            self.Node_bg:getChildByName("Button_"..i):getChildByName("Text_StageName"):setString(v.StageName)
            self.Node_bg:getChildByName("Button_"..i):addTouchEventListener(handler(self, self.stageBtnCbk))
            self.Node_bg:getChildByName("Button_"..i):setTag(v.ID)
            self.Node_bg:getChildByName("Button_"..i):setScale(0.85)
            if v.Stage <= max_proc then
                self.Node_bg:getChildByName("Button_"..i):loadTextureNormal("res/UI/bt_ditu_disable.png")
                self.Node_bg:getChildByName("Button_"..i):loadTexturePressed("res/UI/bt_ditu_disable_select.png")
                self.Node_bg:getChildByName("Button_"..i):loadTextureDisabled("res/UI/bt_ditu_disable_select.png")
            elseif v.Stage == max_proc + 1 then
                self.Node_bg:getChildByName("Button_"..i):loadTextureNormal("res/UI/bt_ditu_normal.png")
                self.Node_bg:getChildByName("Button_"..i):loadTexturePressed("res/UI/bt_ditu_select.png")
                self.Node_bg:getChildByName("Button_"..i):loadTextureDisabled("res/UI/bt_ditu_select.png")
                self:stageBtnCbk(self.Node_bg:getChildByName("Button_"..i), ccui.TouchEventType.ended)
            else
                self.Node_bg:getChildByName("Button_"..i):loadTextureNormal("res/UI/bt_ditusuo_normal.png")
                self.Node_bg:getChildByName("Button_"..i):loadTexturePressed("res/UI/bt_ditusuo_select.png")
                self.Node_bg:getChildByName("Button_"..i):loadTextureDisabled("res/UI/bt_ditusuo_select.png")
            end
        else

        end
    end


    self.Node:getChildByName("Button_11"):addTouchEventListener(handler(self, self.stageListBtnCbk))
    self.listTab = {} 
    self.listTab.max_proc = max_proc
    self.listTab.limitX = limitX
    self.listTab.limitY = limitY
    self.listTab.stageRes = stageRes
    self.listTab.stageId = stageId
    self.listTab.StageResMap = StageResMap

end

function StageDetailLayer:initData( stageId )
    local stageRes = INITLUA:getStageResById(stageId)
    local StageResMap = INITLUA:getStageResMapByType(stageRes.StageType)
    local max_proc = 0
    for k,v in pairs(mm.data.playerStage) do
        if v.chapter == stageRes.StageType then
            max_proc = v.max_proc
            break
        end
    end


    local maxStage = 0
    for k,v in pairs(StageResMap) do
        if v.Stage > maxStage then
            maxStage = v.Stage
        end
    end
    
    local tab = {}
    local max = 1
    for k,v in pairs(StageResMap) do
        local zhang = v.Chapter
        local jie = v.Stage
        tab[zhang] = tab[zhang] or {}
        if mm.data.playerinfo.camp == v.Nation then
            table.insert(tab[zhang], v)
        end
        if v.Chapter > max then
            max = v.Chapter
        end
    end
    local useTab = {}
    for i=1,max do
        if tab[i] then
            table.insert(useTab, tab[i])
        end
    end

    -- local hasNum = 0
    -- for i=1,#useTab do

    --     local allt = #useTab[i]
    --     local jindu = 0
    --     if useTab[i][1].Chapter == stageRes.Chapter then
    --         jindu = max_proc - hasNum
    --     elseif useTab[i][1].Chapter < stageRes.Chapter then
    --         jindu = allt
    --     end

    --     hasNum = hasNum + allt
    --     -- useTab[i].jindu = jindu

    -- end

    self.data = {}
    self.data.stageRes = stageRes
    self.data.StageResMap = StageResMap
    self.data.max_proc = max_proc
    self.data.tab = tab
    self.data.useTab = useTab
    self.data.maxStage = maxStage

end

function StageDetailLayer:updateStageInfo(zhang)
    local curTab = self.data.tab[zhang]
    local stageRes = self.data.stageRes
    self.Node:getChildByName("Text_title"):setString(curTab[1].ChapterName)
    
    local StageResMap = self.data.StageResMap
    local maxStage = self.data.maxStage
    
    self.StageInfoTab = {}
    
    for k,v in pairs(curTab) do
        if (mm.data.playerinfo.camp == v.Nation) then
            -- 只显示本阵营能打的关卡
            local i = v.Stage%10
            if i == 0 then
                i = 10
            end
            self.StageInfoTab[v.ID] = v
            self.Node_bg = self.Node:getChildByName("ScrollView_stage"):getChildByName("Node_bg")
            self.Node_bg:getChildByName("Button_"..i):getChildByName("Text_StageName"):setString(v.StageName)
            self.Node_bg:getChildByName("Button_"..i):addTouchEventListener(handler(self, self.stageBtnCbk))
            self.Node_bg:getChildByName("Button_"..i):setTag(v.ID)
            self.Node_bg:getChildByName("Button_"..i):setScale(0.85)
            if v.Stage <= self.data.max_proc then
                self.Node_bg:getChildByName("Button_"..i):loadTextureNormal("res/UI/bt_ditu_disable.png")
                self.Node_bg:getChildByName("Button_"..i):loadTexturePressed("res/UI/bt_ditu_disable_select.png")
                self.Node_bg:getChildByName("Button_"..i):loadTextureDisabled("res/UI/bt_ditu_disable_select.png")
            elseif v.Stage == self.data.max_proc + 1 then
                self.Node_bg:getChildByName("Button_"..i):loadTextureNormal("res/UI/bt_ditu_normal.png")
                self.Node_bg:getChildByName("Button_"..i):loadTexturePressed("res/UI/bt_ditu_select.png")
                self.Node_bg:getChildByName("Button_"..i):loadTextureDisabled("res/UI/bt_ditu_select.png")
                self:stageBtnCbk(self.Node_bg:getChildByName("Button_"..i), ccui.TouchEventType.ended)
            else
                self.Node_bg:getChildByName("Button_"..i):loadTextureNormal("res/UI/bt_ditusuo_normal.png")
                self.Node_bg:getChildByName("Button_"..i):loadTexturePressed("res/UI/bt_ditusuo_select.png")
                self.Node_bg:getChildByName("Button_"..i):loadTextureDisabled("res/UI/bt_ditusuo_select.png")
            end

            

        else

        end
    end

    if (zhang  < self.data.stageRes.Chapter) then
        self:stageBtnCbk(self.Node_bg:getChildByName("Button_1"), ccui.TouchEventType.ended)
    end


    self.Node:getChildByName("Button_11"):addTouchEventListener(handler(self, self.stageListBtnCbk))
    self.listTab = {} 
    self.listTab.max_proc = self.data.max_proc
    self.listTab.stageRes = stageRes
    self.listTab.stageId = stageId
    self.listTab.StageResMap = StageResMap

    if self.data.stageRes.StageType == MM.EStageType.STBattle then
        self.Node:getChildByName("Button_11"):setVisible(true)
        self.Node:getChildByName("Image_buttom"):getChildByName("Text_num"):setVisible(false)
    else
        self.Node:getChildByName("Button_11"):setVisible(false)
        self.Node:getChildByName("Image_buttom"):getChildByName("Text_num"):setVisible(true)
    end

    
    

    if self.data.tab[zhang - 1] and #self.data.tab[zhang - 1] > 0 then 
        self.Node:getChildByName("Button_left"):addTouchEventListener(handler(self, self.toStageIdBtnCbk))
        self.Node:getChildByName("Button_left"):setVisible(true)
        self.Node:getChildByName("Button_left"):setTag(zhang - 1)
    else
        self.Node:getChildByName("Button_left"):setVisible(false)
    end

    if (zhang  < self.data.stageRes.Chapter) and self.data.tab[zhang + 1] and #self.data.tab[zhang + 1] > 0 then
        self.Node:getChildByName("Button_right"):addTouchEventListener(handler(self, self.toStageIdBtnCbk))
        self.Node:getChildByName("Button_right"):setVisible(true)
        self.Node:getChildByName("Button_right"):setTag(zhang + 1)
    else
        self.Node:getChildByName("Button_right"):setVisible(false)
    end

end

function StageDetailLayer:toStageIdBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local tag = widget:getTag()
        self:updateStageInfo(tag)
    end

end

function StageDetailLayer:stageListBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local stageListLayer = require("src.app.views.layer.stageListLayer").new({pLayer = self, listTab = self.listTab})
        self:addChild(stageListLayer, MoGlobalZorder[2000002])
    end

end

function StageDetailLayer:stageBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        -- 奖励界面
        self.item_reward:setVisible(true)
        local stageRes = self.StageInfoTab[widget:getTag()]
        self.tiaozhanBtn:setTag(stageRes.ID) -- 将挑战按钮的Tag设置为当前关卡的ID

        if self.isSTBattle then
            local state = self:getStageState( stageRes )
            if state == 1 then
                self.tiaozhanBtn:setTitleText("扫荡")
            else
                self.tiaozhanBtn:setTitleText("挑战")
            end
        end

        local dizhanli = 0
        for i=1,#stageRes.StageEnemy do
            local EnemyRes = INITLUA:getMonsterResById(stageRes.StageEnemy[i])
            dizhanli = dizhanli + EnemyRes.monster_power
        end

        self.textZhanLi:setString("战力:"..gameUtil.dealNumber( dizhanli ))
        -- 获取要显示的掉落
        local dropEquipTab = {}
        if mm.data.playerinfo.camp == 1 then -- LOL掉落
            for i = 1, #stageRes.StageDropLOLEquip do
                local temp = {}
                temp.id = stageRes.StageDropLOLEquip[i]
                temp.pingjia = INITLUA:getEquipByid(temp.id).eq_rate
                temp.type = 1
                table.insert(dropEquipTab, temp)
            end
            for i = 1, #stageRes.StageDropLOLItem do
                local temp = {}
                temp.id = stageRes.StageDropLOLItem[i]
                temp.pingjia = INITLUA:getItemByid(temp.id).eq_rate
                temp.type = 2
                table.insert(dropEquipTab, temp)
            end
        else
            for i = 1, #stageRes.StageDropDOTAEquip do
                local temp = {}
                temp.id = stageRes.StageDropDOTAEquip[i]
                temp.type = 1
                temp.pingjia = INITLUA:getEquipByid(temp.id).eq_rate
                table.insert(dropEquipTab, temp)
            end
            for i = 1, #stageRes.StageDropDOTAItem do
                local temp = {}
                temp.id = stageRes.StageDropDOTAItem[i]
                temp.pingjia = INITLUA:getItemByid(temp.id).eq_rate
                temp.type = 2
                table.insert(dropEquipTab, temp)
            end
        end
        function sort_rule(a, b)
            if a.type == b.type then
                return a.pingjia > b.pingjia
            else
                return a.type < b.type
            end
        end
        if #dropEquipTab ~= 0 then
            table.sort(dropEquipTab, sort_rule)
        end

        for i=1,5 do
            local imageView = self.item_reward:getChildByName("Image_"..i)
            imageView:removeAllChildren()
            if dropEquipTab[i] ~= nil then
                local dropRes
                if dropEquipTab[i].type == 1 then
                    dropRes = INITLUA:getEquipByid(dropEquipTab[i].id)
                    if dropRes.EquipType == MM.EEquipType.ET_HunShi then
                        imageView:setTouchEnabled(true)
                        imageView:setTag(dropEquipTab[i].id)
                        imageView:addTouchEventListener(handler(self, self.hunshiCbk))
                    else
                        imageView:setTouchEnabled(true)
                        imageView:setTag(dropEquipTab[i].id)
                        imageView:addTouchEventListener(handler(self, self.equipCbk))
                    end
                else
                    dropRes = INITLUA:getItemByid(dropEquipTab[i].id)
                    imageView:setTouchEnabled(true)
                    imageView:setTag(dropEquipTab[i].id)
                    imageView:addTouchEventListener(handler(self, self.itemCbk))
                end
                local sprite = cc.Sprite:create( (dropRes.item_res or dropRes.eq_res)..".png" )
                local pinPathRes = gameUtil.getEquipPinRes( dropRes.Quality )
                if #pinPathRes > 0 then
                    local pinImgView = ccui.ImageView:create()
                    pinImgView:loadTexture(pinPathRes)
                    sprite:addChild(pinImgView)
                    pinImgView:setAnchorPoint(cc.p(0,0))
                    pinImgView:setPosition(0, 0)
                    pinImgView:setScale(sprite:getContentSize().width/pinImgView:getContentSize().width, sprite:getContentSize().height/pinImgView:getContentSize().height)
                    -- if flag == 1 then
                    --     gameUtil.setGRAY(pinImgView:getVirtualRenderer():getSprite())
                    -- end
                end

                if dropRes.EquipType and dropRes.EquipType == MM.EEquipType.ET_HunShi then
                    local hunShiTag = cc.Sprite:create("res/UI/icon_hunshi.png")
                    hunShiTag:setAnchorPoint(cc.p(0, 1))
                    hunShiTag:setPosition(cc.p(2, imageView:getContentSize().height-2))
                    hunShiTag:setScale(imageView:getContentSize().width/hunShiTag:getContentSize().width*0.93)
                    imageView:addChild(hunShiTag, 2)
                    -- if flag == 1 then
                    --     gameUtil.setGRAY(hunShiTag)
                    -- end
                end

                if dropRes.EquipType and dropRes.EquipType == MM.EEquipType.ET_SuiPian then
                    local suipianPinPathRes = gameUtil.getEquipSuipianPinRes(dropRes.Quality)
                    local suipianTag = cc.Sprite:create(suipianPinPathRes)
                    suipianTag:setPosition(cc.p(20, sprite:getContentSize().height - 15))
                    sprite:addChild(suipianTag)
                end

                sprite:setPosition(imageView:getContentSize().width/2, imageView:getContentSize().height/2)
                
                sprite:setScale(imageView:getContentSize().width/sprite:getContentSize().width)
                imageView:addChild(sprite, 1)
                if flag == 1 then
                    gameUtil.setGRAY(imageView:getVirtualRenderer():getSprite())
                    gameUtil.setGRAY(sprite)
                end
                imageView:setVisible(true)
            else
                imageView:setVisible(false)
            end
        end

        -- 设置按钮选中状态
        if self.selectButton ~= nil then
            self.selectButton:setEnabled(true)
            self.selectButton:setBright(true)
        end
        self.selectButton = widget
        self.selectButton:setEnabled(false)
        self.selectButton:setBright(false)
    end
end

function StageDetailLayer:equipCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        local GoodsShowLayer = require("src.app.views.layer.GoodsShowLayer").new({id = id, type = 1})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(GoodsShowLayer, MoGlobalZorder[2000002])
        GoodsShowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(GoodsShowLayer)
    end
end

function StageDetailLayer:hunshiCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        local GoodsShowLayer = require("src.app.views.layer.GoodsShowLayer").new({id = id, type = 2})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(GoodsShowLayer, MoGlobalZorder[2000002])
        GoodsShowLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(GoodsShowLayer)
    end
end

function StageDetailLayer:itemCbk( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then
        local tag = widget:getTag()
        local itemRes = INITLUA:getItemByid(tag)
        if itemRes.GiftID ~= 0 then
            --gameUtil:addTishi({s = "礼包:"..itemRes.GiftID})
            local LiBaoLayer = require("src.app.views.layer.LiBaoLayer").new({id = itemRes.ID})
            local size  = cc.Director:getInstance():getWinSize()
            mm.scene():addChild(LiBaoLayer, MoGlobalZorder[2999999])
            LiBaoLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(LiBaoLayer)
        else
            local id = tag
            local GoodsShowLayer = require("src.app.views.layer.GoodsShowLayer").new({id = id, type = 3})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(GoodsShowLayer, MoGlobalZorder[2000002])
            GoodsShowLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(GoodsShowLayer)
        end
    end
end

function StageDetailLayer:buySdBtnCbk( widget, touchkey )
    if touchkey == ccui.TouchEventType.ended then
        local tab = {}
        tab.OnlyBuy = true
        local Saodanggoumai = require("src.app.views.layer.Saodanggoumai").new(tab)
        self:addChild(Saodanggoumai, 100)
    end
end

function StageDetailLayer:tiaozhanBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        print("tiaozhanBtnCbk       curStageRes.ID ")
        if gameUtil.isFunctionOpen(closeFuncOrder.BUZHEN_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end
        -- 判断该关卡是否可以挑战
        if widget:getTag() == 0 then
            gameUtil:addTishi({p = self, s = MoGameRet[990021]})
            return
        end

        -- if mm.GuildId ~= 10305 and mm.GuildId ~= 10405 and  mm.GuildId ~= 10605 then
        --     if mm.data.playerExtra.pkTimes <= 0 then
        --         gameUtil.showBuyDialog( self, "pk")
        --         return
        --     end
        -- end


        
        if self.leftNum <= 0 then
            gameUtil.showBuyDialog( self, widget:getTag())
            return
        end
        local curStageRes = self.StageInfoTab[widget:getTag()]
        
        -- 判断等级
        if curStageRes.LevelLowerLimit > gameUtil.getPlayerLv(mm.data.playerinfo.exp) then
            gameUtil:addTishi({p = self, s = curStageRes.LevelLowerLimit..MoGameRet[990020]})
            return
        end

        print("tiaozhanBtnCbk       curStageRes.ID "..curStageRes.ID)
        local state = self:getStageState( curStageRes )
        print("tiaozhanBtnCbk       state "..state)
        print("tiaozhanBtnCbk       self.listTab.max_proc "..self.listTab.max_proc)


        if self.isSTBattle then
            if state == 1 then
                self.tiaozhanBtn:setTitleText("扫荡")
                local hasSaoJuan = gameUtil.getSaoDangJuanNum()
                
                if hasSaoJuan <= 0 then
                    local tab = {}
                    tab.stageId = curStageRes.ID
                    local Saodanggoumai = require("src.app.views.layer.Saodanggoumai").new(tab)
                    self:addChild(Saodanggoumai, 100)
                else
                    local tab = {}
                    tab.stageId = curStageRes.ID
                    local Saodang = require("src.app.views.layer.Saodang").new(tab)
                    self:addChild(Saodang, 100)
                end
            elseif state == 2 then
                if (mm.diFangZhen and widget:getTag() == mm.diFangZhen.stageId) or (mm.curDiZhen and mm.curDiZhen.stageId == widget:getTag()) then
                    gameUtil:addTishi({s = MoGameRet[990066]})
                    return
                end
                local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_, type = 1, Info = widget:getTag()})
                local size  = cc.Director:getInstance():getWinSize()
                self:addChild(BuZhenLayer)
                BuZhenLayer:setContentSize(cc.size(size.width, size.height))
                ccui.Helper:doLayout(BuZhenLayer)
            elseif state == 3 then
                gameUtil:addTishi({p = self, s = MoGameRet[990019]})
            end
        else
            if (mm.diFangZhen and widget:getTag() == mm.diFangZhen.stageId) or (mm.curDiZhen and mm.curDiZhen.stageId == widget:getTag()) then
                gameUtil:addTishi({s = MoGameRet[990066]})
                return
            end

            if state == 3 then
                return
            end
            local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_, type = 1, Info = widget:getTag()})
            local size  = cc.Director:getInstance():getWinSize()
            self:addChild(BuZhenLayer)
            BuZhenLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(BuZhenLayer)
        end
        
        
        
    end
end

function StageDetailLayer:getStageState( stageTab )
    for k,v in pairs(mm.data.playerStage) do
        if stageTab.StageType == v.chapter then
            
            if stageTab.Stage > v.max_proc + 1 then
                return 3
            elseif stageTab.Stage == v.max_proc + 1 then
                return 2
            else
                return 1
            end
        end
    end

    if stageTab.Stage == 1 then
        return 2
    else
        return 3
    end

    
end

function StageDetailLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        -- self:removeFromParent()
        mm:popLayer()
    end
end

return StageDetailLayer