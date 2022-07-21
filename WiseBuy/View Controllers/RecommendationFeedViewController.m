//
//  RecommendationFeedViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/17/22.
//

#import "RecommendationFeedViewController.h"
#import "Parse/Parse.h"
#import "PostCell.h"
#import "Post.h"

@interface RecommendationFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *posts;

@end

static NSString *const connectionSegue = @"connectionSegue";

@implementation RecommendationFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self queryPosts];
}

-(void) queryPosts {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"itemName"];
    [query includeKey:@"price"];
    [query includeKey:@"sellerName"];
    [query includeKey:@"postedBy"];
    [query whereKey:@"postedBy" containedIn:user[@"friendList"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.description);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    Post *post = self.posts[indexPath.row];
    
    PFQuery *query = [PFUser query];
    [query includeKey:@"first_name"];
    [query includeKey:@"last_name"];
    [query includeKey:@"image"];

    [query whereKey:@"objectId" equalTo:post.user.objectId];
    NSArray *user = query.findObjects;
    NSLog(@"%@", user[0][@"image"]);
    
    // TODO: fix this later
//    NSURL *url = [NSURL URLWithString:user[0][@"image"]];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    UIImage *img = [[UIImage alloc] initWithData:data];
//
//    cell.userImageView.image = img;
    cell.usernameLabel.text = post.username;
    cell.userFullNameLabel.text = [NSString stringWithFormat:@"%@%@", user[0][@"first_name"], user[0][@"last_name"]];
    cell.itemNameLabel.text = post.itemName;
    cell.priceLabel.text = post.price;
    cell.sellerLabel.text = post.sellerName;
    cell.linkLabel.text = post.itemLink;
    
    return cell;
}

- (IBAction)didTapFindConnections:(id)sender {
    [self performSegueWithIdentifier:connectionSegue sender:sender];
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
