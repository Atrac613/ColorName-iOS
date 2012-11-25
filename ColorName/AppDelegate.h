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

#define SharedAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    ColorNameService *colorNameService;
    FMDatabase *db;
    BOOL isAuthenticated;
    BOOL canBeMerge;
    NSString *userId;
    NSOperationQueue *operationQueue;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ColorNameService *colorNmaeService;
@property (strong, nonatomic) FMDatabase *db;
@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic) BOOL canBeMerge;
@property (strong, nonatomic) NSString *userId;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end
