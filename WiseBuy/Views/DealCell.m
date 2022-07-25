//
//  DealCell.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/6/22.
//

#import "DealCell.h"
#import "Parse/Parse.h"
#import "Item.h"

@implementation DealCell

- (void)setDeal:(AppDeal *)deal {
    _deal = deal;
    NSData *itemImage = _deal.item.image;
//    NSLog(@"%@", [itemImage ]);
//    NSURL *url = [NSURL URLWithString:itemImage.url];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    self.itemImageView.image = [UIImage imageWithData:_deal.item.image];

//    UIImage *img = [[UIImage alloc] initWithData:itemImage];
    self.itemImage.image = [UIImage imageWithData:_deal.item.image];

//    self.itemImage.image = image;
    self.itemName.text = _deal.item.name;
    self.sellerName.text = _deal.sellerName;
    self.price.text = [DealCell formattedPrice:_deal.price];
}

+ (NSString *)formattedPrice:(NSNumber *)price {
    return [NSNumberFormatter localizedStringFromNumber:price numberStyle:NSNumberFormatterCurrencyStyle];
}

@end
