local sprotoparser = require "app.net.sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
    type 0 : integer
    session 1 : integer
}

handshake 1 {
    response {
        msg 0  : string
    }
}

.playerinfo {
    id          0   : integer
    qufu        1   : string
    nickname    2   : string
    exp         3   : integer
    level       4   : integer
    camp        5   : integer   # 1:lol  2:dota
    gold        6   : integer
    diamond     7   : integer
    shenbing    8   : integer
    viplevel    9   : integer
    vipexp      10  : integer
    exppool     11  : integer
    card        12  :*integer
    luckyValue  13  : integer
    honor       14  : integer
    gongxian    15  : integer
    uid         16  : string
    monthcard         17  : integer  #月卡剩余发放次数(暂时没用)
    highmonthcard     18  : integer  #高级月卡剩余发放次数(暂时没用)
    alllife           19  : integer  #终生卡数量
    rechargetype      20  : string   #已存在的充值商品ID
    myMaxRank    21 : string
    lockEndTime  22 : integer
    talkOpenTime 23 : integer
    coinValue    24 : integer
    gameSession  25 : string
    meleeCoin    26 : integer
    pkCoin       27 : integer
    logicQufu    28 : string
    lastMonthcardTimes           29  : integer  #月卡剩余发放次数
    lastHighmonthcardTimes       30  : integer  #高级月卡剩余发放次数
    dailyBuySDCount              31  : integer
}

.stageInfo {
    chapter     0 : integer
    stageId     1 : integer
    max_proc    2 : integer
    dailyCount  3 : integer
    extraTime           4 : integer
    buyExtraTime        5 : integer
}

.playerExtra{
    skillNum                0 : integer
    RaidsTimes              1 : integer
    refreshSkillTime        2 : integer
    exchangeGoldLevel       3 : integer
    exchangeExpPoolLevel    4 : integer
    exchangeGoldDayTimes    5 : integer
    exchangeExpDayTimes     6 : integer
    pkValue                 7 : integer
    vipGiftTab              8 : *integer
    buyFundRecord           9 : string
    pkTimes                 10 : integer
    EquipBuyCount           11 : integer
    blessTimes              12 : integer  #祝福次数
    lastMeleeTime           13 : integer  #上次参战时间
    meleeTimes              14 : integer  #参战次数
    reliveTimes             15 : integer  #复活次数
    noCDStatus              16 : integer  #春哥状态 0 true
    noCDTimes               17 : integer  #春哥次数
    noCDStatusMeleeTimes    18 : integer  #春哥状态后 参战次数
    hasRaidsTimes           19 : integer
    refreshStoreTimes       20 : integer
    saodangTimes            21 : integer
    momianTimes             22 : integer
    wumianTimes             23 : integer
    lastRecoverChallengeTime   24 : integer
    challengeTimes          25 : integer
}


.talkInfo {
        type            0 : integer
        fromid          1 : integer
        fromname        2 : string
        toid            3 : integer
        toname          4 : string
        message         5 : string
        vipLv           6 : integer
        camp            7 : integer
        lv              8 : integer
}

login 2{
    request {
        uid        0 : string
        qudao      1 : string
        qufu       2 : string
        session    3 : string
        param      4 : string
        zi_qudao   5 : string
    }

    response {
        type            0 : integer       # 0:success 1:error 2:请创建角色
        message         1 : string
        playerinfo      2 : playerinfo
        playerEquip     3 : *equipinfo
        playerItem      4 : *iteminfo
        playerHunshi    5 : *hunshiinfo
        playerHero      6 : *heroInfo
        playerFormation 7 : *formation
        playerStage     8 : *stageInfo
        playerTask      9 : *taskInfo
        TaskProc        10 : taskProc
        guajiTime       11 : integer
        guajiWuPin      12 : *integer
        curDuanWei      13 : string
        playerExtra     14 : playerExtra
        dropTab         15 : *dropinfo
        addPoolExp      16 : integer
        addGold         17 : integer
        addExp          18 : integer
        noReadNum       19 : integer
	    myMaxRank       20 : string
        activityInfo    21 : string
        activityRecord  22 : string
        publicActivityExtraInfo     23 : string
        closeFuncTab    24 : *integer
        meleeStatus     25 : integer
        ranktime        26 : integer
        worldTalk       27 : *talkInfo
    }
}

createactor 3 {
    request {
        camp            0 : integer     # 1:dota   2:lol
        actorid         1 : integer
        nickname        2 : string
        qufu            3 : string
        zi_qudao        4 : string
        qudao           5 : string
    }

    response {
        type            0 : integer     # 0:success 1:error
        message         1 : string
        playerinfo      2 : playerinfo
        playerHero      3 : *heroInfo
        playerFormation 4 : *formation
        playerExtra     5 : playerExtra
        curDuanWei      6 : string
        activityInfo    7 : string
        activityRecord  8 : string
        publicActivityExtraInfo     9 : string
        closeFuncTab    10 : *integer
        meleeStatus     11 : integer
        ranktime        12 : integer
        worldTalk       13 : *talkInfo
    }

}

