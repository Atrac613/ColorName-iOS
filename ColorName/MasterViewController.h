//
//  MasterViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MasterViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIView *previewView;
    IBOutlet UIView *colorView;
    IBOutlet UITableView *tableView;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    
    UIColor *currentColor;
    NSMutableArray *colorList;
}

@property (nonatomic, retain) IBOutlet UIView *previewView;
@property (nonatomic, retain) IBOutlet UIView *colorView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, retain) NSMutableArray *colorList;

@end
