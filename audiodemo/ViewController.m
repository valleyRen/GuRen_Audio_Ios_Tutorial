//
//  ViewController.m
//  Demo
//
//  Created by 张乃淦 on 16/2/18.
//  Copyright © 2016年 pingan. All rights reserved.
//

#import "ViewController.h"
#import "PAUserListViewController.h"
#import "utility.h"
#import <AVFoundation/AVFoundation.h>
#include "valley_rtc_sdk/ValleyRtcAPI_OC.h"
#include "valley_rtc_sdk/ValleyRtcExtInterface_OC.h"
#include <valley_rtc_sdk/ValleyRtcDef_OC.h>
//宏定义获取屏幕的宽度
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width


@interface ViewController ()
@property (nonatomic,strong) UILabel*     uidLabel;
@property (nonatomic,strong) UILabel*     roomKeyLabel;
@property (nonatomic,strong) UITextField* uidTextField;
@property (nonatomic,strong) UITextField* roomKeyTextField;
@property (nonatomic,strong) UIButton*    loginButton;
@property (nonatomic,strong) UILabel*     version;
@property (nullable)__weak PAUserListViewController* weakUserListController;
@property (nullable) IRtcChannel* channel;
@end

@implementation ViewController
{
    NSTimer* timer;
    bool enableMusicBtn;
}


////新接口
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
                    PAUserListViewController* page    = [[PAUserListViewController alloc] initWithChannel:_channel EnableMusicBtn:enableMusicBtn ];// 要注册回调事件。
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
-(void)Notify : (int)type ob:(object_base*)ob
{
    switch (type) {
        case NotifyConnectionLost:
        {
            NSLog(@"网络断开...\n");
        }break;
        case NotifyReConnected:       // null
        {
            NSLog(@"网络重新连接上...\n");
        }break;
        case NotifyDuplicateLogined:
        {
            NSLog(@"当前帐号其他地方登陆\n");
            [_channel Logout];
        }break;// null
        case NotifyChannelClose:
        {
            object_error* err = (object_error*)ob;
            NSLog(@"房间关闭：%d\n", [err getErrorCode]);
            [_channel Logout];
        }break;
        case  NotifyChannelAttr:
        {
            object_channel_attr* channel_attr = (object_channel_attr*)ob;
            NSString* attr = [NSString stringWithFormat:@"收到频道属性变化：%@:%@",[channel_attr getAttrName] ,[channel_attr getAttrValue]];
            NSLog(@"%@", attr);
        }
        break;
        default:
            [_weakUserListController Notify:type ob:ob];
            break;
    }
}

///新接口
//界面即将出现设置视图位置
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setViewsLayerout];
}


- (void)viewDidLoad {
    _weakUserListController = nil;
    _channel = nil;
    [super viewDidLoad];
    self.title = @"登陆界面";
    [self.view addSubview:self.uidLabel];
    [self.view addSubview:self.roomKeyLabel];
    [self.view addSubview:self.uidTextField];
    [self.view addSubview:self.roomKeyTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.version];
    UIColor *color= [UIColor colorWithRed:0x72/255.0 green:0xd5/255.0 blue:0x72/255.0 alpha:1];
    [self.view setBackgroundColor:color];
    //点击空白区域失去界面失去焦点
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabTouch:)];
    [self.view addGestureRecognizer:tap];
    

    
    timer = [ NSTimer  scheduledTimerWithTimeInterval: 0.1
             
                                               target: self
             
                                             selector: @selector ( onTimer: )
             
                                             userInfo:nil
             
                                              repeats: YES ];
    
    [self CreateRoom];

}


-(void)CreateRoom
{
    NSString *documentsDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
#ifdef DEBUG
    SetLogLevel(LEVEL_VERBOSE);Cdebug
#endif
    
   // 新接口
    [ValleyRtcAPI InitSDK:documentsDirectory];
  //[ValleyRtcAPI SetAuthoKey:@"5a004a00bb039df5jpaDY8R"];
    
    _channel = [ValleyRtcAPI CreateChannel];
    [_channel EnableInterface:RTC_USERS_ID];
    [_channel EnableInterface:RTC_AUDIO_ID];
    [_channel EnableInterface:RTC_AUDIOSYS_ID];
    [_channel EnableInterface:RTC_DEVICE_CONTROLER_ID];
    [_channel RegisterRtcSink:self];
}

