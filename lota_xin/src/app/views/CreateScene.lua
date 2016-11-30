if not json then
    require "cocos.cocos2d.json"
end
if not util then
    require "util"
end

game = require("app.models.game")
game:ctor()

local CreateScene = class("CreateScene", cc.load("mvc").ViewBase)
CreateScene.RESOURCE_FILENAME = "CreateScene.csb"

mm.data.time = mm.data.time or {}

function CreateScene:onCreate()
    self.randoming = false
    self.scene = self:getChildByName("Scene")

    -- dota按钮
    -- self.dotaBtn = self.scene:getChildByName("dotaBtn")
    -- self.dotaBtn:addTouchEventListener(handler(self, self.dotaBtnCbk))

    local Node_dota = self.scene:getChildByName("Node_dota")

    local anime = gameUtil.createSkeAnmion( {name = "dotazyqz",scale = 0.7} )
    anime:setAnimation(0, "stand", true)
    Node_dota:addChild(anime,-10)
    anime:setPosition(0, -15)

    -- gameUtil.addArmatureFile("res/Effect/uiEffect/dotazyqz/dotazyqz.ExportJson")
    -- local anime = ccs.Armature:create("dotazyqz")
    -- local animation = anime:getAnimation()
    -- Node_dota:addChild(anime,-10)
    -- animation:play("dotazyqz")
    -- anime:setScale(3.3)

    local anime = gameUtil.createSkeAnmion( {name = "dotazy",scale = 0.7} )
    anime:setAnimation(0, "stand", true)
    Node_dota:addChild(anime,-10)
    anime:setPosition(0, 5)

    -- gameUtil.addArmatureFile("res/Effect/uiEffect/dotazy/dotazy.ExportJson")
    -- local anime = ccs.Armature:create("dotazy")
    -- local animation = anime:getAnimation()
    -- Node_dota:addChild(anime,-10)
    -- --anime:setPosition(vipImg:getContentSize().width*0.5,vipImg:getContentSize().height*0.5)
    -- animation:play("dotazy")
    -- anime:setScale(3.3)

    anime:setVisible(false)
    self.dotaZy = anime
    Node_dota:getChildByName("Panel_dota"):addTouchEventListener(handler(self, self.dotaBtnCbk))


    -- lol按钮
    -- self.lolBtn = self.scene:getChildByName("lolBtn")
    -- self.lolBtn:addTouchEventListener(handler(self, self.lolBtnCbk))
    local Node_lol = self.scene:getChildByName("Node_lol")
    
    local anime = gameUtil.createSkeAnmion( {name = "lolzyqz",scale = 0.7} )
    anime:setAnimation(0, "stand", true)
    Node_lol:addChild(anime,-10)

    -- gameUtil.addArmatureFile("res/Effect/uiEffect/lolzyqz/lolzyqz.ExportJson")
    -- local anime = ccs.Armature:create("lolzyqz")
    -- local animation = anime:getAnimation()
    -- Node_lol:addChild(anime,-10)
    -- --anime:setPosition(vipImg:getContentSize().width*0.5,vipImg:getContentSize().height*0.5)
    -- animation:play("lolzyqz")
    -- anime:setScale(3.3)
    
    local anime = gameUtil.createSkeAnmion( {name = "lolzy",scale = 0.7} )
    anime:setAnimation(0, "stand", true)
    Node_lol:addChild(anime,-10)

    -- gameUtil.addArmatureFile("res/Effect/uiEffect/lolzy/lolzy.ExportJson")
    -- local anime = ccs.Armature:create("lolzy")
    -- local animation = anime:getAnimation()
    -- Node_lol:addChild(anime,-10)
    -- --anime:setPosition(vipImg:getContentSize().width*0.5,vipImg:getContentSize().height*0.5)
    -- animation:play("lolzy")
    -- anime:setScale(3.3)
    
    -- local anime = gameUtil.createSkeAnmion( {name = "lolzy",scale = 1} )
    -- anime:setAnimation(0, "stand", true)
    -- Node_lol:addChild(anime,-10)

    self.lolZy = anime
    Node_lol:getChildByName("Panel_lol"):addTouchEventListener(handler(self, self.lolBtnCbk))


    -- 随机按钮
    self.randBtn = self.scene:getChildByName("randBtn")
    self.randBtn:addTouchEventListener(handler(self, self.randBtnCbk))
    gameUtil.setBtnEffect(self.randBtn)

    -- 创建按钮
    self.createBtn = self.scene:getChildByName("createBtn")
    self.createBtn:addTouchEventListener(handler(self, self.createBtnCbk))
    gameUtil.setBtnEffect(self.createBtn)

    local editBox = cc.EditBox:create(cc.size(320,55), "res/UI/jm_shurukuang.png")
    editBox:setAnchorPoint(0.5,0.5)
    editBox:setFont("res/font/youyuan.TTF", 32)
    editBox:setPlaceHolder("点击输入")
    self.editBox = editBox

    local nodeShuru = self.scene:getChildByName("Node_shuru")
    nodeShuru:addChild(editBox)
    --editBox:update(0.012)


    self.scene:getChildByName("Image_11"):loadTexture("res/UI/icon_biaozhi_lol.png")
    self.scene:getChildByName("Text_4"):setString(MoGameRet[990056])
    self.scene:getChildByName("Text_4_0"):setString(MoGameRet[990057])

    self.camp = 1

    self:addListener()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    -- local Image = self.scene:getChildByName("Image_6")
    -- Image:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))

    self:showLoading(false)
