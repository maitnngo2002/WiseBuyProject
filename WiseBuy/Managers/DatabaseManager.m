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
#import "SceneDelegate.h"
#import "User.h"

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

+ (void)logoutUser:(UIViewController *)vc {
    SceneDelegate *sceneDelegate = (SceneDelegate *) vc.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *initialNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"InitialNavigationController"];
    sceneDelegate.window.rootViewController = initialNavigationController;
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        else {
            NSLog(@"Logout successful!");
        }
    }];
}

+ (void)getCurrentUser:(void(^)(User *user))completion {
    PFUser *user = [PFUser currentUser];
    User *currentUser = [User new];
    currentUser.firstName = user[@"first_name"];
    currentUser.lastName = user[@"last_name"];
    currentUser.email = user[@"email"];
    currentUser.username = user[@"username"];
    PFFileObject *profileImage = user[@"image"];
    [profileImage getDataInBackgroundWithBlock:^(NSData * _Nullable imageData, NSError * _Nullable error) {
        if (!error) {
            currentUser.profileImage = imageData;
        }
    }];
    [DatabaseManager fetchSavedDeals:^(NSArray * _Nonnull deals, NSError * _Nonnull error) {
        if (!error) {
            currentUser.savedDeals = (NSMutableArray *)deals;
            completion(currentUser);
        }
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
                    [AlertManager dealsNotFoundAlert:vc errorType:NoDealFoundError];
                }
            }];
            [DatabaseManager updateRecentItems:object withCompletion:^(NSError * _Nonnull error) {
                if (error) {
                    [AlertManager dealsNotFoundAlert:vc errorType:NoDealFoundError];
                }
            }];
        }
        else {
            completion(nil, error);
            [AlertManager dealsNotFoundAlert:vc errorType:NoItemFoundError];
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
    } else {
        return nil;
    }
    if (object[@"price"] != nil && [object[@"price"] isKindOfClass:[NSNumber class]]) {
        deal.price = object[@"price"];
    } else {
        return nil;
    }
    if (object[@"item"] != nil && [object[@"item"] isKindOfClass:[PFObject class]]) {
        deal.item = [DatabaseManager createServerItemFromPFObject:object[@"item"]];
    } else {
        return nil;
    }
    if (object[@"link"] != nil && [object[@"link"] isKindOfClass:[NSString class]]) {
        deal.itemURL = object[@"link"];
    } else {
        return nil;
    }
    deal.objectId = object.objectId;
    return deal;
}

+ (void)createDealFromServerDealWithBlock:(Deal *)serverDeal withCompletion:(void(^)(AppDeal *appDeal ,NSError *error))completion {
    AppDeal *deal = [AppDeal new];
    deal.itemURL = [NSURL URLWithString:serverDeal.itemURL];
    deal.price = serverDeal.price;
    deal.sellerName = serverDeal.sellerName;
    deal.identifier = serverDeal.objectId;

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
    }
    if (object[@"information"] != nil && [object[@"information"] isKindOfClass:[NSString class]]) {
        serverItem.information = object[@"information"];
    }
    if (object[@"barcode"] != nil && [object[@"barcode"] isKindOfClass:[NSString class]]) {
        serverItem.barcode = object[@"barcode"];
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

+ (BOOL)checkIfItemAlreadyExist:(NSString *)barcode {
    PFQuery *itemQuery = [Item query];
    [itemQuery whereKey:@"barcode" equalTo:barcode];
    
    if ([itemQuery countObjects ] > 0) {
        return YES;
    }
    
    return NO;
}

+ (void)saveDeal:(AppDeal *)appDeal withCompletion:(void(^)(NSError *error))completion {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"dealsSaved"];
    [DatabaseManager getPFObjectFromAppDeal:appDeal withCompletion:^(PFObject *object) {
        if (object != nil) {
            [relation addObject:object];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    completion(nil);
                }
                else {
                    completion(error);
                }
            }];
        }
    }];
}

+ (void)unsaveDeal:(AppDeal *)appDeal withCompletion:(void(^)(NSError *error))completion {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"dealsSaved"];
    [DatabaseManager getPFObjectFromAppDeal:appDeal withCompletion:^(PFObject *object) {
        if (object != nil) {
            [relation removeObject:object];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    completion(nil);
                }
                else {
                    completion(error);
                }
            }];
        }
    }];
}

+ (void)fetchSavedDeals:(void(^)(NSArray *deals, NSError *error))completion {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"dealsSaved"];
    PFQuery *query = [relation query];
    [query includeKey:@"dealsSaved.item"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            [DatabaseManager createSavedDealsFromFetchWithBlock:objects withCompletion:^(NSArray *appDeals) {
                completion(appDeals, nil);
            }];
            completion(objects, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

+ (void)fetchAllDeals:(void(^)(NSArray *deals ,NSError *error))completion {
    PFQuery *dealsQuery = [Deal query];
    [dealsQuery includeKey:@"item"];
    [dealsQuery orderByAscending:@"price"];
    
    [dealsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            [DatabaseManager createDealsFromFetchWithBlock:objects withCompletion:^(NSArray *appDeals) {
                completion(appDeals, nil);
            }];
        }
        else {
            completion(nil, error);
        }
    }];
}

