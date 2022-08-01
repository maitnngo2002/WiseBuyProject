//
//  Deal.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "Deal.h"

static NSString *const kDeal = @"Deal";

@implementation Deal

@dynamic sellerName;
@dynamic itemURL;
@dynamic price;
@dynamic item;

+ (nonnull NSString *)parseClassName {
    return kDeal;
}

@end
