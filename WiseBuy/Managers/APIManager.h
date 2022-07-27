//
//  APIManager.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "EbayAPI.h"
#import "UPCDatabaseAPI.h"
#import "SearchUPCAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (void)fetchDealsFromAPIs: (NSString *)barcode;
@property (strong, nonatomic) NSMutableArray *apiList;

@end

NS_ASSUME_NONNULL_END
