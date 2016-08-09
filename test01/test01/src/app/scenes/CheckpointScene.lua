-- require("app/res/MoResConstants")
require("app/res/BeastTableRes")
require("app/res/BossTableRes")
require("app/res/CheckpointTableRes")
require("app/res/ItemTableRes")

local __one = {class=cc.FilteredSpriteWithOne}

local CheckpointScene = class("CheckpointScene", function()
    return display.newScene("CheckpointScene")
end)

function CheckpointScene:ctor()
    self.Bg = display.newSprite("res/loginUI/bm_beijing1.jpg")
    self.Bg:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.Bg)
    self.Bg:setPosition(display.cx, display.cy)

    self:addUI()
    self:createPageView()

    
end

function CheckpointScene:addUI( ... )


    local addImg = ccui.ImageView:create()
    addImg:loadTexture("res/checkpointUI/bm_biaoti.png")
    self:addChild(addImg)
    addImg:setPosition(display.cx,display.top - 65)
    addImg:setAnchorPoint(cc.p(0.5, 0.5))

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "关卡选择",
        font  = "font/huakang.TTF",
        size = 36,
    })
    :align(display.CENTER, display.cx,display.top - 55)
    :addTo(self)

    self.backButton = cc.ui.UIPushButton.new({normal = "res/checkpointUI/check_ui/bt_fanhui.png", 
                                                pressed = "res/checkpointUI/check_ui/bt_fanhui.png", 
                                                disabled = "res/checkpointUI/check_ui/bt_fanhui.png"})
    :align(display.RIGHT_TOP, display.right - 10, display.top - 10)
    :addTo(self)
    self.backButton:onButtonClicked(function(tag)
        self:backBtnCbk()
    end)

    self.shangButton = cc.ui.UIPushButton.new({normal = "res/checkpointUI/check_ui/bt_shang.png", 
                                                pressed = "res/checkpointUI/check_ui/bt_shang.png", 
                                                disabled = "res/checkpointUI/check_ui/bt_shang.png"})
    :align(display.CENTER, display.left + 160, display.top - 60)
    :addTo(self)
    self.shangButton:onButtonClicked(function(tag)
        self:leftBtnCbk()
    end)


    self.xiaButton = cc.ui.UIPushButton.new({normal = "res/checkpointUI/check_ui/bt_xia.png", 
                                                pressed = "res/checkpointUI/check_ui/bt_xia.png", 
                                                disabled = "res/checkpointUI/check_ui/bt_xia.png"})
    :align(display.CENTER, display.left + 160, display.bottom + 60)
    :addTo(self)
    self.xiaButton:onButtonClicked(function(tag)
        self:rightBtnCbk()
    end)


    local img_dsc_bg = ccui.ImageView:create()
    img_dsc_bg:loadTexture("res/checkpointUI/check_ui/bm_miaoshudi.png")
    img_dsc_bg:setPosition(display.left + 280, display.bottom + 100)
    img_dsc_bg:setAnchorPoint(cc.p(0, 0))
    img_dsc_bg:setTouchEnabled(false)
    self:addChild(img_dsc_bg)


    self.img_dsc = ccui.ImageView:create()
    self.img_dsc:loadTexture("res/checkpointUI/check_ui/bm_miaoshudi.png")
    self.img_dsc:setPosition(display.left + 285, display.bottom + 5)
    self.img_dsc:setAnchorPoint(cc.p(0, 0))
    self.img_dsc:setTouchEnabled(false)
    self:addChild(self.img_dsc)

    self.dscText = {}
    self.dscText[1] = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = tostring("第一章"),
        font  = "font/youyuan.TTF",
        size = 40,
    })
    :align(display.CENTER, 480 , 220)
    :addTo(self)

    self.dscText[2] = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = tostring("沙漠皇帝"),
        font  = "font/youyuan.TTF",
        size = 26,
    })
    :align(display.CENTER, 480 , 180)
    :addTo(self)

    self.dscText[3] = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = tostring("小新小新小新小新小新小新小新小新小新"),
        font  = "font/youyuan.TTF",
        size = 30,
    })
    :align(display.LEFT_TOP, 360 , 165)
    :addTo(self)
    self.dscText[3]:setWidth(400)

    self.dscText[4] = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = tostring("掉落："),
        font  = "font/youyuan.TTF",
        size = 36,
        color = cc.c3b(255,215,0)
    })
    :align(display.BOTTOM_LEFT, 380 , 40)
    :addTo(self)

    self.enter_btn = cc.ui.UIPushButton.new({normal = "res/checkpointUI/check_ui/bt_oneanniu_n.png", 
                                                    pressed = "res/checkpointUI/check_ui/bt_oneanniu_n.png", 
                                                    disabled = "res/checkpointUI/check_ui/bt_oneanniu_p.png"})
    :align(display.BOTTOM_RIGHT, display.right - 50, display.bottom + 50)
    :addTo(self)
    :setButtonLabel(cc.ui.UILabel.new({text = "挑战", size = 40,  color = cc.c3b(255, 255, 255)}))


    self.enter_btn:onButtonClicked(function(event)
        self:EnterFight(event)
    end)

    self.dscText[5] = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = tostring("消耗：10"),
        font  = "font/youyuan.TTF",
        size = 28,
        color = cc.c3b(255,255,255)
    })
    :align(display.BOTTOM_RIGHT, display.right - 100, display.bottom + 10)
    :addTo(self)

    local tiliImg = ccui.ImageView:create()
    tiliImg:loadTexture("res/mainUI/bt_tili.png")
    tiliImg:setPosition(display.right - 80, display.bottom + 10)
    tiliImg:setAnchorPoint(cc.p(0, 0))
    tiliImg:setTouchEnabled(false)
    self:addChild(tiliImg)

    self.itemTab = {}
    for i=1,3 do
        self.itemTab[i] = ccui.ImageView:create()
        self.itemTab[i]:loadTexture("res/icon/item/I044.png")
        self.itemTab[i]:setPosition(500 + (i - 1) * 110, display.bottom + 5)
        self.itemTab[i]:setAnchorPoint(cc.p(0, 0))
        self.itemTab[i]:setTouchEnabled(false)
        self:addChild(self.itemTab[i]) 
    end
