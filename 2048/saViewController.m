//
//  saViewController.m
//  2048
//
//  Created by Safin Ahmed on 01/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "saAppDelegate.h"
#import "saViewController.h"
#import "saTile.h"
#import "saUtils.h"
#import "saTutorial.h"


@interface saViewController () 

@property (nonatomic, strong) UIView *menu;

@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *soundBtn;
@property (nonatomic, strong) UIButton *restartBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *tutBtn;
@property (nonatomic, strong) UISegmentedControl *typeBtns;

@property (nonatomic, strong) UILabel *scoreLabel;

@property (nonatomic) saGameStatusType status;
@property (nonatomic) BOOL soundOn;

@property (nonatomic, strong) NSMutableArray *board;
@property (nonatomic, strong) NSMutableArray *boardTiles;

@property (nonatomic, strong) UIView* gameView;
@property (nonatomic, strong) saTutorial* tutorialView;

@property (nonatomic) int score;

@property (nonatomic) BOOL isiPhone5;

@property (nonatomic) BOOL hasRestarted;
@property (nonatomic) int gameType; //0 - 2048, 1 - 4096, 2 - Unlimited

@end

@implementation saViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.status = saGameStatusNew;
    self.gameView = self.view;
    self.isiPhone5 = [saUtils isiPhone5];
    self.hasRestarted = NO;
    self.gameType = 0;

    
    //GET SETTINGS
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger sound = [defaults integerForKey:@"sound"];

    if(sound == 2) {
        self.soundOn = YES;
    }
    else if (sound == 1) {
        self.soundOn = NO;
    }
    else
    {
        self.soundOn = YES;
        [defaults setInteger:2 forKey:@"sound"];
        [defaults synchronize];
    }
    
    
    //SETUP BACKGROUND IMAGE (BOARD)
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"board"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    
    //SETUP SCORE LABEL
    [self setupScoreAndPause];
    
    //SETUP BOARD
    self.board = [[NSMutableArray alloc] initWithCapacity: BOARD_SIZE];
    self.boardTiles = [[NSMutableArray alloc] initWithCapacity: BOARD_SIZE];
    
    for(int i=0;i<BOARD_SIZE;i++) {
        self.board[i] = [[NSMutableArray alloc] initWithCapacity: BOARD_SIZE];
        self.boardTiles[i] = [[NSMutableArray alloc] initWithCapacity: BOARD_SIZE];
        for(int j=0;j<BOARD_SIZE;j++) {
            CGPoint point = CGPointZero;
            
            if(self.isiPhone5)
                point = CGPointMake((TILE_SIZE_X * i) + (PADDING * i + 2) + OFFSET_X, ([saUtils getTileSizeY] * j) + (PADDING * j + (j+2)) + [saUtils getOffsetY]);
            else
                point = CGPointMake((TILE_SIZE_X * i) + (PADDING * i + 2) + OFFSET_X, ([saUtils getTileSizeY] * j) + (PADDING * j + 2) + [saUtils getOffsetY]);
            
            self.board[i][j] = [NSValue valueWithCGPoint:point];
            self.boardTiles[i][j] = [NSNull null];
        }
    }
    
    //GESTURES
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveTile:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveTile:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveTile:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveTile:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
        
    //MENU
    [self showMenu];
    
   
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [FlurryAds setAdDelegate:self];
    // 1. Fetch and display banner ads
    [FlurryAds fetchAndDisplayAdForSpace:@"BOTTOM_AD" view:self.view size:BANNER_BOTTOM];
//    // 2. Fetch fullscreen ads for later display
//    [FlurryAds fetchAdForSpace:@"INTERSTITIAL" frame:self.view.frame size:FULLSCREEN];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Remove Banner Ads and reset delegate
    [FlurryAds removeAdFromSpace:@"BOTTOM_AD" ];
    [FlurryAds setAdDelegate:nil];
}

#pragma mark SETUP

