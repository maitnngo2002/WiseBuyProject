//
//  FriendCell.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/18/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@property (strong, nonatomic) PFUser *cellUser;
@property (nonatomic) int chosenMode;
@end

NS_ASSUME_NONNULL_END
