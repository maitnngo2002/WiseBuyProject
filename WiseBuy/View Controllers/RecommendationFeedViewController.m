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
#import "AlertManager.h"
#import "ProgressHUDManager.h"
#import "JGProgressHUD/JGProgressHUD.h"

@interface RecommendationFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<Post *> *posts;
@property (nonatomic, strong) NSURL *buyLink;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

static NSString *const kConnectionSegue = @"connectionSegue";
static NSString *const kPostCellIdentifier = @"PostCell";
static NSString *const kPost = @"Post";
static NSString *const kCreateAt = @"createdAt";
static NSString *const kItemName = @"itemName";
static NSString *const kPrice = @"price";
static NSString *const kSellerName = @"sellerName";
static NSString *const kPostedBy = @"postedBy";
static NSString *const kFriendList = @"friendList";
static NSString *const kFirstName = @"first_name";
static NSString *const kLastName = @"last_name";
static NSString *const kImage = @"image";
static NSString *const kObjectId = @"objectId";
static NSString *const kProgressHUDText = @"Loading Posts...";

@implementation RecommendationFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                         action:@selector(queryPosts)
                         forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self queryPosts];
}

-(void) queryPosts {
    
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    
    progressHUD.textLabel.text = kProgressHUDText;
    [progressHUD showInView:self.view];

    [ProgressHUDManager setLoadingState:YES viewController:self];
    
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:kPost];
    [query orderByDescending:kCreateAt];
    [query includeKey:kItemName];
    [query includeKey:kPrice];
    [query includeKey:kSellerName];
    [query includeKey:kPostedBy];
    [query whereKey:kPostedBy containedIn:user[kFriendList]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = posts;
            [self.tableView reloadData];
            [progressHUD dismissAfterDelay:0.0 animated:YES];
            [self.refreshControl endRefreshing];
            [ProgressHUDManager setLoadingState:NO viewController:self];

        } else {
            NSLog(@"%@", error.description);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:kPostCellIdentifier];
    
    Post *post = self.posts[indexPath.row];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        PFQuery *query = [PFUser query];
        [query includeKey:kFirstName];
        [query includeKey:kLastName];
        [query includeKey:kImage];
        [query whereKey:kObjectId equalTo:post.user.objectId];
        NSArray *user = query.findObjects;

        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (user.count > 0) {
                PFFileObject *userImage = user[0][kImage];
                NSURL *url = [NSURL URLWithString:userImage.url];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img = [[UIImage alloc] initWithData:data];

                cell.userImageView.image = img;
                cell.usernameLabel.text = post.username;
                cell.userFullNameLabel.text = [NSString stringWithFormat:@"%@%@", user[0][kFirstName], user[0][kLastName]];

            }
            [cell setPost:post];
            self.buyLink = [NSURL URLWithString:post.link];

        });
    });
    
    return cell;
}

- (IBAction)didTapBuy:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:self.buyLink]) {
         [UIApplication.sharedApplication openURL:self.buyLink options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
             if (!success) {
                 [AlertManager cannotOpenLink:self];
             }
         }];
     }
    else {
        [AlertManager cannotOpenLink:self];
    }
}

- (IBAction)didTapFindConnections:(id)sender {
    [self performSegueWithIdentifier:kConnectionSegue sender:sender];
}


@end
