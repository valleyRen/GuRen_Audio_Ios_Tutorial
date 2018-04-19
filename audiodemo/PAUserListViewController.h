//
//  PAUserListViewController.h
//  Demo
//
//  Created by 张乃淦 on 16/2/18.
//  Copyright © 2016年 pingan. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <valley_rtc_sdk/ValleyRtcDef_OC.h>
#include <valley_rtc_sdk/ValleyRtcAPI_OC.h>
//宏定义获取屏幕的宽度
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface PAUserListViewController : UIViewController

//重写构造方法传值
-(instancetype)initWithChannel:(nonnull IRtcChannel*)channel EnableMusicBtn:(bool) enableMusicBtn;
-(void)UpdateUserList;
-(void)Respond : (int)type ec:(int)ec ob:(nullable object_base*)ob;
-(void)Notify : (int)type ob : (nullable object_base*)ob;
@end
