#ifndef _VALLEYRTCAPIEXT_H
#define _VALLEYRTCAPIEXT_H

#include "ValleyRtcDef.h"
#include "ValleyRtcAPI.h"

namespace Valley
{    
	class IRtcSinkEx : public IRtcSink
	{
	public:
		enum eStemType
		{ 
			steam_before_send = 0x02,
			steam_playout = 0x04,
		};
	public:
		virtual void OnTransAudioStream(eStemType stype, void* pcm, int len, int channel, int samplerate, const void* userdata){}
		virtual void OnTransUserAudioStream(void* pcm, int len, int channel, int samplerate, const char* uid, const void* userdata){}
	};

	class IRtcUsers : public IExtInterface
	{
	public:
		enum{ IID = 0x01 };
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

	public:
		virtual int  GetUserCount() = 0;
		virtual int  GetUserList(user_sheet_ptr& userlist) = 0;
		virtual int  GetUser(const char* uid, user_ptr& user) = 0;
		virtual int  KickOff(const char* uid) = 0;
		virtual int  SetUserAttr(const char* uid, const char* name, const char* value) = 0;
		virtual int  GettUserAttr(const char* uid, const char* name, string_ptr& value) = 0;
	};
 
	class IRtcAudio : public IExtInterface
	{ 
	public:
		enum{ IID = 0x02 };
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
	public:  
		virtual int   BlockUser(const char* uid, bool block) = 0;
		virtual int   DisableUserSpeak(const char* uid, bool disspeak) = 0;
		virtual int   EnableSpeak(bool enable) = 0;
		virtual bool  GetSpeakEnabled() = 0;
		virtual void  EnablePlayout(bool enable) = 0;
		virtual bool  GetPlayoutEnabled() = 0;
	}; 

	class IRtcAudioSystem : public IExtInterface
	{
	public:
		enum{ IID = 0x04 }; 
		virtual int   SetPlayoutVolume(int volume) = 0;
		virtual int   GetPlayoutVolume(int& volume) = 0;
		virtual void  SetSpeakerphoneOn(bool bOn) = 0;
		virtual bool  GetSpeakerphoneOn() = 0;

		/*
		 * GetDeviceList 枚举系统音频采集或播放设备 
		 * 采集设备： 默认为AUTO 表示系统将自动检测输入设备，第一个检测到声音信号的作为采集设备
		 * 播放设备： 默认为DEFAULT表示系统默认设备
		 */
		virtual int  GetDeviceList(bool bRecord, string_sheet_ptr& arr) = 0;   
		virtual int  GetCurrentDevice(bool bRecord, string_ptr& deviceName) = 0; //获取当前语音采集或播放的设备， AUTO为自适应
		virtual int  SetCurrentDevice(bool bRecord, const char* deviceName) = 0; //指定当前语音采集或播放的设备，DEFAULT为系统默认
	}; 


	class IRtcDeviceControler : public IExtInterface
	{  
	public: 
		enum{ IID = 0x08 };  
		enum{ //typeCtrlByHeadset = 0x01,  //受耳机插拔控制(插上耳机，无回声，那么高音质，否则讲话模式)
			  typeAec = 0x04,    //回声抑制控制
			  typeNs = 0x08,     //噪声抑制控制
			  typeAgc = 0x010,   //自动增益控制
			  typeVad = 0x020,   //静音检测控制 
			  typeEcho = 0x40,   //而返控制

			  typeMusicMode         = 0x1000, // 音乐房间控制接口，必须调用typeMusicMode设置为音乐房间才有效
			  typeHookRecord        = 0x2000, // HookCapture  PushRecordAudioFrame 有效
			  typeHookPlayout       = 0x4000, // HookPlayout  GetPlayoutAudioFrame 有效
			  typeBackgroundMusic   = 0x8000, // 支持背景音乐  PushBackgroudAudioFrame 有效 
		};

		virtual int  Enable(int types, bool enable) = 0;
		virtual bool IsEnabled(int type) = 0;  

 		virtual int  GetPlayoutAudioFrame(char* pcm, int len, int& samprate, int& channel) = 0; //获取当前拦截到的播放声音
		virtual int  PushRecordAudioFrame(char* pcm, int len, int samprate, int channel) = 0;   //发送采集到的声音 hookCaptre=true有效
		   
		//发送背景音乐  trackindex 音轨标识，必须0~500
		virtual int  PushBackgroudAudioFrame(int trackindex, char* pcm, int len, int samprate, int channel, float scale = 1.0f, bool bSendToNet = false, bool bPlayout = false) = 0; 

		virtual int  EnalbleStreamTransCallback(bool bEnable, const void* userdata = nullptr) = 0;  //此接口必须在登录前调用，OnTransAudioStream 将裸数据传出来，用户可以实现本地录音，修改数据有等
		virtual int  EnalbleUserStreamTransCallback(bool bEnable, const void* userdata = nullptr) = 0; //此接口必须在登录前调用，OnTransUserAudioStream 将收到的每个人的语音裸数据传出来
	}; 
}; 
 

#endif//_VALLEYRTCAPIEXT_H 
