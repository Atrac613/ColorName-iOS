//
//  DevicePerformance.m
//  ColorName
//
//  Created by Osamu Noguchi on 4/1/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import "DevicePerformance.h"
#import "MachineName.h"

@implementation DevicePerformance

@synthesize lowPerformanceMachine;

- (id)init {
    lowPerformanceMachine = [[NSArray alloc] initWithObjects:@"iPod1,1", @"iPod2,1", @"iPod3,1", @"iPod4,1", @"iPhone1,1", @"iPhone1,2", @"iPhone2,1", @"iPad1,1", @"iPad2,1", @"iPhone3,1", nil];
    
    return self;
}

- (BOOL)isHighPerformanceMachine {
    NSString *currentMachineName = [[[MachineName alloc] init] machineName];
    
    if ([lowPerformanceMachine containsObject:currentMachineName]) {
        return NO;
    }
    
    return YES;
}

@end
