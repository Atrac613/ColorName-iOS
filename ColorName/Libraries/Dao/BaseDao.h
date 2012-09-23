//
//  BaseDao.h
//  ColorName
//
//  Created by Osamu Noguchi on 9/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface BaseDao : NSObject {
    FMDatabase *db;
}

@property (strong, nonatomic) FMDatabase *db;

- (NSString*)setTable:(NSString*)sql;

@end
