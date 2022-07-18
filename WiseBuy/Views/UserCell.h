//
//  UserCell.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "User.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol UserCellDelegate;

@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) id<UserCellDelegate> delegate;
@property (strong, nonatomic) User *user;
@end

NS_ASSUME_NONNULL_END
