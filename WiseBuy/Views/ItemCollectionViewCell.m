//
//  ItemCollectionViewCell.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/18/22.
//

#import "ItemCollectionViewCell.h"

@implementation ItemCollectionViewCell

- (void)setItem:(AppItem *)item {
    _item = item;
    self.itemImageView.image = [UIImage imageWithData:item.image];
}

@end
