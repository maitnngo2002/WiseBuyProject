//
//  User.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSData *profileImage;
@property (nonatomic, strong) NSMutableArray *savedDeals;

+ (NSString *)getFullName: (User *)user;

@end

NS_ASSUME_NONNULL_END
