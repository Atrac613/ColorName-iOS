//
//  MasterViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TbColorNameJaDao.h"

@interface MasterViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIView *previewView;
    IBOutlet UIView *colorView;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *stateButton;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    NSTimer *timer;
    
    UIColor *currentColor;
    NSMutableArray *colorList;
    
    BOOL isPlay;
    
    TbColorNameJaDao *colorNameJaDao;
}

@property (nonatomic, retain) IBOutlet UIView *previewView;
@property (nonatomic, retain) IBOutlet UIView *colorView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *stateButton;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, retain) NSMutableArray *colorList;
@property (nonatomic) BOOL isPlay;
@property (nonatomic, retain) TbColorNameJaDao *colorNameJaDao;

@end
