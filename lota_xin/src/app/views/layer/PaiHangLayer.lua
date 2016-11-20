local PaiHangLayer = class("PaiHangLayer", require("app.views.mmExtend.LayerBase"))
PaiHangLayer.RESOURCE_FILENAME = "PaihangbangLayer.csb"

function PaiHangLayer:onCreate(param)
    self.param = param
    self.scene = self.param.scene
    self.Node = self:getResourceNode()

    -- 关闭按钮
    local imageBG = self.Node:getChildByName("Image_bg")

    self.backBtn = imageBG:getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.Button_totalZhnali = imageBG:getChildByName("Button_zhuangbei")
    self.Button_totalZhnali:addTouchEventListener(handler(self, self.totalZhanliCbk))

    -- self.Button_tibuZhanli = imageBG:getChildByName("Button_hunshi")
    -- self.Button_tibuZhanli:getChildByName("Text"):setString("替补")
    -- self.Button_tibuZhanli:addTouchEventListener(handler(self, self.tibuZhanliCbk))

    self.Button_tianTiZhanli = imageBG:getChildByName("Button_hunshi")
    self.Button_tianTiZhanli:getChildByName("Text"):setString("竞技")
    self.Button_tianTiZhanli:addTouchEventListener(handler(self, self.tianTiZhanliCbk))

    self.Button_heroZhanli = imageBG:getChildByName("Button_xiaohao")
    self.Button_heroZhanli:getChildByName("Text"):setString("英雄")
    self.Button_heroZhanli:addTouchEventListener(handler(self, self.heroZhanliCbk))

    self:initAreanUI()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
end

function PaiHangLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getZhanliList" then
            self.zhanliList = event.t.zhanliList
            self:updateUI(event.t.zhanliList)
        elseif event.code == "getPlayerInfo" then
            local zhanli = 0
            for k,v in pairs(self.zhanliList) do
                if self.checkId == v.playerid then
                    zhanli = v.zhanli
                    break
                end
            end
         
            local zhenrongchakanLayer = require("src.app.views.layer.zhenrongchakan").new({info = event.t, zhanli = zhanli})
            self:addChild(zhenrongchakanLayer)
        elseif event.code == "getTibuZhanliList" then
            self.zhanliList = event.t.zhanliList
            self:updateUI(event.t.zhanliList)
        elseif event.code == "getHeroZhanliList" then
            self.zhanliList = event.t.zhanliList
            self:updateUI(event.t.zhanliList)
        elseif event.code == "getTianTiList" then
            self.zhanliList = event.t.zhanliList
            self:updateUI(event.t.zhanliList)
        end
    end
end


function PaiHangLayer:onEnter() 
    
end

function PaiHangLayer:tianTiZhanliCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curLayerName = "tianTiZhanli"
        mm.req("getTianTiList",{getType = 0})
    end
end

function PaiHangLayer:totalZhanliCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curLayerName = "totalZhanli"
        mm.req("getZhanliList",{getType = 0})
    end
end


function PaiHangLayer:tibuZhanliCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curLayerName = "tibuZhanli"
        mm.req("getTibuZhanliList",{getType = 0})
    end
end

function PaiHangLayer:heroZhanliCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curLayerName = "heroZhanli"
        mm.req("getHeroZhanliList",{getType = 0})
    end
end


