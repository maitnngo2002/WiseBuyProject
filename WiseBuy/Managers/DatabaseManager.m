//
//  DatabaseManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "DatabaseManager.h"
#import "Deal.h"
#import "AlertManager.h"
#import "AppDeal.h"

@implementation DatabaseManager

+(void)loginUser:(NSString *)username password:(NSString *)password withCompletion:(void(^)(BOOL success, NSError *error))completion {
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error) {
            NSLog(@"Log in attempt failed: %@", error.localizedDescription);
            completion(NO, error);
        }
        else {
            completion(YES, nil);
        }
    }];
}

+(void)registerUser:(User *)user withCompletion:(void(^)(BOOL success, NSError *error))completion{
    PFUser *newUser = [PFUser new];
    newUser.username = user.username;
    newUser.password = user.password;
    newUser.email = user.email;
    newUser[@"first_name"] = user.firstName;
    newUser[@"last_name"] = user.lastName;
    newUser[@"image"] = [DatabaseManager getPFFileFromImageData:user.profileImage];

    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        completion(succeeded, error);
    }];
}

+ (void)fetchItem:(NSString *)barcode viewController:(UIViewController *)vc withCompletion:(void(^)(NSArray *deals,NSError *error))completion {
    PFQuery *itemQuery = [Item query];
    [itemQuery whereKey:@"barcode" equalTo:barcode];
    [itemQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object != nil) {
            [DatabaseManager fetchDeals:object withCompletion:^(NSArray * _Nonnull deals, NSError * _Nonnull error) {
                if (deals.count > 0) {
                    [DatabaseManager createDealsFromFetchWithBlock:deals withCompletion:^(NSArray *appDeals) {
                        completion(appDeals, nil);
                    }];
                }
                else {
//                    [AlertManager dealNotFoundAlert:vc errorType:NoDealFoundError];
                }
            }];
        }
        else {
            completion(nil, error);
//            [AlertManager dealNotFoundAlert:vc errorType:NoItemFoundError];
        }
    }];
}

+ (void)createDealsFromFetchWithBlock:(NSArray *)serverDeals withCompletion:(void(^)(NSArray *appDeals))completion{
    NSMutableArray *result = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    for (PFObject *obj in serverDeals) {
        Deal *serverDeal = [DatabaseManager createDealFromObject:obj];
        if (serverDeal != nil) {
            dispatch_group_enter(group);
            [DatabaseManager createDealFromServerDealWithBlock:serverDeal withCompletion:^(AppDeal *appDeal, NSError *error) {
                [result addObject:appDeal];
                dispatch_group_leave(group);
            }];
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion(result);
    });
}

+ (Deal *)createDealFromObject:(PFObject *)object {
    Deal *deal = [Deal new];
    if (object[@"sellerName"] != nil && [object[@"sellerName"] isKindOfClass:[NSString class]]) {
        deal.sellerName = object[@"sellerName"];
    }
    else {
//        NSLog(@"error create deal from object");
        return nil;
    }
    if (object[@"price"] != nil && [object[@"price"] isKindOfClass:[NSNumber class]]) {
        deal.price = object[@"price"];
    }
    else {
        NSLog(@"error create deal from object");

        return nil;
    }
    if (object[@"item"] != nil && [object[@"item"] isKindOfClass:[PFObject class]]) {
        deal.item = [DatabaseManager createServerItemFromPFObject:object[@"item"]];
    }
    else {
        NSLog(@"error create deal from object");

        return nil;
    }
    if (object[@"link"] != nil && [object[@"link"] isKindOfClass:[NSString class]]) {
//        NSLog(@"error create deal from object");

        deal.itemURL = object[@"link"];
    }
    else {
        return nil;
    }
    return deal;
}

+ (void)createDealFromServerDealWithBlock:(Deal *)serverDeal withCompletion:(void(^)(AppDeal *appDeal ,NSError *error))completion {
    AppDeal *deal = [AppDeal new];
    deal.itemURL = [NSURL URLWithString:serverDeal.itemURL];
    deal.price = serverDeal.price;
    deal.sellerName = serverDeal.sellerName;
    [DatabaseManager createItemWithBlock:serverDeal.item withCompletion:^(AppItem *appItem, NSError *error) {
        if (error) {
            NSLog(@"Error at createDealFromServerDealWithBlock");
        }
        else {
            deal.item = appItem;
            completion(deal, nil);
        }
    }];
}

+ (Item *)createServerItemFromPFObject:(PFObject *)object {
    Item *serverItem = [Item new];
    
    if (object[@"name"] != nil && [object[@"name"] isKindOfClass:[NSString class]]) {
        serverItem.name = object[@"name"];
        NSLog(@"%@",serverItem.name);
    }
    if (object[@"information"] != nil && [object[@"information"] isKindOfClass:[NSString class]]) {
        serverItem.information = object[@"information"];
        NSLog(@"%@",serverItem.information);
    }
    if (object[@"barcode"] != nil && [object[@"barcode"] isKindOfClass:[NSString class]]) {
        serverItem.barcode = object[@"barcode"];
        NSLog(@"%@",serverItem.barcode);
    }
    if (object[@"image"] != nil) {
        serverItem.image = object[@"image"];
    }
    serverItem.objectId = object.objectId;

    return serverItem;
}

+ (void)createItemWithBlock:(Item *)serverItem withCompletion:(void(^)(AppItem *appItem ,NSError *error))completion {
    AppItem *item = [AppItem new];
    item.barcode = serverItem.barcode;
    item.name = serverItem.name;
    item.information = serverItem.information;
    item.identifier = serverItem.objectId;
    [serverItem.image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"eror create item with block");
            completion(nil,error);
        }
        else {
            item.image = data;
            completion(item, nil);
        }
    }];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (PFFileObject *)getPFFileFromImageData: (NSData *)imageData {
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (void)fetchDeals:(PFObject *)item withCompletion:(void(^)(NSArray *deals ,NSError *error))completion {
    
    PFQuery *setQuery = [Deal query];
    [setQuery includeKey:@"link"];
    [setQuery whereKey:@"link" equalTo:item];

    PFQuery *dealsQuery = [Deal query];
    [dealsQuery includeKey:@"item"];
    [dealsQuery whereKey:@"item" equalTo:item];
    
    [dealsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            completion(objects, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

@end
