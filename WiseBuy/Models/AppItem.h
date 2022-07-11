//
//  AppItem.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSString *identifier;

@end

NS_ASSUME_NONNULL_END
