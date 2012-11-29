//
//  FlipFromRightSegue.m
//  ColorName
//
//  Created by Osamu Noguchi on 11/29/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "FlipFromRightSegue.h"

@implementation FlipFromRightSegue

- (void)perform {
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    [UIView transitionWithView:src.navigationController.view duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];
                    }
                    completion:NULL];
}


@end
