local VSLayer = class("VSLayer", require("app.views.mmExtend.LayerBase"))
VSLayer.RESOURCE_FILENAME = "VSLayer.csb"

function VSLayer:onCreate(param)
    self.scene = param.scene
    self.hisZhandouli = param.zhandouli
    self.hisNickName = param.nickname
    self.diPlayerInfo = param.diPlayerInfo
    self.Node = self:getResourceNode()
    --self.PanelHeibg = self.scene:getChildByName("Scene"):getChildByName("Panel_heibg")
    --self.PanelHeibg:setVisible(true)
    self.Node:getChildByName("Panel_touch"):setVisible(false)
    local size = cc.Director:getInstance():getWinSize()
    local mine = self.Node:getChildByName("Node_mine")
    --mine:setPositionY(size.height*3/4)
    local his = self.Node:getChildByName("Node_his")
    --his:setPositionY(size.height*3/4)

    local ydnode = self.Node:getChildByName("Panel_yindao")
    ydnode:setVisible(false)

    print("yyyyyyyyyyyyyyyyyy     "..param.isluoduoyindao)
    if param.isluoduoyindao and param.isluoduoyindao == 4 then
        self.Node:getChildByName("Panel_yindao"):setVisible(true)

        local anime = gameUtil.createSkeAnmion( {name = "yd"} )
        anime:setAnimation(0, "stand", true)
        ydnode:addChild(anime,10)
        anime:setScaleX(1)
        anime:setScaleY(1)
        anime:setPosition(ydnode:getContentSize().width*0.5, ydnode:getContentSize().height*0.5)
        game.ydnode = ydnode
        ydnode:addTouchEventListener(handler(self, self.ydnodeCall))



    end

    self.mineZhanLi = mine:getChildByName("Text_zhandouli")


    self.anime = gameUtil.createSkeAnmion( {name = "zlsx"} )
    self.anime:setAnimation(0, "stand", false)
    self.mineZhanLi:addChild(self.anime,10)
    self.anime:setPosition(cc.p(50, 15))
    
    self:showAnime()
    his:getChildByName("Text_zhandouli"):setString(gameUtil.dealNumber(self.hisZhandouli)..":战力")

    

    mine:getChildByName("Text_dengji"):setString(gameUtil.getPlayerLv(mm.data.playerinfo.exp or 0))
    gameUtil.setVipLevel( mine:getChildByName("Node_vip"), gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp) )
    if self.diPlayerInfo then
        his:getChildByName("Text_dengji"):setString(gameUtil.getPlayerLv(self.diPlayerInfo.exp or 0))
        gameUtil.setVipLevel( his:getChildByName("Node_vip"), gameUtil.getPlayerVipLv(self.diPlayerInfo.vipexp) )
    else
        his:getChildByName("Text_dengji"):setVisible(false)
        his:getChildByName("Node_vip"):setVisible(false)
    end

    if mm.data.playerinfo.camp == 1 then
        mine:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/L036.png")
        his:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/D038.png")
        mine:getChildByName("Image_camp"):loadTexture("res/UI/bt_qizhilol_select.png")
        his:getChildByName("Image_camp"):loadTexture("res/UI/bt_qizhidota_select.png")
        --mine:getChildByName("Image_di"):loadTexture("res/UI/jm_VSlan.png")
        --his:getChildByName("Image_di"):loadTexture("res/UI/jm_VShong.png")
    else
        mine:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/D038.png")
        his:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/L036.png")
        mine:getChildByName("Image_camp"):loadTexture("res/UI/bt_qizhidota_select.png")
        his:getChildByName("Image_camp"):loadTexture("res/UI/bt_qizhilol_select.png")
        -- mine:getChildByName("Image_di"):loadTexture("res/UI/jm_VShong.png")
        -- his:getChildByName("Image_di"):loadTexture("res/UI/jm_VSlan.png")
    end

    if mm.guaJiReward == nil then
        mine:getChildByName("Text_name"):setString(mm.data.playerinfo.nickname)
        his:getChildByName("Text_name"):setString(self.hisNickName)
    else
        if mm.data.playerinfo.camp == 1 then
            mine:getChildByName("Text_name"):setString(mm.data.playerinfo.qufu.."区-联盟")
            his:getChildByName("Text_name"):setString(self.diPlayerInfo.qufu.."区-部落")
        else
            mine:getChildByName("Text_name"):setString(mm.data.playerinfo.qufu.."区-部落")
            his:getChildByName("Text_name"):setString(self.diPlayerInfo.qufu.."区-联盟")
        end

        local BlessValue = gameUtil.getBlessValue( mm.data.playerExtra.blessTimes ) * 0.01
        BlessValue = (1 + BlessValue)
        --祝福战力增加
        local allZhanli = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue )
        mine:getChildByName("Text_zhandouli"):setString("战力:"..gameUtil.dealNumber(math.floor(allZhanli * BlessValue)))
        his:getChildByName("Text_zhandouli"):setString(gameUtil.dealNumber(math.floor(self.hisZhandouli * BlessValue * math.random(80,120) * 0.01))..":战力")
    end

    mine:getChildByName("Image_touxiang1"):setTouchEnabled(true)
    mine:getChildByName("Image_touxiang1"):addTouchEventListener(handler(self, self.headBtnCbk))

    mine:runAction(cc.MoveBy:create(0.2, cc.p(320, 0)))
    his:runAction(cc.MoveBy:create(0.2, cc.p(-320, 0)))


    -- gameUtil.addArmatureFile("res/Effect/uiEffect/vs/vs.ExportJson")
    -- local VS_play = ccs.Armature:create("vs")
    -- self:addChild(VS_play, 49)
    -- VS_play:setPosition(size.width/2, size.height-40)
    -- VS_play:setScale(3.5)
    -- VS_play:getAnimation():play("vs")

    local VS_play = gameUtil.createSkeAnmion( {name = "vs",scale = 0.7} )
    VS_play:setAnimation(0, "stand", false)
    self:addChild(VS_play, 49)
    VS_play:setPosition(size.width/2, size.height-40)


    gameUtil.playUIEffect( "Fight" )
    
    -- function delete( ... )
    --     --self.PanelHeibg:setVisible(false)
    --     self:removeFromParent()
    -- end
    --self:runAction( cc.Sequence:create(cc.DelayTime:create(10), cc.CallFunc:create(delete)))

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))

    mine:getChildByName("Image_2"):addTouchEventListener(handler(self, self.showForceInfo))

