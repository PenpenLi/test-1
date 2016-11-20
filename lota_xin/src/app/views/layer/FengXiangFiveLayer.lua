local FengXiangFiveLayer = class("FengXiangFive", require("app.views.mmExtend.LayerBase"))
FengXiangFiveLayer.RESOURCE_FILENAME = "FenxiangLayer.csb"

function FengXiangFiveLayer:onEnter()
	--self:init()
end

function FengXiangFiveLayer:onCleanup()
    self:clearAllGlobalEventListener()
end

function FengXiangFiveLayer:onExit()
	
end

function FengXiangFiveLayer:onCreate(param)
    self:init(param)

    self:addGlobalEventListener(EventDef.SERVER_MSG, handler(self, self.globalEventsListener))
end

function FengXiangFiveLayer:init(param)
	--添加node事件
	self.scene = param.scene
    self.Node = self:getResourceNode()

    local rootNode = self.Node:getChildByName("Image_bg")
    local leftText = rootNode:getChildByName("Image_top"):getChildByName("Text_myZhanLi")
    
    local num = 0
    if mm.puTongZhen then
        num  = #mm.puTongZhen
    end
    local tibuNum = #mm.data.playerHero - num
    leftText:setString("替补数量:"..tibuNum)

    local rightText = rootNode:getChildByName("Image_top"):getChildByName("Text_hisZhanLi")
    rightText:setString("战力:"..gameUtil.dealNumber( gameUtil.getPlayerForce( mm.data.playerExtra.pkValue ) ))


    local infoNode = rootNode:getChildByName("Image_di")
    if mm.data.playerinfo.camp == 1 then
        infoNode:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/L036.png")
    else
        infoNode:getChildByName("Image_touxiang1"):loadTexture("res/icon/head/D038.png")
    end
    infoNode:getChildByName("Text_dengji"):setString(gameUtil.getPlayerLv(mm.data.playerinfo.exp or 0))
    infoNode:getChildByName("Text_name"):setString(mm.data.playerinfo.nickname)
    gameUtil.setVipLevel( infoNode:getChildByName("Node_vip"), gameUtil.getPlayerVipLv(mm.data.playerinfo.vipexp) )

    local currentServer = gameUtil.getDefaultServerInfo(game.severList)
    local curSeverName = currentServer.Name
    
    -- local severId = cc.UserDefault:getInstance():getIntegerForKey("severId",0)
    -- local curSeverName = ""
    -- for k,v in pairs(game.severList) do
    --     if v.id == severId then
    --         curSeverName = v.Name
    --     end
    -- end
    infoNode:getChildByName("Text_zhandouli"):setString("服务器:"..curSeverName)


    local closeBtn = rootNode:getChildByName("Button_back")
    closeBtn:addTouchEventListener(handler(self, self.closeBtnCbk))
    gameUtil.setBtnEffect(closeBtn)

    local weixinBtn = rootNode:getChildByName("Button_3")
    weixinBtn:addTouchEventListener(handler(self, self.weixinBtnCbk))
    gameUtil.setBtnEffect(weixinBtn)

    local weiboBtn = rootNode:getChildByName("Button_4")
    weiboBtn:addTouchEventListener(handler(self, self.weiboBtnCbk))
    gameUtil.setBtnEffect(weiboBtn)

    local circleBtn = rootNode:getChildByName("Button_5")
    circleBtn:addTouchEventListener(handler(self, self.circleBtnCbk))
    gameUtil.setBtnEffect(circleBtn) 

    self:initMyZhenData()
    self:showHero() 
end

function FengXiangFiveLayer:initMyZhenData( )
    local putongForm = nil
    for i=1,#mm.data.playerFormation do
        if mm.data.playerFormation[i].type == 1 then
            putongForm = mm.data.playerFormation[i]
        end
    end
    self.myZhen = {}
    if putongForm ~= nil then
        for i=1,#putongForm.formationTab do
            self.myZhen[i] = {}
            self.myZhen[i].id = putongForm.formationTab[i].id
            local pos = gameUtil.getHeroTab( self.myZhen[i].id ).pos
            self.myZhen[i].pos = pos
        end
    end
