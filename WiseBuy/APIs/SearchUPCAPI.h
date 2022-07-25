//
//  SearchUPCAPI.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import <Foundation/Foundation.h>
#import "APIHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchUPCAPI : NSObject <APIDelegate>

+ (void)fetchDeals:(NSString *)barcode;

@end

NS_ASSUME_NONNULL_END