reconnect 4 {
    request {
        qudao       0 : string
        uid         1 : string
        session     2 : string
        playerid    3 : integer
        qufu        4 : string
        gameSession 5 : string
    }

    response {
        type            0 : integer     # 0:success 1:error
        message         1 : string
    }
}

talk 5{
    request {
        type        0 : integer
        playerid    1 : integer
        message     2 : string
    }

    response {
        type            0 : integer
        playerInfo      1 : playerinfo
        playerItem      2 : *iteminfo
        dailyTalkCount  3 : integer
    }
}

.heroDiedTab{
    heroId    1 : integer
    camp      2 : integer
}

.dropinfo{
    id    1 : integer
    num   2 : integer
    type  3 : integer     # 1.装备   2.道具   3.魂石  4.皮肤
}

fight 6 {
    request {
        type        0 : integer
        result      1 : integer  # 0:success 1:fail
        enemyid     2 : integer
        stageId     3 : integer
        heroDiedTab 4 : *heroDiedTab
        failtime    5 : integer
        userAction  6 : *integer
    }

    response {
        type            0  : integer     # 0:success 1:error
        playerinfo      1  : playerinfo
        addExp          2  : integer
        addGold         3  : integer
        addMoney        4  : integer
        playerEquip     5  : *equipinfo
        playerItem      6  : *iteminfo
        playerHunshi    7  : *hunshiinfo
        playerHero      8  : *heroInfo
        dropTab         9  : *dropinfo
        playerStage     10 : *stageInfo
        guajiTime       11 : integer
        guajiWuPin      12 : *integer
        stageId         13 : integer
        result          14 : integer
        pkValue         15 : integer
        addExppool      16 : integer
        addhonors       17 : integer
        ranktime        18 : integer        
        enemyid         19 : integer
        startIndex      20 : integer
        endIndex        21 : integer
        addHonor        22 : integer
        fightType       23 : integer
    }
}

.equipinfo {
    id          0   : integer
    num          1   : integer
}

addEquip 7 {
    request {
        getType         0 : integer
        equipinfo       1 : *equipinfo
    }

    response {
        type        0 : integer     # 0:success 1:error

    }
}

getEquip 8 {
    request {
        getType         0 : integer

    }

    response {
        type                0 : integer     # 0:success 1:error
        playerEquip         1 : *equipinfo
    }
}

.heroEqInfo {
    eqIndex  0: integer
    eqId 1   : integer
    eqLv 2   : integer
}

.skillInfo {
    id 0   : integer
    lv 1   : integer
    index 2  : integer
}

.heroInfo {
    id          0   : integer
    lv          1   : integer
    xinlv       2   : integer
    jinlv       3   : integer
    exp         4   : integer
    eqTab       5   : *heroEqInfo
    skill       6   : *skillInfo
    preciousInfo 7 : *preciousInfo
    skinInfo     8 : skinInfo
}

addHero 9 {
    request {
        getType         0 : integer
        heroInfo       1 : *heroInfo
    }

    response {
        type        0 : integer     # 0:success 1:error

    }
}

getHero 10 {
    request {
        getType         0 : integer

    }

    response {
        type                0 : integer     # 0:success 1:error
        playerHero         1 : *heroInfo
    }
}

.hunshiinfo {
    id          0   : integer
    num          1   : integer
}

addHunshi 11 {
    request {
        getType         0 : integer
        hunshiinfo       1 : *hunshiinfo
    }

    response {
        type        0 : integer     # 0:success 1:error

    }
}

getHunshi 12 {
    request {
        getType         0 : integer

    }

    response {
        type                0 : integer     # 0:success 1:error
        playerHunshi         1 : *hunshiinfo
    }
}

.iteminfo {
    id          0   : integer
    num         1   : integer
    level       2   : integer
}

addItem 13 {
    request {
        getType         0 : integer
        iteminfo       1 : *iteminfo
    }

    response {
        type        0 : integer     # 0:success 1:error

    }
}

getItem 14 {
    request {
        getType         0 : integer

    }

    response {
        type                0 : integer     # 0:success 1:error
        playerItem         1 : *iteminfo
    }
}

heroUpXin 15 {
    request {
        getType         0 : integer
        heroId          1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerHunshi        1 : *hunshiinfo
        playerHero          2 : heroInfo
        message             3 : string
        HeroXingUpCount     4 : integer
        playerInfo          5 : playerinfo
    }
}

heroUpExp 16 {
    request {
        getType         0 : integer
        heroId          1 : integer
        itemId          2 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerItem         1 : *iteminfo
        playerHero         2 : *heroInfo
        message     3 : string
    }
}

equipSell 17 {
    request {
        getType          0 : integer
        equipId          1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerEquip         1 : *equipinfo
        message             2 : string
    }
}

