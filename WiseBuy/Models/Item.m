//
//  Item.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "Item.h"

static NSString *const kItem = @"Item";

@implementation Item

@dynamic barcode;
@dynamic name;
@dynamic image;
@dynamic information;

+ (nonnull NSString *)parseClassName {
    return kItem;
}
@end
