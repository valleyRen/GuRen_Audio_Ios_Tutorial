#pragma once
#include <stdint.h>
#define __VALLEYAPI extern "C"

#define ERR_SUCCEED 0         // 操作成功
#define ERR_NOT_LOGINED  -1   // 未登录成功       
#define ERR_ALREADY_RUN  -2   // 已经在运行   
#define ERR_USER_NOTFOUND -3  // 未找到用户   
#define ERR_EXCUTING -4		  // 正在执行中 
#define ERR_NOT_INITIALIZE -5 // 未初始化
#define ERR_UNSUPPORT -6      // 功能不支持
#define ERR_ARGUMENT  -7	  // 参数错误

#define ERR_CHANNEL_EXPIRED 1        // 频道已经失效
#define ERR_CONNECT_SERVER_FAILED 2  // 连接服务器失败
#define ERR_REQUEST_TIMEOUT 3  // 请求超时
#define ERR_CONFIG 4  // 配置信息错误 
#define ERR_NET_POOL 5  // 网络不好
#define ERR_VERSION_UNSUPPORTED 6  // 版本不支持
#define ERR_AUTHO_FAILED 7  // 授权失败 
#define ERR_NOT_ENOUGH_CHANNEL 8  // 频道资源不足
#define ERR_SERVER_ERROR 9  // 服务器错误
#define ERR_OPEN_RECORD 10  // 打开采集失败
#define ERR_OPEN_PLAYOUT 11  // 打开播放失败
#define ERR_RECORD_PERMISSION 12  // 没有录音权限

#define ERR_UNDEFINED 100  // 未定义错误

//登陆结果
#define RTC_CALLBACK_RESPONED_LOGIN          1
//设置频道属性结果
#define RTC_CALLBACK_RESPONED_CHANNEL_ATTR   2
//踢人结果
#define RTC_CALLBACK_RESPONED_KICK_OFF       3
//设置用户属性结果
#define RTC_CALLBACK_RESPONED_USER_ATTR      4
//拒听用户结果
#define RTC_CALLBACK_RESPONED_BLOCK_USER     5
//禁言用户结果
#define RTC_CALLBACK_RESPONED_DISABLE_SPEAK  6

//重复登陆被踢出频道通知
#define RTC_CALLBACK_NOTIFY_DUPLICATE_LOGINED         101
//频道关闭通知
#define RTC_CALLBACK_NOTIFY_CHANNEL_CLOSE             102
//网络不通
#define RTC_CALLBACK_NOTIFY_CONNECTION_LOST           103
//网络重新连接
#define RTC_CALLBACK_NOTIFY_RECONNECTED               104
//用户属性变化通知
#define RTC_CALLBACK_NOTIFY_CHANNEL_ATTR              105
//新用户进入频道通知
#define RTC_CALLBACK_NOTIFY_USER_ENTER_CHANNEL        106
//用户离开频道通知
#define RTC_CALLBACK_NOTIFY_USER_LEAVE_CHANNEL        107
//有用户被踢出频道
#define RTC_CALLBACK_NOTIFY_KICK_OFF                  108
//用户属性变化通知
#define RTC_CALLBACK_NOTIFY_USER_ATTR                 109
//用户被禁言通知
#define RTC_CALLBACK_NOTIFY_USER_DISABLE_SPEAK        110
//用户正在讲话通知
#define RTC_CALLBACK_NOTIFY_USER_SPEAKING             111

//结构体的成员全部使用确定大小的类型,防止不同平台不同语言有不同的解释。
#pragma pack(1)

struct RtcObjectBase
{
#define RTC_OBJECT_BASE 0
    int32_t type;       //具体的派生类类型，因为C语言不支持继承，这里标识下。上层不需要关心
};

// 登陆返回结果
struct RtcObjectLogin
{
#define RTC_OBJECT_LOGIN  1
    RtcObjectBase base;
    const char* channelid;
    const char* userid;
    const char* userinfo;
};

//频道属性
struct RtcObjectChannelAttr
{
#define RTC_OBJECT_CHANNEL_ATTR 2
    RtcObjectBase base;
    const char* name;
    const char* value;
};

//用户id
struct RtcObjectUserID
{
#define RTC_OBJECT_USER_ID 3
    RtcObjectBase base;
    const char* userid;
};

//用户属性，attr值需要调用Valley_GettUserAttr获取
struct RtcObjectUserAttr
{
#define RTC_OBJECT_USER_ATTR 4
    RtcObjectBase base;
    const char* userid;
    const char* name;
    const char* value;
};

// 拒听某用户的结果或者通知
struct RtcObjectBlockUser
{
#define RTC_OBJECT_BLOCK_USER 5
    RtcObjectBase base;
    const char*   userid;
    int32_t       isblock;
};

//禁言某人发言结果或者通知
struct RtcObjectDisableSpeak
{
#define RTC_OBJECT_DISABLE_SPEAK 6
    RtcObjectBase base;
    const char*   userid;
    int32_t       disable;
};

