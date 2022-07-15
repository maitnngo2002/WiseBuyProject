//
//  UserCell.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UserCellDelegate;

@interface UserCell : UITableViewCell

@property (weak, nonatomic) id<UserCellDelegate> delegate;
@property (strong, nonatomic) User *user;
@end

NS_ASSUME_NONNULL_END
