//
//  FavoritesColorViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TbFavoriteColorNameDao.h"

@interface FavoritesColorViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    IBOutlet UITableView *tableView;
    IBOutlet UIBarButtonItem *syncButton;
    IBOutlet UIToolbar *toolBar;
    
    NSMutableArray *colorList;
    NSArray *remoteColorList;
    NSMutableArray *addedColorNameList;
    
    NSURLConnection *connection;
    NSMutableData *httpResponseData;
    
    NSString *alertMode;
    
    TbFavoriteColorNameDao *favoriteColorNameDao;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *syncButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) NSMutableArray *colorList;
@property (nonatomic, retain) NSArray *remoteColorList;
@property (nonatomic, retain) NSMutableArray *addedColorNameList;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *httpResponseData;
@property (nonatomic, retain) NSString *alertMode;
@property (nonatomic, strong) TbFavoriteColorNameDao *favoriteColorNameDao;

- (IBAction)syncButtonPressed:(id)sender;

@end