-(void)setupScoreAndPause {
    
    // SCORE LABEL
    CGPoint labelCenter = CGPointZero;
    
    if(self.isiPhone5)
        labelCenter = CGPointMake(250.5f, 64.0f);
    else
        labelCenter = CGPointMake(250.5f, 54.0f);
    
    CGRect labelFrame = CGRectMake(0,
                                   0,
                                   140.0f,
                                   30.0f);
    self.scoreLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.scoreLabel.font = [UIFont fontWithName:@"Noteworthy-Bold" size:26.0f];
    self.scoreLabel.textColor = [UIColor blackColor];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.center = labelCenter;
    [self.view addSubview:self.scoreLabel];
      
    
    //PAUSE BUTTON
    UIImage *pauseImg = [UIImage imageNamed:@"pauseBtn"];
    
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseBtn.frame = CGRectMake(0.0f, 0.0f, 35.0f, 35.0f);
    [self.pauseBtn setBackgroundImage:pauseImg forState:UIControlStateNormal];
    CGPoint pauseCenter = self.isiPhone5 ? CGPointMake(OFFSET_X * 6, 62.0f) : CGPointMake(OFFSET_X * 6, 52.0f);
    self.pauseBtn.center = pauseCenter;
    [self.pauseBtn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pauseBtn];
    
    
}

#pragma mark BUTTONS

-(void)restart:(id)sender {
    self.status = saGameStatusNew;
    [self play:nil];
}
    
-(void)play:(id)sender{
    
    if(self.status != saGameStatusPaused) {
        
        [Flurry logEvent:@"PLAY"];
        
        [self updateScore:0];
        self.hasRestarted = NO;
        self.gameType = (int)self.typeBtns.selectedSegmentIndex;
        
        for(int i=0;i<BOARD_SIZE;i++) {
            for(int j=0;j<BOARD_SIZE;j++) {
                saTile *curTile = (saTile*)self.boardTiles[i][j];
                if(![curTile isEqual:[NSNull null]]) {
                    [curTile removeFromSuperview];
                    self.boardTiles[i][j] = [NSNull null];
                }
            }
        }
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            self.menu.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.menu.hidden = YES;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
            [self addTile];
            [self addTile];
        }];
    } else {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            self.menu.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished){
            self.menu.hidden = YES;
        }];
    }
    
    self.status = saGameStatusPlaying;
    
    
}

-(void)pause:(UIButton*)sender{
    
    if(self.status == saGameStatusNew)
        return;
    
    if(self.status == saGameStatusPaused) {
        self.status = saGameStatusPlaying;
        self.menu.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.menu.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
            self.menu.hidden = YES;
        }];
        return;
    }
    
    else {
        self.status = saGameStatusPaused;
        [self showMenu];
    }
    
}

-(void)share:(id)sender {
    
    NSArray *activityItems;
    
    activityItems = @[NSLocalizedString(@"shareText",nil)];
    
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}

#pragma mark GAME MECHANICS

-(void)addTile {
    
    NSMutableArray *freePoints = [[NSMutableArray alloc] initWithCapacity:(BOARD_SIZE*BOARD_SIZE)];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i=0;i<BOARD_SIZE;i++) {
        for(int j=0;j<BOARD_SIZE;j++) {
            saTile *curTile = self.boardTiles[i][j];
            if([curTile isEqual:[NSNull null]]) {
                [freePoints addObject:self.board[i][j]];
                NSNumber *numberI = [NSNumber numberWithInt:i];
                [array addObject:numberI];
                NSNumber *numberJ = [NSNumber numberWithInt:j];
                [array addObject:numberJ];
            }
            else
                curTile.hasMerged = NO;
        }
    }
    
    if([freePoints count] == 0)
        return;
    
    int idx = arc4random() % [freePoints count];
    
    CGPoint tileLocation = [freePoints[idx] CGPointValue];
    saTile *aTile = [[saTile alloc]initWithFrame:CGRectMake(tileLocation.x, tileLocation.y, TILE_SIZE_X, [saUtils getTileSizeY])];
    aTile.center = CGPointMake(tileLocation.x + (TILE_SIZE_X / 2), tileLocation.y + ([saUtils getTileSizeY] / 2));
    
    [UIView animateWithDuration:TILE_ANIMATION_TIME animations:^{
        aTile.frame =  CGRectMake(tileLocation.x, tileLocation.y, TILE_SIZE_X, [saUtils getTileSizeY]);
    } completion:^(BOOL finished) {
        [aTile addLabel];
    }];
    
    int i = [array[idx*2] intValue];
    int j = [array[(idx*2)+1] intValue];
    
    self.boardTiles[i][j] = aTile;
    [self.view addSubview:aTile];
    
    if([freePoints count] == 1) {
        if(![self hasMoves]) {
            self.status = saGameStatusLost;
            [self gameOver];
        }
    }
}

