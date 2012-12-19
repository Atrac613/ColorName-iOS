//
//  MasterViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "MasterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "FMDatabase.h"
#import "JSON.h"
#import "UIColor_Categories.h"
#import "ColorListCell.h"
#import "TbColorName.h"
#import "ColorDetailViewController.h"
#import "FavoritesColorViewController.h"
#import "SVProgressHUD.h"
#import "AboutViewController.h"
#import "GAI.h"

@interface MasterViewController () {
}
@end

@implementation MasterViewController
@synthesize previewLayer;
@synthesize previewView;
@synthesize colorView;
@synthesize currentColor;
@synthesize tableView;
@synthesize stateButton;
@synthesize session;
@synthesize timer;
@synthesize colorNameJaDao;
@synthesize colorNameEnDao;
@synthesize tableSectionArray;
@synthesize tableContentArray;
@synthesize alertMode;
@synthesize isPlay;
@synthesize isInitializing;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // for Google Analytics
    self.trackedViewName = NSStringFromClass([self class]);
    
    [self.navigationItem setTitle:NSLocalizedString(@"COLORNAME", @"")];
    
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [aboutButton addTarget:self action:@selector(aboutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame = aboutButton.frame;
    [aboutButton setFrame:CGRectMake(frame.origin.x, frame.origin.y, 40, frame.size.height)];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:aboutButton]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FAVORITES", @"") style:UIBarButtonItemStylePlain target:self action:@selector(favoritesColorButtonPressed)]];
    
    isPlay = YES;
    isInitializing = NO;
    
    colorNameJaDao = [[TbColorNameJaDao alloc] init];
    colorNameEnDao = [[TbColorNameEnDao alloc] init];
    
    tableSectionArray = [[NSMutableArray alloc] init];
    tableContentArray = [[NSMutableArray alloc] init];
    
    [self performSelectorInBackground:@selector(operationInitializationTask) withObject:nil];
    
    [self setupAVCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self videoController:!isPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self videoController:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBActions

- (IBAction)stateButtonPressed:(id)sender {
    [self videoController:isPlay];
}

- (void)favoritesColorButtonPressed {
    FavoritesColorViewController *favoritesColorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesColorViewController"];
    [self.navigationController pushViewController:favoritesColorViewController animated:YES];
}

- (void)aboutButtonPressed {
    [self performSegueWithIdentifier:@"AboutViewFromMasterView" sender:self];
}

#pragma mark - Background Task

- (void)showInitializingProgressView {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"INITIALIZING", @"")];
    
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)hideInitializingProgressView {
    [SVProgressHUD dismiss];
    
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)operationInitializationTask {
    [self createDB];
    
    if ([colorNameJaDao countAll] <= 0 || [colorNameEnDao countAll] <= 0) {
        [self performSelectorOnMainThread:@selector(showInitializingProgressView) withObject:nil waitUntilDone:NO];
        
        isInitializing = YES;
    }
    
    [self initDBJa];
    [self initDBEn];
    
    [self performSelectorOnMainThread:@selector(completeInitializationTask) withObject:nil waitUntilDone:NO];
}

- (void)completeInitializationTask {
    isInitializing = NO;
    
    [self hideInitializingProgressView];
    
    [self showUsageStatisticsPermissionAlert:NO];
}

- (void)createDB {
    [colorNameJaDao createTable];
    [colorNameEnDao createTable];
}

- (void)initDBJa {
    if ([colorNameJaDao countAll] > 0) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"color_names_ja" ofType:@"json"]];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [jsonString JSONValue];
    
    for (int i = 0; i < [jsonArray count]; i++) {
        NSDictionary *dict = [jsonArray objectAtIndex:i];
        NSString *name = [dict valueForKey:@"kanji"];
        NSString *nameYomi = [dict valueForKey:@"yomi"];
        NSString *hex = [dict valueForKey:@"hex"];
        
        UIColor *color = [UIColor colorWithHexString:hex];
        const CGFloat *rgba = CGColorGetComponents(color.CGColor);
        
        if ([colorNameJaDao countWithName:name nameYomi:nameYomi red:rgba[0] * 255 green:rgba[1] * 255 blue:rgba[2] * 255] == 0) {
            [colorNameJaDao insertWithName:name nameYomi:nameYomi red:rgba[0] * 255 green:rgba[1] * 255 blue:rgba[2] * 255];
        }
    }
}

