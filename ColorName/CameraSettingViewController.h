//
//  CameraSettingViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 4/1/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface CameraSettingViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