end

function VSLayer:globalEventsListener( event )
    if event.name == EventDef.UI_MSG then
        if event.code == "refreshBlood" then
            self:refreshBlood(event.curABlood, event.initABlood, event.curBBlood, event.initBBlood)
        elseif event.code == "backFightSceneBackup" then
            self:showAnime()
        
        end
    end
end

function VSLayer:headBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        gameUtil.addUserAction(19)    
        mm.pushLayoer( {scene = self.scene, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.PlayerInfoLayer",
                                 resName = "PlayerInfoLayer",params = {}} )
    end
end

function VSLayer:refreshBlood(curABlood, initABlood, curBBlood, initBBlood)
    local color = {
        "res/UI/jm_xuetiao_hong.png" ,
        "res/UI/jm_xuetiao_fen.png",
        "res/UI/jm_xuetiao_cheng.png",
        "res/UI/jm_xuetiao_lv.png",  
        "res/UI/jm_xuetiao_huang.png"}
    local mine = self.Node:getChildByName("Node_mine")
    local his = self.Node:getChildByName("Node_his")
    local myBloodText = mine:getChildByName("Text_xueliang")
    local hisBloodText = his:getChildByName("Text_xueliang")
    local myLoadingBar = mine:getChildByName("LoadingBar")
    local hisLoadingBar = his:getChildByName("LoadingBar")
    local curLeftA = 0
    if curABlood == 0 then
        curLeftA = 0
    else
        curLeftA = curABlood - math.floor(curABlood/(initABlood/5))*(initABlood/5)
        if curLeftA == 0 then
            curLeftA = math.floor(initABlood/5)
        end
    end
    local curLeftB = 0
    if curBBlood == 0 then
        curLeftB = 0
    else
        curLeftB = curBBlood - math.floor(curBBlood/(initBBlood/5))*(initBBlood/5)
        if curLeftB == 0 then
            curLeftB = math.floor(initBBlood/5)
        end
    end
    myBloodText:setString(math.ceil(curABlood).."/"..initABlood)
    hisBloodText:setString(math.ceil(curBBlood).."/"..initBBlood)
    myLoadingBar:loadTexture(color[math.ceil(curABlood/(initABlood/5))])
    hisLoadingBar:loadTexture(color[math.ceil(curBBlood/(initBBlood/5))])
    hisLoadingBar:setPercent(curLeftB*100/(initBBlood/5))
    myLoadingBar:setPercent(curLeftA*100/(initABlood/5))
end

function VSLayer:showAnime( )
    local allZhanli = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue )
    if mm.data.lastZhanLi == nil or allZhanli == mm.data.lastZhanLi then
        self.anime:setVisible(false)
        self.mineZhanLi:setString("战力:"..gameUtil.dealNumber(allZhanli))
    else
        self.mineZhanLi:setString("战力:"..gameUtil.dealNumber(mm.data.lastZhanLi))
        local delayAction1 = cc.DelayTime:create(0.5)
        local delayAction2 = cc.DelayTime:create(0.5)
        local function delAction()
            self.anime:setVisible(true)
            self.anime:setAnimation(0, "stand", false)
            -- self.animation:play(self.resName)
            -- anime:setScale(3.3)
        end
        local function endAction()
            self.anime:setVisible(false)
            self.mineZhanLi:setString("战力:"..gameUtil.dealNumber(allZhanli))
        end

        local sequence = cc.Sequence:create(delayAction1, cc.CallFunc:create(delAction), delayAction2, cc.CallFunc:create(endAction))
        self.mineZhanLi:runAction(sequence)
    end
    mm.data.lastZhanLi = allZhanli
end

function VSLayer:showForceInfo( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then 
        if game.ydnode then
            game.ydnode:setVisible(false)
        else
            mm.pushLayoer( {scene = self.scene, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ForceInfoLayer",
                                 resName = "ForceInfoLayer",params = {}} )
        end
    end
end

function VSLayer:ydnodeCall( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then 
        if game.ydnode then
            game.ydnode:setVisible(false)
            mm.pushLayoer( {scene = self.scene, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ForceInfoLayer",
                                 resName = "ForceInfoLayer",params = {}} )
        end
    end
end


function VSLayer:onEnter()
    if mm.GuildId == 10003 then
        Guide:startGuildById(10004, self.Node:getChildByName("Panel_Guild"))
    end
end

function VSLayer:onExit()
    game.ydnode = nil
end

function VSLayer:onEnterTransitionFinish()
    
end

function VSLayer:onExitTransitionStart()
    
end

function VSLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return VSLayer
