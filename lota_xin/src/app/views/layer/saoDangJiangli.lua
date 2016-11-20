--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local saoDangJiangli = class("saoDangJiangli", require("app.views.mmExtend.LayerBase"))
saoDangJiangli.RESOURCE_FILENAME = "JSZjiangliLayer.csb"


function saoDangJiangli:onCleanup()
    --self:clearAllGlobalEventListener()
end

function saoDangJiangli:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )


end

function saoDangJiangli:onExit()

end

function saoDangJiangli:onCreate(param)
    self:init(param)

    --self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function saoDangJiangli:init(param)
    self.param = param
    -- self.scene = param.scene

    self.allDropTab = mm.data.saodangDrop
    self.saodangTimes = mm.data.saodangTimes
    self:initLayerUI()
end

function saoDangJiangli:initLayerUI( )
    self.Node = self:getResourceNode()

    self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_1"):setString("扫荡次数")
    self.Node:getChildByName("Image_bg"):getChildByName("Text_01"):setString("扫荡奖励")


    local Text_zhantimes = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_zhantimes")
    Text_zhantimes:setString(self.saodangTimes)

    local Image_gold = self.Node:getChildByName("Image_bg"):getChildByName("Image_gold")
    Image_gold:setVisible(true)
    Image_gold:loadTexture("res/UI/pc_jinbi.png")
    -- Image_gold:setContentSize(cc.p(33,32))
    Image_gold:setScaleX(0.5)
    Image_gold:setScaleY(1.6)

    local Text_exp = self.Node:getChildByName("Image_bg"):getChildByName("Text_exp")
    Text_exp:setString(mm.data.saodangTab.addGold)

    self.Node:getChildByName("Image_bg"):getChildByName("Image_exp"):setVisible(false)
    self.Node:getChildByName("Image_bg"):getChildByName("Text_exppool"):setVisible(false)

    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    Button_ok:setTouchEnabled(false)
    performWithDelay(self,function(  )
        Button_ok:setTouchEnabled(true)
    end,0.2)




    local size  = cc.Director:getInstance():getWinSize()

    local ListView = self.Node:getChildByName("ListView")

    local dTab = self.allDropTab



    if dTab then

        local count = 0

        local itemHeight = 84 * 1.2
        local itemWidth = 84


        local offsetY = itemHeight*0.3
        local offsetX = itemWidth*0.1
        local all = #dTab

        local custom_item = ccui.Layout:create()

        local hasTab = {}
        for k,v in pairs(dTab) do
            if v.num > 0 then
                table.insert(hasTab, v)
                print(v.id .. "saoDangJiangli       1111111 v.num  "..v.num)
            end
        end

        for k,v1 in pairs(hasTab) do
            count = count + 1

            local equip = INITLUA:getEquipByid(v1.id)

            if equip and v1.num > 0 then
                print(v1.id .. "saoDangJiangli    #   1111111 v.num  "..v1.num)
                local item = gameUtil.createEquipItem(v1.id,v1.num)
                item:setAnchorPoint(cc.p(0.0,1))
                
                itemHeight = item:getContentSize().height * 1.3
                itemWidth = item:getContentSize().width * 1.1
                custom_item:addChild(item)

                offsetY = itemHeight*0.3
                offsetX = itemWidth*0.1
                cclog(" www ###################     all    "..all)
                local tempY = math.floor((count/5) + 1) * itemHeight - 20
                local tempX = (size.width-itemWidth*5-offsetX*4) * 0.5 + itemWidth * 0.2
                item:setPosition(tempX + itemWidth* 1 * ((count-1)%5), tempY)
                -- local aaa = tempX + itemWidth* 1.2 * ((count-1)%5)
                -- local bbb = tempY - offsetY  - itemHeight * ((math.floor((count-1)/5))+1)
                -- cclog(" www ###################         "..aaa)
                -- cclog(" www ###################         "..bbb)
                if equip.EquipType == MM.EEquipType.ET_SuiPian then
                    local suipianPinPathRes = gameUtil.getEquipSuipianPinRes(equip.Quality)
                    local suipianTag = cc.Sprite:create(suipianPinPathRes)
                    suipianTag:setPosition(cc.p(20, item:getContentSize().height - 15))
                    item:addChild(suipianTag)
                end
            else
                print(v1.id .. "saoDangJiangli    #   22222 v.num  "..v1.num)
            end

        end


        local H = math.floor((count/5) + 1) * itemHeight 
        cclog(" www ###################     count    "..count)
        cclog(" www ###################      H   "..H)

        custom_item:setContentSize(size.width,H) 

        ListView:pushBackCustomItem(custom_item)

    end


    local dropTab = self.allDropTab
    local count = 0
    if dropTab then
        for k,v in pairs(dropTab) do
            count = count + v.num
        end
    end


    self.Node:getChildByName("Image_bg"):getChildByName("Text_Num"):setString("获得装备："..count)

end





function saoDangJiangli:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function saoDangJiangli:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end



function saoDangJiangli:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        
    end
end

return saoDangJiangli


