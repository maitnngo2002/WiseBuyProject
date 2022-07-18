//
//  FindConnectionsViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/17/22.
//

#import "FindConnectionsViewController.h"
#import "UserCell.h"
#import "Parse/Parse.h"
#import "User.h"

@interface FindConnectionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *users;

@end

@implementation FindConnectionsViewController

-(void)viewWillAppear:(BOOL)animated {
    [self fetchUsers];

    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;


    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        [self fetchUsers];
        dispatch_async(dispatch_get_main_queue(), ^(void){
        });
    });
    
}

- (void)fetchUsers {
    PFQuery *query = [PFUser query];
    self.users = [query findObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    User *user = self.users[indexPath.row - 1];
    [cell setUser:user];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

@end
