#ifndef MORES_H_
#define MORES_H_

#include "MoConfig.h"

#define BEASTTABLE_DSC_MAXNUM		128
#define BEASTTABLE_M_RES_MAXNUM		64
#define BEASTTABLE_M_SHIPEI_MAXNUM		64

#define BOSSTABLE_DSC_MAXNUM		128
#define BOSSTABLE_B_RES_MAXNUM		64
#define BOSSTABLE_B_SHIPEI_MAXNUM		64

#define CHECKPOINTTABLE_CHAPTER_T_MAXNUM		128
#define CHECKPOINTTABLE_CHAPTER_NAME_MAXNUM		128
#define CHECKPOINTTABLE_SECTION_NAME_MAXNUM		128
#define CHECKPOINTTABLE_CHAPTER_DSC_MAXNUM		128
#define CHECKPOINTTABLE_ITEM_ID_MAXNUM		3
#define CHECKPOINTTABLE_ITEM_LV_MAXNUM		3
#define CHECKPOINTTABLE_C_RES_MAXNUM		64

#define FLOWERTABLE_NAME_MAXNUM		64
#define FLOWERTABLE_ITEMSRC_MAXNUM		64
#define FLOWERTABLE_F_RES_MAXNUM		64

#define ITEMTABLE_NAME_MAXNUM		64
#define ITEMTABLE_ITEMSRC_MAXNUM		64
#define ITEMTABLE_ITEM_RES_MAXNUM		64
#define ITEMTABLE_ITEMLAYERPATH_MAXNUM		32

enum EFType{
	ef_jinyandan		=	0,
	ef_shuaxinjuan		=	1,
	ef_PKitem		=	2,
	ef_lound		=	3,
	ef_gift		=	4,
	ef_choujiangka		=	5,
	ef_zhibaoshengji		=	6,
	ef_zhibaojinjie		=	7,
	ef_huanqianzawu		=	8,
	FTYPE_FourByte	=0x7FFFFFFF
};

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
	char				 m_acm_shipei[BEASTTABLE_M_SHIPEI_MAXNUM];
};


struct BossTableRes{
	uint32				 m_uiID;
	uint32				 m_uib_blood;
	uint32				 m_uib_speed;
	uint32				 m_uiclothes;
	uint32				 m_uiaccessories;
	char				 m_acdsc[BOSSTABLE_DSC_MAXNUM];
	char				 m_acb_res[BOSSTABLE_B_RES_MAXNUM];
	char				 m_acb_shipei[BOSSTABLE_B_SHIPEI_MAXNUM];
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
	char				 m_acc_res[CHECKPOINTTABLE_C_RES_MAXNUM];
};


struct FlowerTableRes{
	uint32				 m_uiID;
	char				 m_acName[FLOWERTABLE_NAME_MAXNUM];
	char				 m_acitemsrc[FLOWERTABLE_ITEMSRC_MAXNUM];
	uint32				 m_uif_count;
	uint32				 m_uif_groupcount;
	float				 m_ff_jinbi;
	float				 m_ff_zuanshi;
	EFType			m_eFType;
	uint32				 m_uif_rate;
	EQuality			m_eQuality;
	float				 m_ff_time01;
	float				 m_ff_time02;
	float				 m_ff_time03;
	uint32				 m_uiGiftID;
	char				 m_acf_res[FLOWERTABLE_F_RES_MAXNUM];
};


struct ItemTableRes{
	uint32				 m_uiID;
	char				 m_acName[ITEMTABLE_NAME_MAXNUM];
	char				 m_acitemsrc[ITEMTABLE_ITEMSRC_MAXNUM];
	uint32				 m_uieq_count;
	uint32				 m_uieq_groupcount;
	float				 m_fitem_jinbi;
	float				 m_fitem_zuanshi;
	EItemType			m_eItemType;
	uint32				 m_uieq_rate;
	EQuality			m_eQuality;
	float				 m_fitemNum;
	uint32				 m_uiGiftID;
	char				 m_acitem_res[ITEMTABLE_ITEM_RES_MAXNUM];
	char				 m_acItemLayerPath[ITEMTABLE_ITEMLAYERPATH_MAXNUM];
};


#pragma pack ()

#endif