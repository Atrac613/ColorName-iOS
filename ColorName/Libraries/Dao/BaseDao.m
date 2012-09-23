//
//  BaseDao.m
//  ColorName
//
//  Created by Osamu Noguchi on 9/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "BaseDao.h"
#import "AppDelegate.h"
@implementation BaseDao
@synthesize db;

- (id)init{
    if (self = [super init]) {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        db = appDelegate.db;
    }
    
    return self;
}

- (NSString*)setTable:(NSString*)sql {
    return nil;
}

@end
