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

static NSString *const kConnectionSegue = @"connectionSegue";

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
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        PFQuery *query = [PFUser query];
        [query includeKey:@"first_name"];
        [query includeKey:@"last_name"];
        [query includeKey:@"image"];

        [query whereKey:@"objectId" equalTo:post.user.objectId];
        NSArray *user = query.findObjects;

        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (user) {
                PFFileObject *userImage = user[0][@"image"];
                NSURL *url = [NSURL URLWithString:userImage.url];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img = [[UIImage alloc] initWithData:data];

                cell.userImageView.image = img;
                cell.usernameLabel.text = post.username;
                cell.userFullNameLabel.text = [NSString stringWithFormat:@"%@%@", user[0][@"first_name"], user[0][@"last_name"]];

            }
            cell.itemNameLabel.text = post.itemName;
            cell.priceLabel.text = post.price;
            cell.sellerLabel.text = post.sellerName;
            cell.linkLabel.text = @"amazon.com"; // TODO: fix this later
            
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"amazon.com"];
            [str addAttribute: NSLinkAttributeName value: @"http://www.google.com" range: NSMakeRange(0, str.length)];
            cell.linkLabel.attributedText = str;
            
        });
    });
    
    return cell;
}


- (IBAction)didTapFindConnections:(id)sender {
    [self performSegueWithIdentifier:kConnectionSegue sender:sender];
}


@end
