//
//  APIManager.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "Deal.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (void)fetchDealsFromEbayAPI;

@end

NS_ASSUME_NONNULL_END
