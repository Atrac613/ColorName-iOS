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
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self rightButtonIsBusy];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self rightButtonIsNormal];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
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

- (void)leftButtonIsBusy {
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

- (void)rightButtonIsNormal {
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)leftButtonIsNormal {
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

@end