- (void)initDBEn {
    if ([colorNameEnDao countAll] > 0) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"color_names_us" ofType:@"json"]];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [jsonString JSONValue];
    
    for (int i = 0; i < [jsonArray count]; i++) {
        NSDictionary *dict = [jsonArray objectAtIndex:i];
        NSString *name = [dict valueForKey:@"name"];
        NSString *hex = [dict valueForKey:@"hex"];
        
        UIColor *color = [UIColor colorWithHexString:hex];
        const CGFloat *rgba = CGColorGetComponents(color.CGColor);
        
        if ([colorNameEnDao countWithName:name red:rgba[0] * 255 green:rgba[1] * 255 blue:rgba[2] * 255] == 0) {
            [colorNameEnDao insertWithName:name red:rgba[0] * 255 green:rgba[1] * 255 blue:rgba[2] * 255];
        }
    }
}

- (void)getColorList {
    if (!currentColor || isInitializing) {
        return;
    }

    tableSectionArray = [[NSMutableArray alloc] init];
    tableContentArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"enabled_lang_japanese"] || [defaults boolForKey:@"enabled_lang_english"]) {
        NSString *lang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
        
        if ([lang isEqualToString:@"ja"]) {
            if ([defaults boolForKey:@"enabled_lang_japanese"]) {
                [tableSectionArray addObject:NSLocalizedString(@"JAPANESE", @"")];
                [tableContentArray addObject:[colorNameJaDao findColorNameWithColor:currentColor]];
            }
            
            if ([defaults boolForKey:@"enabled_lang_english"]) {
                [tableSectionArray addObject:NSLocalizedString(@"ENGLISH", @"")];
                [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor]];
            }
        } else {
            if ([defaults boolForKey:@"enabled_lang_english"]) {
                [tableSectionArray addObject:NSLocalizedString(@"ENGLISH", @"")];
                [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor]];
            }
            
            if ([defaults boolForKey:@"enabled_lang_japanese"]) {
                [tableSectionArray addObject:NSLocalizedString(@"JAPANESE", @"")];
                [tableContentArray addObject:[colorNameJaDao findColorNameWithColor:currentColor]];
            }
        }
    } else {
        [tableSectionArray addObject:NSLocalizedString(@"ENGLISH", @"")];
        [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor]];
    }
    
    [tableView reloadData];
}

- (void)setupAVCapture
{
    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetLow];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.videoSettings = settings;
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:dataOutput];
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    [session startRunning];
}

- (void)getCenterColor:(UIImage*)image {
    UIColor *color = [self getRGBPixelColorAtPoint:image point:CGPointMake(image.size.height/2, image.size.width/2)];
    
    if (!color) {
        return;
    }
    
    [colorView setBackgroundColor:color];
    
    currentColor = color;
}

- (UIColor*)getRGBPixelColorAtPoint:(UIImage*)image point:(CGPoint)point {
    UIColor* color = nil;
    
    CGImageRef cgImage = [image CGImage];
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    NSUInteger x = (NSUInteger)floor(point.x);
    NSUInteger y = (NSUInteger)floor(point.y);
    
    if ((x < width) && (y < height))
    {
        CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
        CFDataRef bitmapData = CGDataProviderCopyData(provider);
        const UInt8 *data = CFDataGetBytePtr(bitmapData);
        size_t offset = ((width * y) + x) * 4;
        UInt8 red = data[offset+2];
        UInt8 blue = data[offset];
        UInt8 green = data[offset+1];
        UInt8 alpha = data[offset+3];
        CFRelease(bitmapData);
        color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
    }
    
    return color;
}

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection {
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(
                                      base, width, height, 8, bytesPerRow, colorSpace, 
                                      kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage scale:1.0f 
                          orientation:UIImageOrientationRight];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    [self getCenterColor:image];
}

