//
//  ComposeViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/19/22.
//

#import "ComposeViewController.h"
#import "Parse/Parse.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemName;
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UITextField *sellerName;
@property (weak, nonatomic) IBOutlet UITextField *buyLink;

@end

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
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    post[@"itemName"] = self.itemName.text;
    post[@"price"] = self.price.text;
    post[@"sellerName"] = self.sellerName.text;
    post[@"link"] = self.buyLink.text;

    PFUser *currentUser = [PFUser currentUser];
    post[@"user"] = currentUser;
    post[@"postedBy"] = currentUser.username;
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            NSLog(@"%@", error.description);
            // TODO: Send an alert to user saying there's an error
        } else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
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