end

function CreateScene:dotaBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.dotaZy:setVisible(true)
        self.lolZy:setVisible(false)

        self.scene:getChildByName("Image_11"):loadTexture("res/UI/icon_biaozhi_dota.png")
        self.scene:getChildByName("Text_4"):setString(MoGameRet[990054])
        self.scene:getChildByName("Text_4_0"):setString(MoGameRet[990055])
        self.camp = 2
        gameUtil.playUIEffect( "Flag_Click" )
    end
end

function CreateScene:lolBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        -- self.dotaBtn:setEnabled(true)
        self.dotaZy:setVisible(false)
        self.lolZy:setVisible(true)

        self.scene:getChildByName("Image_11"):loadTexture("res/UI/icon_biaozhi_lol.png")
        self.scene:getChildByName("Text_4"):setString(MoGameRet[990056])
        self.scene:getChildByName("Text_4_0"):setString(MoGameRet[990057])

        self.camp = 1
        gameUtil.playUIEffect( "Flag_Click" )
    end
end

function CreateScene:randBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.randoming == true then
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "点击过快,请等待", z = 100})
            return
        end
        
        local curSeverId = cc.UserDefault:getInstance():getStringForKey("severId", "101")

        local function randomName( t )
            if t.type == 0 then
                local name = self.scene:getChildByName("nametext")
                self.editBox:setText(t.name)
            else
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "暂时无法随机昵称", z = 100})
            end
            self.randoming = false
        end
        -- local curSeverId = game.severList[1].Areaid
        if device.platform == "windows" then
            -- mm.req("getRandomName",{type = 1, qufu = "101"})
            
            self.app_.clientTCP:send("getRandomName",{type = 1, qufu = curSeverId},randomName)
            self.randoming = true
        else
            local currentServer = gameUtil.getDefaultServerInfo(game.severList)
            curSeverId = currentServer.Areaid

            -- mm.req("getRandomName",{type = 1, qufu = tostring(curSeverId) or "101"})
            self.app_.clientTCP:send("getRandomName",{type = 1, qufu = tostring(curSeverId) or "100"},randomName)
            self.randoming = true
        end
        
    end
end

