//
//  SearchUPCAPI.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "SearchUPCAPI.h"

static NSString *const kUpcQuery = @"&upc=";
static NSString *const kBaseURL = @"https://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=";

@implementation SearchUPCAPI

+ (void)fetchDeals:(nonnull NSString *)barcode {
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *accessToken = [dict objectForKey: @"access_Token"];
    NSString *const accessTokenStr = accessToken;
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_Token"]) {
        accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_Token"];
    }
    
    NSString *fullURL = [NSString stringWithFormat:@"%@%@%@%@", kBaseURL, accessTokenStr, kUpcQuery, barcode];
    
    NSString *userKey = [dict objectForKey: @"searchUPC_userKey"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"searchUPC_userKey"]) {
        userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"searchUPC_userKey"];
    }
    NSDictionary *headers = @{
        @"user_key": userKey
    };
    
    NSDictionary *responseDictionary = [APIHelper getResponseFromAPI:fullURL :headers];
    if (![responseDictionary[@"0"][@"currency"] isEqual:@"N/A"]) { // check the first element if the deal exists
        Item *newItem = [APIHelper createItem:responseDictionary[@"0"][@"productname"] :responseDictionary[@"0"][@"storename"] :barcode :responseDictionary[@"0"][@"imageurl"]];
        
        for (id key in responseDictionary) {
            NSDictionary *offer = [responseDictionary objectForKey:key];
            
            [APIHelper createDeal:newItem :offer[@"storename"] :offer[@"price"] :offer[@"link"]];
        }
    }
}


@end
