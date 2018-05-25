//
//  AudioEngineSwrapper.c
//  audiodemo
//
//  Created by 张乃淦 on 16/2/26.
//  Copyright © 2016年 valleyren. All rights reserved.
//

#include "utility.h"
#import <UIKit/UIAlertView.h>

NSString* toNSString(const char* str)
{
    if (!str) {
        return @"";
    }
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [NSString stringWithCString:str  encoding:enc];
}

const char* toString(NSString* str)
{
    if (!str) {
        return "";
    }
    return [str cStringUsingEncoding:NSASCIIStringEncoding];
}


NSString* formatUserString(NSString*user_id,int bBlocked,int bDisableSpeaked)
{
    NSString*strStatus = [NSString new];
    strStatus =  [strStatus stringByAppendingString:@"普通成员/"];
    
    if (bBlocked) {
        strStatus = [strStatus stringByAppendingString:@"阻止/"];
    }
    else{
        strStatus = [strStatus stringByAppendingString:@"未阻止/"];
    }
    
    if (bDisableSpeaked) {
        strStatus =[strStatus stringByAppendingString:@"禁言"];
    }else {
        strStatus =[strStatus stringByAppendingString:@"未禁言"];
    }

    return strStatus;

}

void MessageBox(NSString*title,NSString*msg)
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alter show];
}