//错误码
struct RtcObjectError
{
#define RTC_OBJECT_ERROR 7
    RtcObjectBase base;
    int32_t error_code;
};

//用户对象
struct RtcObjectUser
{
#define RTC_OBJECT_USER 8
    RtcObjectBase base;
    const char* userid;
    const char* userinfo;
    int32_t     isblock;
    int32_t     disablespeak;
};

//用户对象列表
struct RtcObjectUserList
{
#define RTC_OBJECT_USER_LIST 9
    RtcObjectBase base;
    RtcObjectUser*user_item;
    int32_t       user_count;
};

//用户正在说话通知
struct RtcObjectUserSpeaking
{
#define RTC_OBJECT_USER_SPEAKING 10
    RtcObjectBase base;
    const char*   userid;
    int32_t       volume;
};

// 通用字符串
struct RtcObjectString
{
#define RTC_OBJECT_STRING   11
    RtcObjectBase base;
    const char* string;
};
#pragma pack()

//异步事件回调接口
typedef void( *LPRTCEVENTCALLBACK )( int type, int ec, struct RtcObjectBase *base, void* userdata );

//全局函数

/**
* @brief     安卓平台调用，初始化安卓
* @return    __VALLEYAPI void
* @param     void * AppilcationCtx: 安卓的application context 对象。
*/
__VALLEYAPI void					Valley_InitAndroid( void* AppilcationCtx );

/**
* @brief     初始化SDK，只需要调用一次
* @return    __VALLEYAPI void
* @param     const char * appfolder：可读写的文件路径
*/
__VALLEYAPI void					Valley_InitSDK( const char* appfolder );
/**
* @brief     清理SDK资源，与Valley_InitSDK成对出现。
* @return    __VALLEYAPI void
*/
__VALLEYAPI void					Valley_CleanSDK();
/**
* @brief     设置授权码
* @return    __VALLEYAPI void
* @param     const char * authokey
*/
__VALLEYAPI void					Valley_SetAuthoKey( const char* authokey );
/**
* @brief     错误码描述
* @return    __VALLEYAPI const char*
* @param     int ec
*/
__VALLEYAPI const char*			    Valley_GetErrDesc( int ec );
/**
* @brief     SDK版本
* @return    __VALLEYAPI const char*
*/
__VALLEYAPI const char*			    Valley_GetSDKVersion();

//频道主体逻辑
/**
* @brief     创建一个频道
* @return    __VALLEYAPI void*
*/
__VALLEYAPI void*                  Valley_CreateChannel();
/**
* @brief     注册异步事件回调函数
* @return    __VALLEYAPI void
* @param     void * state Valley_CreateChannel 返回值，下同。
* @param     LPRTCEVENTCALLBACK cb 回调函数，不可为空
* @param     bool use_poll 是否由上层驱动事件，主动来取，为true则需要上层不断调用Poll函数，推荐传true。
* @param     void * userdata 上层自定义数据
*/
__VALLEYAPI void                   Valley_RegisterRtcSink( void* state, LPRTCEVENTCALLBACK cb, bool use_poll,void* userdata );
/**
* @brief     激活模块
* @return    __VALLEYAPI int 参见错误码。
* @param     void * state
* @param     int id 1表示用户相关的接口，2表示实时语音操作相关的接口
*/
__VALLEYAPI int                    Valley_EnableInterface( void* state, int id );
/**
* @brief     登陆频道，异步操作。
* @return    __VALLEYAPI int
* @param     void * state
* @param     const char * channelid，任意值，不可为空。
* @param     const char * userid，任意值，不可为空。
* @param     const char * userinfo，自定义
*/
__VALLEYAPI int                    Valley_Login( void* state, const char* channelid, const char* userid, const char* userinfo );
/**
* @brief     退出频道
* @return    __VALLEYAPI void
* @param     void * state
*/
__VALLEYAPI void                   Valley_Logout( void* state );

/**
* @brief     获取登陆状态
* @return    __VALLEYAPI int
             STATUS_NONE = 0, //未登录
             STATUS_LOGINING = 1,//正在登录
             STATUS_LOGINED  = 2,//已经登陆
* @param     void * state
*/
__VALLEYAPI int                    Valley_GetLoginStatus( void* state );
/**
* @brief     上层自定义设置频道属性，键值对。
* @return    __VALLEYAPI int
* @param     void * state
* @param     const char * name 任意值，不可为空。
* @param     const char * value 任意值，为空则清除该键值对。
*/
__VALLEYAPI int                    Valley_SetChannelAttr( void* state, const char* name, const char* value );
/**
* @brief     获取频道属性，键值对
* @return    __VALLEYAPI int
* @param     void * state
* @param     const char * name 任意值
* @param     RtcObjectString * value 用完需要调用Valley_ReleaseRtcObject释放内存
*/
__VALLEYAPI int                    Valley_GetChannelAttr( void* state, const char* name, RtcObjectString* value );
/**
* @brief     删除频道
* @return    __VALLEYAPI void
* @param     void * state
* @param     bool sync 为true，则同步等待频道释放完毕；否则立即返回，在后台线程释放。推荐传true。
*/
__VALLEYAPI void                   Valley_Release( void* state, bool sync );
/**
* @brief     定时查询异步事件，推荐不大于200ms调用一次。调用这个必须与注册函数的use_poll=true配合。
* @return    __VALLEYAPI void
* @param     void * state
*/
__VALLEYAPI void                   Valley_Poll( void* state );

