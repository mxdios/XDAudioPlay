//
//  XDTools.m
//  XDStreamingKitDemo
//
//  Created by miaoxiaodong on 2017/11/29.
//  Copyright © 2017年 mark. All rights reserved.
//

#import "XDTools.h"

@implementation XDTools
+ (NSString *)convertStringWithTime:(float)time {
    if (isnan(time)) time = 0.f;
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}
@end