function CreateScene:createBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local nameStr = self.editBox:getText()
        local length = gameUtil.getRealCharNum(nameStr)

        if length < 2 then
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "名字不能少于2个字符", z = 10000})
            return
        end

        local find = string.find(nameStr, "%s")
        if find ~= nil then
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "名字中不能包含空字符", z = 10000})
            return
        end

        if length > 8 then
            gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "名字长度不能超过8个字符", z = 10000})
            return
        end

        local function createRet( msg )
            if msg.type == 0 then
                mm.data.playerinfo = msg.playerinfo
                mm.data.playerHero = msg.playerHero
                mm.data.playerFormation = msg.playerFormation
                mm.data.playerExtra = msg.playerExtra
                mm.data.time.skillTime = msg.playerExtra.refreshSkillTime
                mm.data.curDuanWei = msg.curDuanWei
                mm.data.myMaxRank = msg.myMaxRank

                mm.data.activityInfo = msg.activityInfo
                mm.data.activityRecord = msg.activityRecord
                mm.data.publicActivityExtraInfo = msg.publicActivityExtraInfo

                mm.data.closeFuncTab = msg.closeFuncTab or {}
                mm.data.meleeStatus = msg.meleeStatus or 3

                mm.data.ranktime = msg.ranktime 
                
                mm.initTalk( msg.worldTalk )

                local function getDiRenListBack( event )
                    if event.type == 0 then
                        mm.direninfo = util.copyTab(event.direninfo)
                        mm.direnIndex = 1
                    else
                    end
                    self.app_:run("FightScene")
                    -- self:LoadingScence()
                end
                self.app_.clientTCP:send("getDiRenList",{type=0},getDiRenListBack)

                if device.platform == "android" then
                    ---------TODO---------------
                elseif device.platform == "ios" then
                    local info = {}
                    info.submitType = "Account"
                    info.roleName_ios = nameStr
                    info = json.encode(info)
                    SDKUtil:submitExtendData(info)
                end
            elseif msg.type == 1 then
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = msg.message, z = 100})
                self:showLoading(false)
            elseif msg.type == 2 then
                self:showLoading(false)
            end
        end

        

        
        if device.platform == "windows" then
            local curSeverId = cc.UserDefault:getInstance():getStringForKey("severId","0")
            if curSeverId == "0" then
                print("---------------CreateScene---------ERRRRRRRRRRRRRRRRORRRRRR------------------------")
                curSeverId = "101"
                cc.UserDefault:getInstance():setStringForKey("severId",curSeverId)
            end
            self.app_.clientTCP:send("createactor",{camp=self.camp,actorid=1,nickname= nameStr, qudao = "dianhun", zi_qudao = "01",qufu = curSeverId},createRet)

            self:showLoading(true)
        else
            local currentServer = gameUtil.getDefaultServerInfo(game.severList)
            local curSeverId = currentServer.Areaid

            if PLATFORM == "dhtest" then
                self.app_.clientTCP:send("createactor",{camp=self.camp,actorid=1,nickname= nameStr,qufu = curSeverId, zi_qudao = PLATFORMVER, qudao = "dhsdk" },createRet)
            else
                self.app_.clientTCP:send("createactor",{camp=self.camp,actorid=1,nickname= nameStr,qufu = curSeverId, zi_qudao = PLATFORMVER, qudao = PLATFORM },createRet)
            end
            self:showLoading(true)
        end
    end
end

