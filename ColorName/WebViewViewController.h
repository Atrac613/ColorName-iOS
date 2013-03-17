//
//  WebViewViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 10/21/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface WebViewViewController : GAITrackedViewController <UIWebViewDelegate> {
    IBOutlet UINavigationItem *navigationItem;
    IBOutlet UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)cancelButtonPressed;
- (void)rightButtonIsBusy;
- (void)rightButtonIsNormal;
- (void)leftButtonIsBusy;
- (void)leftButtonIsNormal;

@end
