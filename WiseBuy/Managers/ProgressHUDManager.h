//
//  ProgressHUDManager.h
//  WiseBuy
//
//  Created by Mai Ngo on 7/19/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressHUDManager : NSObject

+ (void)setLoadingState:(BOOL)isLoading viewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
