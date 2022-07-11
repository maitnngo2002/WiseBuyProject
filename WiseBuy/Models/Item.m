//
//  Item.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "Item.h"

@implementation Item

@dynamic barcode;
@dynamic name;
@dynamic image;
@dynamic description;

+ (nonnull NSString *)parseClassName {
    return @"Item";
}
@end
