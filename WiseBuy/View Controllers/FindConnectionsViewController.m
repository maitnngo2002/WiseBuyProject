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

static NSString *const kFriendCellIdentifier = @"FriendCell";
static NSString *const kAdd = @"Add";
static NSString *const kRemove = @"Remove";
static NSString *const kCancel = @"Cancel";
static NSString *const kAccept = @"Accept";
static NSString *const kFriendList = @"friendList";
static NSString *const kOutgoingFriendRequests = @"outgoingFriendRequests";
static NSString *const kIncomingFriendRequests = @"incomingFriendRequests";
static NSString *const kUsername = @"username";
static NSString *const kName = @"name";
static NSString *const kFirstName = @"first_name";
static NSString *const kLastName = @"last_name";
static NSString *const kImage = @"image";
static NSString *const kLoadFriends = @"loadFriends";

@implementation FindConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchBar.delegate = self;
    
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriends) name:kLoadFriends object:nil];
    
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
    FriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier];
    if (self.friends > 0) {
        PFUser *friend = self.friends[indexPath.row];
        cell.cellUser = friend;
        cell.nameLabel.text = [NSString stringWithFormat:@"%@%@", friend[kFirstName] , friend[kLastName]];
        cell.usernameLabel.text = friend[kUsername];
        
        PFFileObject *userImage = cell.cellUser[kImage];
        NSURL *url = [NSURL URLWithString:userImage.url];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        cell.profileImageView.image = img;
        
        if (self.segControl.selectedSegmentIndex == 1) {
            [cell.addFriendButton setTitle:kRemove forState:UIControlStateNormal];
            [cell.addFriendButton setTintColor:[UIColor systemRedColor]];
            cell.chosenMode = 1;
            
        } else if (self.segControl.selectedSegmentIndex == 0) {
            [cell.addFriendButton setTitle:kAdd forState:UIControlStateNormal];
            cell.chosenMode = 0;
            if ([self.user[kOutgoingFriendRequests] containsObject:friend.username]) {
                cell.addFriendButton.tintColor = [UIColor systemTealColor];
                [cell.addFriendButton setTitle:kCancel forState:UIControlStateNormal];
            } else {
                [cell.addFriendButton setTintColor:[UIColor systemIndigoColor]];
            }
        } else {
            [cell.addFriendButton setTitle:kAccept forState:UIControlStateNormal];
            [cell.addFriendButton setTintColor:[UIColor systemOrangeColor]];
            cell.chosenMode = 2;
        }
        
        if (self.segControl.selectedSegmentIndex == 0) {
            [cell.addFriendButton setTitle:kAdd forState:UIControlStateNormal];
            cell.chosenMode = 0;
            if ([self.user[kOutgoingFriendRequests] containsObject:friend.username]) {
                cell.addFriendButton.tintColor = [UIColor systemTealColor];
                [cell.addFriendButton setTitle:kCancel forState:UIControlStateNormal];
            } else {
                [cell.addFriendButton setTintColor:[UIColor systemIndigoColor]];
            }
        } else if (self.segControl.selectedSegmentIndex == 1) {
            [cell.addFriendButton setTitle:kRemove forState:UIControlStateNormal];
            [cell.addFriendButton setTintColor:[UIColor systemRedColor]];
            cell.chosenMode = 1;
        } else {
            [cell.addFriendButton setTitle:kAccept forState:UIControlStateNormal];
            [cell.addFriendButton setTintColor:[UIColor systemOrangeColor]];
            cell.chosenMode = 2;
        }
    }
    return cell;
}

-(void) friendQuery:(NSString *)container {
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = [self.user[kFriendList] count];
    [query includeKey:kUsername];
    [query whereKey:kUsername containedIn:self.user[kFriendList]];
    [query includeKey:kName];

    if(![container isEqualToString:@""]) {
        [query whereKey:kUsername containsString:container];
        [query whereKey:kName containsString:container];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray<User *> *friends, NSError *error) {
        if (friends != nil) {
            self.friends = friends;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
}

-(void) addQuery:(NSString *)container {
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = 20;
    [query includeKey:kUsername];
    [query whereKey:kUsername notContainedIn:self.user[kFriendList]];
    [query whereKey:kUsername notEqualTo:self.user.username];
    if(![container isEqualToString:@""]) {
        [query whereKey:kUsername containsString:container];
    } else {
        [query whereKey:kUsername containedIn:self.user[kOutgoingFriendRequests]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray<User *> *friends, NSError *error) {
        if (friends != nil) {
            self.friends = friends;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void) requestQuery:(NSString *)container {
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = 20;
    [query includeKey:kUsername];
    [query whereKey:kUsername notContainedIn:self.user[kFriendList]];
    [query whereKey:kUsername notEqualTo:self.user.username];
    [query whereKey:kUsername containedIn:self.user[kIncomingFriendRequests]];
    if(![container isEqualToString:@""]) {
        [query whereKey:kUsername containsString:container];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray<User *> *friends, NSError *error) {
        if (friends != nil) {
            self.friends = friends;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }

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