end

function CheckpointScene:createPageView()
    local curCheckPoint = self:getCurCheckPoint()

    local chapterNumber = 7
    
    self.imgTab = {}
    self.curOpenItem = CheckpointTable[curCheckPoint]["chapter"]
    self.curOpenItemJie = CheckpointTable[curCheckPoint]["section"]

    
    self.check_img = {}
    self.check_suo = {}
    self.check_btn = {}
    self.check_pos = {}
    self.check_pos[1] = {x= display.left + 450, y = display.bottom + 380}
    self.check_pos[2] = {x= display.left + 680, y = display.bottom + 420}
    self.check_pos[3] = {x= display.left + 910, y = display.bottom + 380}


    for i=1,3 do
        self.check_img[i] = display.newSprite(nil, nil,nil , __one)
        self.check_img[i]:setTexture("res/checkpointUI/check_res/c_01/a01.png")
        self.check_img[i]:setPosition(self.check_pos[i].x, self.check_pos[i].y)
        self.check_img[i]:setAnchorPoint(cc.p(0.5, 0.5))
        self.check_img[i]:setTouchEnabled(false)
        self:addChild(self.check_img[i])
        self.check_img[i]:setScale(0.9)

        self.check_suo[i] = ccui.ImageView:create()
        self.check_suo[i]:loadTexture("res/checkpointUI/check_ui/bm_suo.png")
        self.check_suo[i]:setPosition(self.check_pos[i].x, self.check_pos[i].y)
        self.check_suo[i]:setAnchorPoint(cc.p(0.5, 0.5))
        self.check_suo[i]:setTouchEnabled(false)
        self.check_suo[i]:setVisible(false)
        self:addChild(self.check_suo[i])

        self.check_btn[i] = cc.ui.UIPushButton.new({normal = "res/checkpointUI/check_ui/bt_xuanguan_normal.png", 
                                                    pressed = "res/checkpointUI/check_ui/bt_xuanguan_press.png", 
                                                    disabled = "res/checkpointUI/check_ui/bt_xuanguan_press.png"})
        :align(display.CENTER, self.check_pos[i].x, self.check_pos[i].y)
        :addTo(self)
        self.check_btn[i]:onButtonClicked(function(event)
            self:btn02BtnCbk(event)
        end)
        self.check_btn[i]:setTag(i)
    

    end
    
    local item_width = 291
    local item_height = 183

    self.pv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "res/checkpointUI/bm_xuangguandi.png",
        viewRect = cc.rect(display.left + 20, display.left + 100, item_width, item_height * 2.5),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :onTouch(handler(self, self.touchListener))
        :addTo(self)





    
    -- add items
    for i=1,chapterNumber do

        local str = "A" .. string.format("%03d",((i - 1)* 3 + 1))
        print(" str "..str)
        local id = util.getNumFormChar(str, 4)
        local zhangTab = CheckpointTable[id]



        local item = self.pv:newItem()
        
        local img = display.newSprite(nil, nil,nil , __one)
        img:setTexture("res/checkpointUI/check_res/"..zhangTab["c_res"].."/".."b01.png")
        img:setPosition(item_width*0.5, item_height)
        img:setAnchorPoint(cc.p(0.5, 0.5))
        img:setTouchEnabled(false)
        self.imgTab[i] = img

        if i > self.curOpenItem then
            img:setFilter(filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1}))
        end

        if self.curOpenItem ~= i then
            img:setScale(0.8)
        else
            self.img_dsc:loadTexture("res/checkpointUI/check_res/"..zhangTab["c_res"].."/".."b02.png")
            self:updateDsc(i)
            self.enterBtnTag = id

            self:setCheckBtn(self.curOpenItemJie)

            self:updateContent(curCheckPoint)
        end

        local textLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = tostring(zhangTab["chapter_t"]),
            font  = "font/youyuan.TTF",
            size = 40,
        })
        :align(display.BOTTOM_LEFT, 20 , 20)
        :addTo(img)

 
        item:addContent(img)

        item:setItemSize(item_width, item_height)
        
        self.pv:addItem(item)        
    end
    self.pv:reload(self.curOpenItem)



    

    

        
        

