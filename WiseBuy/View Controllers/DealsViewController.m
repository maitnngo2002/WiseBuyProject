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
    
//    [APIManager fetchDealsFromUPCDatabase:self.barcode];
//    [APIManager fetchDealsFromSearchUPCAPI:self.barcode];
//    [APIManager fetchDealsFromEbayAPI:self.barcode];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
