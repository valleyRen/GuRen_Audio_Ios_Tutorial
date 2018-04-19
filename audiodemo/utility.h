//
//  AudioEngineSwrapper.h
//  audiodemo
//
//  Created by 陳偉榮 on 16/2/26.
//  Copyright © 2016年 valleyren. All rights reserved.
//

#ifndef utility_h
#define utility_h

#include <Foundation/Foundation.h> 
struct ConfigTable
{
    int type;
    int bplay;
    int open;
    const char* text;
};

NSString* toNSString(const char* str);


const char* toString(NSString* str);


//宏定义获取屏幕的宽度
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
void MessageBox(NSString*title,NSString*msg);
NSString* formatUserString( NSString* user_id, int bBlock, int bDisableSpeaked);

extern int  UILoginState;// 0 是第一个页面，1，2，3，依次叠加
 
#endif /* utility_h */
