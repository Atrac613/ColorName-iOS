//
//  ColorNameTests.h
//  ColorNameTests
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TbColorNameJaDao.h"
#import "TbColorNameEnDao.h"

@interface ColorNameTests : SenTestCase {
    TbColorNameJaDao *colorNameJaDao;
    TbColorNameEnDao *colorNameEnDao;
}

@end