end

function CheckpointScene:updateContent(id)
    print("idid "..id)
    local zhangTab = CheckpointTable[id]

    self.dscText[1]:setString(zhangTab["chapter_t"])
    self.dscText[2]:setString(zhangTab["section_name"])
    self.dscText[3]:setString(zhangTab["chapter_dsc"])

    local t = zhangTab["item_ID"]
    
    for i=1,3 do
        print("t[i]  "..t[i])
        print(" "..Item[t[i]]["item_res"])
        if t[i] then
            self.itemTab[i]:loadTexture(Item[t[i]]["item_res"]..".png")
            self.itemTab[i]:setVisible(true)
        else
            self.itemTab[i]:setVisible(false)
        end
    end

end

function CheckpointScene:updateDsc(index)
    
    

    for i=1,3 do
        local str = "A" .. string.format("%03d",((index - 1)* 3 + i))
        print(" str "..str)
        local id = util.getNumFormChar(str, 4)
        local zhangTab = CheckpointTable[id]

        local curCheckPoint = self:getCurCheckPoint()


        self.check_img[i]:setTexture("res/checkpointUI/check_res/"..zhangTab["c_res"].."/".."a01.png")

        -- self.check_btn[i]:setTag(id)

        print(" id "..id)
        print(" curCheckPoint "..curCheckPoint)
        if id > curCheckPoint then
            self.check_suo[i]:setVisible(true)
            self.check_img[i]:setFilter(filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1}))
        else
            self.check_suo[i]:setVisible(false)
            self.check_img[i]:clearFilter()
        end

    end

end


---------------------

--章节描述


        
---------------------

function CheckpointScene:touchListener(event)
    dump(event, "TestUIPageViewScene - event:")
    if event.name == "clicked" then
        if self.curOpenItem ~= event.itemPos then
            self.imgTab[self.curOpenItem]:setScale(0.8)
            self.imgTab[event.itemPos]:setScale(1)
            self.curOpenItem = event.itemPos
            self:updateDsc(event.itemPos)


            self:setCheckBtn( 1 )

            local str = "A" .. string.format("%03d",((event.itemPos - 1)* 3 + 1))
            print(" str "..str)
            local id = util.getNumFormChar(str, 4)
            self:updateContent(id)

            self.enterBtnTag = id
        end

    end

    

end

function CheckpointScene:setCheckBtn( index )
    for i=1,3 do
        if i == index then
            self.check_img[i]:setScale(1)
            self.check_btn[i]:setButtonEnabled(false)
        else
            self.check_img[i]:setScale(0.9)
            self.check_btn[i]:setButtonEnabled(true)
        end
    end
end


function CheckpointScene:getCurCheckPoint( ... )
    local id = cc.UserDefault:getInstance():getIntegerForKey("checkId", 1093677105)
    print("CheckpointScene:getCurCheckPoint "..id)
    return id
end



function CheckpointScene:backBtnCbk()  
    appInstance:enterMainScene()
end

function CheckpointScene:leftBtnCbk()  

end

function CheckpointScene:rightBtnCbk()  

end

function CheckpointScene:btn01BtnCbk()  

end

function CheckpointScene:btn02BtnCbk(event)  
    -- appInstance:enterMenuScene()

    local index = event.target:getTag()
    local str = "A" .. string.format("%03d",((self.curOpenItem - 1)* 3 + index))
    print(" str "..str)
    local id = util.getNumFormChar(str, 4)

    self.enterBtnTag = id
    self:updateContent(id)

    self:setCheckBtn( index )
end

function CheckpointScene:btn03BtnCbk()  

end

