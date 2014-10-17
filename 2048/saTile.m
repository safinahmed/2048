//
//  saTile.m
//  2048
//
//  Created by Safin Ahmed on 01/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//
#import "saTile.h"

@interface saTile ()

@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic, strong) UILabel *points;

@end

@implementation saTile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.value = 2;
//        self.value = arc4random() % 1000;
        self.hasMerged = NO;
        self.backgroundColor = [self getColor];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)tap
{
    self.value *= 2;
    [self updateTile];
}

-(void)addLabel
{
    CGRect labelFrame = CGRectMake(0,
                                   0,
                                   self.bounds.size.width,
                                   self.bounds.size.height);
    self.myLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.myLabel.text = [[NSString alloc] initWithFormat:@"%d",self.value];
    self.myLabel.font = [UIFont fontWithName:@"Baskerville-Bold" size:30.0f];
    self.myLabel.textAlignment = NSTextAlignmentCenter;
    self.myLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:self.myLabel];
}

- (void)drawRect:(CGRect)rect
{

}

-(void)mergeTo:(saTile*)tile
{
    [UIView beginAnimations:@"tileSwap" context:(__bridge void *)tile];
    /* 5 seconds animation */
    [UIView setAnimationDuration:0.2f];
    /* Receive animation delegates */
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:
     @selector(imageViewDidStop:finished:context:)];
    
    [self setFrame:tile.frame];
    [UIView commitAnimations];
    
    self.value += tile.value;
    
    [self showPoints];
}

-(void)showPoints
{
    CGRect labelFrame = CGRectMake(0,
                                   0,
                                   self.bounds.size.width,
                                   self.bounds.size.height);
    __block UILabel* pts = [[UILabel alloc] initWithFrame:labelFrame];
    pts.font = [UIFont fontWithName:@"EdwardianScriptITCStd"  size:18.0f];
    pts.textAlignment = NSTextAlignmentCenter;
    pts.center = CGPointMake(CGRectGetMidX(self.bounds)-5.0f, CGRectGetMidY(self.bounds)-5.0f);
    pts.alpha = 1.0f;
    pts.textColor = [UIColor blueColor];
    pts.text = [[NSString alloc] initWithFormat:@"+%d",self.value];
    
    [self addSubview:pts];
    
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        pts.center = CGPointMake(pts.center.x, -10);
        pts.alpha = 0.5f;
        
    }
    completion:^(BOOL finished){
        [pts removeFromSuperview];
    }];
}

- (void)imageViewDidStop:(NSString *)paramAnimationID finished:(NSNumber *)paramFinished
                 context:(void *)paramContext {
    saTile *oldTile = (__bridge saTile *)paramContext;
    
    [oldTile removeFromSuperview];
    
    [UIView transitionWithView:self duration:0.2f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [self updateTile];
    } completion:^(BOOL finished) {
    }];
}

-(void)updateTile
{
    if(self.value > 100000)
        self.myLabel.font = [UIFont fontWithName:@"Baskerville-Bold" size:18.0f];
    else if(self.value > 10000)
        self.myLabel.font = [UIFont fontWithName:@"Baskerville-Bold" size:24.0f];
    self.backgroundColor = [self getColor];
    self.myLabel.text = [[NSString alloc] initWithFormat:@"%d",self.value];
}

-(UIColor*)getColor {
    
    switch(self.value) {
        case 4: return [UIColor colorWithRed:105.0f/255.0f green:141.0f/255.0f blue:190.0f/255.0f alpha:1.0f];
        case 8: return [UIColor colorWithRed:253.0f/255.0f green:234.0f/255.0f blue:218.0f/255.0f alpha:1.0f];
            
        case 16: return [UIColor colorWithRed:247.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
        case 32: return [UIColor colorWithRed:210.0f/255.0f green:204.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
            
        case 64: return [UIColor colorWithRed:159.0f/255.0f green:179.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        case 128: return [UIColor colorWithRed:104.0f/255.0f green:173.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
            
        case 256: return [UIColor colorWithRed:250.0f/255.0f green:192.0f/255.0f blue:144.0f/255.0f alpha:1.0f];
        case 512: return [UIColor colorWithRed:217.0f/255.0f green:150.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
            
        case 1024: return [UIColor colorWithRed:179.0f/255.0f green:162.0f/255.0f blue:199.0f/255.0f alpha:1.0f];
        case 2048: return [UIColor colorWithRed:236.0f/255.0f green:260.0f/255.0f blue:129.0f/255.0f alpha:1.0f];
            
        case 4096: return [UIColor colorWithRed:67.0f/255.0f green:143.0f/255.0f blue:161.0f/255.0f alpha:1.0f];
        case 8192: return [UIColor colorWithRed:245.0f/255.0f green:199.0f/255.0f blue:99.0f/255.0f alpha:1.0f];
            
        case 16384: return [UIColor colorWithRed:244.0f/255.0f green:172.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
        case 32768: return [UIColor colorWithRed:55.0f/255.0f green:95.0f/255.0f blue:146.0f/255.0f alpha:1.0f];
            
        case 65536:return [UIColor colorWithRed:128.0f/255.0f green:120.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
        case 131072: return [UIColor colorWithRed:195.0f/255.0f green:224.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
            
        default: return [UIColor colorWithRed:220.0f/255.0f green:230.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
    }
}

@end
