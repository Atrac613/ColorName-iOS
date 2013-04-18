//
//  ColorListCell.h
//  ColorName
//
//  Created by Osamu Noguchi on 7/31/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorImageView.h"

@interface ColorListCell : UITableViewCell {
    UILabel *colorNameLabel;
    UILabel *colorNameYomiLabel;
    ColorImageView *colorView;
}

@property (nonatomic, retain) UILabel *colorNameLabel;
@property (nonatomic, retain) UILabel *colorNameYomiLabel;
@property (nonatomic, retain) ColorImageView *colorView;

- (void)checkNameYomiLength;

@end
