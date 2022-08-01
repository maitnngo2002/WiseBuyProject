//
//  Post.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/19/22.
//

#import "Post.h"

static NSString *const kPost = @"Post";

@implementation Post

@dynamic user;
@dynamic username;
@dynamic itemName;
@dynamic sellerName;
@dynamic price;
@dynamic link;

+ (nonnull NSString *)parseClassName {
    return kPost;
}


@end
