local TalkLayer = class("TalkLayer", require("app.views.mmExtend.LayerBase"))
TalkLayer.RESOURCE_FILENAME = "TalkLayer.csb"

function TalkLayer:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function TalkLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "talk" then
            self:ReceiveTalk(event.t)
        end
    end
end

function TalkLayer:onEnter()
    
end

function TalkLayer:onExit()
    
end

function TalkLayer:onEnterTransitionFinish()
    
end

function TalkLayer:onExitTransitionStart()
    
end

function TalkLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function TalkLayer:init(param)

    self.isNew = param.isNew

    self.Node = self:getResourceNode()

    self.ListView = self.Node:getChildByName("ListView_1")
    

    -- 世界按钮
    self.worldBtn = self.Node:getChildByName("Button_zhenying")
    self.worldBtn:addTouchEventListener(handler(self, self.LabelBtnCbk))
    self.worldBtn:setTag(2)
    -- 阵营按钮
    self.campBtn = self.Node:getChildByName("Button_shijie")
    self.campBtn:addTouchEventListener(handler(self, self.LabelBtnCbk))
    self.campBtn:setTag(3)
    -- 战斗按钮
    self.fightingBtn = self.Node:getChildByName("Button_zhandou")
    self.fightingBtn:addTouchEventListener(handler(self, self.LabelBtnCbk))
    self.fightingBtn:setTag(4)

    self.systemBtn = self.Node:getChildByName("Button_siliao")
    self.systemBtn:addTouchEventListener(handler(self, self.LabelBtnCbk))
    self.systemBtn:setTag(5)
    self.systemBtn:setVisible(true)
    self.systemBtn:setTouchEnabled(true)

    if self.isNew then
        gameUtil.addNewImg( self.fightingBtn, 50 )
    end

    -- -- 私聊按钮
    -- self.whisperBtn = self.Node:getChildByName("Button_siliao")
    -- self.whisperBtn:addTouchEventListener(handler(self, self.LabelBtnCbk))
    -- self.whisperBtn:setTag(2)
    -- ok按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(self.backBtn)

    -- 输入框
    local editBox = cc.EditBox:create(cc.size(390,55), cc.Scale9Sprite:create("res/UI/jm_shurukuang.png"))
    editBox:setAnchorPoint(0,0.5)
    editBox:setFont("res/font/youyuan.TTF", 30)
    self.editBox = editBox

    local nodeShuru = self.Node:getChildByName("Node")
    nodeShuru:addChild(editBox)

    -- 发送按钮
    self.sendBtn = self.Node:getChildByName("Button_send")
    self.sendBtn:addTouchEventListener(handler(self, self.sendBtnCbk))
    gameUtil.setBtnEffect(self.sendBtn)

    self:setBtn(self.worldBtn)
    self:updateTalk(self.Channel)
    
    
end

