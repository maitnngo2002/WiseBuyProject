//
//  User.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "User.h"

@implementation User

+ (NSString *)getFullName:(User *)user {
    return [[user.firstName stringByAppendingString:@" "] stringByAppendingString:user.lastName];
}

@end
