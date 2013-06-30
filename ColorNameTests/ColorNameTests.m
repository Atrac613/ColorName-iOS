//
//  ColorNameTests.m
//  ColorNameTests
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ColorNameTests.h"
#import "JSON.h"
#import "UIColor_Categories.h"
#import "MasterViewController.h"

static NSTimeInterval const SenDefaultTimeoutInterval = 30.f;

@implementation ColorNameTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test001FindYellowColor
{
    colorNameEnDao = [[TbColorNameEnDao alloc] init];
    
    NSArray *results = [colorNameEnDao findColorNameWithColor:[UIColor yellowColor]];
    
    NSLog(@"Results: %d", [results count]);
    
    STAssertTrue([results count] > 0, @"Database is not initialize.");
}

@end
