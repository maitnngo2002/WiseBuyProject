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
    
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", fullBaseURL, barcode];
    NSLog(@"%@", requestURL);
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
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"%@",responseDictionary);
            dispatch_semaphore_signal(sema);
            
      }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (void)fetchDealsFromUPCDatabase:(NSString *)barcode{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSString *baseURL = @"https://api.upcitemdb.com/prod/v1/lookup?upc=";

    NSString *fullBaseURL = [NSString stringWithFormat:@"%@%@", baseURL, barcode];
    
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
          
          NSInteger count = [responseDictionary[@"items"][0][@"offers"] count];
          int x;
          for (x = 0;x <= count; x++)
          {
              NSDictionary *offer = [responseDictionary[@"items"][0][@"offers"] objectAtIndex:x];
              NSLog(@"%@", responseDictionary[@"items"][0]);
              NSLog(@"%@", responseDictionary[@"items"][0]);
                    NSLog(@"%@", responseDictionary[@"items"][0][@"description"]);
              NSLog(@"%@", responseDictionary[@"items"][0][@"images"][0]);
              
              Item *newItem = [Item new];
              newItem[@"name"] = responseDictionary[@"items"][0][@"title"];
              newItem[@"description"] = responseDictionary[@"items"][0][@"description"];
              newItem[@"barcode"] = responseDictionary[@"items"][0][@"description"][@"upc"];

              NSURL *imageurl = [NSURL URLWithString: responseDictionary[@"items"][0][@"images"][0]];
              NSLog(@"%@", imageurl);
              
              NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: responseDictionary[@"items"][0][@"images"][0]]];
              UIImage *image = [UIImage imageWithData: imageData];
              newItem[@"image"] = [DatabaseManager getPFFileFromImage:image];
              NSLog(@"%@", newItem);
              [newItem saveInBackground];

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
//                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                  NSError *parseError = nil;
                  NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                  NSLog(@"%@",responseDictionary);
                  dispatch_semaphore_signal(sema);
              }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}
@end
