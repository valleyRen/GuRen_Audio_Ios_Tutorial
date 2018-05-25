#ifndef _ValleyRtcExtInterface_OC
#define _ValleyRtcExtInterface_OC

#include "ValleyRtcDef_OC.h"


@interface IRtcUsers:IExtInterface
	enum{ RTC_USERS_ID = 0x01 };
	enum
	{  
		RespondKickOff        = 101,	   // object_userid 
		RespondUserAttr       = 102,	   // object_user_attr
	};

	enum
	{ 
		NotifyUserEnterChannel = 101,      // object_user
		NotifyUserLeaveChannel = 102,      // object_userid  
		NotifyKickOff          = 103,      // object_userid 
		NotifyUserAttr         = 104,      // object_user_attr
	};  
	-(int)GetUserCount;
	-(int)GetUserList : (nonnull object_user_sheet*)usersheet;
	-(int)GetUser : (nonnull NSString*)uid user : (nonnull object_user*)user;
	-(int)KickOff : (nonnull NSString*)uid;
	-(int)SetUserAttr : (nonnull NSString*)uid name : (nonnull NSString*)name value:(NSString*)value;
	-(int)GettUserAttr : (nonnull NSString*)uid name : (nonnull NSString*)name value : (nonnull object_string*)value;
 @end

@interface IRtcAudio:IExtInterface
	enum{RTC_AUDIO_ID = 0x02};
	enum
	{ 
		RespondDisableUserSpeak    = 201, // object_disable_speak
		RespondBlockUser           = 202, // object_block_speak
	};
	enum
	{ 
		NotifyDisableUserSpeak     = 201,   // object_disable_speak  
		NotifyUserSpeaking         = 202,   // object_user_speaking 
	};   

	-(int)BlockUser : (nonnull NSString*)uid block : (bool)block;
	-(int)DisableUserSpeak : (nonnull NSString*)uid block : (bool)block;
	-(int)EnableSpeak : (bool)enable;
	-(bool)GetSpeakEnabled;
	-(int)EnablePlayout : (bool)enable;
	-(bool)GetPlayoutEnabled; 
@end 


@interface IRtcAudioSystem:IExtInterface
enum{ RTC_AUDIOSYS_ID = 0x04 };  
-(void)SetPlayoutVolume : (int)volume;
-(int)GetPlayoutVolume;
-(void)SetSpeakerphoneOn : (bool)bOn;
-(bool)GetSpeakerphoneOn;
@end




@interface IRtcDeviceControler :IExtInterface
enum{ RTC_DEVICE_CONTROLER_ID = 0x08 };
enum{
	typeCtrlByHeadset = 0x01,  //�ܶ�����ο���(���϶������޻�������ô�����ʣ����򽲻�ģʽ)
	typeAec = 0x04,    //�������ƿ���
	typeNs = 0x08,     //�������ƿ���
	typeAgc = 0x010,   //�Զ��������
	typeVad = 0x020,   //���������� 
	typeEcho = 0x40,   //��������

	typeMusicMode = 0x1000, // ���ַ���, Ĭ�Ͼ������ַ���
	typeBackgroundMusic = 0x8000, // ֧�ֱ�������  PushBackgroudAudioFrame ��Ч 
};

enum{
	stream_audio = 0x01,
	stream_video = 0x02,
};

-(int)Enable:(int)type enable:(bool)enable;
-(bool)IsEnabled : (int)type; 
-(int)SetBackgroudMusic:(int)trackIndex filepath:(nonnull NSString*)filepath loopflag : (bool)loopflag volume : (float)volume bSendToNet : (bool)bSendToNet bPlayout : (bool)bPlayout;
-(void)SetBackgroudMusicVolume:(int)trackIndex volume:(float)volume;/*volume 0.0 ~ 1.0f*/
 
-(int)StartRtmp:(nonnull NSString*)url sreamtypes : (int)sreamtypes bUseServer : (bool)bUseServer;
-(void)StopRtmp;

/*stream_audio*/
-(int)StartRecord:(int)sreamtypes;
- (void)StopRecord;
-(void)PauseRecord:(bool)bPause;

@end

 

#endif//_ValleyRtcExtInterface_OC
