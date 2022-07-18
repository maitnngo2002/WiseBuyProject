//
//  ItemCollectionViewCell.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/18/22.
//

#import <UIKit/UIKit.h>
#import "AppItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItemCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) AppItem *item;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;

@end

NS_ASSUME_NONNULL_END
