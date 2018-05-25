 
#ifndef _ValleyRtcAPI_OC_H
#define _ValleyRtcAPI_OC_H

#import <Foundation/Foundation.h> 
#import "ValleyRtcExtInterface_OC.h"
#import "ValleyRtcDef_OC.h"
@protocol IRtcSink
-(void)Respond : (int)type ec:(int)ec ob:(nullable object_base*)ob;
-(void)Notify : (int)type ob : (nullable object_base*)ob;
@end 
 
@interface IRtcChannel : NSObject
	enum
	{
		RespondLogin = 1,		     // object_login 
		RespondChannelAttr = 2,		 // object_channel_attr
	};

	enum eNotifyType
	{
		NotifyConnectionLost = 1,    // null
		NotifyReConnected = 2,       // null
		NotifyDuplicateLogined = 3,  // null  
		NotifyChannelClose = 4,      // object_error   
		NotifyChannelAttr = 5,       // object_channel_attr
	}; 

	-(void)RegisterRtcSink : (id<IRtcSink>)sink;
	-(int)EnableInterface:(int)iids;
	-(int)DisableInterface:(int)iid;
	-(IExtInterface*)GetInterface:(int)iid;
	-(int)Login:(nonnull NSString*)channelid userid:(nonnull NSString*)userid userinfo:(nullable NSString*)userinfo;
	-(void)Logout;
	-(int)GetLoginStatus;
	-(int)SetChannelAttr:(nonnull NSString*)name value:(nullable NSString*)value;
	-(int)GetChannelAttr:(nonnull NSString*)name value:(nonnull object_string*)value; 
    -(void)Poll;
	-(void)Pause:(bool)bPause;
	-(void)Release:(bool)syn;
	@end


@interface ValleyRtcAPI:NSObject
+ (void)InitSDK:(nonnull NSString*)appfolder;
+(void)SetAuthoKey:(nonnull NSString*)authokey;
+(void)CleanSDK;
+(nullable NSString*)GetErrDesc:(int)ec;
+(nonnull NSString*)GetSDKVersion;
+(nullable IRtcChannel*)CreateChannel;
@end

#endif // _ValleyRtcAPI_OC_H
 