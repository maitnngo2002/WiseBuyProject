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
    
    [APIManager fetchDealsFromUPCDatabase:self.barcode];
    [APIManager fetchDealsFromSearchUPCAPI:self.barcode];
    [APIManager fetchDealsFromEbayAPI:self.barcode];

    [DatabaseManager fetchItem:self.barcode viewController:self withCompletion:^(NSArray * _Nonnull deals, NSError * _Nonnull error) {
        if (deals.count > 0) {
            self.deals = (NSMutableArray *) deals;

            [self.tableView reloadData];
        }
        else {
            //alert
            NSLog(@"error %@", error.localizedDescription);
        }
    }];
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
