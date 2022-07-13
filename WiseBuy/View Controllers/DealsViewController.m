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

@interface DealsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *deals;

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
    NSLog(@"%@", self.barcode);
//    [APIManager fetchDealsFromUPCDatabase:@"53039031"];

    if (![DatabaseManager checkIfItemAlreadyExist:@"53039031"]) {
        [APIManager fetchDealsFromEbayAPI:@"53039031"];
        [APIManager fetchDealsFromUPCDatabase:self.barcode];
        [APIManager fetchDealsFromSearchUPCAPI:self.barcode];
    }
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    HUD.textLabel.text = @"Waiting for deals to be displayed";
    [HUD showInView:self.view];
    
    [self setLoadingState:YES viewController:self];
    
    [DatabaseManager fetchItem:@"53039031" viewController:self withCompletion:^(NSArray * _Nonnull deals, NSError * _Nonnull error) {
        if (deals.count > 0) {
            self.deals = (NSMutableArray *) deals;

            [self.tableView reloadData];
            
            [HUD dismissAfterDelay:0.1 animated:YES];
            [self setLoadingState:NO viewController:self];
        }
        else {
            //alert
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
