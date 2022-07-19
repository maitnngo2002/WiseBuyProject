//
//  FriendCell.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/18/22.
//

#import "FriendCell.h"

@implementation FriendCell

- (IBAction)didTapAddFriend:(id)sender {
    PFUser *user = [PFUser currentUser];

    if (self.chosenMode == 0) {
        if ([user[@"outgoingFriendRequests"] containsObject:self.cellUser.username]) {
            NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[@"outgoingFriendRequests"]];
            [requests removeObject:self.cellUser.username];
            user[@"outgoingFriendRequests"] = [NSArray arrayWithArray:requests];
            
            requests = [NSMutableArray arrayWithArray:self.cellUser[@"incomingFriendRequests"]];
            [requests removeObject:user.username];
            self.cellUser[@"incomingFriendRequests"] = [NSArray arrayWithArray:requests];
            
            [self postOtherUser:self.cellUser];
            [self postUser:user];
            [self updateLabels];
        } else {
            NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[@"outgoingFriendRequests"]];
            [requests addObject:self.cellUser.username];
            user[@"outgoingFriendRequests"] = [NSArray arrayWithArray:requests];
            
            requests = [NSMutableArray arrayWithArray:self.cellUser[@"incomingFriendRequests"]];
            [requests addObject:user.username];
                        
            self.cellUser[@"incomingFriendRequests"] = [NSArray arrayWithArray:requests];
            
            [self postUser:user];

            [self postOtherUser:self.cellUser];
            
            [self updateLabels];
        }
    } else if (self.chosenMode == 1) {
        NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[@"friendList"]];
        [mutableArr removeObject:self.cellUser.username];
        user[@"friendList"] = [NSArray arrayWithArray:mutableArr];
        
        mutableArr = [NSMutableArray arrayWithArray:self.cellUser[@"friendList"]];
        [mutableArr removeObject:user.username];
        self.cellUser[@"friendList"] = [NSArray arrayWithArray:mutableArr];
        
        [self postOtherUser:self.cellUser];
        [self postUser:user];
        [self updateLabels];
        
    } else if (self.chosenMode == 2) {
        NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[@"incomingFriendRequests"]];
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:user[@"friendList"]];
        
        [requests removeObject:self.cellUser.username];
        [friends addObject:self.cellUser.username];
        
        user[@"incomingFriendRequests"] = [NSArray arrayWithArray:requests];
        user[@"friendList"] = [NSArray arrayWithArray:friends];
        
        requests = [[NSMutableArray alloc] initWithArray:self.cellUser[@"outgoingFriendRequests"]];
        friends = [[NSMutableArray alloc] initWithArray:self.cellUser[@"friendList"]];
        
        [requests removeObject:user.username];
        [friends addObject:user.username];
        
        self.cellUser[@"outgoingFriendRequests"] = requests;
        self.cellUser[@"friendList"] = friends;
        
        [self postUser:user];
        [self postOtherUser:self.cellUser];
        
        [self updateLabels];
    }
}

-(void) postOtherUser:(PFUser *)otherUser {
    
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setValue:otherUser.username forKey:@"username"];
    [paramsDict setValue:otherUser[@"friendList"] forKey:@"friendList"];
    [paramsDict setValue:otherUser[@"incomingFriendRequests"] forKey:@"incomingFriendRequests"];
    [paramsDict setValue:otherUser[@"outgoingFriendRequests"] forKey:@"outgoingFriendRequests"];
    
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsDict];

    [PFCloud callFunctionInBackground:@"saveOtherUser" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
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
        if ([PFUser.currentUser[@"outgoingFriendRequests"] containsObject:self.cellUser.username]) {
            self.addFriendButton.tintColor = [UIColor systemTealColor];
            [self.addFriendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            self.addFriendButton.tintColor = [UIColor orangeColor];
            [self.addFriendButton setTitle:@"Add" forState:UIControlStateNormal];
        }
    } else if (self.chosenMode == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    }
   
}
@end
