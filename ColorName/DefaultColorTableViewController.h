//
//  DefaultColorTableViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 3/17/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TbColorNameJaDao.h"
#import "TbColorNameEnDao.h"
#import "GAITrackedViewController.h"

@interface DefaultColorTableViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    
    UIColor *currentColor;
    NSMutableArray *tableSectionArray;
    NSMutableArray *tableContentArray;
    
    TbColorNameJaDao *colorNameJaDao;
    TbColorNameEnDao *colorNameEnDao;
    
    BOOL isInitializing;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, retain) NSMutableArray *tableSectionArray;
@property (nonatomic, retain) NSMutableArray *tableContentArray;
@property (nonatomic, retain) TbColorNameJaDao *colorNameJaDao;
@property (nonatomic, retain) TbColorNameEnDao *colorNameEnDao;
@property (nonatomic) BOOL isInitializing;

- (void)getColorList;

@end
