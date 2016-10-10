
require("app/res/ItemTableRes")
require("app/res/FlowerTableRes")


local __one = {class=cc.FilteredSpriteWithOne}
game = game or {}


local scheduler = cc.Director:getInstance():getScheduler()

local GardenScene = class("GardenScene", function()
    return display.newScene("GardenScene")
end)

function GardenScene:ctor()
    self.Bg = display.newSprite("res/gardenUI/bm_huayuanBJ.jpg")
    self.Bg:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.Bg)
    self.Bg:setPosition(display.cx, display.cy)

    local reqTab = {}
    game.clientTCP:send("gardenEnter", reqTab, handler(self, self.gardenEnterBack))



    -- self:initDate({id = game.uid, name = "我的", lv = "10", isHelp = 0})
    
    

    self.rate_ = 0.016
    self.time = 0
    self:start_monster_scheduler()
end

-- function GardenScene:initDate( t )
--     self.uid = game.uid
--     self.curUid = t.id or 1000001

--     if game.gardenDate then
--         self.gardenDate = game.gardenDate
--     else
--         self.gardenDate = {
--             [1] = {id = 1177563185, startTime = 1470628800,work = {},},
--             [2] = {id = 1177563185, startTime = 1470572400,work = {},},
--             [3] = {id = 1177563185, startTime = 1470564000,work = {},},
--             [4] = {id = nil, startTime = nil,work = nil,},
--         }
--         game.gardenDate = self.gardenDate
--     end
    

-- end


function GardenScene:gardenEnterBack(t)
    print(" GardenScene:gardenEnterBack()  ================1 ")
    dump(t)
    print(" GardenScene:gardenEnterBack()  ================2 ")


    self.gardenDate = {}

    for i=1,#t.playerGarden do
        dump(t.playerGarden[i])

        local tempT = {}
        tempT.id = t.playerGarden[i].id
        tempT.startTime = t.playerGarden[i].beginTime
        tempT.state = t.playerGarden[i].state
        tempT.helpCount = t.playerGarden[i].helpCount
        tempT.stealCount = t.playerGarden[i].stealCount

        self.gardenDate[t.playerGarden[i].index] = tempT
    end


    self:createPageView()
    self:addUI()




end

function GardenScene:onExit()
    print(" MenuScene:onExit()  ================ ")
    
end

function GardenScene:stop_monster_scheduler()
    if self.monster_scheduler_id_ ~= nil then
        scheduler:unscheduleScriptEntry(self.monster_scheduler_id_)
        self.monster_scheduler_id_ = nil
    end
end

function GardenScene:start_monster_scheduler()
    self:stop_monster_scheduler()

    local update_func = function(dt)

        self.time = self.time + dt
        if self.time > 1 then
            self.time = self.time - 1
            self:update()
        end
        
    end

    self.monster_scheduler_id_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_func, self.rate_, false)
end

function GardenScene:update()
    local tag = nil
    if self.shouhuoLabel then
        tag = self.shouhuoLabel:getTag()
    end


    local hasNum = 3

    local AllNum = 4
    local lie = 3
    -- add items
    for i=1,AllNum do


        for index=1,3 do
            local number = ((i-1)*3 + index)

            local huaImg = ""
            local h = 25

            local text = ""
        
            print("number " ..number)
            local tab = self.gardenDate[number]
            if tab then
                local id  = tab["id"]
                if id and id > 0 then
                    local fTab = FlowerTable[id]
                    local newTime = os.time()
                    local d_time = newTime - tab.startTime
                    print("newTime " ..newTime)
                    print("tab.startTime " ..tab.startTime)
                    print("d_time " ..d_time)
                    if d_time < fTab.f_time01 then
                        huaImg = fTab["f_res"] .."_01.png"
                        text = util.timeFmt(fTab.f_time03 - d_time)
                    elseif d_time >= fTab.f_time01 and d_time < fTab.f_time03 then
                        huaImg = fTab["f_res"] .."_02.png"
                        text = util.timeFmt(fTab.f_time03 - d_time)
                    elseif d_time >= fTab.f_time03 then
                        huaImg = fTab["f_res"] .."_03.png"
                        text = "可收获"
                    end
                    print("f_res " ..fTab["f_res"])
                    print("huaImg " ..huaImg)
                else
                    huaImg = "res/gardenUI/bt_zhongzhi.png"
                    text = "请种植"
                end
            else
                huaImg = "res/gardenUI/bm_shitou.png"
                text = "待开垦"
            end


            self.image[number]:setTexture(huaImg)


            self.label[number]:setString(text)

            if tag == number then
                if self.shouhuoLabel then
                    self.shouhuoLabel:setString(text)
                end
            end

        end

    end

