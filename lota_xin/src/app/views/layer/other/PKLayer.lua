local PKLayer = class("PKLayer", require("app.views.mmExtend.LayerBase"))
PKLayer.RESOURCE_FILENAME = "PKLayer.csb"

local closeFuncOrder = require("app.views.mmExtend.closeFuncOrder")

function PKLayer:onCreate(param)
    self.Node = self:getResourceNode()
    self.param = param
    self.ListView = self.Node:getChildByName("ListView_pkItem")

    self.Node:getChildByName("Text_time"):setVisible(false)
    local backBtn = self.Node:getChildByName("Button_back")
    backBtn:addTouchEventListener(handler(self, self.backCbk))
    gameUtil.setBtnEffect(backBtn)

    self.zhanliUPBtn = self.Node:getChildByName("Button_zhanliUP")
    gameUtil.setBtnEffect(self.zhanliUPBtn)
    self.zhanliUPBtn:addTouchEventListener(handler(self, self.zhanliUPCbk))
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))

    if param.hintText ~= nil then
        gameUtil:addTishi({s = param.hintText})
    end
end

function PKLayer:backCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        game:dispatchEvent({name = EventDef.UI_MSG, code = "closePkLayer"})
        mm.popLayer()
    end
end

function PKLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getPKEnterData" then
            self:stopAllActions()
            self:initPkItem(event.t)

            if mm.GuildId == 10201 then
                performWithDelay(self,function( ... )
                    Guide:startGuildById(10202, self.luedduoBtn)
                end, 0.01)
            elseif mm.GuildId == 10301 then
                
                performWithDelay(self,function( ... )
                    Guide:startGuildById(10302, self.sidouBtn)
                end, 0.01)

            elseif mm.GuildId == 10401 then
                
                performWithDelay(self,function( ... )
                    Guide:startGuildById(10402, self.pkBtn)
                end, 0.01)

            elseif mm.GuildId == 10601 then
                
                performWithDelay(self,function( ... )
                    if self.girlBtn then
                        Guide:startGuildById(10602, self.girlBtn)
                    elseif self.beastBtn then
                        Guide:startGuildById(10602, self.beastBtn)
                    else
                        Guide:GuildEnd()
                    end
                end, 0.01)

            end

        elseif event.code == "fiveRefreshNotify" then
            local Text_pkNum = self.Node:getChildByName("Text_pkNum")
            local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
            local tab = INITLUA:getVipInfoByLevel( vipLv )
            Text_pkNum:setString("剩余PK次数："..mm.data.playerExtra.pkTimes.."/"..tab.PKNumMax)
            mm.req("getPKEnterData", {type = 1})
        elseif event.code == "buySomeThing" then
            local Text_pkNum = self.Node:getChildByName("Text_pkNum")
            local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
            local tab = INITLUA:getVipInfoByLevel( vipLv )
            Text_pkNum:setString("剩余PK次数："..mm.data.playerExtra.pkTimes.."/"..tab.PKNumMax)
        end
    end
end

function PKLayer:onEnter()
    mm.req("getPKEnterData", {type = 1})
end

function PKLayer:onExit()
    
end

function PKLayer:initPkItem( pkInfo )
    local Text_pkNum = self.Node:getChildByName("Text_pkNum")
    local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
    local tab = INITLUA:getVipInfoByLevel( vipLv )
    Text_pkNum:setString("剩余PK次数："..mm.data.playerExtra.pkTimes.."/"..tab.PKNumMax)
    mm.data.time.pkTime = pkInfo.time
    self.diren = pkInfo.pkDiren
    -- self.peopleTab = pkInfo.peopleTab or {}
    -- self.stageTab = pkInfo.stageTab or {}
    schedule(self, function()
        if mm.data.time.pkTime ~= 0 then
            self.Node:getChildByName("Text_time"):setString(util.timeFmt(mm.data.time.pkTime))
            self.Node:getChildByName("Text_time"):setVisible(true)
        else
            self.Node:getChildByName("Text_time"):setVisible(false)
        end
    end, 1)
    -- if #self.peopleTab + #self.stageTab == 3 then
    --     self:initThreePkInfo()
    -- else
    mm.data.time.serverTime = pkInfo.serverTime
    local serverTime = os.date("*t", pkInfo.serverTime)
    if serverTime.hour < 5 then
        if serverTime.wday - 1 <= 0 then
            self.weekDay = 7
        else
            self.weekDay = serverTime.wday - 1
        end
    else
        self.weekDay = serverTime.wday
    end
    self:initMorePkInfo()
    -- end
