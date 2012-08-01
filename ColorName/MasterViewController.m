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

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Color Name"];

    [self createDB];
    [self initDB];
    
    [self setupAVCapture];
    
    [NSTimer scheduledTimerWithTimeInterval:1 
                                     target:self 
                                   selector:@selector(getColorList) 
                                   userInfo:nil
                                    repeats:YES];

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

- (void)createDB {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    FMDatabase *db = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"app.db"]];
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS color_name_ja (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, name_yomi TEXT, red INTEGER, green INTEGER, blue INTEGER);";
    
    [db open];
    [db executeUpdate:sql];
    [db close];
}

- (void)initDB {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    FMDatabase *db = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"app.db"]];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"color_names_ja" ofType:@"json"]];
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *jsonArray = [jsonString JSONValue];
    
    [db open];
    
    NSString *sql = @"SELECT count(*) FROM color_name_ja;";
    FMResultSet *results = [db executeQuery:sql];
    while([results next]){
        if ([[results stringForColumn:@"count(*)"] intValue] > 0) {
            [db close];
            
            return;
        }
    }
    
    for (int i = 0; i < [jsonArray count]; i++) {
        NSDictionary *dict = [jsonArray objectAtIndex:i];
        NSString *name = [dict valueForKey:@"kanji"];
        NSString *name_yomi = [dict valueForKey:@"yomi"];
        NSString *hex = [dict valueForKey:@"hex"];
        
        UIColor *color = [UIColor colorWithHexString:hex];
        const CGFloat *rgba = CGColorGetComponents(color.CGColor);
        
        sql = @"SELECT count(*) FROM color_name_ja WHERE name = ? AND name_yomi = ? AND red = ? AND green = ? AND blue = ?;";
        
        results = [db executeQuery:sql, name, name_yomi, [NSNumber numberWithFloat:rgba[0]], [NSNumber numberWithFloat:rgba[1]], [NSNumber numberWithFloat:rgba[2]]];
        
        while([results next]){
            if ([[results stringForColumn:@"count(*)"] intValue] == 0) {
                sql = @"INSERT INTO color_name_ja (name, name_yomi, red, green, blue) VALUES (?, ?, ?, ?, ?)";
                [db executeUpdate:sql, name, name_yomi, [NSNumber numberWithFloat:rgba[0] * 255], [NSNumber numberWithFloat:rgba[1] * 255], [NSNumber numberWithFloat:rgba[2] * 255]];
            }
        }
    }
    [db close];
}

- (NSMutableArray*)findColorName:(UIColor*)color {
    NSMutableArray *_colorList = [[NSMutableArray alloc] init];
    
    if (!color) {
        return _colorList;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    FMDatabase *db = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"app.db"]];
    
    const CGFloat *rgba = CGColorGetComponents(color.CGColor);
    
    NSString *sql = @"SELECT name, name_yomi, red, green, blue, (pow((?-red), 2) + pow((?-green), 2) + pow((?-blue), 2)) as difference FROM color_name_ja ORDER BY difference;";
    
    [db open];
    
    FMResultSet *results = [db executeQuery:sql, [NSNumber numberWithFloat:rgba[0] * 255], [NSNumber numberWithFloat:rgba[1] * 255], [NSNumber numberWithFloat:rgba[2] * 255]];
    
    while([results next]){
        if ([results intForColumn:@"difference"] < 2000) {
            NSString *name = [results stringForColumn:@"name"];
            NSString *name_yomi = [results stringForColumn:@"name_yomi"];
            NSNumber *red = [NSNumber numberWithInt:[results intForColumn:@"red"]];
            NSNumber *green = [NSNumber numberWithInt:[results intForColumn:@"green"]];
            NSNumber *blue = [NSNumber numberWithInt:[results intForColumn:@"blue"]];
            [_colorList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  name, @"name",
                                  name_yomi, @"name_yomi",
                                  red, @"red",
                                  green, @"green",
                                  blue, @"blue",nil]];
        }
    }
    
    [db close];
    
    return _colorList;
}

- (void)getColorList {
    colorList = [self findColorName:currentColor];
    
    [tableView reloadData];
}

- (void)setupAVCapture
{
    AVCaptureSession *session = [AVCaptureSession new];
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
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    [session startRunning];
}

- (void)getCenterColor:(UIImage*)image {
    UIColor *color = [self getRGBPixelColorAtPoint:image point:CGPointMake(image.size.height/2 - 20, image.size.width/2)];
    
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
    
    float red = [[[colorList objectAtIndex:indexPath.row] objectForKey:@"red"] intValue] / 255.f;
    float green = [[[colorList objectAtIndex:indexPath.row] objectForKey:@"green"] intValue] / 255.f;
    float blue = [[[colorList objectAtIndex:indexPath.row] objectForKey:@"blue"] intValue] / 255.f;
    NSLog(@"%f %f %f", red, green, blue);
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
    
    [cell.colorNameLabel setText:[[colorList objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [cell.colorNameYomiLabel setText:[[colorList objectAtIndex:indexPath.row] objectForKey:@"name_yomi"]];
    [cell.colorView setBackgroundColor:color];
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

@end
