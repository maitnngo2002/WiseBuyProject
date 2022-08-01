//
//  APIHelper.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "Deal.h"

NS_ASSUME_NONNULL_BEGIN

@protocol APIDelegate <NSObject>

+ (void)fetchDeals: (NSString *)barcode;

@end

@interface APIHelper : NSObject

+ (Item *)createItem: (NSString *)name description:(NSString *) description barcode:(NSString *) barcode imageUrl:(NSString *) imageUrl;
+ (void)createDeal: (Item *)item sellerName:(NSString *) sellerName price:(NSString *) price link:(NSString *) link;
+ (NSDictionary *)getResponseFromAPI: (NSString *)requestURL headers:(NSDictionary *) headers;

@end


NS_ASSUME_NONNULL_END
