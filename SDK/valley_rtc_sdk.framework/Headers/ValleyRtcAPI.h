#ifndef _VALLEYRTCAPI_H
#define _VALLEYRTCAPI_H

#include "ValleyRtcDef.h"

namespace Valley
{    
	class IRtcSink
	{ 
	public: 
		virtual void Respond(int type, int ec, object_base* ob, void* userdata) = 0;
		virtual void Notify(int type, object_base* ob, void* userdata) = 0;
	};

	 
	class IRtcChannel
	{ 
	public: 
		enum
		{ 
			RespondLogin       = 1,		     // object_login 
			RespondChannelAttr = 2,			 // object_channel_attr
		};

		enum eNotifyType
		{
			NotifyConnectionLost   = 1,       // null
			NotifyReConnected      = 2,       // null
			NotifyDuplicateLogined = 3,       // null  
			NotifyChannelClose     = 4,       // object_error   
			NotifyChannelAttr      = 5,       // object_channel_attr
		};
	public:
		virtual ~IRtcChannel(){}
		virtual void            RegisterRtcSink(IRtcSink* sink, bool usePoll, void* userdata = NULL) = 0;
		virtual int             EnableInterface(int iids) = 0; 
		virtual int             DisableInterface(int iid) = 0;
		virtual IExtInterface*  GetInterface(int iid) = 0;
		virtual int             Login(const char* channelid, const char* userid, const char* userinfo=NULL) = 0;
		virtual void            Logout() = 0;
		virtual int             GetLoginStatus() = 0;  
		virtual int             SetChannelAttr(const char* name, const char* value) = 0;
		virtual int             GetChannelAttr(const char* name, string_ptr& value) = 0; 
		virtual void            Release(bool sync) = 0;
		virtual void            Poll() = 0;
		virtual void            Pause(bool bPause) = 0; 
	};  
};
 

__RTCAPI void					InitAndroid(void* AppilcationCtx);
__RTCAPI void					InitSDK(const char* appfolder);
__RTCAPI void					CleanSDK();
__RTCAPI void					SetAuthoKey(const char* authokey);
__RTCAPI const char*			GetErrDesc(int ec);
__RTCAPI const char*			GetSDKVersion();
__RTCAPI Valley::IRtcChannel*   CreateChannel(); 


#endif//_VALLEYRTCAPI_H
