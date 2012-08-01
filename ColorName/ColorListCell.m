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
@synthesize colorNameYomiLabel;
@synthesize colorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        colorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 7, 300, 20)];
        [colorNameLabel setTextColor:[UIColor blackColor]];
        [colorNameLabel setFont:[UIFont systemFontOfSize:20]];
        [colorNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:colorNameLabel];
        
        colorNameYomiLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, 300, 10)];
        [colorNameYomiLabel setTextColor:[UIColor blackColor]];
        [colorNameYomiLabel setFont:[UIFont systemFontOfSize:10]];
        [colorNameYomiLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:colorNameYomiLabel];
        
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
