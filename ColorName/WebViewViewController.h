//
//  WebViewViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 10/21/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController<UIWebViewDelegate> {
    IBOutlet UINavigationItem *navigationItem;
    IBOutlet UIWebView *webView;
    
    BOOL signIn;
}

@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic) BOOL signIn;

@end
