//
//  DevicePerformance.h
//  ColorName
//
//  Created by Osamu Noguchi on 4/1/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DevicePerformance : NSObject {
    NSArray *lowPerformanceMachine;
}

@property (strong, nonatomic) NSArray *lowPerformanceMachine;

- (BOOL)isHighPerformanceMachine;

@end
