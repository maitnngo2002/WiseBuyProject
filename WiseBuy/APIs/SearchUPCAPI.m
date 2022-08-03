//
//  SearchUPCAPI.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "SearchUPCAPI.h"

static NSString *const kUpcQuery = @"&upc=";
static NSString *const kBaseURL = @"https://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=";
static NSString *const kAccessToken = @"access_Token";
static NSString *const kSearchUPCUserKey = @"searchUPC_userKey";

@implementation SearchUPCAPI

+ (void)fetchDeals:(nonnull NSString *)barcode {
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *accessToken = [dict objectForKey:kAccessToken];
    NSString *const accessTokenStr = accessToken;
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken]) {
        accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken];
    }
    
    NSString *fullURL = [NSString stringWithFormat:@"%@%@%@%@", kBaseURL, accessTokenStr, kUpcQuery, barcode];
    
    NSString *userKey = [dict objectForKey: kSearchUPCUserKey];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kSearchUPCUserKey]) {
        userKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSearchUPCUserKey];
    }
    NSDictionary *headers = [[NSDictionary alloc] init];
    if (userKey) {
        headers = @{
            @"user_key": userKey
        };
    }
    
    NSDictionary *responseDictionary = [APIHelper getResponseFromAPI:fullURL headers:headers];
    if (![responseDictionary[@"0"][@"currency"] isEqual:@"N/A"]) { // check the first element if the deal exists
        
        NSString *const title = responseDictionary[@"0"][@"productname"];
        NSString *const description = responseDictionary[@"0"][@"storename"];
        NSString *const imageUrl = responseDictionary[@"0"][@"imageurl"];
        
        Item *newItem = [APIHelper createItem:title description:description barcode:barcode imageUrl:imageUrl];
        
        for (id key in responseDictionary) {
            NSDictionary *offer = [responseDictionary objectForKey:key];
            
            NSString *const sellerName = offer[@"storename"];
            NSString *const price = offer[@"price"];
            NSString *const link = offer[@"link"];
            
            [APIHelper createDeal:newItem sellerName:sellerName price:price link:link];
        }
    }
}


@end
