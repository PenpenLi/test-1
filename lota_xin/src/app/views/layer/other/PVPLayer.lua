local PVPLayer = class("PVPLayer", require("app.views.mmExtend.LayerBase"))
PVPLayer.RESOURCE_FILENAME = "PVPLayer.csb"

function PVPLayer:onCreate(param)
    self.param = param
    self.scene = self.param.scene
    self.Node = self:getResourceNode()

    -- 关闭按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.Button_jinji = self.Node:getChildByName("Button_jinji")
    self.Button_jinji:addTouchEventListener(handler(self, self.jinjiCbk))

    self.Button_dashi = self.Node:getChildByName("Button_dashi")
    self.Button_dashi:addTouchEventListener(handler(self, self.dashiCbk))

    self.Button_wangzhe = self.Node:getChildByName("Button_wangzhe")
    self.Button_wangzhe:addTouchEventListener(handler(self, self.wangzheCbk))

    self:initAreanUI()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
end

function PVPLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getRank" then
            self:initPVPList(event.t)

        elseif event.code == "getRankList" then
            self:updateRankUI(event.t.rank, event.t.rankList)
            self.rankList = event.t.rankList
        elseif event.code == "getPlayerInfo" then
            local zhanli
            for k,v in pairs(self.rankList) do
                if self.checkId == v.playerid then
                    zhanli = v.zhanli
                    break
                end
            end
         
            zhenrongchakanLayer = require("src.app.views.layer.zhenrongchakan").new({info = event.t, zhanli = zhanli})
            self:addChild(zhenrongchakanLayer, MoGlobalZorder[2999999])
        elseif event.code == "snipe" then

            print("PVPLayer:tiaozhanBtnCbk ===========  3333 "..event.t.type)

            if event.t.type == 0 then
                print("PVPLayer:tiaozhanBtnCbk ===========  3336 ")
                
                local BuZhenLayer = require("src.app.views.layer.BuZhenNewLayer").new({app = self.app_, type = 20, Info = event.t.direninfo})
                local size  = cc.Director:getInstance():getWinSize()
                self:addChild(BuZhenLayer)
                BuZhenLayer:setContentSize(cc.size(size.width, size.height))
                ccui.Helper:doLayout(BuZhenLayer)
            else
                print("PVPLayer:tiaozhanBtnCbk ===========  444 ")
                
            end

        end

    end
end


function PVPLayer:onEnter() 
    if mm.GuildId == 15005 then
        -- performWithDelay(self,function( ... )
            Guide:startGuildById(15006, self.dropInfoBtn)
        -- end, 0.01)
    end
end

function PVPLayer:jinjiCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curLayerName = "jingji"
        mm.req("getRankList",{getType = 0})
    end
end


function PVPLayer:dashiCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curLayerName = "dashi"
        mm.req("getRankList",{getType = 1093677622})
    end
end

function PVPLayer:wangzheCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self.curLayerName = "wangzhe"
        mm.req("getRankList",{getType = 1093677623})
    end
end

function PVPLayer:tiaozhanBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local id = widget:getTag()
        if (mm.diFangZhen and mm.diFangZhen.diType and 10 == mm.diFangZhen.diType) or (mm.curDiZhen and mm.curDiZhen.diType and mm.curDiZhen.diType == 10) then
            gameUtil:addTishi({s = MoGameRet[990066]})
            return
        end

        
        print("PVPLayer:tiaozhanBtnCbk ===========  0000 "..id)
        print("PVPLayer:tiaozhanBtnCbk ===========  0000 "..mm.data.playerExtra.pkTimes)

        if tonumber(mm.data.playerExtra.pkTimes) > 0 then
            print("PVPLayer:tiaozhanBtnCbk ===========  1111 ")

            mm.req("snipe",{playerid = id, snipeType = 0})

        else
       
            gameUtil:addTishi({s = MoGameRet[990502]})
        end
    end
end



