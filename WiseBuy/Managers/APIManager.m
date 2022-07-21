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
#import "DatabaseManager.h"

@implementation APIManager

+ (void)fetchDealsFromAPIs: (NSString *)barcode {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self fetchDealsFromEbayAPI:barcode];
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self fetchDealsFromUPCDatabase:barcode];
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [self fetchDealsFromSearchUPCAPI:barcode];
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

+ (void)fetchDealsFromEbayAPI:(NSString *)barcode {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *securityName = [dict objectForKey: @"appSecurityName"];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"appSecurityName"]) {
        securityName = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSecurityName"];
    }
    
    NSString *const appSecurityName = securityName;
    NSString *const firstHalfBaseURL = @"https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByProduct&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=";
    NSString *const secondHalfBaseURL = @"&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=2&productId.@type=ReferenceID&productId=";

    NSString *fullBaseURL = [NSString stringWithFormat:@"%@%@%@", firstHalfBaseURL, appSecurityName, secondHalfBaseURL];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", fullBaseURL, barcode];
    
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
              
              NSDictionary *finalResponseDic = responseDictionary[@"findItemsByProductResponse"][0][@"searchResult"][0];
          if (finalResponseDic[@"count"] > 0) {
              NSArray *offerLists = finalResponseDic[@"item"];
                  
                Item *newItem = [self createItem:offerLists[0][@"title"][0] :offerLists[0][@"condition"][0][@"conditionDisplayName"][0] :barcode :offerLists[0][@"galleryURL"][0]];
                  
                for (NSDictionary* offer in offerLists) {
                    [self createDeal:newItem :@"Ebay" :offer[@"sellingStatus"][0][@"convertedCurrentPrice"][0][@"__value__"] :offer[@"viewItemURL"][0]];
                }
          }
          dispatch_semaphore_signal(sema);
      }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (void)fetchDealsFromUPCDatabase:(NSString *)barcode{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSString *const baseURL = @"https://api.upcitemdb.com/prod/v1/lookup?upc=";

    NSString *const fullBaseURL = [NSString stringWithFormat:@"%@%@", baseURL, barcode];
    
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
      @"user_key": userKey
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
          if (responseDictionary.count > 0) {
              Item *newItem = [self createItem:responseDictionary[@"items"][0][@"title"] :responseDictionary[@"items"][0][@"description"] :responseDictionary[@"items"][0][@"upc"] :responseDictionary[@"items"][0][@"images"][0]];
              
              NSInteger count = [responseDictionary[@"items"][0][@"offers"] count];
              if (count > 0) {
                  int x;
                  for (x = 0;x <= count - 1; x++)
                  {
                      NSDictionary *offer = [responseDictionary[@"items"][0][@"offers"] objectAtIndex:x];
                      [self createDeal:newItem :offer[@"merchant"] :offer[@"price"] :offer[@"link"]];
                  }
              }
              
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
    
    NSString *const accessTokenStr = accessToken;
    NSString *const upcQuery = @"&upc=";
    NSString *const baseURL = @"https://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=";
    NSString *fullURL = [NSString stringWithFormat:@"%@%@%@%@", baseURL, accessTokenStr, upcQuery, barcode];
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
                  NSLog(@"%@", responseDictionary);
                  NSLog(@"%lu", (unsigned long)responseDictionary.count);
                  if (responseDictionary.count > 0) {
                      Item *newItem = [self createItem:responseDictionary[@"0"][@"productname"] :responseDictionary[@"0"][@"storename"] :barcode :responseDictionary[@"0"][@"imageurl"]];
                      
                      for (id key in responseDictionary)
                      {
                          NSDictionary *offer = [responseDictionary objectForKey:key];
                          
                          [self createDeal:newItem :offer[@"storename"] :offer[@"price"] :offer[@"link"]];
                          
                      }
                  }
                  dispatch_semaphore_signal(sema);
              }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (Item *)createItem: (NSString *)name : (NSString *)description : (NSString *)barcode : (NSString *)imageUrl {
    Item *newItem = [Item new];
    newItem[@"name"] = name;
    newItem[@"description"] = description;
    newItem[@"barcode"] = barcode;
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:imageData];

    if (img) {
        newItem[@"image"] = [DatabaseManager getPFFileFromImage:img];
    } else {
        newItem[@"image"] = [DatabaseManager getPFFileFromImage:[UIImage imageNamed:@"2x.png"]];
    }
    
    [newItem saveInBackground];
    
    return newItem;
}

+ (void)createDeal: (Item *)item : (NSString *)sellerName : (NSString *)price : (NSString *)link {
    Deal *newDeal = [Deal new];
    
    newDeal[@"item"] = item;
    newDeal[@"sellerName"] = sellerName;

    if ([price isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *priceNumber = [f numberFromString:price];
        
        newDeal[@"price"] = priceNumber;
    }
    else {
        newDeal[@"price"] = price;
    }
    newDeal[@"link"] = link;
    [newDeal saveInBackground];
}

@end
