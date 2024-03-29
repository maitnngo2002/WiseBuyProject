//
//  AppItem.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/11/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface AppItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *information;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSString *identifier;

@end

NS_ASSUME_NONNULL_END
