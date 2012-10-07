//
//  TbColorNameJaDao.m
//  ColorName
//
//  Created by Osamu Noguchi on 9/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "TbColorNameJaDao.h"
#import "TbColorName.h"

@implementation TbColorNameJaDao

- (NSString*)setTable:(NSString *)sql {
    return [NSString stringWithFormat:sql, @"color_name_ja"];
}

- (void)createTable {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [db executeUpdate:[self setTable:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, name_yomi TEXT, red INTEGER, green INTEGER, blue INTEGER);"]];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (int)countAll {
    NSLog(@"%@", NSStringFromSelector(_cmd));
          
    int count = 0;
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT count(*) FROM %@"]];
    
    while([resultSet next]){
        count = [[resultSet stringForColumn:@"count(*)"] intValue];
    }
    
    [resultSet close];
    
    return count;
}

- (int)countWithName:(NSString *)name nameYomi:(NSString *)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    int count = 0;
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT count(*) FROM %@ WHERE name = ? AND name_yomi = ? AND red = ? AND green = ? AND blue = ?;"], name, nameYomi, [NSNumber numberWithInteger:red], [NSNumber numberWithInteger:green], [NSNumber numberWithInteger:blue]];
    
    while([resultSet next]){
        count = [[resultSet stringForColumn:@"count(*)"] intValue];
    }
    
    [resultSet close];
    
    return count;
}

- (void)insertWithName:(NSString *)name nameYomi:(NSString *)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [db executeUpdate:[self setTable:@"INSERT INTO %@ (name, name_yomi, red, green, blue) VALUES (?, ?, ?, ?, ?)"], name, nameYomi, [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue]];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (NSMutableArray*)findColorNameWithColor:(UIColor *)color {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:0];
    
    const CGFloat *rgba = CGColorGetComponents(color.CGColor);
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT id, name, name_yomi, red, green, blue, (pow((?-red), 2) + pow((?-green), 2) + pow((?-blue), 2)) as difference FROM %@ ORDER BY difference;"], [NSNumber numberWithFloat:rgba[0] * 255], [NSNumber numberWithFloat:rgba[1] * 255], [NSNumber numberWithFloat:rgba[2] * 255]];
    
    while([resultSet next]){
        if ([resultSet intForColumn:@"difference"] < 2000) {
            TbColorName *result = [[TbColorName alloc] initWithIndex:[resultSet intForColumn:@"id"] name:[resultSet stringForColumn:@"name"] nameYomi:[resultSet stringForColumn:@"name_yomi"] red:[resultSet intForColumn:@"red"] green:[resultSet intForColumn:@"green"] blue:[resultSet intForColumn:@"blue"] langage:@"ja_JP"];
            [results addObject:result];
        }
    }
    
    [resultSet close];
    
    return results;
}

- (TbColorName*)findColorNameWithColor:(UIColor *)color colorName:(NSString *)colorName {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    TbColorName *result;
    
    const CGFloat *rgba = CGColorGetComponents(color.CGColor);
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT id, name, name_yomi, red, green, blue, (pow((?-red), 2) + pow((?-green), 2) + pow((?-blue), 2)) as difference FROM %@  WHERE name = ? ORDER BY difference;"], [NSNumber numberWithFloat:rgba[0] * 255], [NSNumber numberWithFloat:rgba[1] * 255], [NSNumber numberWithFloat:rgba[2] * 255], colorName];
    
    while([resultSet next]){
        if ([resultSet intForColumn:@"difference"] < 2000) {
            result = [[TbColorName alloc] initWithIndex:[resultSet intForColumn:@"id"] name:[resultSet stringForColumn:@"name"] nameYomi:[resultSet stringForColumn:@"name_yomi"] red:[resultSet intForColumn:@"red"] green:[resultSet intForColumn:@"green"] blue:[resultSet intForColumn:@"blue"] langage:@"ja_JP"];
        }
    }
    
    [resultSet close];
    
    return result;
}

@end
