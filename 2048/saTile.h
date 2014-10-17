//
//  saTile.h
//  2048
//
//  Created by Safin Ahmed on 01/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface saTile : UIView

@property (nonatomic) int value;
@property (nonatomic) BOOL hasMerged;

-(void)mergeTo:(saTile*)tile;
-(void)addLabel;
-(void)showPoints;
@end
