//
//  AuthViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 11/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "AuthViewController.h"
#import "AppDelegate.h"

@interface AuthViewController ()

@end

@implementation AuthViewController

@synthesize signIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setTitle:@"Authentication"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *urlString;
    if (signIn) {
        if (TARGET_IPHONE_SIMULATOR) {
            urlString = @"http://localhost:8093/api/v1/login";
        } else {
            urlString = @"https://color-name-app.appspot.com/api/v1/login";
        }
    } else {
        if (TARGET_IPHONE_SIMULATOR) {
            urlString = @"http://localhost:8093/api/v1/logout";
        } else {
            urlString = @"https://color-name-app.appspot.com/api/v1/logout";
        }
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSURL *url = [request URL];
    
    if (signIn) {
        if ([[url path] isEqualToString:@"/login/successful"]) {
            appDelegate.isAuthenticated = YES;
            
            [self performSelector:@selector(cancelButtonPressed) withObject:nil afterDelay:1.f];
            
            return NO;
        }
    } else {
        if ([[url path] isEqualToString:@"/logout/successful"]) {
            appDelegate.isAuthenticated = NO;
            
            [self performSelector:@selector(cancelButtonPressed) withObject:nil afterDelay:1.f];
            
            return NO;
        }
    }
    
    return YES;
}

@end
