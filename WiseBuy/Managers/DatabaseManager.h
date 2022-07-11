//
//  DatabaseManager.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseManager : NSObject

+(void)loginUser:(NSString *)username password:(NSString *)password withCompletion:(void(^)(BOOL success, NSError *error))completion;
+(void)registerUser:(User *)user withCompletion:(void(^)(BOOL success, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
