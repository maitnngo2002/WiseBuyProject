//
//  APIManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "APIManager.h"

@implementation APIManager

-(id)init {
    self = [super init];
    if(self) {
        self.apiList = [[NSMutableArray alloc] init];
        [self.apiList addObject:[EbayAPI class]];
        [self.apiList addObject:[UPCDatabaseAPI class]];
        [self.apiList addObject:[SearchUPCAPI class]];
    }
    return self;
}

+ (void)fetchDealsFromAPIs: (NSString *)barcode {
    APIManager *apiManger = [[APIManager alloc] init];
    dispatch_group_t group = dispatch_group_create();
    for(Class <APIDelegate> class in apiManger.apiList) {
        dispatch_group_enter(group);
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            [class fetchDeals: barcode];
            dispatch_group_leave(group);
        });
    }
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

@end