local loadRes = {
    "res/FightBg/land_guaji.png",
    "res/FightBg/ground_lvdi.png",
    "res/UI/icon_ditu_lvdi.png",
    "res/icon/jiemian/icon_liansheng4.png",
    "res/UI/pc_disucai.png",
    "res/hero/guanzhong/d_4_qizhi/d_4_qizhi.png",
    "res/hero/guanzhong/l_4_qizhi/l_4_qizhi.png",
    "res/UI/pc_vs.png",
    "res/UI/jm_buzhendi.png",
    "res/UI/bt_yingxiong_normal.png",
    "res/UI/bt_yingxiong_select.png",
    "res/UI/bt_shouzhi_normal.png",
    "res/UI/bt_shouzhi_select.png",
    "res/UI/bt_shangcheng_normal.png",
    "res/UI/bt_shangcheng_select.png",
    "res/UI/bt_guanqia_normal.png",
    "res/UI/bt_guanqia_select.png",
    "res/UI/bt_qizhidota_normal.png",
    "res/UI/bt_qizhilol_normal.png",
    "res/UI/jm_dadi.png",
    "res/UI/jm_tanchu.png",
    "res/UI/jm_xiaodi.png",
    "res/Effect/uiEffect/sl/sl.png",
    "res/Effect/uiEffect/drcx/drcx.png",
}
function CreateScene:LoadingScence( ... )
    local count = 1
    local all = #loadRes
    local function callback( ... )
        if count <= all then
            count = count + 1
            display.loadImage(loadRes[count - 1], callback)
        else
            self.app_:run("FightScene")
        end
    end

    display.loadImage(loadRes[1], callback)
    count = count + 1



    
end

function CreateScene:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getRandomName" then
            if event.t.type == 0 then
                local name = self.scene:getChildByName("nametext")
                self.editBox:setText(event.t.name)
            else
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "暂时无法随机昵称", z = 100})
            end
        end
    end
end

function CreateScene:addListener()
    self.listeners = {}
    

    local function eventCustomListener1( ... )
        mm.self = nil
        self.app_:run("LoginSceneFinal")
    end
    self.listeners[1] = cc.EventListenerCustom:create("login_data_refesh",eventCustomListener1)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listeners[1], 1)

end

function CreateScene:onCleanup()
    if self.listeners ~= nil then 
        for k,v in pairs(self.listeners) do
           self:getEventDispatcher():removeEventListener(v)
        end
    end


    self:clearAllGlobalEventListener()
end

function CreateScene:showLoading( show ) 
    if self.loadingUI == nil then
        self.loadingUI = cc.CSLoader:createNode("heiloading.csb")
        self:addChild(self.loadingUI)
        
        local size  = cc.Director:getInstance():getWinSize()
        self.loadingUI:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(self.loadingUI)

        local animNode = self.loadingUI:getChildByName("Node_1")
        local player = cc.Sprite:create("res/hero/loading/loading0001.png")
        player:setScale(1.0)
        animNode:addChild(player)
        
        local animation = cc.Animation:create()
        animation:addSpriteFrameWithFile("res/hero/loading/loading0001.png")
        animation:addSpriteFrameWithFile("res/hero/loading/loading0002.png")
        animation:addSpriteFrameWithFile("res/hero/loading/loading0003.png")
        animation:setDelayPerUnit(0.1)
        -- animation:setLoops(-1)
        local action = cc.Animate:create(animation)
        local delay = cc.DelayTime:create(0.0)
        local sequence =  cc.Sequence:create(action, delay)
        player:runAction(cc.RepeatForever:create(sequence))
        
        require("app.res.TipsRes")
        
        local textSrc = ""
        local size = 0
        for k,v in pairs(Tips) do
            size = size + 1
        end
        if size == 0 then
            textSrc = ""
        else
            local index = math.random(1, size)
            local tempIndex = 0
            for k,v in pairs(Tips) do
                tempIndex = tempIndex + 1
                if tempIndex == index then
                    textSrc = v.LoadingTips
                    break
                end
            end
            -- textSrc = Tips[index].LoadingTips
        end
        local textNode = self.loadingUI:getChildByName("Text_1")
        textNode:setString(textSrc)


        local loadingText = self.loadingUI:getChildByName("Text")
        local num = 1
        local function flyBack( ... )
            local append = ""
            if num == 1 then
                append = ""
            elseif num == 2 then
                append = "."
            elseif num == 3 then
                append = ".."
            else
                append = "..."
            end
            loadingText:setString("用力加载中"..append)
            num = num + 1
            if num > 4 then
                num = 1
            end
        end
        local sequence = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(flyBack) )
        loadingText:runAction(cc.RepeatForever:create(sequence))
    end
    self.loadingUI:setVisible(show)
end

return CreateScene
