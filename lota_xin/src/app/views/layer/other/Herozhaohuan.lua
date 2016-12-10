local Herozhaohuan = class("Herozhaohuan", require("app.views.mmExtend.LayerBase"))
Herozhaohuan.RESOURCE_FILENAME = "Herozhaohuan.csb"

function Herozhaohuan:onCreate(param)
    self:init(param)
    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function Herozhaohuan:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "heroHeChen" then
            self:zhaohuanBack(event.t)
        end
    end
end

function Herozhaohuan:onEnter()
    if mm.GuildId == 10029 then
        Guide:startGuildById(10030, self.zhaohuanBtn)
    end
end

function Herozhaohuan:onExit()
    
end

function Herozhaohuan:onEnterTransitionFinish()
    
end

function Herozhaohuan:onExitTransitionStart()
    
end

function Herozhaohuan:onCleanup()
    self:clearAllGlobalEventListener()
end

function Herozhaohuan:init(param)

    self.app = param.app
    self.heroId = param.heroId
    self.Node = self:getResourceNode()
    
    self.Node:getChildByName("Panel_touch"):addTouchEventListener(handler(self, self.backBtnCbk))

    local Image_icon = self.Node:getChildByName("Image_bg"):getChildByName("hero_icon")
    Image_icon:loadTexture(gameUtil.getHeroIcon(self.heroId))
    local Image_kuang = ccui.ImageView:create()
    Image_kuang:loadTexture("res/icon/jiemian/jm_herokuang1.png")
    Image_kuang:setAnchorPoint(cc.p(0, 0))
    Image_kuang:setScale(Image_icon:getContentSize().width/Image_kuang:getContentSize().width, Image_icon:getContentSize().height/Image_kuang:getContentSize().height)
    Image_icon:addChild(Image_kuang)

    self.Node:getChildByName("Image_bg"):getChildByName("Text_name"):setText(gameUtil.getHeroTab( self.heroId ).Name)
    self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_src"):setText(gameUtil.getHeroTab( self.heroId ).Hero_Desc)

    local xinlv = gameUtil.getHeroTab(self.heroId).chushixin
    local NeedGold = 0
    for i=1, xinlv do
        NeedGold = NeedGold + PEIZHI.xinji[i].gold
    end
    if NeedGold ~= 0 then
        self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_NeedGold"):setString("还需要金币："..NeedGold)
    else
        self.Node:getChildByName("Image_bg"):getChildByName("Image_bg01"):getChildByName("Text_NeedGold"):setVisible(false)
    end
    -- 添加星级
    for i=1, xinlv do
        local image_xing = ccui.ImageView:create()
        image_xing:loadTexture("res/UI/icon_xingxing_normal.png")

        image_xing:setPosition(Image_icon:getContentSize().width * 0.5 + (i - 1) * image_xing:getContentSize().width - (xinlv - 1) * image_xing:getContentSize().width * 0.5, image_xing:getContentSize().height * 0.5)
        image_xing:setScale(0.6)
        Image_icon:addChild(image_xing)
    end

    -- 装备按钮
    self.zhaohuanBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_EquipmentBtn")
    gameUtil.setBtnEffect(self.zhaohuanBtn)
    self.zhaohuanBtn:addTouchEventListener(handler(self, self.zhaohuanBtnCbk))
    
    local backBtn = self.Node:getChildByName("Image_bg"):getChildByName("Button_back")
    backBtn:addTouchEventListener(handler(self, self.backBtnCbk))
    gameUtil.setBtnEffect(backBtn)

    

    

end

function Herozhaohuan:zhaohuanBack( event )
    local type  = event.type
    if 0 == type then

        if mm.GuildId == 10030 then
            Guide:startGuildById(10031, mm.GuildScene.heroListBackBtn)
        end

        mm.data.playerHero = event.playerHero
        mm.data.playerHunshi = event.playerHunshi

        game:dispatchEvent({name = EventDef.UI_MSG, code = "heroHeChen"})

        local GetHeroLayer = require("src.app.views.layer.GetHeroLayer").new({heroId = self.heroId})
        local size  = cc.Director:getInstance():getWinSize()
        mm.self:addChild(GetHeroLayer, MoGlobalZorder[2999999])
        GetHeroLayer:setContentSize(cc.size(size.width, size.height))
        GetHeroLayer:setPosition(cc.p(0, 0))
        ccui.Helper:doLayout(GetHeroLayer)

        self:removeFromParent()
        gameUtil.playUIEffect( "Hero_Summon" )
    elseif type == 1 then
        gameUtil:addTishi({p = self, s = event.message})
    end
end

function Herozhaohuan:zhaohuanBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        mm.req("heroHeChen",{getType=1,heroId = self.heroId})
    end
end

function Herozhaohuan:backBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

return Herozhaohuan
