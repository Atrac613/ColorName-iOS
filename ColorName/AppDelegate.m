//
//  AppDelegate.m
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "AppDelegate.h"
#import "Appirater.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize colorNmaeService;
@synthesize db;
@synthesize isAuthenticated;
@synthesize canBeCombine;
@synthesize userId;
@synthesize operationQueue;
@synthesize tracker;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // operation queue
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    
    colorNmaeService = [[ColorNameService alloc] init];
    
    isAuthenticated = NO;
    canBeCombine = NO;
    
    if (![self initDatabase]) {
        NSLog(@"Failed to init database.");
    }
    
    userId = @"";
    
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingId];
    
    tracker = [[GAI sharedInstance] defaultTracker];
    
    [Appirater setAppId:[NSString stringWithFormat:@"%d", kAppId]];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (!SEND_USAGE_STATISTICS) {
        [[GAI sharedInstance] setOptOut:YES];
        
        NSLog(@"Don't send usage statistics.");
    } else {
        [[GAI sharedInstance] setOptOut:NO];
        
        NSLog(@"Send usage staistics.");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)initDatabase {
    BOOL success;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"app.db"];
    
    db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        success = YES;
    } else {
        NSLog(@"Failed to open database.");
        success = NO;
    }
    
    return success;
}

- (void)closeDatabase {
    [db close];
}

@end
