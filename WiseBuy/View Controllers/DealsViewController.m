//
//  DealsViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "DealsViewController.h"
#import "DealCell.h"
#import "DatabaseManager.h"
#import "APIManager.h"
#import "AppDeal.h"
#import "DetailsViewController.h"
#import "JGProgressHUD/JGProgressHUD.h"
#import "AlertManager.h"

@interface DealsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *deals;
@property (strong, nonatomic) NSMutableArray *savedDeals;

@end

@implementation DealsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (![DatabaseManager checkIfItemAlreadyExist:self.barcode]) {
        [APIManager fetchDealsFromEbayAPI:self.barcode];
        [APIManager fetchDealsFromUPCDatabase:self.barcode];
        [APIManager fetchDealsFromSearchUPCAPI:self.barcode];
    }
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    
    HUD.textLabel.text = @"Waiting for deals to be displayed";
    [HUD showInView:self.view];

    [self setLoadingState:YES viewController:self];
    
    // TODO: Hard-code barcode value for testing purpose. Remove later.
    [DatabaseManager fetchItem:@"888462323772" viewController:self withCompletion:^(NSArray * _Nonnull deals, NSError * _Nonnull error) {
        if (deals.count > 0) {
            self.deals = (NSMutableArray *) deals;

            NSLog(@"%lu", (unsigned long)self.deals.count);
            [self.tableView reloadData];
            [HUD dismissAfterDelay:0.1 animated:YES];
                [self setLoadingState:NO viewController:self];
        }
        else {
            NSLog(@"error %@", error.localizedDescription);
        }
    }];
}

- (void)setLoadingState:(BOOL)isFetching viewController:(UIViewController *)vc {
    if (isFetching) {
        vc.view.userInteractionEnabled = NO;
        vc.view.alpha = 0.5f;
        [vc.navigationController setNavigationBarHidden:YES];
        [vc.tabBarController.tabBar setHidden:YES];
    }
    else {
        vc.view.userInteractionEnabled = YES;
        [vc.navigationController setNavigationBarHidden:NO];
        [vc.tabBarController.tabBar setHidden:NO];
        vc.view.alpha = 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DealCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    
    AppDeal *deal = self.deals[indexPath.row];
    cell.itemImage.image = [UIImage imageWithData:deal.item.image];
    cell.itemName.text = deal.item.name;
    cell.sellerName.text = deal.sellerName;
    cell.price.text = [deal.price stringValue];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deals.count;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDeal *deal = self.deals[indexPath.row];

    UIContextualAction *saveAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Save" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [DatabaseManager saveDeal:deal withCompletion:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                [AlertManager cannotSaveDeal:self];
            }
            completionHandler(YES);
        }];
        if (self.savedDeals.count == 0) {
            self.savedDeals = [NSMutableArray array];
        }
        [self.savedDeals addObject:deal];
        [self.tableView reloadData];
    }];

    UIContextualAction *unsaveAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Unsave" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [DatabaseManager unsaveDeal:deal withCompletion:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                [AlertManager cannotSaveDeal:self];
            }
            completionHandler(YES);
        }];
        [self.tableView reloadData];
    }];

    if ([self alreadySaved:deal]) {
        UISwipeActionsConfiguration *actionConfigurations = [UISwipeActionsConfiguration configurationWithActions:@[unsaveAction]];
        return actionConfigurations;
    }
    else {
        UISwipeActionsConfiguration *actionConfigurations = [UISwipeActionsConfiguration configurationWithActions:@[saveAction]];
        return actionConfigurations;
    }
}

- (BOOL)alreadySaved:(AppDeal *)deal {
    if (self.savedDeals.count == 0) {
        return NO;
    }
    for (AppDeal *savedDeal in self.savedDeals) {
        if ([deal.identifier isEqualToString:savedDeal.identifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"detailsSegue"]) {
         UITableViewCell *tappedCell = sender;
         NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
         AppDeal *currentDeal = self.deals[indexPath.row];
         DetailsViewController *detailsViewController = [segue destinationViewController];
         detailsViewController.deal = currentDeal;
         [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     }
}

@end
