//
//  PAUserListViewController.m
//  Demo
//
//  Created by 张乃淦 on 16/2/18.
//  Copyright © 2016年 pingan. All rights reserved.
//

#import "PAUserListViewController.h"
#import "utility.h"
#import <AVFoundation/AVFoundation.h>
#import <valley_rtc_sdk/ValleyRtcDef_OC.h>
#import <valley_rtc_sdk/ValleyRtcAPI_OC.h>

//需要显示耳返功能就放开这行注释
#define _ENABLE_ECHO

@interface PAUserListViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)UIButton *routeChangeButton;
@property (nonatomic, strong)UIButton *playButton;
@property (nonatomic, strong)UIButton *recordButton;
@property (nonatomic, strong)UIButton *debugButton;
@property (nonatomic, strong)UIButton *anchorButton;
@property (nonatomic, strong)UIButton *joinMicBtn;
@property (nonatomic,strong)UIButton *audienceButton;
@end

@interface UserEx : NSObject 
@property(nonnull) NSString* userid;
@property(atomic) bool isBlocked;
@property(atomic) bool isDispeaked;
@property() bool   isSpeaking;
@property()NSTimeInterval lastSpeakingTime;
@end
@implementation UserEx
@end

@implementation PAUserListViewController

NSMutableArray<UserEx*>* userList;
BOOL    playing;
BOOL    recording;
NSIndexPath* indexpath;
BOOL    bSpeakingStateChange;
NSTimer* timer;
bool enableMusicBtn;
IRtcChannel* channel;
IRtcUsers* rtcUsers;
IRtcAudio* rtcAudio;
IRtcAudioSystem* rtcSystem;
IRtcDeviceControler* rtcMusicCtrl;

-(void)Respond : (int)type ec:(int)ec ob:(nullable object_base*)ob
{
    switch (type)
    {
        case RespondKickOff:
        {
            object_userid* userid = (object_userid*)ob;
            [self UpdateUserList];
            //update userlist;
        }
        break;
        case RespondUserAttr:
        {
            //update user attr;
            object_user_attr* attr = (object_user_attr*)ob;
        }
        break;
        case RespondDisableUserSpeak:
        {
            //update user state;
            object_disable_speak* disSpeak = (object_disable_speak*)ob;
        }
        break;
        case RespondBlockUser:
        {
            object_block_speak* block = (object_block_speak*)block;
            //update block state;
        }
        break;
        default:
            break;
    }
}
-(void)Notify : (int)type ob : (nullable object_base*)ob
{
    switch (type)
    {
        case NotifyUserEnterChannel:      // object_user
        {
            object_user* user = (object_user*) ob;
            [self addUser:user ];
        }break;
        case NotifyUserLeaveChannel:
        {
            object_userid* userid = (object_userid*)ob;
            [self removeUser:[userid getUserID] ];
        }break;
        case NotifyKickOff:
        {
            object_userid* userid = (object_userid*)ob;
            [self removeUser:[userid getUserID] ];
        }break;
        case NotifyUserAttr:      // :
        {
            object_user_attr* user_attr = (object_user_attr*)ob;
           // update user.
        }
        break;
        case NotifyDisableUserSpeak:
        {
            object_disable_speak* dispeak = (object_disable_speak*) ob;
            //[self UpdateUserList ];
        }break;
        case NotifyUserSpeaking:
        {
            object_user_speaking* speaking = (object_user_speaking*)ob;
            NSString*uid = [speaking getUserID];
            for (UserEx* u in userList) {
                if( u.userid == uid )
                {
                    if(!u.isSpeaking)
                    {
                        bSpeakingStateChange = true;
                    }
                    u.isSpeaking = true;
                    u.lastSpeakingTime = [[NSDate date] timeIntervalSince1970]*1000;
                    return;
                }
            }
        }break;
        default:
            break;
    }
}