end






function GardenScene:addUI( ... )
    self.backButton = cc.ui.UIPushButton.new({normal = "res/checkpointUI/check_ui/bt_fanhui.png", 
                                                pressed = "res/checkpointUI/check_ui/bt_fanhui.png", 
                                                disabled = "res/checkpointUI/check_ui/bt_fanhui.png"})
    :align(display.RIGHT_TOP, display.right - 10, display.top - 10)
    :addTo(self)
    self.backButton:onButtonClicked(function(tag)
        self:backBtnCbk()
    end)


    --
    local img01 = display.newSprite(nil, nil,nil , __one)
    img01:setTexture("res/gardenUI/bm_daojutai.png")
    img01:setPosition(display.left + 80, 0)
    img01:setAnchorPoint(cc.p(0.5, 0))
    img01:setTouchEnabled(false)
    self:addChild(img01)

    local imgItem01 = display.newSprite(nil, nil,nil , __one)
    imgItem01:setTexture("res/gardenUI/bm_chuizi.png")
    imgItem01:setPosition(display.left + 80, 60)
    imgItem01:setAnchorPoint(cc.p(0.5, 0))
    imgItem01:setTouchEnabled(false)
    img01:addChild(imgItem01)

    local img02 = display.newSprite(nil, nil,nil , __one)
    img02:setTexture("res/gardenUI/bm_daojutai.png")
    img02:setPosition(display.left + 235, 0)
    img02:setAnchorPoint(cc.p(0.5, 0))
    img02:setTouchEnabled(false)
    self:addChild(img02)

    local imgItem02 = display.newSprite(nil, nil,nil , __one)
    imgItem02:setTexture("res/gardenUI/bm_yingyangye.png")
    imgItem02:setPosition(display.left + 80, 60)
    imgItem02:setAnchorPoint(cc.p(0.5, 0))
    imgItem02:setTouchEnabled(false)
    img02:addChild(imgItem02)

    --
    local leftBtn = cc.ui.UIPushButton.new({normal = "res/gardenUI/bt_haoyou_normal.png", 
                                                    pressed = "res/gardenUI/bt_haoyou__press.png", 
                                                    disabled = "res/gardenUI/bt_haoyou__press.png"})
    :align(display.CENTER_LEFT, display.left, display.cy + 100)
    :addTo(self)
    leftBtn:onButtonClicked(function(event)
        self:leftBtnCbk(event)
    end)
    self.haoyouBtn = leftBtn

    self:openHaoyou()
end