function PVPLayer:updateRankUI(rank, rankList)
    local sollowView = self.ContentLayer:getChildByName("ScrollView") 
    sollowView:removeAllChildren()
    sollowView:jumpToTop()
    local function fun( i, table, cell )
        cell:setSwallowTouches(false)

        -- __DEBUG__TABLE__(rankList[i])


        cell:setTag(table.playerid)


        if table.camp == 1 then
            cell:getChildByName("Image_bk"):loadTexture("res/icon/head/L023.png")
            cell:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhilol_select.png")
        else
            cell:getChildByName("Image_bk"):loadTexture("res/icon/head/D074.png")
            cell:getChildByName("Image_zhenying"):loadTexture("res/UI/bt_qizhidota_select.png")
        end
        cell:getChildByName("Text_name"):setString(table.nickname)

        cell:getChildByName("Text_zhanli"):setString("战力："..table.zhanli)

        if i < 4 then
            cell:getChildByName("RankImage"):loadTexture("res/icon/jiemian/icon_paihang_"..i..".png")
            cell:getChildByName("Text_ranking"):setVisible(false)
        else
            cell:getChildByName("RankImage"):loadTexture("res/icon/jiemian/icon_paihang_4.png")

            local textNode = cell:getChildByName("Text_ranking")
            textNode:setText(i)
            textNode:setVisible(true)

            textNode:setFontSize(45)

            if i > 99 then
                textNode:setFontSize(36)
            end
        end



        if self.curLayerName == "jingji" and tonumber(mm.data.curDuanWei) >= 1093677617 and table.playerid ~= mm.data.playerinfo.id then
            cell:getChildByName("ButtonTiaozhan"):setVisible(true)
            cell:getChildByName("ButtonTiaozhan"):setTag(table.playerid)
            cell:getChildByName("ButtonTiaozhan"):addTouchEventListener(handler(self, self.tiaozhanBtnCbk))
            gameUtil.setBtnEffect(cell:getChildByName("ButtonTiaozhan"))
            cell:getChildByName("Text"):setVisible(true)
        else
            cell:getChildByName("ButtonTiaozhan"):setVisible(false)
            cell:getChildByName("Text"):setVisible(false)
        end

    end


    if rankList and #rankList > 0 then
        gameUtil.setSollowView(sollowView, 6, 1, rankList, 105, "TTAreanItem.csb", fun, handler(self, self.checkPlayer))
    else
        local function aa( ... )
        end
        sollowView:addEventListenerScrollView(aa)
        sollowView:setInnerContainerSize(cc.size(sollowView:getSize().width, sollowView:getSize().height))

        local cell = cc.CSLoader:createNode("TTNoneAreanItem.csb")
        -- cell = cell:getChildByName("Image_bg"):clone()
        sollowView:addChild(cell)
        cell:setPosition(0, sollowView:getSize().height - 424)
    end


    self.duanwei = rank
    local image = self.ContentLayer:getChildByName("Image_6")
    image:removeAllChildren()
    local res = "icon1"
    
    local curDuanWei = tonumber(self.duanwei)
    if curDuanWei == 1093677105 
        or curDuanWei == 1093677106 
        or curDuanWei == 1093677107 
        or curDuanWei == 1093677108 
        or curDuanWei == 1093677109 then
        res = "icon1"
    elseif curDuanWei == 1093677110 
        or curDuanWei == 1093677111 
        or curDuanWei == 1093677112 
        or curDuanWei == 1093677113 
        or curDuanWei == 1093677360 then
        res = "icon2"
    elseif curDuanWei == 1093677361 
        or curDuanWei == 1093677362 
        or curDuanWei == 1093677363 
        or curDuanWei == 1093677364 
        or curDuanWei == 1093677365 then
        res = "icon3"
    elseif curDuanWei == 1093677366 
        or curDuanWei == 1093677367 
        or curDuanWei == 1093677368 
        or curDuanWei == 1093677369 
        or curDuanWei == 1093677616 then
        res = "icon4"
    elseif curDuanWei == 1093677617 
        or curDuanWei == 1093677618 
        or curDuanWei == 1093677619 
        or curDuanWei == 1093677620 
        or curDuanWei == 1093677621 then
        res = "icon5"
    elseif curDuanWei == 1093677622  then
        res = "ds"
    elseif curDuanWei == 1093677623 then
        res = "zqwz"
    else
        
    end

    -- local index = INITLUA:getDropOutRes()[curDuanWei]['Res']
    -- gameUtil.addArmatureFile("res/Effect/uiEffect/"..res.."/"..res..".ExportJson")
    -- local anime = ccs.Armature:create(res)
    -- -- 将胜利文字替换为高清的
    -- local duanwei = ccs.Skin:create("res/icon/jiemian/"..index..".png")
    -- local text_bone = anime:getBone(res)
    -- text_bone:removeDisplay(0)
    -- text_bone:addDisplay(duanwei, 0)
    -- text_bone:setScale(1)

    -- local animation = anime:getAnimation()
    -- anime:setScale(1.2)
    -- image:removeAllChildren()
    -- image:addChild(anime,10)
    -- anime:setName('duanwei')
    -- anime:setTag(curDuanWei)
    -- animation:play(res)

    local anime = gameUtil.createSkeAnmion( {name = res, scale = 1.4} )
    anime:setAnimation(0, "stand", true)
    image:removeAllChildren()
    image:addChild(anime,10)
    anime:setName('duanwei')
    anime:setTag(curDuanWei)

    if res ~= "ds" and res ~= "zqwz" then
        local index = INITLUA:getDropOutRes()[curDuanWei]['RankIconNum']
        anime:setAttachment(res .."=",res .."=" ..index )
    end

    local zjId = 0

    if tonumber(self.duanwei) == tonumber(mm.data.curDuanWei) then
        for i=1,#rankList do
            if tonumber(rankList[i].playerid) == tonumber(mm.data.playerinfo.id) then
                self.ContentLayer:getChildByName("Text_paiming"):setText(i)
                self.ContentLayer:getChildByName("Text_ming"):setText(rankList[i].nickname)
                self.ContentLayer:getChildByName("Text_shenglv"):setText(rankList[i].zhanli)

                zjId = i

            end
        end
    else
        self.ContentLayer:getChildByName("Text_paiming"):setText("")
        self.ContentLayer:getChildByName("Text_ming"):setText("")
        self.ContentLayer:getChildByName("Text_shenglv"):setText("")
        
    end

    -- 顶部按钮效果设置
    if self.curLayerName == "jingji" then
        self:setBtn(self.Button_jinji)
    elseif self.curLayerName == "dashi" then
        self:setBtn(self.Button_dashi)
    else
        self:setBtn(self.Button_wangzhe)
    end

    local honorValue = 0
    local goldValue = 0
    local rankGift = INITLUA:getRankGift()
    for k,v in pairs(rankGift) do
        if v.DropFrom == curDuanWei  then
            if v.RankGiftRange[1] == zjId or (v.RankGiftRange[1] and v.RankGiftRange[2] and v.RankGiftRange[1] <= zjId and v.RankGiftRange[2] >= zjId) then
                honorValue = v.RankGiftGlory
                goldValue = v.RankGiftGold

                break
            end
        end
    end

    


    if self.curLayerName == "jingji" then

        local pkTimes = tonumber(mm.data.playerExtra.pkTimes)
        local rongyuImageView = gameUtil.createOTItem("res/icon/jiemian/icon_zuanshi.png", honorValue)
        self.ContentLayer:getChildByName("Image_5"):getChildByName("ItemImage_1"):addChild(rongyuImageView)

        local jinbiImageView = gameUtil.createOTItem("res/icon/jiemian/icon_jinbi.png", goldValue)
        self.ContentLayer:getChildByName("Image_5"):getChildByName("ItemImage_2"):addChild(jinbiImageView)

        self.ContentLayer:getChildByName("Image_5"):getChildByName("ItemImage_1"):setVisible(true)
        self.ContentLayer:getChildByName("Image_5"):getChildByName("ItemImage_2"):setVisible(true)

        if curDuanWei >= 1093677617 then
            local vipLv = gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp)
            local vipInfo = INITLUA:getVIPTabById(vipLv)
            local PKNumMax = vipInfo.PKNumMax

            self.ContentLayer:getChildByName("Image_5"):getChildByName("Text_1"):setString("剩余次数："..pkTimes.." / "..PKNumMax)
            self.ContentLayer:getChildByName("Image_5"):getChildByName("Text_1"):setVisible(true)
            self.ContentLayer:getChildByName("Image_5"):getChildByName("Text_2"):setVisible(true)
        else
            self.ContentLayer:getChildByName("Image_5"):getChildByName("Text_1"):setVisible(false)
            self.ContentLayer:getChildByName("Image_5"):getChildByName("Text_2"):setVisible(false)
        end

    else
        self.ContentLayer:getChildByName("Image_5"):getChildByName("Text_1"):setVisible(false)
        self.ContentLayer:getChildByName("Image_5"):getChildByName("Text_2"):setVisible(false)
        self.ContentLayer:getChildByName("Image_5"):getChildByName("ItemImage_1"):setVisible(false)
        self.ContentLayer:getChildByName("Image_5"):getChildByName("ItemImage_2"):setVisible(false)
    end



