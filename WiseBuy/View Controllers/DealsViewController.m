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
#import "ProgressHUDManager.h"

@interface DealsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *deals;
@property (strong, nonatomic) NSMutableArray *savedDeals;

@end

static NSString *const detailsSegue = @"detailsSegue";

@implementation DealsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (![DatabaseManager checkIfItemAlreadyExist:self.barcode]) {
                [APIManager fetchDealsFromAPIs:self.barcode];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self queryItem];
        });
    });
}

- (void)queryItem{
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    
    progressHUD.textLabel.text = @"Waiting for deals to be displayed";
    [progressHUD showInView:self.view];

    [ProgressHUDManager setLoadingState:YES viewController:self];
    
    [DatabaseManager fetchItem:self.barcode viewController:self withCompletion:^(NSArray * _Nonnull deals, NSError * _Nonnull error) {
        if (deals.count > 0) {
            self.deals = (NSMutableArray *) deals;

            [DatabaseManager fetchSavedDeals:^(NSArray * _Nonnull deals, NSError * _Nonnull error) {
                if (self.deals.count == 0) {
                    self.savedDeals = [NSMutableArray array];
                }
                else {
                    self.savedDeals = (NSMutableArray *) deals;
                }
                [self.tableView reloadData];
                
                [progressHUD dismissAfterDelay:0.1 animated:YES];
                [ProgressHUDManager setLoadingState:NO viewController:self];
            }];
        }
        else {
            NSLog(@"error %@", error.localizedDescription);
        }
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DealCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    
    AppDeal *deal = self.deals[indexPath.row];
    [cell setDeal:deal];
    
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
    saveAction.backgroundColor = [UIColor systemBlueColor];

    UIContextualAction *unsaveAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Unsave" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [DatabaseManager unsaveDeal:deal withCompletion:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                [AlertManager cannotSaveDeal:self];
            }
            completionHandler(YES);
        }];
        [self removeDealWithIdentifier:deal.identifier];
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

- (void)removeDealWithIdentifier:(NSString *)identifier {
    AppDeal *dealToDelete;
    for (AppDeal *savedDeal in self.savedDeals) {
        if ([savedDeal.identifier isEqualToString:identifier]) {
            dealToDelete = savedDeal;
            break;
        }
    }
    [self.savedDeals removeObject:dealToDelete];
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
     if ([segue.identifier isEqualToString:detailsSegue]) {
         UITableViewCell *tappedCell = sender;
         NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
         AppDeal *currentDeal = self.deals[indexPath.row];
         DetailsViewController *detailsViewController = [segue destinationViewController];
         detailsViewController.deal = currentDeal;
         [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     }
}

@end
