//
//  WebViewViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 10/21/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "WebViewViewController.h"
#import "AppDelegate.h"

@interface WebViewViewController ()

@end

@implementation WebViewViewController

@synthesize navigationItem;
@synthesize webView;
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
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)]];
    
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
            urlString = @"https://color-name-app.appspot.com/api/v1/logiut";
        }
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self rightButtonIsBusy];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self rightButtonIsNormal];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSURL *url = [request URL];

    if (signIn) {
        if ([[url path] isEqualToString:@"/login/successful"]) {
            appDelegate.isAuthenticated = YES;
            
            [self dismissModalViewControllerAnimated:YES];
            
            return NO;
        }
    } else {
        if ([[url path] isEqualToString:@"/logout/successful"]) {
            appDelegate.isAuthenticated = NO;
            
            [self dismissModalViewControllerAnimated:YES];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)rightButtonIsBusy {
    BOOL isBusy = NO;
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            isBusy = YES;
        }
    }
    
    if (isBusy == NO) {
        UIActivityIndicatorView *indicatorView;
        indicatorView = [[UIActivityIndicatorView alloc] init];
        [indicatorView setFrame:CGRectMake(275, 2, 40, 40)];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [indicatorView startAnimating];
        
        [self.view addSubview:indicatorView];
    }
}

- (void)rightButtonIsNormal {
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [view removeFromSuperview];
        }
    }
}

@end
