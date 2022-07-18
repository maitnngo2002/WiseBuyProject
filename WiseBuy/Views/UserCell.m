//
//  UserCell.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/15/22.
//

#import "UserCell.h"
#import "User.h"

@implementation UserCell

- (void)setUser:(User *)user {
    _user = user;
    self.fullNameLabel.text = [User getFullName:_user];
    self.usernameLabel.text = _user.username;
    self.profileImageView.image = [UIImage imageWithData:_user.profileImage];
}

@end
