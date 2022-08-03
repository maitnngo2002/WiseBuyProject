//
//  DatabaseManager.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Parse/Parse.h"
#import "AppDeal.h"
#import "Deal.h"
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseManager : NSObject

+(void)loginUser:(NSString *)username password:(NSString *)password withCompletion:(void(^)(BOOL success, NSError *error))completion;
+(void)registerUser:(User *)user withCompletion:(void(^)(BOOL success, NSError *error))completion;
+ (void)logoutUser:(UIViewController *)vc;
+ (void)getCurrentUser:(void(^)(User *user))completion;

+ (void)fetchItem:(NSString *)barcode viewController:(UIViewController *)vc withCompletion:(void(^)(NSArray<Deal *> *deals,NSError *error))completion;
+ (void)fetchRecentItems:(void(^)(NSArray<Item *> *items,NSError *error))completion;

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
+ (BOOL)checkIfItemAlreadyExist:(NSString *)barcode;
+ (void)saveDeal:(AppDeal *)appDeal withCompletion:(void(^)(NSError *error))completion;
+ (void)unsaveDeal:(AppDeal *)appDeal withCompletion:(void(^)(NSError *error))completion;
+ (void)fetchAllDeals:(void(^)(NSArray<Deal *> *deals ,NSError *error))completion;
+ (void)fetchSavedDeals:(void(^)(NSArray<Deal *> *deals, NSError *error))completion;
+ (void)isCurrentDealSaved:(NSString *)identifier withCompletion:(void(^)(_Bool hasDeal, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
