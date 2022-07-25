//
//  EbayAPI.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "EbayAPI.h"

static NSString *const kFirstHalfBaseURL = @"https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByProduct&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=";
static NSString *const kSecondHalfBaseURL = @"&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=2&productId.@type=ReferenceID&productId=";

@implementation EbayAPI

+ (void)fetchDeals: (NSString *)barcode {
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *securityName = [dict objectForKey: @"appSecurityName"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"appSecurityName"]) {
        securityName = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSecurityName"];
    }
    
    NSString *const appSecurityName = securityName;
    
    NSString *fullBaseURL = [NSString stringWithFormat:@"%@%@%@", kFirstHalfBaseURL, appSecurityName, kSecondHalfBaseURL];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", fullBaseURL, barcode];
    
    NSDictionary *responseDictionary = [APIHelper getResponseFromAPI:requestURL :[NSDictionary dictionary]];
    if (responseDictionary ) {
        NSDictionary *finalResponseDic = responseDictionary[@"findItemsByProductResponse"][0][@"searchResult"][0];

        if (![finalResponseDic[@"@count"]  isEqual: @"0"]) {
            NSArray *offerLists = finalResponseDic[@"item"];
            
            Item *newItem = [APIHelper createItem:offerLists[0][@"title"][0] :offerLists[0][@"condition"][0][@"conditionDisplayName"][0] :barcode :offerLists[0][@"galleryURL"][0]];
            
            for (NSDictionary* offer in offerLists) {
                [APIHelper createDeal:newItem :@"Ebay" :offer[@"sellingStatus"][0][@"convertedCurrentPrice"][0][@"__value__"] :offer[@"viewItemURL"][0]];
            }
        }
    }
    
}


@end

