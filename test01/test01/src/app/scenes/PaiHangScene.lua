

local PaiHangScene = class("PaiHangScene", function()
    return display.newScene("PaiHangScene")
end)

function PaiHangScene:ctor()
    self.Bg = display.newSprite("res/loginUI/bm_beijing1.jpg")
    self.Bg:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.Bg)
    self.Bg:setPosition(display.cx, display.cy)



    self:addUI()
end

function PaiHangScene:addUI( ... )


    local addImg = ccui.ImageView:create()
    addImg:loadTexture("res/checkpointUI/bm_biaoti.png")
    self:addChild(addImg)
    addImg:setPosition(display.cx,display.top - 65)
    addImg:setAnchorPoint(cc.p(0.5, 0.5))

    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text  = "排行榜",
        font  = "font/youyuan.TTF",
        size = 36,
    })
    :align(display.CENTER, display.cx,display.top - 55)
    :addTo(self)

    self.backButton = cc.ui.UIPushButton.new({normal = "res/paihangUI/bt_xx.png", 
                                                pressed = "res/paihangUI/bt_xx.png", 
                                                disabled = "res/paihangUI/bt_xx.png"})
    :align(display.RIGHT_TOP, display.right - 10, display.top - 10)
    :addTo(self)
    self.backButton:onButtonClicked(function(tag)
        self:backBtnCbk()
    end)

    self.AllButton = cc.ui.UIPushButton.new({normal = "res/paihangUI/bt_fenye_normal.png", 
                                                pressed = "res/paihangUI/bt_fenye_press.png", 
                                                disabled = "res/paihangUI/bt_fenye_press.png"})
    :align(display.CENTER_LEFT, display.left, display.top - 150)
    :addTo(self)
    self.AllButton:onButtonClicked(function(tag)
        self:allBtnCbk()
    end)
    self.AllButton:setButtonEnabled(false)

    local img = ccui.ImageView:create()
    img:loadTexture("res/paihangUI/bt_quanqiu.png")
    img:setPosition(display.left, display.top - 150)
    img:setAnchorPoint(cc.p(0, 0.5))
    self:addChild(img)

    local numLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = "Global",
            font  = "font/youyuan.TTF",
            size = 44,
        })
    :align(display.CENTER_LEFT, display.left + 50, display.top - 150)
    :addTo(self)

    self:createListView()



end

function PaiHangScene:createListView()

    self.lv = cc.ui.UIListView.new {
            -- bgColor = cc.c4b(200, 200, 200, 120),
            -- bg = "res/paihangUI/bm_tiao1.png",
            bgScale9 = true,
            viewRect = cc.rect(250, 80, 850, 480),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            -- scrollbarImgV = "res/paihangUI/bm_tiao1.png"
        }
        :onTouch(handler(self, self.touchListener))
        :addTo(self)

    -- add items
    for i=1,20 do
        local item = self.lv:newItem()

        local img = ccui.ImageView:create()
        img:loadTexture("res/paihangUI/bm_tiao1.png")
        img:setPosition(0, 0)
        img:setAnchorPoint(cc.p(0, 0))
        img:setTouchEnabled(false)

        local img01 = ccui.ImageView:create()
        img01:loadTexture("res/paihangUI/bm_tiao2.png")
        img01:setPosition(0, 65-21)
        img01:setAnchorPoint(cc.p(0, 0))
        img01:setTouchEnabled(false)
        img:addChild(img01)

        local img01res = ""
        if i < 4 then
            img01res = "res/paihangUI/bm_paihangbiao"..i..".png"
        else
            img01res = "res/paihangUI/bm_paihangbiao4.png"
        end

        local img01 = ccui.ImageView:create()
        img01:loadTexture(img01res)
        img01:setPosition(50, 30)
        img01:setAnchorPoint(cc.p(0, 0.5))
        img01:setTouchEnabled(false)
        img:addChild(img01)

        local numLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text  = tostring(i),
            font  = "font/huakang.TTF",
            size = 20,
        })
        :align(display.CENTER, 32,32)
        :addTo(img01)

        
        item:addContent(img)
        item:setItemSize(848, 65)


        self.lv:addItem(item)
    end
    self.lv:reload()

end

function PaiHangScene:touchListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        if 3 == event.itemPos then
            listView:removeItem(event.item, true)
        else
            -- event.item:setItemSize(120, 80)
        end
    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end
end



function PaiHangScene:backBtnCbk()  
    appInstance:enterMainScene()
end

function PaiHangScene:leftBtnCbk()  

end

function PaiHangScene:rightBtnCbk()  

end

function PaiHangScene:btn01BtnCbk()  

end

function PaiHangScene:btn02BtnCbk()  
    appInstance:enterMenuScene()
end

function PaiHangScene:btn03BtnCbk()  

end

return PaiHangScene