////用户列表控制接口
/**
* @brief     获取频道用户数
* @return    __VALLEYAPI int 人数
* @param     void * state
*/
__VALLEYAPI int  Valley_GetUserCount( void* state );
/**
* @brief     获取频道用户列表
* @return    __VALLEYAPI int 错误码
* @param     void * state
* @param     RtcObjectUserList * user_list 用户列表，使用完必须调用Valley_ReleaseRtcObject 释放内存
*/
__VALLEYAPI int  Valley_GetUserList( void* state, RtcObjectUserList* user_list );
/**
* @brief     获取用户
* @return    __VALLEYAPI int
* @param     void * state
* @param     const char * uid 用户id
* @param     RtcObjectUser * user 使用完必须调用Valley_ReleaseRtcObject 释放内存
*/
__VALLEYAPI int  Valley_GetUser( void* state, const char* uid, RtcObjectUser* user );
/**
* @brief     把用户踢出房间
* @return    __VALLEYAPI int
* @param     void * state
* @param     const char * uid 用户id
*/
__VALLEYAPI int  Valley_KickOff( void* state, const char* uid );
/**
* @brief     设置用户属性，键值对
* @return    __VALLEYAPI int
* @param     void * state
* @param     const char * uid 用户id
* @param     const char * name 键，任意值，不可为空
* @param     const char * value 值，任意值，如果为空，则清除此条键值对
*/
__VALLEYAPI int  Valley_SetUserAttr( void* state,const char* uid, const char* name, const char* value );
/**
* @brief     获取用户属性，键值对
* @return    __VALLEYAPI int
* @param     void * state
* @param     const char * uid 用户id
* @param     const char * name 键 任意值，不可为空
* @param     RtcObjectString * value 值，使用完必须调用Valley_ReleaseRtcObject 释放内存
*/
__VALLEYAPI int  Valley_GettUserAttr( void* state, const char* uid, const char* name, RtcObjectString* value );


////实时语音控制逻辑接口
/**
* @brief     拒听用户发言
* @return    __VALLEYAPI int 参见错误码
* @param     void * state
* @param     const char * uid 用户id
* @param     bool block 是否拒听
*/
__VALLEYAPI int   Valley_BlockUser( void* state,const char* uid, bool block );
/**
* @brief     禁止用户发言
* @return    __VALLEYAPI int 错误码
* @param     void * state
* @param     const char * uid 用户id
* @param     bool disspeak 禁言
*/
__VALLEYAPI int   Valley_DisableUserSpeak( void* state, const char* uid, bool disspeak );
/**
* @brief     是否要讲话
* @return    __VALLEYAPI void
* @param     void * state
* @param     bool enable
*/
__VALLEYAPI int  Valley_EnableSpeak( void* state, bool enable );
/**
* @brief     查询是否打开讲话
* @return    __VALLEYAPI bool
* @param     void * state
*/
__VALLEYAPI bool  Valley_GetSpeakEnabled( void* state );
/**
* @brief     播放
* @return    __VALLEYAPI void
* @param     void * state
* @param     bool enable
*/
__VALLEYAPI void  Valley_EnablePlayout( void* state, bool enable );

/**
* @brief     是否打开播放
* @return    __VALLEYAPI bool
* @param     void * state
*/
__VALLEYAPI bool  Valley_GetPlayoutEnabled( void* state );
/**
* @brief     设置播放音量
* @return    __VALLEYAPI int
* @param     void * state
* @param     int volume 有效值[0-100]
*/
__VALLEYAPI int   Valley_SetPlayoutVolume( void* state, int volume );
/**
* @brief     打开耳机模式
* @return    __VALLEYAPI void
* @param     void * state
* @param     bool enable
*/
__VALLEYAPI void  Valley_SetSpeakerphoneOn( void* state, bool enable );
/**
* @brief     是否打开耳机
* @return    __VALLEYAPI bool
* @param     void * state
*/
__VALLEYAPI bool  Valley_GetSpeakerphoneOn( void* state );

/**
* @brief     释放内存
* @return    __VALLEYAPI void
* @param     RtcObjectBase * obj
*/
__VALLEYAPI void  Valley_ReleaseRtcObject( RtcObjectBase* obj );
