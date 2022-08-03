//
//  HistoryViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "HistoryViewController.h"
#import <JGProgressHUD/JGProgressHUD.h>
#import "DealsViewController.h"
#import "DatabaseManager.h"
#import "AlertManager.h"
#import "ItemCollectionViewCell.h"
#import "AppItem.h"
#import "AppDeal.h"
#import "ProgressHUDManager.h"

@interface HistoryViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray<Deal *> *deals;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSArray<AppItem *> *filteredItems;

@end

static NSString *const kItemHistorySegue = @"itemHistorySegue";
static NSString *const kItemCollectionViewCellIdentifier = @"ItemCollectionViewCell";

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    progressHUD.textLabel.text = @"Fetching history";
    [progressHUD showInView:self.view];

    [ProgressHUDManager setLoadingState:YES viewController:self];
    
    [DatabaseManager fetchRecentItems:^(NSArray<Item *> * _Nonnull items, NSError * _Nonnull error) {
        if (items.count > 0) {
            self.items = (NSMutableArray *) items;
            self.filteredItems = self.items;
            [self.collectionView reloadData];
            progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        }
        [progressHUD dismissAfterDelay:0.1 animated:YES];
        [ProgressHUDManager setLoadingState:NO viewController:self];
    }];
    
    [DatabaseManager fetchAllDeals:^(NSArray<Deal *> * _Nonnull deals, NSError * _Nonnull error) {
        if (deals.count > 0) {
            self.deals = deals;
        }
    }];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.definesPresentationContext = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.flowLayout.minimumLineSpacing = 1.25;
    self.flowLayout.minimumInteritemSpacing = 1.25;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (BOOL) itemHasDeals:(AppItem *)item {
    if (self.deals.count == 0) {
        return NO;
    }
    
    for (AppDeal *deal in self.deals) {
        if ([deal.item.identifier isEqualToString:item.identifier]) {
            return YES;
        }
    }
    return NO;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kItemCollectionViewCellIdentifier forIndexPath:indexPath];
    AppItem *currentItem = self.filteredItems[indexPath.row];
    [cell setItem:currentItem];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredItems.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat totalwidth = self.collectionView.bounds.size.width;
    CGFloat postersPerLine = 2;
    CGFloat dimensions = (totalwidth - self.flowLayout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    return CGSizeMake(dimensions, dimensions*1.3);
}

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    if (searchText) {
        if (searchText.length != 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
            self.filteredItems = [self.items filteredArrayUsingPredicate:predicate];
        }
        else {
            self.filteredItems = self.items;
        }
        
        [self.collectionView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    AppItem *currentItem = self.filteredItems[indexPath.row];
    if ([segue.identifier isEqualToString:kItemHistorySegue] && [self itemHasDeals:currentItem]) {
        DealsViewController *dealsController = [segue destinationViewController];
        dealsController.barcode = currentItem.barcode;
    }
    else {
        [AlertManager dealsNotFoundAlert:self errorType:NoDealFoundError];
    }
}

@end
