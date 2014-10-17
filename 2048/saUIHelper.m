//
//  saUIHelper.m
//  2048
//
//  Created by Safin Ahmed on 05/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import "saUIHelper.h"

@interface saUIHelper ()

@property (nonatomic, strong) UIView *myView;
@property (nonatomic, strong) UIView *relationview;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic) BOOL drawBounds;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic) BOOL hasBounds;
@property (nonatomic) BOOL isResizing;
@property (nonatomic) CGColorRef oldColor;
@property (nonatomic) CGColorRef originalColor;
@property (nonatomic) float originalBorderSize;

@end


@implementation saUIHelper


-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(self.isResizing) {
        CGPoint velocity = [recognizer velocityInView:self.myView];
        
        if(velocity.x > 0)
        {
            NSLog(@"gesture went right");
        }
        else
        {
            NSLog(@"gesture went left");
        }
        
        CGPoint translation = [recognizer translationInView:self.myView];
        recognizer.view.frame = CGRectMake(self.myView.frame.origin.x,
                                           self.myView.frame.origin.y,
                                           self.myView.frame.size.width+translation.x,
                                           self.myView.frame.size.height+translation.y);
        recognizer.view.center = CGPointMake(self.myView.center.x-translation.x, self.myView.center.y-translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.myView];
        NSLog(@"%@ %f %f",self.tag,recognizer.view.center.x,recognizer.view.center.y);
    }
    else
    {
        CGPoint translation = [recognizer translationInView:self.myView];
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.myView];
        NSLog(@"%@ %f %f",self.tag,recognizer.view.center.x,recognizer.view.center.y);
    }
}

-(void)handleLP:(UILongPressGestureRecognizer *)recognizer
{
    CALayer * layer = [self.myView layer];
    [layer setBorderWidth:4.0f];
    [layer setBorderColor:[[UIColor redColor] CGColor]];
    self.hasBounds = YES;
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    CALayer * layer = [self.myView layer];
    if(self.isResizing)
    {
        [layer setBorderWidth:self.originalBorderSize];
        [layer setBorderColor:self.originalColor];
        self.isResizing = NO;
    }
    else
    {
        [layer setBorderWidth:4.0f];
        [layer setBorderColor:[[UIColor greenColor] CGColor]];
        self.isResizing = YES;
    }
}

-(saUIHelper*)initWithView:(UIView*)view forRelationView:(UIView*)relationview withTag:(NSString*)tag drawBounds:(BOOL)drawBounds
{
    self = [super init];
    if(self){
        self.myView = view;
        self.relationview = relationview;
        self.tag = tag;
        self.drawBounds = drawBounds;
    }
    return self;
}

-(void)start
{
    
    self.myView.userInteractionEnabled = YES;
    CALayer * layer = [self.myView layer];
    self.originalBorderSize = layer.borderWidth;
    self.originalColor = layer.borderColor;
    
    if(self.panRecognizer == nil)
        self.panRecognizer =
        [[UIPanGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(handlePan:)];
    
    [self.myView addGestureRecognizer:self.panRecognizer];
    
    if(self.drawBounds) {
        if(self.lpRecognizer == nil)
            self.lpRecognizer =
            [[UILongPressGestureRecognizer alloc]
             initWithTarget:self
             action:@selector(handleLP:)];
        
        [self.myView addGestureRecognizer:self.lpRecognizer];
    }
    
    if(self.tapRecognizer == nil) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleDoubleTap:)];
        self.tapRecognizer.numberOfTapsRequired = 2;
        [self.myView addGestureRecognizer:self.tapRecognizer];
    }
    
}

-(void)stop {
    
    [self.myView removeGestureRecognizer:self.panRecognizer];
    [self.myView removeGestureRecognizer:self.lpRecognizer];
    
}

-(void)remove {
    [self stop];
    self.myView = nil;
    self.tag = nil;
    self.relationview = nil;
}


@end