-(instancetype)initWithChannel:(nonnull IRtcChannel*)c EnableMusicBtn:(bool ) enable
{
    if (self = [super init]) {
        self.title = @"用户列表";
        playing = TRUE;
        recording = FALSE;
        bSpeakingStateChange = FALSE;
    }
    channel = c;
    enableMusicBtn = enable;
    rtcUsers = (IRtcUsers*)[channel GetInterface:RTC_USERS_ID];
    rtcAudio = (IRtcAudio*)[channel GetInterface:RTC_AUDIO_ID];
    rtcMusicCtrl = (IRtcDeviceControler*)[channel GetInterface:RTC_DEVICE_CONTROLER_ID]; 
    rtcSystem = (IRtcAudioSystem*)[channel GetInterface:RTC_AUDIOSYS_ID];
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.routeChangeButton];

    if(enableMusicBtn)
    {
        [self.view addSubview:self.audienceButton];
        [self.view addSubview:self.joinMicBtn];
        [self.view addSubview:self.anchorButton];
    }


#ifdef _DEBUG
    [self.view addSubview:self.debugButton];
#endif
    UIColor *color= [UIColor colorWithRed:0x72/255.0 green:0xd5/255.0 blue:0x72/255.0 alpha:1];
    [self.view setBackgroundColor:color];
        [self.tableView setBackgroundColor:color];
    
    [self loadData];
    timer = [ NSTimer  scheduledTimerWithTimeInterval: 0.5
     
                                       target: self
     
                                     selector: @selector ( onTimer: )
     
                                     userInfo:nil
     
                                      repeats: YES ];
        [self UpdateUserList];
    
    

    bool speaker =  [self isBuildInSpeakerActive];
    if(speaker)
    {
        [_routeChangeButton setTitle:@"扬声器" forState:UIControlStateNormal];
    }
    else
    {
        [_routeChangeButton setTitle:@"听筒" forState:UIControlStateNormal];
    }

    if(enableMusicBtn)
    {
        [self buttonClickEnableAudienceMode:_audienceButton];
    }
}


- (BOOL)isBuildInSpeakerActive{
    CFDictionaryRef currentRouteDescriptionDictionary = nil;
    UInt32 dataSize = sizeof(currentRouteDescriptionDictionary);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dataSize, &currentRouteDescriptionDictionary);
    if (currentRouteDescriptionDictionary) {
        CFArrayRef outputs = CFDictionaryGetValue(currentRouteDescriptionDictionary, kAudioSession_AudioRouteKey_Outputs);
        if(CFArrayGetCount(outputs) > 0) {
            CFDictionaryRef currentOutput = CFArrayGetValueAtIndex(outputs, 0);
            CFStringRef outputType = CFDictionaryGetValue(currentOutput, kAudioSession_AudioRouteKey_Type);
            return (CFStringCompare(outputType, kAudioSessionOutputRoute_BuiltInSpeaker, 0) == kCFCompareEqualTo);
        }
    }
    
    return NO;
}

- (void)loadData
{
    [self UpdateUserList];
}


 //页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated
{
    //开启定时器
   // [timer setFireDate:[NSDate distantPast]];
    if (timer == nil) {
        timer = [ NSTimer  scheduledTimerWithTimeInterval: 0.5
                 
                                                   target: self
                 
                                                 selector: @selector ( onTimer: )
                 
                                                 userInfo:nil
                 
                                                  repeats: YES ];
    }
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated
{
    //关闭定时器
   if(timer)
   {
       [timer invalidate];
       timer = nil;
   }

    //红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}
- (void) dealloc
{
    [channel Logout];
}


- (AVAudioSessionPortDescription*)bluetoothAudioDevice
{
    NSArray* bluetoothRoutes = @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP];
    return [self audioDeviceFromTypes:bluetoothRoutes];
}

- (AVAudioSessionPortDescription*)normalAudioDevice
{
    NSArray* bluetoothRoutes = @[AVAudioSessionPortBuiltInMic];
    return [self audioDeviceFromTypes:bluetoothRoutes];
}


- (AVAudioSessionPortDescription*)audioDeviceFromTypes:(NSArray*)types
{
    NSArray* routes = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription* route in routes)
    {
        if ([types containsObject:route.portType])
        {
            return route;
        }
    }
    return nil;
}

