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
    NSURL *url = [NSURL URLWithString:item.image.url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    
    self.itemImageView.image = image;
}

@end
