//
//  saTutorial.m
//  2048
//
//  Created by Safin Ahmed on 09/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import "saTutorial.h"
#import "saTile.h"
#import "saUtils.h"

@interface saTutorial ()

@property (nonatomic, strong) saTile *tile1;
@property (nonatomic, strong) saTile *tile2;
@property (nonatomic, strong) saTile *tile3;
@property (nonatomic, strong) saTile *tile4;
@property (nonatomic, strong) UIImageView *handImageView;

@end

@implementation saTutorial

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isPaused = YES;
        // Initialization code
        //SETUP BACKGROUND IMAGE (BOARD)
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial"]];
        bgImageView.frame = self.bounds;
        [self addSubview:bgImageView];
        
        //INSTRUCTIONS
        CGRect labelFrame = CGRectMake(0,
                                       0,
                                       self.bounds.size.width-20,
                                       400);
        UILabel *instructions = [[UILabel alloc] initWithFrame:labelFrame];
        
        instructions.text = NSLocalizedString(@"tutorialText",nil);
        instructions.numberOfLines=10;
        instructions.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
        instructions.textAlignment = NSTextAlignmentLeft;
        if([saUtils isiPhone5])
            instructions.center = CGPointMake(CGRectGetMidX(self.bounds), 90.0f);
        else
            instructions.center = CGPointMake(CGRectGetMidX(self.bounds), 70.0f);
        [self addSubview:instructions];
    }
    return self;
}

-(void)playScenario:(int) scenario onBoard:(NSMutableArray*)board {
    
    [self.tile1 removeFromSuperview];
    [self.tile2 removeFromSuperview];
    [self.tile3 removeFromSuperview];
    [self.tile4 removeFromSuperview];
    [self.handImageView removeFromSuperview];
    
    if(scenario == 0) {
        CGPoint point1 =[board[0][1] CGPointValue];
        point1.y += [saUtils getTutOffsetY];
        
        CGPoint point2 =[board[2][1] CGPointValue];
        point2.y += [saUtils getTutOffsetY];
        
        //SCENARIO 1
        self.handImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hand"]];
        self.handImageView.center = CGPointMake(point1.x + (TILE_SIZE_X / 2), point2.y + ([saUtils getTileSizeY] * 2));

        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            if(self.isPaused)
                return;
            
            self.tile1 = [self addTile:point1];
            self.tile2 = [self addTile:point2];
            [self addSubview:self.handImageView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                if(self.isPaused)
                    return;
                
                [UIView animateWithDuration:TILE_ANIMATION_TIME*3 animations:^{
                    self.handImageView.center = CGPointMake(point2.x + TILE_SIZE_X, point2.y + ([saUtils getTileSizeY] * 2));
                    
                }];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    
                    if(self.isPaused)
                        return;
                    [self.tile1 mergeTo:self.tile2];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        
                        if(self.isPaused)
                            return;
                        self.tile3 = [self addTile:point1];
                        
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            
                            if(self.isPaused)
                                return;
                            
                            [self start:board];
                        });
                    });
                    
                });
            });
            
        });
    }
}

-(void)start:(NSMutableArray*)board {

    if(self.isPaused)
        return;
    
    [self playScenario:0 onBoard:board];

}

-(void)move:(saTile*)aTile To:(CGPoint)tileLocation {
    
    [UIView animateWithDuration:TILE_ANIMATION_TIME animations:^{
        aTile.center = CGPointMake(tileLocation.x+(TILE_SIZE_X/2), tileLocation.y+([saUtils getTileSizeY]/2));
    } completion:^(BOOL finished) {
        //[aTile addLabel];
    }];
}

-(saTile*)addTile:(CGPoint)tileLocation {

    saTile *aTile = [[saTile alloc]initWithFrame:CGRectMake(tileLocation.x, tileLocation.y, 0, 0)];
    aTile.center = CGPointMake(tileLocation.x + (TILE_SIZE_X / 2), tileLocation.y + ([saUtils getTileSizeY] / 2));
    [self addSubview:aTile];
    
    [UIView animateWithDuration:TILE_ANIMATION_TIME animations:^{
        aTile.frame =  CGRectMake(tileLocation.x, tileLocation.y, TILE_SIZE_X, [saUtils getTileSizeY]);
    } completion:^(BOOL finished) {
        [aTile addLabel];
    }];
    
    return aTile;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