function GardenScene:openHaoyou( ... )

    game.haoyouList = {
        [1] = {id = 1000001, name = "我的", lv = "10", isHelp = 1},
        [2] = {id = 1000002, name = "诸葛亮", lv = "5", isHelp = 1},
        [3] = {id = 1000004, name = "诸葛亮", lv = "5", isHelp = 1},
        [4] = {id = 1000005, name = "诸葛亮", lv = "5", isHelp = 1},
        [5] = {id = 1000006, name = "诸葛亮", lv = "5", isHelp = 1},
        [6] = {id = 1000007, name = "诸葛亮", lv = "5", isHelp = 1},
    }
    
    local sprite = display.newScale9Sprite("res/gardenUI/bm_yijidi.png", 50, 50, cc.size(310, 450))
    sprite:setPosition(display.left - 10 - 320, display.bottom + 160)
    sprite:setAnchorPoint(cc.p(0,0))
    self:addChild(sprite)
    self.haoyouSprite = sprite

    local item_width = 300
    local item_height = 110

    self.pv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "res/checkpointUI/bm_xuangguandi.png",
        viewRect = cc.rect(0, 10, item_width, 430),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :onTouch(handler(self, self.haoyouTouchListener))
        :addTo(sprite)

    local number = #game.haoyouList

    -- add items
    for i=1,number do


        local item = self.pv:newItem()

        local img = display.newScale9Sprite("res/gardenUI/bm_erjidi.png", 50, 50, cc.size(item_width, 110))
        img:setPosition(item_width*0.5, item_height)
        img:setAnchorPoint(cc.p(0.5, 0.5))


        local img01 = ccui.ImageView:create()
        img01:loadTexture("res/gardenUI/bm_dengjidi.png")
        img01:setPosition(50, 50)
        img01:setAnchorPoint(cc.p(0.5, 0.5))
        img01:setTouchEnabled(false)
        img:addChild(img01)

        local numLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = game.haoyouList[i].lv,
            font  = "font/huakang.TTF",
            size = 20,
        })
        :align(display.CENTER, 32,32)
        :addTo(img01)


        local textLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = game.haoyouList[i].name,
            font  = "font/youyuan.TTF",
            size = 40,
        })
        :align(display.CENTER_LEFT, 80 , 50)
        :addTo(img)

        local imgHelp = display.newSprite(nil, nil,nil , __one)
        imgHelp:setTexture("res/gardenUI/bt_touqu.png")
        imgHelp:setPosition(250, 55)
        imgHelp:setAnchorPoint(cc.p(0.5, 0.5))
        imgHelp:setTouchEnabled(false)
        img:addChild(imgHelp)

 
        item:addContent(img)

        item:setItemSize(item_width, item_height)
        
        self.pv:addItem(item)        
    end
    self.pv:reload(self.curOpenItem)




end


function GardenScene:haoyouTouchListener(event)
    dump(event, "GardenScene TestUIPageViewScene - event:")
    if event.name == "clicked" then
        
        print("clicked "..event.itemPos)

        self:initDate( game.haoyouList[event.itemPos] )

        self:createPageView()
        
    end

    

end



function GardenScene:createPageView()
    if self.huajiaBg and self.pagePv then
        local aa = self.huajiaBg
        local bb = self.pagePv
        self.huajiaBg:runAction(cc.MoveBy:create(0.3,cc.p(0, display.height)) )

        function aaa( ... )
            aa:removeFromParent()
            bb:removeFromParent()
        end
        self.pagePv:runAction(cc.Sequence:create(
                            cc.MoveBy:create(0.3,cc.p(0, display.height)),
                            cc.CallFunc:create(aaa)
                            )
                        )
    end

    self.label = {}
    self.image = {}

    local huajiaBg = ccui.ImageView:create()
    huajiaBg:loadTexture("res/gardenUI/bm_huajia.png")
    self:addChild(huajiaBg)
    huajiaBg:setPosition(display.right + 25,display.bottom - display.height)
    huajiaBg:setAnchorPoint(cc.p(1, 0))
    self.huajiaBg = huajiaBg


    local item_width = 720
    local item_height = 250

    self.pv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "res/checkpointUI/bm_xuangguandi.png",
        viewRect = cc.rect(display.right - item_width + 5, display.bottom - display.height , item_width, item_height * 2.2),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :onTouch(handler(self, self.touchListener))
        :addTo(self)
    self.pagePv = self.pv


    local hasNum = 3

    local AllNum = 4
    local lie = 3
    -- add items
    for i=1,AllNum do

        local item = self.pv:newItem()

        local layer = display.newNode()
        layer:setContentSize(item_width, item_height)
        
        local img = display.newSprite(nil, nil,nil , __one)
        img:setTexture("res/gardenUI/bm_huajiatiao.png")
        img:setPosition(item_width*0.5, 0)
        img:setAnchorPoint(cc.p(0.5, 0))
        -- img:setTouchEnabled(false)
        layer:addChild(img)

        for index=1,3 do
            local number = ((i-1)*3 + index)
            local imgbg = display.newSprite(nil, nil,nil , __one)
            imgbg:setTexture("res/gardenUI/bm_yinying.png")
            imgbg:setPosition(140 + (index - 1 ) * 200, 10)
            imgbg:setAnchorPoint(cc.p(0.5, 0))
            -- imgbg:setTouchEnabled(false)
            layer:addChild(imgbg)
            local huaImg = ""
            local h = 25

            local text = ""
        
            print("number " ..number)
            local tab = self.gardenDate[number]
            if tab then
                local id  = tab["id"]
                if id and id > 0 then
                    local fTab = FlowerTable[id]
                    local newTime = os.time()
                    local d_time = newTime - tab.startTime
                    print("newTime " ..newTime)
                    print("tab.startTime " ..tab.startTime)
                    print("d_time " ..d_time)
                    if d_time < fTab.f_time01 then
                        huaImg = fTab["f_res"] .."_01.png"
                        text = util.timeFmt(fTab.f_time03 - d_time)
                    elseif d_time >= fTab.f_time01 and d_time < fTab.f_time03 then
                        huaImg = fTab["f_res"] .."_02.png"
                        text = util.timeFmt(fTab.f_time03 - d_time)
                    elseif d_time >= fTab.f_time03 then
                        huaImg = fTab["f_res"] .."_03.png"
                        text = "可收获"
                    end
                    print("f_res " ..fTab["f_res"])
                    print("huaImg " ..huaImg)
                else
                    huaImg = "res/gardenUI/bt_zhongzhi.png"
                    text = "请种植"
                end
            else
                huaImg = "res/gardenUI/bm_shitou.png"
                text = "待开垦"
            end

            local img = display.newSprite(nil, nil,nil , __one)
            img:setTexture(huaImg)
            img:setPosition(140 + (index - 1 ) * 200, 10)
            img:setAnchorPoint(cc.p(0.5, 0))
            img:setTouchEnabled(true)
            layer:addChild(img)
            self.image[number] = img
            img:setTag(number)

            img:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                return self:huaOnTouch(img, event, layer)
            end)

            local label = cc.ui.UILabel.new({
                UILabelType = 2,
                text  = text,
                font  = "font/huakang.TTF",
                size = 24,
            })
            :align(display.CENTER, 140 + (index - 1 ) * 200, 0)
            :addTo(layer)
            self.label[number] = label

        end
        

 
        item:addContent(layer)

        item:setItemSize(item_width, item_height)
        
        self.pv:addItem(item)        
    end
    self.pv:reload(self.curOpenItem)

    --move
    huajiaBg:runAction(cc.MoveBy:create(0.3,cc.p(0, display.height)) )

    function aaa( ... )
        -- body
    end
    self.pv:runAction(cc.Sequence:create(
                        cc.MoveBy:create(0.3,cc.p(0, display.height)),
                        cc.CallFunc:create(aaa)
                        )
                    )
        

