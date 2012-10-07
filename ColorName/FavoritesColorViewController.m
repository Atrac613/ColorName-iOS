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

@interface FavoritesColorViewController ()

@end

@implementation FavoritesColorViewController

@synthesize tableView;
@synthesize colorList;
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
    return @"Japanese";
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
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    
    TbColorName *colorName = (TbColorName*)[colorList objectAtIndex:indexPath.row];
    
    ColorDetailViewController *colorDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorDetailViewController"];
    colorDetailViewController.colorName = colorName;
    [self.navigationController pushViewController:colorDetailViewController animated:YES];
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

@end
