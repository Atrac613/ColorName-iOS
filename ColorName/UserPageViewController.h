//
//  UserPageViewController.h
//  ColorName
//
//  Created by Osamu Noguchi on 11/23/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "WebViewViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface UserPageViewController : WebViewViewController<UIPickerViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    IBOutlet UIBarButtonItem *updateProfileButton;

    NSString *selectedAccountName;
    NSMutableArray *accountArray;
    ACAccountType *accountType;
    
    UIActionSheet *pickerViewPopup;
    UIPickerView *pickerView;
    UIToolbar *pickerToolbar;
    
    UIImageView *avatarView;
    UITextField *userIdField;
    UITextField *nickNameField;
    
    NSURLConnection *connection;
    NSMutableData *httpResponseData;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *updateProfileButton;
@property (nonatomic, retain) NSString *selectedAccountName;
@property (nonatomic, retain) NSMutableArray *accountArray;
@property (nonatomic, retain) ACAccountType *accountType;
@property (nonatomic, retain) UIActionSheet *pickerViewPopup;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIToolbar *pickerToolbar;
@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) UITextField *userIdField;
@property (nonatomic, retain) UITextField *nickNameField;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *httpResponseData;

- (IBAction)updateProfileButtonPressed:(id)sender;
- (IBAction)actionButtonPressed:(id)sender;

@end
