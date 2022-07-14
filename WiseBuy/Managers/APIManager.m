//
//  APIManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "APIManager.h"
#import "Parse/Parse.h"
#import "Deal.h"
#import "Item.h"
#import "Foundation/Foundation.h"
#import "Parse/Parse.h"
#import "DatabaseManager.h"

@implementation APIManager

+ (void)fetchDealsFromEbayAPI:(NSString *)barcode {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *securityName = [dict objectForKey: @"appSecurityName"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"appSecurityName"]) {
        securityName = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSecurityName"];
    }
    
    NSString *appSecurityName = securityName;
    NSString *firstHalfBaseURL = @"https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByProduct&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=";
    NSString *secondHalfBaseURL = @"&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=2&productId.@type=ReferenceID&productId=";

    NSString *fullBaseURL = [NSString stringWithFormat:@"%@%@%@", firstHalfBaseURL, appSecurityName, secondHalfBaseURL];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", fullBaseURL, @"53039031"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];

    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"%@", error);
        dispatch_semaphore_signal(sema);
      } else {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
          
//          [self getDealsFromJSON:responseDictionary];
          
          NSDictionary *finalResponseDic = responseDictionary[@"findItemsByProductResponse"][0][@"searchResult"][0];
          NSArray *offerLists = finalResponseDic[@"item"];
          
          Item *newItem = [self createItem:offerLists[0][@"title"][0] :offerLists[0][@"condition"][0][@"conditionDisplayName"][0] :barcode :offerLists[0][@"galleryURL"][0]];
          
          for (NSDictionary* offer in offerLists) {
              [self createDeal:newItem :@"Ebay" :offer[@"sellingStatus"][0][@"convertedCurrentPrice"][0][@"__value__"] :offer[@"viewItemURL"][0]];
          }
        dispatch_semaphore_signal(sema);
            
      }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (void)fetchDealsFromUPCDatabase:(NSString *)barcode{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSString *baseURL = @"https://api.upcitemdb.com/prod/v1/lookup?upc=";

    NSString *fullBaseURL = [NSString stringWithFormat:@"%@%@", baseURL, @"888462323772"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullBaseURL]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *userKey = [dict objectForKey: @"searchUPC_userKey"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"upcDatabase_userKey"]) {
        userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"upcDatabase_userKey"];
    }
    NSDictionary *headers = @{
      @"user_key": @"38ece1f67747388f5034080aeebc2dc9"
    };

    [request setAllHTTPHeaderFields:headers];

    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"%@", error);
        dispatch_semaphore_signal(sema);
      } else {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        dispatch_semaphore_signal(sema);

          
          Item *newItem = [self createItem:responseDictionary[@"items"][0][@"title"] :responseDictionary[@"items"][0][@"description"] :responseDictionary[@"items"][0][@"upc"] :responseDictionary[@"items"][0][@"images"][0]];
          
          NSInteger count = [responseDictionary[@"items"][0][@"offers"] count];
          int x;
          for (x = 0;x <= count - 1; x++)
          {
              NSDictionary *offer = [responseDictionary[@"items"][0][@"offers"] objectAtIndex:x];
              
              [self createDeal:newItem :offer[@"merchant"] :offer[@"price"] :offer[@"link"]];
          }
          
      }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (void)fetchDealsFromSearchUPCAPI:(NSString *)barcode{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *accessToken = [dict objectForKey: @"access_Token"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_Token"]) {
        accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_Token"];
    }
    
    NSString *accessTokenStr = accessToken;
    NSString *upcQuery = @"&upc=";
    NSString *baseURL = @"https://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=";
    NSString *fullURL = [NSString stringWithFormat:@"%@%@%@%@", baseURL, accessTokenStr, upcQuery, @"888462323772"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullURL]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];
    
    NSString *userKey = [dict objectForKey: @"searchUPC_userKey"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"searchUPC_userKey"]) {
        userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"searchUPC_userKey"];
    }
    NSDictionary *headers = @{
      @"user_key": userKey
    };

    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:@"GET"];

        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
              if (error) {
                  NSLog(@"%@", error);
                  dispatch_semaphore_signal(sema);
              } else {
                  NSError *parseError = nil;
                  NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                  
//                  [self getDealsFromJSON:responseDictionary:barcode];
                  Item *newItem = [self createItem:responseDictionary[@"0"][@"productname"] :responseDictionary[@"0"][@"storename"] :barcode :responseDictionary[@"0"][@"imageurl"]];
                  
                  for (id key in responseDictionary)
                  {
                      NSDictionary *offer = [responseDictionary objectForKey:key];
                      
                      [self createDeal:newItem :offer[@"storename"] :offer[@"price"] :offer[@"link"]];
                      
                  }
                  dispatch_semaphore_signal(sema);
              }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (void) getDealsFromJSON: (NSDictionary *)responseDictionary : (NSString *)barcode {
    NSMutableArray *prices = [[NSMutableArray alloc] init];
    NSMutableArray *links = [[NSMutableArray alloc] init];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *sellers = [[NSMutableArray alloc] init];

    prices = [self getSpecficValues:@"price" :responseDictionary];
    NSMutableArray *to_delete = [[NSMutableArray alloc] init];

    for (NSString *price in prices) {
        if ([price  isEqual: @""]) {
            [to_delete addObject:price];
        }
    }
    for (NSString *price in to_delete) {
        [prices removeObject:price];
    }
    titles = [self getSpecficValues:@"title" :responseDictionary];
    
    NSString *descriptions = [[self getSpecficValues:@"description" :responseDictionary] firstObject]; // get the description of the item
    
    links = [self getSpecficValues:@"link" :responseDictionary];

    sellers = [self getSpecficValues:@"merchant" :responseDictionary]; // check for several keywords such as merchant, sellerStore, seller
    
    NSLog(@"%lu", (unsigned long)links.count);
    NSLog(@"%lu", (unsigned long)prices.count);
    NSLog(@"%lu", (unsigned long)sellers.count);
}