-(void)moveTile:(UISwipeGestureRecognizer *)recognizer {
    
    if(self.status != saGameStatusPlaying)
        return;
    
    [self playSound:@"swipe" ofType:@"mp3"];
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        for(int i=1;i<BOARD_SIZE;i++) {
            for(int j=0;j<BOARD_SIZE;j++) {
                
                saTile *curTile = self.boardTiles[i][j];
                
                if([curTile isEqual:[NSNull null]])
                    continue;
                
                saTile *tempTile = nil;
                CGPoint tempPoint = CGPointZero;
                int tempX = 0;
                
                for(int x=i-1;x>=0;x--) {
                    
                    saTile *destTile = self.boardTiles[x][j];
                    
                    if([destTile isEqual:[NSNull null]]) {
                        tempTile = destTile;
                        tempPoint = [self.board[x][j] CGPointValue];
                        tempX = x;
                    }
                    else {
                        if(curTile.value == destTile.value && destTile.hasMerged == NO) {
                            [curTile mergeTo:destTile];
                            [self updateScore:destTile.value*2];
                            [self playSound:@"merge" ofType:@"mp3"];
                            self.boardTiles[x][j] = curTile;
                            self.boardTiles[i][j] = [NSNull null];
                            curTile.hasMerged = true;
                            tempTile = nil;
                            if(curTile.value == [saUtils finishTile:self.gameType]) {
                                self.status = saGameStatusWon;
                                [self performSelector:@selector(gameOver) withObject:nil afterDelay:0.2f];
                            }
                        }
                        break;
                    }
                }
                
                if(tempTile != nil) {
                    [UIView animateWithDuration:TILE_ANIMATION_TIME animations:^{
                        CGPoint point = tempPoint;
                        curTile.frame = CGRectMake(point.x, point.y, TILE_SIZE_X, [saUtils getTileSizeY]);
                    }];
                    self.boardTiles[tempX][j] = curTile;
                    self.boardTiles[i][j] = [NSNull null];
                }
            }
        }
    }

    else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        for(int i=BOARD_SIZE-2;i>-1;i--) {
            for(int j=0;j<BOARD_SIZE;j++) {
                
                saTile *curTile = self.boardTiles[i][j];
                
                if([curTile isEqual:[NSNull null]])
                    continue;
                
                saTile *tempTile = nil;
                CGPoint tempPoint = CGPointZero;
                int tempX = 0;
                
                for(int x=i+1;x<BOARD_SIZE;x++) {
                    
                    saTile *destTile = self.boardTiles[x][j];
                    
                    if([destTile isEqual:[NSNull null]]) {
                        tempTile = destTile;
                        tempPoint = [self.board[x][j] CGPointValue];
                        tempX = x;
                    }
                    else {
                        if(curTile.value == destTile.value && destTile.hasMerged == NO) {
                            [curTile mergeTo:destTile];
                            [self updateScore:destTile.value*2];
                            [self playSound:@"merge" ofType:@"mp3"];
                            self.boardTiles[x][j] = curTile;
                            self.boardTiles[i][j] = [NSNull null];
                            curTile.hasMerged = true;
                            tempTile = nil;
                            if(curTile.value == [saUtils finishTile:self.gameType]) {
                                self.status = saGameStatusWon;
                                [self performSelector:@selector(gameOver) withObject:nil afterDelay:0.2f];
                            }
                        }
                        break;
                    }
                }
                
                if(tempTile != nil) {
                    [UIView animateWithDuration:TILE_ANIMATION_TIME animations:^{
                        CGPoint point = tempPoint;
                        curTile.frame = CGRectMake(point.x, point.y, TILE_SIZE_X, [saUtils getTileSizeY]);
                    }];
                    self.boardTiles[tempX][j] = curTile;
                    self.boardTiles[i][j] = [NSNull null];
                }
            }
        }
    }
    
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionDown)
    {
        for(int i=0;i<BOARD_SIZE;i++) {
            for(int j=BOARD_SIZE-2;j>-1;j--) {
                
                saTile *curTile = self.boardTiles[i][j];
                
                if([curTile isEqual:[NSNull null]])
                    continue;
                
                saTile *tempTile = nil;
                CGPoint tempPoint = CGPointZero;
                int tempX = 0;
                
                for(int x=j+1;x<BOARD_SIZE;x++) {
                    
                    saTile *destTile = self.boardTiles[i][x];
                    
                    if([destTile isEqual:[NSNull null]]) {
                        tempTile = destTile;
                        tempPoint = [self.board[i][x] CGPointValue];
                        tempX = x;
                    }
                    else {
                        if(curTile.value == destTile.value && destTile.hasMerged == NO) {
                            [curTile mergeTo:destTile];
                            [self updateScore:destTile.value*2];
                            [self playSound:@"merge" ofType:@"mp3"];
                            self.boardTiles[i][x] = curTile;
                            self.boardTiles[i][j] = [NSNull null];
                            curTile.hasMerged = true;
                            tempTile = nil;
                            if(curTile.value == [saUtils finishTile:self.gameType]) {
                                self.status = saGameStatusWon;
                                [self performSelector:@selector(gameOver) withObject:nil afterDelay:0.2f];
                            }
                        }
                        break;
                    }
                }
                
                if(tempTile != nil) {
                    [UIView animateWithDuration:TILE_ANIMATION_TIME animations:^{
                        CGPoint point = tempPoint;
                        curTile.frame = CGRectMake(point.x, point.y, TILE_SIZE_X, [saUtils getTileSizeY]);
                    }];
                    self.boardTiles[i][tempX] = curTile;
                    self.boardTiles[i][j] = [NSNull null];
                }
            }
        }
        
    }
    
    
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionUp)
    {
        for(int i=0;i<BOARD_SIZE;i++) {
            for(int j=1;j<BOARD_SIZE;j++) {
                
                saTile *curTile = self.boardTiles[i][j];
                
                if([curTile isEqual:[NSNull null]])
                    continue;
                
                saTile *tempTile = nil;
                CGPoint tempPoint = CGPointZero;
                int tempX = 0;
                
                for(int x=j-1;x>=0;x--) {
                    
                    saTile *destTile = self.boardTiles[i][x];
                    
                    if([destTile isEqual:[NSNull null]]) {
                        tempTile = destTile;
                        tempPoint = [self.board[i][x] CGPointValue];
                        tempX = x;
                    }
                    else {
                        if(curTile.value == destTile.value && destTile.hasMerged == NO) {
                            [curTile mergeTo:destTile];
                            [self updateScore:destTile.value*2];
                            [self playSound:@"merge" ofType:@"mp3"];
                            self.boardTiles[i][x] = curTile;
                            self.boardTiles[i][j] = [NSNull null];
                            curTile.hasMerged = true;
                            tempTile = nil;
                            if(curTile.value == [saUtils finishTile:self.gameType]) {
                                self.status = saGameStatusWon;
                                [self performSelector:@selector(gameOver) withObject:nil afterDelay:0.2f];
                            }
                        }
                        break;
                    }
                }
                
                if(tempTile != nil) {
                    [UIView animateWithDuration:TILE_ANIMATION_TIME animations:^{
                        CGPoint point = tempPoint;
                        curTile.frame = CGRectMake(point.x, point.y, TILE_SIZE_X, [saUtils getTileSizeY]);
                    }];
                    self.boardTiles[i][tempX] = curTile;
                    self.boardTiles[i][j] = [NSNull null];
                }
            }
        }
        
    }

    [self performSelector:@selector(addTile) withObject:nil afterDelay:.2f];
    
}

