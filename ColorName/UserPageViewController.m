//
//  UserPageViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 11/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "UserPageViewController.h"
#import "JSON.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface UserPageViewController ()

@end

@implementation UserPageViewController

@synthesize updateProfileButton;
@synthesize selectedAccountName;
@synthesize accountArray;
@synthesize accountType;
@synthesize pickerViewPopup;
@synthesize pickerView;
@synthesize pickerToolbar;
@synthesize avatarView;
@synthesize userIdField;
@synthesize nickNameField;
@synthesize connection;
@synthesize httpResponseData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // for Google Analytics
    self.screenName = NSStringFromClass([self class]);
	
    [self.navigationItem setTitle:NSLocalizedString(@"MY_PAGE", @"")];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)]];
    
    [updateProfileButton setTitle:NSLocalizedString(@"UPDATE_PROFILE", @"")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadProfilePage];
}

- (void)loadProfilePage {
    NSString *urlString;
    if (TARGET_IPHONE_SIMULATOR) {
        urlString = [NSString stringWithFormat:@"http://localhost:8093/u/%@", SharedAppDelegate.userId];
    } else {
        urlString = [NSString stringWithFormat:@"http://color-name.atrac613.io/u/%@", SharedAppDelegate.userId];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - IBAction

- (IBAction)updateProfileButtonPressed:(id)sender {
    [self twitterAccountCheck];
}

- (IBAction)actionButtonPressed:(id)sender {
    [SharedAppDelegate.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction" action:@"buttonPress" label:@"actionButton" value:nil] build]];
    
    [[UIApplication sharedApplication] openURL:webView.request.URL];
}

#pragma mark - Profile

- (void)twitterAccountCheck {
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] == 1) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                selectedAccountName = twitterAccount.username;
                
                [self performSelectorInBackground:@selector(updateProfileFromTwitter) withObject:nil];
            } else if ([accountsArray count] > 1) {
                [self selectTwitterAccount:accountsArray];
            } else {
                NSArray *params = [NSArray arrayWithObjects:NSLocalizedString(@"UPDATE_PROFILE_ALERT_TITLE", @""), NSLocalizedString(@"UPDATE_PROFILE_ERROR_MESSAGE", @""), nil];
                [self performSelectorOnMainThread:@selector(showAlertDialog:) withObject:params waitUntilDone:YES];
            }
        } else {
            NSArray *params = [NSArray arrayWithObjects:NSLocalizedString(@"UPDATE_PROFILE_ALERT_TITLE", @""), NSLocalizedString(@"UPDATE_PROFILE_ERROR_MESSAGE", @""), nil];
            [self performSelectorOnMainThread:@selector(showAlertDialog:) withObject:params waitUntilDone:YES];
        }
    }];
}

- (void)showAlertDialog:(NSArray*)params {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[params objectAtIndex:0] message:[params objectAtIndex:1] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"CLOSE", @""), nil];
    [alert show];
}

- (void)selectTwitterAccount:(NSArray*)accountsArray {
    accountArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [accountsArray count]; i++) {
        ACAccount *twitterAccount = [accountsArray objectAtIndex:i];
        [accountArray addObject:[NSString stringWithFormat:@"@%@", twitterAccount.username]];
    }
    
    [self performSelectorOnMainThread:@selector(showTwitterAccountPickerView) withObject:nil waitUntilDone:NO];
}

- (void)showTwitterAccountPickerView {
    pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Select Account"
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,44,0,0)];
    
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    
    NSString *accountName = selectedAccountName;
    if ([accountType.identifier isEqualToString:ACAccountTypeIdentifierTwitter]) {
        accountName = [NSString stringWithFormat:@"@%@", selectedAccountName];
    }
    
    for (int i = 0; i < [accountArray count]; i++) {
        if ([accountName isEqualToString:[accountArray objectAtIndex:i]]) {
            [pickerView selectRow:i inComponent:0 animated:YES];
        }
    }
    
    pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UILabel *toolBarTitle = [[UILabel alloc] init];
    [toolBarTitle setBackgroundColor:[UIColor clearColor]];
    [toolBarTitle setTextColor:[UIColor whiteColor]];
    [toolBarTitle setFont:[UIFont boldSystemFontOfSize:12.f]];
    [toolBarTitle setText:NSLocalizedString(@"UPDATE_PROFILE_PICKER_TITLE", @"")];
    [toolBarTitle sizeToFit];
    
    UIBarButtonItem *toolBarTitleButton = [[UIBarButtonItem alloc] initWithCustomView:toolBarTitle];
    [barItems addObject:toolBarTitleButton];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closePicker:)];
    [barItems addObject:doneBtn];
    
    [pickerToolbar setItems:barItems animated:YES];
    
    [pickerViewPopup addSubview:pickerToolbar];
    [pickerViewPopup addSubview:pickerView];
    [pickerViewPopup showInView:self.view];
    [pickerViewPopup setBounds:CGRectMake(0,0,320, 476)];
}

