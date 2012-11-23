//
//  FavoritesColorViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "FavoritesColorViewController.h"
#import "ColorDetailViewController.h"
#import "ColorListCell.h"
#import "JSON.h"
#import "SVProgressHUD.h"
#import "AuthViewController.h"
#import "UserPageViewController.h"
#import "AppDelegate.h"

@interface FavoritesColorViewController ()

@end

@implementation FavoritesColorViewController

@synthesize tableView;
@synthesize syncButton;
@synthesize toolBar;
@synthesize colorList;
@synthesize connection;
@synthesize httpResponseData;
@synthesize favoriteColorNameDao;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Favorites"];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    favoriteColorNameDao = [[TbFavoriteColorNameDao alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    colorList = [favoriteColorNameDao getAll];
    [tableView reloadData];
    
    if (SharedAppDelegate.isAuthenticated) {
        SharedAppDelegate.isAuthenticated = NO;
        
        [self syncAction];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView delegate

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [tableView setEditing:editing animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [colorList count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
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
    
    TbColorName *colorName = (TbColorName*)[colorList objectAtIndex:indexPath.row];
    
    float red = [colorName red] / 255.f;
    float green = [colorName green] / 255.f;
    float blue = [colorName blue] / 255.f;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
    
    [cell.colorNameLabel setText:[colorName name]];
    [cell.colorNameYomiLabel setText:[colorName nameYomi]];
    [cell.colorView setBackgroundColor:color];
    [cell checkNameYomiLength];
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![SVProgressHUD isVisible]) {
        TbColorName *colorName = (TbColorName*)[colorList objectAtIndex:indexPath.row];
        
        ColorDetailViewController *colorDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorDetailViewController"];
        colorDetailViewController.colorName = colorName;
        [self.navigationController pushViewController:colorDetailViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithArray:colorList];
    TbColorName *colorName = (TbColorName*)[colorList objectAtIndex:sourceIndexPath.row];
    
    [tmpArray removeObject:colorName];
    
    [tmpArray insertObject:colorName atIndex:destinationIndexPath.row];
    
    int rank = 0;
    for (TbColorName *colorName in tmpArray) {
        [favoriteColorNameDao updateRank:rank favorite_id:colorName.index];
        rank++;
    }
    
    colorList = [favoriteColorNameDao getAll];
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TbColorName *colorName = (TbColorName*)[colorList objectAtIndex:indexPath.row];
        [favoriteColorNameDao removeFromId:colorName.index];
        
        [colorList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - IBActions

- (IBAction)syncButtonPressed:(id)sender {
    if ([SVProgressHUD isVisible]) {
        [connection cancel];
        
        [syncButton setStyle:UIBarButtonItemStyleDone];
        [syncButton setTitle:@"Sync"];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        [SVProgressHUD dismiss];
    } else {
        AuthViewController *authViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
        authViewController.signIn = YES;
        [self presentModalViewController:authViewController animated:YES];
    }
}

- (void)syncAction {
    [syncButton setStyle:UIBarButtonItemStyleBordered];
    [syncButton setTitle:@"Cancel"];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [SVProgressHUD showWithStatus:@"Uploading"];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[colorList count]];
    
    int rank = 1;
    for (TbColorName *colorName in colorList) {
        NSArray *keys = [NSArray arrayWithObjects:@"name", @"name_yomi", @"red", @"green", @"blue", @"rank", nil];
        NSArray *objects = [NSArray arrayWithObjects:colorName.name, colorName.nameYomi, [NSNumber numberWithInt:colorName.red], [NSNumber numberWithInt:colorName.green], [NSNumber numberWithInt:colorName.blue], [NSNumber numberWithInt:rank], nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [array addObject:dict];
        
        rank++;
    }
    
    [self uploadAction:[array JSONRepresentation]];
}

- (void)showViewButton {
    NSMutableArray *toolBarItems = [toolBar.items mutableCopy];
    
    if ([toolBarItems count] <= 3) {
        UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"View" style:UIBarButtonItemStyleBordered target:self action:@selector(viewButtonPressed)];
        
        [toolBarItems insertObject:item0 atIndex:0];
        [toolBarItems insertObject:item1 atIndex:1];
        
        [toolBar setItems:toolBarItems animated:YES];
    }
}

- (void)viewButtonPressed {
    if ([SharedAppDelegate.userId length] > 0) {
        UserPageViewController *userPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPageViewController"];
        [self presentModalViewController:userPageViewController animated:YES];
    }
}

#pragma mark - Upload Action

- (void)uploadAction:(NSString*)jsonData {
    NSString *urlString;
    if (TARGET_IPHONE_SIMULATOR) {
        urlString = @"http://localhost:8093/api/v1/save_with_multiple";
    } else {
        urlString = @"https://color-name-app.appspot.com/api/v1/save_with_multiple";
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:YES];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"raw_data"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", jsonData] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    int statusCode = [((NSHTTPURLResponse *)response) statusCode];
    if (statusCode != 200) {
        NSLog(@"ErrorCode: %d", statusCode);
    } else {
        httpResponseData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [httpResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([httpResponseData length] > 0) {
        NSString *jsonString = [[NSString alloc] initWithData:httpResponseData encoding:NSUTF8StringEncoding];
        NSDictionary *result = [NSDictionary dictionaryWithDictionary:[jsonString JSONValue]];

        SharedAppDelegate.userId = [result valueForKey:@"user_id"];
        
        [self syncFinishWithResult:YES];
    } else {
        [self syncFinishWithResult:NO];
    }
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self syncFinishWithResult:NO];
}

- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

}

- (NSString*)data2str:(NSData*)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)syncFinishWithResult:(BOOL)result {
    if (result) {
        [syncButton setStyle:UIBarButtonItemStyleDone];
        [syncButton setTitle:@"Sync"];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
        
        [self performSelector:@selector(showViewButton) withObject:nil afterDelay:1.f];
    } else {
        [syncButton setStyle:UIBarButtonItemStyleDone];
        [syncButton setTitle:@"Sync"];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        [SVProgressHUD showErrorWithStatus:@"Failed"];
    }
}

@end