-(void)gameOver {
    
    UILabel* statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0f)];
    statusLabel.center = CGPointMake(self.view.frame.size.width/2, -10);
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.text = self.status == saGameStatusLost ? NSLocalizedString(@"lostMsg",nil) : NSLocalizedString(@"wonMsg",nil) ;
    statusLabel.textColor = self.status == saGameStatusLost ? [UIColor redColor] : [UIColor blueColor];
    statusLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:40.0f];
    [self.view addSubview:statusLabel];
    
    CGPoint destPoint = CGPointZero;
    
    if(self.isiPhone5)
        destPoint = CGPointMake(self.view.frame.size.width/2, 105.0f);
    else
        destPoint = CGPointMake(self.view.frame.size.width/2, 85.0f);
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            statusLabel.center = destPoint;
    } completion:^(BOOL finished){
        [self countRemainingPoints];
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [statusLabel removeFromSuperview];
        saAppDelegate *del = [[UIApplication sharedApplication] delegate];
        [del.cb showInterstitial];
    });
    
//    if(self.gameType == 2){
//        NSLog(@"GAME TYPE 2");
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [statusLabel removeFromSuperview];
//            saAppDelegate *del = [[UIApplication sharedApplication] delegate];
//            [del.cb showInterstitial];
//        });
//    }
//    else {
//        // Delay execution of my block for 3 seconds.
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [statusLabel removeFromSuperview];
//            if([FlurryAds adReadyForSpace:@"INTERSTITIAL" ])
//                [FlurryAds displayAdForSpace:@"INTERSTITIAL" onView:self.view];
//            else
//                [self showMenu];
//        });
//    }

    self.status = saGameStatusNew;
}