end

function FengXiangFiveLayer:showHero()
    local sortRules = {
        {
            func = function(v)
                return v.pos
            end,
            isAscending = true
        },
    }
    self.myZhen = util.powerSort(self.myZhen, sortRules)

    local rootNode = self.Node:getChildByName("Image_bg")
    for i = 1, 5 do
        local Image = rootNode:getChildByName("Image_hero"):getChildByName("Image_"..i)
        local oldHero = Image:getChildByName("Hero")
        if oldHero ~= nil then
            oldHero:removeFromParent()
        end
    end
    for i = 1, #self.myZhen do
        local Image = rootNode:getChildByName("Image_hero"):getChildByName("Image_"..i)
        local skeletonNode = gameUtil.createSkeletonAnimation(gameUtil.getHeroTab(self.myZhen[i].id).Src..".json", gameUtil.getHeroTab(self.myZhen[i].id).Src..".atlas",1.5)
        skeletonNode:setPosition(Image:getContentSize().width * 0.5, Image:getContentSize().height * 0.8)
        skeletonNode:update(0.012)
        skeletonNode:setAnimation(0, "stand", true)
        skeletonNode:setScale(0.6)
        skeletonNode:setName("Hero")
        Image:addChild(skeletonNode)
    end
end


function FengXiangFiveLayer:globalEventsListener( event )
    if event.name == EventDef.SERVER_MSG then
        if event.code == "getStoreInfo" then

        end
    end
end

function FengXiangFiveLayer:closeBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:removeFromParent()
    end
end

function FengXiangFiveLayer:weixinBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then 
        self:captureScreenAndShare()
    end
end

function FengXiangFiveLayer:weiboBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:captureScreenAndShare()
    end
end

function FengXiangFiveLayer:circleBtnCbk(widget,touchkey)
    if touchkey == ccui.TouchEventType.ended then
        self:captureScreenAndShare()
    end
end

function FengXiangFiveLayer:captureScreenAndShare( )
    --[[
    public static final String share_sdk_title_key = "title";
    public static final String share_sdk_title_url_key = "titleurl";
    public static final String share_sdk_text_key = "text";
    public static final String share_sdk_pic_path_key = "picpath";
    picurl
    public static final String share_sdk_url_key = "url";
    public static final String share_sdk_comment_key = "comment";
    public static final String share_sdk_site_url_key = "siteurl";
    public static final String share_sdk_site_key = "site";
    --]]
    --截屏回调方法  
    local function afterCaptured(succeed, outputFile)  
        if succeed then  
            print("Capture screen succeed...."..outputFile)  
            local info = {}
            info.title = "LOTA方块战争"
            info.text = "MOBA大乱斗，你是支持撸啊撸还是刀塔呢！？#LOTA#"

            info.picurl = ""

            --local savePath = SystemUtil:getPicturePath()
            --info.picpath = savePath.."/mengmobile_picaaaa_mh1444797200816.jpg"
            info.picpath = outputFile
            -------weixin--------------url为空时 为分享图片!!-----
            info.url = ""
            info.url = "http://www.lolvsdota.cn/index.html"
            -----------QQ REN----------
            info.titleurl = "http://www.lolvsdota.cn/index.html"
            info.comment = "一起来玩吧!"
            info.siteurl = "http://www.lolvsdota.cn/index.html"
            info.site = ""

            info = json.encode(info)
            SDKUtil:shareSDK(info)
        else  
          print("Capture screen failed.")  
        end  
    end 
    local savePath = SystemUtil:getPicturePath()

    local fileName = savePath.."/share_team.jpg"

    cc.utils:captureScreen(afterCaptured, fileName) 
end

return FengXiangFiveLayer