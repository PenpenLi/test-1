local zhenrongchakan = class("zhenrongchakan", require("app.views.mmExtend.LayerBase"))
zhenrongchakan.RESOURCE_FILENAME = "zhenrongchakan.csb"

function zhenrongchakan:onCreate(param)
    self.param = param
    self.zztype = param.zztype or 1
    self.Node = self:getResourceNode()

    -- 关闭按钮
    self.backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_7")
    self.backBtn:addTouchEventListener(handler(self, self.backBtnCbk))

    self:initAreanUI()

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
    self:addGlobalEventListener(EventDef.UI_MSG, handler(self, self.globalEventsListener))
end

function zhenrongchakan:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        -- if event.code == "getRank" then

        -- end

    end
end


function zhenrongchakan:onEnter() 
    
end

function zhenrongchakan:jinjiCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 

    end
end




function zhenrongchakan:initAreanUI( ... )
    local info = self.param.info.direninfo
    local zhanli = self.param.zhanli
    local mine = self.Node:getChildByName("Image_touxiang")

    local allZhanli = zhanli

    mine:getChildByName("Text_zhandouli"):setString("战力:"..allZhanli)

    mine:getChildByName("Text_dengji"):setString(gameUtil.getPlayerLv(info.playerinfo.exp or 0))
    gameUtil.setVipLevel( mine:getChildByName("Node_vip"), gameUtil.getPlayerVipLv(info.playerinfo.vipexp) )
    

    if info.playerinfo.camp == 1 then
        mine:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/L036.png")
        -- mine:getChildByName("Image_camp"):loadTexture("res/UI/bt_qizhilol_select.png")
    else
        mine:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/D038.png")
        -- mine:getChildByName("Image_camp"):loadTexture("res/UI/bt_qizhidota_select.png")
    end

    mine:getChildByName("Text_name"):setString(info.playerinfo.nickname)



    local playerFormation = info.playerFormation
    local playerHero = info.playerHero

    local puTongZhen = {}

    for i=1,#playerFormation do
        if playerFormation[i].type == self.zztype then
            for j=1,#playerFormation[i].formationTab do
                table.insert(puTongZhen, playerFormation[i].formationTab[j].id)
            end
        end
    end

    for i=1,#puTongZhen do
        for k,v in pairs(playerHero) do
            if v.id == puTongZhen[i] then
                local custom_item = ccui.Layout:create()
                local Image_icon = gameUtil.createTouXiang(v)
  
                self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Image_"..i):addChild(Image_icon)
                custom_item:setContentSize(Image_icon:getContentSize())
                Image_icon:setPositionY(Image_icon:getContentSize().height*0.5)

            end
        end
    end



end



function zhenrongchakan:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end



function zhenrongchakan:onCleanup()
    self:clearAllGlobalEventListener()
end

return zhenrongchakan
