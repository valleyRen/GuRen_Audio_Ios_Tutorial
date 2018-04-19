//
//  DebugViewController.h
//  real_audio
//
//  Created by 陳偉榮 on 2017/5/5.
//  Copyright © 2017年 snailgame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utility.h"
#include "snail_real_audio/SnailAudioEngine_OC.h"
@interface DebugViewController : UIViewController

//重写构造方法传值
-(instancetype)initWithRoom:(AudioRoom*)room CfgTable:(struct ConfigTable*) cfgTable LengthOfTable:(int)length;
@end
