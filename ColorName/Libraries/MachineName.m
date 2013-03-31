//
//  MachineName.m
//  ColorName
//
//  Created by Osamu Noguchi on 4/1/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//
//  Thanks: http://stackoverflow.com/questions/1108859/detect-the-specific-iphone-ipod-touch-model
//

#import "MachineName.h"
#import <sys/utsname.h>

@implementation MachineName

/***
 * return examples:
 *
 * @"i386"      on the simulator
 * @"iPod1,1"   on iPod Touch
 * @"iPod2,1"   on iPod Touch Second Generation
 * @"iPod3,1"   on iPod Touch Third Generation
 * @"iPod4,1"   on iPod Touch Fourth Generation
 * @"iPhone1,1" on iPhone
 * @"iPhone1,2" on iPhone 3G
 * @"iPhone2,1" on iPhone 3GS
 * @"iPad1,1"   on iPad
 * @"iPad2,1"   on iPad 2
 * @"iPad3,1"   on iPad 3 (aka new iPad)
 * @"iPhone3,1" on iPhone 4
 * @"iPhone4,1" on iPhone 4S
 * @"iPhone5,1" on iPhone 5
 * @"iPhone5,2" on iPhone 5
 ***/

- (NSString*)machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}



@end
