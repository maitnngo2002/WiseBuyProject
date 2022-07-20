//
//  Post.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/19/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *sellerName;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *itemLink;

@end

NS_ASSUME_NONNULL_END
