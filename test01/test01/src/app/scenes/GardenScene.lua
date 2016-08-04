
require("app/res/ItemRes")

local __one = {class=cc.FilteredSpriteWithOne}

local GardenScene = class("GardenScene", function()
    return display.newScene("GardenScene")
end)

function GardenScene:ctor()
    self.Bg = display.newSprite("res/gardenUI/bm_huayuanBJ.jpg")
    self.Bg:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.Bg)
    self.Bg:setPosition(display.cx, display.cy)

    
    self:createPageView()
    self:addUI()
    
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
    :align(display.CENTER_LEFT, display.left, display.cy)
    :addTo(self)
    leftBtn:onButtonClicked(function(event)
        self:leftBtnCbk(event)
    end)

    
end

function GardenScene:createPageView()
    local huajiaBg = ccui.ImageView:create()
    huajiaBg:loadTexture("res/gardenUI/bm_huajia.png")
    self:addChild(huajiaBg)
    huajiaBg:setPosition(display.right + 35,display.bottom)
    huajiaBg:setAnchorPoint(cc.p(1, 0))


    local item_width = 720
    local item_height = 250

    self.pv = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "res/checkpointUI/bm_xuangguandi.png",
        viewRect = cc.rect(display.right - item_width - 50, display.bottom, item_width, item_height * 2.2),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :onTouch(handler(self, self.touchListener))
        :addTo(self)



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
        img:setTouchEnabled(false)
        layer:addChild(img)

        for index=1,3 do
            local imgbg = display.newSprite(nil, nil,nil , __one)
            imgbg:setTexture("res/gardenUI/bm_yinying.png")
            imgbg:setPosition(120 + (index - 1 ) * 200, 10)
            imgbg:setAnchorPoint(cc.p(0.5, 0))
            imgbg:setTouchEnabled(false)
            layer:addChild(imgbg)
            local huaImg = ""
            local h = 25
            if ((i-1)*3 + index) <= hasNum then
                huaImg = "res/gardenUI/ZW01_0"..index..".png"
            else
                huaImg = "res/gardenUI/bm_shitou.png"
            end 
            local img = display.newSprite(nil, nil,nil , __one)
            img:setTexture(huaImg)
            img:setPosition(120 + (index - 1 ) * 200, 25)
            img:setAnchorPoint(cc.p(0.5, 0))
            img:setTouchEnabled(false)
            layer:addChild(img)
        end
        

 
        item:addContent(layer)

        item:setItemSize(item_width, item_height)
        
        self.pv:addItem(item)        
    end
    self.pv:reload(self.curOpenItem)



    

    

        
        

end


function GardenScene:touchListener(event)
    dump(event, "TestUIPageViewScene - event:")
    if event.name == "clicked" then
        if self.curOpenItem ~= event.itemPos then
           
        end

    end

    

end



function GardenScene:backBtnCbk()  
    appInstance:enterMainScene()
end

function GardenScene:leftBtnCbk()  

end

function GardenScene:rightBtnCbk()  

end

function GardenScene:btn01BtnCbk()  

end


return GardenScene

