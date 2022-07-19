//
//  FindConnectionsViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/17/22.
//

#import "FindConnectionsViewController.h"
#import "Parse/Parse.h"
#import "User.h"
#import "FriendCell.h"

@interface FindConnectionsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSArray *friends;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation FindConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchBar.delegate = self;
    
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriends) name:@"loadFriends" object:nil];
    
    [self setupActivityIndicator];
    
    self.user = [PFUser currentUser];

    [self friendQuery:self.searchBar.text];
    [self.tableView reloadData];
    
}

-(void)loadFriends {
    if (self.segControl.selectedSegmentIndex == 0) {
        [self addQuery:self.searchBar.text];
    } else if (self.segControl.selectedSegmentIndex == 1) {
        [self friendQuery:self.searchBar.text];
    } else if(self.segControl.selectedSegmentIndex == 2) {
        [self requestQuery:self.searchBar.text];
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    PFUser *friend = self.friends[indexPath.row];
    cell.cellUser = friend;
    cell.nameLabel.text = [NSString stringWithFormat:@"%@%@", friend[@"first_name"] , friend[@"last_name"]];
    cell.usernameLabel.text = friend[@"username"];
    
    // TODO: Assign the profileImageView later
    // cell.profileImageView.image = [UIImage imageNamed:cell.cellUser[@"image"]];
    
    if(self.segControl.selectedSegmentIndex == 1) {
        [cell.addFriendButton setTitle:@"Remove" forState:UIControlStateNormal];
        [cell.addFriendButton setTintColor:[UIColor systemRedColor]];
        cell.chosenMode = 1;
    } else if (self.segControl.selectedSegmentIndex == 0) {
        [cell.addFriendButton setTitle:@"Add" forState:UIControlStateNormal];
        cell.chosenMode = 0;
        if([self.user[@"outgoingFriendRequests"] containsObject:friend.username]) {
            cell.addFriendButton.tintColor = [UIColor systemTealColor];
            [cell.addFriendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            [cell.addFriendButton setTintColor:[UIColor systemIndigoColor]];
        }
    } else {
        [cell.addFriendButton setTitle:@"Accept" forState:UIControlStateNormal];
        [cell.addFriendButton setTintColor:[UIColor systemOrangeColor]];
        cell.chosenMode = 2;
    }
    
    if(self.segControl.selectedSegmentIndex == 0) {
        [cell.addFriendButton setTitle:@"Add" forState:UIControlStateNormal];
        cell.chosenMode = 0;
        if([self.user[@"outgoingFriendRequests"] containsObject:friend.username]) {
            cell.addFriendButton.tintColor = [UIColor systemTealColor];
            [cell.addFriendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            [cell.addFriendButton setTintColor:[UIColor systemIndigoColor]];
        }
    } else if (self.segControl.selectedSegmentIndex == 1) {
        [cell.addFriendButton setTitle:@"Remove" forState:UIControlStateNormal];
        [cell.addFriendButton setTintColor:[UIColor systemRedColor]];
        cell.chosenMode = 1;
    } else {
        [cell.addFriendButton setTitle:@"Accept" forState:UIControlStateNormal];
        [cell.addFriendButton setTintColor:[UIColor systemOrangeColor]];
        cell.chosenMode = 2;
    }
    return cell;
}

-(void) friendQuery:(NSString *)container {
    // construct query
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = [self.user[@"friendList"] count];
    [query includeKey:@"username"];
    [query whereKey:@"username" containedIn:self.user[@"friendList"]];
    [query includeKey:@"name"];

    if(![container isEqualToString:@""]) {
        [query whereKey:@"username" containsString:container];
        [query whereKey:@"name" containsString:container];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            self.friends = friends;
            NSLog(@"Received friends! %@", self.friends);
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
}

-(void) addQuery:(NSString *)container {
    // construct query
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = 20;
    [query includeKey:@"username"];
    [query whereKey:@"username" notContainedIn:self.user[@"friendList"]];
    [query whereKey:@"username" notEqualTo:self.user.username];
    if(![container isEqualToString:@""]) {
        [query whereKey:@"username" containsString:container];
    } else {
        [query whereKey:@"username" containedIn:self.user[@"outgoingFriendRequests"]];
    }
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            // do something with the array of object returned by the call
            self.friends = friends;
            NSLog(@"Received friends! %@", self.friends);
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void) requestQuery:(NSString *)container {
    // construct query
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = 50;
    [query includeKey:@"username"];
    [query whereKey:@"username" notContainedIn:self.user[@"friendList"]];
    [query whereKey:@"username" notEqualTo:self.user.username];
    [query whereKey:@"username" containedIn:self.user[@"incomingFriendRequests"]];
    if(![container isEqualToString:@""]) {
        [query whereKey:@"username" containsString:container];
    }
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            // do something with the array of object returned by the call
            self.friends = friends;
            NSLog(@"Received friends! %@", self.friends);
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
    //Mkaes the animations nicer for when cells are selected
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }

// If the segment controller is changed, reload the information and requery
- (IBAction)segChanged:(id)sender {
    if(self.segControl.selectedSegmentIndex == 1) {
        self.friends = nil;
        [self friendQuery:self.searchBar.text];
    } else if(self.segControl.selectedSegmentIndex == 0) {
        self.friends = nil;
        [self addQuery:self.searchBar.text];
    } else {
        self.friends = nil;
        [self requestQuery:self.searchBar.text];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(self.segControl.selectedSegmentIndex == 1) {
        [self friendQuery:[searchText lowercaseString]];
        [self.tableView reloadData];
    } else if(self.segControl.selectedSegmentIndex == 0) {
        [self addQuery:[searchText lowercaseString]];
        [self.tableView reloadData];
    } else {
        [self requestQuery:[searchText lowercaseString]];
        [self.tableView reloadData];
    }
}

-(void) setupActivityIndicator{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = true;
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [self.view addSubview:self.activityIndicator];
}

@end
