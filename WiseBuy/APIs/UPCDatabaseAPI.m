//
//  UPCDatabaseAPI.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "UPCDatabaseAPI.h"

static NSString *const kBaseURL = @"https://api.upcitemdb.com/prod/v1/lookup?upc=";
static NSString *const kSearchUPCUserKey = @"upcDatabase_userKey";

@implementation UPCDatabaseAPI

+ (void)fetchDeals:(NSString *)barcode {
    
    NSString *const fullBaseURL = [NSString stringWithFormat:@"%@%@", kBaseURL, barcode];
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
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
    
    NSDictionary *responseDictionary = [APIHelper getResponseFromAPI:fullBaseURL headers:headers];
    if ([responseDictionary[@"items"] count]) {
        NSInteger count = [responseDictionary[@"items"][0][@"offers"] count];
        
        if (count > 0) {
            NSString *const title = responseDictionary[@"items"][0][@"title"];
            NSString *const description = responseDictionary[@"items"][0][@"description"];
            NSString *const imageUrl = responseDictionary[@"items"][0][@"images"][0];
            
            Item *newItem = [APIHelper createItem:title description:description barcode:barcode imageUrl:imageUrl];
            
            for (int x = 0; x < count; x++) {
                NSDictionary *offer = [responseDictionary[@"items"][0][@"offers"] objectAtIndex:x];
                NSString *const sellerName = offer[@"merchant"];
                NSString *const price = offer[@"price"];
                NSString *const link = offer[@"link"];
                
                [APIHelper createDeal:newItem sellerName:sellerName price:price link:link];
            }
        }
    }
    
}

@end
