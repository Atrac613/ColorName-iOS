//
//  TbFavoriteColorNameDao.m
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "TbFavoriteColorNameDao.h"
#import "TbColorName.h"

@implementation TbFavoriteColorNameDao

- (NSString*)setTable:(NSString *)sql {
    return [NSString stringWithFormat:sql, @"favorite_color_name"];
}

- (void)createTable {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [db executeUpdate:[self setTable:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, name_yomi TEXT, red INTEGER, green INTEGER, blue INTEGER, rank INTEGER, language TEXT);"]];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (int)countAll {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    int count = 0;
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT count(*) FROM %@"]];
    
    while([resultSet next]){
        count = [[resultSet stringForColumn:@"count(*)"] intValue];
    }
    
    [resultSet close];
    
    return count;
}

- (void)sortAll {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT id, rank FROM %@ ORDER BY rank"]];
    
    int rank = 0;
    while([resultSet next]){
        [db executeUpdate:[self setTable:@"UPDATE %@ SET rank = ? WHERE id = ?"], [NSNumber numberWithInt:rank], [NSNumber numberWithInt:[resultSet intForColumn:@"id"]]];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        rank++;
    }
    
    [resultSet close];
}

- (void)updateRank:(int)rank favorite_id:(int)favorite_id {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [db executeUpdate:[self setTable:@"UPDATE %@ SET rank = ? WHERE id = ?"], [NSNumber numberWithInt:rank], [NSNumber numberWithInt:favorite_id]];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (int)countWithColorName:(TbColorName *)colorName {
    return [self countWithName:colorName.name nameYomi:colorName.nameYomi red:colorName.red green:colorName.green blue:colorName.blue];
}

- (int)countWithName:(NSString *)name nameYomi:(NSString *)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    int count = 0;
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT count(*) FROM %@ WHERE name = ? AND name_yomi = ? AND red = ? AND green = ? AND blue = ?;"], name, nameYomi, [NSNumber numberWithInteger:red], [NSNumber numberWithInteger:green], [NSNumber numberWithInteger:blue]];
    
    while([resultSet next]){
        count = [[resultSet stringForColumn:@"count(*)"] intValue];
    }
    
    [resultSet close];
    
    return count;
}

- (void)insertWithName:(NSString *)name nameYomi:(NSString *)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self insertWithName:name nameYomi:nameYomi red:red green:green blue:blue rank:0];
}

- (void)insertWithName:(NSString *)name nameYomi:(NSString *)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue rank:(NSInteger)rank {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (!rank || rank == 0) {
        [self sortAll];
        rank = [self countAll] + 1;
    }
    
    [db executeUpdate:[self setTable:@"INSERT INTO %@ (name, name_yomi, red, green, blue, rank) VALUES (?, ?, ?, ?, ?, ?)"], name, nameYomi, [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], [NSNumber numberWithInt:rank]];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (void)insertWithColorName:(TbColorName *)colorName {
    [self insertWithName:colorName.name nameYomi:colorName.nameYomi red:colorName.red green:colorName.green blue:colorName.blue];
}

- (void)removeFromName:(NSString *)name nameYomi:(NSString *)nameYomi red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE name = ? AND name_yomi = ? AND red = ? AND green = ? AND blue = ?"], name, nameYomi, [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue]];
    
    [self sortAll];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (void)removeFromColorName:(TbColorName *)colorName {
    [self removeFromName:colorName.name nameYomi:colorName.nameYomi red:colorName.red green:colorName.green blue:colorName.blue];
}

- (void)removeFromId:(int)favorite_id {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE id = ?"], [NSNumber numberWithInt:favorite_id]];
    
    [self sortAll];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (NSMutableArray*)findColorNameWithColor:(UIColor *)color {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:0];
    
    const CGFloat *rgba = CGColorGetComponents(color.CGColor);
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT id, name, name_yomi, red, green, blue, language, (pow((?-red), 2) + pow((?-green), 2) + pow((?-blue), 2)) as difference FROM %@ ORDER BY difference;"], [NSNumber numberWithFloat:rgba[0] * 255], [NSNumber numberWithFloat:rgba[1] * 255], [NSNumber numberWithFloat:rgba[2] * 255]];
    
    while([resultSet next]){
        if ([resultSet intForColumn:@"difference"] < 2000) {
            TbColorName *result = [[TbColorName alloc] initWithIndex:[resultSet intForColumn:@"id"] name:[resultSet stringForColumn:@"name"] nameYomi:[resultSet stringForColumn:@"name_yomi"] red:[resultSet intForColumn:@"red"] green:[resultSet intForColumn:@"green"] blue:[resultSet intForColumn:@"blue"] language:[resultSet stringForColumn:@"language"]];
            [results addObject:result];
        }
    }
    
    [resultSet close];
    
    return results;
}

- (NSMutableArray*)getAll {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:0];
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT id, name, name_yomi, red, green, blue, rank, language FROM %@ ORDER BY rank;"]];
    
    while([resultSet next]){
        TbColorName *result = [[TbColorName alloc] initWithIndex:[resultSet intForColumn:@"id"] name:[resultSet stringForColumn:@"name"] nameYomi:[resultSet stringForColumn:@"name_yomi"] red:[resultSet intForColumn:@"red"] green:[resultSet intForColumn:@"green"] blue:[resultSet intForColumn:@"blue"] language:[resultSet stringForColumn:@"language"]];
        [results addObject:result];
    }
    
    [resultSet close];
    
    return results;
}

- (TbColorName*)findColorNameWithColor:(UIColor *)color colorName:(NSString *)colorName {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    TbColorName *result;
    
    const CGFloat *rgba = CGColorGetComponents(color.CGColor);
    
    FMResultSet *resultSet = [db executeQuery:[self setTable:@"SELECT id, name, name_yomi, red, green, blue, language, (pow((?-red), 2) + pow((?-green), 2) + pow((?-blue), 2)) as difference FROM %@  WHERE name = ? ORDER BY difference;"], [NSNumber numberWithFloat:rgba[0] * 255], [NSNumber numberWithFloat:rgba[1] * 255], [NSNumber numberWithFloat:rgba[2] * 255], colorName];
    
    while([resultSet next]){
        if ([resultSet intForColumn:@"difference"] < 2000) {
            result = [[TbColorName alloc] initWithIndex:[resultSet intForColumn:@"id"] name:[resultSet stringForColumn:@"name"] nameYomi:[resultSet stringForColumn:@"name_yomi"] red:[resultSet intForColumn:@"red"] green:[resultSet intForColumn:@"green"] blue:[resultSet intForColumn:@"blue"] language:[resultSet stringForColumn:@"language"]];
        }
    }
    
    [resultSet close];
    
    return result;
}

@end