end

function PKLayer:initMorePkInfo( ... )
    if mm.data.playerStage == nil then
        mm.data.playerStage = {}
    end
    local stageResMap = INITLUA:getStageResMap()
    local allShowStage = {{ID = 0, StageSort = 0}}
    for k,v in pairs(stageResMap) do
        if v[1].StagePKVisible == 1 then
            local tab = {}
            -- 判断是否开放
            tab.flag = 0
            for x,y in pairs(v[1].StageOpenDay) do
                if y == self.weekDay then
                    tab.flag = 1
                    break
                end
            end
            local max_proc = 0
            tab.leftCount = v[1].ChapterLimit
            tab.LevelLowerLimit = v[1].LevelLowerLimit
            for p, q in pairs(mm.data.playerStage) do
                if q.chapter == v[1].StageType then
                    max_proc = q.max_proc
                    tab.ID = q.stageId
                    tab.leftCount = v[1].ChapterLimit - q.dailyCount
                    if tab.leftCount < 0 then
                        tab.leftCount = 0
                    end
                end
            end
            tab.StageSort = v[1].StageSort
            for p, q in pairs(v) do
                if q.Stage == max_proc + 1 and q.Nation == mm.data.playerinfo.camp then
                    tab.ID = q.ID
                end
                if tab.LevelLowerLimit > q.LevelLowerLimit then
                    tab.LevelLowerLimit = q.LevelLowerLimit
                end
            end
            table.insert(allShowStage, tab)
        end
    end
    function sort_rule( a, b )
        return a.StageSort < b.StageSort
    end
    table.sort(allShowStage, sort_rule)

    local hang = #allShowStage / 3
    if #allShowStage % 3 ~= 0 then
        hang = hang + 1
    end
    self.ListView:removeAllItems()
    for i=1, hang do
        local pkHang = cc.CSLoader:createNode("pkHang.csb")
        local hang_item = ccui.Layout:create()
        hang_item:addChild(pkHang)
        hang_item:setContentSize(pkHang:getContentSize())
        self.ListView:pushBackCustomItem(hang_item)
        for j = 1, 3 do
            if i == 1 and j == 1 then
                -- 初始化第一个pk玩家
                local custom_item = ccui.Layout:create()
                local PkItem = cc.CSLoader:createNode("PKkapian.csb")
                PkItem:getChildByName("Image_bg"):setSwallowTouches(false)
                PkItem:setAnchorPoint(cc.p(0, 0))
                pkHang:getChildByName("Node_"..j):addChild(custom_item)

                PkItem:getChildByName("Image_bg"):setTouchEnabled(false)
                custom_item:setContentSize(PkItem:getContentSize())
                custom_item:addChild(PkItem)
                custom_item:setTouchEnabled(true)
                custom_item:setTag(0)
                custom_item:addTouchEventListener(handler(self, self.pkDirenCbk))

                if self.diren.playerinfo.camp == 1 then
                    PkItem:getChildByName("Image_bg"):loadTexture("res/icon/jiemian/icon_PKkapian1.png")
                    PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoLOL.png")
                else
                    PkItem:getChildByName("Image_bg"):loadTexture("res/icon/jiemian/icon_PKkapian5.png")
                    PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoDOTA.png")
                end
                PkItem:getChildByName("Image_bg"):getChildByName("Image_jiaobiao"):loadTexture("res/icon/jiemian/icon_PKjiaobiao5.png")
                PkItem:getChildByName("Image_bg"):getChildByName("Text_name"):setString(self.diren.playerinfo.nickname)

                for i=1,3 do
                    PkItem:getChildByName("Image_bg"):getChildByName("Image_"..i):setVisible(false)
                end

                local formation
                for k,v in pairs(self.diren.playerFormation) do
                    if v.type == 1 then
                        formation = v.formationTab
                        break
                    end
                end

                local dizhanli = 0
                if formation then
                    for i=1,#formation do
                        for hk,hv in pairs(self.diren.playerHero) do
                            if hv.id == formation[i].id then
                                formation[i].jinlv = hv.jinlv
                                formation[i].exp = hv.exp
                                formation[i].xinlv = hv.xinlv
                               
                                local zhanli = gameUtil.Zhandouli( hv , self.diren.playerHero, self.diren.pkValue)
                                if zhanli then
                                    dizhanli = dizhanli + zhanli
                                end
                            end
                        end
                    end
                end
                PkItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setVisible(false)
                local curZhanli = gameUtil.getPlayerForce()
                local pkValue = mm.data.playerExtra.pkValue + 1
                if pkValue >= 20 then
                    pkValue = 20
                end
                local addZhanli = gameUtil.getPlayerForce(pkValue) - curZhanli
                PkItem:getChildByName("Image_bg"):getChildByName("Text_shenglv"):setString(MoGameRet[990022]..addZhanli)

                self.luedduoBtn = PkItem:getChildByName("Image_bg")

            else
                if allShowStage[(i-1)*3 + j] ~= nil then
                    local custom_item = ccui.Layout:create()
                    local PkItem = cc.CSLoader:createNode("PKkapian.csb")
                    PkItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setVisible(false)
                    PkItem:getChildByName("Image_bg"):setSwallowTouches(false)
                    PkItem:setAnchorPoint(cc.p(0, 0))
                    pkHang:getChildByName("Node_"..j):addChild(custom_item)

                    PkItem:getChildByName("Image_bg"):setTouchEnabled(false)
                    custom_item:setContentSize(PkItem:getContentSize())
                    custom_item:addChild(PkItem)
                    custom_item:setTag(allShowStage[(i-1)*3 + j].ID)
                    custom_item:setTouchEnabled(true)
                    custom_item:addTouchEventListener(handler(self, self.selectCbk))
                    local stageRes = INITLUA:getStageResById(allShowStage[(i-1)*3 + j].ID)
                    PkItem:getChildByName("Image_bg"):getChildByName("Text_name"):setString(stageRes.StageName)
                    PkItem:getChildByName("Image_bg"):getChildByName("Text_shenglv"):setVisible(false)
                    PkItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setLocalZOrder(100)

                    local dizhanli = 0
                    local enemyHeroSrc
                    for i=1,#stageRes.StageEnemy do
                        local EnemyRes = INITLUA:getMonsterResById(stageRes.StageEnemy[i])
                        dizhanli = dizhanli + EnemyRes.monster_power
                    end
                    local str = ""..dizhanli
                    if dizhanli >= 1000000 then
                        if dizhanli%10000 > 1000 then
                            str = string.format("%.1f", dizhanli/10000).."万"
                        else
                            str = string.format("%.0f", dizhanli/10000).."万"
                        end
                    end
                    if stageRes.StageType ~= 11 then
                        PkItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setVisible(true)
                        schedule(self, function()
                            local time = gameUtil.getLeftTime(mm.data.time.serverTime, allShowStage[(i-1)*3 + j].ID, allShowStage[(i-1)*3 + j].flag)
                            if allShowStage[(i-1)*3 + j].flag == 0 then
                                PkItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setString("开启:"..util.timeFmt(time))
                            else
                                PkItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setString("关闭:"..util.timeFmt(time))
                            end
                        end, 1)


                    else
                        PkItem:getChildByName("Image_bg"):getChildByName("Text_zhanli"):setVisible(false)

                        self.sidouBtn = PkItem:getChildByName("Image_bg")
                    end

                    if stageRes.StageConerType == MM.EStageConerType.SCBattle then -- 挑战
                        PkItem:getChildByName("Image_bg"):loadTexture("res/icon/jiemian/icon_PKkapian3.png")
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_jiaobiao"):loadTexture("res/icon/jiemian/icon_PKjiaobiao3.png")
                    elseif stageRes.StageConerType == MM.EStageConerType.SCGold then -- 金钱
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_jiaobiao"):loadTexture("res/icon/jiemian/icon_PKjiaobiao3.png")
                        PkItem:getChildByName("Image_bg"):loadTexture("res/icon/jiemian/icon_PKkapian2.png")
                    elseif stageRes.StageConerType == MM.EStageConerType.SCExp then -- 经验
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_jiaobiao"):loadTexture("res/icon/jiemian/icon_PKjiaobiao3.png")
                        PkItem:getChildByName("Image_bg"):loadTexture("res/icon/jiemian/icon_PKkapian2.png")
                    elseif stageRes.StageConerType == MM.EStageConerType.SCStar then -- 明星
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_jiaobiao"):loadTexture("res/icon/jiemian/icon_PKjiaobiao1.png")
                        PkItem:getChildByName("Image_bg"):loadTexture("res/icon/jiemian/icon_PKkapian4.png")
                    end
                    if allShowStage[(i-1)*3 + j].flag == 0 then
                        gameUtil.setGRAY(PkItem:getChildByName("Image_bg"):getVirtualRenderer():getSprite())
                        gameUtil.setGRAY(PkItem:getChildByName("Image_bg"):getChildByName("Image_jiaobiao"):getVirtualRenderer():getSprite())
                    else
                        if stageRes.StageType == 3 or stageRes.StageType == 2 then
                            self.pkBtn = PkItem:getChildByName("Image_bg")
                        end
                    end

                    if stageRes.StageType == MM.EStageType.STAD then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoAD.png")
                    elseif stageRes.StageType == MM.EStageType.STAP then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoAP.png")
                    elseif stageRes.StageType == MM.EStageType.STBoy then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoMAN.png")
                    elseif stageRes.StageType == MM.EStageType.STGirl then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoWOMAN.png")
                        if allShowStage[(i-1)*3 + j].flag == 1 then
                            self.girlBtn = PkItem:getChildByName("Image_bg")
                        end
                    elseif stageRes.StageType == MM.EStageType.STBeast then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoIT.png")
                        if allShowStage[(i-1)*3 + j].flag == 1 then
                            self.beastBtn = PkItem:getChildByName("Image_bg")
                        end
                    elseif stageRes.StageType == MM.EStageType.STGold then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoJIN.png")
                    elseif stageRes.StageType == MM.EStageType.STExp then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaoEXP.png")
                    elseif stageRes.StageType == MM.EStageType.STBattle then
                        PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):loadTexture("res/icon/jiemian/icon_PKtubiaodun.png")
                    end
                    if allShowStage[(i-1)*3 + j].flag == 0 then
                        gameUtil.setGRAY(PkItem:getChildByName("Image_bg"):getChildByName("Image_pk"):getVirtualRenderer():getSprite())
                    end
                    local dropEquipTab = {}
                    if mm.data.playerinfo.camp == 1 then-- LOL掉落
                        for i = 1, #stageRes.StageDropLOLEquip do
                            local temp = {}
                            temp.id = stageRes.StageDropLOLEquip[i]
                            temp.pingjia = INITLUA:getEquipByid(temp.id).eq_rate
                            table.insert(dropEquipTab, temp)
                        end
                    else
                        for i = 1, #stageRes.StageDropDOTAEquip do
                            local temp = {}
                            temp.id = stageRes.StageDropDOTAEquip[i]
                            temp.pingjia = INITLUA:getEquipByid(temp.id).eq_rate
                            table.insert(dropEquipTab, temp)
                        end
                    end
                    function sort_rule(a, b)
                        return a.pingjia > b.pingjia
                    end
                    if #dropEquipTab ~= 0 then
                        table.sort(dropEquipTab, sort_rule)
                    end
                    for k=1,3 do
                        local imageView = PkItem:getChildByName("Image_bg"):getChildByName("Image_"..k)
                        if dropEquipTab[k] ~= nil then
                            local sprite = cc.Sprite:create(gameUtil.getEquipIconRes(dropEquipTab[k].id))
                            local pinPathRes = gameUtil.getEquipPinRes(INITLUA:getEquipByid( dropEquipTab[k].id ).Quality)
                            if #pinPathRes > 0 then
                                local pinImgView = ccui.ImageView:create()
                                pinImgView:loadTexture(pinPathRes)
                                sprite:addChild(pinImgView)
                                pinImgView:setAnchorPoint(cc.p(0,0))
                                pinImgView:setPosition(0, 0)
                                pinImgView:setScale(sprite:getContentSize().width/pinImgView:getContentSize().width, sprite:getContentSize().height/pinImgView:getContentSize().height)
                                if allShowStage[(i-1)*3 + j].flag == 0 then
                                    gameUtil.setGRAY(pinImgView:getVirtualRenderer():getSprite())
                                end
                            end

                            if INITLUA:getEquipByid( dropEquipTab[k].id ).EquipType == MM.EEquipType.ET_HunShi then
                                local hunShiTag = cc.Sprite:create("res/UI/icon_hunshi.png")
                                hunShiTag:setAnchorPoint(cc.p(0, 1))
                                hunShiTag:setPosition(cc.p(2, imageView:getContentSize().height-2))
                                hunShiTag:setScale(imageView:getContentSize().width/hunShiTag:getContentSize().width*0.93)
                                imageView:addChild(hunShiTag, 2)
                                if allShowStage[(i-1)*3 + j].flag == 0 then
                                    gameUtil.setGRAY(hunShiTag)
                                end
                            end

                            local equipRes = INITLUA:getEquipByid( dropEquipTab[k].id )
                            if equipRes.EquipType == MM.EEquipType.ET_SuiPian then
                                local suipianPinPathRes = gameUtil.getEquipSuipianPinRes(equipRes.Quality)
                                local suipianTag = cc.Sprite:create(suipianPinPathRes)
                                suipianTag:setPosition(cc.p(20, sprite:getContentSize().height - 15))
                                if allShowStage[(i-1)*3 + j].flag == 0 then
                                    gameUtil.setGRAY(suipianTag)
                                end
                                sprite:addChild(suipianTag)
                            end

                            sprite:setPosition(imageView:getContentSize().width/2, imageView:getContentSize().height/2)
                            
                            sprite:setScale(imageView:getContentSize().width/sprite:getContentSize().width)
                            imageView:addChild(sprite, 1)
                            if allShowStage[(i-1)*3 + j].flag == 0 then
                                gameUtil.setGRAY(imageView:getVirtualRenderer():getSprite())
                                gameUtil.setGRAY(sprite)
                            end
                        else
                            imageView:setVisible(false)
                        end
                    end

                    if allShowStage[(i-1)*3 + j].leftCount > 0 and mm.data.playerExtra.pkTimes > 0 and allShowStage[(i-1)*3 + j].flag == 1 and 
                        gameUtil.getPlayerLv(mm.data.playerinfo.exp) >= allShowStage[(i-1)*3 + j].LevelLowerLimit then
                        gameUtil.addRedPoint(PkItem:getChildByName("Image_bg"), 0.95, 0.95)
                    end

                    -- if #dropEquipTab == 0 then
                    --     local imageView1 = PkItem:getChildByName("Image_bg"):getChildByName("Image_1")
                    --     local image1 = gameUtil.createItemByIcon("res/icon/jiemian/icon_zuanshi.png", stageRes.StageDiamond)
                    --     image:setScale(imageView1:getContentSize().width/image1:getContentSize().width)
                    --     image:setAnchorPoint(cc.p(0, 0))
                    --     imageView1:addChild(image1)
                    --     imageView1:setVisible(true)
                    --     local imageView2 = PkItem:getChildByName("Image_bg"):getChildByName("Image_2")
                    --     local image2 = gameUtil.createItemByIcon("res/icon/jiemian/icon_jinbi.png", stageRes.StageGold)
                    --     image2:setScale(imageView2:getContentSize().width/image2:getContentSize().width)
                    --     image2:setAnchorPoint(cc.p(0, 0))
                    --     imageView2:addChild(image)
                    --     imageView2:setVisible(true)
                    --     if allShowStage[(i-1)*3 + j].flag == 0 then
                    --         gameUtil.setGRAY(image1)
                    --         gameUtil.setGRAY(image2)
                    --     end
                    -- elseif #dropEquipTab == 1 then
                    --     local imageView1 = PkItem:getChildByName("Image_bg"):getChildByName("Image_2")
                    --     local image1 = gameUtil.createItemByIcon("res/icon/jiemian/icon_zuanshi.png", stageRes.StageDiamond)
                    --     image1:setScale(imageView1:getContentSize().width/image1:getContentSize().width)
                    --     image1:setAnchorPoint(cc.p(0, 0))
                    --     imageView1:addChild(image1)
                    --     imageView1:setVisible(true)
                    --     local imageView2 = PkItem:getChildByName("Image_bg"):getChildByName("Image_3")
                    --     local image2 = gameUtil.createItemByIcon("res/icon/jiemian/icon_jinbi.png", stageRes.StageGold)
                    --     image2:setScale(imageView2:getContentSize().width/image2:getContentSize().width)
                    --     image2:setAnchorPoint(cc.p(0, 0))
                    --     imageView2:addChild(image2)
                    --     imageView2:setVisible(true)
                    --     if allShowStage[(i-1)*3 + j].flag == 0 then
                    --         gameUtil.setGRAY(image1)
                    --         gameUtil.setGRAY(image2)
                    --     end
                    -- elseif #dropEquipTab == 2 then
                    --     local imageView = PkItem:getChildByName("Image_bg"):getChildByName("Image_3")
                    --     local image = gameUtil.createItemByIcon("res/icon/jiemian/icon_zuanshi.png", stageRes.StageDiamond)
                    --     image:setScale(imageView:getContentSize().width/image:getContentSize().width)
                    --     image:setAnchorPoint(cc.p(0, 0))
                    --     imageView:addChild(image)
                    --     imageView:setVisible(true)
                    --     if allShowStage[(i-1)*3 + j].flag == 0 then
                    --         gameUtil.setGRAY(image)
                    --     end
                    -- end
                else

                end
            end
        end
    end
