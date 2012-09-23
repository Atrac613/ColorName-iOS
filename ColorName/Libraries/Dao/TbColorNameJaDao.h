//
//  TbColorNameJaDao.h
//  ColorName
//
//  Created by Osamu Noguchi on 9/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDao.h"

@interface TbColorNameJaDao : BaseDao {
    
}

- (void)createTable;
- (int)countAll;
- (int)countWithName:(NSString*)name nameYomi:(NSString*)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (void)insertWithName:(NSString*)name nameYomi:(NSString*)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (NSMutableArray*)findColorNameWithColor:(UIColor*)color;

@end