heroUpequip 18 {
    request {
        getType         0 : integer
        heroId          1 : integer
        eqId            2 : integer
        eqIndex         3 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerEquip         1 : *equipinfo
        playerHero          2 : heroInfo
        message             3 : string
    }
}

eqHeChen 19 {
    request {
        getType         0 : integer
        eqId            1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerEquip         1 : *equipinfo
        playerHunshi          2 : *hunshiinfo
        message             3 : string
    }
}

heroUpPinJie 20 {
    request {
        getType           0 : integer
        heroId            1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerHero          1 : heroInfo
        message             2 : string
    }
}

heroHeChen 21 {
    request {
        getType             0 : integer
        heroId              1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerHero          1 : *heroInfo
        playerHunshi        2 : *hunshiinfo
        message             3 : string
        playerInfo          4 : playerinfo
    }
}

.formationId {
    id          0 : integer

}

.formation {
    type              0 : integer
    formationTab      1 : *formationId
    helpFormationTab  2 : *formationId
}

saveFormation 22 {
    request {
        getType             0 : integer
        playerFormation     1 : formation
        pkType              2 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        message             1 : string
        playerFormation     2 : *formation
        pkTimes             3 : integer
    }
}


.areaninfo {
    playerid            0 : integer
    ranking             1 : integer
    nickname            2 : string
    level               3 : integer
    wins                4 : integer
    camp                5 : integer
    zhanli              6 : string
    meleeKillNum        7 : integer
}

getRank 23 {
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        rankList            1 : *areaninfo
        lv                  2 : string
        message             3 : string
    }
}



.fuchouinfo {
    playerid            0 : integer
    nickname            1 : string
    zhanli              2 : integer
    duanwei             3 : string
    zhanqu              4 : string
}

getFuChou 24 {
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        fuchouList            1 : *fuchouinfo
        message             2 : string
    }
}

fuChouZhan 25 {
    request {
        getType             0 : integer
        fuchouId            1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerinfo          1 : playerinfo
        playerEquip         2 : *equipinfo
        playerHero          3 : *heroInfo
        playerFormation     4 : *formation
        message             5 : string
    }
}

.direninfo {
    playerinfo          1 : playerinfo
    playerEquip         2 : *equipinfo
    playerHero          3 : *heroInfo
    playerFormation     4 : *formation
    pkValue             5 : integer
}

getDiRenList 26 {
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        direninfo           1 : *direninfo
        message             2 : string
    }
}

.taskInfo{
    taskId              0 : integer
    taskValue           1 : integer
    taskState           2 : integer         # 0:HaveGet 1:NotGet
}

.taskProc{
    DailyPKCount              0 : integer
    killTimorCount            1 : integer
    killYingMoCount           2 : integer
    HeroMaxLevel              3 : integer
    HeroQuality               4 : integer
    PkWithDiCount             5 : integer
    PkWithMyCamp              6 : integer
    PkWithFamous              7 : integer
    PkWithStage               8 : integer
    HeroLevelCount            9 : integer
    HeroJinJieCount           10 : integer
    HeroSkillUpCount          11 : integer
    EquipBuyCount             12 : integer
    ExpBuyCount               13 : integer
    GoldBuyCount              14 : integer
    HeroXingUpCount           15 : integer
    dailyTalkCount            16 : integer
    saodangTimes              17 : integer
    wumianTimes               18 : integer
    momianTimes               19 : integer
    DailyEquipBuyCount        20 : integer
    DailyHeroSkillUpCount     21 : integer
    TianTiLadder              22 : integer
    DailySnipeCount           23 : integer
}

getTaskInfo 27{
    request {
        getType             0 : integer
        getClassify         1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        taskInfo            1 : *taskInfo
        taskProc            2 : taskProc
        playerStage         3 : *stageInfo
    }
}

getTaskReward 28{
    request {
        getType             0 : integer
        taskId              1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        taskInfo            1 : taskInfo
        playerInfo          2 : playerinfo
        playerEquip         3 : *equipinfo
        playerItem          4 : *iteminfo
        playerHunshi        5 : *hunshiinfo
    }
}

heroLevelUp 29{
    request {
        getType             0 : integer
        heroId              1 : integer
    }

    response {
        type                0 : integer     # 0:success 1:failed
        playerHero          1 : heroInfo
        exppool             2 : integer
    }
}

.buyItemInfo {
    itemID                  0 : integer
    itemNum                 1 : integer
    status                  2 : integer  #销售状态 0 在售 1 售罄
    storeID                 3 : string   #销售商城ID
}

.buyGoldInfo {
    diamond                 0 : integer
    crit                    1 : integer
    gold                    2 : integer
}

.buyExpInfo{
    diamond                 0 : integer
    crit                    1 : integer
    exp                     2 : integer
}

.stageExtra{
    id                      0 : integer
    extraTime               1 : integer
    buyExtraTime            2 : integer
}

