#ifndef _ValleyRtcDef_OC
#define _ValleyRtcDef_OC
  

#import <Foundation/Foundation.h>

@interface object_base:NSObject
@end

@interface IExtInterface : NSObject
@end

@interface object_string:object_base
- (nullable NSString*)c_str;
@end


@interface object_error:object_base
-(int)getErrorCode; 
@end


@interface object_login:object_base
- (nonnull NSString*) getUserID;
-(nonnull NSString*) getChannelID;
-(nullable NSString*)getUserInfo;
@end


@interface object_userid:object_base
- (nonnull  NSString*) getUserID;
@end


@interface object_user:object_base
- (nonnull  NSString*) getUserID;
-(nullable NSString*)getUserInfo;
-(bool)getDisableSpeak;
-(bool)getBlocked;
-(nonnull NSString*)getAttr:(nonnull NSString*)name;
@end


@interface object_user_sheet:object_base
-(nullable object_user*)item:(int)index;
-(int)size;
@end

  
@interface object_disable_speak:object_base
- (nonnull NSString*) getUserID;
-(bool)getDisabled;
@end

 

@interface object_block_speak:object_base
- (nonnull NSString*) getUserID;
-(bool)getBlocked;
@end
 

@interface object_user_speaking:object_base
- (nonnull NSString*) getUserID;
-(int)getVolume;
@end


@interface object_user_attr:object_base
-(nonnull NSString*)getUserID;
-(nonnull NSString*)getAttrName;
-(nullable NSString*)getAttrValue;
@end


@interface object_channel_attr:object_base
- (nonnull NSString*)getAttrName;
-(nullable NSString*)getAttrValue;
@end
 
 
#endif//_ValleyRtcDef_OC
