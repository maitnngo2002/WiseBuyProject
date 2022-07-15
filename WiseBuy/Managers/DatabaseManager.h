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

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseManager : NSObject

+(void)loginUser:(NSString *)username password:(NSString *)password withCompletion:(void(^)(BOOL success, NSError *error))completion;
+(void)registerUser:(User *)user withCompletion:(void(^)(BOOL success, NSError *error))completion;
+ (void)logoutUser:(UIViewController *)vc;

+ (void)fetchItem:(NSString *)barcode viewController:(UIViewController *)vc withCompletion:(void(^)(NSArray *deals,NSError *error))completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
+ (PFFileObject *)getPFFileFromImageData: (NSData *)imageData;
+ (BOOL)checkIfItemAlreadyExist:(NSString *)barcode;
+ (void)saveDeal:(AppDeal *)appDeal withCompletion:(void(^)(NSError *error))completion;
+ (void)unsaveDeal:(AppDeal *)appDeal withCompletion:(void(^)(NSError *error))completion;
+ (void)fetchSavedDeals:(void(^)(NSArray *deals, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