-(void) changeBluetoothInput:(bool)bluetoothInput{
    //if (true)
    {
        if(bluetoothInput){
            //[[AVAudioSession sharedInstance] setActive:NO error:nil];
            
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            AVAudioSessionPortDescription* _bluetoothPort = [self bluetoothAudioDevice];
            [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort
                                                         error:nil];
        }else{
            //[[AVAudioSession sharedInstance] setActive:NO error:nil];
            //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            AVAudioSessionPortDescription* _bluetoothPort = [self normalAudioDevice];
            [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort
                                                         error:nil];
        }
    }
}
-(void) onTimer:(NSTimer*)sender
{
    [self checkSpeaking];
}


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

-(void) addUser:(object_user*)obj
{
    NSString * uid = [obj getUserID];
    for (UserEx* u in userList) {
        if( u.userid == uid )
        {
            u.isBlocked = [obj getBlocked];
            u.isDispeaked = [obj getDisableSpeak];
            // 这里根据上层自定义的需要，去取attr属性值。
            return;
        }
    }
    UserEx* usertex = [UserEx new];
    usertex.userid = [obj getUserID];
    usertex.isBlocked = [obj getBlocked];
    usertex.isDispeaked = [obj getDisableSpeak];
    [userList addObject:usertex];
    [self UpdateUI];
}

-(void)UpdateUser:(object_user*) obj
{
    NSString * uid = [obj getUserID];
    for (UserEx* u in userList) {
        if( u.userid == uid )
        {
            u.isBlocked = [obj getBlocked];
            u.isDispeaked = [obj getDisableSpeak];
            // 这里根据上层自定义的需要，去取attr属性值。
            return;
        }
    }
    [self UpdateUI];
}

-(void)removeUser:(NSString*)uid
{
    for (UserEx* u in userList) {
        if( u.userid == uid )
        {
            [userList removeObject:u];
            break;
        }
    }
    [self UpdateUI];
}


-(void)UpdateUI
{
    [self.dataSource removeAllObjects];
    for (UserEx* userex in userList) {
        NSString*strValue = formatUserString(userex.userid,userex.isBlocked,userex.isDispeaked);
        [self.dataSource addObject:strValue];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void) checkSpeaking
{
    // 用局部刷新
    if (bSpeakingStateChange == FALSE) {
       
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970]*1000;//ms
        for(NSInteger i = 0; i < userList.count;i++){
            UserEx* user = userList[i];
            if (user.isSpeaking && (timestamp - user.lastSpeakingTime >= 400) )
            {
                user.isSpeaking = 0;
                bSpeakingStateChange = true;
                break;
            }
            else
            {
                continue;
            }
        }
    }

    
    if (bSpeakingStateChange ) {
        bSpeakingStateChange = FALSE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
    }
}


#pragma mark - UITableViewDataSource
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  self.dataSource.count;
}

// 设置每一行的内容，这是UI显示的重点，可以很好的锻炼iOS开发UI的能力
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    //如果缓存池没有到则重新创建并放到缓存池中
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
        UIColor *color= [UIColor colorWithRed:0x72/255.0 green:0xd5/255.0 blue:0x72/255.0 alpha:1];
        [cell setBackgroundColor:color];
    }
    UserEx *user = userList[indexPath.row];
    if ( user.userid.length > 50 ) {
        cell.textLabel.text = [user.userid substringToIndex:50];
    }
    else
        cell.textLabel.text = user.userid;
    
    if (user.isSpeaking) {
        CGSize size;
        size.height = 30;
        size.width = 30;
        UIImage*img = [UIImage imageNamed:@"open.png"];
        img = [self scaleToSize:img size:size];
        [cell.imageView setImage:img];
        
    }
    else{
        CGSize size;
        size.height = 30;
        size.width = 30;
        UIImage*img = [UIImage imageNamed:@"close.png"];
        img = [self scaleToSize:img size:size];
        [cell.imageView setImage:img];
    }
    cell.detailTextLabel.text = self.dataSource[indexPath.row];
    return cell;
}
         
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
}

         
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
         
