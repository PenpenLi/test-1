--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/7/23
-- Time: 16:10
-- To change this template use File | Settings | File Templates.
--

local JinjichenggongLayer = class("JinjichenggongLayer", require("app.views.mmExtend.LayerBase"))
JinjichenggongLayer.RESOURCE_FILENAME = "Jinjichenggong.csb"


function JinjichenggongLayer:onCleanup()
    --self:clearAllGlobalEventListener()
end

function JinjichenggongLayer:onEnter()
    gameUtil.playUIEffect( "Income_Outline" )

    -- if mm.GuildId == 15003 then
    --     performWithDelay(self,function( ... )
    --         Guide:startGuildById(15004, self.okBtn)
    --     end, 0.01)
    --     Guide:setHandVisible(true)
    --     Guide:setkuangImgVisible(true)
    --     Guide:setImageViewVisible(true)
    -- elseif mm.GuildId == 15053 then
    --     performWithDelay(self,function( ... )
    --         Guide:startGuildById(15054, self.okBtn)
    --     end, 0.01)
    --     Guide:setHandVisible(true)
    --     Guide:setkuangImgVisible(true)
    --     Guide:setImageViewVisible(true)
    -- end

end

function JinjichenggongLayer:onExit()

end

function JinjichenggongLayer:onCreate(param)
    self:init(param)

end

function JinjichenggongLayer:init(param)
    self.param = param

    self:initLayerUI()
end

function JinjichenggongLayer:initLayerUI( )
    self.Node = self:getResourceNode()

    local curZhanli = gameUtil.getPlayerForce()
    local curRank = mm.data.curDuanWei
    local DropOutTab = INITLUA:getDropOutRes()
    local toRank = DropOutTab[tonumber(curRank)]['RankUpID']
    
    local oldRank = nil
    for k,v in pairs(DropOutTab) do
        local torank = v['RankUpID']
        if tonumber(curRank) == tonumber(torank) then
            oldRank = v
        end
    end

    if tonumber(curRank) < 1093677617 then
        self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_time"):setString("下次晋级需要战力"..DropOutTab[toRank]["RankFightNum"])
    else
        self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_time"):setVisible(false)
    end

    local NodeOld = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Node_old")
    local NodeCur = self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Node_cur")

    self:addRankImg(NodeOld, oldRank.ID)
    self:addRankImg(NodeCur, curRank)

    self:initStageDrop()

    local Button_ok = self.Node:getChildByName("Image_bg"):getChildByName("Button_ok")
    Button_ok:addTouchEventListener(handler(self, self.ButtonOkBack))
    self.okBtn = Button_ok

    self.Node:getChildByName("Image_bg"):getChildByName("Button_drop"):addTouchEventListener(handler(self, self.ButtonDrop))
    self.Node:getChildByName("Image_bg"):getChildByName("Text_drop"):addTouchEventListener(handler(self, self.ButtonDrop))

end