end

function GardenScene:huaOnTouch(img, event, layer)
    print("-------------------endedendedendedendedended----------2222img "..img:getTag())
    local number = img:getTag()
    local index = number%3
    if index == 0 then index = 3 end
    if event.name == "ended" then
        print("number " ..number)
            local tab = self.gardenDate[number]
            if tab then
                local id  = tab["id"]
                if id and id > 0 then
                    local fTab = FlowerTable[id]
                    local newTime = os.time()
                    local d_time = newTime - tab.startTime
                    print("newTime " ..newTime)
                    print("tab.startTime " ..tab.startTime)
                    print("d_time " ..d_time)
                    if d_time < fTab.f_time03 then
                        if layer:getChildByTag(101) then
                            layer:getChildByTag(101):removeFromParent()
                        else
                            local img = display.newSprite(nil, nil,nil , __one)
                            img:setTexture("res/gardenUI/bm_anniutiao.png")
                            img:setPosition(140 + (index - 1 ) * 200, 120)
                            img:setAnchorPoint(cc.p(0.5, 0))
                            img:setTouchEnabled(true)
                            layer:addChild(img)
                            img:setTag(101)
                        end
                        
                        if self.uid == self.curUid then
                            if layer:getChildByTag(102) then
                                layer:getChildByTag(102):removeFromParent()
                            else
                                local img = display.newSprite(nil, nil,nil , __one)
                                img:setTexture("res/gardenUI/bt_wancheng.png")
                                img:setPosition(140 + (index - 1 ) * 200, 175)
                                img:setAnchorPoint(cc.p(0.5, 0))
                                img:setTouchEnabled(true)
                                layer:addChild(img)
                                img:setTag(102)
                                img:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                                    -- return self:huaOnTouch(img, event, layer)
                                    print("bt_wanchengbt_wanchengbt_wanchengbt_wancheng "..event.name)
                                    if event.name == "ended" then
                                        local reqTab = {id = id, index = number}
                                        game.clientTCP:send("gatherFlower", reqTab, handler(self, self.gatherFlowerBack))
                                        -- self:shouhuoLayer(number, layer)
                                    end
                                    return true
                                end)
                            end
                        else
                            if layer:getChildByTag(103) then
                                layer:getChildByTag(103):removeFromParent()
                            else
                                local img = display.newSprite(nil, nil,nil , __one)
                                img:setTexture("res/gardenUI/bt_jiaoshui.png")
                                img:setPosition(140 + (index - 1 ) * 200, 175)
                                img:setAnchorPoint(cc.p(0.5, 0))
                                img:setTouchEnabled(true)
                                layer:addChild(img)
                                img:setTag(103)
                            end
                        end

                        
                    elseif d_time >= fTab.f_time03 then
                        if self.uid ~= self.curUid then
                            if layer:getChildByTag(101) then
                                layer:getChildByTag(101):removeFromParent()
                            else
                                local img = display.newSprite(nil, nil,nil , __one)
                                img:setTexture("res/gardenUI/bm_anniutiao.png")
                                img:setPosition(140 + (index - 1 ) * 200, 120)
                                img:setAnchorPoint(cc.p(0.5, 0))
                                img:setTouchEnabled(true)
                                layer:addChild(img)
                                img:setTag(101)
                            end

                            if layer:getChildByTag(102) then
                                layer:getChildByTag(102):removeFromParent()
                            else
                                local img = display.newSprite(nil, nil,nil , __one)
                                img:setTexture("res/gardenUI/bt_touqu.png")
                                img:setPosition(140 + (index - 1 ) * 200 , 175)
                                img:setAnchorPoint(cc.p(0.5, 0))
                                img:setTouchEnabled(true)
                                layer:addChild(img)
                                img:setTag(102)
                            end
                        else
                            --弹收获框
                            self:caiZhaiLayer(number)
                        end
                    end
                    
                else 
                    -- 弹选择种子界面
                    self:zhongzhiLayer(number)
                end
            else
                -- 弹花钱开垦界面
                self:kaikenLayer()
            end



    end
    return true
