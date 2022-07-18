//
//  DealCell.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "AppDeal.h"

NS_ASSUME_NONNULL_BEGIN

@interface DealCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *sellerName;
@property (weak, nonatomic) IBOutlet UILabel *price;

@property (strong, nonatomic) AppDeal *deal;

@end

NS_ASSUME_NONNULL_END
