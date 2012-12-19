//
//  AboutViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 11/29/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AboutViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