#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isInitializing) {
        return 1;
    }
    
    return [tableSectionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isInitializing) {
        return 1;
    }
    
    NSInteger count = [[tableContentArray objectAtIndex:section] count];
    
    if (count > 0) {
        return count;
    } else {
        return 1;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (isInitializing) {
        return @"";
    }
    
    return [tableSectionArray objectAtIndex:section];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return  @"";
}

- (float)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isInitializing) {
        return tableView.frame.size.height;
    } else {
        return 45.f;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isInitializing) {
        NSString *cellIdentifier = @"EmptyTableViewCell";
        UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell.textLabel setText:NSLocalizedString(@"PLEASE_WAIT", @"")];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    } else {
        if ([[tableContentArray objectAtIndex:indexPath.section] count] > 0) {
            NSString *cellIdentifier = @"TableViewCell";
            
            ColorListCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[ColorListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            
            TbColorName *colorName = [[tableContentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            
            float red = [colorName red] / 255.f;
            float green = [colorName green] / 255.f;
            float blue = [colorName blue] / 255.f;
            
            UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
            
            [cell.colorNameLabel setText:[colorName name]];
            [cell.colorNameYomiLabel setText:[colorName nameYomi]];
            [cell.colorView setBackgroundColor:color];
            [cell checkNameYomiLength];
            
            return cell;
        } else {
            return [self createNotFoundCell:tv];
        }
    }
}

- (UITableViewCell*)createNotFoundCell:(UITableView *)tv {
    NSString *cellIdentifier = @"NotFoundTableViewCell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.textLabel setText:NSLocalizedString(@"NOT_FOUND", @"")];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!isInitializing) {
        if ([[tableContentArray objectAtIndex:indexPath.section] count] > 0) {
            TbColorName *colorName = [[tableContentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            
            ColorDetailViewController *colorDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorDetailViewController"];
            colorDetailViewController.colorName = colorName;
            [self.navigationController pushViewController:colorDetailViewController animated:YES];
        }
    }
}

- (void)videoController:(BOOL)state {
    if (state) {
        isPlay = NO;
        [stateButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
        [session stopRunning];
    } else {
        isPlay = YES;
        [stateButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
        [session startRunning];
    }
    
    [self timerToggle];
}

- (void)timerToggle {
    if (isPlay) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(getColorList)
                                               userInfo:nil
                                                repeats:YES];
    } else {
        [timer invalidate];
        timer = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    if ([previewLayer containsPoint:point]) {
        [self videoController:isPlay];
    }
}

#pragma mark - Send usage statistics dialog

- (void)showUsageStatisticsPermissionAlert:(BOOL)force {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kSendUsageStatisticsAlert] && !force) {
        return;
    }
    
    alertMode = @"confirm_usage_statistics";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CONFIRM_USAGE_STATISTICS", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"NO", @"") otherButtonTitles:NSLocalizedString(@"YES", @""), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertMode isEqualToString:@"confirm_usage_statistics"]) {
        alertMode = @"";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kSendUsageStatisticsAlert];
        
        if (buttonIndex == 1) {
            [defaults setObject:[NSNumber numberWithBool:YES] forKey:kSendUsageStatistics];
            
            [[GAI sharedInstance] setOptOut:NO];
        } else {
            [defaults setObject:[NSNumber numberWithBool:NO] forKey:kSendUsageStatistics];
            
            [[GAI sharedInstance] setOptOut:YES];
        }
        
        [defaults synchronize];
    }
}

+ (void)initialize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"enabled_lang_japanese"] == nil && [defaults objectForKey:@"enabled_lang_english"] == nil) {
        NSString *lang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
        
        if ([lang isEqualToString:@"ja"]) {
            [defaults setBool:YES forKey:@"enabled_lang_japanese"];
            [defaults setBool:NO forKey:@"enabled_lang_english"];
        } else {
            [defaults setBool:NO forKey:@"enabled_lang_japanese"];
            [defaults setBool:YES forKey:@"enabled_lang_english"];
        }
        
        [defaults synchronize];
    }
}

@end
