//
//  TbFavoriteColorNameDao.h
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDao.h"
#import "TbColorName.h"

@interface TbFavoriteColorNameDao : BaseDao {
    
}

- (void)createTable;
- (int)countAll;
- (NSMutableArray*)getAll;
- (void)sortAll;
- (void)updateRank:(int)rank favorite_id:(int)favorite_id;
- (int)countWithName:(NSString*)name nameYomi:(NSString*)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (void)insertWithName:(NSString*)name nameYomi:(NSString*)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (void)insertWithName:(NSString *)name nameYomi:(NSString *)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue rank:(NSInteger)rank;
- (void)removeFromId:(int)favorite_id;
- (void)removeFromName:(NSString*)name nameYomi:(NSString*)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (NSMutableArray*)findColorNameWithColor:(UIColor*)color;
- (TbColorName*)findColorNameWithColor:(UIColor*)color colorName:(NSString*)colorName;

@end
