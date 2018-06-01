#GuRen_Audio_Ios_Tutorial<br>
#real_audio-valley 为demo源码<br>
#SDK为SDK包<br>
官网地址：https://doc.valley.ren/
### DEMO运行指引
**1.环境准备**
-  一台iMac，安装好Xcode，必须能支持iOS SDK6.0以上的版本。其他编译器或者IDE需要自己配置项目工程或者脚本。
-  从官网下载页面获取iOS版本的压缩包，内含SDK和demo。
-  目前支持真机调试，暂不支持模拟器调试。

**2.导入项目**
解压工程，可以看到目录结构如下
![解压项目](https://doc.valley.ren/images/2017-11-20/5a127a6ab2508.png "解压项目")

用Xcode打开real_audio.xcodeproj，可以看到目录结构如下
![](https://doc.valley.ren/images/2017-11-20/5a127cc4e56b1.png)

**4.运行项目**
如果没有错误，可以看到登陆界面
![](https://doc.valley.ren/images/2017-11-20/5a1280ae84e88.jpg)

输入用户名和房间号，点击登陆即可。用户名任意，但不能是中文，且长度不能超过128字节。房间号在测试环境下只能输入1-50号房间，正式环境无限制。一个房间不能有两个同名ID。否则会踢掉之前登陆的用户。

如果登陆成功，会看到用户列表界面
![](https://doc.valley.ren/images/2017-11-20/5a12818740025.jpg)

上面显示房间里的所有用户，底部有两个按钮，可以控制说话和播放。点击左上角登陆界面按钮退出房间。

关于SDK如何集成到自己的项目里，请看下一节《SDK的获取和集成》。


### SDK获取及集成
**1.SDK概述**
SDK包含静态库
valley_rtc_sdk.framework
导出头文件有
- ValleyRtcAPI_OC.h
- ValleyRtcDef_OC.h
- ValleyRtcExtInterface_OC.h
- ValleyRtcAPI.h
- ValleyRtcDef.h
- ValleyRtcExtInterface.h

SDK提供了C++ 和Objective-C两种语言接口，其中以OC为后缀的是OC版本。目前没有提供swift版本。iOS文档只介绍OC的接口调用，如果要用C++， 请访问C++语言子目录的文档。
可以看到项目依赖系统库列表

**2.下载SDK**
请在官网的下载页面获取。

**3.引入到工程里**
将sdk直接拖动到项目里，然后添加相关系统依赖库
-  CoreTelephoney.framework
-  libiconv.tbd
-  libc++.1.tbd
-  libz.tbd

**4.权限管理**
需要添加麦克风权限，打开info.plist文件，添加Privacy - Microphone Usage Description 条目，描述里写“请求麦克风权限”或者自定义。
![](https://doc.valley.ren/images/2017-11-20/5a127e8b714d6.png)

**5.后台运行**
如果需要APP切换到后台依然可以说话和播放，则做如下设置
![](https://doc.valley.ren/images/2017-11-20/5a127e9e23046.png)

### 功能实现文档
**1.初始化SDK环境**
在调用其他API之前，需要先初始化SDK的工作环境，调用接口
ValleyRtcAPI类的静态成员函数
+ (void)InitSDK:(nonnull NSString*)appfolder;
参数appfolder必须具有读写权限，SDK用来存放配置信息和日志信息。
在整个SDK的使用生命周期内，只需要调用一次InitSDK函数，当app不再使用sdk或者退出程序，并且保证已经释放所有IRtcChannel对象时，请调用
+(void)CleanSDK;来清理资源

**2.创建房间。**
用户调用函数 +(nullable IRtcChannel*)CreateChannel; 来创建一个房间实例。
获得接口指针后先注册处理事件回调的接口和启用子模块功能。参考代码如下
```objective-c
-(void)CreateRoom
{
          NSString *documentsDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
#ifdef DEBUG
          SetLogLevel(LEVEL_DEBUG);//debug
#endif
    
          [ValleyRtcAPI InitSDK:documentsDirectory];//只需要调用一次，这里演示原因，没有判断多次调用。
          _channel = [ValleyRtcAPI CreateChannel];
         [_channel EnableInterface:RTC_USERS_ID];
         [_channel EnableInterface:RTC_AUDIO_ID];
         [_channel RegisterRtcSink:self];
         [_channel SetAuthoKey:authKey];//设置SDK授权码，测试环境请传空值。
}
```
EnableInterface函数用来启用子模块，RTC_USERS_ID表示用户列表功能，RTC_AUDIO_ID表示实时语音功能。建议开发者根据需求开启用户列表功能，要开启实时语音功能。

**3.登陆房间**
实例代码如下
```objective-c
[_channel Login:_roomKeyTextField.text userid:_uidTextField.text userinfo:nil];
```
第一个参数是房间号，测试环境下0-50，正式环境无限制，可以任意填写。第一个参数是用户名，任意填写。第三个参数可选，上层自定义信息。
调用Login函数后，应该定时调用Poll函数来轮询回调事件。时间周期由上层自定义，但为了及时处理事件，建议不超过1s。
当登陆成功后会收到一个事件号，上层需要处理此事件。参考代码如下
```objective-c
-(void)Respond : (int)type ec:(int)ec ob:(object_base*)ob
{
    switch (type)
    {
        case RespondLogin:
        {
            object_login* reslogin = (object_login*)ob;
            if (ec)
            {
                NSString*err=[NSString stringWithFormat:@"登陆房间失败，错误原因：%@",[ValleyRtcAPI GetErrDesc:ec]];
                MessageBox(@"警告", err);
                return;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                     PAUserListViewController* page    = [[PAUserListViewController alloc] initWithChannel:_channel ];// 要注册回调事件。
                    [self.navigationController pushViewController:page animated:YES];
                    _weakUserListController = page;
                });
            });
            break;
        }
        case RespondChannelAttr:
        {
            object_channel_attr* channel_attr = (object_channel_attr*)ob;
            NSString* attr = [NSString stringWithFormat:@"收到频道属性变化：%@:%@",[channel_attr getAttrName] ,[channel_attr getAttrValue]];
            NSLog(@"%@", attr);
        }break;
        default:
            if(_weakUserListController)
            {
                [_weakUserListController Respond:type ec:ec ob:ob];
            }
            break;
    }
}
```
这里只列出Respond类型的事件处理，Notify类型的事件由服务器端推送过来，也类似处理，请参考demo的相关处理。
如果登陆失败，上层可以重新调用登陆接口，如果是网络等原因，也可以选择放弃登陆。

**4.登出房间**
直接调用
[_channel Logout];
退出房间是立即返回，可以立即重新调用登陆操作。

**5.销毁房间**
[_channel Relase:true];
如果传false，则立即返回，不阻塞上层，sdk资源的释放异步执行，此刻应用程序应该保证不会立即退出进程，否则可能导致崩溃。

**6.相关操作**
登陆成功后可以处理用户列表和控制语音说话和播放。这些功能在文件里ValleyRtcExtInterface_OC.h提供。其中
IRtcUsers类处理用户相关事件,  rtcUsers = (IRtcUsers*)[channel GetInterface:RTC_USERS_ID];
IRtcAudio类处理实时语音相关事件。rtcAudio = (IRtcAudio*)[channel GetInterface:RTC_AUDIO_ID];
实例代码参考demo里的PAUserListViewController类。
获取用户列表的参考实现
```objective-c
-(void)UpdateUserList
{
    object_user_sheet* us = [object_user_sheet new];
    int ec = [rtcUsers GetUserList:(us)];
    if(ec == 0)
    {
        int size = [us size];
        userList = [[NSMutableArray alloc]init];
        for (int i = 0; i < size; i++)
        {
            object_user* user = [us item:i];
            if(!user)
            {
                continue;
            }
            UserEx* userex = [UserEx alloc];
            userex.userid = [user getUserID];
            userex.isDispeaked = [user getDisableSpeak];
            userex.isBlocked = [user getBlocked];
            [userList addObject:userex];

        }
        [self UpdateUI];
    }
}
```
控制说话和播放的参考实现
```objective-c
- (void)buttonClickPlay:(UIButton *)sender{
    NSString *str = @"播放中";
    if(playing){
        str = @"静音中";
    }

    playing = !playing;
    if (playing) {
        [_playButton setTitle:@"播放中" forState:UIControlStateNormal];
    }else{
        [_playButton setTitle:@"静音中" forState:UIControlStateNormal];
    }
    [rtcAudio EnablePlayout:playing];
}

- (void)buttonClickRecord:(UIButton *)sender{
    NSString *str= @"说话中";
    if(!recording){
        str = @"停止中";
    }
    recording = !recording;
    
    if (recording) {
        [_recordButton setTitle:@"说话中" forState:UIControlStateNormal];
    }else{
        [_recordButton setTitle:@"停止中" forState:UIControlStateNormal];
    }
    [rtcAudio EnableSpeak:recording];
}
```
