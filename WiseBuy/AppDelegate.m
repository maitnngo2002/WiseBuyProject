//
//  AppDelegate.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"

@interface AppDelegate ()

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *clientKey = [dict objectForKey: @"client_Key"];
    NSString *appId = [dict objectForKey: @"application_Id"];
    
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"client_Key"]) {
        clientKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"client_Key"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"application_Id"]) {
        appId = [[NSUserDefaults standardUserDefaults] stringForKey:@"application_Id"];
    }
    
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            configuration.applicationId = appId;
            configuration.clientKey = clientKey;
            configuration.server = @"https://parseapi.back4app.com";
        }];
    [Parse initializeWithConfiguration:config];
    
    return YES;
}

@end
