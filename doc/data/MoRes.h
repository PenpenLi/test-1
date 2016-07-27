#ifndef MORES_H_
#define MORES_H_

#include "MoConfig.h"

#define BEASTTABLE_DSC_MAXNUM		128
#define BEASTTABLE_M_RES_MAXNUM		64

#define BOSSTABLE_DSC_MAXNUM		128
#define BOSSTABLE_B_RES_MAXNUM		64

#define CHECKPOINTTABLE_CHAPTER_T_MAXNUM		128
#define CHECKPOINTTABLE_CHAPTER_NAME_MAXNUM		128
#define CHECKPOINTTABLE_SECTION_NAME_MAXNUM		128
#define CHECKPOINTTABLE_CHAPTER_DSC_MAXNUM		128
#define CHECKPOINTTABLE_ITEM_ID_MAXNUM		3
#define CHECKPOINTTABLE_ITEM_LV_MAXNUM		3

#define ITEM_NAME_MAXNUM		64
#define ITEM_ITEMSRC_MAXNUM		64
#define ITEM_ITEM_RES_MAXNUM		64
#define ITEM_ITEMLAYERPATH_MAXNUM		32

enum EItemType{
	eitem_jinyandan		=	0,
	eitem_shuaxinjuan		=	1,
	eitem_PKitem		=	2,
	eitem_lound		=	3,
	eitem_gift		=	4,
	eitem_choujiangka		=	5,
	eitem_zhibaoshengji		=	6,
	eitem_zhibaojinjie		=	7,
	eitem_huanqianzawu		=	8,
	ITEMTYPE_FourByte	=0x7FFFFFFF
};

enum EQuality{
	eNoColor		=	0,
	eWhiteQuality		=	1,
	eGreenQuality		=	2,
	eBlueQuality		=	3,
	ePurpleQuality		=	4,
	eOrangeQuality		=	5,
	eGoldQuality		=	6,
	eDarkGoldQuality		=	7,
	eSevenColorQuality		=	8,
	QUALITY_FourByte	=0x7FFFFFFF
};

#pragma pack (1)

struct BeastTableRes{
	uint32				 m_uiID;
	uint32				 m_uib_blood;
	uint32				 m_uib_speed;
	uint32				 m_uiclothes;
	char				 m_acdsc[BEASTTABLE_DSC_MAXNUM];
	char				 m_acm_res[BEASTTABLE_M_RES_MAXNUM];
};


struct BossTableRes{
	uint32				 m_uiID;
	uint32				 m_uib_blood;
	uint32				 m_uib_speed;
	uint32				 m_uiclothes;
	uint32				 m_uiaccessories;
	char				 m_acdsc[BOSSTABLE_DSC_MAXNUM];
	char				 m_acb_res[BOSSTABLE_B_RES_MAXNUM];
};


struct CheckpointTableRes{
	uint32				 m_uiID;
	uint32				 m_uichapter;
	char				 m_acchapter_t[CHECKPOINTTABLE_CHAPTER_T_MAXNUM];
	uint32				 m_uisection;
	char				 m_acchapter_name[CHECKPOINTTABLE_CHAPTER_NAME_MAXNUM];
	char				 m_acsection_name[CHECKPOINTTABLE_SECTION_NAME_MAXNUM];
	char				 m_acchapter_dsc[CHECKPOINTTABLE_CHAPTER_DSC_MAXNUM];
	uint32				 m_uiM01_ID;
	uint32				 m_uiM01_num;
	float				 m_fM01_time;
	float				 m_fM01_b_add;
	float				 m_fM01_s_add;
	uint32				 m_uiM02_ID;
	uint32				 m_uiM02_num;
	uint32				 m_uiM02_time;
	float				 m_fM02_b_add;
	float				 m_fM02_s_add;
	uint32				 m_uiM03_ID;
	uint32				 m_uiM03_num;
	uint32				 m_uiM03_time;
	uint32				 m_uiB01_ID;
	uint32				 m_uiB01_time;
	float				 m_fB01_b_add;
	float				 m_fB01_s_add;
	uint32				 m_uiNextID;
	uint32				 m_uiitem_ID[CHECKPOINTTABLE_ITEM_ID_MAXNUM];
	float				 m_fitem_lv[CHECKPOINTTABLE_ITEM_LV_MAXNUM];
};


struct ItemRes{
	uint32				 m_uiID;
	char				 m_acName[ITEM_NAME_MAXNUM];
	char				 m_acitemsrc[ITEM_ITEMSRC_MAXNUM];
	uint32				 m_uieq_count;
	uint32				 m_uieq_groupcount;
	float				 m_fitem_jinbi;
	float				 m_fitem_zuanshi;
	EItemType			m_eItemType;
	uint32				 m_uieq_rate;
	EQuality			m_eQuality;
	float				 m_fitemNum;
	uint32				 m_uiGiftID;
	char				 m_acitem_res[ITEM_ITEM_RES_MAXNUM];
	char				 m_acItemLayerPath[ITEM_ITEMLAYERPATH_MAXNUM];
};


#pragma pack ()

#endif