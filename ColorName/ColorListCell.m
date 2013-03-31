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
        colorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 7, 245, 20)];
        [colorNameLabel setTextColor:[UIColor blackColor]];
        [colorNameLabel setFont:[UIFont systemFontOfSize:20]];
        [colorNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:colorNameLabel];
        
        colorNameYomiLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, 245, 10)];
        [colorNameYomiLabel setTextColor:[UIColor blackColor]];
        [colorNameYomiLabel setFont:[UIFont systemFontOfSize:10]];
        [colorNameYomiLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:colorNameYomiLabel];
        
        colorView = [[ColorImageView alloc] initWithFrame:CGRectMake(10, 7, 30, 30)];
        [self.contentView addSubview:colorView];
    }
    return self;
}

- (void)checkNameYomiLength {
    float width = 0;
    if (self.editing) {
        width = 45;
    }
    
    if ([colorNameYomiLabel.text length] > 0) {
        [colorNameLabel setFrame:CGRectMake(50, 7, 245 - width, 20)];
        [colorNameYomiLabel setFrame:CGRectMake(50, 30, 245 - width, 10)];
        [colorNameYomiLabel setHidden:NO];
    } else {
        [colorNameLabel setFrame:CGRectMake(50, 12, 245 - width, 20)];
        [colorNameYomiLabel setHidden:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self checkNameYomiLength];
    
    [UIView commitAnimations];
}

@end
