//
//  APIManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "APIManager.h"

@implementation APIManager

+ (void)fetchDealsFromAPIs: (NSString *)barcode {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [EbayAPI fetchDeals:barcode];
        
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [UPCDatabaseAPI fetchDeals:barcode];
        
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [SearchUPCAPI fetchDeals:barcode];
        
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
    
}

@end