#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}


#pragma mark 点击行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath == nil)
        return;
    
    
    
    indexpath = indexPath;
//    MessageBox(@"点击事件", [[NSString alloc] initWithFormat:@"点击了%li 组,%li 行",(long)indexPath.section,(long)indexPath.row]);
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
       
        self.tableView.frame = [[UIScreen mainScreen] bounds];
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    return _tableView;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)buttonClickChangeRoute:(UIButton *)sender{
    [self.view endEditing:YES];

    bool speakerphone = [rtcSystem GetSpeakerphoneOn];
    [rtcSystem SetSpeakerphoneOn:!speakerphone];
    //static bool speaker = false;
    bool speaker =  !speakerphone;//[self isBuildInSpeakerActive];
    //speaker = !speaker;
    UInt32 audioRouteOverride = speaker ? kAudioSessionOverrideAudioRoute_Speaker:kAudioSessionOverrideAudioRoute_None;
    
    int ec = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    if(ec == kAudioSessionUnsupportedPropertyError)
    {
        printf("不支持的值！\n");
    }
    else if ( ec == kAudioSessionNotInitialized)
    {
        printf("audio session 没有初始化\n");
    }
    else if ( ec != 0 )
    {
        printf("error code:%d\n",ec);
    }
    if (speaker)
    {
        [_routeChangeButton setTitle:@"扬声器" forState:UIControlStateNormal];
        
        int ec = [rtcMusicCtrl SetBackgroudMusic:0 filepath:@"123" loopflag:0 volume:1.0f bSendToNet:0 bPlayout:1];
        printf("SetBackgroudMusic code:%d\n",ec);
    }
    else
    {
        [_routeChangeButton setTitle:@"听筒" forState:UIControlStateNormal];
    }
}

- (void)buttonClickPlay:(UIButton *)sender{
    [self.view endEditing:YES];
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
    [self.view endEditing:YES];
    NSString *str= @"说话中";
    if(!recording){
        str = @"停止中";
    }
   // MessageBox(@"录音", str);
    recording = !recording;
    
    if (recording) {
        [_recordButton setTitle:@"说话中" forState:UIControlStateNormal];
    }else{
        [_recordButton setTitle:@"停止中" forState:UIControlStateNormal];
    }
    [rtcAudio EnableSpeak:recording];
}

-(void) buttonClickDebug:(UIButton *)sender{
    [self.view endEditing:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
          //  DebugViewController *userListPage = [[DebugViewController alloc] initWithRoom:nil  CfgTable:cfgTable LengthOfTable:sizeof(cfgTable)/sizeof(cfgTable[0]) ];
         //   [self.navigationController pushViewController:userListPage animated:YES];
        });
    });
}



-(void) buttonClickEnableAnchorMode:(UIButton *)sender{
    [self.view endEditing:YES];
    [_joinMicBtn setEnabled:true];
    [_anchorButton setEnabled:false];
    [_audienceButton setEnabled:true];
    [rtcMusicCtrl Enable:typeCtrlByHeadset enable:false];
    [rtcMusicCtrl Enable:typeNs|typeAec|typeVad|typeAgc enable:false];
}

-(void) buttonClickEnableJoinMicMode:(UIButton *)sender{
    [self.view endEditing:YES];
    if( !rtcMusicCtrl )
    {
        return;
    }
    
    [_joinMicBtn setEnabled:false];
    [_anchorButton setEnabled:true];
    [_audienceButton setEnabled:true];
    
    [rtcMusicCtrl Enable:typeCtrlByHeadset enable:true];
}

