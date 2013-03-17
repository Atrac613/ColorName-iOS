//
//  LanguageSettingViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 12/16/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "LanguageSettingViewController.h"

@interface LanguageSettingViewController ()

@end

@implementation LanguageSettingViewController

@synthesize tableView;

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
    self.trackedViewName = NSStringFromClass([self class]);
    
    [self.navigationItem setTitle:NSLocalizedString(@"APPLICATION_SETTINGS", @"")];
	
    [tableView setAllowsSelection:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"LANGUAGES", @"");
    }
    
    return @"";
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return  @"";
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TableViewCell";
    
    UITableViewCell *cell;
    
    cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == 0) {
        [cell.textLabel setText:NSLocalizedString(@"ENGLISH", @"")];
        
        UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 20.0)];
        [switchObj setOn:[defaults boolForKey:@"enabled_lang_english"]];
        [switchObj addTarget:self action:@selector(englishSwitch:) forControlEvents:UIControlEventValueChanged];
        
        [cell setAccessoryView:switchObj];
    } else {
        [cell.textLabel setText:NSLocalizedString(@"JAPANESE", @"")];
        
        UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 20.0)];
        [switchObj setOn:[defaults boolForKey:@"enabled_lang_japanese"]];
        [switchObj addTarget:self action:@selector(japaneseSwitch:) forControlEvents:UIControlEventValueChanged];
        
        [cell setAccessoryView:switchObj];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)englishSwitch:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:((UISwitch*)sender).on forKey:@"enabled_lang_english"];
    [defaults synchronize];
}

- (void)japaneseSwitch:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:((UISwitch*)sender).on forKey:@"enabled_lang_japanese"];
    [defaults synchronize];
}

@end
