//
//  AppDeal.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "AppItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDeal : NSObject

@property (nonatomic, strong) NSString *sellerName;
@property (nonatomic, strong) NSURL *itemURL;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) AppItem *item;
@property (nonatomic, strong) NSString *identifier;

@end

NS_ASSUME_NONNULL_END
