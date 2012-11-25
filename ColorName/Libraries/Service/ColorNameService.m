//
//  ColorNameService.m
//  ColorName
//
//  Created by Osamu Noguchi on 11/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ColorNameService.h"
#import "JSON.h"

@implementation ColorNameService


- (id)getFavoriteColor {
    id resultArray = [[NSArray alloc] init];
    
    NSString *urlString;
    
    if (TARGET_IPHONE_SIMULATOR) {
        urlString = @"http://localhost:8093/api/v1/get_favorite_color";
    } else {
        urlString = @"https://color-name-app.appspot.com/api/v1/get_favorite_color";
    }
    
    NSString *jsonString = [self getJsonString:urlString];
    
    id statuseTmpArray = [jsonString JSONValue];
    if ([statuseTmpArray isKindOfClass:[NSArray class]]) {
        resultArray = statuseTmpArray;
    }
    
    jsonString = nil;
    statuseTmpArray = nil;
    
    return resultArray;
}

- (NSString *)getJsonString:(NSString *)urlString {
    NSLog(@"urlString: %@", urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"GET"];
    
    NSError *error    = nil;
    NSURLResponse *response = nil;
    
    NSData *contentData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *jsonString;
    
    int statusCode = [((NSHTTPURLResponse *)response) statusCode];
    if (statusCode == 420) {
        NSLog(@"Response Code: 420 Enhance Your Calm.");
        NSException *exception = [NSException exceptionWithName:@"Exception" reason:@"HttpResponseCode420" userInfo:nil];
        @throw exception;
    }
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        NSException *exception = [NSException exceptionWithName:@"Exception" reason:[error localizedDescription] userInfo:nil];
        @throw exception;
    } else {
        jsonString    = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
        
        NSLog(@"jsonString: %@", jsonString);
    }
    
    return jsonString;
}

@end
