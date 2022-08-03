//
//  DetailsViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "DetailsViewController.h"
#import "AlertManager.h"
#import "JGProgressHUD.h"
#import "DatabaseManager.h"
#import "ProgressHUDManager.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *sellerName;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property BOOL alreadySaved;

@end

static NSString *const kSave = @"Save";
static NSString *const kUnsave = @"Unsave";
static NSString *const kProgressHUDText = @"Loading...";

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *url = [NSURL URLWithString:self.deal.item.image.url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    self.itemImageView.image = image;
    self.itemName.text = self.deal.item.name;
    self.sellerName.text = self.deal.sellerName;
    self.priceLabel.text = [NSNumberFormatter localizedStringFromNumber:self.deal.price numberStyle:NSNumberFormatterCurrencyStyle];
    self.descriptionLabel.text = self.deal.item.information;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    progressHUD.textLabel.text = kProgressHUDText;
    
    [progressHUD showInView:self.view];
    [ProgressHUDManager setLoadingState:YES viewController:self];
    
    [DatabaseManager isCurrentDealSaved:self.deal.identifier withCompletion:^(bool hasDeal, NSError * _Nonnull error) {
        if (error) {
            progressHUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
        }
        else if (hasDeal) {
            self.alreadySaved = YES;
            [self setSaveButtonOnDealStatus];
        }
        else {
            self.alreadySaved = NO;
            [self setSaveButtonOnDealStatus];
        }
        [progressHUD dismissAfterDelay:0.1 animated:YES];
        
        [ProgressHUDManager setLoadingState:NO viewController:self];
    }];
}

- (void)setSaveButtonOnDealStatus {
    if (self.alreadySaved) {
        [self.saveButton setTitle:kUnsave forState:UIControlStateNormal];
        [self.saveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else {
        [self.saveButton setTitle:kSave forState:UIControlStateNormal];
        [self.saveButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    }
}

- (IBAction)onTapBuy:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:self.deal.itemURL]) {
         [UIApplication.sharedApplication openURL:self.deal.itemURL options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
             if (!success) {
                 [AlertManager cannotOpenLink:self];
             }
         }];
     }
    else {
        [AlertManager cannotOpenLink:self];
    }
}
- (IBAction)onTapSave:(id)sender {
    if (!self.alreadySaved) {
        [DatabaseManager saveDeal:self.deal withCompletion:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                [AlertManager cannotSaveDeal:self];
            }
            else {
                self.alreadySaved = YES;
                [self setSaveButtonOnDealStatus];
            }
        }];
    }
    else {
        [DatabaseManager unsaveDeal:self.deal withCompletion:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                [AlertManager cannotSaveDeal:self];
            }
            else {
                self.alreadySaved = NO;
                [self setSaveButtonOnDealStatus];
            }
        }];
    }
}

- (IBAction)onTapImage:(id)sender {
    UIImageView *fullScreenImageView = [[UIImageView alloc] initWithImage:self.itemImageView.image];
    fullScreenImageView.frame = [[UIScreen mainScreen] bounds];
    fullScreenImageView.backgroundColor = [UIColor blackColor];
    fullScreenImageView.contentMode = UIViewContentModeScaleAspectFit;
    fullScreenImageView.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullScreenImage:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [fullScreenImageView addGestureRecognizer:swipeRecognizer];
    fullScreenImageView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view addSubview:fullScreenImageView];
        [self.navigationController setNavigationBarHidden:YES];
        [self.tabBarController.tabBar setHidden:YES];
        fullScreenImageView.alpha = 1;
    }];
}

- (void)dismissFullScreenImage:(UISwipeGestureRecognizer *)sender {
    self.view.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self.tabBarController.tabBar setHidden:NO];
        [sender.view removeFromSuperview];
        self.view.alpha = 1;
    }];
}

@end
