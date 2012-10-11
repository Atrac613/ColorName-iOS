//
//  FavoritesColorViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TbFavoriteColorNameDao.h"

@interface FavoritesColorViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    
    NSMutableArray *colorList;
    NSMutableData *httpResponseData;
    
    TbFavoriteColorNameDao *favoriteColorNameDao;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *colorList;
@property (nonatomic, retain) NSMutableData *httpResponseData;
@property (nonatomic, strong) TbFavoriteColorNameDao *favoriteColorNameDao;

- (IBAction)syncButtonPressed:(id)sender;

@end
