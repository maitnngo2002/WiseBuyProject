//
//  DatabaseManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "DatabaseManager.h"
#import "Deal.h"
#import "AlertManager.h"
#import "AppDeal.h"

@implementation DatabaseManager

+(void)loginUser:(NSString *)username password:(NSString *)password withCompletion:(void(^)(BOOL success, NSError *error))completion {
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error) {
            NSLog(@"Log in attempt failed: %@", error.localizedDescription);
            completion(NO, error);
        }
        else {
            completion(YES, nil);
        }
    }];
}

+(void)registerUser:(User *)user withCompletion:(void(^)(BOOL success, NSError *error))completion{
    PFUser *newUser = [PFUser new];
    newUser.username = user.username;
    newUser.password = user.password;
    newUser.email = user.email;
    newUser[@"first_name"] = user.firstName;
    newUser[@"last_name"] = user.lastName;
    newUser[@"image"] = [DatabaseManager getPFFileFromImage:user.profileImage];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        completion(succeeded, error);
    }];
}

+(PFFileObject *) getPFFileFromImage: (NSData *)imageData {
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (void)fetchDeals:(PFObject *)item withCompletion:(void(^)(NSArray *deals ,NSError *error))completion {
    PFQuery *dealsQuery = [Deal query];
    [dealsQuery includeKey:@"item"];
    [dealsQuery whereKey:@"item" equalTo:item];
    
    [dealsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            completion(objects, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

+ (void)fetchItem:(NSString *)barcode viewController:(UIViewController *)vc withCompletion:(void(^)(NSArray *deals,NSError *error))completion {}
@end
