local youjianLayer = class("youjianLayer", require("app.views.mmExtend.LayerBase"))
youjianLayer.RESOURCE_FILENAME = "youjianLayer.csb"

function youjianLayer:onEnter() 
    if mm.lastMaillist ~= nil then
        self:updateMail( mm.lastMaillist )
    end
end

function youjianLayer:onExit()
    if self.tcpSession then
        mm.app.clientTCP:removeSessionmap(self.tcpSession)
    end
end

function youjianLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function youjianLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function youjianLayer:init(param)
    self.app = param.app
    self.scene = param.scene
    self.Node = self:getResourceNode()

    self.ListView = self.Node:getChildByName("Image_bg"):getChildByName("ListView")
    --self:showMail()

    self.Node:getChildByName("Image_bg"):getChildByName("Text_id"):setString(mm.data.playerinfo.id)

    self.tcpSession =  mm.app.clientTCP:send("maillist",{getType=1},handler(self, self.showMail))

    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self.Node:getChildByName("Image_bg"):getChildByName("Text_None"):setVisible(false)

    gameUtil.setBtnEffect(self.backBtn)
end

function youjianLayer:showMail( event )
    local testMailList = {}
    testMailList[1] = {}
    testMailList[1].id = 200222
    testMailList[1].fromid = 10000
    testMailList[1].fromname = "系统"
    testMailList[1].toid = 234
    testMailList[1].toname = "自己"
    testMailList[1].title = "你有一封邮件"
    testMailList[1].text = "邮件内容不知道邮件内容不知道邮件内容不知道邮件内容不知道邮件内容不知道邮件内容不知道邮件内容不知道邮件内容不知道邮件内容不知道邮件内容不知道"
    testMailList[1].mailGoodsinfo = {}
    testMailList[1].hasread = 0 --未读
    testMailList[1].time = os.time()

    testMailList[1].mailGoodsinfo = {}
    testMailList[1].mailGoodsinfo.exp = 111
    testMailList[1].mailGoodsinfo.gold = 222
    testMailList[1].mailGoodsinfo.diamond = 333
    testMailList[1].mailGoodsinfo.vipexp = 0
    testMailList[1].mailGoodsinfo.exppool = 555
    testMailList[1].mailGoodsinfo.honor = 666
    testMailList[1].mailGoodsinfo.gongxian = 0
    testMailList[1].mailGoodsinfo.mailGoodsItem = {}

    testMailList[1].mailGoodsinfo.mailGoodsItem[1] = {}
    testMailList[1].mailGoodsinfo.mailGoodsItem[1].id = 1160785969 --多兰剑
    testMailList[1].mailGoodsinfo.mailGoodsItem[1].num = 100
    testMailList[1].mailGoodsinfo.mailGoodsItem[1].type = 0

    testMailList[1].mailGoodsinfo.mailGoodsItem[2] = {}
    testMailList[1].mailGoodsinfo.mailGoodsItem[2].id = 1160785969 --多兰剑
    testMailList[1].mailGoodsinfo.mailGoodsItem[2].num = 100
    testMailList[1].mailGoodsinfo.mailGoodsItem[2].type = 0

    event.type = 0
    if event.type == 0 then
        self:updateMail(event.maillist)
    end
end

--截取中英混合的UTF8字符串，endIndex可缺省
function youjianLayer:subStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = self:subStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = self:subStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, self:subStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, self:subStringGetTrueIndex(str, startIndex), self:subStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--获取中英混合UTF8字符串的真实字符数量
function youjianLayer:subStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = self:subStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function youjianLayer:subStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = self:subStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function youjianLayer:subStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<223 then
        byteCount = 2
    elseif curByte>=224 and curByte<239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

