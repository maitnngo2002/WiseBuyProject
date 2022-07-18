//
//  DealCell.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/6/22.
//

#import "DealCell.h"

@implementation DealCell

- (void)setDeal:(AppDeal *)deal {
    _deal = deal;
    self.itemImage.image = [UIImage imageWithData:_deal.item.image];
    self.itemName.text = _deal.item.name;
    self.sellerName.text = _deal.sellerName;
    self.price.text = [DealCell formattedPrice:_deal.price];
}

+ (NSString *)formattedPrice:(NSNumber *)price {
    return [NSNumberFormatter localizedStringFromNumber:price numberStyle:NSNumberFormatterCurrencyStyle];
}

@end
