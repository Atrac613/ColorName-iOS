//
//  FlipFromLeftSegue.m
//  ColorName
//
//  Created by Osamu Noguchi on 11/27/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "FlipFromLeftSegue.h"

@implementation FlipFromLeftSegue

- (void)perform {
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;

    [UIView transitionWithView:src.navigationController.view duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];
                    }
                    completion:NULL];
}

@end