-(void)countRemainingPoints {
    for(int i=0;i<BOARD_SIZE;i++) {
        for(int j=0;j<BOARD_SIZE;j++) {
            saTile* tile = self.boardTiles[i][j];
            if(![tile isEqual:[NSNull null]])
            {
                    [tile showPoints];
                    [self updateScore:tile.value];
            }
        }
    }
}

-(void)showMenu{
    
    float viewWidth = self.view.frame.size.width - (OFFSET_X + TILE_SIZE_X) + 20.0f;
    float viewHeight = self.view.frame.size.height - ([saUtils getTileSizeY] + [saUtils getOffsetY]) + 20.0f;

    //FIRST LOAD
    if(self.menu == nil) {
        
        self.menu = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewWidth, viewHeight)];
        
        self.menu.center = self.view.center;
        self.menu.backgroundColor = [UIColor colorWithRed:242.0f green:255.0f blue:251.0f alpha:1.0f];
        self.menu.layer.cornerRadius = 50.0f;
        self.menu.layer.masksToBounds = YES;
        
        //GAME TYPE
        NSArray *itemArray = [NSArray arrayWithObjects: @"2048", @"4096", NSLocalizedString(@"unlimitedTxt",nil), nil];
        self.typeBtns = [[UISegmentedControl alloc] initWithItems:itemArray];
        self.typeBtns.frame = CGRectMake(0, 0, viewWidth-20, 50);
        self.typeBtns.center = CGPointMake(viewWidth/2,45.0f);
        self.typeBtns.selectedSegmentIndex = 0;
        self.typeBtns.tintColor = [UIColor orangeColor];
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Futura-Medium" size:15], NSFontAttributeName, nil];
        [self.typeBtns setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        [self.menu addSubview:self.typeBtns];
        
        //TITLE
//        UIImage *titleImg = [UIImage imageNamed:@"title"];
//        UIImageView* iView = [[UIImageView alloc] initWithImage:titleImg];
//        iView.center = CGPointMake(viewWidth/2,45.0f);
//        [self.menu addSubview:iView];
        
        //PLAY
        UIImage *playImg = [UIImage imageNamed:@"playBtn"];
        
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playBtn.frame = CGRectMake(0.0f,0.0f, 60.0f, 60.0f);
        self.playBtn.center = CGPointMake(viewWidth/2,(viewHeight/2)-35.0f);
        [self.playBtn setBackgroundImage:playImg forState:UIControlStateNormal];
        [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [self.menu addSubview:self.playBtn];
        
        //RESTART
        UIImage *restartImg = [UIImage imageNamed:@"retryBtn"];
        self.restartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.restartBtn.frame = CGRectMake(0.0f,0.0f, 60.0f, 60.0f);
        self.restartBtn.center = CGPointMake(viewWidth - (viewWidth/3),(viewHeight/2)-35.0f);
        [self.restartBtn setBackgroundImage:restartImg forState:UIControlStateNormal];
        [self.restartBtn addTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
        self.restartBtn.hidden = YES;
        [self.menu addSubview:self.restartBtn];
        
        
        //SOUND
        UIImage *soundImg = [self getSoundImg];
        self.soundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.soundBtn.frame = CGRectMake(0.0f,0.0f, 60.0f, 60.0f);
        
        if (self.isiPhone5)
            self.soundBtn.center = CGPointMake(viewWidth/3,(viewHeight/2)+50.0f);
        else
            self.soundBtn.center = CGPointMake(viewWidth/3,(viewHeight/2)+35.0f);
        
        [self.soundBtn setBackgroundImage:soundImg forState:UIControlStateNormal];
        [self.soundBtn addTarget:self action:@selector(soundPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.menu addSubview:self.soundBtn];
        
        
        //SHARE
        UIImage *shareImg = [UIImage imageNamed:@"shareBtn"];
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareBtn.frame = CGRectMake(0.0f,0.0f, 60.0f, 60.0f);
        
        if (self.isiPhone5)
            self.shareBtn.center = CGPointMake(viewWidth - (viewWidth/3),(viewHeight/2)+50.0f);
        else
            self.shareBtn.center = CGPointMake(viewWidth - (viewWidth/3),(viewHeight/2)+35.0f);
        
        [self.shareBtn setBackgroundImage:shareImg forState:UIControlStateNormal];
        [self.shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.menu addSubview:self.shareBtn];
        
        //TUTORIAL
        
        UIImage *tutImg = [UIImage imageNamed:@"tutBtn"];
        self.tutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.tutBtn.frame = CGRectMake(0.0f,0.0f, 60.0f, 60.0f);
        self.tutBtn.center = CGPointMake(viewWidth/2,viewHeight - 50.0f);
        [self.tutBtn setBackgroundImage:tutImg forState:UIControlStateNormal];
        [self.tutBtn addTarget:self action:@selector(tutorial:) forControlEvents:UIControlEventTouchUpInside];
        [self.menu addSubview:self.tutBtn];
        
        [self.view addSubview:self.menu];
    } else
        self.typeBtns.selectedSegmentIndex = self.gameType;
    
    if(self.status == saGameStatusLost) {
        self.playBtn.center = CGPointMake(viewWidth/2,(viewHeight/2)-35.0f);
        self.restartBtn.hidden = YES;
    }
    
    
    self.menu.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        self.menu.transform = CGAffineTransformIdentity;
        self.menu.hidden = NO;
        [self.view bringSubviewToFront:self.menu];
        
        if(self.status == saGameStatusPaused) {
            self.playBtn.center = CGPointMake(viewWidth/3,(viewHeight/2)-35.0f);
            self.restartBtn.hidden = NO;
        } else {
            self.playBtn.center = CGPointMake(viewWidth/2,(viewHeight/2)-35.0f);
            self.restartBtn.hidden = YES;
        }
        
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
    
    [self.view bringSubviewToFront:self.menu];
    
}

//If points = 0 restarts score
-(void)updateScore:(int)points {
    
    if(points == 0)
        self.score = 0;
    else
        self.score += points;
    
    self.scoreLabel.text = [[NSString alloc]initWithFormat:@"%d",self.score];
}

#pragma mark ADs
-(BOOL) spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL) interstitial {
    if (interstitial) {
        // Pause app state here
    }
    // Continue ad display
    return YES; }
/*
 * Resumeappstatewhentheinterstitialisdismissed. */
-(void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    if (interstitial) {
        [self showMenu];
        [FlurryAds fetchAdForSpace:@"INTERSTITIAL" frame:self.view.frame size:FULLSCREEN];
    }
}

- (void)didFailToLoadInterstitial:(NSString *)location {
    if(self.score > 0) {
        if([FlurryAds adReadyForSpace:@"INTERSTITIAL" ]) {
            [FlurryAds displayAdForSpace:@"INTERSTITIAL" onView:self.view];
        }
        else {
            [self showMenu];
        }
    }
}

- (void)didDismissInterstitial:(CBLocation)location {
     [self showMenu];
}

#pragma mark TUTORIAL

- (void)tutorial:(UIButton*)sender{
    
    //FIRST LOAD
    if(self.tutorialView == nil) {
        self.tutorialView = [[saTutorial alloc]initWithFrame:self.view.frame];
        //BUTTON
        UIButton* okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        okBtn.frame = CGRectMake(0.0f,0.0f, 60.0f, 60.0f);
        okBtn.center = CGPointMake(CGRectGetMidX(self.view.frame), self.view.frame.size.height-20.0f);
        [okBtn setTitle:@"OK" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(tutorialOK:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tutorialView addSubview:okBtn];
    }
    
    [UIView transitionFromView:self.gameView toView:self.tutorialView
                      duration:.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
                        if(self.tutorialView.isPaused)
                        {
                            self.tutorialView.isPaused = NO;
                            [self.tutorialView start:self.board];
                        }
                    }];
}

- (void)tutorialOK:(UIButton*)sender{
    self.tutorialView.isPaused = YES;
    [UIView transitionFromView:self.tutorialView toView:self.gameView
                      duration:.5f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:NULL];
}

#pragma mark SOUND

-(UIImage*)getSoundImg {
    UIImage *soundImg =nil;
    if(self.soundOn)
        soundImg = [UIImage imageNamed:@"soundOnBtn"];
    else
        soundImg = [UIImage imageNamed:@"soundOffBtn"];
    
    return soundImg;
}

-(void)playSound:(NSString*)sound ofType:(NSString*)soundType
{
    
    if(!self.soundOn)
        return;
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFURLRef soundFileURLref;
        soundFileURLref = CFBundleCopyResourceURL(mainBundle ,(__bridge CFStringRef)sound,CFSTR ("wav"),NULL);
        UInt32 soundID;
        AudioServicesCreateSystemSoundID(soundFileURLref, &soundID);
        AudioServicesPlaySystemSound(soundID);
        CFRelease(soundFileURLref);
        
        //        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
        //                                             pathForResource:sound
        //                                             ofType:soundType]];
        //
        //        NSError *error;
        //        _audioPlayer = [[AVAudioPlayer alloc]
        //                        initWithContentsOfURL:url
        //                        error:&error];
        //        if (error)
        //        {
        //            NSLog(@"Error in audioPlayer: %@", [error description]);
        //        } else {
        //            _audioPlayer.delegate = this;
        //            [_audioPlayer prepareToPlay];
        //            [_audioPlayer play];
        //        }
    });
}

