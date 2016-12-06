#ifndef MORES_H_
#define MORES_H_

#include "MoConfig.h"

#define BOSSTABLE_NAME_MAXNUM		128
#define BOSSTABLE_SRC_MAXNUM		64

#define EQUIPTABLE_NAME_MAXNUM		128
#define EQUIPTABLE_DESC_MAXNUM		512
#define EQUIPTABLE_ICONSRC_MAXNUM		64

#define SPEEDTABLE_ATTACK05_MAXNUM		32


#define MATERIALTABLE_NAME_MAXNUM		128
#define MATERIALTABLE_DESC_MAXNUM		512
#define MATERIALTABLE_ICONSRC_MAXNUM		64

#define PETTABLE_NAME_MAXNUM		128
#define PETTABLE_PET_DESC_MAXNUM		512
#define PETTABLE_QUALITY_MAXNUM		5
#define PETTABLE_SRC_MAXNUM		64
#define PETTABLE_HEADSRC_MAXNUM		64

#pragma pack (1)

struct bossTableRes{
	uint32				 m_uiID;
	char				 m_acName[BOSSTABLE_NAME_MAXNUM];
	int32				 m_iblood;
	char				 m_acSrc[BOSSTABLE_SRC_MAXNUM];
};


struct equipTableRes{
	int32				 m_iID;
	char				 m_acName[EQUIPTABLE_NAME_MAXNUM];
	char				 m_acDesc[EQUIPTABLE_DESC_MAXNUM];
	uint32				 m_uiType;
	uint32				 m_uiquality;
	char				 m_aciconSrc[EQUIPTABLE_ICONSRC_MAXNUM];
};


struct speedTableRes{
	int32				 m_iLV;
	int32				 m_iAttack01;
	int32				 m_iAttack02;
	int32				 m_iAttack03;
	int32				 m_iAttack04;
	int32				 m_iAttack05[SPEEDTABLE_ATTACK05_MAXNUM];
	int32				 m_iAttack06;
	int32				 m_iAttack07;
	int32				 m_iAttack08;
	int32				 m_iAttack09;
	int32				 m_iAttack10;
	int32				 m_iCrit01;
	int32				 m_iCrit02;
	int32				 m_iCrit03;
	int32				 m_iCrit04;
	int32				 m_iCrit05;
	int32				 m_iCrit06;
	int32				 m_iCrit07;
	int32				 m_iCrit08;
	int32				 m_iCrit09;
	int32				 m_iCrit10;
	int32				 m_iSpeed01;
	int32				 m_iSpeed02;
	int32				 m_iSpeed03;
	int32				 m_iSpeed04;
	int32				 m_iSpeed05;
	int32				 m_iSpeed06;
	int32				 m_iSpeed07;
	int32				 m_iSpeed08;
	int32				 m_iSpeed09;
	int32				 m_iSpeed10;
};


struct goldTableRes{
	int32				 m_iID;
	int32				 m_iPlayerUpLv;
	int32				 m_iPlayerUpSkill;
	int32				 m_iPetUpLv;
	int32				 m_iPetUpSkill;
};


struct materialTableRes{
	int32				 m_iID;
	char				 m_acName[MATERIALTABLE_NAME_MAXNUM];
	char				 m_acDesc[MATERIALTABLE_DESC_MAXNUM];
	int32				 m_iquality;
	char				 m_aciconSrc[MATERIALTABLE_ICONSRC_MAXNUM];
};


struct petTableRes{
	int32				 m_iID;
	char				 m_acName[PETTABLE_NAME_MAXNUM];
	char				 m_acPet_Desc[PETTABLE_PET_DESC_MAXNUM];
	int32				 m_iquality[PETTABLE_QUALITY_MAXNUM];
	char				 m_acSrc[PETTABLE_SRC_MAXNUM];
	char				 m_acheadSrc[PETTABLE_HEADSRC_MAXNUM];
	int32				 m_imaterialID;
	uint32				 m_uicallNum;
	uint32				 m_uipromotionNum;
};


#pragma pack ()

#endif