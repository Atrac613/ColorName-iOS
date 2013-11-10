//
//  ColorDetailsViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TbColorNameJaDao.h"
#import "TbFavoriteColorNameDao.h"
#import "TbColorName.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface ColorDetailsViewController : UITableViewController {
    IBOutlet UILabel *colorNameLabel;
    IBOutlet UILabel *colorNameYomiLabel;
    IBOutlet UIView *colorView;
    IBOutlet UILabel *redLevelLabel;
    IBOutlet UILabel *greenLevelLabel;
    IBOutlet UILabel *blueLevelLabel;
    IBOutlet UIProgressView *redLevelBar;
    IBOutlet UIProgressView *greenLevelBar;
    IBOutlet UIProgressView *blueLevelBar;
    IBOutlet UILabel *cLevelLabel;
    IBOutlet UILabel *mLevelLabel;
    IBOutlet UILabel *yLevelLabel;
    IBOutlet UILabel *kLevelLabel;
    IBOutlet UIProgressView *cLevelBar;
    IBOutlet UIProgressView *mLevelBar;
    IBOutlet UIProgressView *yLevelBar;
    IBOutlet UIProgressView *kLevelBar;
    IBOutlet UILabel *hexLabel;
    IBOutlet UIButton *likeButton;
    IBOutlet UILabel *similarColorsLabel;
    IBOutlet UILabel *shareLabel;
    
    TbColorName *colorName;
    TbColorNameJaDao *colorNameJaDao;
    TbFavoriteColorNameDao *favoriteColorNameDao;
    
    UIColor *currentColor;
}

@property (nonatomic, strong) IBOutlet UILabel *colorNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *colorNameYomiLabel;
@property (nonatomic, strong) IBOutlet UIView *colorView;
@property (nonatomic, strong) IBOutlet UILabel *redLevelLabel;
@property (nonatomic, strong) IBOutlet UILabel *greenLevelLabel;
@property (nonatomic, strong) IBOutlet UILabel *blueLevelLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *redLevelBar;
@property (nonatomic, strong) IBOutlet UIProgressView *greenLevelBar;
@property (nonatomic, strong) IBOutlet UIProgressView *blueLevelBar;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *cLevelLabel;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *mLevelLabel;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *yLevelLabel;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *kLevelLabel;
@property (nonatomic, strong) IBOutlet IBOutlet UIProgressView *cLevelBar;
@property (nonatomic, strong) IBOutlet IBOutlet UIProgressView *mLevelBar;
@property (nonatomic, strong) IBOutlet IBOutlet UIProgressView *yLevelBar;
@property (nonatomic, strong) IBOutlet IBOutlet UIProgressView *kLevelBar;
@property (nonatomic, strong) IBOutlet UILabel *hexLabel;
@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) IBOutlet UILabel *similarColorsLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareLabel;
@property (nonatomic, strong) TbColorName *colorName;
@property (nonatomic, strong) TbColorNameJaDao *colorNameJaDao;
@property (nonatomic, strong) TbFavoriteColorNameDao *favoriteColorNameDao;
@property (nonatomic, strong) UIColor *currentColor;

@end
