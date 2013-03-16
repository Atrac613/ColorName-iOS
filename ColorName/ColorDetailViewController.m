//
//  ColorDetailViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ColorDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TbColorName.h"
#import "LINEActivity.h"
#import "AppDelegate.h"
#import "SimilarColorViewController.h"

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
@synthesize similarColorButton;
@synthesize shareButton;
@synthesize colorName;
@synthesize colorNameJaDao;
@synthesize favoriteColorNameDao;
@synthesize currentColor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // for Google Analytics
    self.trackedViewName = NSStringFromClass([self class]);
    
    [self.navigationItem setTitle:NSLocalizedString(@"DETAIL", @"")];
    
    colorNameJaDao = [[TbColorNameJaDao alloc] init];
    favoriteColorNameDao = [[TbFavoriteColorNameDao alloc] init];
    
    [favoriteColorNameDao createTable];
	
    float red = [colorName red] / 255.f;
    float green = [colorName green] / 255.f;
    float blue = [colorName blue] / 255.f;
    
    currentColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
    [colorView setBackgroundColor:currentColor];
    
    [colorNameLabel setText:colorName.name];
    [colorNameLabel setAdjustsFontSizeToFitWidth:YES];
    [colorNameYomiLabel setText:colorName.nameYomi];
    [colorNameYomiLabel setAdjustsFontSizeToFitWidth:YES];
    
    [redLevelLabel setText:[NSString stringWithFormat:@"%d", colorName.red]];
    [greenLevelLabel setText:[NSString stringWithFormat:@"%d", colorName.green]];
    [blueLevelLabel setText:[NSString stringWithFormat:@"%d", colorName.blue]];
    
    [redLevelBar setProgress:red];
    [greenLevelBar setProgress:green];
    [blueLevelBar setProgress:blue];
    
    [hexLabel setText:[NSString stringWithFormat:@"#%02x%02x%02x", [colorName red], [colorName green], [colorName blue]]];
    
    [similarColorButton setTitle:NSLocalizedString(@"SIMILAR_COLOR", @"") forState:UIControlStateNormal];
    [shareButton setTitle:NSLocalizedString(@"SHARE", @"") forState:UIControlStateNormal];
    
    [self checkLikeButtonState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)likeButtonPressed:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        likeButton.highlighted = YES;
    }];
    
    if ([favoriteColorNameDao countWithColorName:colorName] <= 0) {
        [favoriteColorNameDao insertWithColorName:colorName];
    } else {
        [favoriteColorNameDao removeFromColorName:colorName];
    }
    
    [self performSelector:@selector(checkLikeButtonState) withObject:nil afterDelay:0.f];
}

- (void)checkLikeButtonState {
    if ([favoriteColorNameDao countWithColorName:colorName] > 0) {
        [likeButton setTitle:@"Liked" forState:UIControlStateNormal];
        [likeButton setHighlighted:YES];
        
        [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"liked" withValue:nil];
    } else {
        [likeButton setTitle:@"Like" forState:UIControlStateNormal];
        [likeButton setHighlighted:NO];
        
        [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"like" withValue:nil];
    }
}

- (IBAction)similarColorButtonPressed:(id)sender {
    [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"similarColor" withValue:nil];
    
    SimilarColorViewController *similarColorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SimilarColorViewController"];
    similarColorViewController.currentColor = currentColor;
    [self.navigationController pushViewController:similarColorViewController animated:YES];
}

- (IBAction)shareButtonPressed:(id)sender {
    [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"share" withValue:nil];
    
    NSString *message;
    
    if (colorNameYomiLabel.text.length > 0) {
        message = [NSString stringWithFormat:@"%@(%@) %@ R:%@ G:%@ B:%@", colorNameLabel.text, colorNameYomiLabel.text, hexLabel.text, redLevelLabel.text, greenLevelLabel.text, blueLevelLabel.text];
    } else {
        message = [NSString stringWithFormat:@"%@ %@ R:%@ G:%@ B:%@", colorNameLabel.text, hexLabel.text, redLevelLabel.text, greenLevelLabel.text, blueLevelLabel.text];
    }
    
    NSString *appStoreUrl;
    NSString *lang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    if ([lang isEqualToString:@"ja"]) {
        appStoreUrl = @"https://itunes.apple.com/jp/app/colorname*/id584817516?mt=8";
    } else {
        appStoreUrl = @"https://itunes.apple.com/app/colorname*/id584817516?mt=8";
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"enabled_suffix"]) {
        message = [NSString stringWithFormat:@"%@ via ColorName* %@", message, appStoreUrl];
    }
    
    [self openInOtherApps:message];
}

#pragma mark - UIActivityViewController

- (void)openInOtherApps:(NSString*)message {
    NSArray *actItems;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"enabled_attachment"]) {
        UIImage *canvasImage = [self convertColorViewToUIImage];
        actItems = [NSArray arrayWithObjects:UIImagePNGRepresentation(canvasImage), message, nil];
    } else {
        actItems = [NSArray arrayWithObjects:message, nil];
    }
    
    NSArray *applicationActivities = @[[[LINEActivity alloc] init]];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:applicationActivities];
    activityView.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    
    activityView.completionHandler = ^(NSString *activityType, BOOL completed){
        NSLog(@"Activity Type: %@", activityType);
        
        [SharedAppDelegate.tracker sendEventWithCategory:@"uiActivity" withAction:@"buttonPress" withLabel:activityType withValue:nil];
        
        if (completed) {
            NSLog(@"Done.");
        } else {
            NSLog(@"Failed.");
            
            LINEActivity *lineActivity = [[LINEActivity alloc] init];
            if ([activityType isEqualToString:[lineActivity activityType]]) {
                NSString *shortMessage;

                if (colorNameYomiLabel.text.length > 0) {
                    shortMessage = [NSString stringWithFormat:@"%@(%@) - %@", colorNameLabel.text, colorNameYomiLabel.text, hexLabel.text];
                } else {
                    shortMessage = [NSString stringWithFormat:@"%@ - %@", colorNameLabel.text, hexLabel.text];
                }
                
                shortMessage = [shortMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [lineActivity openLINEWithItem:shortMessage];
            }
        }
        
    };
    
    [self presentViewController:activityView animated:YES completion:nil];
}

#pragma mark - Other

- (UIImage*)convertColorViewToUIImage {
    CGRect screenRect = CGRectMake(0, 0, 300.f, 300.f);
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [colorView.backgroundColor set];
    CGContextFillRect(ctx, screenRect);
    
    [colorView.layer renderInContext:ctx];
    
    UIImage *convertImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return convertImage;
}

@end
