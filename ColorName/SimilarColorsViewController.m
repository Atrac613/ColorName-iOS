//
//  SimilarColorsViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 3/17/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import "SimilarColorsViewController.h"

@interface SimilarColorsViewController ()

@end

@implementation SimilarColorsViewController

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
	
    [self.navigationItem setTitle:NSLocalizedString(@"SIMILAR_COLORS", @"")];
    
    [self getColorList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
