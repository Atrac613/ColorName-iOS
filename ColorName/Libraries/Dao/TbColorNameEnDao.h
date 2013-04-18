//
//  TbColorNameEnDao.h
//  ColorName
//
//  Created by Osamu Noguchi on 10/8/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDao.h"
#import "TbColorName.h"

@interface TbColorNameEnDao : BaseDao {
    
}

- (void)createTable;
- (int)countAll;
- (int)countWithName:(NSString*)name red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (void)insertWithName:(NSString*)name red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (NSMutableArray*)findColorNameWithColor:(UIColor*)color;
- (NSMutableArray*)findColorNameWithColor:(UIColor*)color offset:(int)offset;
- (NSMutableArray*)findColorNameWithColor:(UIColor*)color difference:(int)difference;
- (TbColorName*)findColorNameWithColor:(UIColor*)color colorName:(NSString*)colorName;

@end