end


function PVPLayer:checkPlayer(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        self.checkId = tag
        mm.req("getPlayerInfo",{playerid = tag})
    end
end

function PVPLayer:setBtn( btn )
    self.Button_jinji:setBright(true)
    self.Button_dashi:setBright(true)
    self.Button_wangzhe:setBright(true)

    self.Button_jinji:setEnabled(true)
    self.Button_dashi:setEnabled(true)
    self.Button_wangzhe:setEnabled(true)
    
    btn:setBright(false)
    btn:setEnabled(false)
end

function PVPLayer:initAreanUI( ... )
    local AreanLayer = cc.CSLoader:createNode("AreanLayer.csb")
    if self.ContentLayer then
        self.ContentLayer:removeFromParent()
    end
    self.ContentLayer = AreanLayer
    self.ContentLayer:getChildByName("Text_msg"):setString(MoGameRet[990005])
    self:addChild(AreanLayer)
    local size  = cc.Director:getInstance():getWinSize()
    AreanLayer:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(AreanLayer)

    -- 天梯按钮
    self.rewardBtn = AreanLayer:getChildByName("Button_guize")
    self.rewardBtn:addTouchEventListener(handler(self, self.rewardBtnCbk))
    gameUtil.setBtnEffect(self.rewardBtn)

    -- 查看掉落
    self.dropInfoBtn = AreanLayer:getChildByName("Button_3")
    self.dropInfoBtn:addTouchEventListener(handler(self, self.dropInfoBtnCbk))
    gameUtil.setBtnEffect(self.dropInfoBtn)

    -- 查看掉落
    self.guizeBtn = AreanLayer:getChildByName("Image_3")
    self.guizeBtn:addTouchEventListener(handler(self, self.guizeBtnCbk))

    -- self.ListView = AreanLayer:getChildByName("ListView") 

    -- mm.req("getRank",{getType=1})
    self.curLayerName = "jingji"
    mm.req("getRankList",{getType = 0})
end



function PVPLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function PVPLayer:initFuCouList( event )
    local FuCouList = event.fuchouList
    if event.type == 0 then
        for k,v in pairs(FuCouList) do
            local custom_item = ccui.Layout:create()
            local AreanFuChouItem = cc.CSLoader:createNode("areanFCItem.csb")
            custom_item:addChild(AreanFuChouItem)
            custom_item:setContentSize(AreanFuChouItem:getContentSize())
            self.FuCouListView:pushBackCustomItem(custom_item)
            AreanFuChouItem:getChildByName("Button_1"):setSwallowTouches(false)
            AreanFuChouItem:getChildByName("Button_1"):addTouchEventListener(handler(self, self.zhandouBtnCbk))
            AreanFuChouItem:getChildByName("Button_1"):setTag(v.playerid)
            AreanFuChouItem:getChildByName("Text_name"):setText(v.nickname)
            AreanFuChouItem:getChildByName("Text_zhanli"):setText(v.zhanli)
            AreanFuChouItem:getChildByName("Text_zhanqu"):setText(v.duanwei .. "(".. v.zhanqu ..")")

        end
    end

end

function PVPLayer:FuCouZhanBack( event )
    if event.type == 0 then
        local playerinfo  = event.playerinfo
        local playerEquip   = event.playerEquip
        local playerHero     = event.playerHero
        local playerFormation    = event.playerFormation

        local BuZhenLayer = require("src.app.views.layer.BuZhenLayer").create({app = self.param.app, playerinfo = playerinfo, diFormation = playerFormation,diHero = playerHero})
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(BuZhenLayer)
        BuZhenLayer:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(BuZhenLayer)


    end
end


function PVPLayer:zhandouBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local playerid = widget:getTag()

        self.param.app.clientTCP:send("fuChouZhan",{getType=1, fuchouId = playerid},handler(self, self.FuCouZhanBack))

    end
end

function PVPLayer:qinlueBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if not self.AreanFuCouLayer then
            local AreanFuCouLayer = cc.CSLoader:createNode("AreanFuCouLayer.csb")
            
            
            self:addChild(AreanFuCouLayer)
            local size  = cc.Director:getInstance():getWinSize()
            AreanFuCouLayer:setContentSize(cc.size(size.width, size.height))
            ccui.Helper:doLayout(AreanFuCouLayer)

            self.FuCouListView = AreanFuCouLayer:getChildByName("ListView")

            AreanFuCouLayer:getChildByName("Panel_touch"):addTouchEventListener(handler(self, self.qinlueRemoveBtnCbk))
            self.AreanFuCouLayer = AreanFuCouLayer

            self.param.app.clientTCP:send("getFuChou",{getType=1},handler(self, self.initFuCouList))
        end
    end
end

function PVPLayer:guizeBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local LadderLayer = require("src.app.views.layer.LadderRuleLayer").new()
        self:addChild(LadderLayer)
    end
end

function PVPLayer:dropInfoBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local key = 1093677623
        local name = "最强王者"

        
        local dropOutRes = INITLUA:getDropOutRes()
        local key = dropOutRes[tonumber(self.duanwei)].ID
        name = dropOutRes[tonumber(self.duanwei)].Name
        
        local rewardLayer = require("src.app.views.layer.DropItemLayer").new(key)
        self:addChild(rewardLayer)
    end
end

function PVPLayer:rewardBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
            -- mm.pushLayoer( {scene = self.scene, clear = 1, zord = MoGlobalZorder[2000002], res = "src.app.views.layer.ShangChengLayer",
            --                     resName = "ShangChengLayer",params = {typeLayer = 1, scene = self.scene}} )
        local TTRules = require("src.app.views.layer.TTRules").new()
        local size  = cc.Director:getInstance():getWinSize()
        self:addChild(TTRules, 50)
        TTRules:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(TTRules)
    end
end

function PVPLayer:qinlueRemoveBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.AreanFuCouLayer then
            self.AreanFuCouLayer:removeFromParent()
            self.AreanFuCouLayer = nil
        end
    end
end

function PVPLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

return PVPLayer