function TalkLayer:ReceiveTalk(event)
    if event.type == -1 then
        gameUtil:addTishi({p = self, s = MoGameRet[990001]})
    elseif event.type == 0 then
        mm.data.playerinfo = event.playerInfo or mm.data.playerinfo
        mm.data.playerItem = event.playerItem or mm.data.playerItem
        mm.data.playerTaskProc.dailyTalkCount = event.dailyTalkCount or mm.data.playerTaskProc.dailyTalkCount

        self:updateBottom()
    elseif event.type == 2 then
        mm.data.playerinfo = event.playerInfo or mm.data.playerinfo
        self.notice = cc.CSLoader:createNode("wangluolianjie.csb")
        self:addChild(self.notice)
        local size  = cc.Director:getInstance():getWinSize()
        self.notice:setContentSize(cc.size(size.width, size.height))
        ccui.Helper:doLayout(self.notice)

        local okBtn = self.notice:getChildByName("Button_ok")
        okBtn:setZoomScale(-okBtn:getZoomScale())
        okBtn:setPressedActionEnabled(true)
        okBtn:addTouchEventListener(handler(self, self.tempOkBtnCbk))
        
        local date = os.date("*t", mm.data.playerinfo.talkOpenTime)
        local str = string.format("%04d-%02d-%02d %02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
        self.notice:getChildByName("Text_tishi"):setString("您已被禁言\n解除时间"..str)

        self:updateBottom()
    else
        mm.data.playerinfo = event.playerInfo or mm.data.playerinfo
        self:updateTalk(self.Channel)
    end
end

function TalkLayer:tempOkBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.notice then
            self.notice:removeFromParent()
            self.notice = nil
        end
    end
end

local colorType = {
            cc.c4b(255,255,255,255),
            cc.c4b(22, 206, 22,255),
            cc.c4b(16, 146, 252,255),
            cc.c4b(240,0,255,255),
            cc.c4b(255,162,0,255),
            cc.c4b(246,208,0,255),
            cc.c4b(246,208,0,255),
        }

function TalkLayer:createText( t, size )
    local size = size or 24
    if t and t.str then
        local talkText = ccui.Text:create(t.str, "fonts/huakang.TTF", size)
        talkText:setColor(cc.c3b(255, 255, 255))
        talkText:setAnchorPoint(cc.p(0,0))
        talkText:ignoreContentAdaptWithSize(false)

        if  t.guajiResult then
            if t.guajiResult ~= 1 then
                talkText:setColor(cc.c3b(255, 0, 0))
            else
                talkText:setColor(cc.c3b(22, 206, 22))
            end
        end

        return talkText
    end
    return nil
end



function TalkLayer:createTtemText( t, size )
    local size = size or 24
    if t and t.str then

        local wupinT = t.wupinT
        local color = colorType[1]
        if wupinT then
            color = colorType[wupinT.Quality]
        end
        
        local talkText = ccui.Text:create(t.str, "fonts/huakang.TTF", size)
        talkText:setColor(color)
        talkText:setAnchorPoint(cc.p(0,0))
        talkText:ignoreContentAdaptWithSize(false)
        return talkText
    end
    return nil
end


function TalkLayer:updateTalk(Channel)
    self.ListView:removeAllItems()
    if (not mm.talkMsg) or (not mm.talkMsg[Channel]) or (#mm.talkMsg[Channel] == 0) then
        return
    end
    local data = mm.talkMsg[Channel]
    while #data > 30 do
        table.remove(data, 1)
    end

    if Channel == 4 then

        print("111111111111111111111updateTalk            ")
        for i=1,#data do
            local custom_item2 = ccui.Layout:create()
            local TalkItem2 = ccui.Layout:create()--cc.CSLoader:createNode("TalkItem_0.csb")

            local di = TalkItem2--:getChildByName("Panel_1")
            di:setSwallowTouches(false)

            -- local color = cc.c3b(255,255,255)
            -- if data[i]["fromid"] == 0 then
            --     color = cc.c3b(255, 0, 0)
            --     di:setVisible(false)
            -- else

            -- end
            local tab = data[i]
            local labelTab = {}
            table.insert(labelTab, self:createText( tab.biaoti, 30 ))
            table.insert(labelTab, self:createText( tab.addGold ))
            table.insert(labelTab, self:createText( tab.addExp ))
            table.insert(labelTab, self:createText( tab.addExppool ))
            table.insert(labelTab, self:createText( tab.addhonors ))
            table.insert(labelTab, self:createText( tab.pkbi ))
            
            if tab.drop and #tab.drop > 0 then
                for i=1,#tab.drop do
                    table.insert(labelTab, self:createTtemText( tab.drop[i] ))
                end
            end
            local hh = #labelTab*30+25
            for i=1,#labelTab do
                di:addChild(labelTab[i])
                labelTab[i]:setPosition(20, hh - i * 30 - 15)
                -- labelTab[i]:setContentSize(460,labelTab[i]:getContentSize().height)
                print("111111111111111111111updateTalk        111111111    ")
            end
            print("111111111111111111111updateTalk       222222222     ")
            di:setContentSize(cc.size(500, hh))
            TalkItem2:setContentSize(di:getContentSize())
            custom_item2:setContentSize(di:getContentSize())
            custom_item2:addChild(TalkItem2)
            
            self.ListView:pushBackCustomItem(custom_item2)
        end




        if self.fightingBtn:getChildByName("newHint") then
            self.fightingBtn:getChildByName("newHint"):setVisible(false)
        end

        mm.GuildScene:detalkBtnNew()



    else
        print("111111111111111111111updateTalk     333333333333       "..#data)
        for i=1,#data do
            print("111111111111111111111updateTalk      444444444444      ")
            local custom_item = ccui.Layout:create()
            local custom_item2 = ccui.Layout:create()
            local TalkItem = cc.CSLoader:createNode("TalkItem.csb")
            local TalkItem2 = cc.CSLoader:createNode("TalkItem_0.csb")
            custom_item:addChild(TalkItem)
            if Channel == 2 or Channel == 5 then
                TalkItem:getChildByName("Image_1"):loadTexture("res/UI/icon_liaotian_shijie.png")
            elseif Channel == 3 then
                TalkItem:getChildByName("Image_1"):loadTexture("res/UI/icon_liaotian_zhenying.png")
            else
                TalkItem:getChildByName("Image_1"):loadTexture("res/UI/icon_liaotian_shijie.png")
            end

            TalkItem:getChildByName("Text_name"):setText(data[i]["fromname"])
            local Text_Content = TalkItem:getChildByName("Text_7")

            local di = TalkItem2:getChildByName("Panel_1")
            di:setSwallowTouches(false)
            local color = cc.c3b(255,255,255)

            if data[i]["fromid"] == 0 and Channel == 5 then
                color = cc.c3b(255, 0, 0)
                di:setVisible(false)
                TalkItem:getChildByName("Image_9"):getChildByName("Text_lv"):setString("99")
                gameUtil.setVipLevel( TalkItem:getChildByName("Image_9"):getChildByName("Node"), 99 )
            else
                TalkItem:getChildByName("Image_9"):getChildByName("Text_lv"):setString(data[i]["lv"])
                gameUtil.setVipLevel( TalkItem:getChildByName("Image_9"):getChildByName("Node"), data[i]["vipLv"] )
            end
            local re1 = ccui.RichElementText:create(1, color, 255, data[i]["message"], "", 30)
            local richText = ccui.RichText:create()
            local hang = gameUtil.getStringHang(data[i]["message"])
            richText:pushBackElement(re1)
            richText:ignoreContentAdaptWithSize(false)
            richText:setContentSize(cc.size(di:getContentSize().width - 60, hang*30+10))
            richText:setAnchorPoint(cc.p(0, 0))
            di:setAnchorPoint(cc.p(0, 0))
            richText:formatText()
            richText:setPosition(cc.p(10, 0))
            local rs = richText:getBoundingBox()

            di:setContentSize(cc.size(di:getContentSize().width, hang*30+25))
            TalkItem2:addChild(richText)
            TalkItem2:setContentSize(di:getContentSize())
            custom_item2:setContentSize(di:getContentSize())
            custom_item2:addChild(TalkItem2)
            
            custom_item:setContentSize(TalkItem:getContentSize())

            self.ListView:pushBackCustomItem(custom_item)
            self.ListView:pushBackCustomItem(custom_item2)
        end
    end

    performWithDelay(self,function( ... )
        self.ListView:jumpToBottom()
    end, 0.01)

    self:updateBottom()
end


function TalkLayer:setBtn(btn)
    -- 设置按钮状态
    self.worldBtn:setBright(true)
    self.campBtn:setBright(true)
    self.fightingBtn:setBright(true)
    self.systemBtn:setBright(true)
    -- self.whisperBtn:setBright(true)
    self.Node:getChildByName("Image_1"):setVisible(true)
    self.sendBtn:setVisible(true)
    self.editBox:setVisible(true)


    btn:setBright(false)
    self.Channel = btn:getTag()

    self:updateBottom()
end

function TalkLayer:updateBottom()
    if self.Channel == 2 then
        local num = gameUtil.getSmallLaBaNum()
        if num <= 0 then
            self.sendBtn:getChildByName("Text_num"):setVisible(true)
            self.sendBtn:getChildByName("Image_3"):setVisible(true)
            self.editBox:setPlaceHolder(MoGameRet[990038])
            self.sendBtn:getChildByName("Text_num"):setString(mm.data.playerinfo.diamond)
            self.sendBtn:getChildByName("Image_3"):loadTexture("res/UI/pc_zuanshi.png")
        else
            local str
            if num >= 100 then
                str = "(99+)"
            else
                str = "("..num..")"
            end
            self.sendBtn:getChildByName("Text_num"):setString(str)
            self.editBox:setPlaceHolder(MoGameRet[990039])
            self.sendBtn:getChildByName("Image_3"):setVisible(true)
            self.sendBtn:getChildByName("Text_num"):setVisible(true)
            self.sendBtn:getChildByName("Image_3"):loadTexture("res/UI/bt_laba.png")
        end
    elseif self.Channel == 3 then
        self.sendBtn:getChildByName("Text_num"):setVisible(false)
        self.sendBtn:getChildByName("Image_3"):setVisible(false)
        self.editBox:setPlaceHolder(MoGameRet[990040])
    elseif self.Channel == 4 then
        self.Node:getChildByName("Image_1"):setVisible(false)
        self.sendBtn:setVisible(false)
        self.editBox:setVisible(false)
    elseif self.Channel == 5 then
        self.Node:getChildByName("Image_1"):setVisible(false)
        self.sendBtn:setVisible(false)
        self.editBox:setVisible(false)
    end
end

function TalkLayer:LabelBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:updateTalk(widget:getTag())
        self:setBtn(widget)
    end
end

function TalkLayer:sendBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local endTime = os.clock()
        if endTime - self.touchTime > 2 and self.showFlag == nil then
            self:showTalkMsgBox(self)
            self.showFlag = 1
        else
            if self.showFlag == nil then
                self.showFlag = 1
                local text = self.editBox:getText()
                if text == nil or #text == 0 then
                    gameUtil:addTishi({p = self, s = MoGameRet[990037]})
                    return
                end
                if gameUtil.getRealCharNum(text) > 70 then
                    self.editBox:setText(text)
                    gameUtil:addTishi({p = self, s = "聊天内容不能超过70字"})
                    return
                end
                mm.req("talk",{type=self.Channel,playerid=mm.data.playerinfo.id,message=text})
                self.editBox:setText("")
            end
        end
    elseif touchkey == ccui.TouchEventType.began then
        self.touchTime = os.clock()
        self.showFlag = nil 
        performWithDelay(self, function()
            if not self.showFlag then
                self:showTalkMsgBox(self)
                self.showFlag = 1
            end
        end, 1)
    elseif touchkey == ccui.TouchEventType.canceled then
        local endTime = os.clock()
        if endTime - self.touchTime > 2 and self.showFlag == nil then
            self:showTalkMsgBox(self)
        end
        self.showFlag = 1
    end
end

function TalkLayer:showTalkMsgBox(layer)
    self.messageBox = cc.CSLoader:createNode("talkMsgBox.csb")
    layer:addChild(self.messageBox)
    local size  = cc.Director:getInstance():getWinSize()
    self.messageBox:setContentSize(cc.size(size.width, size.height))
    ccui.Helper:doLayout(self.messageBox)

    local okBtn = self.messageBox:getChildByName("Image_bg"):getChildByName("Button_ok")
    gameUtil.setBtnEffect(okBtn)
    okBtn:addTouchEventListener(handler(self, self.okBtnCbk))

    if gameUtil.getBigLaBaNum() > 0 then
        self.messageBox:getChildByName("Image_bg"):getChildByName("Text_msg"):setString(MoGameRet[990041])
        self.messageBox:getChildByName("Image_bg"):getChildByName("Image_diamond"):setVisible(false)
    else
        self.messageBox:getChildByName("Image_bg"):getChildByName("Text_msg"):setString(MoGameRet[990042])
    end

    local backBtn = self.messageBox:getChildByName("Image_bg"):getChildByName("Button_back")
    gameUtil.setBtnEffect(backBtn)
    backBtn:addTouchEventListener(handler(self, self.closeBox))
end

function TalkLayer:closeBox(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        if self.messageBox ~= nil then
            self.messageBox:removeFromParent()
        end
    end
end

local function dealName(str)
    local name = ""
    for i=1,#str do
        local v = string.sub(str, i, i)
        if v ~= '\r' and v ~= '\n' then
            name = name..v
        end
    end
    return name
end


function TalkLayer:okBtnCbk(widget, touchkey)
    if touchkey == ccui.TouchEventType.ended then
        local text = self.editBox:getText()
        if text == nil or #text == 0 then
            gameUtil:addTishi({p = self, s = MoGameRet[990037]})
            return
        end
        mm.req("talk",{type=1,playerid=mm.data.playerinfo.id,message=dealName(text)})
        self.editBox:setText("")
        self.messageBox:removeFromParent()
    end
end

function TalkLayer:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return TalkLayer
