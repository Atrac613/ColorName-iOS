//
//  ColorDetailViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ColorDetailViewController.h"
#import "TbColorName.h"

@interface ColorDetailViewController ()

@end

@implementation ColorDetailViewController

@synthesize colorNameLabel;
@synthesize colorNameYomiLabel;
@synthesize colorView;
@synthesize redLevelLabel;
@synthesize greenLevelLabel;
@synthesize blueLevelLabel;
@synthesize redLevelBar;
@synthesize greenLevelBar;
@synthesize blueLevelBar;
@synthesize hexLabel;
@synthesize likeButton;
@synthesize colorName;
@synthesize colorNameJaDao;
@synthesize favoriteColorNameDao;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Detail"];
    
    colorNameJaDao = [[TbColorNameJaDao alloc] init];
    favoriteColorNameDao = [[TbFavoriteColorNameDao alloc] init];
    
    [favoriteColorNameDao createTable];
	
    float red = [colorName red] / 255.f;
    float green = [colorName green] / 255.f;
    float blue = [colorName blue] / 255.f;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
    [colorView setBackgroundColor:color];
    
    [colorNameLabel setText:colorName.name];
    [colorNameYomiLabel setText:colorName.nameYomi];
    
    [redLevelLabel setText:[NSString stringWithFormat:@"%d", colorName.red]];
    [greenLevelLabel setText:[NSString stringWithFormat:@"%d", colorName.green]];
    [blueLevelLabel setText:[NSString stringWithFormat:@"%d", colorName.blue]];
    
    [redLevelBar setProgress:red];
    [greenLevelBar setProgress:green];
    [blueLevelBar setProgress:blue];
    
    [hexLabel setText:[NSString stringWithFormat:@"#%02x%02x%02x", [colorName red], [colorName green], [colorName blue]]];
    
    [self checkLikeButtonState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)likeButtonPressed:(id)sender {
    if ([favoriteColorNameDao countWithName:colorName.name nameYomi:colorName.nameYomi red:colorName.red green:colorName.green blue:colorName.blue] <= 0) {
        [favoriteColorNameDao insertWithName:colorName.name nameYomi:colorName.nameYomi red:colorName.red green:colorName.green blue:colorName.blue];
        
    } else {
        [favoriteColorNameDao removeFromId:colorName.index];
    }
    
    [self performSelector:@selector(checkLikeButtonState) withObject:nil afterDelay:0.1f];
}

- (void)checkLikeButtonState {
    if ([favoriteColorNameDao countWithName:colorName.name nameYomi:colorName.nameYomi red:colorName.red green:colorName.green blue:colorName.blue] > 0) {
        [likeButton setHighlighted:YES];
    } else {
        [likeButton setHighlighted:NO];
    }
}

@end
