//
//  AlertManager.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlertManager : NSObject

typedef NS_ENUM(NSInteger, errorType) {
    InputValidationError,
    LoginErrorMissingInput,
    ServerError
};

typedef NS_ENUM(NSInteger, dealErrorType) {
    NoDealFoundError,
    NoItemFoundError
};

+ (void)loginAlert:(errorType)error errorString:(nullable NSString *) errorString viewController:(UIViewController *)vc;
+ (void)logoutAlert:(UIViewController *)vc;
+ (void)videoPermissionAlert:(UIViewController *)vc;
+ (void)dealsNotFoundAlert:(UIViewController *)vc errorType:(dealErrorType)error;
+ (void)cannotOpenLink:(UIViewController *)vc;
+ (void)cannotSaveDeal:(UIViewController *)vc;
+ (void)cannotPostDeal:(UIViewController *)vc;
+ (void)postDealAlert:(UIViewController *)vc;
+ (void)invalidUrlAlert:(UIViewController *)vc;
+ (void)invalidPriceInputAlert:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