end

function GardenScene:gatherFlowerBack(t)
    print(" GardenScene:gatherFlowerBack()  ================1 ")
    dump(t)
    print(" GardenScene:gatherFlowerBack()  ================2 ")

    if t.result == 0 then
        table.insert(self.gardenDate, {id = nil, startTime = nil,work = nil,})
    end


    
end

function GardenScene:shouhuoLayer(number, flayer)  
    local layer = display.newColorLayer(cc.c4b(0, 0, 0, 160))
    layer:setContentSize(display.width, display.height)
    self:addChild(layer)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            layer:removeFromParent()
        end
        return true
    end)


    local sprite = display.newScale9Sprite("res/gardenUI/bm_yijidi.png", 50, 50, cc.size(700, 360))
    sprite:setPosition(display.width * 0.5, display.height * 0.5)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_sanjidi.png", 50, 50, cc.size(660, 280))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 20)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_erjidi.png", 70, 50, cc.size(645, 105))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 100)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "太阳花",
        font  = "font/huakang.TTF",
        size = 40,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 150)
    :addTo(layer)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "花费钻石使植物立即成熟",
        font  = "font/youyuan.TTF",
        size = 32,
        color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 100)
    :addTo(layer)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_wenzige.png")
    sprite:setPosition(display.width * 0.5, display.height * 0.5 + 75)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_shuzitiao.png")
    sprite:setPosition(display.width * 0.5 - 150, display.height * 0.5 + 25)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "金币:1000 - 2000",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 - 150, display.height * 0.5 + 25)
    :addTo(layer)


    local sprite = display.newScale9Sprite("res/gardenUI/bm_shuzitiao.png")
    sprite:setPosition(display.width * 0.5 + 150, display.height * 0.5 + 25)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "道具:3",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 + 150, display.height * 0.5 + 25)
    :addTo(layer)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "成熟倒计时:",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 - 180, display.height * 0.5 - 65)
    :addTo(layer)
    

    local sprite = display.newScale9Sprite("res/gardenUI/bm_shuzitiao.png")
    sprite:setPosition(display.width * 0.5 + 150, display.height * 0.5 + 25)
    layer:addChild(sprite)


    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "00:00:00",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 - 180, display.height * 0.5 - 110)
    :addTo(layer)
    self.shouhuoLabel = label
    self.shouhuoLabel:setTag(number)

    self.check_btn = cc.ui.UIPushButton.new({normal = "res/gardenUI/bt_yijianniu.png", 
                                                    pressed = "res/gardenUI/bt_yijianniu.png", 
                                                    disabled = "res/gardenUI/bt_yijianniu.png"})
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 100)
    :addTo(layer)
    self.check_btn:onButtonClicked(function(event)
        self:yijianchenshuCbk(event, number, flayer, layer)
    end)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "10",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 + 160, display.height * 0.5 - 85)
    :addTo(layer)

    local sprite = display.newScale9Sprite("res/gardenUI/bt_zuanshi.png")
    sprite:setPosition(display.width * 0.5 + 180 + 30, display.height * 0.5 - 85)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "立即成熟",
        font  = "font/youyuan.TTF",
        size = 24,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 110)
    :addTo(layer)
