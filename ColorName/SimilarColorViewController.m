//
//  SimilarColorViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 3/17/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import "SimilarColorViewController.h"

@interface SimilarColorViewController ()

@end

@implementation SimilarColorViewController

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
	
    [self.navigationItem setTitle:NSLocalizedString(@"SIMILAR_COLOR", @"")];
    
    [self getColorList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
