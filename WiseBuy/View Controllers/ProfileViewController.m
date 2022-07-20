//
//  ProfileViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "ProfileViewController.h"
#import "DetailsViewController.h"
#import "DatabaseManager.h"
#import "AlertManager.h"
#import "DealCell.h"
#import "UserCell.h"
#import "User.h"
#import "JGProgressHUD/JGProgressHUD.h"
#import "ProgressHUDManager.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) User *user;

@end

static NSString *const settingsSegue = @"settingsSegue";
static NSString *const historySegue = @"historySegue";

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil]  forCellReuseIdentifier:@"UserCell"];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    progressHUD.textLabel.text = @"Fetching profile...";
    [progressHUD showInView:self.view];
    [ProgressHUDManager setLoadingState:YES viewController:self];
    [DatabaseManager getCurrentUser:^(User * _Nonnull user) {
         if (user) {
             [self setUser:user];
             [self.tableView reloadData];
             progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
         }
        [progressHUD dismissAfterDelay:0.1 animated:YES];
        [ProgressHUDManager setLoadingState:NO viewController:self];
     }];
    
}

- (void)setUser:(User *)user {
    _user = user;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        cell.delegate = self;
        [cell setUser:_user];
        return cell;
    }
    else {
        DealCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DealCell"];
        AppDeal *deal = _user.savedDeals[indexPath.row - 1];
        [cell setDeal:deal];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _user.savedDeals.count + 1;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDeal *deal = _user.savedDeals[indexPath.row - 1];
    UIContextualAction *unsaveAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Unsave" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [DatabaseManager unsaveDeal:deal withCompletion:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                [AlertManager cannotSaveDeal:self];
            }
        }];
        [self.user.savedDeals removeObjectAtIndex:indexPath.row - 1];
        [self.tableView reloadData];
    }];
    UISwipeActionsConfiguration *actionConfigurations = [UISwipeActionsConfiguration configurationWithActions:@[unsaveAction]];
    return actionConfigurations;
    
}

- (void)userCell:(UserCell *)userCell didTapProfileImage:(UIImage *)image {
    UIImageView *fullScreenImageView = [[UIImageView alloc] initWithImage:userCell.profileImageView.image];
    fullScreenImageView.frame = [[UIScreen mainScreen] bounds];
    fullScreenImageView.backgroundColor = [UIColor blackColor];
    fullScreenImageView.contentMode = UIViewContentModeScaleAspectFit;
    fullScreenImageView.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullScreenImage:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [fullScreenImageView addGestureRecognizer:swipeRecognizer];
    fullScreenImageView.alpha = 0;
    [UIView animateWithDuration:0.625 animations:^{
        [self.view addSubview:fullScreenImageView];
        [self.navigationController setNavigationBarHidden:YES];
        [self.tabBarController.tabBar setHidden:YES];
        fullScreenImageView.alpha = 1;
    }];
}

- (void)dismissFullScreenImage:(UISwipeGestureRecognizer *)sender {
    self.view.alpha = 0;
    [UIView animateWithDuration:0.65 animations:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self.tabBarController.tabBar setHidden:NO];
        [sender.view removeFromSuperview];
        self.view.alpha = 1;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    [self updateProfileImage: originalImage ?: editedImage];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateProfileImage:(UIImage *)image {
    CGSize size = CGSizeMake(400, 400);
    _user.profileImage = UIImagePNGRepresentation([self resizeImage:image withSize:size]);
}

- (void)pickImage {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
