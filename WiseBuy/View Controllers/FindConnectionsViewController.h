//
//  FindConnectionsViewController.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/17/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FindConnectionsViewController : UIViewController
typedef NS_ENUM(NSInteger, errorType) {
    InputValidationError,
    LoginErrorMissingInput,
    ServerError
};
@end

NS_ASSUME_NONNULL_END
