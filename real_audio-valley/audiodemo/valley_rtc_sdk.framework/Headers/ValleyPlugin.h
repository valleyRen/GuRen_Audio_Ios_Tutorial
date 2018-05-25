#ifndef _VALLEY_PLUGIN_INTERFACE_H
#define _VALLEY_PLUGIN_INTERFACE_H
 

namespace Valley
{ 
	typedef unsigned long  ulong_t;
	class IRtcChannel;
	class IRtcDeviceControler;

	namespace Plugin
	{ 
		#define TRACKINDEX_ALL -1 

		enum 
		{
			ECODE_SUCCEED = 0,
			PLUG_ERR_FROM = 1000,
			ECODE_OPENFILE_FAILED = PLUG_ERR_FROM+1,
			ECODE_UNSUPPORT_FORMAT = PLUG_ERR_FROM + 2,
			ECODE_PARAMS_ERROR = PLUG_ERR_FROM + 3,
		}; 


		enum eType
		{
			typeAudioPlayer = 0,
			typeAudioDemo = 1,
			typeRoomControler = 5,
		};

		enum 
		{
			NotifyPlayAudioData = 1000,       // object_audio_data 
			NotifyPlayAudioEnd = 1001,       // nullptr 
		};

		struct object_base
		{
		public:
			virtual ~object_base(){}
		};

		struct object_audio_data : public object_base
		{
			char*       pcm;
			int         dlen;
			int         channel;
			int         samprate;
			ulong_t     timeEscaped;
			ulong_t     fileTime;
		};

		struct ICallback
		{  
			virtual void OnPluginNotify(int ntftype, object_base* obj, const void* userdata) {};
		};

		class IBase
		{
		public:
			virtual ~IBase(){}
			virtual void Release(){}
		};

		class IAudioPlayer : public IBase
		{ 
		public:
			virtual void SetCallback(ICallback* pCallback, const void* userdata) = 0;
			virtual int  PlayFile(const char* filename, bool loopflag) = 0;
			virtual void Stop() = 0;
			virtual void Pause(bool bPause) = 0;
			virtual int  SetVolume(float sc) = 0;
			virtual int  SetPlayTime(ulong_t timePosition) = 0;
			virtual int  GetPlayedTime(ulong_t& timePosition) = 0;
			virtual int  GetFileTime(ulong_t& timeSpan) = 0;
		}; 


		class IAudioPlayerDemo : public IBase
		{ 
		public:
			//trackIndex 音轨标识 目前支持 [0~4]
			virtual int  Play(int trackIndex, IRtcDeviceControler* pRtcDeviceControler, const char* filename, bool loopflag, float scVolume, bool bSendToNet, bool bPlayToDevice) = 0;
			virtual void Stop(int trackIndex) = 0;
			virtual void SetVolume(int trackIndex, float sc) = 0;
			virtual int  SetPlayTime(int trackIndex, ulong_t timePosition) = 0;
			virtual int  GetPlayedTime(int trackIndex, ulong_t& timePosition) = 0;
			virtual int  GetFileTime(int trackIndex, ulong_t& timeSpan) = 0;
			virtual int  GetPlayEndCount(int trackIndex) = 0;
			virtual void Pause(int trackIndex, bool bPause) = 0;
		};


		class IRoomControler : public IBase
		{
		public:
			enum streamtype
			{
				stream_audio = 0x01,
				stream_video = 0x02,
			};
		public:
			virtual int  Init(IRtcChannel* pRtcChannel) = 0;
			virtual int  StartRtmp(const char* url, int stypes = stream_audio, bool bUseServer = false) = 0;
			virtual void StopRtmp() = 0;
			virtual void PauseRtmp(bool bPause) = 0;
			virtual int  StartRecord(int stypes = stream_audio) = 0;
			virtual void StopRecord() = 0;
			virtual void PauseRecord(bool bPause) = 0;
		};
	}

	Plugin::IBase* CreatePlugin(Plugin::eType type);
};
 

#endif//_VALLEY_PLUGIN_INTERFACE_H 
 