//
//  ColorImageView.m
//  ColorName
//
//  Created by Osamu Noguchi on 3/31/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import "ColorImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColorImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setImageFromUIColor:(UIColor *)color {
    UIImage *colorImage = [self convertUIColorToUIImage:color];
    
    [self setImage:colorImage];
}

- (UIImage*)convertUIColorToUIImage:(UIColor*)color {
    CGRect screenRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, screenRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