end

function GardenScene:kaikenLayer()  
    local layer = display.newColorLayer(cc.c4b(0, 0, 0, 160))
    layer:setContentSize(display.width, display.height)
    self:addChild(layer)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            self.shouhuoLabel = nil
            layer:removeFromParent()
        end
        return true
    end)


    local sprite = display.newScale9Sprite("res/gardenUI/bm_yijidi.png", 50, 50, cc.size(700, 360))
    sprite:setPosition(display.width * 0.5, display.height * 0.5)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_sanjidi.png", 50, 50, cc.size(660, 280))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 20)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_erjidi.png", 70, 50, cc.size(645, 105))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 100)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "开垦",
        font  = "font/huakang.TTF",
        size = 40,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 150)
    :addTo(layer)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "你确定要开垦这块位置吗？",
        font  = "font/youyuan.TTF",
        size = 32,
        color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 100)
    :addTo(layer)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_wenzige.png")
    sprite:setPosition(display.width * 0.5, display.height * 0.5 + 75)
    layer:addChild(sprite)

    

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "(开垦后可种植更多植物)",
        font  = "font/youyuan.TTF",
        size = 32,
        color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 25)
    :addTo(layer)


    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "开放等级:10",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 - 180, display.height * 0.5 - 80)
    :addTo(layer)




    self.check_btn = cc.ui.UIPushButton.new({normal = "res/gardenUI/bt_yijianniu.png", 
                                                    pressed = "res/gardenUI/bt_yijianniu.png", 
                                                    disabled = "res/gardenUI/bt_yijianniu.png"})
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 100)
    :addTo(layer)
    self.check_btn:onButtonClicked(function(event)
        self:kaikenCbk(event, layer)
    end)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "10",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 + 160, display.height * 0.5 - 85)
    :addTo(layer)

    local sprite = display.newScale9Sprite("res/gardenUI/bt_zuanshi.png")
    sprite:setPosition(display.width * 0.5 + 180 + 30, display.height * 0.5 - 85)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "开垦",
        font  = "font/youyuan.TTF",
        size = 24,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 110)
    :addTo(layer)
end

function GardenScene:zhongzhiLayer(number)  
    local layer = display.newColorLayer(cc.c4b(0, 0, 0, 160))
    layer:setContentSize(display.width, display.height)
    self:addChild(layer)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            self.shouhuoLabel = nil
            layer:removeFromParent()
        end
        return true
    end)


    local sprite = display.newScale9Sprite("res/gardenUI/bm_yijidi.png", 50, 50, cc.size(700, 360))
    sprite:setPosition(display.width * 0.5, display.height * 0.5)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_sanjidi.png", 50, 50, cc.size(660, 280))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 20)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_erjidi.png", 70, 50, cc.size(645, 105))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 100)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "种植",
        font  = "font/huakang.TTF",
        size = 40,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 150)
    :addTo(layer)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "请选择一颗种子种植",
        font  = "font/youyuan.TTF",
        size = 32,
        color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 100)
    :addTo(layer)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_wenzige.png")
    sprite:setPosition(display.width * 0.5, display.height * 0.5 + 75)
    layer:addChild(sprite)

    

    


    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "太阳花种子",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 - 180, display.height * 0.5 - 80)
    :addTo(layer)




    self.check_btn = cc.ui.UIPushButton.new({normal = "res/gardenUI/bt_yijianniu.png", 
                                                    pressed = "res/gardenUI/bt_yijianniu.png", 
                                                    disabled = "res/gardenUI/bt_yijianniu.png"})
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 100)
    :addTo(layer)
    self.check_btn:onButtonClicked(function(event)
        self:zhongzhiCbk(event, layer, number)
    end)



    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "种植",
        font  = "font/youyuan.TTF",
        size = 40,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 90)
    :addTo(layer)
