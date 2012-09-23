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
#import "TbColorNameJa.h"

@interface MasterViewController () {
}
@end

@implementation MasterViewController
@synthesize previewLayer;
@synthesize previewView;
@synthesize colorView;
@synthesize currentColor;
@synthesize colorList;
@synthesize tableView;
@synthesize stateButton;
@synthesize isPlay;
@synthesize session;
@synthesize timer;
@synthesize colorNameJaDao;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Color Name"];
    
    isPlay = YES;
    colorNameJaDao = [[TbColorNameJaDao alloc] init];

    [self createDB];
    [self initDB];
    
    [self setupAVCapture];
    
    [self timerToggle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - IBActions

- (IBAction)stateButtonPressed:(id)sender {
    [self videoController:isPlay];
}

- (void)createDB {
    [colorNameJaDao createTable];
}

- (void)initDB {
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

- (NSMutableArray*)findColorName:(UIColor*)color {
    NSMutableArray *_colorList = [[NSMutableArray alloc] init];
    
    if (!color) {
        return _colorList;
    }
    
    _colorList = [colorNameJaDao findColorNameWithColor:color];
    
    return _colorList;
}

- (void)getColorList {
    colorList = [self findColorName:currentColor];
    
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
    UIColor *color = [self getRGBPixelColorAtPoint:image point:CGPointMake(image.size.height/2 - 10, image.size.width/2)];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [colorList count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"日本語";
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return  @"";
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TableViewCell";
    
    ColorListCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ColorListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    TbColorNameJa *colorNameJa = (TbColorNameJa*)[colorList objectAtIndex:indexPath.row];
    
    float red = [colorNameJa red] / 255.f;
    float green = [colorNameJa green] / 255.f;
    float blue = [colorNameJa blue] / 255.f;
    NSLog(@"%f %f %f", red, green, blue);
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
    
    [cell.colorNameLabel setText:[colorNameJa name]];
    [cell.colorNameYomiLabel setText:[colorNameJa nameYomi]];
    [cell.colorView setBackgroundColor:color];
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
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

@end