buySomeThing 30{
    request {
        getType             0 : integer  #用来携带某些id
        buyType             1 : integer  #1 购买经验 2 商城物品 3 直购装备 4 直购金币 5 购买vip礼包 6 兑换技能点或者pk次数 7 购买道具
        buyItemInfo         2 : buyItemInfo
    }

    response {
        type                0 : integer     # 0:success 1:failed
        code                1 : integer
        playerinfo          2 : playerinfo
        buyItemInfo         3 : buyItemInfo
        storeInfo           4 : *storeInfo
        playerEquip         5 : *equipinfo
        buyGoldInfo         6 : *buyGoldInfo
        soldOut             7 : integer
        playerExtra         8 : playerExtra
        buyExpInfo          9 : *buyExpInfo
        playerItem          10 : *iteminfo
        playerHunshi        11 : *hunshiinfo
        dropTab             12 : *dropinfo
        stageExtra          13 : stageExtra
    }
}

.mailGoodsItem {
    id          0   : integer
    num         1   : integer
    type        2   : integer   # 1.装备   2.道具   3.魂石  4.皮肤
}

.mailGoodsinfo {
    exp             0   : integer
    gold            1   : integer
    diamond         2   : integer
    vipexp          3   : integer
    exppool         4   : integer
    honor           5   : integer
    gongxian        6   : integer
    mailGoodsItem   7   : *mailGoodsItem
    meleeCoin       8   : integer
    skillNum        9   : integer
    raidsNum        10  : integer
}

.mailinfo {
   id        0 : integer
   fromid    1 : integer
   fromname  2 : string
   toid      3 : integer
   toname    4 : string
   title     5 : string
   text      6 : string
   mailGoodsinfo  7 : mailGoodsinfo
   hasread   8 : integer     #0:未读   1：已读
   time      9 : integer
   mailType  10 : integer
   newMailType 11 : integer
   mailIcon    12 : string
   jumpto      13 : string
}

maillist 31 {
    request {
        type    0 : integer
    }
    response {
        type     0 : integer   # 0:成功  1：没邮件   2：错误  看message
        message  1 : string
        maillist 2 : *mailinfo
    }
}

mailProcess 32 {
    request {
        id     0 : integer
        type   1 : integer          # 1:领取
    }

    response {
        type     0 : integer   #0: 成功  1：失败
        message  1 : string
        id       2 : integer
        dropTab  3 : *dropinfo
        playerInfo    4 : playerinfo
        playerExtra   5 : playerExtra
    }


}

killReward 33 {
    request {
        time           0   : integer
        userAction     1   : *integer
    }

    response {
        type     0 : integer   #0: 成功  1：失败
        playerinfo          1: playerinfo
        message  2 : string
    }
}

guaJiReward 34 {
    request {
        type    0 : integer
    }

    response {
        type                0 : integer   #0: 成功  1：失败
        playerEquip         1 : *equipinfo
        playerItem          2 : *iteminfo
        playerHunshi        3 : *hunshiinfo
        dropTab             5 : *dropinfo
        guajiTime           7 : integer
        guajiWuPin          8 : *integer
        playerinfo          9 : playerinfo
        playerExtra         10 : playerExtra
        addPoolExp          12  : integer
        addGold             13  : integer
        addExp              14 : integer
        noReadNum           15 : integer
    }
}


.storeItemInfo {
    showIndex               0   : integer    #显示顺序
    discountValue           1   : integer    #折扣值
    itemID                  2   : integer    #物品ID
    condition               3   : integer    #限制条件 0 无, 1 vip限制
    conditionValue          4   : integer    #限制条件的值
    status                  5   : integer    #销售状态 0 在售 1 售罄
}


.storeInfo {
    refreshTime          0   : *integer        #刷新时间
    storeItems           1   : *storeItemInfo  #在售商品信息列表
    shopSort             2   : integer         #显示顺序
    storeID              3   : string          #商场ID
}

getStoreInfo 35 {
    request {
        type    0 : integer
    }

    response {
        type                0 : integer   #0: 成功  1：失败
        storeInfo           1 : *storeInfo
        playerinfo          2 : playerinfo
    }
}

refreshStoreInfo 36 {
    request {
        type               0 : integer
        storeID            1 : string          #商场ID
    }

    response {
        type                0 : integer   #0: 成功  1：失败
        code                1 : integer
        storeInfo           2 : *storeInfo
        playerinfo          3 : playerinfo
        playerItem          4 : *iteminfo
        playerExtra         5 : playerExtra
    }
}

skillUp 37 {
    request {
        type               0 : integer
        heroId             1 : integer
        skillId            2 : integer
    }

    response {
        type                0 : integer
        skillNum            1 : integer
        playerHero          2 : heroInfo
        message             3 : string
        gold                4 : integer
        time                5 : integer
    }
}


