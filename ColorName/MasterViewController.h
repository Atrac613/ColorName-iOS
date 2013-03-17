//
//  MasterViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DefaultColorTableViewController.h"

@interface MasterViewController : DefaultColorTableViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate> {
    IBOutlet UIView *previewView;
    IBOutlet UIView *colorView;
    IBOutlet UIButton *stateButton;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    NSTimer *timer;
    
    NSString *alertMode;
    
    BOOL isPlay;
}

@property (nonatomic, retain) IBOutlet UIView *previewView;
@property (nonatomic, retain) IBOutlet UIView *colorView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *stateButton;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSString *alertMode;
@property (nonatomic) BOOL isPlay;

@end
