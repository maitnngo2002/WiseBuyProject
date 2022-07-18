//
//  RecommendationFeedViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/17/22.
//

#import "RecommendationFeedViewController.h"

@interface RecommendationFeedViewController ()

@end

@implementation RecommendationFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapFindConnections:(id)sender {
    [self performSegueWithIdentifier:@"connectionSegue" sender:sender];
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
