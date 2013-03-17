//
//  FavoritesColorViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 10/7/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "FavoritesColorViewController.h"
#import "ColorDetailsViewController.h"
#import "ColorListCell.h"
#import "JSON.h"
#import "SVProgressHUD.h"
#import "AuthViewController.h"
#import "UserPageViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>

@interface FavoritesColorViewController ()

@end

@implementation FavoritesColorViewController

@synthesize tableView;
@synthesize syncButton;
@synthesize toolBar;
@synthesize colorList;
@synthesize remoteColorList;
@synthesize addedColorNameList;
@synthesize alertMode;
@synthesize connection;
@synthesize httpResponseData;
@synthesize favoriteColorNameDao;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // for Google Analytics
    self.trackedViewName = NSStringFromClass([self class]);
    
    [self.navigationItem setTitle:NSLocalizedString(@"FAVORITES", @"")];
    [self.navigationItem setRightBarButtonItem:self.editButtonItem];

    [syncButton setTitle:NSLocalizedString(@"SYNC", @"")];
    
    favoriteColorNameDao = [[TbFavoriteColorNameDao alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    colorList = [favoriteColorNameDao getAll];
    [tableView reloadData];
    
    if (SharedAppDelegate.isAuthenticated) {
        SharedAppDelegate.isAuthenticated = NO;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (SharedAppDelegate.canBeCombine && ![defaults boolForKey:@"COMBINE_DIALOG"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INFO", @"") message:NSLocalizedString(@"CONFIRM_COMBINE_MESSAGE", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"NO", @"") otherButtonTitles:NSLocalizedString(@"YES", @""), nil];
            [alert show];
        } else {
            [self syncAction];
        }
    } else {
        if (![self checkHowToUseAlert]) {
            [self showHowToUseAlertWithNumder:1];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate

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
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
        
        ColorDetailsViewController *colorDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorDetailsViewController"];
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
        [favoriteColorNameDao removeFromColorName:colorName];
        
        [colorList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - IBAction

- (IBAction)syncButtonPressed:(id)sender {
    [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"sync" withValue:nil];
    
    if ([SVProgressHUD isVisible]) {
        [connection cancel];
        
        [syncButton setStyle:UIBarButtonItemStyleDone];
        [syncButton setTitle:NSLocalizedString(@"SYNC", @"")];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        [SVProgressHUD dismiss];
    } else {
        AuthViewController *authViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
        authViewController.signIn = YES;
        [self presentViewController:authViewController animated:YES completion:nil];
    }
}

- (void)syncAction {
    [syncButton setStyle:UIBarButtonItemStyleBordered];
    [syncButton setTitle:NSLocalizedString(@"CANCEL", @"")];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"UPLOADING", @"")];
    
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

- (void)showMyPageButton {
    NSMutableArray *toolBarItems = [toolBar.items mutableCopy];
    
    if ([toolBarItems count] <= 3) {
        UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MY_PAGE", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(myPageButtonPressed)];
        
        [toolBarItems insertObject:item0 atIndex:0];
        [toolBarItems insertObject:item1 atIndex:1];
        
        [toolBar setItems:toolBarItems animated:YES];
    }
}

- (void)myPageButtonPressed {
    if ([SharedAppDelegate.userId length] > 0) {
        [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"myPage" withValue:nil];
        
        UserPageViewController *userPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPageViewController"];
        [userPageViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:userPageViewController animated:YES completion:nil];
    }
}

- (BOOL)checkHowToUseAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"HOW_TO_USE_ALERT_1"]) {
        return YES;
    }
    
    return NO;
}

- (void)showHowToUseAlertWithNumder:(NSInteger)number {
    UIAlertView *alert;
    switch (number) {
        case 1:
            alertMode = @"how_to_use_1";
            
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HOW_TO_USE", @"") message:NSLocalizedString(@"HOW_TO_USE_MESSAGE_1", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"NEXT", @"") otherButtonTitles:nil, nil];
            [alert show];
            
            break;
        case 2:
            alertMode = @"how_to_use_2";
            
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HOW_TO_USE", @"") message:NSLocalizedString(@"HOW_TO_USE_MESSAGE_2", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:nil, nil];
            [alert show];
            
            break;
        default:
            break;
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
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([httpResponseData length] > 0) {
        NSString *jsonString = [[NSString alloc] initWithData:httpResponseData encoding:NSUTF8StringEncoding];
        NSDictionary *result = [NSDictionary dictionaryWithDictionary:[jsonString JSONValue]];

        SharedAppDelegate.userId = [result valueForKey:@"user_id"];
        
        NSArray *newColorList = [result valueForKey:@"new_color"];
        addedColorNameList = [[NSMutableArray alloc]initWithCapacity:[newColorList count]];
        for (NSDictionary *new in newColorList) {
            [addedColorNameList addObject:[new valueForKey:@"name"]];
        }
        
        [self syncFinishWithResult:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"COMBINE_DIALOG"];

        [self performSelector:@selector(showTweetConfirmDialog) withObject:nil afterDelay:1.f];
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
        [syncButton setTitle:NSLocalizedString(@"SYNC", @"")];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SUCCESS", @"")];
        
        [self performSelector:@selector(showMyPageButton) withObject:nil afterDelay:1.f];
    } else {
        [syncButton setStyle:UIBarButtonItemStyleDone];
        [syncButton setTitle:NSLocalizedString(@"SYNC", @"")];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"FAILED", @"")];
    }
}

- (void)showTweetConfirmDialog {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && [addedColorNameList count] > 0) {
        alertMode = @"tweet";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CONFIRM_TWEET_MESSAGE", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"NO", @"") otherButtonTitles:NSLocalizedString(@"YES", @""), nil];
        [alert show];
    } else {
        [self showFacebookConfirmDialog];
    }
}

