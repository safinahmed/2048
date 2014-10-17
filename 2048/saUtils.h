//
//  saUtils.h
//  2048
//
//  Created by Safin Ahmed on 09/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import <Foundation/Foundation.h>


const float TILE_SIZE_X ;

const float OFFSET_X ;

const float PADDING ;

const int BOARD_SIZE;

const float TILE_ANIMATION_TIME;

enum {
    saGameStatusNew = 1,
    saGameStatusPlaying = 2,
    saGameStatusPaused = 3,
    saGameStatusLost = 4,
    saGameStatusWon = 5
};
typedef NSUInteger saGameStatusType;

@interface saUtils : NSObject
+ (int)finishTile:(int)type;
+(BOOL)isiPhone5;
+(float)getTileSizeY;
+(float)getOffsetY;
+(float)getTutOffsetY;
@end
