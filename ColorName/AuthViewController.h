//
//  AuthViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 11/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "WebViewViewController.h"

@interface AuthViewController : WebViewViewController {
    BOOL signIn;
}

@property (nonatomic) BOOL signIn;

@end
