//
//  DefaultColorTableViewController.m
//  ColorName
//
//  Created by Osamu Noguchi on 3/17/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import "DefaultColorTableViewController.h"
#import "ColorListCell.h"
#import "ColorDetailsViewController.h"

@interface DefaultColorTableViewController ()

@end

@implementation DefaultColorTableViewController

@synthesize tableView;
@synthesize currentColor;
@synthesize colorNameJaDao;
@synthesize colorNameEnDao;
@synthesize tableSectionArray;
@synthesize tableContentArray;
@synthesize isInitializing;

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
	
    colorNameJaDao = [[TbColorNameJaDao alloc] init];
    colorNameEnDao = [[TbColorNameEnDao alloc] init];
    
    tableSectionArray = [[NSMutableArray alloc] init];
    tableContentArray = [[NSMutableArray alloc] init];
    
    isInitializing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Build Color List

- (void)getColorList {
    [self getColorListWithOffset:0];
}

- (void)getColorListWithOffset:(int)offset {
    if (!currentColor || isInitializing) {
        return;
    }
    
    tableSectionArray = [[NSMutableArray alloc] init];
    tableContentArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL langJapanese = [defaults boolForKey:@"enabled_lang_japanese"];
    BOOL langEnglish = [defaults boolForKey:@"enabled_lang_english"];
    
    if (langJapanese || langEnglish) {
        NSString *lang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
        
        if ([lang isEqualToString:@"ja"]) {
            if (langJapanese) {
                if (langJapanese && langEnglish) {
                    [tableSectionArray addObject:NSLocalizedString(@"JAPANESE", @"")];
                } else {
                    [tableSectionArray addObject:NSLocalizedString(@"SEARCH_RESULTS", @"")];
                }
                
                if (offset > 0) {
                    [tableContentArray addObject:[colorNameJaDao findColorNameWithColor:currentColor offset:offset]];
                } else {
                    [tableContentArray addObject:[colorNameJaDao findColorNameWithColor:currentColor]];
                }
            }
            
            if (langEnglish) {
                if (langJapanese && langEnglish) {
                    [tableSectionArray addObject:NSLocalizedString(@"ENGLISH", @"")];
                } else {
                    [tableSectionArray addObject:NSLocalizedString(@"SEARCH_RESULTS", @"")];
                }
                
                if (offset > 0) {
                    [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor offset:offset]];
                } else {
                    [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor]];
                }
            }
        } else {
            if (langEnglish) {
                if (langJapanese && langEnglish) {
                    [tableSectionArray addObject:NSLocalizedString(@"ENGLISH", @"")];
                } else {
                    [tableSectionArray addObject:NSLocalizedString(@"SEARCH_RESULTS", @"")];
                }
                
                if (offset > 0) {
                    [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor offset:offset]];
                } else {
                    [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor]];
                }
            }
            
            if (langJapanese) {
                if (langJapanese && langEnglish) {
                    [tableSectionArray addObject:NSLocalizedString(@"JAPANESE", @"")];
                } else {
                    [tableSectionArray addObject:NSLocalizedString(@"SEARCH_RESULTS", @"")];
                }
                
                if (offset > 0) {
                    [tableContentArray addObject:[colorNameJaDao findColorNameWithColor:currentColor offset:offset]];
                } else {
                    [tableContentArray addObject:[colorNameJaDao findColorNameWithColor:currentColor]];
                }
            }
        }
    } else {
        [tableSectionArray addObject:NSLocalizedString(@"SEARCH_RESULTS", @"")];
        [tableContentArray addObject:[colorNameEnDao findColorNameWithColor:currentColor]];
    }
    
    [tableView reloadData];
}

#pragma mark - UITableView Delegate

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
        [tableView setSeparatorColor:[UIColor clearColor]];
        
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
        [tableView setSeparatorColor:[UIColor lightGrayColor]];
        
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
            [cell.colorView setImageFromUIColor:color];
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
            
            ColorDetailsViewController *colorDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorDetailsViewController"];
            colorDetailViewController.colorName = colorName;
            [self.navigationController pushViewController:colorDetailViewController animated:YES];
        }
    }
}

@end
