//
//  TbColorNameJa.m
//  ColorName
//
//  Created by Osamu Noguchi on 9/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "TbColorNameJa.h"

@implementation TbColorNameJa
@synthesize name;
@synthesize nameYomi;
@synthesize red;
@synthesize green;
@synthesize blue;

- (id)initWithIndex:(int)_index name:(NSString *)_name nameYomi:(NSString *)_nameYomi red:(NSInteger)_red green:(NSInteger)_green blue:(NSInteger)_blue {
    if (self = [super init]) {
        index = _index;
        self.name = _name;
        self.nameYomi = _nameYomi;
        self.red = _red;
        self.green = _green;
        self.blue = _blue;
    }
    
    return self;
}

@end
