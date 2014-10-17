//
//  saTutorial.h
//  2048
//
//  Created by Safin Ahmed on 09/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface saTutorial : UIView

@property (nonatomic) BOOL isPaused;

-(void)start:(NSMutableArray*)board;
@end