Raids 38 {
    request {
        type               0 : integer
        time               1 : integer
    }

    response {
        type                0 : integer
        playerinfo          1 : playerinfo
        playerEquip         2 : *equipinfo
        playerExtra         3 : playerExtra
        addPoolExp          4  : integer
        addGold             5  : integer
        guajiTime           6 : integer
        guajiWuPin          7 : *integer
        addExp              8 : integer
        dropTab             9 : *dropinfo
        playerHunshi        10 : *hunshiinfo
    }
}

.pkStageInfo {
    type    0 : integer
    index   1 : integer
    content 2 : integer
}

.pkPeopleInfo {
    type    0 : integer
    index   1 : integer
    content 2 : direninfo
}

getPKEnterData 39{
    request {
        type        0 : integer
    }

    response {
        type        0 : integer
        pkDiren     1 : direninfo
        pkCount     2 : integer
        time        3 : integer
        serverTime  4 : integer
    }
}

getRandomName 40{
    request {
        type        0 : integer
        qufu        1 : string
    }

    response {
        type        0 : integer
        name        1 : string
    }
}

getMailNumWithoutRead 41{
    request {
        type        0 : integer
    }

    response {
        type        0 : integer
        num         1 : integer
    }
}

readMail 42{
    request {
        type        0 : integer
        id          1 : integer
    }

    response {
        type        0 : integer
        num         1 : integer
    }
}

rankUp 43{
    request {
        type        0 : integer
        toRank      1 : string
    }

    response {
        type            0 : integer
        curRank         1 : string
        message         2 : string
        playerinfo      3 : playerinfo
    }
}

.rankListInfo {
    playerid            0 : integer
    nickname            1 : string
    exp                 2 : integer
    camp                3 : integer
    zhanli              4 : integer
    qufu                5 : string
}

getRankList 44 {
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer
        rankList            1 : *rankListInfo
        rank                2 : string
        message             3 : string
    }
}

.orderInfo {
    orderid            0 : string
    proId              1 : string
}

getOrderInfo 45{
    request {
        type           0 : integer
        proId          1 : string
    }

    response {
        type        0 : integer
        orderInfo   1 : orderInfo
    }
}

.recordInfo {
    proId              0 : string
}

getBuyRecordInfo 46{
    request {
        type           0 : integer
    }

    response {
        type            0 : integer
        buyRecordInfo   1 : *recordInfo
    }
}

useItem 47{
    request {
        type           0 : integer
        itemId         1 : integer
    }

    response {
        type            0 : integer
        playerInfo      1 : playerinfo
        dropTab         2 : *dropinfo
        itemId          3 : integer
        playerExtra     4 : playerExtra
    }
}

getActivityInfo 48{
    request {
        type           0 : integer
    }

    response {
        type                        0 : integer
        activityInfo                1 : string
        activityRecord              2 : string
        publicActivityExtraInfo     3 : string
    }
}

rewardActivity 49{
    request {
        type           0 : integer
        activityId     1 : string
        conditionValue 2 : integer
        actLevel       3 : integer
    }

    response {
        type           0 : integer
        playerinfo     1 : playerinfo
        playerExtra    2 : playerExtra
        conditionValue 3 : integer
        activityInfo   4 : string
        activityRecord 5 : string
        publicActivityExtraInfo     6 : string
        rewardID       7 : integer
        dropTab        8 : *dropinfo
    }
}

buyFund 50{
    request {
        type           0 : integer
    }

    response {
        type           0 : integer
        code           1 : integer
        playerinfo     2 : playerinfo
        playerExtra    3 : playerExtra
        activityRecord 4 : string
    }
}


readActivity 51{
    request {
        type           0 : integer
        activityId     1 : integer
    }

    response {
        type           0 : integer
        activityId     1 : integer
    }
}

.eventSprite {
    key              0 : string
    value            1 : string
}

.payTimes {
    type             0 : integer
    value            1 : integer
}

refreshEvent 52{
    request {
        type           0 : integer
    }

    response {
        type           0 : integer
        data           1 : *eventSprite
        pkPayTimes     2 : *payTimes
    }
}

.luckdrawInfo {
    gold           0 : integer    # 金币更新
    diamond        1 : integer    # 钻石更新
    expPool        2 : integer    # 经验池更新（增加）
    goldTime       3 : integer    # 剩余时间
    diamondTime    4 : integer    # 剩余时间
    enemyTime      5 : integer    # 剩余时间
    restGoldTimes  6 : integer
    restDiamondTimes  7 : integer
    restEnemyTimes  8 : integer    
}

.consumeItemInfo {
    id          0 : integer  # 消耗id
    count       1 : integer  # 消耗个数
}

luckdraw 53{
    request {
        type           0 : string     # "gold" "diamond" "enemy" "info"
        subtype        1 : integer    # 0:免费  1：一次   2：10次
    }

    response {
        type            0 : integer    # 0：成功  1：免费次数已过 2：时间未到 3：钱不够 4:金币不够 5:钻石不足 6:未知错误
        message         1 : string     #
        items           2 : *integer   # 物品id
        hunshiIndex     3 : *integer   # 是英雄转化的魂石，则把index记录下来
        consumeItemInfo 4 : consumeItemInfo # 消耗物品的信息
        luckdrawInfo    5 : luckdrawInfo    # 剩余时间等信息
    }
}

