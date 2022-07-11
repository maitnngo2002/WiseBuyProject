//
//  APIManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "APIManager.h"
#import "Parse/Parse.h"
#import "Deal.h"
#import "Foundation/Foundation.h"
#import "Parse/Parse.h"

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

    NSString *fullBaseURL = [NSString stringWithFormat:@"%@/%@/%@/", firstHalfBaseURL, appSecurityName, secondHalfBaseURL];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@/%@/", fullBaseURL, barcode];
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

+ (void)fetchDealsFromUPCDatabase{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.upcitemdb.com/prod/v1/lookup?upc=079298000085"]
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
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
//        NSLog(@"%@",responseDictionary);
        dispatch_semaphore_signal(sema);
          
          NSLog(@"%@", responseDictionary[@"items"]);
          
          PFObject *deal = [PFObject objectWithClassName:@"Deal"];
          deal[@"sellerName"] = @"Test";
          deal[@"itemURL"] = @"google.com";
          deal[@"price"] = @NO;
          PFObject *item = [PFObject objectWithClassName:@"Item"];
          deal[@"item"] = item;
          [deal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
              if (succeeded) {
                  NSLog(@"Object saved!");
              } else {
                  NSLog(@"Error: %@", error.description);
              }
          }];
      }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (void)fetchDealsFromSearchUPCAPI{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=E5EF4E1F-DBD0-40AF-9CBB-481A384FFAA4&upc=079298000085"]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
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
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                  NSError *parseError = nil;
                  NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                  NSLog(@"%@",responseDictionary);
                  dispatch_semaphore_signal(sema);
                  
                  PFObject *deal = [PFObject objectWithClassName:@"Deal"];
                  deal[@"sellerName"] = @"Test";
                  deal[@"itemURL"] = @"google.com";
                  deal[@"price"] = @NO;
                  PFObject *item = [PFObject objectWithClassName:@"Item"];
                  deal[@"item"] = item;
                  [deal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                      if (succeeded) {
                          NSLog(@"Object saved!");
                      } else {
                          NSLog(@"Error: %@", error.description);
                      }
                  }];
              }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}
@end
