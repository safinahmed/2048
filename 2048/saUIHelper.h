//
//  saUIHelper.h
//  2048
//
//  Created by Safin Ahmed on 05/04/14.
//  Copyright (c) 2014 Safin Ahmed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface saUIHelper : NSObject

-(saUIHelper*)initWithView:(UIView*)view forRelationView:(UIView*)relationview withTag:(NSString*)tag drawBounds:(BOOL)drawBounds;
-(void)start;
-(void)stop;
-(void)remove;
@end