.preciousInfo {
    id          0   : integer
    order       1   : integer # 阶
    lv          2   : integer # 级
    restExp     3   : integer # 剩余经验
}

preciousLvUp 54{
    request {
        heroId           0 : integer     # 英雄Id
        preciousId       1 : integer     # 至宝Id
        orderTag         2 : integer     # 0:升级 1:进阶
        itemId           3 : *integer     # 消耗Item
    }

    response {
        result         0 : integer    # 0：升级成功  1：进阶成功 2：其他错误
        message        1 : string     # 其他错误信息
        heroId         2 : integer     # 英雄Id
        preciousInfo   3 : preciousInfo # 至宝id和经验
        itemId         4 : *integer     # 消耗Item
    }
} 

.skinCollected {
    id          0   : integer # skinId
    flag        1   : integer # 0 未收集 1 已收集 2 已收集未使用过
}

.skinInfo {
    id          0   : integer # skinId
    collectList 1   : *skinCollected
}

skinOn 55{
    request {
        heroId           0 : integer     # 英雄Id
        skinId           1 : integer     # 皮肤Id
        tag              2 : integer     # 0 请求信息 1 穿上 
    }

    response {
        result         0 : integer    # 0：成功  1：其他错误
        message        1 : string     #
        heroId         2 : integer     # 英雄Id
        skinInfo       3 : skinInfo    # 皮肤信息
    }
}

meleeEnter 56{
    request {
        
    }

    response {
        type                     0 : integer
        time                     1 : integer
        meleeKillNum             2 : integer
        campKillNum              3 : integer
        autoShowFinalResult      4 : integer  # 0 显示
        meleeStatus              5 : integer
        serverTime               6 : integer
    }
}

getMeleeList 57 {
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        direninfo           1 : *direninfo
        message             2 : string
        campForce           3 : string
    }
}

killMelee 58 {
    request {
        num           0   : integer
    }

    response {
        type              0 : integer
        meleeKillNum      1 : integer
        campKillNum       2 : integer
        campForce         3 : string
    }
}

fightResultMelee 59 {
    request {
        result           0   : integer  #0: 成功  1：失败
    }

    response {
        type     0 : integer   #0: 成功  1：失败
    }
}

.meleeStoreInfo {
    id           0 : integer  #物品ID
    num          1 : integer  #物品剩余个数
}

getMeleeStore 60{
    request {
        type           0 : integer
    }

    response {
        type             0 : integer
        refreshTime      1 : integer
        meleeStoreInfo   2 : *meleeStoreInfo
        meleeWinTimes    3 : integer  #乱斗胜利次数
    }
} 

.buyMeleeStoreItemInfo {
    itemID           0 : integer  #物品ID
    itemNum          1 : integer  #物品个数
}

buyMeleeStoreItem 61{
    request {
        type           0 : integer
        itemID         1 : integer
        itemNum        2 : integer
    }

    response {
        type             0 : integer
        buyItemInfo      1 : buyMeleeStoreItemInfo
        refreshTime      2 : integer
        meleeStoreInfo   3 : *meleeStoreInfo
        meleeWinTimes    4 : integer  #乱斗胜利次数
        code             5 : integer
        playerinfo       6 : playerinfo
        playerEquip      7 : *equipinfo
        playerExtra      8 : playerExtra
        playerItem       9 : *iteminfo
        playerHunshi     10 : *hunshiinfo
    }
} 

blessMelee 62{
    request {
        type           0 : integer
    }

    response {
        type             0 : integer
        code             1 : integer
        playerinfo       2 : playerinfo
        playerExtra      3 : playerExtra
        campForce        4 : string
    }
}

getMeleeRank 63{
    request {
        type            0 : integer
    }

    response {
        type                0 : integer
        rankList            1 : *areaninfo
        myInfo              2 : areaninfo
    }
}

joinMelee 64{
    request {
        type                0 : integer
    }

    response {
        type                0 : integer
        code                1 : integer
        playerinfo          2 : playerinfo
        playerExtra         3 : playerExtra
        meleeKillNum        4 : integer
        campKillNum         5 : integer
        dropTab             6 : *dropinfo
        dropResID           7 : integer
        addKillNum          8 : integer
        serverTime          9 : integer
        campForce           10 : string
    }
}

getFinalResultData 65{
    request {
        type                0 : integer
    }

    response {
        status                 0 : string    # win   fail
        campKillNum            1 : integer
        campForce              2 : string
        playerKillNum          3 : integer
        playerLocalRank        4 : integer
        playerWorldRank        5 : integer
    }
}

