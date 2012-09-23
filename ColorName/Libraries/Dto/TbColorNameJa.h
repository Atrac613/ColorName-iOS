//
//  TbColorNameJa.h
//  ColorName
//
//  Created by Osamu Noguchi on 9/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TbColorNameJa : NSObject {
    int index;
    NSString *name;
    NSString *nameYomi;
    NSInteger red;
    NSInteger green;
    NSInteger blue;
}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *nameYomi;
@property (nonatomic) NSInteger red;
@property (nonatomic) NSInteger green;
@property (nonatomic) NSInteger blue;

- (id)initWithIndex:(int)_index name:(NSString*)_name nameYomi:(NSString*)_nameYomi red:(NSInteger)_red green:(NSInteger)_green blue:(NSInteger)_blue;

@end