- (void)showTweetDialog:(NSArray*)colors {
    if ([colors count] > 0) {
        NSString *newColorName = [colors componentsJoinedByString:@", "];
        if ([newColorName length] > 100) {
            newColorName = [newColorName substringWithRange:NSMakeRange(0, 100)];
            newColorName = [NSString stringWithFormat:@"%@...", newColorName];
        }
        
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"TWEET_MESSAGE", @""), newColorName];
        
        SLComposeViewController *twitterPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterPostViewController setInitialText:message];
        [twitterPostViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://color-name.atrac613.io/u/%@", SharedAppDelegate.userId]]];
        
        [twitterPostViewController setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Done");
                    
                default:
                    break;
            }
            
            [self dismissViewControllerAnimated:YES completion:^(void){
                [self showFacebookConfirmDialog];
            }];
        }];
        
        [self presentViewController:twitterPostViewController animated:YES completion:nil];
    }
}

- (void)showFacebookConfirmDialog {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] && [addedColorNameList count] > 0) {
        alertMode = @"facebook";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CONFIRM_FACEBOOK_SHARE_MESSAGE", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"NO", @"") otherButtonTitles:NSLocalizedString(@"YES", @""), nil];
        [alert show];
    }
}

- (void)showFacebookDialog:(NSArray*)colors {
    if ([colors count] > 0) {
        NSString *newColorName = [colors componentsJoinedByString:@", "];

        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"FACEBOOK_SHARE_MESSAGE", @""), newColorName];
        
        SLComposeViewController *facebookPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookPostViewController setInitialText:message];
        [facebookPostViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://color-name.atrac613.io/u/%@", SharedAppDelegate.userId]]];
        
        [facebookPostViewController setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Done");
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:facebookPostViewController animated:YES completion:nil];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertMode isEqualToString:@"tweet"]) {
        alertMode = @"";
        
        [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"tweetDialog" withValue:[NSNumber numberWithInteger:buttonIndex]];
        
        if (buttonIndex == 1) {
            [self performSelector:@selector(showTweetDialog:) withObject:addedColorNameList afterDelay:1.f];
        } else {
            [self performSelector:@selector(showFacebookConfirmDialog) withObject:nil afterDelay:1.f];
        }
    } else if ([alertMode isEqualToString:@"facebook"]) {
        alertMode = @"";
        
        [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"facebookDialog" withValue:[NSNumber numberWithInteger:buttonIndex]];
        
        if (buttonIndex == 1) {
            [self performSelector:@selector(showFacebookDialog:) withObject:addedColorNameList afterDelay:1.f];
        }
    } else if ([alertMode isEqualToString:@"how_to_use_1"]) {
        alertMode = @"";
        
        [self showHowToUseAlertWithNumder:2];
    } else if ([alertMode isEqualToString:@"how_to_use_2"]) {
        alertMode = @"";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"HOW_TO_USE_ALERT_1"];
        [defaults synchronize];
    } else {
        [SharedAppDelegate.tracker sendEventWithCategory:@"uiAction" withAction:@"buttonPress" withLabel:@"combining" withValue:[NSNumber numberWithInteger:buttonIndex]];
        
        if (buttonIndex == 1) {
            [self.navigationItem setHidesBackButton:YES animated:YES];
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            [SVProgressHUD showWithStatus:NSLocalizedString(@"COMBINING", @"")];
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationGetFavoriteColor) object:nil];
            [operation setQueuePriority:NSOperationQueuePriorityHigh];
            [SharedAppDelegate.operationQueue addOperation:operation];
            
        } else {
            [self syncAction];
        }
    }
}

#pragma mark - Operation

- (void)operationGetFavoriteColor {
    @try {
        remoteColorList = [SharedAppDelegate.colorNmaeService getFavoriteColor];
        
        [favoriteColorNameDao createTable];
        
        for (NSDictionary *colorName in remoteColorList) {
            NSString *name = [colorName valueForKey:@"name"];
            NSString *nameYomi = [colorName valueForKey:@"name_yomi"];
            NSInteger red = [[colorName valueForKey:@"red"] intValue];
            NSInteger green = [[colorName valueForKey:@"green"] intValue];
            NSInteger blue = [[colorName valueForKey:@"blue"] intValue];
            NSInteger rank = [[colorName valueForKey:@"rank"] intValue];

            if ([favoriteColorNameDao countWithName:name nameYomi:nameYomi red:red green:green blue:blue] <= 0) {
                [favoriteColorNameDao insertWithName:name nameYomi:nameYomi red:red green:green blue:blue rank:rank];
            }
        }
        
        colorList = [favoriteColorNameDao getAll];
        
        [self performSelectorOnMainThread:@selector(completeGetFavoriteColor) withObject:nil waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    }
}

- (void)completeGetFavoriteColor {
    [self syncFinishWithResult:YES];
    [tableView reloadData];
    
    [self syncAction];
}

@end
