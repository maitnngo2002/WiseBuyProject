//
//  Deal.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface Deal : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *sellerName;
@property (nonatomic, strong) NSString *itemURL;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) Item *item;

@end

NS_ASSUME_NONNULL_END
