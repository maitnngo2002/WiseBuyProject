//
//  APIHelper.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/21/22.
//

#import "APIHelper.h"
#import "DatabaseManager.h"
#import "Parse/Parse.h"

static NSString *const kName = @"name";
static NSString *const kDescription = @"description";
static NSString *const kBarcode = @"barcode";
static NSString *const kImage = @"image";
static NSString *const kSellerNmae = @"sellerName";
static NSString *const kPrice = @"price";
static NSString *const kLink = @"link";
static NSString *const kItem = @"item";

@implementation APIHelper

+ (Item *)createItem: (NSString *)name description:(NSString *) description barcode:(NSString *) barcode imageUrl:(NSString *) imageUrl {
    Item *newItem = [Item new];
    newItem[kName] = name;
    newItem[kDescription] = description;
    newItem[kBarcode] = barcode;
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:imageData];
    
    if (img) {
        newItem[kImage] = [DatabaseManager getPFFileFromImage:img];
    }
    if (![DatabaseManager checkIfItemAlreadyExist:barcode]) {
        [newItem saveInBackground];
    }

    return newItem;
}

+ (void)createDeal: (Item *)item sellerName:(NSString *) sellerName price:(NSString *) price link:(NSString *) link {    Deal *newDeal = [Deal new];
    
    newDeal[kItem] = item;
    newDeal[kSellerNmae] = sellerName;
    
    if ([price isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [NSNumberFormatter new];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *priceNumber = [f numberFromString:price];
        
        newDeal[kPrice] = priceNumber;
    }
    else {
        newDeal[kPrice] = price;
    }
    newDeal[kLink] = link;
    [newDeal saveInBackground];
}

+ (NSDictionary *)getResponseFromAPI: (NSString *)requestURL headers:(NSDictionary *) headers {
    
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