-(void)buttonClickEnableAudienceMode:(UIButton*)sender
{
    [self.view endEditing:YES];
    [_joinMicBtn setEnabled:true];
    [_anchorButton setEnabled:true];
    [_audienceButton setEnabled:false];
    [rtcMusicCtrl Enable:typeCtrlByHeadset enable:false];
    [rtcMusicCtrl Enable:typeNs|typeAec|typeVad|typeAgc enable:true];

}


-(UIButton *)routeChangeButton
{
    if (!_routeChangeButton) {
        _routeChangeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if([rtcSystem GetSpeakerphoneOn])
        {
            [_routeChangeButton setTitle:@"扬声器" forState:UIControlStateNormal];
        }
        else
        {
            [_routeChangeButton setTitle:@"听筒" forState:UIControlStateNormal];
        }

       [_routeChangeButton addTarget:self action:@selector(buttonClickChangeRoute:) forControlEvents:UIControlEventTouchUpInside];
        _routeChangeButton.frame = CGRectMake(kScreenWidth - 100,kScreenHeight-100,70,50);
        NSLog(@" the screen size is :%f,%f",kScreenHeight,kScreenWidth);
    }
    return _routeChangeButton;
}

-(UIButton *)playButton
{
    if (!_playButton)
    {
        _playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_playButton setTitle:@"播放中" forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(buttonClickPlay:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.frame = CGRectMake(80,kScreenHeight-100,70,50);
        NSLog(@" the screen size is :%f,%f",kScreenHeight,kScreenWidth);
    }
    return _playButton;
}

-(UIButton *)recordButton
{
    if (!_recordButton)
    {
        _recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_recordButton setTitle:@"停止中" forState:UIControlStateNormal];
        [_recordButton addTarget:self action:@selector(buttonClickRecord:) forControlEvents:UIControlEventTouchUpInside];
        _recordButton.frame = CGRectMake(180,kScreenHeight-100,70,50);
    }
    return _recordButton;
}

-(UIButton *)debugButton
{
    if (!_debugButton)
    {
        _debugButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_debugButton setTitle:@"调试" forState:UIControlStateNormal];
        [_debugButton addTarget:self action:@selector(buttonClickDebug:) forControlEvents:UIControlEventTouchUpInside];
        _debugButton.frame = CGRectMake(kScreenWidth-100,kScreenHeight-100,70,50);
    }
    return _debugButton;
}

-(UIButton *)audienceButton
{
    if (!_audienceButton)
    {
        _audienceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_audienceButton setTitle:@"观众模式" forState:UIControlStateNormal];
        [_audienceButton addTarget:self action:@selector(buttonClickEnableAudienceMode:) forControlEvents:UIControlEventTouchUpInside];
        _audienceButton.frame = CGRectMake(80,kScreenHeight-50,70,50);
    }
    return _audienceButton;
}

-(UIButton *)anchorButton
{
    if (!_anchorButton)
    {
        _anchorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_anchorButton setTitle:@"主播模式" forState:UIControlStateNormal];
        [_anchorButton addTarget:self action:@selector(buttonClickEnableAnchorMode:) forControlEvents:UIControlEventTouchUpInside];
        _anchorButton.frame = CGRectMake(180,kScreenHeight-50,70,50);
    }
    return _anchorButton;
}

-(UIButton *)joinMicBtn
{
    if (!_joinMicBtn)
    {
        _joinMicBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_joinMicBtn setTitle:@"主播连麦模式" forState:UIControlStateNormal];
        [_joinMicBtn addTarget:self action:@selector(buttonClickEnableJoinMicMode:) forControlEvents:UIControlEventTouchUpInside];
        _joinMicBtn.frame = CGRectMake(kScreenWidth - 100,kScreenHeight-50,100,50);
    }
    return _joinMicBtn;
}



@end











