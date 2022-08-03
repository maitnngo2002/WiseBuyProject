//
//  EbayAPI.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "EbayAPI.h"

static NSString *const kFirstHalfBaseURL = @"https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByProduct&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=";
static NSString *const kSecondHalfBaseURL = @"&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=2&productId.@type=ReferenceID&productId=";
static NSString *const kSellerName = @"Ebay";
static NSString *const kAppSecurityName = @"appSecurityName";

@implementation EbayAPI

+ (void)fetchDeals: (NSString *)barcode {
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *securityName = [dict objectForKey: kAppSecurityName];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kAppSecurityName]) {
        securityName = [[NSUserDefaults standardUserDefaults] stringForKey:kAppSecurityName];
    }
    
    NSString *const appSecurityName = securityName;
    
    NSString *fullBaseURL = [NSString stringWithFormat:@"%@%@%@", kFirstHalfBaseURL, appSecurityName, kSecondHalfBaseURL];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", fullBaseURL, barcode];
    
    NSDictionary *responseDictionary = [APIHelper getResponseFromAPI:requestURL headers:[NSDictionary dictionary]];
    if (responseDictionary ) {
        NSDictionary *finalResponseDic = responseDictionary[@"findItemsByProductResponse"][0][@"searchResult"][0];

        if (![finalResponseDic[@"@count"]  isEqual: @"0"]) {
            NSArray<NSDictionary *> *offerLists = finalResponseDic[@"item"];
            
            NSString *const title = offerLists[0][@"title"][0];
            NSString *const description = offerLists[0][@"condition"][0][@"conditionDisplayName"][0];
            NSString *const imageUrl = offerLists[0][@"galleryURL"][0];
            
            Item *newItem = [APIHelper createItem:title description:description barcode:barcode imageUrl:imageUrl];
            
            for (NSDictionary* offer in offerLists) {
                
                NSString *const price = offer[@"sellingStatus"][0][@"convertedCurrentPrice"][0][@"__value__"];
                NSString *const link = offer[@"viewItemURL"][0];
                
                [APIHelper createDeal:newItem sellerName:kSellerName price:price link:link];
            }
        }
    }
    
}


@end