+ (Item *)createItem: (NSString *)name : (NSString *)description : (NSString *)barcode : (NSString *)imageUrl {
    Item *newItem = [Item new];
    newItem[@"name"] = name;
    newItem[@"description"] = description;
    newItem[@"barcode"] = barcode;
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
    
    newItem[@"image"] = [PFFileObject fileObjectWithData:imageData];
    
    [newItem saveInBackground];
    
    return newItem;
}

+ (void)createDeal: (Item *)item : (NSString *)sellerName : (NSString *)price : (NSString *)link {
    Deal *newDeal = [Deal new];
    
    newDeal[@"item"] = item;
    newDeal[@"sellerName"] = sellerName;
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *priceNumber = [f numberFromString:price];
    
    newDeal[@"price"] = priceNumber;
    
    newDeal[@"link"] = link;
    [newDeal saveInBackground];
}

+ (NSMutableArray *)getSpecficValues: (NSString *)keyString : (NSDictionary *)responseDictionary{
        
    NSMutableArray *valueLists = [[NSMutableArray alloc] init];
    NSString *responseString = [NSString stringWithFormat:@"%@", responseDictionary];
    
    NSArray *removeKeys = @[@" ", @"(", @")", @"\n", @"highest_recorded_price", @"lowest_recorded_price", @"lowest_recorded_price", @"list_price", @"\""]; // for getting prices
    
    NSString *trimmed;
    for (NSString *key in removeKeys) {
        trimmed = [responseString stringByReplacingOccurrencesOfString:key withString:@""];
    }
    NSRange searchRange = NSMakeRange(0,responseString.length);
    NSRange foundRange;
    while (searchRange.location < trimmed.length) {
        searchRange.length = trimmed.length-searchRange.location;
        foundRange = [trimmed rangeOfString:keyString options:0 range:searchRange];
        if (foundRange.location != NSNotFound) {
            NSInteger endingIndex = foundRange.location+foundRange.length;
            
            NSInteger valueStartingIndex = endingIndex + 1;
            
            NSString *foundValue = [trimmed substringFromIndex:valueStartingIndex];
            NSArray *split = [foundValue componentsSeparatedByString:@";"];
            NSString *finalPrice = split[0];
            [valueLists addObject:finalPrice];
            NSLog(@"%@", finalPrice);
            searchRange.location = foundRange.location+foundRange.length;
        } else {
            // no more substring to find
            break;
        }
    }
    
//    NSLog(@"%ld", (long)[priceLists[0] integerValue]);
    return valueLists;
}
@end
