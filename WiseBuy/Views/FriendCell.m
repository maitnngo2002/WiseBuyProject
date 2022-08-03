//
//  FriendCell.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/18/22.
//

#import "FriendCell.h"

static NSString *const kOutgoingFriendRequests = @"outgoingFriendRequests";
static NSString *const kIncomingFriendRequests = @"incomingFriendRequests";
static NSString *const kFriendList = @"friendList";
static NSString *const kCloudFunctionName = @"saveOtherUser";
static NSString *const kUsername = @"username";
static NSString *const kAdd = @"Add";
static NSString *const kCancel = @"Cancel";
static NSString *const kLoadFriends = @"loadFriends";

@implementation FriendCell

- (IBAction)didTapAddFriend:(id)sender {
    PFUser *user = [PFUser currentUser];

    if (self.chosenMode == 0) {
        if ([user[kOutgoingFriendRequests] containsObject:self.cellUser.username]) {
            NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[kOutgoingFriendRequests]];
            [requests removeObject:self.cellUser.username];
            user[kOutgoingFriendRequests] = [NSArray arrayWithArray:requests];
            
            requests = [NSMutableArray arrayWithArray:self.cellUser[kIncomingFriendRequests]];
            [requests removeObject:user.username];
            self.cellUser[kIncomingFriendRequests] = [NSArray arrayWithArray:requests];
            
            [self postOtherUser:self.cellUser];
            [self postUser:user];
            [self updateLabels];
        } else {
            NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[kOutgoingFriendRequests]];
            [requests addObject:self.cellUser.username];
            user[kOutgoingFriendRequests] = [NSArray arrayWithArray:requests];
            
            requests = [NSMutableArray arrayWithArray:self.cellUser[kIncomingFriendRequests]];
            [requests addObject:user.username];
                        
            self.cellUser[kIncomingFriendRequests] = [NSArray arrayWithArray:requests];
            
            [self postUser:user];

            [self postOtherUser:self.cellUser];
            
            [self updateLabels];
        }
    } else if (self.chosenMode == 1) {
        NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[kFriendList]];
        [mutableArr removeObject:self.cellUser.username];
        user[kFriendList] = [NSArray arrayWithArray:mutableArr];
        
        mutableArr = [NSMutableArray arrayWithArray:self.cellUser[kFriendList]];
        [mutableArr removeObject:user.username];
        self.cellUser[kFriendList] = [NSArray arrayWithArray:mutableArr];
        
        [self postOtherUser:self.cellUser];
        [self postUser:user];
        [self updateLabels];
        
    } else if (self.chosenMode == 2) {
        NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[kIncomingFriendRequests]];
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:user[kFriendList]];
        
        [requests removeObject:self.cellUser.username];
        [friends addObject:self.cellUser.username];
        
        user[kIncomingFriendRequests] = [NSArray arrayWithArray:requests];
        user[kFriendList] = [NSArray arrayWithArray:friends];
        
        requests = [[NSMutableArray alloc] initWithArray:self.cellUser[kOutgoingFriendRequests]];
        friends = [[NSMutableArray alloc] initWithArray:self.cellUser[kFriendList]];
        
        [requests removeObject:user.username];
        [friends addObject:user.username];
        
        self.cellUser[kOutgoingFriendRequests] = requests;
        self.cellUser[kFriendList] = friends;
        
        [self postUser:user];
        [self postOtherUser:self.cellUser];
        
        [self updateLabels];
    }
}

-(void) postOtherUser:(PFUser *)otherUser {
    
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setValue:otherUser.username forKey:kUsername];
    [paramsDict setValue:otherUser[kFriendList] forKey:kFriendList];
    [paramsDict setValue:otherUser[kIncomingFriendRequests] forKey:kIncomingFriendRequests];
    [paramsDict setValue:otherUser[kOutgoingFriendRequests] forKey:kOutgoingFriendRequests];
    
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsDict];

    [PFCloud callFunctionInBackground:kCloudFunctionName withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error saving other user's data");
        }
    }];
}

-(void) postUser:(PFUser *)user {
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error saving current user's data");
        }
    }];
}

-(void) updateLabels {
    if (self.chosenMode == 0) {
        if ([PFUser.currentUser[kOutgoingFriendRequests] containsObject:self.cellUser.username]) {
            self.addFriendButton.tintColor = [UIColor systemTealColor];
            [self.addFriendButton setTitle:kCancel forState:UIControlStateNormal];
        } else {
            self.addFriendButton.tintColor = [UIColor orangeColor];
            [self.addFriendButton setTitle:kAdd forState:UIControlStateNormal];
        }
    } else if (self.chosenMode == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFriends object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFriends object:nil];
    }
   
}
@end
