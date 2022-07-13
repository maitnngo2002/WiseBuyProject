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
          
          NSDictionary *finalResponseDic = responseDictionary[@"findItemsByProductResponse"][0][@"searchResult"][0];
          NSArray *offerLists = finalResponseDic[@"item"];
          
          Item *newItem = [Item new];
          newItem[@"name"] = offerLists[0][@"title"][0];
          newItem[@"description"] = offerLists[0][@"condition"][0][@"conditionDisplayName"][0];
          
          newItem[@"barcode"] = offerLists[0][@"productId"][0][@"__value__"];
          
          NSString *itemUrl = offerLists[0][@"viewItemURL"][0];
          NSString *imageUrl = offerLists[0][@"galleryURL"][0];
                    
          NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
          newItem[@"image"] = [PFFileObject fileObjectWithData:imageData];
          
          [newItem saveInBackground];
          
          for (NSDictionary* offer in offerLists) {
              NSString *price = offer[@"sellingStatus"][0][@"convertedCurrentPrice"][0][@"__value__"];
              
              NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
              f.numberStyle = NSNumberFormatterDecimalStyle;
              NSNumber *priceNumber = [f numberFromString:price];

              Deal *newDeal = [Deal new];
              newDeal[@"item"] = newItem;
              newDeal[@"sellerName"] = @"Ebay";
              newDeal[@"price"] = priceNumber;
              newDeal[@"link"] = itemUrl;
              [newDeal saveInBackground];
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

    NSString *fullBaseURL = [NSString stringWithFormat:@"%@%@", baseURL, @"53039031"];
    
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
          
          Item *newItem = [Item new];
          newItem[@"name"] = responseDictionary[@"items"][0][@"title"];
          newItem[@"description"] = responseDictionary[@"items"][0][@"description"];
          newItem[@"barcode"] = responseDictionary[@"items"][0][@"upc"];
          
          NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: responseDictionary[@"items"][0][@"images"][0]]];
          
          newItem[@"image"] = [PFFileObject fileObjectWithData:imageData];
                        
          [newItem saveInBackground];
          
          NSInteger count = [responseDictionary[@"items"][0][@"offers"] count];
          int x;
          for (x = 0;x <= count - 1; x++)
          {
              NSDictionary *offer = [responseDictionary[@"items"][0][@"offers"] objectAtIndex:x];
              
              Deal *newDeal = [Deal new];
              
              newDeal[@"item"] = newItem;
              newDeal[@"sellerName"] = offer[@"merchant"];
              newDeal[@"price"] = offer[@"price"];
              newDeal[@"link"] = offer[@"link"];
              [newDeal saveInBackground];
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
    NSString *fullURL = [NSString stringWithFormat:@"%@%@%@%@", baseURL, accessTokenStr, upcQuery, @"5034504124677"];
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
                  
                  NSLog(@"%@",responseDictionary);
                  
                  
                  Item *newItem = [Item new];
                  newItem[@"name"] = responseDictionary[@"0"][@"productname"];
                  newItem[@"description"] = responseDictionary[@"0"][@"storename"];
                  newItem[@"barcode"] = @"5034504124677";
                  
                  NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: responseDictionary[@"0"][@"imageurl"]]];
                  
                  NSLog(@"%@", responseDictionary[@"0"][@"imageurl"]);
                  newItem[@"image"] = [PFFileObject fileObjectWithData:imageData];
                  
                  [newItem saveInBackground];
                  
                  for (id key in responseDictionary)
                  {
                      NSDictionary *offer = [responseDictionary objectForKey:key];
                      
                      NSString *price = offer[@"price"];
                      NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                      f.numberStyle = NSNumberFormatterDecimalStyle;
                      NSNumber *priceNumber = [f numberFromString:price];
                      
                      Deal *newDeal = [Deal new];
                      
                      newDeal[@"item"] = newItem;
                      newDeal[@"sellerName"] = offer[@"storename"];
                      newDeal[@"price"] = priceNumber;
                      newDeal[@"link"] = offer[@"producturl"];
                      [newDeal saveInBackground];
                  }
                  dispatch_semaphore_signal(sema);
              }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}
@end