- (void)soundPressed:(UIButton*)sender{
    self.soundOn = !self.soundOn;
    [self.soundBtn setBackgroundImage:[self getSoundImg] forState:UIControlStateNormal];
    
    int soundOn = self.soundOn ? 2 : 1;
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue,^(void){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:soundOn forKey:@"sound"];
        [defaults synchronize];
    });
    
    
}

#pragma mark MOVE CHECK
-(BOOL)hasMoves {
    
    for(int i=0;i<BOARD_SIZE;i++) {
        for(int j=0;j<BOARD_SIZE;j++) {
            if([self canMoveDownWithI:i J:j])
                return YES;
            if([self canMoveLeftWithI:i J:j])
                return YES;
            if([self canMoveRightWithI:i J:j])
                return YES;
            if([self canMoveUpWithI:i J:j])
                return YES;
        }
    }
    return NO;
}

-(BOOL)canMoveUpWithI:(int)i J:(int)j {
    
    if(j == 0)
        return NO;
    
    saTile *curTile = self.boardTiles[i][j];
    saTile *destTile = self.boardTiles[i][j-1];
    
    return curTile.value == destTile.value;
    
}

-(BOOL)canMoveDownWithI:(int)i J:(int)j {
    
    if(j == BOARD_SIZE-1)
        return NO;
    
    saTile *curTile = self.boardTiles[i][j];
    saTile *destTile = self.boardTiles[i][j+1];
    
    return curTile.value == destTile.value;
    
}

