//
//  OCMockSampleTests.m
//  ColorName
//
//  Created by Osamu Noguchi on 6/30/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import "OCMockSampleTests.h"
#import <OCMock/OCMock.h>

@implementation OCMockSampleTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testReturnsStubbedReturnValue
{
	id mock = [OCMockObject mockForClass:[NSString class]];
	[[[mock stub] andReturn:@"megamock"] lowercaseString];
	id returnValue = [mock lowercaseString];
    
	STAssertEqualObjects(@"megamock", returnValue, @"Should have returned stubbed value.");
}

@end
