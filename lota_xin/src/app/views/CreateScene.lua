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


    local Node_dota = self.scene:getChildByName("Node_dota")
    local Node_lol = self.scene:getChildByName("Node_lol")
   


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
            if t.result == 0 then
                self.editBox:setText(t.nickName)
            else
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = "暂时无法随机昵称", z = 100})
            end
            self.randoming = false
        end
        -- local curSeverId = game.severList[1].Areaid
        if device.platform == "windows" then
            -- mm.req("getRandomName",{type = 1, qufu = "101"})
            
            self.app_.clientTCP:send("randomname",{type = 1},randomName)
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
            print("CreateScene createRet              !!!!!!!!!!!!!!!!!!!!!!  "..json.encode(msg))
            if msg.result == 0 then
                local function loginret(msg)
                    print("CreateScene loginret              !!!!!!!!!!!!!!!!!!!!!!  "..json.encode(msg))

                    print("CreateScene loginret       msg.base.pet       !!!!!!!!!!!!!!!!!!!!!!  "..json.encode(msg.base.pet))

                    mm.data.base = msg.base
                    mm.data.player = msg.master
                    mm.data.player.id = msg.base.id
                    mm.data.playerPet = msg.pet
                    mm.data.petEquip = msg.equip
                    self.app_:run("FightScene")

                end

                print("CreateScene login send              !!!!!!!!!!!!!!!!!!!!!!  "..json.encode(game.loginInfoTab))
                self.app_.clientTCP:send("login",game.loginInfoTab, loginret)
               
            elseif msg.result == 1 then
                gameUtil:addTishi({p = cc.Director:getInstance():getRunningScene(), s = msg.message, z = 100})
                self:showLoading(false)
            elseif msg.result == 2 then
                self:showLoading(false)
            end
        end

        

        
        -- if device.platform == "windows" then
            local curSeverId = cc.UserDefault:getInstance():getStringForKey("severId","0")
            if curSeverId == "0" then
                print("---------------CreateScene---------ERRRRRRRRRRRRRRRRORRRRRR------------------------")
            end
            self.app_.clientTCP:send("newchar",{nickName= nameStr},createRet)

            self:showLoading(true)
        -- else
        --     local currentServer = gameUtil.getDefaultServerInfo(game.severList)
        --     local curSeverId = currentServer.Areaid

        --     if PLATFORM == "dhtest" then
        --         self.app_.clientTCP:send("createactor",{camp=self.camp,actorid=1,nickname= nameStr,qufu = curSeverId, zi_qudao = PLATFORMVER, qudao = "dhsdk" },createRet)
        --     else
        --         self.app_.clientTCP:send("createactor",{camp=self.camp,actorid=1,nickname= nameStr,qufu = curSeverId, zi_qudao = PLATFORMVER, qudao = PLATFORM },createRet)
        --     end
        --     self:showLoading(true)
        -- end
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
            if event.t.result == 0 then
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