-(void) onTimer:(NSTimer*)sender{
    [_channel Poll];
}

- (void) dealloc{
    [_channel Release:true];
    [ValleyRtcAPI CleanSDK];
}


//按钮点击事件
- (void)buttonClick:(UIButton *)sender{
    [self.view endEditing:YES];//让界面失去焦点
    unsigned long length =_uidTextField.text.length;
    if (length == 0){
        MessageBox(@"警告",@"请输入用户名");
        return;
    }
    
    length =_roomKeyTextField.text.length;
    if (length == 0){
        MessageBox(@"警告",@"请输入房间号");
        return;
    }
    
    IRtcDeviceControler* ctrl = (IRtcDeviceControler*)[_channel GetInterface:RTC_DEVICE_CONTROLER_ID];
    
    NSString* roomid = _roomKeyTextField.text;
    if ( ([roomid isEqualToString: @"1"] ) || [roomid  isEqualToString: @"7"] || [roomid  isEqualToString: @"8"] || [roomid  isEqualToString: @"9"] ) {
        [_channel EnableInterface:RTC_DEVICE_CONTROLER_ID];
        [ctrl Enable:typeMusicMode enable:true];
        enableMusicBtn = true;
    }
    else
    {
        [ctrl Enable:typeMusicMode enable:false];
        enableMusicBtn = false;
    }
    [_channel Login:_roomKeyTextField.text userid:_uidTextField.text userinfo:nil];
}

- (void)tabTouch:(UITapGestureRecognizer *)sender{
    [self.view endEditing:YES];
}

//界面的布局
- (void)setViewsLayerout{
    self.uidLabel.frame = CGRectMake(0,200,70,40);
    self.uidTextField.frame = CGRectMake(60, 200, kScreenWidth - 80, 40);
    self.roomKeyLabel.frame = CGRectMake(0,_uidTextField.frame.origin.y + 40 + 20,70,40);
    self.roomKeyTextField.frame = CGRectMake(60, _uidTextField.frame.origin.y + 40 + 20, kScreenWidth - 80, 40);
    self.loginButton.frame = CGRectMake(0, _roomKeyTextField.frame.origin.y + 40 + 20, 80, 40);
    self.version.frame = CGRectMake(60, kScreenHeight - 60, kScreenWidth - 80, 40);
    
    CGPoint tempCenter = self.loginButton.center;
    tempCenter.x = self.view.center.x;
    self.loginButton.center = tempCenter;
    
    self.version.textAlignment = NSTextAlignmentCenter;
}

//获取帐号输入框
-(UITextField *)uidTextField{
    if (!_uidTextField) {
        _uidTextField = [[UITextField alloc] init];
        _uidTextField.borderStyle = UITextBorderStyleRoundedRect;
        _uidTextField.placeholder = @"请输入用户名";
    }
    return _uidTextField;
}

//获取密码输入框
-(UITextField *)roomKeyTextField{
    if (!_roomKeyTextField) {
        _roomKeyTextField = [[UITextField alloc] init];
        _roomKeyTextField.secureTextEntry = NO;//房间号输入
        _roomKeyTextField.borderStyle =UITextBorderStyleRoundedRect;
        _roomKeyTextField.placeholder = @"请输入房间号";
        
    }
    return _roomKeyTextField;
}

-(UILabel*)uidLabel{
    if(!_uidLabel){
        _uidLabel = [[UILabel alloc] init];
        _uidLabel.text = @"用户名";
    }
    return _uidLabel;
}



-(UILabel*)roomKeyLabel{
    if(!_roomKeyLabel){
        _roomKeyLabel = [[UILabel alloc] init];
        _roomKeyLabel.text = @"房间号";
    }
    return _roomKeyLabel;
}

//获取登陆按钮
-(UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}


-(UILabel*)version{
    if(!_version){
        _version = [[UILabel alloc] init];
        _version.text = [ValleyRtcAPI GetSDKVersion];
    }
    return _version;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
