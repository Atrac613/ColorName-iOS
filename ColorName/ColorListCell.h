//
//  ColorListCell.h
//  ColorName
//
//  Created by Osamu Noguchi on 7/31/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorListCell : UITableViewCell {
    UILabel *colorNameLabel;
    UILabel *colorNameYomiLabel;
    UIView *colorView;
}

@property (nonatomic, retain) UILabel *colorNameLabel;
@property (nonatomic, retain) UILabel *colorNameYomiLabel;
@property (nonatomic, retain) UIView *colorView;

@end