function CheckpointScene:EnterFight(event)  
    -- appInstance:enterMenuScene()

    local id = self.enterBtnTag
    local curCheckPoint = self:getCurCheckPoint()
    print(" id "..id)
    print(" curCheckPoint "..curCheckPoint)
    if id > curCheckPoint then
        print(" 未解锁 ")
    else
        appInstance:enterMenuScene({id})
    end

end

return CheckpointScene



-- if id == curCheckPoint then
        --     curOpenItem = i
        -- end
        -- if id > curCheckPoint then
        --     local img = ccui.ImageView:create()
        --     img:loadTexture("res/checkpointUI/bm_suo.png")
        --     img:setPosition(180, 125)
        --     img:setAnchorPoint(cc.p(0.5, 0.5))
        --     img:setTouchEnabled(false)
        --     item:addChild(img)
        -- end

        -- self.btn01Button = cc.ui.UIPushButton.new({normal = "res/checkpointUI/bt_xuanguan_normal.png", 
        --                                             pressed = "res/checkpointUI/bt_xuanguan_press.png", 
        --                                             disabled = "res/checkpointUI/bt_xuanguan_press.png"})
        -- :align(display.CENTER, 180, 125)
        -- :addTo(item)
        -- self.btn01Button:onButtonClicked(function(tag)
        --     self:btn02BtnCbk(id)
        -- end)
        -- -- self.btn01Button:setTag(i)
        
        -- local img = ccui.ImageView:create()
        -- img:loadTexture("res/checkpointUI/bm_guanqia01_a01.png")
        -- img:setPosition(360, 125)
        -- img:setAnchorPoint(cc.p(0.5, 0.5))
        -- img:setTouchEnabled(false)
        -- item:addChild(img)

        -- local str = "A" .. string.format("%03d",((i - 1)* 3 + 2))
        -- print(" str "..str)
        -- local id = util.getNumFormChar(str, 4)
        -- if id == curCheckPoint then
        --     curOpenItem = i
        -- end
        -- if id > curCheckPoint then
        --     local img = ccui.ImageView:create()
        --     img:loadTexture("res/checkpointUI/bm_suo.png")
        --     img:setPosition(360, 125)
        --     img:setAnchorPoint(cc.p(0.5, 0.5))
        --     img:setTouchEnabled(false)
        --     item:addChild(img)
        -- end

        -- self.btn02Button = cc.ui.UIPushButton.new({normal = "res/checkpointUI/bt_xuanguan_normal.png", 
        --                                             pressed = "res/checkpointUI/bt_xuanguan_press.png", 
        --                                             disabled = "res/checkpointUI/bt_xuanguan_press.png"})
        -- :align(display.CENTER, 360 , 125)
        -- :addTo(item)
        -- self.btn02Button:onButtonClicked(function(tag)
        --     self:btn02BtnCbk(id)
        -- end)
        -- -- self.btn02Button:setTag(i)

        -- local label = cc.ui.UILabel.new({
        --     UILabelType = 2,
        --     text  = "体力:10",
        --     font  = "font/huakang.TTF",
        --     size = 36,
        -- })
        -- :align(display.CENTER, 360 , 30)
        -- :addTo(item)

        -- local img = ccui.ImageView:create()
        -- img:loadTexture("res/checkpointUI/bm_guanqia01_a01.png")
        -- img:setPosition(540, 125)
        -- img:setAnchorPoint(cc.p(0.5, 0.5))
        -- img:setTouchEnabled(false)
        -- item:addChild(img)

        -- local str = "A" .. string.format("%03d",((i - 1)* 3 + 3))
        -- print(" str "..str)
        -- local id = util.getNumFormChar(str, 4)
        -- if id == curCheckPoint then
        --     curOpenItem = i
        -- end
        -- if id > curCheckPoint then
        --     local img = ccui.ImageView:create()
        --     img:loadTexture("res/checkpointUI/bm_suo.png")
        --     img:setPosition(540, 125)
        --     img:setAnchorPoint(cc.p(0.5, 0.5))
        --     img:setTouchEnabled(false)
        --     item:addChild(img)
        -- end

        -- self.btn03Button = cc.ui.UIPushButton.new({normal = "res/checkpointUI/bt_xuanguan_normal.png", 
        --                                             pressed = "res/checkpointUI/bt_xuanguan_press.png", 
        --                                             disabled = "res/checkpointUI/bt_xuanguan_press.png"})
        -- :align(display.CENTER, 540, 125)
        -- :addTo(item)
        -- self.btn03Button:onButtonClicked(function(tag)
        --     self:btn02BtnCbk(id)
        -- end)
        -- -- self.btn02Button:setTag(i)