function PaiHangLayer:updateUI(zhanliList)
    local sollowView = self.ContentLayer:getChildByName("ScrollView") 
    sollowView:removeAllChildren()
    sollowView:jumpToTop()
    if zhanliList == nil then
        return
    end

    local function fun( i, table, cell )
        cell:setSwallowTouches(false)

        if i < 4 then
            cell:getChildByName("Image_1"):loadTexture("res/icon/jiemian/icon_paihang_"..i..".png")
            cell:getChildByName("Text_ranking"):setVisible(false)
        else
            cell:getChildByName("Image_1"):loadTexture("res/icon/jiemian/icon_paihang_4.png")

            local textNode = cell:getChildByName("Text_ranking")
            textNode:setText(i)
            textNode:setVisible(true)

            if i > 99 then
                textNode:setFontSize(36)
            elseif i > 9 then
                textNode:setFontSize(45)
            else
                textNode:setFontSize(48)
            end
        end
        -- __DEBUG__TABLE__(zhanliList[i])

        -- local name = table.qufu.."."..table.nickname
        local name = table.nickname
        cell:getChildByName("Text_name"):setText(name)
        --cell:getChildByName("Text_lv"):setText("LV: "..table.level)
        cell:getChildByName("Text_zhanli"):setText("战力: "..table.zhanli)

        if self.curLayerName == "heroZhanli" then
            local heroInfo = {}
            heroInfo.id = table.heroId
            heroInfo.jinlv = table.heroJinlv
            heroInfo.exp = table.heroExp
            heroInfo.xinlv = table.heroXinlv

            local touxiang = gameUtil.createTouXiang(heroInfo)
            local posx, posy = cell:getChildByName("Image_zhenying"):getPosition()
            -- local heroRes = gameUtil.getHeroIcon(table.heroId)
        
            cell:removeChildByTag(999999)
            cell:addChild(touxiang)
            touxiang:setTag(999999)
            touxiang:setPosition(posx,posy)
            touxiang:setAnchorPoint(cc.p(0.5,0.5))
            cell:getChildByName("Image_zhenying"):setVisible(false)
        else
            if table.camp == 1 then
                cell:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhilol_select.png")
            else
                cell:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhidota_select.png")
            end
        end

        if table.camp == 1 then
            cell:getChildByName("Image_icon"):loadTexture("res/icon/head/L023.png")
        else
            cell:getChildByName("Image_icon"):loadTexture("res/icon/head/D074.png")
        end

        if table.playerid == mm.data.playerinfo.id then
            cell:loadTexture("res/UI/bt_tiao_hong.png")
        else
            cell:loadTexture("res/UI/bt_tiao_normal.png")
        end

        cell:setTag(table.playerid)
    end

    if zhanliList and #zhanliList > 0 then
        gameUtil.setSollowView(sollowView, 8, 1, zhanliList, 105, "AreanItem.csb", fun, handler(self, self.checkPlayer))
    end

    local selfNode = self.ContentLayer:getChildByName("Image_4")
    selfNode:getChildByName("Text_paiming"):setText(">200")
    selfNode:getChildByName("Text_ming"):setText(mm.data.playerinfo.nickname)

    local valueAll = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue, true )
    local valueA = gameUtil.getPlayerForce( mm.data.playerExtra.pkValue, false )
    local valueB = valueAll - valueA

    if self.curLayerName == "totalZhanli" then
        selfNode:getChildByName("Text_shenglv"):setText(valueAll)
    elseif self.curLayerName == "tibuZhanli" then
        selfNode:getChildByName("Text_shenglv"):setText(valueB)
    else
        selfNode:getChildByName("Text_shenglv"):setText(0)
    end
    

    for k,v in pairs(zhanliList) do
        if v.playerid == mm.data.playerinfo.id then
            selfNode:getChildByName("Text_paiming"):setText(k)
            selfNode:getChildByName("Text_ming"):setText(v.nickname)
            selfNode:getChildByName("Text_shenglv"):setText(v.zhanli)
            break
        end
    end

    -- 顶部按钮效果设置
    if self.curLayerName == "totalZhanli" then
        self:setBtn(self.Button_totalZhnali)
        -- 中间文字
        self.ContentLayer:getChildByName("Image_1"):getChildByName("Image_5"):loadTexture("res/UI/pc_zhanli.png")
    elseif self.curLayerName == "tibuZhanli" then
        self:setBtn(self.Button_tibuZhanli)
        -- 中间文字
        self.ContentLayer:getChildByName("Image_1"):getChildByName("Image_5"):loadTexture("res/UI/pc_tibu.png")
    elseif self.curLayerName == "tianTiZhanli" then
        self:setBtn(self.Button_tianTiZhanli)
        -- 中间文字
        self.ContentLayer:getChildByName("Image_1"):getChildByName("Image_5"):loadTexture("res/UI/pc_jingjipaihang.png")
    else
        self:setBtn(self.Button_heroZhanli)
        -- 中间文字
        self.ContentLayer:getChildByName("Image_1"):getChildByName("Image_5"):loadTexture("res/UI/pc_yingxiong.png")
    end
end


function PaiHangLayer:checkPlayer(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.curLayerName == "tibuZhanli" or self.curLayerName == "heroZhanli" then
            return
        end

        local tag = widget:getTag()
        self.checkId = tag
        mm.req("getPlayerInfo",{playerid = tag})
    end
end

function PaiHangLayer:setBtn( btn )
    self.Button_totalZhnali:setBright(true)
    -- self.Button_tibuZhanli:setBright(true)
    self.Button_tianTiZhanli:setBright(true)
    self.Button_heroZhanli:setBright(true)

    self.Button_totalZhnali:setEnabled(true)
    -- self.Button_tibuZhanli:setEnabled(true)
    self.Button_tianTiZhanli:setEnabled(true)
    self.Button_heroZhanli:setEnabled(true)
    
    btn:setBright(false)
    btn:setEnabled(false)
end

function PaiHangLayer:initAreanUI( ... )
    local AreanLayer = cc.CSLoader:createNode("PaihangbangZL.csb")
    if self.ContentLayer then
        self.ContentLayer:removeFromParent()
    end
    self.ContentLayer = AreanLayer
    -- self.ContentLayer:getChildByName("Text_msg"):setString(MoGameRet[990005])
    self:addChild(AreanLayer)
    local size  = cc.Director:getInstance():getWinSize()
    AreanLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(AreanLayer)

    -- 天梯按钮
    self.rewardBtn = AreanLayer:getChildByName("Button_2")
    self.rewardBtn:setVisible(false)
    self.rewardBtn:addTouchEventListener(handler(self, self.rewardBtnCbk))
    gameUtil.setBtnEffect(self.rewardBtn)

    self.curLayerName = "totalZhanli"
    mm.req("getZhanliList",{getType = 0})

    -- mm.req("getTianTiInfo",{getType = 0})
end



function PaiHangLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function PaiHangLayer:rewardBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        mm.pushLayoer( {scene = self.scene, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ShangChengLayer",
                            resName = "ShangChengLayer",params = {typeLayer = 1, scene = self.scene}} )
    end
end

function PaiHangLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return PaiHangLayer
