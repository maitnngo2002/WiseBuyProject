//
//  APIHelper.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "APIHelper.h"
#import "DatabaseManager.h"
#import "Parse/Parse.h"

@implementation APIHelper

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
    }
    if (![DatabaseManager checkIfItemAlreadyExist:barcode]) {
        [newItem saveInBackground];
    }

    return newItem;
}

+ (void)createDeal: (Item *)item : (NSString *)sellerName : (NSString *)price : (NSString *)link {
    Deal *newDeal = [Deal new];
    
    newDeal[@"item"] = item;
    newDeal[@"sellerName"] = sellerName;
    
    if ([price isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [NSNumberFormatter new];
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

+ (NSDictionary *)getResponseFromAPI: (NSString *)requestURL : (NSDictionary *)headers {
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    __block NSDictionary *responseDictionary = [[NSDictionary alloc] init];
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    if (headers) {
        [request setAllHTTPHeaderFields:headers];

    }
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSError *parseError = nil;
            responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            dispatch_semaphore_signal(sema);
        }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return responseDictionary;
}

@end