-(BOOL)canMoveLeftWithI:(int)i J:(int)j {
    
    if(i == 0)
        return NO;
    
    saTile *curTile = self.boardTiles[i][j];
    saTile *destTile = self.boardTiles[i-1][j];
    
    return curTile.value == destTile.value;
    
}

-(BOOL)canMoveRightWithI:(int)i J:(int)j {
    
    if(i == BOARD_SIZE-1)
        return NO;
    
    saTile *curTile = self.boardTiles[i][j];
    saTile *destTile = self.boardTiles[i+1][j];
    
    return curTile.value == destTile.value;
}



-(void)printBoard {
    
    NSLog(@"------ BOARD BEGINNING ------");
    
    for(int i=0;i<BOARD_SIZE;i++) {
        NSString *line = @"";
        for(int j=0;j<BOARD_SIZE;j++) {
            if(self.boardTiles[j][i] == [NSNull null])
                line = [line stringByAppendingString:[[NSString alloc]initWithFormat:@"%d;%d - N      ",j,i]];
            else
                line = [line stringByAppendingString:[[NSString alloc]initWithFormat:@"%d;%d - %d     ",j,i,((saTile*)self.boardTiles[j][i]).value]];
        }
        NSLog(@"%@",line);
    }
    
    NSLog(@"------ BOARD ENDING ------");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
