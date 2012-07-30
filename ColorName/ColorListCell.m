//
//  ColorListCell.m
//  ColorName
//
//  Created by Osamu Noguchi on 7/31/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ColorListCell.h"

@implementation ColorListCell
@synthesize colorNameLabel;
@synthesize colorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        colorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 7, 300, 30)];
        [colorNameLabel setTextColor:[UIColor blackColor]];
        [colorNameLabel setFont:[UIFont systemFontOfSize:24]];
        [colorNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:colorNameLabel];
        
        colorView = [[UIView alloc] initWithFrame:CGRectMake(10, 7, 30, 30)];
        [self.contentView addSubview:colorView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