+ (void)createSavedDealsFromFetchWithBlock:(NSArray *)serverDeals withCompletion:(void(^)(NSArray *appDeals))completion{
    NSMutableArray *result = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    for (PFObject *obj in serverDeals) {
        dispatch_group_enter(group);
        [DatabaseManager createDealFromObjectWithBlock:obj withCompletion:^(Deal *deal) {
            if (deal != nil) {
                [DatabaseManager createDealFromServerDealWithBlock:deal withCompletion:^(AppDeal *appDeal, NSError *error) {
                    [result addObject:appDeal];
                    dispatch_group_leave(group);
                }];
            }
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion(result);
    });
}

+ (void)isCurrentDealSaved:(NSString *)identifier withCompletion:(void(^)(_Bool hasDeal, NSError *error))completion {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"dealsSaved"];
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            for (PFObject *obj in objects) {
                if ([obj.objectId isEqualToString:identifier]) {
                    completion(YES, nil);
                    return;
                }
            }
            completion(NO, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

+ (void)createDealFromObjectWithBlock:(PFObject *)object withCompletion:(void(^)(Deal *deal))completion {
    Deal *deal = [Deal new];
    if (object[@"sellerName"] != nil && [object[@"sellerName"] isKindOfClass:[NSString class]]) {
        deal.sellerName = object[@"sellerName"];
    }
    else {
        completion(nil);
    }
    if (object[@"price"] != nil && [object[@"price"] isKindOfClass:[NSNumber class]]) {
        deal.price = object[@"price"];
    }
    else {
        completion(nil);
    }
    if (object[@"link"] != nil && [object[@"link"] isKindOfClass:[NSString class]]) {
        deal.itemURL = object[@"link"];
    }
    else {
        completion(nil);
    }
    if (object[@"item"] != nil && [object[@"item"] isKindOfClass:[PFObject class]]) {
        [DatabaseManager createServerItemFromPFObjectWithBlock:object[@"item"] withCompletion:^(Item *item) {
            if (item != nil) {
                deal.item = item;
                deal.objectId = object.objectId;
                completion(deal);
            }
            else {
                completion(nil);
            }
        }];
    }
    else {
        completion(nil);
    }
}

+ (void)createServerItemFromPFObjectWithBlock:(PFObject *)serverObject withCompletion:(void(^)(Item *item))completion {
    Item *serverItem = [Item new];
    PFQuery *itemQuery = [Item query];
    [itemQuery getObjectInBackgroundWithId:serverObject.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object[@"name"] != nil && [object[@"name"] isKindOfClass:[NSString class]]) {
            serverItem.name = object[@"name"];
        }
        if (object[@"info"] != nil && [object[@"info"] isKindOfClass:[NSString class]]) {
            serverItem.information = object[@"info"];
        }
        if (object[@"barcode"] != nil && [object[@"barcode"] isKindOfClass:[NSString class]]) {
            serverItem.barcode = object[@"barcode"];
        }
        if (object[@"image"] != nil) {
            serverItem.image = object[@"image"];
        }
        serverItem.objectId = object.objectId;
        completion(serverItem);
    }];
}

+ (void)getPFObjectFromAppDeal:(AppDeal *)appDeal withCompletion:(void(^)(PFObject *object))completion {
    PFQuery *dealQuery = [Deal query];
    [dealQuery getObjectInBackgroundWithId:appDeal.identifier block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            completion(object);
        }
        else {
            completion(nil);
        }
    }];
}

+ (void)fetchRecentItems:(void(^)(NSArray *items,NSError *error))completion {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"recentItems"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            [DatabaseManager createItemsFromFetchWithBlock:objects withCompletion:^(NSArray *appItems) {
                if (appItems.count > 0) {
                    completion(appItems, nil);
                }
                else {
                    completion(appItems, error);
                }
            }];
        }
        else {
            completion(nil, error);
        }
    }];
}

+ (void)createItemsFromFetchWithBlock:(NSArray *)serverItems withCompletion:(void(^)(NSArray *appItems))completion {
    NSMutableArray *result = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    for (PFObject *obj in serverItems) {
        Item *serverItem = [DatabaseManager createServerItemFromPFObject:obj];
        if (serverItem != nil) {
            dispatch_group_enter(group);
            [DatabaseManager createItemWithBlock:serverItem withCompletion:^(AppItem *appItem, NSError *error) {
                [result addObject:appItem];
                dispatch_group_leave(group);
            }];
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion(result);
    });
}

+ (void)updateRecentItems:(PFObject *)item withCompletion:(void(^)(NSError *error))completion {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"recentItems"];
    if (item != nil) {
        [relation addObject:item];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                completion(nil);
            }
            else {
                completion(error);
            }
        }];
    }
}

@end