saveTheWorld 66{
    request {
        type                0 : integer
    }

    response {
        type                0 : integer
        code                1 : integer
        playerinfo          2 : playerinfo
        playerExtra         3 : playerExtra
        campForce           4 : string
        serverTime          5 : integer
    }
}

getPlayerInfo 67{
    request {
        playerid            0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        direninfo           1 : direninfo
        message             2 : string
    }
}

.zhanliListInfo {
    playerid            0 : integer
    nickname            1 : string
    camp                2 : integer
    zhanli              3 : integer
    tibuNum             4 : integer
    heroId              5 : integer
    heroJinlv           6 : integer
    heroExp             7 : integer 
    heroXinlv           8 : integer
    qufu                9 : string
}


getZhanliList 68{
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        zhanliList          1 : *zhanliListInfo
    }
}

getTibuZhanliList 69{
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        zhanliList          1 : *zhanliListInfo
    }
}

getHeroZhanliList 70{
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        zhanliList          1 : *zhanliListInfo
    }
}

.upEquipResult {
	type                0 : integer     # 0:success 1:error
    playerEquip         1 : *equipinfo
    playerHero          2 : *heroInfo
    message             3 : string
}

composeEquip 71{
    request {
        type                0 : integer
        suipianId           1 : integer
        targetEquipId       2 : integer
        heroId              3 : integer
        eqId                4 : integer
        eqIndex             5 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerEquip         1 : *equipinfo
        upEquipResult       2 : upEquipResult
        playerHero          3 : heroInfo
    }
}

clientHeartBeat 72{
    request {
        type               0 : integer
    }

    response {
        type               0 : integer
    }
}

.eqInfo {
    id     0 : integer
    index  1 : integer
}

heroUpequipAll 73{
    request {
        getType         0 : integer
        heroId          1 : integer
        eqInfos         2 : *eqInfo
    }

    response {
        type                0 : integer     # 0:success 1:error
        playerEquip         1 : *equipinfo
        playerHero          2 : heroInfo
        equipIds            3 : *integer
        message             4 : string
    }
}

saodang 74{
    request {
        type        0 : integer
        stageId     1 : integer
        times       2 : integer
    }

    response {
        type            0  : integer     # 0:success 1:error
        playerinfo      1  : playerinfo
        addExp          2  : integer
        addGold         3  : integer
        addMoney        4  : integer
        playerEquip     5  : *equipinfo
        playerItem      6  : *iteminfo
        playerHunshi    7  : *hunshiinfo
        playerHero      8  : *heroInfo
        dropTab         9  : *dropinfo
        stageId         13 : integer
        addExppool      16 : integer
        addhonors       17 : integer
        times           18 : integer
    }
}

.tianTiInfo {
    id                  0 : integer
    nickname            1 : string
    camp                2 : integer
    score               3 : integer
    rank                4 : integer
    qufu                5 : string
}

getTianTiInfo 75{
    request {
        type        0 : integer
    }

    response {
        type                  0 : integer    
        topTenInfo            1 : *tianTiInfo
        fightInfo             2 : *tianTiInfo
        selfInfo              3 : tianTiInfo
        challengeTimes        4 : integer   #剩余次数
        refreshTianTiTime     5 : integer   #剩余时间
        buychallengeTimes     6 : integer
    }
}

challengeTianTi 76{
    request {
        diamondType         0 : integer     # 0 正常挑战 1 砖石挑战
        playerid            1 : integer
    }

    response {
        diamondType         0 : integer     # 0 砖石正常 1 砖石不足 2 购买次数超出 3 未知错误
        type                1 : integer     # 0:success 1:error
        direninfo           2 : direninfo
        message             3 : string
        buychallengeTimes   4 : integer
    }
}

getTianTiList 77{
    request {
        getType             0 : integer
    }

    response {
        type                0 : integer     # 0:success 1:error
        zhanliList          1 : *zhanliListInfo
    }
}

snipe 78{
    request {
        snipeType           0 : integer
        playerid            1 : integer
    }

    response {
        type                1 : integer     # 0:success 1:error
        direninfo           2 : direninfo
        message             3 : string
        pkValue             4 : integer
        pkTimes             5 : integer
    }
}

]]