function youjianLayer:updateMail( maillist )
    self.maillist = maillist
    mm.lastMaillist = self.maillist

    --self.maillist = testMailList
    if self.maillist == nil then
        self.Node:getChildByName("Image_bg"):getChildByName("Text_None"):setVisible(true)
        self:mailShuaxin(0)
        return
    end

    self.ListView:removeAllItems()

    local num  = #self.maillist
    if num > 0 then
        self.Node:getChildByName("Image_bg"):getChildByName("Text_None"):setVisible(false)
        self:mailShuaxin(num)
    else
        self.Node:getChildByName("Image_bg"):getChildByName("Text_None"):setVisible(true)
        self:mailShuaxin(0)
    end
    
    function sortRule(a, b)
        return a.time > b.time
    end
    table.sort(self.maillist, sortRule)

    for i=1,num do
        local custom_item = ccui.Layout:create()
        self.maillist[i].tag = self.maillist[i].id
    
        local youjianItem = cc.CSLoader:createNode("youjianItem.csb")
        custom_item:addChild(youjianItem)
        custom_item:setContentSize(youjianItem:getContentSize())
        custom_item:setTag(self.maillist[i].tag)
        self.ListView:pushBackCustomItem(custom_item)

        youjianItem:getChildByName("Image_bg"):addTouchEventListener(handler(self, self.selectCbk))
        youjianItem:getChildByName("Image_bg"):setSwallowTouches(false)
        youjianItem:getChildByName("Image_bg"):setTag(i)

        local title = self.maillist[i].title
        title = self:subStringUTF8(title, 1, 16)

        youjianItem:getChildByName("Image_bg"):getChildByName("Text_biaoti"):setText(title)
        youjianItem:getChildByName("Image_bg"):getChildByName("Text_name"):setText("发件人:"..self.maillist[i].fromname)

        local time = os.date("*t", self.maillist[i].time)
        youjianItem:getChildByName("Image_bg"):getChildByName("Text_shijian"):setText(time.year.."."..time.month.."."..time.day)

        local mailIcon = self.maillist[i].mailIcon
        if mailIcon and mailIcon ~= "" then
            youjianItem:getChildByName("Image_bg"):getChildByName("Image_icon_3"):loadTexture("res/icon/head/"..mailIcon..".png")
        end
    end
end

function youjianLayer:mailShuaxin(num)
    mm.data.noReadNum = num
    mm.GuildScene:mailShuaxin()
end


