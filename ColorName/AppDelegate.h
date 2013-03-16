//
//  AppDelegate.h
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "ColorNameService.h"
#import "GAI.h"

#define SharedAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    ColorNameService *colorNameService;
    FMDatabase *db;
    BOOL isAuthenticated;
    BOOL canBeCombine;
    NSString *userId;
    NSOperationQueue *operationQueue;
    
    id<GAITracker> tracker;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ColorNameService *colorNmaeService;
@property (strong, nonatomic) FMDatabase *db;
@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic) BOOL canBeCombine;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) id<GAITracker> tracker;

@end