end

function PKLayer:pkDirenCbk( widget, touchkey )
    if touchkey == ccui.TouchEventType.ended then

        if gameUtil.isFunctionOpen(closeFuncOrder.PK_CAMP) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        -- 判断等级
        if 22 > gameUtil.getPlayerLv(mm.data.playerinfo.exp) then
            gameUtil:addTishi({p = self, s = "22"..MoGameRet[990020]})
            return
        end

        if mm.data.playerExtra.pkTimes <= 0 then
            gameUtil.showBuyDialog( self, "pk")
            return
        end

        if gameUtil.isFunctionOpen(closeFuncOrder.BUZHEN_ENTER) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_, type = 2, Info = self.diren})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(BuZhenLayer)
        BuZhenLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(BuZhenLayer)
    end
end

function PKLayer:selectCbk( widget, touchkey )
    --widget:setAnchorPoint(cc.p(0.5, 0.5))
    if touchkey == ccui.TouchEventType.ended then

        -- 判断是否开放
        local flag = 0
        local curStageRes = INITLUA:getStageResById(widget:getTag())
        local order = closeFuncOrder.PK_ENTER
        if curStageRes.StageType == MM.EStageType.STAD then
            order = closeFuncOrder.PK_AD
        elseif curStageRes.StageType == MM.EStageType.STAP then
            order = closeFuncOrder.PK_AP
        elseif curStageRes.StageType == MM.EStageType.STGirl then
            order = closeFuncOrder.PK_GIRL
        elseif curStageRes.StageType == MM.EStageType.STBeast then
            order = closeFuncOrder.PK_BEAST
        elseif curStageRes.StageType == MM.EStageType.STBattle then
            order = closeFuncOrder.PK_BATTLE
        end

        if gameUtil.isFunctionOpen(order) == false then
            gameUtil:addTishi({s = MoGameRet[990047]})
            return
        end

        -- for x,y in pairs(curStageRes.StageOpenDay) do
        --     if y == self.weekDay then
        --         flag = 1
        --         break
        --     end
        -- end
        -- if flag == 0 then
        --     local str = ""..MoGameRet[990028][curStageRes.StageOpenDay[1]]
        --     for i=2, #curStageRes.StageOpenDay do
        --         str = str.."、"..MoGameRet[990028][curStageRes.StageOpenDay[i]]
        --     end
        --     gameUtil:addTishi({p = self.scene, s = string.format(MoGameRet[990025], str)})
        --     return
        -- end
        if mm.PkTiShi ~= nil then
            gameUtil:addTishi({p = self.scene, s = MoGameRet[990018]})
            return
        end

        local StageDetailLayer = require("src.app.views.layer.StageDetailLayer").new({app = self.app, stageId = widget:getTag()})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(StageDetailLayer)
    elseif touchkey == ccui.TouchEventType.began then
        --widget:getChildByName("pkItem"):setScale(0.90)
        --widget:getChildByName("pkItem"):setScale(0.90)
    elseif touchkey == ccui.TouchEventType.canceled then
        --widget:getChildByName("pkItem"):setScale(1)
        --widget:getChildByName("pkItem"):setScale(1)
    end
end

function PKLayer:zhanliUPCbk( widget, touchkey )
    if touchkey == ccui.TouchEventType.ended then
        local heroId = gameUtil.GetLevelMaxHeroId()
        gameUtil:goToSomeWhere( self, "HeroLayer", {app = self.param.app, heroId = heroId, LayerTag = 1})
    end
end

function PKLayer:onEnterTransitionFinish()

end

function PKLayer:onExitTransitionStart()
    
end

function PKLayer:onCleanup()
    self:stopAllActions()
    self:clearAllGlobalEventListener()
end

return PKLayer