end

function GardenScene:zhongzhiLayer(number)  
    local layer = display.newColorLayer(cc.c4b(0, 0, 0, 160))
    layer:setContentSize(display.width, display.height)
    self:addChild(layer)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            self.shouhuoLabel = nil
            layer:removeFromParent()
        end
        return true
    end)


    local sprite = display.newScale9Sprite("res/gardenUI/bm_yijidi.png", 50, 50, cc.size(700, 360))
    sprite:setPosition(display.width * 0.5, display.height * 0.5)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_sanjidi.png", 50, 50, cc.size(660, 280))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 20)
    layer:addChild(sprite)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_erjidi.png", 70, 50, cc.size(645, 105))
    sprite:setPosition(display.width * 0.5, display.height * 0.5 - 100)
    layer:addChild(sprite)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "种植",
        font  = "font/huakang.TTF",
        size = 40,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 150)
    :addTo(layer)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "请选择一颗种子种植",
        font  = "font/youyuan.TTF",
        size = 32,
        color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 100)
    :addTo(layer)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_wenzige.png")
    sprite:setPosition(display.width * 0.5, display.height * 0.5 + 75)
    layer:addChild(sprite)

    

    


    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "太阳花种子",
        font  = "font/youyuan.TTF",
        size = 32,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 - 180, display.height * 0.5 - 80)
    :addTo(layer)




    self.check_btn = cc.ui.UIPushButton.new({normal = "res/gardenUI/bt_yijianniu.png", 
                                                    pressed = "res/gardenUI/bt_yijianniu.png", 
                                                    disabled = "res/gardenUI/bt_yijianniu.png"})
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 100)
    :addTo(layer)
    self.check_btn:onButtonClicked(function(event)
        self:zhongzhiCbk(event, layer, number)
    end)



    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "种植",
        font  = "font/youyuan.TTF",
        size = 40,
        -- color = display.COLOR_BLACK,
    })
    :align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5 - 90)
    :addTo(layer)
end

function GardenScene:caiZhaiLayer(number)  
    local layer = display.newColorLayer(cc.c4b(0, 0, 0, 160))
    layer:setContentSize(display.width, display.height)
    self:addChild(layer)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            self.gardenDate[number] = {id = nil, startTime = nil,work = nil,}
            self.shouhuoLabel = nil
            layer:removeFromParent()
        end
        return true
    end)


    local sprite = display.newScale9Sprite("res/gardenUI/bm_huayuanBJ.jpg")
    sprite:setPosition(display.width * 0.5, display.height * 0.5)
    layer:addChild(sprite)


    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "金币",
        font  = "font/huakang.TTF",
        size = 52,
        color = cc.c3b(255, 193, 37),--#FFC125
    })
    :align(display.CENTER, display.width * 0.5 - 100, display.height * 0.5 + 200)
    :addTo(layer)

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "你的金币",
        font  = "font/youyuan.TTF",
        size = 32,
        color = cc.c3b(255, 193, 37),--#FFC125
    })
    :align(display.CENTER, display.width * 0.5 + 80, display.height * 0.5 + 200)
    :addTo(layer)

    local sprite = display.newScale9Sprite("res/gardenUI/bm_jinbidui.png")
    sprite:setPosition(display.width * 0.5 - 100, display.height * 0.5 + 100)
    layer:addChild(sprite)

    
    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "100000",
        font  = "font/youyuan.TTF",
        size = 32,
        color = cc.c3b(255, 193, 37),--#FFC125
    })
    :align(display.CENTER, display.width * 0.5, display.height * 0.5 + 100)
    :addTo(layer)



    local sprite = display.newSprite("res/gardenUI/bm_jianglitai.png")
    sprite:setPosition(display.width * 0.5, display.bottom + 0)
    sprite:setAnchorPoint(cc.p(0.5,0))
    layer:addChild(sprite)

    local sprite = display.newSprite("res/icon/flowers/ZW01_03.png")
    sprite:setPosition(display.width * 0.5, display.bottom + 140)
    sprite:setAnchorPoint(cc.p(0.5,0))
    layer:addChild(sprite)
    