function youjianLayer:selectCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        if self.insertIndex then
            self.ListView:removeItem(self.insertIndex)
            self.insertIndex = nil
            return
        end
        local item = widget:getParent():getParent()
        local index = self.ListView:getIndex(item)
        --self.ListView:removeItem(index)

        local insertIndex = index + 1
        local tag = item:getTag()
        local mail = nil
        local num  = #self.maillist
        for i=1,num do
            if self.maillist[i].tag == tag then
                mail = self.maillist[i]
                break
            end
        end

        if mail == nil then
            return
        end


        local youjianZKItem = ccui.Layout:create()
        local youjianZKLayer = cc.CSLoader:createNode("youjianZKLayer.csb")
        youjianZKItem:addChild(youjianZKLayer)
        youjianZKItem:setContentSize(youjianZKLayer:getContentSize().width,(youjianZKLayer:getContentSize().height-18))
        youjianZKItem:setTag(tag)

        local title = youjianZKLayer:getChildByName("Image_di"):getChildByName("Text_2")
        title:setString("发件人:"..mail.fromname)

        
        local listView = youjianZKLayer:getChildByName("Image_di"):getChildByName("Image_2"):getChildByName("ListView_2")

        local rewardBtn = youjianZKLayer:getChildByName("Image_di"):getChildByName("Button_1")
        rewardBtn:addTouchEventListener(handler(self, self.rewardBtc))
        rewardBtn:setTag(tag)
        gameUtil.setBtnEffect(rewardBtn)


        local jumptoBtn = youjianZKLayer:getChildByName("Image_di"):getChildByName("Button_2")
        jumptoBtn:addTouchEventListener(handler(self, self.jumptoBtc))
        jumptoBtn:setTag(tag)
        gameUtil.setBtnEffect(jumptoBtn)

        if mail.jumpto and mail.jumpto ~= "" then
            jumptoBtn:setVisible(true)
        else
            jumptoBtn:setVisible(false)
        end

        local ttfConfig = {}
        ttfConfig.fontFilePath = "font/youyuan.TTF"
        ttfConfig.fontSize = 25
        ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
        ttfConfig.customGlyphs = nil
        ttfConfig.distanceFieldEnabled = true
        ttfConfig.outlineSize = 0
        --mail.text = "12121微风地方让我确认2111111111111111111111111111111111111111111"
        local label = cc.Label:createWithTTF(ttfConfig,mail.text,cc.TEXT_ALIGNMENT_LEFT)
        --local label = ccui.Text:create(mail.text, "fonts/huakang.TTF", 25)
        label:setAnchorPoint(cc.p(0.0,0.0))
        label:setPosition(cc.p(0, 0))
        label:setTextColor( cc.c4b(255, 255, 255, 255) )
        --label:enableGlow(cc.c4b(255, 255, 0, 255))
        --label:setString("")
        label:setLineBreakWithoutSpace(true)
        label:setMaxLineWidth(listView:getContentSize().width)
        
        --label:setWidth(listView:getContentSize().width)
        --label:ignoreContentAdaptWithSize(false)
        --label:setSize(listView:getContentSize().width, label:getContentSize().height)
        --label:setSize(560,100)
        
        local label_item = ccui.Layout:create()
        label_item:addChild(label)
        label_item:setContentSize(label:getBoundingBox())
        listView:pushBackCustomItem(label_item)

        --local mailGoodsinfo = {exp = 123,gold = 234}
        local mailGoodsinfo = mail.mailGoodsinfo
        local icon_item = ccui.Layout:create()

        local hasItems = 0
        local lineNum = 5
        local totalNum = 0
        local itemWidth = 90
        local offsetSrcX = (listView:getContentSize().width - lineNum * itemWidth)/(lineNum+1)

        for k,v in pairs(mailGoodsinfo) do
            if (type(v) == "number" and v > 0) or (type(v) == "table" and #v > 0)then 
                if k == "mailGoodsItem" then
                    local items = v
                    for key,value in pairs(items) do
                        totalNum = totalNum + 1
                    end
                elseif k == "gold" or k == "diamond" or k == "honor" or k == "meleeCoin" or k == "skillNum" or k == "raidsNum" then
                    totalNum = totalNum + 1
                end
            end
        end
        hasItems = totalNum

        local H = math.ceil((totalNum/lineNum)) * itemWidth
        local index = -1
        for k,v in pairs(mailGoodsinfo) do
            if (type(v) == "number" and v > 0) or (type(v) == "table" and #v > 0)then 
                local icon = nil
                if k == "mailGoodsItem" then
                    local items = v
                    for key,value in pairs(items) do
                        index = index + 1
                        if value.type == 1 or value.type == 3 then
                            icon = gameUtil.createEquipItem( value.id , value.num)
                        elseif value.type == 2 then
                            icon = gameUtil.createItemWidget( value.id , value.num)
                        elseif value.type == 4 then
                            --------------皮肤-------------
                            icon = gameUtil.createSkinIcon(value.id)
                        end
                        local scale = (84 / icon:getContentSize().width)
                        icon:setScale(scale)
                        icon:setAnchorPoint(cc.p(0.0,1.0))
                        local offsetX = (index % lineNum) * itemWidth + ((index%lineNum) + 1) * offsetSrcX
                        local offsetY = math.floor((index / lineNum)) * itemWidth
                        icon:setPosition(cc.p(offsetX,H-offsetY))
                        icon_item:addChild(icon)
                    end
                elseif k == "gold" or k == "diamond" or k == "honor" or k == "meleeCoin" or k == "skillNum" or k == "raidsNum" then
                    index = index + 1
                    if k == "gold" then
                        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinbi.png", v)
                    elseif k == "diamond" then
                        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_zuanshi.png", v)
                    elseif k == "honor" then
                        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_rongyu.png", v)--占用
                    elseif k == "meleeCoin" then
                        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_luandoubi.png", v)
                    elseif k == "skillNum" then
                        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinengdian.png", v)
                    elseif k == "raidsNum" then
                        icon = gameUtil.createIconWithNum("res/icon/jiemian/icon_jinshouzhi.png", v)
                    end
                    icon:setAnchorPoint(cc.p(0.0,1.0))
                    local offsetX = (index % lineNum) * itemWidth + ((index%lineNum) + 1) * offsetSrcX
                    local offsetY = math.floor((index / lineNum)) * itemWidth
                    icon:setPosition(cc.p(offsetX,H-offsetY))
                    icon_item:addChild(icon)
                end   
            end
        end
        icon_item:setContentSize(listView:getContentSize().width, (1 + math.floor((index / lineNum))) * itemWidth)
        listView:pushBackCustomItem(icon_item)

        local exp_item = ccui.Layout:create()
        index = -1
        itemWidth = 30
        for k,v in pairs(mailGoodsinfo) do
            if type(v) == "number" and v > 0 then 
                local icon = nil
                if k == "exp" or k == "exppool" then
                    index = index + 1
                    local titlePic = nil
                    if k == "exp" then
                        titlePic = cc.Sprite:create("res/UI/icon_EXPzhandui.png")
                    elseif k == "exppool" then
                        titlePic = cc.Sprite:create("res/UI/icon_EXPjingyanchi.png")
                    end
                    titlePic:setAnchorPoint(cc.p(0.0,1.0))

                    local ttfConfig = {}
                    ttfConfig.fontFilePath = "font/youyuan.TTF"
                    ttfConfig.fontSize = 25
                    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
                    ttfConfig.customGlyphs = nil
                    ttfConfig.distanceFieldEnabled = true
                    ttfConfig.outlineSize = 0
                    
                    local label = cc.Label:createWithTTF(ttfConfig,":"..v,cc.TEXT_ALIGNMENT_LEFT)
                    label:setAnchorPoint(cc.p(0.0,1.0))
                    label:setPosition(cc.p(titlePic:getContentSize().width + 5, 0))
                    label:setTextColor( cc.c4b(255, 255, 255, 255) )
                    --label:enableGlow(cc.c4b(255, 255, 0, 255))
                    --label:setString("")

                    icon = cc.Node:create()
                    icon:addChild(titlePic)
                    icon:addChild(label)

                    icon:setAnchorPoint(cc.p(0.0,1.0))
                    local offsetX = (listView:getContentSize().width / 2 ) * (0.2 + index)
                    local offsetY = itemWidth - 10
                    icon:setPosition(cc.p(offsetX,offsetY))
                    exp_item:addChild(icon)

                    hasItems = hasItems + 1
                end   
            end
        end
        exp_item:setContentSize(listView:getContentSize().width, itemWidth + 20)
        listView:pushBackCustomItem(exp_item)
        --local scaleY = youjianZKItem:getContentSize().height / (youjianZKItem:getContentSize().height-20)
        --youjianZKItem:setScaleY(scaleY)
        self.ListView:insertCustomItem(youjianZKItem,insertIndex)
        self.insertIndex = insertIndex
        if hasItems > 0 then 
            rewardBtn:setTitleText("领取")
        else
            rewardBtn:setTitleText("确定")
        end

        mm.req("readMail",{type = 1, id = mail.id})
    end
end

function youjianLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm:popLayer()
    end
end

function youjianLayer:jumptoBtc( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        local mail = nil
        local num  = #self.maillist
        for i=1,num do
            if self.maillist[i].tag == tag then
                mail = self.maillist[i]
                break
            end
        end
        if mail == nil then
            return
        end
        if mail.newMailType and mail.newMailType == 2 then
            mm.req("mailProcess",{type = 1, id = mail.id})
        end
        game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = mail.jumpto})
    end
end

function youjianLayer:rewardBtc( widget,touchkey )
    if touchkey == ccui.TouchEventType.ended then 
        local tag = widget:getTag()
        local mail = nil
        local num  = #self.maillist
        for i=1,num do
            if self.maillist[i].tag == tag then
                mail = self.maillist[i]
                break
            end
        end
        if mail == nil or mail.mailGoodsinfo == nil then
            return
        end
        ---------------领取邮件-------------
        --testMailList[1].mailGoodsinfo.mailGoodsItem[1].id = 1160785969 --多兰剑
        --mm.data.playerEquip = msg.playerEquip
        --mm.data.playerItem = msg.playerItem
        --mm.data.playerHunshi = msg.playerHunshi
        local needNotice = false

        local equipNum = {}
        local equipTypeNum = 0

        local hunshiNum = {}
        local hunshiTypeNum = 0

        local itemNum = {}
        local itemTypeNum = 0
        if mail.mailGoodsinfo.mailGoodsItem == nil then
            mail.mailGoodsinfo.mailGoodsItem = {}
        end
        for key,value in pairs(mail.mailGoodsinfo.mailGoodsItem) do
            --value.type value.id , value.num
            if value.type == 1 then
                equipTypeNum = equipTypeNum + 1
                equipNum[equipTypeNum] = {}
                equipNum[equipTypeNum].id = value.id
                equipNum[equipTypeNum].num = value.num
            elseif value.type == 3 then
                hunshiTypeNum = hunshiTypeNum + 1
                hunshiNum[hunshiTypeNum] = {}
                hunshiNum[hunshiTypeNum].id = value.id
                hunshiNum[hunshiTypeNum].num = value.num
            elseif value.type == 2 then
                itemTypeNum = itemTypeNum + 1
                itemNum[itemTypeNum] = {}
                itemNum[itemTypeNum].id = value.id
                itemNum[itemTypeNum].num = value.num
            end
        end

        -------------------------检查装备------------start----------------
        local wishEquip = util.copyTab(mm.data.playerEquip)
        for i,va in ipairs(equipNum) do
            local exist = false
            for j,vb in ipairs(wishEquip) do
                if va.id == vb.id then
                    wishEquip[j].num = vb.num + va.num
                    exist = true
                    break 
                end
            end
            if exist == false then
                local temp = util.copyTab(va)
                table.insert(wishEquip, temp)
            end
        end
        local fullEquip, allFullEquip = {}, 0
        if equipTypeNum > 0 then
            fullEquip, allFullEquip = gameUtil.getReGroupGoodsByListForMail(wishEquip, 0)
        end
        
        local realFullEquip = {}
        for i,va in ipairs(fullEquip) do
            for j,vb in ipairs(equipNum) do
                if va.id == vb.id then
                    local temp = util.copyTab(vb)
                    table.insert(realFullEquip,temp)
                    break
                end
            end
        end
        if #realFullEquip > 0 then
            needNotice = true
        end
        -------------------------检查装备------------end----------------
        
        -------------------------检查魂石------------start----------------
        local wishHunshi = util.copyTab(mm.data.playerHunshi)
        for i,va in ipairs(hunshiNum) do
            local exist = false
            for j,vb in ipairs(wishHunshi) do
                if va.id == vb.id then
                    wishHunshi[j].num = vb.num + va.num
                    exist = true
                    break 
                end
            end
            if exist == false then
                local temp = util.copyTab(va)
                table.insert(wishHunshi, temp)
            end
        end
        local fullHunshi, allFullHunshi =  {}, 0
        if hunshiTypeNum > 0 then
            fullHunshi, allFullHunshi = gameUtil.getReGroupGoodsByListForMail(wishHunshi, 0)
        end
        
        local realFullHunshi = {}
        for i,va in ipairs(fullHunshi) do
            for j,vb in ipairs(hunshiNum) do
                if va.id == vb.id then
                    local temp = util.copyTab(vb)
                    table.insert(realFullHunshi,temp)
                    break
                end
            end
        end
        if #realFullHunshi > 0 then
            needNotice = true
        end
        -------------------------检查魂石------------end----------------

        -------------------------检查Item------------start----------------
        local wishItem = util.copyTab(mm.data.playerItem)
        for i,va in ipairs(itemNum) do
            local exist = false
            for j,vb in ipairs(wishItem) do
                if va.id == vb.id then
                    wishItem[j].num = vb.num + va.num
                    exist = true
                    break 
                end
            end
            if exist == false then
                local temp = util.copyTab(va)
                table.insert(wishItem, temp)
            end
        end
        local fullItem, allFullItem = {}, 0
        if itemTypeNum > 0 then
            fullItem, allFullItem = gameUtil.getReGroupGoodsByListForMail(wishItem, 5)
        end
        local realFullItem = {}
        for i,va in ipairs(fullItem) do
            for j,vb in ipairs(itemNum) do
                if va.id == vb.id then
                    local temp = util.copyTab(vb)
                    table.insert(realFullItem,temp)
                    break
                end
            end
        end
        if #realFullItem > 0 then
            needNotice = true
        end        
        -------------------------检查item------------end----------------
        
        --needNotice = true
        -- if needNotice then
        --     --弹出提示界面
        --     local windowLayer = require("src.app.views.layer.MailItemWindow").new({param = {id = mail.id,equip = realFullEquip,hunshi = realFullHunshi,item = realFullItem,equipFull = allFullEquip,hunshiFull = allFullHunshi,itemFull = allFullItem}})
        --     local size  = cc.Director:getInstance():getWinSize()
        --     self:addChild(windowLayer)
        --     --windowLayer:setContentSize(cc.size(size.width, size.height))
        --     local windowSize = windowLayer:getContentSize()
        --     --windowLayer:setPosition(cc.p((size.width-windowSize.width)*0.5,0))
        --     ccui.Helper:doLayout(windowLayer)
        -- else
            --mm.req("getStoreInfo",{id = tag, type = 1})
            mm.req("mailProcess",{type = 1, id = mail.id})
        -- end

        --[[
        测试分组显示
        local testMailList = {}

        testMailList[1] = {}
        testMailList[1].id = 1160785969 --多兰剑
        testMailList[1].num = 1

        testMailList[2] = {}
        testMailList[2].id = 1160786226 --多兰剑
        testMailList[2].num = 10

        local text = gameUtil.getReGroupGoodsByList( testMailList, 1 )
        for k,v in pairs(text) do
        end
        --]]
    end
end

function youjianLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        ----------邮件领取完成删除------------------
        if event.code == "mailProcess" then
            if event.t.type == 0 then
                local mailID = event.t.id
                if self.insertIndex then
                    self.ListView:removeItem(self.insertIndex)
                    self.insertIndex = nil
                end
                -- local jumpto = nil
                if self.maillist then
                    local num  = #self.maillist
                    for i=1,num do
                        if self.maillist[i].tag == mailID then
                            local items = self.ListView:getItems()
                            for k,v in pairs(items) do
                                if v:getTag() == mailID then
                                    -- jumpto = self.maillist[i].jumpto
                                    local index = self.ListView:getIndex(v)
                                    self.ListView:removeItem(index)
                                    table.remove(self.maillist, i)
                                    break
                                end
                            end
                            break
                        end
                    end
                end
                mm.lastMaillist = self.maillist
                gameUtil.playUIEffect( "Reward_Get" )

                local num  = #self.maillist
                if num > 0 then
                    self.Node:getChildByName("Image_bg"):getChildByName("Text_None"):setVisible(false)
                    self:mailShuaxin(num)
                else
                    self.Node:getChildByName("Image_bg"):getChildByName("Text_None"):setVisible(true)
                    self:mailShuaxin(0)
                end
                -- -- 跳转
                -- if jumpto and jumpto ~= "" then
                --     game:dispatchEvent({name = EventDef.UI_MSG, code = "jumpToLayer", layerName = jumpto})
                -- end
            else
                gameUtil:addTishi({p = self.scene, s = event.t.message, z = 1000000})
            end
        end
        
    end
end


return youjianLayer