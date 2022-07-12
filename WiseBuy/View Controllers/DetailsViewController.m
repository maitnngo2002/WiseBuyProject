//
//  DetailsViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "DetailsViewController.h"
#import "AlertManager.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *sellerName;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.itemImageView.image = [UIImage imageWithData:self.deal.item.image];
    self.itemName.text = self.deal.item.name;
    self.sellerName.text = self.deal.sellerName;
    self.priceLabel.text = [NSNumberFormatter localizedStringFromNumber:self.deal.price numberStyle:NSNumberFormatterCurrencyStyle];
    self.descriptionLabel.text = self.deal.item.information;
}
- (IBAction)onTapBuy:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:self.deal.itemURL]) {
         [UIApplication.sharedApplication openURL:self.deal.itemURL options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
             if (success) {
             }
             else {
                 [AlertManager cannotOpenLink:self];
             }
         }];
     }
    else {
        [AlertManager cannotOpenLink:self];
    }
}
- (IBAction)onTapSave:(id)sender {
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
