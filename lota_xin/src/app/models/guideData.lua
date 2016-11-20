local GuideData = {
    
    [10001] = {
        scene = nil,
        btnId = 50001,
        nextId = 10002,
        talk = {1110454324},
        isHand = 0
    },

    [10002] = {
        scene = nil,
        btnId = 50002,
        nextId = 10005,
        talk = {1093677105}
    },

    [10003] = {
        scene = nil,
        btnId = 50103,
        nextId = 10005,
        talk = {1093677107}
    },

    [10004] = {
        scene = nil,
        btnId = 50103,
        nextId = 80005,
        height = 500,
        f = -1
    },

    [80005] = {
        scene = nil,
        btnId = 50103,
        nextId = 80006,
        height = 200,
        scale = 0.9,
        f = -2 -- 往上翻
    },

    [80006] = {
        scene = nil,
        btnId = 50103,
        nextId = 80007,
        height = 200,
        scale = 0.9,
        f = -2 -- 往上翻
    },

    [80007] = {
        scene = nil,
        btnId = 50103,
        nextId = 80008,
        height = 500,
        scale = 0.9,
        f = -2 -- 往上翻
    },

    [80008] = {
        scene = nil,
        btnId = 50103,
        nextId = 80009,
        height = 500,
        scale = 0.9,
        f = -2 -- 往上翻
    },






  --   [10005] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10006,
		-- talk = {1127231537},--点击“按钮”打开任务面板
  --       height = 200,
  --       scale = 0.9,
		-- f = -2 -- 往上翻
  --   },

  --   [10006] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10007,
  --       talk = {1093677109}, -- 点击立刻领取丰厚的任务奖励
  --       height = 400
  --   },

  --   [10007] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10008,
		-- talk = {1127231539}, -- 点击“确定”关闭界面
  --       height = 200
  --   },

  --   [10008] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10009,
  --       talk = {1093677110},--任务给了不少经验池经验，去升级英雄把
  --       height = 200,
  --       scale = 0.9,
  --       f = -2 -- 往上翻
  --   },

  --   [10009] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10010,
  --       talk = {1093677111},--点击目标英雄开查看英雄的详细属性
  --       height = 400
  --   },

  --   [10010] = {          
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10011,
  --       talk = {1093677112},--经验池可以提升英雄等级，帐号等级提升增加经验池累积上限
  --       height = 400
  --   },

  --   [10011] = {             --升级按钮（建议加提示）
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10012,
  --       talk = {1110454321},--提升英雄等级至满级（满级）
  --       height = 500
  --   },

  --   [10012] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10013,
		-- talk = {1127231537},--点击“按钮”打开任务面板
  --       height = 200,
  --       scale = 0.9,
		-- f = -2 -- 往上翻
  --   },

  --   [10013] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10014,
		-- talk = {1127231538},--点击“光亮处”领取任务将领
  --       height = 200
  --   },

  --   [10014] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10015,
		-- talk = {1127231539},--点击“确定”关闭界面
  --       height = 200
  --   },

  --   [10015] = {    --关闭按钮
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10016,
		-- talk = {1127231543},--点击“X”回到主界面，说不定有惊喜
  --       height = 200,
  --       f = -1
  --   },

  --   [10016] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10017,
  --       talk = {1093677360},--不管是否在线，都可以获得挂机战斗场次，厉害吧
  --       height = 200
  --   },

  --   [10017] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10018,
  --       talk = {1093677361},--挂机掉了好多钱和装备$_$
  --       height = 200
  --   },

  --   [10018] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10019,
		-- talk = {1127231542},--点击“确定”关闭界面$_$
  --       height = 200
  --   },

  --   [10019] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10020,
		-- talk = {1127231544},--英雄可以通过穿戴装备提升能力$_$
  --       height = 200,
  --       scale = 0.9,
		-- f = -2 -- 往上翻
  --   },

  --   [10020] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10021,
		-- talk = {1127231545},--绿色“+”号说明可以穿装备啦
  --       height = 200
  --   },

  --   [10021] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10022,
		-- talk = {1127231792},--点击穿戴装备
  --       height = 200
  --   },

  --   [10022] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 19001,
		-- talk = {1127231793},--点击“装备”按钮确定穿戴该装备
  --       height = 200
  --   },

  --   [19001] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10023,
  --       talk = {1110454325},--满级（25级）+满6件装备=进阶
  --       height = 200
  --   },

  --   [19010] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 19011,
  --       height = 200,
  --   },

  --   [19011] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10023,
  --       height = 200,
  --   },

  --   [10023] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10024,
  --       talk = {1093677366},--装备满了，英雄等级满了，那个闪闪发光的按钮是什么
  --       height = 200
  --   },

  --   [10024] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15001,
  --       talk = {1093677367},--进阶后等级回退至1级，可以再次被提示至25级和穿戴更高级的装备
  --       height = 200
  --   },


  --   --晋级赛引导

  --   [15001] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15002,
  --       talk = {1144008753},
  --       height = 400
  --   },

  --   [15002] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15003,
  --       talk = {1144008754},
  --       height = 400
  --   },

  --   [15003] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15004,
  --       talk = {1144008755},
  --       height = 400
  --   },

  --   [15004] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15005,
  --       talk = {1144008756},
  --       height = 200
  --   },

  --   [15005] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15006,
  --       talk = {1144008757},
  --       height = 400
  --   },

  --   [15006] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15007,
  --       talk = {1144008758},
  --       height = 400
  --   },

  --   [15007] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 15008,
  --       talk = {1144008760},
  --       height = 200
  --   },




    [10025] = {
        scene = nil,
        btnId = 50103,
        nextId = 10026,
		talk = {1127231540},
        height = 200
    },

    [10026] = {
        scene = nil,
        btnId = 50103,
        nextId = 10027,
		talk = {1127231541},
        height = 100,
        scale = 1.2
    },

    [10027] = {
        scene = nil,
        btnId = 50103,
        nextId = 10028,
		talk = {1127231798},--点击“确定”关闭界面
        height = 200
    },

    [10028] = {
        scene = nil,
        btnId = 50103,
        nextId = 10029,
        talk = {1093677368},--任务领取了魂石，魂石是什么，赶紧去看看
        height = 250,
        scale = 0.9
    },

    [10029] = {
        scene = nil,
        btnId = 50103,
        nextId = 10030,
        talk = {1127232048},--cool,原来是召唤小弟的！感觉棒棒哒，赶紧拉出来一起战斗
        height = 200
    },

    [10030] = {
        scene = nil,
        btnId = 50103,
        nextId = 19030,
		talk = {1127231801},--cool,点击  召唤  可以获得新的英雄伙伴---------------		
        height = 200
    },

    [19030] = {
        scene = nil,
        btnId = 50103,
        nextId = 10031,
		talk = {1127231798},--cool,抽到了英雄，貌似运气不错呢，感觉去上阵殴打小怪兽了
        height = 200
    },

    [10031] = {
        scene = nil,
        btnId = 50103,
        nextId = 10032,
        height = 200,
        f = -1
    },

    [10032] = {
        scene = nil,
        btnId = 50103,
        nextId = 10033,
		talk = {1127232048},--拿到新伙伴时，记得上阵呦！（点击我方战场）
        height = 200
    },

    [10033] = {
        scene = nil,
        btnId = 50103,
        nextId = 10034,
        talk = {1110454322},--（点击我方战场）
        height = 200
    },

    [10034] = {
        scene = nil,
        btnId = 50103,
        nextId = 10035,
        talk = {1093677616},--点击头像来选择要上阵的英雄
        height = 400
    },

    [10035] = {
        scene = nil,
        btnId = 50103,
        nextId = 10036,
        talk = {1093677617},--点击上阵英雄可以使之下阵，最多同时上阵5个英雄
        height = 180
    },

    [10036] = {
        scene = nil,
        btnId = 50103,
        nextId = 10037,
        talk = {1093677618},--开战才算真的上阵拉
        height = 400
    },



    --晋级赛引导
    [15051] = {
        scene = nil,
        btnId = 50103,
        nextId = 15052,
        talk = {1144008761},
        height = 400
    },

    [15052] = {
        scene = nil,
        btnId = 50103,
        nextId = 15053,
        talk = {1144009008},
        height = 400
    },

    [15053] = {
        scene = nil,
        btnId = 50103,
        nextId = 15054,
        talk = {1144009008},
        height = 400
    },

    [15054] = {
        scene = nil,
        btnId = 50105,
        nextId = 15055,
        talk = {1144009009},
        height = 400
    },

    -- [15054] = {
    --     scene = nil,
    --     btnId = 50103,
    --     nextId = 15054,
    --     talk = {1144009010},
    --     height = 200
    -- },

    -- [15054] = {
    --     scene = nil,
    --     btnId = 50103,
    --     nextId = 15055,
    --     talk = {1144009011},
    --     height = 200
    -- },






    [10037] = {
        scene = nil,
        btnId = 50103,
        nextId = 10038,
        talk = {1093677619},--当你缺少资源的时候，请用“金手指”，手速越快，资源越多
        height = 50
    },

    [10038] = {
        scene = nil,
        btnId = 50103,
        nextId = 10039,
		talk = {1127231799},--点击确定开始使用金手指
        height = 200
    },

    [10039] = {
        scene = nil,
        btnId = 50103,
        nextId = 10040,
        talk = {1093677620},--每次金手指有5秒时间，点击次数越多，奖励越多哦
        height = 200
    },

    [10040] = {
        scene = nil,
        btnId = 50103,
        nextId = 10041,
		talk = {1127231800},--点击敌方阵地，可以快速击杀敌人，获取大量收益
        height = 200
    },

    [10041] = {
        scene = nil,
        btnId = 50103,
        nextId = 10042,
        height = 200
    },

    -- [10042] = {
    --     scene = nil,
    --     btnId = 50103,
    --     nextId = 10043,
    --     height = 200
    -- },

    -- [10043] = {
    --     scene = nil,
    --     btnId = 50103,
    --     nextId = 10044,
    --     height = 200
    -- },

    -- [10044] = {
    --     scene = nil,
    --     btnId = 50103,
    --     nextId = 10045,
    --     height = 200
    -- },



  --   --商城引导
  --   [10101] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10102,
  --       talk = {1479553073},--商城开放啦！快来买买买
  --       height = 200
  --   },

  --   [10102] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10103,
  --       talk = {1479553074},--这里出售所有的装备和稀有的魂石
  --       height = 200
  --   },

  --   [10103] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10104,
  --       talk = {1479553075},--每购买一件商品，都会获得幸运值，幸运值越高，折扣越大！（每日清空）
  --       height = 400
  --   },

  --   [10104] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10105,
  --       talk = {1479553076},--商城商品每2小时刷新，记得经常来看哦！
  --       height = 400
  --   },


  --   --掠夺引导
  --   [10201] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10202,
  --       talk = {1479553077},--掠夺正式开放咯！
  --       height = 200,
  --       scale = 0.9
  --   },

  --   [10202] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10203,
  --       talk = {1479553078},--掠夺会获得临时的战力提升（每日清空）
  --       height = 200,
  --   },

  --   [10203] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10204,
  --       talk = {1479553079},--上阵英雄
  --       height = 400,
  --   },

  --   [10204] = {
  --       scene = nil,
  --       btnId = 50105,
  --       nextId = 10205,
  --       talk = {1479553081},--开始战斗吧！
  --       height = 400,
  --   },

  --   [10205] = {
  --       scene = nil,
  --       btnId = 50105,
  --       nextId = 10206,
  --       talk = {1479553328},--掠夺马上开始，不要着急
  --       height = 400,
  --   },


  --   --掠夺引导
  --   [10301] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10302,
  --       talk = {1479553584},--死斗正式开放，热血战斗一触即发
  --       height = 200,
  --       scale = 0.9
  --   },

  --   [10302] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10303,
  --       talk = {1479553585},--死斗各种明星战队，赢得大宝箱
  --       height = 200,
  --   },

  --   [10303] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10304,
  --       talk = {1479553586},--死斗可以获得各种稀有的装备和魂石
  --       height = 200,
  --   },

  --   [10304] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10305,
  --       talk = {1479553587},--每天可以挑战5次死斗，选择自己能战胜的对手哟
  --       height = 400,
  --   },

  --   [10305] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10306,
  --       talk = {1479553588},--开始挑战吧
  --       height = 400,
  --   },

  --   [10306] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10307,
  --       talk = {1479553589},--上阵最强的英雄组合吧
  --       height = 400,
  --   },

  --   [10307] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10308,
  --       talk = {1479553590},--进入热血的死斗吧
  --       height = 400,
  --   },

  --   [10308] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10309,
  --       talk = {1479553591},--死斗马上开始，不要着急
  --       height = 400,
  --   },

  --   --关卡引导
  --   [10401] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10402,
  --       talk = {1479553840},--烧脑的关卡正式开放
  --       height = 200,
  --       scale = 0.9
  --   },

  --   [10402] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10403,
  --       talk = {1479553841},--每个关卡有自己的主题
  --       height = 200,
  --   },

  --   [10403] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10404,
  --       talk = {1479553842},--挑战胜利可获得稀有魂石
  --       height = 200,
  --   },

  --   [10404] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10405,
  --       talk = {1479553843},--每个类型的关卡每天可挑战5次，选择合适自己的对手
  --       height = 400,
  --   },

  --   [10405] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10406,
  --       talk = {1479553844},--赶紧挑战试一下吧
  --       height = 400,
  --   },

  --   [10406] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10407,
  --       talk = {1479553845},--选择合适的英雄上阵
  --       height = 400,
  --   },

  --   [10407] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10408,
  --       talk = {1479553846},--开战吧
  --       height = 400,
  --   },

  --   [10408] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10409,
  --       talk = {1479553847},--关卡马上开始，不要着急
  --       height = 400,
  --   },

  --   --至宝引导
  --   [10501] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10502,
  --       talk = {1479553848},
  --       height = 200,
  --       scale = 0.9
  --   },

  --   [10502] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10503,
  --       talk = {1479553849},
  --       height = 200,
  --       scale = 1
  --   },

  --   [10503] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10504,
  --       talk = {1479554096},
  --       height = 300,
  --       scale = 1
  --   },

  --   [10504] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10505,
  --       talk = {1479554097},
  --       height = 200,
  --       scale = 1
  --   },

  --   [10505] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10506,
  --       talk = {1479554098},
  --       height = 200,
  --       scale = 1
  --   },

  --   [10506] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10507,
  --       talk = {1479554099},
  --       height = 200,
  --       scale = 1
  --   },


  --   --挑战引导
  --   [10601] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10602,
  --       talk = {1479554100},
  --       height = 200,
  --       scale = 0.9
  --   },

  --   [10602] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10603,
  --       talk = {1479554101},
  --       height = 200,
  --   },

  --   [10603] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10604,
  --       talk = {1479554102},
  --       height = 200,
  --   },

  --   [10604] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10605,
  --       talk = {1479554103},
  --       height = 400,
  --   },

  --   [10605] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10606,
  --       talk = {1479554104},
  --       height = 400,
  --   },

  --   [10606] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10607,
  --       talk = {1479554105},
  --       height = 400,
  --   },

  --   [10607] = {
  --       scene = nil,
  --       btnId = 50103,
  --       nextId = 10608,
  --       talk = {1479554352},
  --       height = 400,
  --   },



      --竞技场引导
    [10701] = {
        scene = nil,
        btnId = 50103,
        nextId = 10702,
        height = 200,
        scale = 0.9
    },

    [10702] = {
        scene = nil,
        btnId = 50103,
        nextId = 10703,
        height = 200,
        scale = 0.9
    },

}

return GuideData