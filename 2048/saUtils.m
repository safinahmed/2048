//
//  saUtils.m
//  2048
//
//  Created by Safin Ahmed on 09/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import "saUtils.h"
#include <sys/types.h>
#include <sys/sysctl.h>

const float TILE_SIZE_X = 68.0f;

const float OFFSET_X = 7.0f;

const float PADDING = 10.0f;

const int BOARD_SIZE = 4;

const float TILE_ANIMATION_TIME = 0.2f;

@implementation saUtils

+ (int)finishTile:(int)type {
    if(type == 1)
        return 4096;
    else if(type == 2)
        return 0;
    
    return 2048;
}

+ (BOOL)isiPhone5 {

    int name[] = {CTL_HW,HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); 
    char *hw_machine = malloc(size);
    
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    
    NSString *tempString = [hardware componentsSeparatedByString: @","][0];

    if([tempString  isEqual: @"iPhone3"] || [tempString isEqual: @"iPhone4"])
        return NO;
    else
        return YES;
    
}

+(float)getTileSizeY {
    if([self isiPhone5])
        return 81.0f;
    else
        return 68.0f;
}

+(float)getOffsetY {
    if([self isiPhone5])
        return 127.0f;
    else
        return 107.0;
}

+(float)getTutOffsetY {
    if([self isiPhone5])
        return 27.0f;
    else
        return 22.0;
}

@end