function JinjichenggongLayer:ButtonDrop(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        local rewardLayer = require("src.app.views.layer.DropItemLayer").new(tonumber(mm.data.curDuanWei))
        self:addChild(rewardLayer)
   
    end
end


function JinjichenggongLayer:initStageDrop(  )
    local curRank = mm.data.curDuanWei
    local DropOutTab = INITLUA:getDropOutRes()

    -- local stageId = nil
    -- local camp = mm.data.playerinfo.camp
    -- if 1 == camp then
    --     stageId = DropOutTab[tonumber(curRank)]['LStageID']
    -- else
    --     stageId = DropOutTab[tonumber(curRank)]['DStageID']
    -- end

    -- local StagePlayerExp = INITLUA:getStageResById( stageId ).StagePlayerExp
    -- local StageExpPool = INITLUA:getStageResById( stageId ).StageExpPool

    

    local Table = DropOutTab[tonumber(curRank)]
    local equipTab = {}
    if mm.data.playerinfo.camp == 1 then
        for k,v in pairs(Table.LOLRankEquip) do
            --local equipRes = INITLUA:getEquipByid(v)
            local temp = {}
            temp.type = 1
            temp.id = v
            temp.num = Table.LOLRandEquipNum[k]
            table.insert(equipTab, temp)
        end
        for k,v in pairs(Table.LOLRankItem) do
            local temp = {}
            temp.type = 2
            temp.id = v
            temp.num = Table.LOLRankItemNum[k]
            table.insert(equipTab, temp)
        end
    else
        for k,v in pairs(Table.DOTARankEquip) do
            --local equipRes = INITLUA:getEquipByid(v)
            local temp = {}
            temp.type = 1
            temp.id = v
            temp.num = Table.DOTARankEquipNum[k]
            table.insert(equipTab, temp)
        end
        for k,v in pairs(Table.DOTARankItem) do
            local temp = {}
            temp.type = 2
            temp.id = v
            temp.num = Table.DOTARankItemNum[k]
            table.insert(equipTab, temp)
        end
    end
    self:pushItemIntoList(equipTab, Table.RankHonors, Table.RankGold, Table.RankDiamond)

    self.Node:getChildByName("Image_bg"):getChildByName("Text_goldNum"):setString(Table.RankPlayerExp)
    self.Node:getChildByName("Image_bg"):getChildByName("Text_expNum"):setString(Table.RankExpPool)
    
end

function JinjichenggongLayer:pushItemIntoList(equipTab, honor, gold, diamond)
    local ListView = self.Node:getChildByName("Image_bg"):getChildByName("ListView_equip")
    ListView:removeAllItems()
    for i=1, #equipTab do
        local imageView
        if equipTab[i].type == 1 then
            imageView = gameUtil.createEquipItem(equipTab[i].id, equipTab[i].num)
        else
            imageView = gameUtil.createItemWidget(equipTab[i].id, equipTab[i].num)
        end
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(imageView:getContentSize())
        custom_item:addChild(imageView)
        ListView:pushBackCustomItem(custom_item)
    end

    if honor > 0 then
        local imageView = gameUtil.createOTItem("res/icon/jiemian/icon_rongyu.png", honor)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(imageView:getContentSize())
        custom_item:addChild(imageView)
        ListView:pushBackCustomItem(custom_item)
    end

    if gold > 0 then
        local imageView = gameUtil.createOTItem("res/icon/jiemian/icon_jinbi.png", gold)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(imageView:getContentSize())
        custom_item:addChild(imageView)
        ListView:pushBackCustomItem(custom_item)
    end

    if diamond > 0 then
        local imageView = gameUtil.createOTItem("res/icon/jiemian/icon_zuanshi.png", diamond)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(imageView:getContentSize())
        custom_item:addChild(imageView)
        ListView:pushBackCustomItem(custom_item)
    end
end



function JinjichenggongLayer:addRankImg( node, curDuanWei )
     local res = "icon1"
    local curDuanWei = tonumber(curDuanWei)
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
        curDuanWei = 1093677105
        res = "icon1"
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
    -- node:removeAllChildren()
    -- node:addChild(anime,10)
    -- anime:setName('duanwei')
    -- anime:setTag(curDuanWei)
    -- animation:play(res)

    local anime = gameUtil.createSkeAnmion( {name = res, scale = 1.2} )
    anime:setAnimation(0, "stand", true)
    node:removeAllChildren()
    node:addChild(anime,10)
    anime:setName('duanwei')
    anime:setTag(curDuanWei)

    if res ~= "ds" and res ~= "zqwz" then
        local index = INITLUA:getDropOutRes()[curDuanWei]['RankIconNum']
        anime:setAttachment(res .."=",res .."=" ..index )
    end

end






function JinjichenggongLayer:ButtonCloseBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()

     
    end
end

function JinjichenggongLayer:ButtonOkBack(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
        if mm.GuildId == 15004 then
            Guide:startGuildById(15005, mm.GuildScene.duanweiBtn)
        elseif mm.GuildId == 15055 then
            -- Guide:startGuildById(10037, mm.GuildScene.jszBtn)
            Guide:GuildEnd()
        end
    end
end


return JinjichenggongLayer


