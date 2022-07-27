//
//  UPCDatabaseAPI.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "UPCDatabaseAPI.h"

static NSString *const kBaseURL = @"https://api.upcitemdb.com/prod/v1/lookup?upc=";

@implementation UPCDatabaseAPI

+ (void)fetchDeals:(NSString *)barcode {
    
    NSString *const fullBaseURL = [NSString stringWithFormat:@"%@%@", kBaseURL, barcode];
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *userKey = [dict objectForKey: @"searchUPC_userKey"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"searchUPC_userKey"]) {
        userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"searchUPC_userKey"];
    }
    NSDictionary *headers = [[NSDictionary alloc] init];
    if (userKey) {
        headers = @{
            @"user_key": userKey
        };
    }
    
    NSDictionary *responseDictionary = [APIHelper getResponseFromAPI:fullBaseURL : headers];
    if ([responseDictionary[@"items"] count]) {
        NSInteger count = [responseDictionary[@"items"][0][@"offers"] count];
        
        if (count > 0) {
            Item *newItem = [APIHelper createItem:responseDictionary[@"items"][0][@"title"] :responseDictionary[@"items"][0][@"description"] :barcode :responseDictionary[@"items"][0][@"images"][0]];
            
            for (int x = 0; x < count; x++) {
                NSDictionary *offer = [responseDictionary[@"items"][0][@"offers"] objectAtIndex:x];
                [APIHelper createDeal:newItem :offer[@"merchant"] :offer[@"price"] :offer[@"link"]];
            }
        }
    }
    
}

@end