- (BOOL)closePicker:(id)sender {
    selectedAccountName = [accountArray objectAtIndex:[pickerView selectedRowInComponent:0]];
    if ([selectedAccountName hasPrefix:@"@"]) {
        selectedAccountName = [selectedAccountName substringFromIndex:1];
    }
    
    [pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([accountType.identifier isEqualToString:ACAccountTypeIdentifierTwitter]) {
        [self performSelectorInBackground:@selector(updateProfileFromTwitter) withObject:nil];
    }
    
    return YES;
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [accountArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%@", [accountArray objectAtIndex:row]];
}

#pragma mark - Update Profile

- (void)updateProfileFromTwitter {
    NSLog(@"Account Name: %@", selectedAccountName);
    
    // Lock update button
    [updateProfileButton setEnabled:NO];
    
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            ACAccount *twitterAccount;
            
            for (ACAccount *account in accountsArray) {
                if ([account.username isEqualToString:selectedAccountName] ) {
                    twitterAccount = account;
                }
            }
            
            NSLog(@"Account: %@", twitterAccount.username);
            
            // Create a request, which in this example, posts a tweet to the user's timeline.
            // This example uses version 1 of the Twitter API.
            // This may need to be changed to whichever version is currently appropriate.
            
            NSString *url = @"http://api.twitter.com/1/account/verify_credentials.json";
            
            SLRequest *getRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:url] parameters:nil];
            [getRequest setAccount:twitterAccount];
            
            // Show Busy indicator
            [self performSelectorOnMainThread:@selector(rightButtonIsBusy) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(leftButtonIsBusy) withObject:nil waitUntilDone:NO];
            
            [getRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if ([urlResponse statusCode] == 200) {
                    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                    NSDictionary *result = [jsonString JSONValue];
                    
                    NSString *profileImageUrl = [result valueForKey:@"profile_image_url"];
                    NSString *screenName = [result valueForKey:@"screen_name"];
                    NSString *name = [result valueForKey:@"name"];
                    
                    NSLog(@"%@ %@ %@", profileImageUrl, screenName, name);
                    
                    NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profileImageUrl]];
                    
                    NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:avatarData, screenName, name, nil] forKeys:[NSArray arrayWithObjects:@"avatar", @"user_id", @"nick_name", nil]];
                    
                    [self performSelectorOnMainThread:@selector(showEditProfileDialog:) withObject:params waitUntilDone:YES];
                } else {
                    [self performSelectorOnMainThread:@selector(syncFinishWithResult:) withObject:NO waitUntilDone:YES];
                }
            }];
        }
    }];
}

- (void)showEditProfileDialog:(NSDictionary*)params {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UPDATE_PROFILE_ALERT_TITLE", @"") message:@"\n\n\n" delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") otherButtonTitles:NSLocalizedString(@"UPDATE", @""), nil];
    
    avatarView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[params valueForKey:@"avatar"]]];
    [avatarView setFrame:CGRectMake(15, 55, 50, 50)];
    [alert addSubview:avatarView];
    
    userIdField = [[UITextField alloc] initWithFrame:CGRectMake(73, 50, 197, 25)];
    userIdField.borderStyle = UITextBorderStyleRoundedRect;
    userIdField.textAlignment = NSTextAlignmentLeft;
    //userIdField.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
    userIdField.textColor = [UIColor grayColor];
    userIdField.minimumFontSize = 8;
    userIdField.adjustsFontSizeToFitWidth = YES;
    userIdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userIdField.returnKeyType = UIReturnKeyDone;
    userIdField.keyboardType = UIKeyboardTypeAlphabet;
    userIdField.delegate = self;
    userIdField.text = [params valueForKey:@"user_id"];
    [alert addSubview:userIdField];
    
    nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(73, 85, 197, 25)];
    nickNameField.borderStyle = UITextBorderStyleRoundedRect;
    nickNameField.textAlignment = NSTextAlignmentLeft;
    //nickNameField.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
    nickNameField.textColor = [UIColor grayColor];
    nickNameField.minimumFontSize = 8;
    nickNameField.adjustsFontSizeToFitWidth = YES;
    nickNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nickNameField.returnKeyType = UIReturnKeyDone;
    nickNameField.delegate = self;
    nickNameField.text = [params valueForKey:@"nick_name"];
    [alert addSubview:nickNameField];
    
    [alert show];
    
    [self performSelectorOnMainThread:@selector(rightButtonIsNormal) withObject:nil waitUntilDone:NO];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [SharedAppDelegate.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction" action:@"buttonPress" label:@"updateProfile" value:[NSNumber numberWithInteger:buttonIndex]] build]];
    
    if (buttonIndex == 1) {
        [updateProfileButton setEnabled:NO];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"UPLOADING", @"")];
        [self uploadAction];
    } else {
        // Unlock update button
        [updateProfileButton setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)characters
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9]*$" options:0 error:&error];
    if ([regex numberOfMatchesInString:characters options:0 range:NSMakeRange(0, [characters length])] > 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Upload Action

- (void)uploadAction {
    NSString *urlString;
    if (TARGET_IPHONE_SIMULATOR) {
        urlString = @"http://localhost:8093/api/v1/update_profile";
    } else {
        urlString = @"https://color-name-app.appspot.com/api/v1/update_profile";
    }
    
    NSString *_userId = userIdField.text;
    NSString *_nickName = nickNameField.text;
    NSData *_avatarData = [NSData dataWithData:UIImagePNGRepresentation(avatarView.image)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:YES];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"user_id"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", _userId] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"nick_name"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", _nickName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:_avatarData]];
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
        
        [self loadProfilePage];
        
        [self syncFinishWithResult:YES];
    } else {
        [self syncFinishWithResult:NO];
    }
    
    // Unlock update button
    [updateProfileButton setEnabled:YES];
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
    [self rightButtonIsNormal];
    
    if (result) {
        [updateProfileButton setEnabled:YES];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SUCCESS", @"")];
    } else {
        [updateProfileButton setEnabled:YES];
        
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"FAILED", @"")];
    }
}

@end
