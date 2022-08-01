//
//  ComposeViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/19/22.
//

#import "ComposeViewController.h"
#import "Parse/Parse.h"
#import "AlertManager.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemName;
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UITextField *sellerName;
@property (weak, nonatomic) IBOutlet UITextField *buyLink;

@end
static NSString *const kPostClass = @"Post";
static NSString *const kItemName = @"itemName";
static NSString *const kPrice = @"price";
static NSString *const kSellerName = @"sellerName";
static NSString *const kLink = @"link";
static NSString *const kUser = @"user";
static NSString *const kPostedBy = @"postedBy";

@implementation ComposeViewController

- (void)viewDidLoad {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)dismissKeyboard {
    [self.itemName resignFirstResponder];
    [self.price resignFirstResponder];
    [self.sellerName resignFirstResponder];
    [self.buyLink resignFirstResponder];
}

- (IBAction)didTapDismiss:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)didTapPost:(id)sender {
    PFObject *post = [PFObject objectWithClassName:kPostClass];
    post[kItemName] = self.itemName.text;
    post[kPrice] = self.price.text;
    post[kSellerName] = self.sellerName.text;
    post[kLink] = self.buyLink.text;

    PFUser *currentUser = [PFUser currentUser];
    post[kUser] = currentUser;
    post[kPostedBy] = currentUser.username;
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            [AlertManager cannotPostDeal:self];
            NSLog(@"%@", error.description);
        } else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

@end