end



function GardenScene:touchListener(event)
    dump(event, "TestUIPageViewScene - event:")
    if event.name == "clicked" then
        if self.curOpenItem ~= event.itemPos then
           
        end

    end

    

end



function GardenScene:backBtnCbk()  
    self:stop_monster_scheduler()
    appInstance:enterMainScene()
end

function GardenScene:leftBtnCbk(event)  
    local x = self.haoyouSprite:getPositionX()
    print(" haoyouSprite  x "..x)

    if x < -100 then
        local function aaa( ... )
            self.haoyouBtn:setTouchEnabled(true)
        end
        
        self.haoyouBtn:setTouchEnabled(false)
        self.haoyouSprite:runAction(cc.MoveBy:create(0.1,cc.p(320,0)) )

        self.haoyouBtn:runAction(cc.Sequence:create(
                        cc.MoveBy:create(0.1,cc.p(290,0)),
                        cc.CallFunc:create(aaa)))
    else
        local function aaa( ... )
            self.haoyouBtn:setTouchEnabled(true)
        end
        
        self.haoyouBtn:setTouchEnabled(false)
        self.haoyouSprite:runAction(cc.MoveBy:create(0.1,cc.p(-320,0)) )

        self.haoyouBtn:runAction(cc.Sequence:create(
                        cc.MoveBy:create(0.1,cc.p(-290,0)),
                        cc.CallFunc:create(aaa)))

    end

    

end

function GardenScene:rightBtnCbk()  

end

function GardenScene:cutFlowerTimeBack(t)
    print(" GardenScene:cutFlowerTimeBack()  ================1 ")
    dump(t)
    print(" GardenScene:cutFlowerTimeBack()  ================2 ")

    if t.result == 0 then
        local flower = t.flower
        self.gardenDate[flower.index] = {id = flower.id, startTime = flower.beginTime , index = flower.index, state = flower.state, helpCount = flower.helpCount, stealCount = flower.stealCount, work = {},}
    end

end

function GardenScene:yijianchenshuCbk(event, number, flayer,layer)  

    local reqTab = {index = number}
    game.clientTCP:send("cutFlowerTime", reqTab, handler(self, self.cutFlowerTimeBack))

    for i=101,103 do
        local node = flayer:getChildByTag(i)
        if node then
            node:removeFromParent()
        end
    end

    self.shouhuoLabel = nil
    layer:removeFromParent()
end

function GardenScene:getNewLandBack(t)
    print(" GardenScene:getNewLandBack()  ================1 ")
    dump(t)
    print(" GardenScene:getNewLandBack()  ================2 ")

    if t.result == 0 then
        table.insert(self.gardenDate, {id = nil, startTime = nil,work = nil,})
    end

end

function GardenScene:kaikenCbk(event, layer)  

    local reqTab = {id = 1177563185, index = #self.gardenDate + 1}
    game.clientTCP:send("getNewLand", reqTab, handler(self, self.getNewLandBack))


    layer:removeFromParent()
end

function GardenScene:plantLandBack(t)
    print(" GardenScene:plantLandBack()  ================1 ")
    dump(t)
    print(" GardenScene:plantLandBack()  ================2 ")

    if t.result == 0 then
        local flower = t.flower
        self.gardenDate[flower.index] = {id = flower.id, startTime = flower.beginTime , index = flower.index, state = flower.state, helpCount = flower.helpCount, stealCount = flower.stealCount, work = {},}
    end

end

function GardenScene:zhongzhiCbk(event, layer, number)  
    local curtime = os.time()
    

    local reqTab = {id = 1177563185, index = number}
    game.clientTCP:send("plantLand", reqTab, handler(self, self.plantLandBack))

    layer:removeFromParent()
end



return GardenScene