proto.s2c = sprotoparser.parse [[
.package {
    type 0 : integer
    session 1 : integer
}

heartbeat 1 {}

talk 2{
    request {
        type            0 : integer
        fromid          1 : integer
        fromname        2 : string
        toid            3 : integer
        toname          4 : string
        message         5 : string
        vipLv           6 : integer
        camp            7 : integer
        lv              8 : integer
    }
}

mailnotify 3{
    request {
        type 0 : integer
        num  1 : integer
    }
}

.taskProc{
    DailyPKCount              0 : integer
    killTimorCount            1 : integer
    killYingMoCount           2 : integer
    HeroMaxLevel              3 : integer
    HeroQuality               4 : integer
    PkWithDiCount             5 : integer
    PkWithMyCamp              6 : integer
    PkWithFamous              7 : integer
    PkWithStage               8 : integer
    HeroLevelCount            9 : integer
    HeroJinJieCount           10 : integer
    HeroSkillUpCount          11 : integer
    EquipBuyCount             12 : integer
    ExpBuyCount               13 : integer
    GoldBuyCount              14 : integer
    HeroXingUpCount           15 : integer
    dailyTalkCount            16 : integer
    saodangTimes              17 : integer
    wumianTimes               18 : integer
    momianTimes               19 : integer
    DailyEquipBuyCount        20 : integer
    DailyHeroSkillUpCount     21 : integer
    TianTiLadder              22 : integer
    DailySnipeCount           23 : integer
}

.stageInfo {
    chapter     0 : integer
    stageId     1 : integer
    max_proc    2 : integer
    dailyCount  3 : integer
    extraTime           4 : integer
    buyExtraTime        5 : integer
}

.equipinfo {
    id          0   : integer
    num          1   : integer
}

.iteminfo {
    id          0   : integer
    num         1   : integer
    level       2   : integer
}

.hunshiinfo {
    id          0   : integer
    num          1   : integer
}

fiveRefreshNotify 4{
    request {
        type          0 : integer
        RaidsTimes    1 : integer
        SkillTime     2 : integer
        SkillNum      3 : integer
        pkTimes       4 : integer
        pkTime        5 : integer
        taskProc      6 : taskProc
        luckyValue    7 : integer
        curDuanWei    8 : string
        pkValue       9 : integer
        playerStage  10 : *stageInfo
        myMaxRank       11 : string
        playerEquip     12 : *equipinfo
        playerItem      13 : *iteminfo
        playerHunshi    14 : *hunshiinfo
        exp             15   : integer
        exppool         16  : integer
        honor           17  : integer
        hasRaidsTimes      18 : integer
        challengeTimes           19 : integer
        refreshTianTiTime        20 : integer
    }
}

.playerinfo {
    id          0   : integer
    qufu        1   : string
    nickname    2   : string
    exp         3   : integer
    level       4   : integer
    camp        5   : integer   # 1:lol  2:dota
    gold        6   : integer
    diamond     7   : integer
    shenbing    8   : integer
    viplevel    9   : integer
    vipexp      10  : integer
    exppool     11  : integer
    card        12  :*integer
    luckyValue  13  : integer
    honor       14  : integer
    gongxian    15  : integer
    uid         16  : string
    monthcard         17  : integer  #月卡剩余发放次数
    highmonthcard     18  : integer  #高级月卡剩余发放次数
    alllife           19  : integer  #终生卡数量
    rechargetype      20  : string   #已存在的充值商品ID
    myMaxRank    21 : string
    lockEndTime  22 : integer
    talkOpenTime 23 : integer
    coinValue    24 : integer
    gameSession  25 : string
    meleeCoin    26 : integer
    pkCoin       27 : integer
    logicQufu    28 : string
    lastMonthcardTimes           29  : integer  #月卡剩余发放次数
    lastHighmonthcardTimes       30  : integer  #高级月卡剩余发放次数
    dailyBuySDCount              31  : integer
}

.storeItemInfo {
    showIndex               0   : integer    #显示顺序
    discountValue           1   : integer    #折扣值
    itemID                  2   : integer    #物品ID
    condition               3   : integer    #限制条件 0 无, 1 vip限制
    conditionValue          4   : integer    #限制条件的值
    status                  5   : integer    #销售状态 0 在售 1 售罄
}


.storeInfo {
    refreshTime          0   : *integer        #刷新时间
    storeItems           1   : *storeItemInfo  #在售商品信息列表
    shopSort             2   : integer         #显示顺序
    storeID              3   : string          #商场ID
}

autoRefreshStoreInfo 5{
    request {
        type                0 : integer   #0: 成功  1：失败
        storeInfo           1 : *storeInfo
        playerinfo          2 : playerinfo
        playerItem          3 : *iteminfo
    }
}

recharge 6{
    request {
        type                0 : integer   #0: 成功  1：失败
        info                1 : string
        playerinfo          2 : playerinfo
        num                 3 : integer
        hasRaidsTimes       4 : integer
        pkTimes             5 : integer
    }
}

closeArea 7{
    request {
        type                0 : integer   #0 服务器关闭 1被另外登录踢掉
    }
}

closeFunction 8{
    request {
        closeFuncTab        0 : *integer
    }
}

forbidLogin 9{
    request {
        lockEndTime        0 : integer
    }
}

notifyStatus 10{
    request {
        meleeStatus          0 : integer    # 1:预备   2:开放   3:结束
        time                 1 : integer
        serverTime           2 : integer
    }
}

notifyMeleeEndResult 11{
    request {
        status                 0 : string    # win   fail
        campKillNum            1 : integer
        campForce              2 : string
        playerKillNum          3 : integer
        playerLocalRank        4 : integer
        playerWorldRank        5 : integer
    }
}

]]


return proto
