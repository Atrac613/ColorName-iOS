//
//  AppDelegate.h
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

#define SharedAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    FMDatabase *db;
    BOOL isAuthenticated;
    NSString *userId;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FMDatabase *db;
@property (nonatomic) BOOL isAuthenticated;
@property (strong, nonatomic) NSString *userId;

@end
