//
//  ProfileViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static NSString *const settingsSegue = @"settingsSegue";
static NSString *const historySegue = @"historySegue";

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapSettings:(id)sender {
    [self performSegueWithIdentifier:settingsSegue sender:sender];
}
- (IBAction)didTapHistory:(id)sender {
    [self performSegueWithIdentifier:historySegue sender:sender];
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
